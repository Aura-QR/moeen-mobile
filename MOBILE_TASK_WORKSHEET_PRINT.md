# Mobile task: «اطبع كورقة عمل» (worksheet print)

**For:** the mobile developer.
**Backend:** no changes needed. PDF and Word are built in the app today.

## What
A worksheet is the **same questions as an exam**, printed for practice or homework instead of marks. It is **not a new tool**: the exam export gets a second style. It matches the website task `FRONTEND_TASK_WORKSHEET_PRINT.md`.

## Where
- **`lib/features/exam_generation/presentation/screens/exam_preview_screen.dart`:** above the PDF / Word options, add a choice **«اختبار» | «ورقة عمل»**, defaulting to «اختبار».
- **`lib/features/exam_generation/data/services/exam_pdf_service.dart` and `exam_word_service.dart`:** add an `isWorksheet` parameter. When it's true:
  - the title is «ورقة عمل: {title}», with **no total mark**;
  - there are **no points** per question, and no mark box or «الدرجة» field in the header;
  - essay questions get 3–4 empty lines;
  - the footer is «ورقة عمل من منصة حضّر»;
  - answers are hidden by default.
- Add the translation keys in Arabic and English.

## Check
- [ ] A worksheet PDF and a worksheet Word file show the differences above.
- [ ] Exam PDF and Word are **exactly as before**.
- [ ] Tested on a real phone: share, save, and print.
