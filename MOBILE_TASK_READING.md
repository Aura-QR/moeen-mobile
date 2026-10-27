# App task: «الفهم القرائي» (reading comprehension, L12)

**For:** the mobile app developer (Flutter).
**API:**
- `docs/DOCUMENTS_API.md` section 15, with sections 2–4 for saving, PDF and Word;
- `docs/AI_JOBS_API.md` for the AI flow;
- `docs/ONLINE_TESTS_API.md` for sharing.

**Copy from:**
- the concept maps screens (L9), for the lesson picker, «✨», the preview and saving;
- the app's question editor from the exam screens, for the questions;
- the online test share flow (L4), after `/to-exam`.

The website task (`FRONTEND_TASK_READING.md`) has the same flow in more detail.

---

## 1. Start
- Add a **«الفهم القرائي»** chip to the tools on the home screen. It opens a screen with the teacher's saved worksheets (`GET /documents?type=reading_comprehension`) and a «قطعة جديدة» button.
- **New worksheet:** pick a lesson, then set the options:
  - المستوى: سهل / متوسط / متقدم (`level`, default `medium`);
  - الطول: قصيرة / متوسطة / طويلة (`length`, default `medium`), with the word count for the stage;
  - عدد الأسئلة: 4–12 (`questions`, default 8);
  - اللغة, only for an English subject (`language`).
- Then tap **«✨ اكتب القطعة والأسئلة»**: `POST /ai-jobs { kind: "reading_passage", input: { lesson_ids: [id], level, length, questions } }`.
  - **`200`:** open the editor at once.
  - **`202`:** poll every 2 seconds for up to 3 minutes, with a progress indicator (the server may try twice).
  - **`done`:** open the editor with `{ ...result, show_answers: true }`.
  - **`failed` or `429`:** show the message and a retry button.
- **«ابدأ بقطعة فارغة»:** the editor with a title, one empty paragraph and no questions.

## 2. The editor
Use three tabs: «القطعة», «المفردات» and «الأسئلة».
- **القطعة:** the title, then one text field per paragraph (≤ 1200), numbered. Add, delete and reorder paragraphs, up to 8. Show the word count.
- **المفردات:** rows of word (≤ 60) and meaning (≤ 200), up to 10.
- **الأسئلة:**
  - three sections, by level: «فهم مباشر», «استنتاج», «تفكير ناقد»;
  - tapping a question opens the question editor, limited to `mcq`, `true_false`, `fill_blank` and `essay`, plus a level picker;
  - «+ سؤال» in each section, up to 20 in all.
- **Settings:** «أسطر الاسم والصف» (`student_fields`), «أضف صفحة الإجابات» (`show_answers`), and «يُحسب شاهدًا لـ».
- **Preview:** a «معاينة» button sends `POST /documents/preview { type: "reading_comprehension", input }`. Show the returned `html` the way the app already previews documents.
- **Save:** `POST /documents` the first time, then `PATCH`. Save on «حفظ» and when leaving the screen.
- **Errors:** a `422` key such as `questions.N…` or `passage.N` points at that item. Open it with the message.
- **PDF:** `GET /documents/{id}/print`, then `Printing.convertHtml` with `PdfPageFormat.a4`. **Word:** `POST /documents/{id}/exports {format: "docx"}`, then poll.

## 3. «شارك إلكترونيًا»
- Save first, then send `POST /documents/{id}/to-exam`.
  - **`201`:** continue with the existing online test share flow for `exam.id`, ending with the link and the QR to share.
  - **`422`:** show the message on its field: no lesson, a question without an answer, or a passage that is too long.
- Say that the exam is a copy: later edits to the worksheet don't change it.

## 4. The passage in online tests
Students answer on the website (`/t/{token}`), which shows the passage. In the app, where the teacher views a test (`GET /online-tests/{id}`), show `passage` above the questions when it's set. Split it on blank lines and number the paragraphs.

## Done when
- [ ] Lesson → options → «✨ اكتب القطعة والأسئلة» → edit → PDF works. The same lesson and options are instant the second time.
- [ ] The PDF shows numbered paragraphs, the vocabulary box, the questions by level, and the answer page when ticked.
- [ ] «شارك إلكترونيًا» makes an exam and opens the share flow with its link and QR.
- [ ] An English lesson gives an English worksheet that reads left to right.
