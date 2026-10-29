# Front task: fixing a teacher's mistyped email (admin) and the «email_bounced» / «email_unverified» messages

**For:** Arwa (and the mobile developer for point 2).
**Backend:** done (`416c59e`). See `docs/LIMITS_SETTINGS.md` §5.

## Why
Some teachers sign up with a mistyped address (e.g. `…@estg.mow.gov.sa` instead of `moe.gov.sa`). Our emails to them bounce, so they never get the confirmation. Now, when Resend reports a bounce, that account's **free trial pauses** until the address is fixed. Paid accounts are never affected.

## 1. Admin: edit the email (site only)
In `/admin/teachers` → the edit dialog (`app/admin/teachers/page.tsx`, the `updateAdminTeacher` call):
- Add an **«البريد الإلكتروني»** field, filled with the current email.
- Send `email` in the `PATCH /api/admin/teachers/{id}` body only when it changed.
- The backend lowercases it, clears the bounce, marks it unverified and sends a new confirmation email.
- **422** when the address belongs to another account: show `errors.email[0]` under the field.
- After saving, show «تم تحديث البريد وإرسال رسالة تأكيد جديدة».

## 2. Teacher: the message (site and app)
AI tools and preparation can now answer:
```json
{ "code": "email_bounced", "status": 403, "action": "contact_support",
  "message": "البريد الإلكتروني الذي سجّلت به (…) غير صحيح ولم تصل إليه رسائلنا. سجّل من جديد ببريدك الصحيح، أو تواصل معنا لتصحيحه، لتكمل تجربتك المجانية.",
  "details": { "email": "…" } }
```
- Show `message` as it is, with a **«تواصل معنا»** button (the existing contact page/support chat).
- If the existing error handling already shows `message`, only the button is new.

**Also `email_unverified`** (a free trial older than 2 days whose email isn't confirmed yet):
```json
{ "code": "email_unverified", "status": 403, "action": "verify_email",
  "message": "أكّد بريدك الإلكتروني (…) لتكمل تجربتك المجانية: افتح الرسالة التي أرسلناها إليك واضغط رابط التأكيد. لم تصلك؟ أعد إرسالها من الشريط أعلى الصفحة.",
  "details": { "email": "…" } }
```
- Show `message` with a **«إعادة إرسال رسالة التأكيد»** button: `POST /api/auth/email/resend-verification` (the same call as `EmailVerificationBanner`).
- After the teacher confirms, everything works again (no reload of anything else needed).

## Check
- [ ] Admin changes a teacher's email → the teacher gets a confirmation email at the new address.
- [ ] A paused trial account sees the message and the contact button when it opens an AI tool.
