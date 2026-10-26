# Agent guide: «اختبار من صورة أو PDF» (exam extraction)

You are implementing a new feature in the Flutter app at the repo root (package name `moean`).
The teacher photographs a test or a textbook page (or picks one PDF). The backend reads the
questions with AI, the teacher reviews them, and they are saved as a **draft exam** in «اختباراتي».
From there the existing exam list already offers print and «شارك إلكترونيًا».

Read this whole file before writing code. Follow it exactly. When it conflicts with `rules.md`, `rules.md` wins.

---

## 0. Ground rules (from `rules.md`, non-negotiable)

- **Cubit only.** `XCubit.get(context)` (`static XCubit get(BuildContext context) => BlocProvider.of(context);`). **Never** `context.read` / `context.watch`.
- Every `BlocBuilder` / `BlocConsumer` has a `buildWhen`.
- **One widget per file.** No private methods returning `Widget`. Pages ≤ 150 lines.
- **No hardcoded text.** Every string in **both** `assets/translations/ar.json` and `en.json`, via `appTranslation().get('key')`. New keys start with `exam_extract_`.
- `ColorsManager`, `TextStylesManager`, `spacing.dart` only. No `Theme.of(context)` for colors/styles. `withValues(alpha:)`, never `withOpacity`.
- Repositories return `Either<Failure, T>`; never throw.
- `ConditionalBuilder` when a screen has loading + error + empty + success.
- Reuse `lib/core/utils/constants/primary/` widgets (`PrimaryTextField`, `PrimaryElevatedButton`, `PrimarySectionCard`, `PrimaryChoiceChips`, `PrimaryEditableList`, `PrimaryConfirmDialog`, `PrimarySnackBar`, `PrimaryErrorView`, `PrimaryFileSourceSheet`, `UpgradePromptBottomSheet`). Do not copy them.
- No new packages. Unit tests (mocktail) for every cubit and pure helper. No dead code.

**Project deviation you must keep:** routes live in `lib/core/utils/constants/routes.dart` (`Routes` + route map). Navigate with `Navigator.pushNamed(context, Routes.x, arguments: …)`.

---

## 1. Relation to the existing exam features (read carefully)

- `lib/features/online_tests/` («الاختبارات الإلكترونية») **already exists**. Its logic is for sharing an existing exam with students and is **not** the logic of this task. **Do not change it, and do not build this feature inside it.** This feature only ends where online tests already begin: the saved exam appears in «اختباراتي», and its existing «شارك إلكترونيًا» button (`ExamListItemWidget.onShareOnline` → `Routes.createOnlineTest`) does the rest.
- `lib/features/exam_generation/` (the exam generator, «اختباراتي» = `Routes.myExams`, `MyExamsCubit`) stays as it is, except the single entry point in section 6.1.
- The new feature lives in its own folder: `lib/features/exam_extraction/`.

---

## 2. What already exists and must be reused

| Need | Existing code | Use |
|---|---|---|
| HTTP | `DioHelper` + `handleApiResponse` (`lib/core/network/remote/`) | `DioHelper.postData` accepts `FormData` (it drops the JSON content type for it). Style: `lib/features/online_tests/data/repositories/online_tests_repository.dart`. |
| Errors | `failureFromApiError` (`lib/core/errors/failures.dart`) | API `message` kept (Arabic). `402` → `PaymentRequiredFailure`. `429` → `ServerFailure(message)`, so show the message as-is. Always render `appTranslation().get(failure.message)`. |
| 402 sheet | `UpgradePromptBottomSheet.show(...)` | Same as `lib/features/exam_generation/presentation/screens/manual_exam_screen.dart`. |
| AI job polling pattern | `AiSuggestionsCubit._waitForJob` (`lib/features/documents/presentation/cubit/ai_suggestions_cubit.dart`) | Copy the **pattern** (loop, delay, `isClosed` checks, timeout). Do **not** reuse `AiJobModel`/`AiJobsRepository`: their `result` is `Map<String, List<String>>` and cannot hold questions. |
| Job endpoint | `aiJobApi(id)` in `lib/core/network/remote/api_endpoints.dart` | `GET /ai-jobs/{id}`. |
| Photos | `ImagePicker` (`image_picker 1.2.4`) | `pickImage(source: camera, maxWidth: 1600, maxHeight: 1600, imageQuality: 85)` and `pickMultiImage(maxWidth: 1600, maxHeight: 1600, imageQuality: 85, limit: 6)`. This **is** the required shrink (longest side 1600, JPEG 85%) and also turns iPhone HEIC into JPEG. No extra package. |
| PDF pick | `DeviceFilePicker.pick(DeviceFileSource.pdf)` (`lib/core/services/device_file_picker.dart`) | Returns `DevicePickedFile` (bytes + name + mime). |
| Subject → lesson picker | `LessonPickerSheet.show(context)` (`lib/features/documents/presentation/widgets/lesson_picker_sheet.dart`) | Returns `PickedLessonModel {lessonId, lessonTitle, subjectName, gradeName}` or null. **Reuse it** for «المادة ← الدرس». Do not build another picker. |
| Exams list | `Routes.myExams` (`MyExamsCubit`) | After save: `Navigator.pushNamedAndRemoveUntil` back to it (or `pushReplacementNamed`) so it loads fresh and shows the draft. |

