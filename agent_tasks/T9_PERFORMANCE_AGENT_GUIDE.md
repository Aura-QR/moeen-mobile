# Agent guide: «الأداء الوظيفي» (T9, performance evidence file)

You are implementing a feature in the Flutter app at the repo root (package name `moean`).
**This is not a new tool.** It is:
1. a second view of an existing portfolio (ملف الإنجاز), organised by the Ministry's performance elements, with self-ratings and a CV form;
2. a small «يُحسب شاهدًا لـ» picker on documents;
3. an export that turns the portfolio into a `performance_file` document (PDF / Word like every document).

Read this whole file before writing code. Follow it exactly. When it conflicts with `rules.md`, `rules.md` wins.

---

## 0. Ground rules (from `rules.md`, non-negotiable)

- **Cubit only.** `XCubit.get(context)` (`static XCubit get(BuildContext context) => BlocProvider.of(context);`). **Never** `context.read` / `context.watch`.
- Every `BlocBuilder` / `BlocConsumer` has a `buildWhen`.
- **One widget per file.** No private methods returning `Widget`. Pages ≤ 150 lines.
- **No hardcoded text.** Every string in **both** `assets/translations/ar.json` and `en.json`, via `appTranslation().get('key')`. New keys start with `performance_` (element picker keys: `document_element_`).
- `ColorsManager`, `TextStylesManager`, `spacing.dart` only. No `Theme.of(context)` for colors/styles. `withValues(alpha:)`, never `withOpacity`.
- Repositories return `Either<Failure, T>`; never throw.
- `ConditionalBuilder` when a screen has loading + error + empty + success.
- Reuse `lib/core/utils/constants/primary/` widgets. Do not copy them.
- No new packages. Unit tests (mocktail) for every cubit, model and pure helper. No dead code.
- **Additive changes only** to existing portfolio / documents code. Existing screens must behave exactly as before, except the few places listed in section 3. Do not touch `lib/features/online_tests/`, `lib/features/qr_codes/`, `lib/features/exam_extraction/`.

**Project deviation you must keep:** routes are constants in `lib/core/utils/constants/routes.dart` (`Routes` + route map). Navigate with `Navigator.pushNamed(context, Routes.x, arguments: …)`.

---

## 1. What already exists and must be reused

| Need | Existing code |
|---|---|
| Portfolio API | `PortfolioRepository` (`lib/features/portfolio/data/repositories/portfolio_repository.dart`): `getRoles`, `getPortfolio`, `updatePortfolio(id, profile:)`, `updateItem`, `uploadFile`, `addLink`, `attachDocument`, `deleteFile`, `downloadBytes`. **Add methods here** (section 3.2); do not make a second portfolio repository. |
| Portfolio models | `lib/features/portfolio/data/models/portfolio_model.dart` (`PortfolioModel`, `PortfolioProfileModel`, `PortfolioItemModel`, file model), `portfolio_roles_model.dart` |
| Portfolio screens | `PortfolioEditorScreen` / `PortfolioEditorCubit`, header `PortfolioEditorHeaderWidget` (with `PortfolioHeaderActionWidget` buttons), item widgets: `PortfolioFilesStripWidget`, `PortfolioFileThumbnailWidget`, `PortfolioEvidenceBadgeWidget` |
| Evidence pickers | `PrimaryFileSourceSheet` (photo / PDF / link), `PrimaryInputDialog` (link title + url) — exactly as `PortfolioItemCardWidget` uses them |
| Documents API | `DocumentsRepository` (`getDocument`, `updateDocument`, `getPrint`, `requestExport`, `getExport`) |
| PDF / Word | `DocumentExportSheet.show(context, documentId:, withExcel: false)` — it already does print (through the **native `html_pdf` channel**, never `Printing.convertHtml` directly), Word with polling, and share. |
| Theme picker | `DocumentThemePicker`, `DocumentTheme` |
| «مستنداتي» | `MyDocumentsScreen._open` uses `documentToolFor(type)`; unknown types show `document_type_unsupported` |
| 402 | `UpgradePromptBottomSheet.show(...)` |

---

## 2. API contract

### 2.1 Elements (`GET /portfolios/roles`, new fields)
```json
"elements": [ { "key": "duties", "title": "أداء الواجبات الوظيفية", "number": 1, "weight": 10 }, "…",
              { "key": "activity_plan", "title": "…", "number": null, "weight": null } ],
"rating_scale": { "min": 1, "max": 5 }
```
11 teacher elements have `number` + `weight` (sum 100). Student-activity items have neither.

