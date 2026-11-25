# App task: the official evaluation form for each role (T9)

**For:** the mobile app developer (Flutter).
**Do it after:** the backend task `docs/BACKEND_TASK_PERFORMANCE_FORMS.md` is on the server.
**API:** `docs/PORTFOLIO_AND_ACHIEVEMENTS_API.md`, section 1.1.
**Builds on:** `docs/MOBILE_TASK_PERFORMANCE.md` (the performance screen you already made).

## Why

Until now every role showed the teacher's 11 elements and weights. The Ministry has a different form for the activity leader, the health guide and the kindergarten teacher. The backend now sends each item's number and weight **from the portfolio's role**. The app must not hold any weights of its own.

Older app versions keep working: the API only adds fields.

## 1. The performance screen (`GET /portfolios/{id}/performance`)

- Keep showing «العنصر N», the title and the weight exactly as the API sends them. **Remove any weight or element number written in the app's code**, if there is one.
- Each item has a new `official` (true/false).
  - `official: true`: the role's form elements, in the order the API sends.
  - `official: false`: show them after the form, under «بنود إضافية (ليست من نموذج تقييم دورك)». No number, no weight, no stars. Evidence and uploads work as usual.
- The self-rating summary is unchanged: it comes from `rating`.

## 2. The element picker on documents (bottom sheet)

- `GET /portfolios/roles` now gives each role a `form: [{key, title, number, weight}]`.
- **Which list to show:** the role of the teacher's most recently updated portfolio (`GET /portfolios`). Show that role's `form` as «العنصر N – title». No portfolio → the `teacher` role's form.
- If the document's current `element` isn't in that list, add it at the end so the current value still shows.
- Keep «لا يُحسب شاهدًا» last.

## 3. Choosing or changing the role

- When creating a portfolio, after a role is picked, list its form's elements with weights. Empty `form`: «لا يوجد نموذج تقييم لهذا الدور بعد؛ أضف بنودك بنفسك».
- When changing a portfolio's role, confirm first: «سيُضاف نموذج تقييم الدور الجديد، وتبقى بنودك الحالية وشواهدها».

## 4. Test cases

- [ ] Teacher portfolio: 11 elements, same weights as before.
- [ ] Activity-leader portfolio: 15 elements. Elements 4–11 show 5%.
- [ ] Health-guide portfolio: 14 elements. The last three are the health elements (15%, 5%, 10%).
- [ ] Kindergarten portfolio: 19 elements.
- [ ] Switch a teacher portfolio to kindergarten: «إعداد وتنفيذ خطة التعلم» moves under «بنود إضافية» with its evidence, and has no stars.
- [ ] Rate every element 5 in an activity-leader portfolio: the summary shows 100%.
- [ ] The exported file (print / Word / PDF) shows the same numbers and weights as the screen.