---

## 3. API contract (backend: `moeen-backend/docs/EXAM_EXTRACTION_API.md`)

Add to `api_endpoints.dart`:
```dart
const String examExtractionsApi = '/exam-extractions';
const String examsFromQuestionsApi = '/exams/from-questions';
```

### 3.1 Start: `POST /exam-extractions` (multipart)
| Field | Rule |
|---|---|
| `files[]` | **1–6 photos** (jpg/png/webp, ≤ 4 MB each) **or one PDF** (≤ 10 MB). Never mix. |
| `count` | 1–40, questions to write when the page has none. App default **10**. |
| `types[]` | optional: `mcq`, `true_false`, `fill_blank`, `essay`, `matching` (not needed in v1) |
| `notes` | optional, ≤ 500 chars |

Build with `FormData.fromMap({...})` and `MultipartFile.fromBytes(bytes, filename: name, contentType: DioMediaType.parse(mime))`, repeating the key `files[]` for each file (`formData.files.add(MapEntry('files[]', …))`).
Response `202 {data: {id, status: "pending", …}}`. `402` no plan. `429 usage_limit_reached` (10/day, 100/month).

### 3.2 Poll: `GET /ai-jobs/{id}`
Every **3 s**, up to **3 minutes** (60 attempts), until `status` is `done` or `failed`. `failed` has `error` (message to show).
`result` when done:
```json
{ "source": "questions",
  "questions": [
    { "type": "mcq", "question_text": "…", "options": ["الورقة","الجذر","الزهرة","الثمرة"],
      "correct_answer": "الجذر", "difficulty": "easy", "needs_answer": false, "suggested": true },
    { "type": "fill_blank", "question_text": "تنقل ...... الماء إلى الأوراق.", "options": [],
      "correct_answer": "", "difficulty": "medium", "needs_answer": true },
    { "type": "matching", "question_text": "صل…",
      "options": { "column_a": ["الجذر"], "column_b": ["تثبيت النبات"] },
      "correct_answer": "1-أ", "difficulty": "medium", "needs_answer": false } ] }
```
- `source`: `questions` (read from the page) or `content` (written from the page text) → show a small banner for `content`: «الصفحة لا تحتوي أسئلة، فكتبنا أسئلة من محتواها».
- `needs_answer: true` → no answer yet; teacher must fill it.
- `suggested: true` → the AI answered it; show the chip «مقترحة، راجعها».
- `options` is a **list** for mcq, **empty list** for true_false/fill_blank/essay, and a **map** `{column_a, column_b}` for matching. Parse defensively (wrong shape → empty).
- True/false answers are always «صح» or «خطأ».

### 3.3 Save: `POST /exams/from-questions`
```json
{ "title": "اختبار النبات", "lesson_id": 123,
  "questions": [ { "type": "mcq", "question_text": "…", "options": ["…"], "correct_answer": "…",
                   "difficulty": "easy", "points": 2 } ] }
```
- `lesson_id` **required**. Every question needs a non-empty `correct_answer`; for `mcq` it must equal one of `options` (else `422`).
- Send `options` back in the same shape you received (list, `[]`, or the matching map).
- Response `201 {success, exam}` → the exam is a draft in «اختباراتي».

---

## 4. Feature folder

```
lib/features/exam_extraction/
├── data/
│   ├── models/
│   │   ├── extracted_question_model.dart   # ExtractedQuestionModel (+ fromJson/toJson/copyWith), QuestionType consts
│   │   ├── extraction_job_model.dart       # ExtractionJobModel {id, status, source, questions, error}
│   │   └── extraction_page_model.dart      # one picked page: bytes, name, mime, isPdf
│   └── repositories/
│       └── exam_extraction_repository.dart
├── presentation/
│   ├── cubit/
│   │   ├── extraction_pages_cubit.dart + extraction_pages_state.dart     # step 1
│   │   ├── extraction_job_cubit.dart + extraction_job_state.dart         # step 2
│   │   └── extraction_review_cubit.dart + extraction_review_state.dart   # steps 3 + 4
│   ├── screens/
│   │   ├── extraction_pages_screen.dart
│   │   ├── extraction_reading_screen.dart
│   │   └── extraction_review_screen.dart
│   └── widgets/            # one widget per file, all prefixed extraction_
```

