# Moeen Flutter Payment + Subscription Integration

**Backend:** Laravel API + Sanctum Bearer tokens  
**Mobile target:** Flutter iOS + Android  
**Payment methods:** Moyasar online card payment + manual bank transfer  
**Currency:** SAR  

This document is the mobile contract for subscriptions, orders, payments, and service activation.

---

## 1. Core Rules

- Flutter must use Bearer token auth for all payment endpoints except `GET /api/subscriptions`.
- Never send or trust an amount from Flutter. The backend calculates the amount from the selected subscription.
- Never put `MOYASAR_SECRET_KEY` in Flutter. Only the backend uses it.
- Flutter may receive `publishable_key` from `POST /api/orders/{order}/pay`.
- The paid subscription is activated only after backend verification succeeds.
- Payment states are server-owned. Flutter should render state from API responses.

Required headers for authenticated calls:

```http
Accept: application/json
Authorization: Bearer <token>
Content-Type: application/json
```

For receipt upload, use `multipart/form-data` and do not manually force a JSON content type.

---

## 2. Subscription System

### 2.1 List Plans

```http
GET /api/subscriptions
```

Auth: not required.

Response:

```json
[
  {
    "id": 2,
    "name": "فصل دراسي واحد",
    "slug": "semester",
    "price": "99.00",
    "ai_quota_per_month": 200,
    "lesson_limit_per_day": 15,
    "features": {
      "basic_preparation": true,
      "content_bank": true,
      "bulk_prepare": true
    }
  }
]
```

Flutter UI:
- Show only plans with `price > 0` in checkout unless you explicitly support free plan selection.
- Use `id` as `service_id` when creating an order.
- Display `price` as text/decimal. Do not use it for payment calculations.

### 2.2 Current Subscription

```http
GET /api/subscription/current
```

Auth: required.

Success:

```json
{
  "plan": {
    "id": 2,
    "name": "فصل دراسي واحد",
    "slug": "semester",
    "price": "99.00",
    "ai_quota_per_month": 200,
    "lesson_limit_per_day": 15,
    "features": {}
  },
  "usage": {
    "ai_used_this_month": 3,
    "lessons_prepared_today": 1,
    "ai_remaining": 197,
    "lessons_remaining_today": 14
  }
}
```

No subscription:

```json
{
  "message": "لا يوجد اشتراك حالي",
  "code": "no_active_subscription",
  "status": 404,
  "action": null,
  "errors": null,
  "details": null
}
```

Flutter behavior:
- On `404/no_active_subscription`, show plans and a “Subscribe” CTA.
- On successful payment, call this endpoint again to refresh app entitlement.

---

## 3. Data Models

### Order Status

```dart
enum OrderStatus {
  pending,
  waitingPayment,
  paid,
  failed,
  cancelled,
}
```

API values:

```text
pending
waiting_payment
paid
failed
cancelled
```

### Payment Status

```text
pending
processing
waiting_verification
paid
failed
rejected
cancelled
```

Recommended UI labels:

| API status | Arabic label | Meaning |
|---|---|---|
| `pending` | بانتظار الدفع | Created but not completed |
| `processing` | قيد المعالجة | Moyasar payment created or being verified |
| `waiting_verification` | بانتظار المراجعة | Manual receipt uploaded |
| `paid` | مدفوع | Subscription activated |
| `failed` | فشل الدفع | Gateway or validation failed |
| `rejected` | مرفوض | Admin rejected manual receipt |
| `cancelled` | ملغي | Payment/order cancelled |

### Payment Method

```text
moyasar
manual_bank_transfer
```

---

## 4. Recommended Flutter Checkout Flow

1. `GET /api/subscriptions`
2. User selects a paid plan.
3. `POST /api/orders` with selected `service_id`.
4. User selects payment method:
   - Moyasar online payment
   - Manual bank transfer
5. Complete the selected flow.
6. On success/pending, call:
   - `GET /api/payments/history`
   - `GET /api/subscription/current`

---

## 5. Create Order

```http
POST /api/orders
```

Auth: required.

Request:

```json
{
  "service_id": 2
}
```

Do not send `amount`, `currency`, or user info.

Success `201`:

```json
{
  "message": "تم إنشاء الطلب بنجاح",
  "order": {
    "id": 15,
    "service_id": 2,
    "service": {
      "id": 2,
      "name": "فصل دراسي واحد",
      "slug": "semester",
      "price": "99.00",
      "features": {}
    },
    "amount": "99.00",
    "currency": "SAR",
    "status": "pending",
    "payments": [],
    "created_at": "2026-07-12T10:00:00+00:00"
  }
}
```

