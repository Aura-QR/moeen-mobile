# Mobile task: «نافس» practice tests (L11)

**For:** the mobile developer.
**API:** `docs/NAFS_API.md`. The backend is done and on `main`.
**Reuse:**
- `lib/features/diagnostic_test` (job polling, the review cubit, the save flow);
- `lib/features/online_tests` (sharing and the diagnosis screen).

## Screens
1. **Entry:** a home chip «نافس», and an item in the exams section.
2. **Choose:**
   - the grade (3 chips), then the subject from `GET /nafs/options`, hiding subjects with empty `subject_ids`;
   - the domains (checkboxes with the `outcome` text), the number of questions (5–25), and «مثل الاختبار الحقيقي»;
   - the note «أسئلة تدريبية جديدة بأسلوب نافس، وليست من أسئلة الهيئة».
3. **Generate:** `POST /nafs` → poll `GET /ai-jobs/{id}`.
4. **Review:** the diagnostic review, with the passage on top for reading. Questions are 4-option mcq only.
5. **Save:** `POST /nafs/save` → open the exam. A «نافس» badge on exams with `kind: "nafs"`.
6. **PDF / Word:** the exam export with a Nafs cover («اختبار تدريبي بأسلوب نافس — …»), the passage first for reading, options أ ب ج د, and an answer-key table.
7. **Online results:** the existing diagnosis screen, titled «النتائج حسب مجالات نافس».

Add the translation keys in Arabic and English. Add tests for the cubit (choose → generate → review → save), like the diagnostic ones.

## Check
- [ ] Primary 6 math and reading on a real phone: generate, review, save, PDF.
- [ ] Primary 3 shows only reading and math.
- [ ] The diagnosis screen shows the Nafs domains after two students answer online.