### 4.1 Models
- `ExtractedQuestionModel`: `type, questionText, options (List<String>), columnA (List<String>), columnB (List<String>), correctAnswer, difficulty, needsAnswer, suggested, points (double, default 1)`.
  - `fromJson` handles the three `options` shapes.
  - `toSaveJson()` → `{type, question_text, options, correct_answer, difficulty, points}` where `options` is `[...]`, `[]`, or `{column_a, column_b}` by type.
  - `bool get hasAnswer => correctAnswer.trim().isNotEmpty`.
  - `bool get mcqAnswerMismatch => type == mcq && hasAnswer && !options.contains(correctAnswer.trim())`.
  - `bool get isHighlighted => needsAnswer && !hasAnswer || mcqAnswerMismatch` (also highlight while `!hasAnswer`).
  - `bool get isValid => questionText.trim().isNotEmpty && hasAnswer && !mcqAnswerMismatch && (type != mcq || options.where(nonEmpty).length >= 2)`.
- `ExtractionJobModel.fromJson(Map)`: `id, status, error?`, and when done `source` + `questions` from `result`.
- `ExtractionPageModel`: `Uint8List bytes, String name, String mime`; `bool get isPdf`.

### 4.2 `ExamExtractionRepository`
```dart
Future<Either<Failure, ExtractionJobModel>> start({
  required List<ExtractionPageModel> pages,
  required int count,
  String? notes,
});                                           // POST /exam-extractions (multipart)
Future<Either<Failure, ExtractionJobModel>> getJob(int id);   // GET /ai-jobs/{id}
Future<Either<Failure, Unit>> saveExam({
  required String title,
  required int lessonId,
  required List<ExtractedQuestionModel> questions,
});                                           // POST /exams/from-questions
```

---

## 5. Cubits (all logic here, none in widgets)

### 5.1 `ExtractionPagesCubit` (step 1)
State: `pages (List<ExtractionPageModel>)`, `count (int, 10)`, `notes`, `error (String?)`.
Rules, all enforced in the cubit:
- `addFromCamera()` → one `pickImage(camera, …1600/85)`; the teacher taps again for more shots. Refuse when 6 photos already, or a PDF is selected.
- `addFromGallery()` → `pickMultiImage(limit: 6 - pages.length, …1600/85)`; take at most the remaining slots.
- `pickPdf()` → replaces all pages with the one PDF. Refuse > 10 MB (`exam_extract_pdf_too_big`).
- Photo > 4 MB after shrinking → refuse that photo (`exam_extract_photo_too_big`).
- Mime: `DevicePickedFile.mimeFromName(name)`, fallback `image/jpeg` for photos from `image_picker` (they are JPEG after `imageQuality`).
- `removePage(i)`, `setCount(1..40 clamp)`, `setNotes(≤ 500)`.
- `bool get canStart => pages.isNotEmpty`.
Inject the `ImagePicker` and `DeviceFilePicker` (constructor params with defaults) so tests can mock them.

### 5.2 `ExtractionJobCubit` (step 2)
State: `status (starting | polling | done | failed | timedOut)`, `job`, `elapsedSeconds`, `error`, `paymentRequired`.
- `start(pages, count, notes)`: call `repository.start`; `402` → `paymentRequired`; other failure (incl. `429`) → `failed` with the message.
- Then poll `getJob(id)` every **3 s**, max **60** attempts (= 3 min). Stop on `done` / `failed` / `isClosed`. Timeout → `timedOut` with `exam_extract_timeout`.
- Progress message changes with elapsed time (keys): 0–10 s `exam_extract_progress_upload` «جارٍ رفع الصفحات…», 10–40 s `exam_extract_progress_reading` «نقرأ الأسئلة…», > 40 s `exam_extract_progress_long` «الصفحات كثيرة، لحظات أخرى…».
- `retry()` → same request again (keep the pages in the state passed from step 1).
- `done` with **0 questions** → `failed` with `exam_extract_no_questions`.
- Constructor takes `pollInterval` and `maxAttempts` (defaults 3 s / 60) so tests can use `Duration.zero`.

