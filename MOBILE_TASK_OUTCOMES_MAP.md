# App task: «خريطة نواتج التعلم» (learning-outcomes map, L9)

**For:** the mobile app developer (Flutter).
**API:** `docs/DOCUMENTS_API.md` section 16, with sections 2–4 for saving, PDF and Word. The AI flow is in `docs/AI_JOBS_API.md`.
**Copy from:**
- the remedial plan's lesson picker, stopping at the subject;
- the concept maps screens (`MOBILE_TASK_CONCEPT_MAPS.md`), for save, preview, PDF and Word.

The website task (`FRONTEND_TASK_OUTCOMES_MAP.md`) has the same flow in more detail.

---

## 1. Start
- Add a **«خريطة نواتج التعلم»** chip to the tools on the home screen. It opens a screen with the teacher's saved maps (`GET /documents?type=outcomes_map`) and a «خريطة جديدة» button.
- **New map:** pick the subject (stage → grade → subject), then the semester (الأول / الثاني), then tap «ابدأ».
- **The skeleton:** `GET /subjects/{id}/lessons`. Keep the picked semester's chapters (all of them if none has a semester), and group them by `unit_id` into `{ name, lessons: [{ lesson_id, title, outcomes: [] }] }` (API section 16).
- Open the editor with `{ subject_id, semester, title: "خريطة نواتج التعلم — {subject} — {semester name}", layout: "table", units }`.

## 2. «✨ اقترح النواتج»
- **One job per unit:** `POST /ai-jobs { kind: "lesson_outcomes", input: { lesson_ids } }`, up to 8 lessons per job (split bigger units). Run the jobs one after another.
- **Progress:** a progress bar «الوحدة 2 من 5». Each unit's card shows a spinner, then ✓.
- **`200`:** fill the unit at once. **`202`:** poll every 2 seconds for up to 60 seconds.
- **Filling:** match `result.lessons[]` by `lesson_id`, and fill only the lessons with no outcomes yet. Never overwrite the teacher's text.
- **`failed`:** mark that unit with a retry button, and carry on. **`429`:** stop, and show the message.

## 3. The editor
- **Units:** an expandable card per unit, showing its name and its lessons.
- **Lessons:** tapping a lesson opens a bottom sheet with:
  - its title (≤ 150);
  - its outcomes as a numbered list. Each is a field (≤ 120) with a delete button, and «+ ناتج» is turned off at 4;
  - «✨ اقترح لهذا الدرس», which runs one job with its `lesson_id`;
  - «حذف الدرس».
- **Adding:** «+ درس» (up to 15 per unit) and «+ وحدة» (up to 12).
- **Settings:**
  - the layout: «جدول» / «شجرة». Under «شجرة», add the hint «الوحدة التي تزيد على 30 عنصرًا تُطبع جدولًا»;
  - the signatures (the teacher and the principal by default);
  - «يُحسب شاهدًا لـ».
- **Preview:** a «معاينة» button, or a tab, sends `POST /documents/preview { type: "outcomes_map", input }`. Show the `html` the way the app already previews documents. It's landscape, so let it zoom.
- **Save:** `POST /documents` the first time, then `PATCH`. Save on «حفظ» and when leaving the screen.
  - A lesson with no outcomes is refused. Save once every lesson has at least one, or let the teacher delete the empty lessons.
- **Errors:** a `422` key `units.N.lessons.M…` points at lesson M of unit N. Open its sheet with the message.
- **PDF:** `GET /documents/{id}/print`, then `Printing.convertHtml` with `PdfPageFormat.a4.landscape`. **Word:** `POST /documents/{id}/exports {format: "docx"}`, then poll.

## Done when
- [ ] Subject → semester → «✨ اقترح النواتج» fills the units one by one. It's instant for a subject another teacher already did.
- [ ] Editing outcomes, lessons and units is kept after reopening.
- [ ] The PDF is landscape and clean, as tables or as trees. A unit over 30 items prints as a table.
