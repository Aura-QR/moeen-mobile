# App task: «خرائط المفاهيم» (concept maps, L9)

**For:** the mobile app developer (Flutter).
**API:** `docs/DOCUMENTS_API.md` section 14, with sections 2–4 for saving, PDF and Word. The AI flow is in `docs/AI_JOBS_API.md`.
**Copy from:**
- the remedial plan's lesson picker;
- the strategy documentation screen, for save, PDF and Word.

The website task (`FRONTEND_TASK_CONCEPT_MAPS.md`) has the same flow in more detail.

---

## 1. Start
- Add a **«خرائط المفاهيم»** chip to the tools on the home screen. It opens a screen with the teacher's saved maps (`GET /documents?type=concept_map`) and a «خريطة جديدة» button.
- **New map:**
  - pick a lesson, then tap **«✨ اقترح الخريطة»**: `POST /ai-jobs { kind: "concept_map", input: { lesson_ids: [id] } }`;
  - **`200`:** open the editor at once;
  - **`202`:** poll every 2 seconds for up to 60 seconds, with a progress indicator;
  - **`done`:** open the editor with `{ ...result, lesson_id, layout: "tree" }`;
  - **`failed` or `429`:** show the message and a retry button.
- **«ابدأ بخريطة فارغة»:** the editor with a title and one main concept.

## 2. The editor
- **Outline:** a list of concepts, indented by level. Tapping a concept opens a bottom sheet with:
  - its text (≤ 60);
  - its link words (≤ 30), for every concept except the main one;
  - the «فراغ للطالب» switch;
  - «+ فرع» (add a concept under it);
  - «لأعلى» / «لأسفل» (move among its siblings);
  - «حذف», which removes it and everything under it, after a confirm.
- **Limits:** turn off «+ فرع» at 30 concepts, at 6 under one concept, and at level 4.
- **Settings:**
  - the layout («شجري» / «دائري»);
  - «أضف صفحة الإجابة» (`show_answers`), only when a blank is ticked;
  - «يُحسب شاهدًا لـ».
- **Preview:** a «معاينة» button, or a tab, sends `POST /documents/preview { type: "concept_map", input }`. Show the returned `html` the way the app already previews documents: in a WebView, or as a picture of the first page made with `Printing.raster`. It's a landscape page, so let it zoom.
- **Save:** `POST /documents` the first time, then `PATCH`. Save on «حفظ» and when leaving the screen.
- **Errors:** a `422` key `nodes.N…` points at concept N in `nodes`. Open its sheet with the message.
- **PDF:** `GET /documents/{id}/print`, then `Printing.convertHtml` with `PdfPageFormat.a4.landscape`. **Word:** `POST /documents/{id}/exports {format: "docx"}`, then poll.

## Done when
- [ ] Lesson → «✨ اقترح الخريطة» → edit → PDF in landscape works. The same lesson is instant the second time.
- [ ] A worksheet with empty boxes, and its answer page, convert to PDF correctly.
- [ ] A 30-concept map stays on one landscape page and is readable on the PDF.