### 2.2 `GET /portfolios/{id}/performance`
```json
{ "data": {
  "portfolio_id": 7, "title": "ملف الإنجاز 1448", "role_label": "معلم",
  "cv": { "name": "…", "qualification": "…", "specialty": "…", "job_title": "…", "rank": "…", "service_start": "…",
          "stage": "…", "subjects": "…", "school_name": "…", "academic_year": "1448" },
  "evidence_target": 3,
  "rating_scale": { "min": 1, "max": 5 },
  "rating": { "elements": 11, "rated": 2, "points": 13, "out_of": 15, "percent": 86.7, "average": 4.33 },
  "document_id": 55,
  "items": [ {
    "id": 31, "item_key": "teaching_strategies", "number": 4, "weight": 10,
    "title": "التنويع في استراتيجيات التدريس", "description": null, "included": true, "self_rating": 4,
    "evidence_count": 3, "state": "complete",
    "files": [ "… same shape as in GET /portfolios/{id} …" ],
    "documents": [ { "id": 12, "type": "strategy_documentation", "title": "توثيق جيكسو — دورة الماء", "created_at": "…" } ]
  } ] } }
```
- `items`: all items in order, excluded ones too (`included: false`).
- `documents`: documents **tagged** with this element and not attached to it (≤ 50).
- `evidence_count` = files + documents. `state`: `none` | `some` | `complete` (card colour).
- `rating`: `percent` and `average` are `null` until something is rated. `document_id`: the exported performance file, or null.
- Label the rating «تقييم ذاتي» (not an official grade).

### 2.3 Self-rating
`PATCH /portfolios/{id}/items/{itemId} {"self_rating": 4}`; `{"self_rating": null}` clears it. Only items with a `weight`.

### 2.4 CV
`PATCH /portfolios/{id} {profile: {...}}` with these fields (labels in section 7):
`name, qualification, specialty, job_title, rank, service_start, stage, subjects, school_name, academic_year`.
**Send the whole profile** (the existing fields such as `phone`, `email`, `signatures` too) so nothing is lost; the existing `updatePortfolio(profile:)` already sends `profile.toJson()`.

### 2.5 Document element (`docs/DOCUMENTS_API.md` section 2)
- Every document has `element` (a portfolio item key or `null`) in `GET /documents` and `GET /documents/{id}`.
- Change: `PATCH /documents/{id} {"element": "<key>"}`; keep out of the file: `{"element": "none"}`.
- `GET /documents?element=<key>` filters.

### 2.6 Export
`POST /portfolios/{id}/performance-file {include_ratings?, theme?}` → the document (`201` first time, `200` after; one per portfolio, rebuilt each call). **Call it every time right before printing.** Then the usual `GET /documents/{id}/print` and `POST /documents/{id}/exports {format: "docx"}` — i.e. `DocumentExportSheet`.
- `422 documents_limit` → show the message. `422 server_document` when trying to edit it as a form.

---

## 3. Additive changes to existing code

### 3.1 Endpoints (`api_endpoints.dart`)
```dart
String portfolioPerformanceApi(int id) => '/portfolios/$id/performance';
String portfolioPerformanceFileApi(int id) => '/portfolios/$id/performance-file';
```

### 3.2 Portfolio data
- `PortfolioRolesModel`: add `elements (List<PortfolioElementModel>)` and `ratingMin/ratingMax` (default 1/5). `PortfolioElementModel {key, title, int? number, int? weight}`. Parse defensively; missing → empty list.
- `PortfolioProfileModel`: add `qualification, jobTitle, rank, serviceStart, subjects` (nullable) to the constructor, `fromJson`, `toJson`, `copyWith` (if it has one). Keep every existing field.
- New models in `lib/features/portfolio/data/models/performance_model.dart`: `PerformanceModel {portfolioId, title, roleLabel, cv (PortfolioProfileModel or a CvModel), evidenceTarget, ratingMin, ratingMax, rating (PerformanceRatingModel), documentId, items}`, `PerformanceItemModel {id, itemKey, number, weight, title, description, included, selfRating, evidenceCount, state (enum none/some/complete/unknown), files (reuse the existing file model), documents (List<PerformanceDocumentRef>)}`, `PerformanceRatingModel {elements, rated, points, outOf, percent?, average?}`, `PerformanceDocumentRef {id, type, title, createdAt}`.
- `PortfolioRepository` new methods:
  ```dart
  Future<Either<Failure, PerformanceModel>> getPerformance(int id);
  Future<Either<Failure, Unit>> setSelfRating(int id, int itemId, int? rating);   // sends null explicitly
  Future<Either<Failure, DocumentModel>> exportPerformanceFile(int id, {bool? includeRatings, String? theme});
  ```
  Note: `setSelfRating(null)` must send `{"self_rating": null}` — do **not** use the `'key': ?value` null-aware map syntax here, it would drop the key.