### 5.3 `ExtractionReviewCubit` (steps 3 + 4)
State: `questions`, `source`, `title`, `lesson (PickedLessonModel?)`, `isSaving`, `error`, `paymentRequired`, `saved (bool)`.
- `updateText(i, v)`, `updateOptions(i, List<String>)` (mcq: one per line → split on `\n`, trim, drop empty), `setCorrectAnswer(i, v)`, `setTrueFalse(i, bool)` (→ «صح»/«خطأ»), `updateColumnA/B(i, list)`, `setPoints(i, double > 0)`, `changeType(i, type)` (reset options/answer to fit), `delete(i)`.
- Editing a `suggested` answer clears `suggested` (the teacher has checked it).
- `bool get canSave => questions.isNotEmpty && questions.every((q) => q.isValid) && title.trim().isNotEmpty && lesson != null && !isSaving`.
- `int get missingCount` → how many are not valid (for the banner «{n} أسئلة تحتاج إجابة»).
- `save()` → `repository.saveExam`; success → `saved: true`; `402` → `paymentRequired`; `422`/other → `error` (API message).

---

## 6. Screens

### 6.1 Entry point (only change outside the feature)
In `lib/features/exam_generation/presentation/widgets/my_exams_header_widget.dart` add one action «اختبار من صورة أو PDF» (icon `Icons.document_scanner_outlined`) → `Navigator.pushNamed(context, Routes.examExtraction)`.
Routes in `routes.dart`:
- `Routes.examExtraction = '/exam-extraction'` → `BlocProvider(ExtractionPagesCubit)` + `ExtractionPagesScreen`.
- `Routes.examExtractionReading = '/exam-extraction/reading'` (argument: `({List<ExtractionPageModel> pages, int count, String? notes})`) → `BlocProvider(ExtractionJobCubit(...)..start(...))`.
- `Routes.examExtractionReview = '/exam-extraction/review'` (argument: `ExtractionJobModel`) → `BlocProvider(ExtractionReviewCubit(...))`.

### 6.2 `ExtractionPagesScreen` (step 1)
- Privacy note card at the top (warning color): «لا ترفع أوراقًا عليها أسماء أو بيانات طلاب».
- Three source buttons: «تصوير», «من المعرض», «ملف PDF».
- Thumbnails grid (`Image.memory`) with a remove ✕, or a PDF tile with its name and size. Counter «{n} / 6».
- Field «عدد الأسئلة إذا كانت الصفحة شرحًا» (number, default 10, 1–40) and optional «ملاحظة للذكاء الاصطناعي» (≤ 500).
- «قراءة الأسئلة» (disabled until `canStart`) → `Routes.examExtractionReading`.

### 6.3 `ExtractionReadingScreen` (step 2)
- Animated loader + the current progress message + elapsed time. Back/close cancels (cubit stops polling on `close`).
- `failed` / `timedOut` → `PrimaryErrorView` with the message and «إعادة المحاولة» (`retry`) + «تغيير الصفحات» (pop).
- `paymentRequired` → `UpgradePromptBottomSheet.show`, then pop.
- `done` → `Navigator.pushReplacementNamed(context, Routes.examExtractionReview, arguments: job)`.

### 6.4 `ExtractionReviewScreen` (steps 3 + 4)
- Top: `source == content` banner; «{n} أسئلة تحتاج إجابة» banner while `missingCount > 0`.
- `ListView` of `ExtractionQuestionCard` (one card per question; each part is its own widget file):
  - header: number, type dropdown (اختيار من متعدد / صح وخطأ / أكمل الفراغ / مقالي / توصيل), «مقترحة، راجعها» chip when `suggested`, delete button (`PrimaryConfirmDialog`);
  - question text field;
  - body by type:
    - **mcq**: options field, one per line + a right-answer picker (radio list / chips built from the current options);
    - **true_false**: صح / خطأ toggle;
    - **matching**: two column fields (one item per line) + answer text field (e.g. «1-أ، 2-ب»);
    - **fill_blank / essay**: answer text field;
  - points field (number > 0);
  - highlighted border + hint text when `isHighlighted` (`ColorsManager` warning/error color).
  - Each card's `BlocBuilder` uses `buildWhen` comparing **only its own question** (`previous.questions[i] != current.questions[i]`) so typing doesn't rebuild the whole list. Give `ExtractedQuestionModel` value equality (`Equatable`) for this.
  - Text controllers: a card that owns controllers is a `StatefulWidget` that only holds the controllers and forwards changes to the cubit (allowed simple local UI state). Do not put business logic in it.