Flutter:
- Store `order.id` in checkout state.
- Use the returned `amount` only for display.
- If app is closed, you can use `GET /api/orders` or `GET /api/payments/history` to recover.

---

## 6. Moyasar Online Payment Flow

### 6.1 Request Moyasar Checkout Config

```http
POST /api/orders/{order_id}/pay
```

Auth: required.

Success:

```json
{
  "order_id": 15,
  "amount": 9900,
  "currency": "SAR",
  "description": "اشتراك حضّر - فصل دراسي واحد",
  "publishable_key": "pk_test_...",
  "callback_url": "https://your-domain/payment/callback",
  "supported_networks": ["visa", "mastercard", "mada"],
  "methods": ["creditcard"],
  "metadata": {
    "order_id": "15",
    "user_id": "2"
  }
}
```

Important:
- `amount` is in halalas. `9900` means `99.00 SAR`.
- Use the returned `publishable_key`; do not hardcode it if possible.
- The backend callback URL may be web-oriented. For Flutter, use one of the mobile strategies below.

### 6.2 Flutter Moyasar Integration Options

#### Option A: Use Moyasar payment page/WebView

Recommended if you do not have an official Flutter-native Moyasar package in your stack.

Flow:
1. Open a WebView containing a small local HTML page that loads Moyasar JS.
2. Initialize Moyasar with the config from `/orders/{id}/pay`.
3. Intercept navigation to `callback_url`.
4. Extract payment id from query parameters.
5. Call backend `GET /api/payments/verify?id=PAYMENT_ID`.

The callback may contain either:

```text
?id=PAYMENT_ID
```

or, depending on SDK/custom flow:

```text
?payment_id=PAYMENT_ID
```

Flutter should support both.

#### Option B: Use Moyasar native/mobile package

If using an official or vetted Flutter package:
1. Pass the backend-provided amount, currency, description, publishable key, and metadata.
2. When Moyasar creates a payment, capture its `payment.id`.
3. Immediately call `POST /api/payments/save-reference`.
4. After 3DS/payment completion, call `GET /api/payments/verify?id=PAYMENT_ID`.

### 6.3 Save Reference Immediately

```http
POST /api/payments/save-reference
```

Auth: required.

Call this as soon as Moyasar creates a payment id, before the user completes 3D Secure.

Request:

```json
{
  "order_id": 15,
  "moyasar_payment_id": "ea4c95ac-d038-441e-aa53-1487185c4e4d"
}
```

Success:

```json
{
  "message": "تم حفظ مرجع الدفع",
  "payment": {
    "id": 20,
    "order_id": 15,
    "payment_method": "moyasar",
    "gateway": "moyasar",
    "moyasar_payment_id": "ea4c95ac-d038-441e-aa53-1487185c4e4d",
    "amount": "99.00",
    "currency": "SAR",
    "status": "processing"
  }
}
```

Why this matters:
- If the user closes the app during 3DS, backend still knows which order the Moyasar payment belongs to.

### 6.4 Verify Payment

```http
GET /api/payments/verify?id=PAYMENT_ID
```

Auth: required.

Success paid:

```json
{
  "message": "تم تأكيد الدفع بنجاح",
  "payment": {
    "id": 20,
    "order_id": 15,
    "payment_method": "moyasar",
    "gateway": "moyasar",
    "moyasar_payment_id": "ea4c95ac-d038-441e-aa53-1487185c4e4d",
    "amount": "99.00",
    "currency": "SAR",
    "status": "paid",
    "paid_at": "2026-07-12T10:05:00+00:00",
    "verified_at": "2026-07-12T10:05:00+00:00"
  }
}
```

Not yet paid:

```json
{
  "message": "لم تكتمل عملية الدفع بعد",
  "payment": {
    "status": "processing"
  }
}
```

Gateway/config error:

```json
{
  "message": "تعذر التحقق من الدفع من بوابة الدفع. راجع إعدادات Moyasar أو حاول لاحقًا.",
  "code": "moyasar_verification_failed"
}
```

HTTP status for gateway verification failure: `502`.

Flutter behavior:
- If `status == paid`, show success and refresh subscription.
- If `status == processing`, show pending and let user retry verification.
- If `502/moyasar_verification_failed`, show “تعذر التحقق من الدفع، حاول لاحقًا” and log the payment id for support.
- Never activate subscription locally before backend says `paid`.

---

## 7. Manual Bank Transfer Flow

### 7.1 Get Bank Transfer Info

```http
GET /api/payments/bank-transfer-info
```

Auth: required.

Response:

```json
{
  "bank_name": "Bank Name",
  "iban": "SA0000000000000000000000",
  "account_holder": "Moeen",
  "instructions": "حوّل قيمة الطلب ثم ارفع صورة الإيصال للمراجعة."
}
```