### 3.3 Document element
- `DocumentModel`: add `final String? element` parsed from `json['element']`. Default null; nothing else changes.
- `DocumentsRepository.updateDocument`: if it can't send only `element`, add `Future<Either<Failure, DocumentModel>> setElement(int id, String? element)` → `PATCH {element: element ?? 'none'}`.
- `DocumentsRepository.getDocuments`: add an optional `element` query parameter (used by the optional filter only).
- `DocumentTypes.performanceFile = 'performance_file'` + label keys `document_type_performance_file` / `_subtitle`. **Do not** add it to `documentTools` (it is not a form tool and must not appear in the «new document» sheet).

### 3.4 The shared element picker (also used by T8 reports — build it once)
In `lib/features/documents/presentation/`:
- `cubit/document_element_cubit.dart` + state: `load()` gets `PortfolioRepository.getRoles()` elements (cache them for the cubit's life) and the document's current `element` (passed in, or from `getDocument`); `change(String? key)` → `setElement`; state `elements`, `current`, `isSaving`, `error`.
- `widgets/document_element_tile.dart`: «يُحسب شاهدًا لـ: <title>» (or «لا يُحسب شاهدًا») + «تغيير».
- `widgets/document_element_sheet.dart`: bottom sheet listing elements («العنصر 4 — title», number-less ones by title) + «لا يُحسب شاهدًا»; returns the picked key (`null` for none). Same sheet is used by «نقل» in the performance screen.
- Constructor takes `documentId` and an optional `initialElement`. Before a document is saved (no id) the tile is hidden.

**Where it appears (only these places):**
1. At the top of `DocumentExportSheet` (every tool opens it after saving, so every document gets the picker without touching each tool).
2. In «مستنداتي»: a «يُحسب شاهدًا لـ» action in the document card's menu (`DocumentCardWidget` / `MyDocumentsList`), opening the sheet. Refresh the list after a change.
3. In the T8 report settings sheet (if T8 exists).

### 3.5 «مستنداتي» and `performance_file`
In `MyDocumentsScreen._open`: when `document.type == DocumentTypes.performanceFile`, do not look for a tool. Open `DocumentExportSheet` for it with a note at the top «يُحدَّث هذا الملف من ملف الإنجاز» (add an optional `noteKey` parameter to the sheet). Duplicate / delete keep working as for other documents.

### 3.6 Entry button
In `PortfolioEditorHeaderWidget`, add one `PortfolioHeaderActionWidget` «الأداء الوظيفي» (icon `Icons.insights_outlined`) next to «تحميل PDF» → `Navigator.pushNamed(context, Routes.portfolioPerformance, arguments: portfolioId)`. On return, refresh the editor (`PortfolioEditorCubit.refresh()`), since evidence may have changed.

### 3.7 Editor counts (`FRONTEND_TASK_PERFORMANCE.md` section 4)
The editor's «✓ n شواهد» uses `files.length`, which now disagrees with the performance view (documents count too). **Do the minimal fix:** rename the editor label to «مرفقات» (new key `portfolio_attachments_count`). Do not change the editor's progress logic.

---

## 4. Feature folder

```
lib/features/performance/
├── presentation/
│   ├── cubit/
│   │   ├── performance_cubit.dart + performance_state.dart          # the whole view
│   │   └── performance_export_cubit.dart + performance_export_state.dart
│   ├── screens/
│   │   ├── performance_screen.dart              # Routes.portfolioPerformance (arg: portfolio id)
│   │   └── performance_item_screen.dart         # Routes.portfolioPerformanceItem (arg: (portfolioId, itemId))
│   └── widgets/                                 # one widget per file, all prefixed performance_
```
Data lives in `lib/features/portfolio/data/` (section 3.2) because it is the same portfolio API.

---

## 5. Cubits

### 5.1 `PerformanceCubit` (provided above both screens: the item screen gets it with `BlocProvider.value`)
Constructor: `portfolioId`, `PortfolioRepository`, `DocumentsRepository`, `DeviceFilePicker`.
State: `performance`, `elements` (from roles, for the move sheet), `isLoading`, `error`, `busyItemIds (Set<int>)`, `uploadProgress (Map<int,double>)`, `paymentRequired`, `message`.
- `load()` / `refresh()` → `getPerformance` + `getRoles` in parallel.
- `setRating(itemId, int? rating)`: optimistic update of the item, call `setSelfRating`, then `refresh()` to get the new `rating` summary from the server (do not compute the summary locally). On failure revert + `error`. Pressing the current rating again sends `null`.
- `setIncluded(itemId, bool)` → existing `updateItem(..., included:)`, then refresh.
- `addEvidence(itemId, DeviceFileSource)` → pick → `PortfolioRepository.uploadFile(... onProgress)` → refresh. `addLink(itemId, url, title)` → `addLink` → refresh. `deleteFile(itemId, fileId)` → refresh.
- `moveDocument(documentId, String? elementKey)` → `DocumentsRepository.setElement` → refresh (the document disappears from this item and appears under the new one).
- `saveCv(PortfolioProfileModel cv)` → `updatePortfolio(portfolioId, profile: mergedProfile)`. Merge onto the full current profile so phone/email/signatures are kept; to get it, `getPortfolio(portfolioId)` once in `load()`.
- All failures → `error` (API message), `PaymentRequiredFailure` → `paymentRequired`.

### 5.2 `PerformanceExportCubit`
State: `includeRatings (default true)`, `theme (DocumentTheme, default teal)`, `isExporting`, `documentId`, `error`.
- `export()` → `exportPerformanceFile(portfolioId, includeRatings:, theme:)` → emit `documentId` → the screen opens `DocumentExportSheet.show(context, documentId: id, withExcel: false)`.
- Called **every time** before printing (never reuse an old `document_id`).

---

## 6. Screens

### 6.1 `PerformanceScreen`
- `ConditionalBuilder`: loading / error (`PrimaryErrorView` + retry) / data. Pull-to-refresh.
- Header card (`PerformanceHeaderCard`): portfolio title, `role_label`, rating summary «التقييم الذاتي: 4.33 من 5 (13 من 15)», plus «قُيّم 2 من 11» when `rated < elements`; **hidden when `rated == 0`**. Button «تصدير ملف الأداء الوظيفي».
- `PerformanceCvSection` (collapsible, above the cards): the 10 fields as `PrimaryTextField`s, «حفظ», and the hint «لا نحفظ رقم الهوية. إن طلبته مدرستك فأضفه إلى ملف Word بعد تحميله.» Controllers live in a small `StatefulWidget` that only holds them.
- List of `PerformanceItemCard`, in order: «العنصر 4» (when `number`), title, weight «10%», state chip (`none` grey «لا توجد شواهد», `some` amber «شواهد جزئية», `complete` green «مكتمل») with `evidence_count`, the rating stars (read-only here), dimmed when `included == false`. Tap → item screen.
- Colors for the three states come from `ColorsManager` (add tokens there if missing, e.g. `statusWarning` already exists — check before adding).

### 6.2 `PerformanceItemScreen`
- Title, number, weight, description.
- `PerformanceRatingStars` (1–5 from `rating_scale`, tap selected again to clear) — only when the item has a `weight`.
- «تضمين في الملف» switch (`included`).
- «الشواهد»: the item's files using the existing `PortfolioFilesStripWidget` / `PortfolioFileThumbnailWidget` if they don't depend on `PortfolioEditorCubit`; if they do, extract the pure display part into a widget both screens use (no copy-paste). «إضافة شاهد» → `PrimaryFileSourceSheet` (photo / PDF / link) exactly as the editor does, with a progress indicator.
- «من مستنداتك في حضّر»: `PerformanceDocumentTile` per document (title, date) with «فتح» (open the tool screen via `documentToolFor(type)`; for unsupported types show `document_type_unsupported`) and «نقل» (`DocumentElementSheet` → `moveDocument`).
- Empty state «لا توجد شواهد مضافة لهذا العنصر.»

### 6.3 Export sheet (`PerformanceExportSheet`)
«إظهار التقييم الذاتي في الملف» switch (`include_ratings`, on), `DocumentThemePicker`, button «تصدير» → `PerformanceExportCubit.export()` → close this sheet → `DocumentExportSheet.show(...)`.

---

## 7. Translations
All keys in **both** files. CV labels (exact Arabic):

| Field | Key | Arabic |
|---|---|---|
| `name` | `performance_cv_name` | الاسم |
| `qualification` | `performance_cv_qualification` | المؤهل العلمي |
| `specialty` | `performance_cv_specialty` | التخصص |
| `job_title` | `performance_cv_job_title` | المسمى الوظيفي |
| `rank` | `performance_cv_rank` | الرتبة |
| `service_start` | `performance_cv_service_start` | تاريخ المباشرة |
| `stage` | `performance_cv_stage` | المرحلة |
| `subjects` | `performance_cv_subjects` | المواد الدراسية |
| `school_name` | `performance_cv_school_name` | المدرسة |
| `academic_year` | `performance_cv_academic_year` | العام الدراسي |

Others (at least): `performance_title`, `performance_open`, `performance_self_rating`, `performance_rating_summary` («التقييم الذاتي: {avg} من {max} ({points} من {out_of})»), `performance_rated_count` («قُيّم {rated} من {elements}»), `performance_element_number` («العنصر {n}»), `performance_weight`, `performance_state_none`, `performance_state_some`, `performance_state_complete`, `performance_evidence_count`, `performance_include`, `performance_add_evidence`, `performance_hader_documents`, `performance_open_document`, `performance_move_document`, `performance_no_evidence`, `performance_cv`, `performance_cv_hint`, `performance_cv_saved`, `performance_export`, `performance_export_include_ratings`, `performance_file_note`, `document_element_label`, `document_element_change`, `document_element_none`, `document_element_saved`, `document_type_performance_file`, `document_type_performance_file_subtitle`, `portfolio_attachments_count`.
Placeholders are replaced in the widget with `.replaceAll('{x}', value)`.

---

## 8. Tests (mocktail)
- `test/features/portfolio/data/models/performance_model_test.dart`: full JSON, `percent/average` null, unknown `state`, missing `documents`, `included: false`.
- `portfolio_roles_model_test.dart`: `elements` + `rating_scale`, and old JSON without them.
- `portfolio_profile_model_test.dart`: new CV fields round-trip, old fields kept.
- Repository test for `setSelfRating(null)` sending `{"self_rating": null}` (mock `DioHelper` the way existing repository tests do, or test the payload builder as a pure function).
- `document_model` test: `element` parsed / null.
- `test/features/performance/presentation/cubit/performance_cubit_test.dart`: load; rating optimistic + refresh; clearing; revert on failure; move document → refresh; CV merge keeps phone/email/signatures; 402.
- `performance_export_cubit_test.dart`: export emits `documentId`; options sent; failure.
- `document_element_cubit_test.dart`: load elements, change to key, change to none.

Run `flutter analyze` (zero new issues) and `flutter test` before you finish. After editing translations, check no existing key disappeared (compare with `git show HEAD:assets/translations/ar.json`).

---

## 9. Order of work
1. Endpoints, models (+ tests), repository methods.
2. Element picker (cubit, tile, sheet) + `DocumentModel.element`; put it in `DocumentExportSheet` and «مستنداتي».
3. `PerformanceCubit` + tests; performance screen (header, cards, CV).
4. Item screen (rating, evidence, documents + move).
5. Export cubit + sheet → `DocumentExportSheet`; `performance_file` in «مستنداتي».
6. Entry button in the portfolio editor, «مرفقات» label, translations, `flutter analyze`, tests.

## 10. Done when
- [ ] After making a strategy documentation (T4), a remedial plan (T1) and a grade analysis (T7), elements 4, 5 and 10 each show one document without attaching anything.
- [ ] Moving a document to another element, or to «لا يُحسب شاهدًا», updates the screen and the exported file.
- [ ] Ratings update the summary; clearing works; the public share page doesn't show them.
- [ ] The exported file with 30 photos converts to PDF on an average Android phone without running out of memory, and shares with `share_plus`; the Word file opens with readable Arabic.
- [ ] The phone number never appears in the exported file; saving the CV keeps the phone/email/signatures in the portfolio.
- [ ] The performance file opens from «مستنداتي» read-only with «يُحدَّث هذا الملف من ملف الإنجاز».
- [ ] The portfolio editor and all document tools behave as before; every string in `ar.json` and `en.json`; `flutter analyze` clean; tests pass.
