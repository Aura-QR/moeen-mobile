
# Flutter Payment and Subscription Lifecycle V2

**Canonical mobile integration contract**  
**Updated:** 2026-08-27  
**Backend payment lifecycle commit:** `c7a296c`  
**Website payment lifecycle commit:** `910855f`  
**Gateway:** MyFatoorah  
**Currency:** SAR  
**Authentication:** Laravel Sanctum Bearer token

This document tells the Flutter team how to match the current website and backend payment behavior. Its main purpose is to prevent a customer with an active subscription from paying again, make repeated taps/reloads safe, resume an already-started payment, and correctly represent cancelled or duplicate charges.

> This document supersedes `FLUTTER_PAYMENT_SUBSCRIPTION_INTEGRATION.md`. That older document describes legacy Moyasar/manual-transfer routes that are not part of the currently registered API.

---

## 1. Required behavior

The Flutter app must follow all of these rules:

1. Fetch the current subscription before showing checkout.
2. If `is_subscribed == true`, hide the plans, promo-code controls, payment form, and pay button. Show the active subscription summary instead.
3. Never rely only on local cached subscription data. The backend is authoritative and protects every checkout entry point.
4. Handle HTTP `409` with code `already_subscribed` from order creation, session initiation, and payment execution.
5. Handle HTTP `409` with code `checkout_in_progress` by resuming the returned payment instead of creating another order.
6. Reuse the `order.id` and `session.session_id` returned by the backend. Do not manufacture a new order after a timeout or repeated tap.
7. Disable checkout buttons while a request is running, but still implement all server response branches because two devices or concurrent requests are possible.
8. Treat payment and order statuses as server-owned state.
9. Activate features only after the backend reports an active subscription. A client-side payment callback alone is not entitlement.
10. If a paid payment has `metadata.requires_refund == true`, show that it needs refund review and do not claim that the subscription was extended.

---

## 2. Why the lifecycle changed

Previously, the same customer could create multiple orders and payment attempts, producing records such as one paid row and several waiting rows. The current backend now enforces this lifecycle:

```text
Open checkout
    |
    +-- same plan/price/promo, not executed --> reuse the same order
    |
    +-- different plan, old checkout not executed --> cancel old order/payment
    |                                                and create replacement
    |
    +-- gateway payment already executed --> 409 checkout_in_progress
    |                                       resume existing payment URL
    |
    +-- active paid subscription --> 409 already_subscribed
                                     show subscription, never show payment UI
```

When one payment succeeds, the backend marks its order as paid, activates the subscription once, and cancels all competing open orders/payments. If an old cancelled gateway link is charged later, the charge is recorded as paid for reconciliation but the subscription is not extended again.

---

## 3. API setup

Use the environment-specific backend URL followed by `/api`:

```dart
final dio = Dio(BaseOptions(
  baseUrl: '$apiBaseUrl/api',
  headers: const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
));
```

Authenticated calls require:

```http
Authorization: Bearer <sanctum-token>
Accept: application/json
Content-Type: application/json
```

Add the token through an interceptor and store it using secure storage. Never place `MYFATOORAH_API_KEY` or `MYFATOORAH_SECRET_KEY` in Flutter.

---

## 4. Current endpoint inventory

### Customer endpoints

| Method | Endpoint | Auth | Purpose |
|---|---|---:|---|
| `GET` | `/subscriptions` | No | List active plans |
| `GET` | `/subscription/current` | Yes | Authoritative entitlement and usage |
| `GET` | `/orders` | Yes | Paginated order recovery/history |
| `POST` | `/orders` | Yes | Create or safely reuse an order |
| `GET` | `/orders/{orderId}` | Yes | Fetch an owned order |
| `POST` | `/orders/{orderId}/pay` | Yes | MyFatoorah session alias; prefer the explicit session endpoint |
| `GET` | `/payments/history` | Yes | Paginated payment history |
| `POST` | `/payments/myfatoorah/session` | Yes | Create/reuse embedded checkout session |
| `POST` | `/payments/myfatoorah/execute` | Yes | Execute session and receive 3DS/payment URL |
| `POST` | `/payments/myfatoorah/save-reference` | Yes | Save a MyFatoorah reference received directly from an SDK callback |
| `GET` | `/payments/myfatoorah/verify` | Yes | Verify gateway state and finalize payment |