Flutter UI:
- Show bank name, IBAN, account holder, and instructions.
- Add “copy IBAN” button.
- Show order amount from the created order.

### 7.2 Upload Receipt

```http
POST /api/payments/manual
```

Auth: required.  
Content type: `multipart/form-data`.

Fields:

| Field | Type | Required |
|---|---|---|
| `order_id` | integer/string | yes |
| `receipt` | file | yes |

Allowed file types:

```text
jpg, jpeg, png, pdf
```

Max size:

```text
5 MB
```

Example Dio upload:

```dart
final formData = FormData.fromMap({
  'order_id': orderId.toString(),
  'receipt': await MultipartFile.fromFile(
    file.path,
    filename: fileName,
  ),
});

final response = await dio.post(
  '/payments/manual',
  data: formData,
  options: Options(
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ),
);
```

Success `201`:

```json
{
  "message": "تم رفع الإيصال وسيتم مراجعته",
  "payment": {
    "id": 21,
    "order_id": 15,
    "payment_method": "manual_bank_transfer",
    "gateway": "manual",
    "amount": "99.00",
    "currency": "SAR",
    "status": "waiting_verification",
    "receipt_path": "payment-receipts/...",
    "paid_at": null,
    "verified_at": null
  }
}
```

Flutter behavior:
- Show pending review screen.
- Tell user they will be notified/updated after admin review.
- Polling is not required, but payment history refresh is useful.

### 7.3 Admin Result

Admin approves:
- `payments.status = paid`
- `orders.status = paid`
- teacher subscription is activated

Admin rejects:
- `payments.status = rejected`
- `orders.status = waiting_payment`
- user can upload another receipt for the same order or create a new order

Flutter behavior:
- In payment history, if status is `rejected`, show upload-again CTA.
- If status is `waiting_verification`, disable duplicate upload unless the product wants multiple receipts.

---

## 8. Payment History

```http
GET /api/payments/history
```

Auth: required.

Response:

```json
{
  "data": [
    {
      "id": 20,
      "order_id": 15,
      "payment_method": "moyasar",
      "gateway": "moyasar",
      "moyasar_payment_id": "ea4c95ac-d038-441e-aa53-1487185c4e4d",
      "transaction_id": "txn_123",
      "amount": "99.00",
      "currency": "SAR",
      "status": "paid",
      "paid_at": "2026-07-12T10:05:00+00:00",
      "verified_at": "2026-07-12T10:05:00+00:00",
      "created_at": "2026-07-12T10:02:00+00:00",
      "order": {
        "id": 15,
        "service_id": 2,
        "service": {
          "name": "فصل دراسي واحد",
          "slug": "semester",
          "price": "99.00"
        },
        "amount": "99.00",
        "currency": "SAR",
        "status": "paid"
      }
    }
  ],
  "links": {},
  "meta": {}
}
```

Flutter:
- Display newest first.
- Show method, amount, status, date, and subscription name.
- Add retry verify action for `processing` Moyasar payments.

---

## 9. Orders

### List Orders

```http
GET /api/orders
```

Auth: required.

Use for recovery if app was closed during checkout.

### Show Order

```http
GET /api/orders/{order_id}
```

Auth: required. The order must belong to the current user.

---

## 10. Error Handling

Common payment errors:

| HTTP | Code/message | Meaning | Flutter behavior |
|---|---|---|---|
| 401 | unauthenticated | Token missing/expired | Logout and show login |
| 403 | Forbidden | Order/payment belongs to another user | Show generic access error |
| 404 | Not found | Order/payment missing | Refresh checkout state |
| 422 | validation errors | Missing fields, invalid file | Show field errors |
| 502 | `moyasar_connection_failed` | Backend could not reach Moyasar | Retry later |
| 502 | `moyasar_verification_failed` | Moyasar rejected verification or gateway error | Show pending/support message |

Validation error shape:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "receipt": ["The receipt field is required."]
  }
}
```

---

## 11. Recommended Screens

### Subscription/Plans Screen

- Calls `GET /api/subscriptions`.
- Shows plan cards.
- If authenticated user has active plan, show current usage from `/subscription/current`.
- CTA: “اشترك الآن” or “ترقية الاشتراك”.

### Checkout Screen

- Creates order with `POST /api/orders`.
- Shows order amount and plan.
- Lets user select:
  - online payment
  - bank transfer

### Moyasar Payment Screen

- Gets config from `POST /api/orders/{id}/pay`.
- Starts Moyasar flow.
- Saves reference immediately after receiving payment id.
- Verifies payment after redirect/completion.

### Bank Transfer Screen

- Shows bank info from `/payments/bank-transfer-info`.
- Uploads receipt via `/payments/manual`.
- Shows pending review.

### Payment Result Screens

- Success: payment status `paid`.
- Pending: status `processing` or `waiting_verification`.
- Failed: status `failed`, `rejected`, or verification endpoint error.

### Payment History Screen

- Calls `/payments/history`.
- Supports retry verify for `processing` Moyasar payments.
- Supports upload again for rejected manual payments.

---

## 12. Dart Model Sketches

```dart
class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String price;
  final int aiQuotaPerMonth;
  final int lessonLimitPerDay;
  final Map<String, dynamic>? features;
}

