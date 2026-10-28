# Mobile task: «التحصيلي» practice tests (L11b)

**For:** the mobile developer.
**API:** `docs/TAHSILI_API.md`. It's the Nafs flow (`docs/MOBILE_TASK_NAFS.md`) for another test.
**Reuse:** the Nafs feature (job polling, the review cubit, the save flow) and `lib/features/online_tests` (sharing and diagnosis). Parameterise it by test rather than copying it.

## Screens
1. **Entry:** the «نافس» home chip becomes «الاختبارات الوطنية», opening two tabs: «نافس» (unchanged) and «التحصيلي».
2. **Choose:**
   - the subject from `GET /tahsili/options`, **hiding subjects with `available: false`**; no grade step;
   - the domains (checkboxes with the `outcome` text) and the number of questions (`limits`);
   - the note from `options.notice`: «أسئلة تدريبية جديدة بأسلوب التحصيلي، وليست من أسئلة الهيئة».
3. **Generate:** `POST /tahsili` with the **subject key** → poll `GET /ai-jobs/{id}`; on `failed`, show `error` with a retry button.
4. **Review:** the Nafs review, with no passage. Questions are 4-option mcq only. Show each question's `check` (folded, «طريقة الحل») and «راجع الإجابات قبل الحفظ».
5. **Save:** `POST /tahsili/save` `{ subject, title, skills }` → open the exam. Show 422 errors at their question or domain path. A «تحصيلي» badge on exams with `kind: "tahsili"`.
6. **PDF / Word:** the Nafs export with the cover «اختبار تدريبي بأسلوب التحصيلي — {subject}», options أ ب ج د, and the answer-key table.
7. **Online results:** the existing diagnosis screen, titled «النتائج حسب مجالات التحصيلي».

Add the translation keys in Arabic and English, and cubit tests for the Tahsili tab (choose → generate → review → save).

## Check
- [ ] Physics, 10 questions on a real phone: generate, review, save, PDF.
- [ ] The «نافس» tab works as before.
- [ ] The diagnosis screen shows the Tahsili domains after two students answer online.