### Server-only endpoint

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/payments/myfatoorah/webhook` | MyFatoorah server notification; never call it from Flutter |

### Admin endpoint

| Method | Endpoint | Auth | Purpose |
|---|---|---:|---|
| `GET` | `/admin/payments` | Admin | Search/filter payment records |

### Legacy routes Flutter must not use

The current router does not register the old manual bank-transfer, Moyasar customer verification, or manual approval/rejection endpoints. Do not implement calls to:

```text
/payments/manual
/payments/bank-transfer-info
/payments/save-reference
/payments/verify
/admin/payments/{id}/approve
/admin/payments/{id}/reject
```

The current customer checkout is MyFatoorah.

---

## 5. Subscription gate

Call this whenever checkout opens, after login restoration, when the app returns from a payment page, and after verification:

```http
GET /api/subscription/current
```

### Active paid subscription: HTTP 200

```json
{
  "plan": {
    "id": 2,
    "name": "فصل دراسي واحد",
    "slug": "semester",
    "price": "25.00",
    "is_unlimited": false,
    "ai_quota_per_month": 200,
    "lesson_limit_per_day": 15,
    "ai_quota_display": "200 شهرياً",
    "lesson_limit_display": "15 يومياً",
    "features": {}
  },
  "is_subscribed": true,
  "is_unlimited": false,
  "can_prepare_lesson": true,
  "subscription_ends_at": "2026-09-27T12:00:00+00:00",
  "subscription_days_remaining": 31,
  "is_in_trial": false,
  "trial_ends_at": null,
  "trial_days_remaining": 0,
  "usage": {
    "ai_used_this_month": 3,
    "lessons_prepared_today": 1,
    "ai_remaining": 197,
    "lessons_remaining_today": 14,
    "ai_remaining_display": "197",
    "lessons_remaining_today_display": "14"
  }
}
```

Flutter UI must show:

- `اشتراكك نشط بالفعل`
- current plan name
- subscription end date
- remaining days
- quota/usage if desired
- navigation to home and payment history

Flutter UI must not show:

- plan selection
- promo-code entry
- MyFatoorah form
- pay/continue buttons

### Trial: HTTP 200

A trial user can receive `is_subscribed: false` and `is_in_trial: true`. A trial is not a paid subscription, so checkout may remain available.

### Expired/no active access: HTTP 402

The response code is one of:

```text
subscription_expired
trial_expired
subscription_required
```

It also returns `action: subscribe`. For the checkout screen, these are eligible-to-subscribe states, not fatal errors. Continue by loading the plans.

### No teacher profile: HTTP 404

```json
{
  "message": "لا يوجد حساب معلم مرتبط",
  "code": "no_teacher_account",
  "status": 404
}
```

Stop checkout and ask the user to complete/fix the teacher account.

### Safe cache behavior

Cache subscription data for fast display, but refresh it from the API. If the network fails and the cache says the user is subscribed, conservatively hide checkout and show the cached subscription. Never use a stale `is_subscribed: false` value to bypass the server; the server will still return `already_subscribed`.

---

## 6. Plans

```http
GET /api/subscriptions
```

The response is a JSON array of plan objects. Only show plans with a numeric price greater than zero in paid checkout. Use the returned `id` as `service_id`.

The app may display the price, but it must never calculate or submit the charge amount. The backend calculates `original_amount`, discount, final `amount`, and currency.

---

## 7. Create or recover an order

```http
POST /api/orders
```

Request:

```json
{
  "service_id": 2,
  "promo_code": "OPTIONAL_CODE"
}
```

`promo_code` is optional and has a maximum length of 40.

### New order: HTTP 201

```json
{
  "message": "تم إنشاء الطلب بنجاح",
  "reused": false,
  "order": {
    "id": 38,
    "service_id": 2,
    "service": {
      "id": 2,
      "name": "فصل دراسي واحد",
      "slug": "semester",
      "price": "25.00",
      "features": {}
    },
    "original_amount": "25.00",
    "discount_amount": "0.00",
    "promo_code": null,
    "amount": "25.00",
    "currency": "SAR",
    "status": "pending",
    "payments": [],
    "created_at": "2026-08-27T10:00:00+00:00",
    "updated_at": "2026-08-27T10:00:00+00:00"
  }
}
```

### Reused safe order: HTTP 200

The shape is the same, with:

```json
{
  "message": "تم استعادة طلب الدفع المفتوح",
  "reused": true
}
```

Use the returned order exactly as if it were newly created. Do not consider HTTP 200 an error.

### Server behavior on plan changes

- If the old checkout was never executed, choosing a different plan cancels the abandoned order/payment and creates a replacement.
- If a gateway payment was already executed, the backend does not silently cancel it. It returns `checkout_in_progress` so Flutter can resume it.

### Free order

If discounts make the final backend amount `0`, the backend can immediately mark the order paid and activate access. If `order.status == paid`, skip MyFatoorah and refresh `/subscription/current`.

---

## 8. The two required HTTP 409 branches

These branches are part of the normal control flow and must not be rendered as generic errors.

### 8.1 `already_subscribed`

Possible from:

- `POST /orders`
- `POST /subscription/upgrade`
- `POST /orders/{id}/pay`
- `POST /payments/myfatoorah/session`
- `POST /payments/myfatoorah/execute`

Response:

```json
{
  "message": "لديك اشتراك نشط بالفعل ولا تحتاج إلى الدفع مرة أخرى.",
  "code": "already_subscribed",
  "status": 409,
  "errors": null,
  "action": "view_subscription",
  "details": {
    "subscription_url": "/api/subscription/current",
    "current_subscription": {
      "plan": {
        "id": 2,
        "name": "فصل دراسي واحد",
        "slug": "semester",
        "price": "25.00",
        "is_unlimited": false,
        "ai_quota_per_month": 200,
        "lesson_limit_per_day": 15,
        "ai_quota_display": "200 شهرياً",
        "lesson_limit_display": "15 يومياً",
        "features": {}
      },
      "is_subscribed": true,
      "subscription_ends_at": "2026-09-27T12:00:00+00:00",
      "subscription_days_remaining": 31
    }
  }
}
```

Required Flutter action:

1. Stop the loading/payment state.
2. Clear in-memory and persisted checkout state (`orderId`, `sessionId`, gateway URL/reference).
3. Update the local subscription cache using `details.current_subscription`.
4. Prefer refreshing `GET /subscription/current` for full usage data.
5. Replace the checkout UI with the active-subscription card.
6. Never retry the rejected checkout request automatically.

### 8.2 `checkout_in_progress`

Response:

```json
{
  "message": "لديك عملية دفع قيد التنفيذ. أكملها قبل بدء طلب جديد.",
  "code": "checkout_in_progress",
  "status": 409,
  "errors": null,
  "action": "resume_payment",
  "details": {
    "order": {
      "id": 37,
      "service_id": 3,
      "amount": "40.00",
      "currency": "SAR",
      "status": "waiting_payment",
      "payments": []
    },
    "payment_url": "https://sa.myfatoorah.com/pay/…",
    "payment_id": "gateway-payment-id",
    "invoice_id": "gateway-invoice-id"
  }
}
```

Required Flutter action:

1. Stop trying to create another order/session.
2. Persist `details.order.id`, `payment_id`, and `invoice_id` when present.
3. If `details.payment_url` is present, show `متابعة الدفع` and open that exact URL.
4. If the URL is absent but a payment/invoice reference exists, verify the reference.
5. If neither reference nor URL is present, refresh the order/history and show a processing state. Do not create a second order.

---

## 9. MyFatoorah session

Use the explicit endpoint:

```http
POST /api/payments/myfatoorah/session
```

Request:

```json
{
  "order_id": 38
}
```

Success: HTTP 200

```json
{
  "message": "تم إنشاء جلسة الدفع بنجاح",
  "session": {
    "order_id": 38,
    "session_id": "session-value",
    "country_code": "SAU",
    "amount": 25,
    "currency": "SAR",
    "portal_host": "https://sa.myfatoorah.com",
    "callback_url": "https://website.example/payment/myfatoorah/callback",
    "error_url": "https://website.example/payment/myfatoorah/error",
    "payment_methods": [],
    "session_data": {}
  }
}
```

Notes:

- The server caches an unexpired session for 20 minutes. Repeated calls return the same session and use one payment row.
- `amount` here is in SAR major units, not halalas.
- Treat `payment_methods` and `session_data` as flexible gateway JSON.
- A session creates no charge by itself.
- Do not request a second session when the order is already `waiting_payment`; handle `checkout_in_progress`.

---

## 10. Render and submit MyFatoorah

Use a maintained MyFatoorah Flutter integration if the app already has one. Otherwise use an in-app WebView for the hosted/embedded flow. Pass only values returned by the backend: session ID, country code, amount, currency, portal host, callback URL, and error URL.

The website implementation follows this logical behavior:

1. Render MyFatoorah with the backend session.
2. Submit the gateway form once.
3. If the gateway immediately returns `paymentURL`, redirect/open it.
4. Otherwise call the backend execute endpoint using the returned session ID, falling back to the backend session ID.
5. Open the returned `payment_url` for 3DS/authorization.

Do not collect, log, persist, or send raw card details through your own API.

---

## 11. Execute payment

```http
POST /api/payments/myfatoorah/execute
```

Request:

```json
{
  "order_id": 38,
  "session_id": "session-value"
}
```

Success: HTTP 200

```json
{
  "message": "تم تنفيذ عملية الدفع بنجاح",
  "payment_url": "https://sa.myfatoorah.com/pay/…",
  "invoice_id": "700",
  "payment_id": "gateway-payment-id"
}
```

Required Flutter action:

1. Persist `order_id`, `session_id`, `payment_id`, `invoice_id`, and `payment_url` before navigating away.
2. Open `payment_url` in the MyFatoorah flow.
3. Disable repeated submission while the request is active.

The endpoint is idempotent for an already-executed order: repeated calls return the existing URL/reference and do not execute another gateway payment. Flutter should still avoid unnecessary repeats.

If `session_id` does not match the order session, the backend returns validation error `422`; clear the invalid local session and reload the order/checkout state.

---

## 12. Saving an SDK reference

The execute endpoint already stores its returned gateway identifiers. Use `save-reference` only when the MyFatoorah SDK/embedded callback gives Flutter a payment ID directly before or instead of the normal execute response.

```http
POST /api/payments/myfatoorah/save-reference
```

```json
{
  "order_id": 38,
  "payment_id": "gateway-payment-id",
  "invoice_id": "700"
}
```

`invoice_id` is optional. Call this before leaving the app when possible. The operation updates/reuses the order's MyFatoorah payment record; it must not be used to create a different checkout.

---

## 13. Callback, WebView, and app resume

The backend currently returns web callback/error URLs from its MyFatoorah configuration. Flutter can integrate without changing those URLs using either approach below.

### Recommended: in-app WebView

1. Open `payment_url` in a WebView.
2. Watch navigation URLs.
3. When navigation starts with `session.callback_url`, extract the gateway key, stop/close the WebView, and call the verify endpoint.
4. When navigation starts with `session.error_url`, close the WebView and show cancelled/failed state, then refresh order/history.

Recognize these callback query keys:

```text
key
paymentId
payment_id
invoiceId
invoice_id
Id
id
```

Use `InvoiceId` as `key_type` when the captured key is `invoiceId` or `invoice_id`; otherwise use `PaymentId`.

### External browser

Before opening the browser, persist the execute response. When Flutter becomes active again, verify the stored `payment_id`; if that is absent, verify `invoice_id` using `key_type=InvoiceId`. Then refresh current subscription and payment history.

Do not mark the flow paid merely because the browser reached a success-looking page. Always verify with the backend.

---

## 14. Verify and finalize

Preferred request using a payment ID:

```http
GET /api/payments/myfatoorah/verify?key=gateway-payment-id&key_type=PaymentId
```

Using an invoice ID:

```http
GET /api/payments/myfatoorah/verify?key=700&key_type=InvoiceId
```

The endpoint also accepts the callback aliases listed in the previous section, but Flutter should normalize them to `key` and `key_type`.

Success/known-state response: HTTP 200

```json
{
  "message": "تم تأكيد الدفع بنجاح",
  "payment": {
    "id": 38,
    "order_id": 38,
    "payment_method": "myfatoorah",
    "gateway": "myfatoorah",
    "moyasar_payment_id": null,
    "myfatoorah_payment_id": "gateway-payment-id",
    "myfatoorah_invoice_id": "700",
    "transaction_id": "gateway-transaction-id",
    "amount": "25.00",
    "currency": "SAR",
    "status": "paid",
    "receipt_path": null,
    "receipt_url": null,
    "metadata": {},
    "paid_at": "2026-08-27T10:05:00+00:00",
    "verified_at": "2026-08-27T10:05:00+00:00",
    "created_at": "2026-08-27T10:02:00+00:00",
    "order": {}
  }
}
```

The message is `لم تكتمل عملية الدفع بعد` when the returned status is not paid.

Flutter branching:

| Payment status | Flutter result |
|---|---|
| `paid` | Refresh current subscription. If no refund flag, clear checkout and show success. |
| `processing` | Show pending, retain references, allow explicit refresh/verify. |
| `failed` | Show failed state and refresh the order before offering another checkout. |
| `cancelled` | Show cancelled; do not reopen its payment URL. Refresh orders/plans. |
| `waiting_verification` | Historical/other flow state; show waiting, never activate locally. |
| `rejected` | Historical/manual state; show rejected, never activate locally. |

Verification is safe to repeat. The backend also receives webhooks, so a payment may already be finalized when Flutter verifies it.

### Verification connection errors

- HTTP `502`, code `myfatoorah_connection_failed`
- HTTP `502`, code `myfatoorah_verification_failed`

Keep the stored reference, show a retry option, and do not create another order.

---

## 15. Successful payment side effects

When the first valid payment succeeds, the backend atomically:

1. marks the payment `paid`;
2. marks its order `paid`;
3. activates the selected subscription;
4. cancels every competing `pending` or `waiting_payment` order;
5. cancels their `pending`, `processing`, or `waiting_verification` payments.

Therefore, Flutter must refresh these endpoints after success:

```text
GET /subscription/current
GET /payments/history
```

If an older list now shows cancelled rows, that is expected cleanup, not a new failure.

---

## 16. Late duplicate charge and refund review

A rare race can occur when a user completes an old gateway link after another payment already activated a subscription. The backend must still record the real charge. It returns the payment as `paid` with metadata similar to:

```json
{
  "requires_refund": true,
  "activation_skipped_reason": "duplicate_payment_after_subscription",
  "duplicate_charge_detected_at": "2026-08-27T10:10:00+00:00"
}
```

Required Flutter behavior:

- Customer label: `تم تسجيل دفعة مكررة وسيتم مراجعة الاسترداد`.
- Admin/payment-history label: `مدفوع - يحتاج استرداد`.
- Use a warning/error color rather than the normal paid-success badge.
- Do not add time to the locally displayed subscription.
- Refresh `/subscription/current`; the backend deliberately skipped a second activation.
- Keep the payment reference visible for support.

Detection:

```dart
final requiresRefund = payment.status == PaymentStatus.paid &&
    payment.metadata?['requires_refund'] == true;
