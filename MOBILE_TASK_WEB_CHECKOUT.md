# App task: pay on the website instead of inside the app

**For:** the mobile app developer (Flutter).
**Backend:** ready on `main`.
**Do it after:** the website task `FRONTEND_TASK_APP_HANDOFF.md` is live (the app opens that page).
**Replaces:** `MOBILE_TASK_MYFATOORAH_REFERENCE.md`. Don't do that one.

## Why

The app takes payments with the MyFatoorah SDK. That has two problems:
1. **Payments can be lost.** The SDK payment carries no order reference. A teacher who pays and closes the app isn't activated; this happened with payment #136.
2. **The live MyFatoorah secret key is inside the app** (`Secrets.myfatoorahApiKey`). Anyone can pull it out of the app file.

From now on the app **doesn't take payments itself**. It opens the site's checkout in the phone's browser, already signed in. The site's checkout matches every payment to its order.

## 1. The switch: `GET /api/app/version`

The app already calls this at start (`AppUpdateService`). The answer now has a new field:

```json
{ "...": "...", "checkout": "web" }
```

- `"web"`: the subscribe buttons open the website (section 2).
- `"off"`: **hide paying in the app completely** (section 3).
- A missing field (old server) or any other value is the same as `"off"`.

The owner sets it per platform on the server (`APP_ANDROID_CHECKOUT`, `APP_IOS_CHECKOUT`), **with no app update**. If Apple or Google object, he switches that platform to `off`. Keep the last value you received in memory, and read it again on every app start.

## 2. `"web"`: open the site's checkout

Wherever the app has «اشترك» / «ترقية» / «جدّد» (the subscription screen, the limit dialogs, the trial-ended banner):

1. Call `POST /api/auth/web-handoff` (signed in, the app's token) with `{"next": "/checkout?service_id=<plan id>"}`. Leave out `service_id` when no plan is chosen: `{"next": "/checkout"}`.
2. The answer is `{"data": {"url": "...", "expires_in": 120}}`.
3. Open `data.url` **in the phone's browser**, using `url_launcher` with `LaunchMode.externalApplication`. **Not** in a WebView inside the app: Apple Pay and the bank's OTP page work properly only in the real browser.
   - The link works **once** and for **2 minutes**. Ask for a new one on every tap; never store it or reuse it.
   - Never log the URL or show it: it holds a sign-in code.
4. While waiting, show a small loader on the button. On an error, show the server's `message`.

**When the teacher comes back to the app** (`AppLifecycleState.resumed`) after a tap from step 3:
- refresh the subscription (`GET /api/auth/me` and the subscription you already load);
- if it's now active, show «تم تفعيل اشتراكك 🎉» and close the subscription screen.

## 3. `"off"`: no paying in the app

- Hide every subscribe / upgrade / renew button, every price, and every link to the site's checkout.
- On the subscription screen, show the current plan and its end date only.
- Where a dialog used to say «اشترك», show only the limit message: «انتهت المحاولات المتاحة في باقتك الحالية.», with no button to pay and no mention of the website. This is Apple's rule: no pointing to a payment outside the app.

## 4. Remove the in-app payment

- Remove the MyFatoorah SDK screens (`myfatoorah_payment_screen.dart` and its cubit and states), the package from `pubspec.yaml`, and the in-app checkout flow.
- **Delete `Secrets.myfatoorahApiKey`** from the code. After this release, the owner will make a new key in MyFatoorah's dashboard and disable the old one. So nothing in the app may need it.
- Keep `admin_payments_table_widget.dart` (admins viewing payments): it doesn't pay.

## 5. Release

1. Bump the version. Tell the owner the version number.
2. After the store approves, the owner raises `APP_*_MINIMUM_VERSION` on the server to the new version. Old versions then must update. This is needed because the old key will stop working, and old versions would fail at payment.

## 6. Test cases

- [ ] `checkout: "web"`: «اشترك» opens the browser on the checkout, signed in, with the chosen plan.
- [ ] Tapping twice opens two fresh links. Each works once.
- [ ] After paying in the browser and going back to the app, the subscription shows active without signing out and in.
- [ ] `checkout: "off"` (set on the server): no price, no pay button, no link to the site anywhere in the app.
- [ ] No MyFatoorah key or SDK left in the app: search the code for `myfatoorah` (only the admin table may stay).
- [ ] Android and iPhone, both.