- Bottom sticky save section:
  - «عنوان الاختبار» (required);
  - «المادة والدرس» tile → `LessonPickerSheet.show(context)` → `setLesson`; shows `subjectName — lessonTitle`;
  - «حفظ كمسودة» button, **disabled until `canSave`**.
- On `saved`: snackbar «حُفظ الاختبار في اختباراتي» → back to `Routes.myExams` (fresh), where the teacher can print or «شارك إلكترونيًا» (existing).
- Leaving with unsaved questions → `PrimaryConfirmDialog` «ستفقد الأسئلة المقروءة».

---

## 7. Translations
Every new key in **both** files. Minimum set (prefix `exam_extract_`):
`exam_extract_title`, `exam_extract_entry`, `exam_extract_privacy_note`, `exam_extract_camera`, `exam_extract_gallery`, `exam_extract_pdf`, `exam_extract_pages_counter`, `exam_extract_max_pages`, `exam_extract_photo_too_big`, `exam_extract_pdf_too_big`, `exam_extract_no_mix`, `exam_extract_count_label`, `exam_extract_notes_label`, `exam_extract_start`, `exam_extract_progress_upload`, `exam_extract_progress_reading`, `exam_extract_progress_long`, `exam_extract_timeout`, `exam_extract_no_questions`, `exam_extract_retry`, `exam_extract_change_pages`, `exam_extract_source_content`, `exam_extract_missing_answers`, `exam_extract_suggested`, `exam_extract_type_mcq`, `exam_extract_type_true_false`, `exam_extract_type_fill_blank`, `exam_extract_type_essay`, `exam_extract_type_matching`, `exam_extract_question_label`, `exam_extract_options_label`, `exam_extract_correct_answer`, `exam_extract_true`, `exam_extract_false`, `exam_extract_column_a`, `exam_extract_column_b`, `exam_extract_answer_label`, `exam_extract_points`, `exam_extract_needs_answer_hint`, `exam_extract_mcq_mismatch_hint`, `exam_extract_delete_confirm`, `exam_extract_exam_title`, `exam_extract_lesson`, `exam_extract_pick_lesson`, `exam_extract_save`, `exam_extract_saved`, `exam_extract_leave_confirm`.
«صح» / «خطأ» sent to the API are **data values**, keep them as constants in the model (they are what the API expects), and show them through the translation keys.

---

## 8. Tests (mocktail, under `test/features/exam_extraction/`)
- `extracted_question_model_test.dart`: `fromJson` for mcq / true_false / fill_blank / matching (map options) / wrong-shaped options; `toSaveJson` round-trip; `isValid`, `mcqAnswerMismatch`, `isHighlighted`.
- `extraction_job_model_test.dart`: pending, done with questions, failed with error.
- `extraction_pages_cubit_test.dart`: max 6 photos, PDF replaces photos, PDF > 10 MB refused, photo > 4 MB refused, count clamp.
- `extraction_job_cubit_test.dart` (`pollInterval: Duration.zero`): pending → done, failed, timeout after N attempts, `402` → paymentRequired, `429` message shown, 0 questions → failed, stops when closed.
- `extraction_review_cubit_test.dart`: edits, delete, `canSave` false until every answer + title + lesson, mcq mismatch blocks save, editing a suggested answer clears `suggested`, save success / `422`.

Run `flutter analyze` (zero new issues) and `flutter test` before you finish.

---

## 9. Order of work
1. Endpoints + models + model tests.
2. Repository.
3. Step 1 cubit + screen; step 2 cubit + screen (test on the emulator with a real photo).
4. Step 3/4 cubit + review screen + `LessonPickerSheet`.
5. Entry in «اختباراتي», routes, translations, tests, `flutter analyze`.

## 10. Done when
- [ ] 1–6 photos (camera or gallery) or one PDF are sent; photos are ≤ 1600 px / JPEG 85 %.
- [ ] The privacy note is shown on the first screen.
- [ ] Polling every 3 s, max 3 min, with a changing message; retry works; `402` shows the upgrade sheet; `429` shows the API message.
- [ ] Every question type is editable; `needs_answer` and mcq mismatches are highlighted; «مقترحة، راجعها» shows on AI answers.
- [ ] Save stays disabled until every question has a valid answer, a title and a lesson.
- [ ] The saved exam appears as a draft in «اختباراتي», and its existing print and «شارك إلكترونيًا» work on it.
- [ ] `lib/features/online_tests/` unchanged; every string in `ar.json` and `en.json`; `flutter analyze` clean; tests pass.