```

---

## 17. Order and payment statuses

### Order status

```dart
enum OrderStatus {
  pending,
  waitingPayment,
  paid,
  failed,
  cancelled,
}
```

| API value | Meaning |
|---|---|
| `pending` | Order exists; gateway payment not executed |
| `waiting_payment` | Gateway execution/reference exists; resume or verify |
| `paid` | Payment completed |
| `failed` | Gateway reports failure/expiry |
| `cancelled` | Superseded/competing checkout was closed |

### Payment status

```dart
enum PaymentStatus {
  pending,
  processing,
  waitingVerification,
  paid,
  failed,
  rejected,
  cancelled,
}
```

Recommended Arabic labels:

| API value | Label |
|---|---|
| `pending` | بانتظار الدفع |
| `processing` | قيد المعالجة |
| `waiting_verification` | بانتظار المراجعة |
| `paid` | مدفوع |
| `failed` | فشل |
| `rejected` | مرفوض |
| `cancelled` | ملغي |

Do not infer subscription access from order status alone. Always refresh `/subscription/current`.

---

## 18. API error model

Most API exceptions use this shape:

```json
{
  "message": "رسالة للمستخدم",
  "code": "machine_readable_code",
  "status": 422,
  "errors": {
    "field": ["field error"]
  },
  "action": null,
  "details": null
}
```

Some gateway controller errors contain only `message` and `code`, so all fields except `message` should be nullable in Flutter.

```dart
class ApiFailure implements Exception {
  ApiFailure({
    required this.httpStatus,
    required this.message,
    this.code,
    this.action,
    this.errors,
    this.details,
  });

