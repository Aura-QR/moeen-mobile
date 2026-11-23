# Mobile task (urgent): name the order on every MyFatoorah payment

## Why

On 20 Nov a teacher paid on the website, but the plan was not activated, because MyFatoorah's invoice did not say which order it was for. The website is fixed. **The app has the same gap.**

In `myfatoorah_payment_screen.dart`, the card payment and Apple Pay both send `MFExecutePaymentRequest(invoiceValue, sessionId)` with no order reference. The backend can then link the payment to the order only through the app's `GET /payments/myfatoorah/verify` call, made right after the payment. The plan is not activated if any of these happens:

- the app is closed or crashes after the card is charged;
- the phone loses its connection;
- the verify call fails.

With the order id on the invoice, MyFatoorah's webhook activates the plan by itself, even if the app is closed.

## Backend change (on `main`)

- A payment with **less than the order's amount** is no longer activated. It becomes `waiting_verification` for an admin to review.
  - Before, a lower `invoiceValue` from the device lowered the order's price and activated the plan.
  - Promo codes still work: they lower the order's `amount` when the order is created.
- When an invoice has no reference, verify picks the teacher's **current** open order (`pending` or `waiting_payment`). Before, it could pick an older order.

## The change: `lib/features/payment/presentation/screen/myfatoorah_payment_screen.dart`

The change is the same in both places: the card in `_executePayment()`, and Apple Pay in `_setupMyfatoorahSDK()`.

```dart
final executeRequest = MFExecutePaymentRequest(
  invoiceValue: invoiceAmount,
  sessionId: _sessionId,
  userDefinedField: _orderId.toString(),   // the backend links the payment to the order from this
  customerReference: _orderId.toString(),
);
```

- `_orderId` is already on the screen; it is the one sent to `initMyfatoorahPayment`.
- `invoiceAmount` must be the **order's amount** (`_amount`, from the order).
  - Don't compute it differently.
  - Less than the order's amount is never activated now.
- **Message when verify fails after a successful payment** (`invoiceStatus == "Paid"` but `verifyMyfatoorahPayment` returns an error or times out):
  - don't show «فشلت عملية الدفع»;
  - show: «استلمنا عملية الدفع ويجري تأكيدها، وسيُفعَّل اشتراكك تلقائيًا خلال دقائق. لا تُعِد الدفع.»;
  - retry verify 3 times, 3 seconds apart, before showing it.

Nothing else changes: the session, `verifyMyfatoorahPayment` and the success screen stay as they are.

## Test

**Before testing:** the owner must have done both of these:
- turned on the webhook in MyFatoorah;
- deployed the backend.

The owner decides on any real payment and pays with his own card. The developer doesn't use a card.

1. Pay a plan with a card from a teacher account with no plan. The plan becomes active and admin «المدفوعات» shows **مدفوع**.
2. Pay again from another account, and close the app right after the OTP. Within a minute or two, admin shows **مدفوع** and the plan is active (the webhook).
3. Apple Pay on an iPhone: same as test 1.
4. A declined card shows an error, and the plan stays inactive.

## Order of work

1. The backend is already on `main`; the owner deploys it.
2. Make the change, then run the tests above with the owner.
3. Ship a new app version (iOS and Android).