class Order {
  final int id;
  final int serviceId;
  final String amount;
  final String currency;
  final String status;
  final SubscriptionPlan? service;
}

class Payment {
  final int id;
  final int orderId;
  final String paymentMethod;
  final String? gateway;
  final String? moyasarPaymentId;
  final String amount;
  final String currency;
  final String status;
  final String? paidAt;
  final String? verifiedAt;
  final Order? order;
}

class MoyasarCheckout {
  final int orderId;
  final int amount; // halalas
  final String currency;
  final String description;
  final String publishableKey;
  final String callbackUrl;
  final List<String> supportedNetworks;
  final List<String> methods;
  final Map<String, String> metadata;
}
```

---

## 13. Dio Service Sketch

```dart
class PaymentApi {
  final Dio dio;

  PaymentApi(this.dio);

  Future<List<SubscriptionPlan>> getSubscriptions() async {
    final res = await dio.get('/subscriptions');
    return (res.data as List)
        .map((e) => SubscriptionPlan.fromJson(e))
        .toList();
  }

  Future<Order> createOrder(int serviceId) async {
    final res = await dio.post('/orders', data: {'service_id': serviceId});
    return Order.fromJson(res.data['order']);
  }

  Future<MoyasarCheckout> getCheckout(int orderId) async {
    final res = await dio.post('/orders/$orderId/pay');
    return MoyasarCheckout.fromJson(res.data);
  }

  Future<Payment> saveReference({
    required int orderId,
    required String moyasarPaymentId,
  }) async {
    final res = await dio.post('/payments/save-reference', data: {
      'order_id': orderId,
      'moyasar_payment_id': moyasarPaymentId,
    });
    return Payment.fromJson(res.data['payment']);
  }

  Future<Payment> verifyPayment(String paymentId) async {
    final res = await dio.get(
      '/payments/verify',
      queryParameters: {'id': paymentId},
    );
    return Payment.fromJson(res.data['payment']);
  }

  Future<Payment> uploadManualReceipt({
    required int orderId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'order_id': orderId.toString(),
      'receipt': await MultipartFile.fromFile(filePath),
    });

    final res = await dio.post('/payments/manual', data: formData);
    return Payment.fromJson(res.data['payment']);
  }
}
```

---

## 14. Testing Checklist

- [ ] `GET /api/subscriptions` loads plans before login.
- [ ] Login stores Sanctum token securely.
- [ ] `GET /api/subscription/current` handles active and inactive subscription.
- [ ] `POST /api/orders` creates an order with server-calculated amount.
- [ ] Online payment receives Moyasar config with `amount` in halalas.
- [ ] Moyasar payment id is saved using `/payments/save-reference`.
- [ ] App can recover after close and verify payment id.
- [ ] `GET /api/payments/verify?id=...` marks payment paid only after backend verification.
- [ ] Wrong Moyasar credentials return `502` with `moyasar_verification_failed`.
- [ ] Bank info screen loads `/payments/bank-transfer-info`.
- [ ] Receipt upload supports JPG, JPEG, PNG, PDF.
- [ ] Rejected receipt appears as `rejected` in history.
- [ ] Approved manual payment activates `/subscription/current`.
- [ ] 401 clears token and returns to login.

---

## 15. Production Notes

Backend env must be configured on the production server:

```env
MOYASAR_BASE_URL=https://api.moyasar.com/v1
MOYASAR_PUBLISHABLE_KEY=pk_test_or_pk_live...
MOYASAR_SECRET_KEY=sk_test_or_sk_live...
MOYASAR_CALLBACK_URL=https://your-mobile-or-web-callback/payment/callback
PAYMENT_CURRENCY=SAR
BANK_TRANSFER_BANK_NAME=...
BANK_TRANSFER_IBAN=...
BANK_TRANSFER_ACCOUNT_HOLDER=...
BANK_TRANSFER_INSTRUCTIONS=...
```

After changing production env:

```bash
php artisan optimize:clear
php artisan config:clear
```

For Moyasar:
- `pk_test_` must be paired with `sk_test_`.
- `pk_live_` must be paired with `sk_live_`.
- Both keys must belong to the same Moyasar account.
- Flutter must never contain the secret key.