  final int httpStatus;
  final String message;
  final String? code;
  final String? action;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? details;

  factory ApiFailure.fromDio(DioException error) {
    final raw = error.response?.data;
    final json = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    Map<String, dynamic>? mapValue(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : null;

    return ApiFailure(
      httpStatus: error.response?.statusCode ?? 0,
      message: json['message']?.toString() ?? 'تعذر إتمام الطلب',
      code: json['code']?.toString(),
      action: json['action']?.toString(),
      errors: mapValue(json['errors']),
      details: mapValue(json['details']),
    );
  }
}
```

Global handling priority:

1. `already_subscribed`
2. `checkout_in_progress`
3. `401 unauthenticated`
4. `402` subscription states
5. `403 forbidden`
6. `404 not_found`/`no_teacher_account`
7. `422 validation_error` or gateway request error
8. `502` gateway verification/connection error
9. `500 server_error`

---

## 19. Dart API layer sketch

The model classes are intentionally omitted here except for their required fields; generate them with the project's normal JSON tooling.

```dart
class PaymentApi {
  PaymentApi(this.dio);

  final Dio dio;

  Future<Map<String, dynamic>> currentSubscription() async {
    final response = await dio.get('/subscription/current');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> plans() async {
    final response = await dio.get('/subscriptions');
    return List<dynamic>.from(response.data as List);
  }

  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    String? promoCode,
  }) async {
    final response = await dio.post('/orders', data: {
      'service_id': serviceId,
      if (promoCode != null && promoCode.trim().isNotEmpty)
        'promo_code': promoCode.trim(),
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> initiateSession(int orderId) async {
    final response = await dio.post(
      '/payments/myfatoorah/session',
      data: {'order_id': orderId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> execute({
    required int orderId,
    required String sessionId,
  }) async {
    final response = await dio.post(
      '/payments/myfatoorah/execute',
      data: {'order_id': orderId, 'session_id': sessionId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> saveReference({
    required int orderId,
    required String paymentId,
    String? invoiceId,
  }) async {
    final response = await dio.post(
      '/payments/myfatoorah/save-reference',
      data: {
        'order_id': orderId,
        'payment_id': paymentId,
        if (invoiceId != null) 'invoice_id': invoiceId,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> verify({
    required String key,
    String keyType = 'PaymentId',
  }) async {
    final response = await dio.get(
      '/payments/myfatoorah/verify',
      queryParameters: {'key': key, 'key_type': keyType},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> paymentHistory({int page = 1}) async {
    final response = await dio.get(
      '/payments/history',
      queryParameters: {'page': page},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> order(int orderId) async {
    final response = await dio.get('/orders/$orderId');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
```

Wrap Dio exceptions once in the repository/interceptor and throw `ApiFailure`. Do not duplicate response-code parsing in widgets.

---

## 20. Checkout controller state machine

Recommended UI states:

```dart
sealed class CheckoutState {}

class CheckoutLoading extends CheckoutState {}
class ActiveSubscriptionVisible extends CheckoutState {}
class PlansVisible extends CheckoutState {}
class CreatingOrder extends CheckoutState {}
class LoadingGatewaySession extends CheckoutState {}
class GatewayFormVisible extends CheckoutState {}
class RedirectingToGateway extends CheckoutState {}
class PaymentProcessing extends CheckoutState {}
class PaymentSucceeded extends CheckoutState {}
class RefundReviewRequired extends CheckoutState {}
class CheckoutFailure extends CheckoutState {}
```

Core orchestration:

```dart
Future<void> startCheckout(int serviceId, String? promoCode) async {
  if (_requestInFlight) return;
  _requestInFlight = true;

  try {
    final orderResponse = await api.createOrder(
      serviceId: serviceId,
      promoCode: promoCode,
    );

    final order = Order.fromJson(orderResponse['order']);

    if (order.status == OrderStatus.paid) {
      await refreshSubscription();
      clearPersistedCheckout();
      return;
    }

    persistOrder(order.id);
    final sessionResponse = await api.initiateSession(order.id);
    final session = MyFatoorahSession.fromJson(sessionResponse['session']);
    persistSession(session);
    emit(GatewayFormVisible(session));
  } on ApiFailure catch (failure) {
    if (failure.code == 'already_subscribed') {
      await handleAlreadySubscribed(failure);
    } else if (failure.code == 'checkout_in_progress') {
      await handleCheckoutInProgress(failure);
    } else {
      emit(CheckoutFailure(failure.message));
    }
  } finally {
    _requestInFlight = false;
  }
}
```

Both 409 handlers must be shared by create-order, initiate-session, and execute calls.

---

## 21. Persisted recovery state

Persist only non-sensitive checkout identifiers:

```json
{
  "order_id": 38,
  "session_id": "session-value",
  "payment_id": "gateway-payment-id",
  "invoice_id": "700",
  "payment_url": "https://sa.myfatoorah.com/pay/…",
  "saved_at": "2026-08-27T10:03:00Z"
}
```

Never persist card number, CVV, expiry, gateway secret, or raw card form state.

On app launch/resume:

1. Refresh current subscription.
2. If active, clear checkout recovery data.
3. Otherwise, if `payment_id` exists, verify it.
4. Else if `invoice_id` exists, verify it as `InvoiceId`.
5. Else if `order_id` exists, fetch the order.
6. For `waiting_payment`, recover the latest payment/reference from the order or `/payments/history`.
7. For `pending`, request/reuse its session only after the user chooses to continue.
8. For `paid`, refresh subscription and clear recovery data.
9. For `failed` or `cancelled`, clear the unusable gateway URL and return to plan selection.

---

## 22. Payment history and admin parity

Customer history:

```http
GET /api/payments/history?page=1&per_page=15
```

The response uses Laravel pagination with `data`, `links`, and `meta`. Display newest first and include method, amount, status, date, plan, and gateway reference.

If the Flutter app includes admin payment management:

```http
GET /api/admin/payments?filter=cancelled&search=user@example.com&per_page=50
```

Supported filters:

```text
pending
paid
failed
cancelled
moyasar
myfatoorah
```

`pending` includes pending, processing, and waiting-verification payments. `failed` includes failed and rejected, while cancelled has its own filter.

The website admin now:

- includes a dedicated cancelled filter;
- renders cancelled as `ملغي`;
- recognizes MyFatoorah references;
- renders a paid late duplicate as `مدفوع - يحتاج استرداد`.

Flutter admin/history should match those rules.

---

## 23. Concurrency and retry rules

| Situation | Correct action |
|---|---|
| User double-taps Continue | Ignore second tap locally; accept 200 reused order if received |
| App retries create-order after timeout | Use returned/reused order; handle 409 resume |
| User chooses another plan before gateway execution | Call create-order for new selection; backend cancels unexecuted old checkout |
| User chooses another plan after gateway execution | Resume existing payment; do not create a competing checkout |
| Session request repeated within 20 minutes | Accept the same session |
| Execute request repeated | Accept the same payment URL/reference |
| Verify request repeated | Accept current server status |
| Payment webhook wins race with app verify | Refresh result; do not duplicate success side effects in Flutter |
| Subscription becomes active on another device | Handle `already_subscribed`, clear checkout, show subscription |
| Gateway cannot be reached | Keep identifiers and allow retry; do not make a new order |

---

## 24. Test checklist for Flutter

### Subscription gate

- [ ] Active subscriber sees plan, expiry, and remaining days but no payment controls.
- [ ] Trial user may open checkout.
- [ ] HTTP 402 expired/required state loads paid plans.
- [ ] Cached active subscription blocks checkout during a temporary refresh failure.
- [ ] `already_subscribed` at every checkout stage immediately replaces payment UI with subscription UI.

### Duplicate prevention

- [ ] Double-tapping Continue sends at most one local request.
- [ ] A backend `200` with `reused: true` continues normally.
- [ ] Selecting a different plan before execution uses the replacement order.
- [ ] `checkout_in_progress` opens the existing `payment_url`.
- [ ] No code path creates a new order after `checkout_in_progress`.

### Gateway

- [ ] Session data renders without any secret key in the app.
- [ ] Session/order/reference are persisted before leaving Flutter.
- [ ] Callback recognizes every supported query-key alias.
- [ ] Invoice callbacks verify with `InvoiceId`.
- [ ] App resume verifies stored references.
- [ ] `processing` is pending, not success.
- [ ] A 502 verification error offers retry and preserves the payment reference.

### Completion and history

- [ ] Normal `paid` refreshes subscription and clears checkout state.
- [ ] Competing records become visibly cancelled after refresh.
- [ ] Cancelled gateway links are never reopened.
- [ ] `requires_refund: true` shows refund-review wording and not normal success.
- [ ] Payment history displays MyFatoorah payment/invoice reference.
- [ ] Admin filter and labels match the website if admin screens exist.

### Security

- [ ] Bearer token stored securely.
- [ ] No gateway secret exists in Flutter source, assets, or remote logs.
- [ ] Raw card data never reaches the app backend or analytics.
- [ ] Flutter never sends or trusts a charge amount.
- [ ] Subscription features unlock only from refreshed backend entitlement.

---

## 25. Backend regression coverage already present

The backend feature tests cover:

- repeated order reuse;
- plan-change cancellation before execution;
- blocking/resuming executed checkout;
- 20-minute session reuse;
- idempotent payment execution;
- active-subscription blocking at all checkout entry points;
- cancelling competing orders after successful payment;
- recording a late duplicate charge for refund without extending access;
- keeping cancelled checkouts cancelled when the gateway is unpaid;
- cleanup of historical open rows for active subscribers.

Relevant tests:

```text
tests/Feature/PaymentLifecycleTest.php
tests/Feature/ActiveSubscriptionCheckoutTest.php
```

Run the backend verification with:

```bash
php artisan test tests/Feature/PaymentLifecycleTest.php tests/Feature/ActiveSubscriptionCheckoutTest.php
```

---

## 26. Flutter acceptance criteria

The Flutter integration is complete only when all of the following are true:

1. An active subscriber cannot see or submit checkout.
2. A stale Flutter state cannot bypass the backend's `already_subscribed` response.
3. Repeated taps/reloads reuse or resume existing server state.
4. Only one gateway checkout can be in progress per customer.
5. MyFatoorah callback/app-resume always verifies with the backend.
6. Normal paid state refreshes and displays the active subscription.
7. Cancelled competing rows are represented accurately.
8. Late duplicate charges are clearly marked for refund review and never extend the subscription twice.
9. The app does not call legacy/unregistered payment routes.
10. All error, retry, offline-resume, and two-device cases preserve server authority.

