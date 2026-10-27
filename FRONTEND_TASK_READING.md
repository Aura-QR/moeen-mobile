# Website task: «الفهم القرائي» (reading comprehension, L12)

**For:** the website developer (Next.js, `Hader-frontend`).
**API:**
- `docs/DOCUMENTS_API.md` section 15, with sections 2–4 for saving, printing and Word;
- `docs/AI_JOBS_API.md` for the AI flow;
- `docs/ONLINE_TESTS_API.md` for sharing and the student page.

**Copy from:**
- the concept maps page (L9), for the lesson picker, «✨», the two-pane editor, preview and autosave;
- the shared question editor `src/components/exams/QuestionEditor.tsx` (L5), for the questions;
- the online test share flow (L4), after `/to-exam`.

---

## 1. Entry, lesson and options
- Add **«الفهم القرائي»** to the tools menu.
- **Route:** `/tools/reading`. Below the start box, list the teacher's saved worksheets (`GET /documents?type=reading_comprehension`).
- **Step 1:** the lesson picker (stage → grade → subject → lesson), then the options:
  - **المستوى:** سهل / متوسط / متقدم (`level`: `easy` | `medium` | `hard`, default `medium`);
  - **الطول:** قصيرة / متوسطة / طويلة (`length`: `short` | `medium` | `long`, default `medium`). Show the word count for the lesson's stage under it, from the table in the API doc (e.g. «نحو 180 كلمة»);
  - **عدد الأسئلة:** 4–12 (`questions`, default 8);
  - **اللغة:** hidden, except for an English subject, where it shows «English» (default) / «العربية» (`language`).
- Then a big **«✨ اكتب القطعة والأسئلة»** button:
  1. Send `POST /ai-jobs { kind: "reading_passage", input: { lesson_ids: [lessonId], level, length, questions, language? } }`. Leave `language` out unless the teacher changed it.
  2. On `200` (`done`), open the editor at once: this passage was ready.
  3. On `202`, poll `GET /ai-jobs/{id}` every 2 seconds for up to 3 minutes, showing «جارٍ كتابة القطعة…». A long passage can take close to a minute, and the server tries a second time when the first passage is off length.
  4. On `done`, open the editor with `{ ...result, show_answers: true }`. `result` already has `lesson_id`, `level` and `language`.
  5. On `failed`, show `error` and a retry button.
  6. On `429`, show the limit message from the response.
- Under the button, a small note: «القطعة مكتوبة جديدة لهذا الدرس، وليست من الكتاب المدرسي.»
- The same lesson and options give the same passage (from the cache). Say so in a tooltip on the button: «لقطعة مختلفة، غيّر المستوى أو الطول».
- **«ابدأ بقطعة فارغة»:** opens the editor with a title, one empty paragraph and no questions. The teacher writes their own passage.

## 2. The editor
**Route:** `/tools/reading/[id]`, or `/tools/reading/new` before the first save. Use two panes, side by side on wide screens and stacked on narrow ones.

### The form pane (right)
- **Title** (`title`, required, ≤ 150).
- **The passage:** one textarea per paragraph (≤ 1200 characters, with a counter near the limit), numbered 1, 2, 3… as on the printed page. Add, delete and reorder paragraphs, up to 8. Show the total word count.
- **Vocabulary:** rows of «الكلمة» (≤ 60) and «معناها» (≤ 200), add and delete, up to 10.
- **Questions:** use `QuestionEditor` for each question, with:
  - only the types `mcq`, `true_false`, `fill_blank` and `essay`;
  - one extra field, **the level** (`level`): «فهم مباشر» / «استنتاج» / «تفكير ناقد»;
  - the questions shown in three groups, by level, in the order they print. Within a group, ↑ ↓ reorders them. Changing a question's level moves it to that group;
  - «+ سؤال» under each group, up to 20 questions in all;
  - for English worksheets, `true_false` answers are still stored as `صح` / `خطأ`. Label the choices True / False in the editor.
- **Options:**
  - «أسطر الاسم والصف» (`student_fields`);
  - «أضف صفحة الإجابات» (`show_answers`);
  - a small line «يُحسب شاهدًا لـ: التنويع في استراتيجيات التدريس» (`element`, as in the other tools).

### The preview pane (left)
- Send `POST /documents/preview { type: "reading_comprehension", input }` on a short debounce (about 600 ms after the last change), and put `html` in an `<iframe srcdoc>`.
- Keep the last good preview while a request is running or returns `422`.

### Saving
- Send `POST /documents { type: "reading_comprehension", input }` the first time, then `PATCH /documents/{id} { input }`, with autosave a few seconds after the last change.
- **Errors:** `422` keys look like `passage.N`, `vocabulary.N.word`, `questions.N.level` or `questions.N` (an mcq's options and answer). N is the index in the array: highlight that field.

### Print and Word
As in the other tools (API sections 4.1 and 4.2). The page is A4 portrait.

## 3. «شارك إلكترونيًا»
- A button next to print and Word. It needs a saved document: save first if there are unsaved changes.
- Send `POST /documents/{id}/to-exam`.
  - On `201`, continue with the **existing share flow** for `exam.id`: the online test form (`POST /online-tests { exam_id, … }`), then the links and QR.
  - On `422`, show the messages on their fields: `lesson_id` (no lesson picked), `questions.N.correct_answer` (a question without an answer) or `passage`.
- Tell the teacher that the exam is a copy: «تُنشأ نسخة في اختباراتي؛ تعديل الورقة لاحقًا لا يغيّر الاختبار.»
- Each click makes a new exam. Turn off the button while the request runs.

## 4. The student page `/t/{token}`
- `GET /public/tests/{token}` and `start` now return **`passage`** (`null` for most tests).
- When it's set, show the passage **above the questions**:
  - split it on blank lines (`\n\n`) and number the paragraphs, as on the worksheet, because questions may say «في الفقرة الثانية»;
  - on wide screens, keep it in a **sticky** box beside or above the questions, with its own scroll;
  - on phones, use a **collapsible** box: open at the start, and a «النص» button that stays at hand to open it again;
  - `dir="auto"` on the box, so an English passage reads left to right.
- When `passage` is `null`, the page is unchanged.
- The teacher's test page (`GET /online-tests/{id}`) also has `passage`: show it above the questions there too.

## Done when
- [ ] A teacher picks a lesson and gets an original passage with questions on three levels and an answer key. The same lesson and options are instant the second time.
- [ ] The editor keeps every change after reopening from «مستنداتي», and the preview follows each change.
- [ ] It prints as a clean worksheet: numbered paragraphs, the vocabulary box, questions grouped by level, and the answer page when ticked. Word opens with the same content.
- [ ] «شارك إلكترونيًا» makes an exam and goes on to the share flow. Students see the passage while they answer, on a phone and on a computer.
- [ ] An English lesson gives an English worksheet that reads left to right.
