# Agent guide: «التقارير والشواهد» (T8, report designer v1, `type: "report"`)

You are implementing a new document tool in the Flutter app at the repo root (package name `moean`).
The teacher builds a free report from **blocks**, usually starting from a template: adds, edits,
reorders and deletes blocks, adds photos, then saves, prints (PDF) and downloads Word like every other
document tool.

Read this whole file before writing code. Follow it exactly. When it conflicts with `rules.md`, `rules.md` wins.

---

## 0. Ground rules (from `rules.md`, non-negotiable)

- **Cubit only.** `XCubit.get(context)` (`static XCubit get(BuildContext context) => BlocProvider.of(context);`). **Never** `context.read` / `context.watch`.
- Every `BlocBuilder` / `BlocConsumer` has a `buildWhen`.
- **One widget per file.** No private methods returning `Widget`. Pages ≤ 150 lines.
- **No hardcoded text.** Every string in **both** `assets/translations/ar.json` and `en.json`, via `appTranslation().get('key')`. New keys start with `report_`.
- `ColorsManager`, `TextStylesManager`, `spacing.dart` only. No `Theme.of(context)` for colors/styles. `withValues(alpha:)`, never `withOpacity`.
- Repositories return `Either<Failure, T>`; never throw.
- `ConditionalBuilder` when a screen has loading + error + empty + success.
- Reuse `lib/core/utils/constants/primary/` (`PrimaryTextField`, `PrimaryElevatedButton`, `PrimarySectionCard`, `PrimaryChoiceChips`, `PrimaryEditableList`, `PrimaryConfirmDialog`, `PrimarySnackBar`, `PrimaryErrorView`, `NoDataWidget`, `UpgradePromptBottomSheet`). Do not copy them.
- No new packages. Unit tests (mocktail) for every cubit, model and pure helper. No dead code.
- **Do not change behaviour of other features.** Only the small, additive shared changes listed in section 3. Do not touch `lib/features/online_tests/`, `lib/features/qr_codes/`, `lib/features/exam_extraction/`.

**Project deviation you must keep:** routes are constants in `lib/core/utils/constants/routes.dart` (`Routes` + route map). Navigate with `Navigator.pushNamed(context, Routes.x, arguments: …)`.

---

## 1. Model to copy: the strategy documentation tool

`lib/features/strategy_documentation/` is the reference for a document tool. Read it fully before you start:
- `StrategyDocumentationCubit`: loads catalogue + defaults + the saved document in parallel, keeps `documentId`, saves with `POST /documents` the first time then `PATCH`, uploads photos.
- `strategy_documentation_screen.dart`: after save, calls `runDocumentFollowUp(...)` (`lib/features/documents/presentation/document_follow_up.dart`), which opens the shared export sheet (PDF / Word) or the attach-to-portfolio sheet.
- Its widgets use the shared document widgets listed below.

## 2. What already exists and must be reused

| Need | Existing code |
|---|---|
| Documents API (create, update, get, list, print, preview, exports, uploads) | `DocumentsRepository` (`lib/features/documents/data/repositories/documents_repository.dart`): `createDocument`, `updateDocument`, `getDocument`, `getDocuments`, `uploadImage(DevicePickedFile)`, `getPrint`, `previewDocument`, `requestExport`, `getExport`. **Do not write new calls for these.** |
| Defaults (teacher, principal, logos) | `DocumentsRepository.getDefaults()`, `DocumentHeaderOverrides`, `DocumentHeaderSection` |
| PDF / Word / share | `DocumentExportSheet` via `runDocumentFollowUp(context, followUp: DocumentFollowUp.export, documentId:, documentType: DocumentTypes.report, portfolioItemKey:)`. PDF goes through the **native `html_pdf` channel** in `DocumentFileService` — never call `Printing.convertHtml` yourself (broken on Android in this app). |
| Preview | `DocumentPreviewCubit` + `DocumentPreviewImage` / `DocumentPreviewSheet` (`POST /documents/preview`) |
| Photos | `DocumentImagesSection` / `DocumentMediaAndDesignSections`, `DocumentUploadRules`, `DeviceFilePicker` (already resizes to 2000 px / 85 %) |
| Theme | `DocumentThemePicker`, `DocumentTheme` |
| Actions bar | `DocumentActionsBar` (save / export / attach) |
| Attach to portfolio | `AttachToPortfolioSheet` (through `runDocumentFollowUp`) |
| «مستنداتي» | `documentTools` in `lib/features/documents/presentation/document_tools.dart`, `DocumentTypes` in `document_model.dart` |
| 402 | `UpgradePromptBottomSheet.show(...)`; `failureFromApiError` already maps 402 to `PaymentRequiredFailure` |
| 422 errors | `ValidationFailure.errors` (`lib/core/errors/failures.dart`) — check how `DioHelper.parseError` passes `errors`; if 422 `errors` are not kept today, add that in a backwards-compatible way (section 3.4). |

---

## 3. Shared, additive changes

### 3.1 Register the type
- `DocumentTypes.report = 'report'` in `lib/features/documents/data/models/document_model.dart`, add it to `all`.
- Translation keys `document_type_report` and `document_type_report_subtitle` (the label pattern `DocumentTypes.labelKey`).
- Add `DocumentTool(type: DocumentTypes.report, icon: Icons.summarize_outlined, route: Routes.reports)` to `documentTools`.

### 3.2 Endpoints (`lib/core/network/remote/api_endpoints.dart`)
```dart
const String reportsToolApi = '/tools/reports';
String reportTemplateApi(String key) => '/tools/reports/$key';
```

### 3.3 Photos limit
`DocumentUploadRules.maxImagesPerDocument` is 6, but a report allows **12**. Do **not** change the constant. Add an optional `maxImages` parameter (default `DocumentUploadRules.maxImagesPerDocument`) to `DocumentImagesSection` (and pass-through in `DocumentMediaAndDesignSections` if you use it), and pass `12` from the report.

### 3.4 Field errors (422)
The report needs the keys of `errors` (e.g. `blocks.3.items.0`). **Today they are lost:** `DioHelper.parseError` (`lib/core/network/remote/dio_helper.dart`) joins the `errors` values into one string and returns only that. Fix it the same way 402/409 are already passed through:
- in `parseError`, for `statusCode == 422` with an `errors` map, return `'__422__:' + jsonEncode({'message': <the same joined text as today>, 'errors': errors})`;
- in `failureFromApiError` (`lib/core/errors/failures.dart`), decode a `__422__:` string into `ValidationFailure(message, errors)`. Check for `__422__:` **before** the generic `error.startsWith('__')` branch (that one splits on `:` and would break the JSON).
Every other screen keeps showing the same `failure.message` as before. Do not change anything else in `DioHelper`. Unit-test both functions (422 with errors, 422 without errors, other codes unchanged).

### 3.5 Element picker («يُحسب شاهدًا لـ»)
The settings sheet needs the element picker from T9 (`agent_tasks/T9_PERFORMANCE_AGENT_GUIDE.md` section 3.4). **If it already exists, reuse it. If not, build it exactly as described there** (shared, in `lib/features/documents/`), so both tasks use one widget.

---

## 4. API contract (backend `docs/DOCUMENTS_API.md` section 12, plus 2–4)

### 4.1 Catalogue
`GET /tools/reports` →
```json
{ "data": {
  "templates": [ { "key": "class_visit", "label": "تقرير زيارة صفية", "description": "…", "element": "professional_community" } ],
  "block_kinds": [ { "kind": "heading", "label": "عنوان" } ],
  "limits": { "blocks": 60, "meta": 8, "images": 12, "title_chars": 150, "text_chars": 3000, "item_chars": 500,
              "list_items": 30, "table_columns": 8, "table_rows": 40, "kv_pairs": 20, "chart_labels": 12, "chart_series": 4 } } }
```
- 11 templates, «تقرير فارغ» first. `block_kinds` is the «إضافة» menu, in order.
- **Always use `limits` from the response**, not hardcoded numbers (keep the numbers above only as model defaults).

`GET /tools/reports/{key}` → `{ key, label, element, input }`. **`input` is the editor state as-is**: `template`, `title`, `meta` (labels, empty values) and starter `blocks`. Some starter lines are empty on purpose; keep them.

### 4.2 `input`
| Field | Rule |
|---|---|
| `title` | **required**, ≤ 150 |
| `template` | template key or empty (sets the default `element`) |
| `meta[]` | ≤ 8 `{label, value}`, label ≤ 60, value ≤ 300. Rows without a value are left out of the print |
| `blocks[]` | ≤ 60 blocks |
| `signatures[]` | ≤ 4 `{title, name}`. Empty → teacher + principal from defaults |
| `images` | ≤ 12 `storage_path`s from `POST /documents/uploads` |
| `theme`, `header` | as in the other tools |

### 4.3 Blocks (each kind keeps only its own fields)
| `kind` | Fields |
|---|---|
| `heading` | `text` ≤ 200 |
| `paragraph` | `text` ≤ 3000 |
| `list` | `items[]` ≤ 30 (≤ 500 each), `ordered` bool |
| `checklist` | `items[]` ≤ 30 |
| `table` | `columns[]` 1–8 (≤ 100), `rows[][]` ≤ 40 rows of text cells (≤ 500), `widths[]` optional, `compact` bool |
| `kv` | `pairs[]` ≤ 20 `{label, value}` |
| `columns` | `columns[]` 2–3 `{heading, items[]}` |
| `images` | `items[]` = paths **that are in `input.images`**, `columns` 1–3 (default 2) |
| `chart` | `title`, `labels[]` ≤ 12, `series[]` ≤ 4 `{name, values[]}` (numbers ≥ 0), `compact` bool |
| `qr` | `url` (**https only**, ≤ 1000), `caption` |
| `page_break` | — |

- Empty texts are fine while editing; empty blocks are left out of the print.
- An `images` block path not in `input.images` → `422` («أضف الصورة إلى صور التقرير أولًا»). Photos in `input.images` not used by any block print at the end under «الشواهد».
- Errors point at fields: `blocks.3.items.0`, `blocks.5.url`, `blocks.N.kind`.
- **Unknown future kinds:** keep them in the list untouched (show a read-only card «نوع غير مدعوم»), and send them back as they came. Never drop data.

### 4.4 Save / print / Word
- First save `POST /documents {type: "report", input}`; after that `PATCH /documents/{id} {input}`.
- PDF / Word / attach: through `runDocumentFollowUp` (section 2). Print is always the **saved** version, so save first.

---

## 5. Feature folder

```
lib/features/reports/
├── data/
│   ├── models/
│   │   ├── report_catalogue_model.dart   # ReportTemplateModel, ReportBlockKindModel, ReportLimitsModel
│   │   ├── report_block.dart             # sealed ReportBlock + one subclass per kind (fromJson/toJson/copyWith)
│   │   ├── report_input.dart             # ReportInput {template, title, meta, blocks, signatures, images, theme, header, extra}
│   │   └── report_field_error.dart       # parses "blocks.3.items.0" → (blockIndex: 3, path: "items.0")
│   └── repositories/
│       └── reports_repository.dart       # getCatalogue(), getTemplate(key)
├── presentation/
│   ├── cubit/
│   │   ├── report_templates_cubit.dart + report_templates_state.dart
│   │   └── report_editor_cubit.dart + report_editor_state.dart
│   ├── screens/
│   │   ├── report_templates_screen.dart  # Routes.reports
│   │   └── report_editor_screen.dart     # Routes.reportEditor
│   └── widgets/                          # one widget per file, all prefixed report_
```

### 5.1 Models
- `ReportBlock` is a **sealed class** with `kind` and an immutable `id` (a local id, e.g. an incrementing int or `UniqueKey().toString()` made in the cubit, **not sent to the API**) used as the `ValueKey` in the reorderable list. Subclasses: `HeadingBlock`, `ParagraphBlock`, `ListBlock`, `ChecklistBlock`, `TableBlock`, `KvBlock`, `ColumnsBlock`, `ImagesBlock`, `ChartBlock`, `QrBlock`, `PageBreakBlock`, `UnknownBlock(raw Map)`.
  - `ReportBlock.fromJson(Map)` switches on `kind`; parse defensively (wrong types → empty values).
  - `toJson()` writes only that kind's fields.
  - `bool get isEmpty` per kind (for the «فارغ» hint only; never drop blocks in the app).
  - `TableBlock.toJson()` pads/trims each row to `columns.length`.
  - `ChartBlock` values are `double`; parse `"12"` and `12` alike; negative → 0.
- `ReportInput.fromJson / toJson` keeps unknown top-level keys in `extra` and writes them back (same idea as `ClassSheetInput.extra`).
- Use `Equatable` so `buildWhen` can compare one block.

### 5.2 `ReportsRepository`
```dart
Future<Either<Failure, ReportCatalogueModel>> getCatalogue();          // GET /tools/reports
Future<Either<Failure, ({String key, String? element, ReportInput input})>> getTemplate(String key);
```
Saving, printing, photos → `DocumentsRepository` (do not duplicate).

---

## 6. Cubits

### 6.1 `ReportTemplatesCubit`
- `load()` → catalogue + `DocumentsRepository.getDocuments(type: DocumentTypes.report)` in parallel. State: `catalogue`, `savedReports`, `isLoading`, `error`.
- `openTemplate(key)` is **not** here; the editor loads the template (so the editor works the same from «مستنداتي»).

### 6.2 `ReportEditorCubit`
Constructor: `documentId (int?)`, `templateKey (String?)`, `ReportsRepository`, `DocumentsRepository`, `DeviceFilePicker`.
State: `catalogue`, `input (ReportInput)`, `images (List<DocumentImageModel>)`, `documentId`, `element`, `status`, `isSaving`, `isUploading`, `isDirty`, `blockErrors (Map<int, String>)`, `titleError`, `paymentRequired`, `error`, `followUp`.

- `load()`:
  - `documentId != null` → `getDocument(id)` → `ReportInput.fromJson(doc.input)`, `images` from `doc.images` (signed urls), `element` from the doc.
  - else `templateKey` → `getTemplate(key)`; else the blank template (`'blank'` key from the catalogue, the first template).
  - Always load the catalogue (for `block_kinds` and `limits`) and the defaults.
- Header: `setTitle`, `addMeta`, `updateMeta(i, label, value)`, `removeMeta(i)` (respect `limits.meta`).
- Blocks: `addBlock(kind, {int? at})` (empty block of that kind), `updateBlock(id, ReportBlock)`, `duplicateBlock(id)` (new local id), `removeBlock(id)`, `reorder(oldIndex, newIndex)` (the `ReorderableListView` convention: adjust `newIndex` when moving down). Respect `limits.blocks`.
- Per-kind helpers, so widgets stay dumb: list/checklist items add/edit/remove/reorder; table add/remove column (≤ `table_columns`), add/edit/remove row (≤ `table_rows`); kv pairs; columns block 2↔3; images block toggle path / set columns; chart labels and series (≤ `chart_labels`, `chart_series`); qr url/caption.
- Photos: `pickImage(source)` → `DocumentUploadRules.validate` → `uploadImage` → add to `input.images` and `images`. `removeImage(path)` also removes it from every `images` block.
- `setTheme`, signatures `add/update/remove` (≤ 4), `setElement(key)` (calls the shared picker's PATCH when `documentId != null`; before the first save keep it in state and send `element` with the create).
- Validation before save (local, same rules as the API): title required; `qr.url` must start with `https://`; image paths must be in `input.images`. Local errors go into `blockErrors` / `titleError` and **block the save**.
- `save({DocumentFollowUp? followUp})`: create or patch; `isDirty = false`; keep `documentId`. On `ValidationFailure` map every `errors` key with `ReportFieldError.parse` → `blockErrors[index] = message` (and `title` → `titleError`); emit `scrollToBlock` = the first index. `PaymentRequiredFailure` → `paymentRequired`.
- **Autosave:** after the first save, debounce 3 s after the last change → `save()` silently (no follow-up, no snackbar on success). Also save in `close()`-adjacent flow: the screen calls `saveIfDirty()` from `PopScope` before leaving.
- «أنشئ بالذكاء الاصطناعي»: **no logic**. The button is disabled with a «قريبًا» chip. Do not add an AI cubit.

---

## 7. Screens and widgets

### 7.1 Entry
- `Routes.reports = '/tools/reports'` → `ReportTemplatesScreen`.
- `Routes.reportEditor = '/tools/reports/editor'`. Arguments: `int` (document id, from «مستنداتي» — `documentTools` passes the id as the argument) **or** `String` (template key). Parse both in the route builder.
- Add a home chip «التقارير والشواهد» next to the other document tools in `home_features_section_widget.dart` (legacy file: only add the chip, do not refactor it; logged-out → `Routes.login`, same as its neighbours).

### 7.2 `ReportTemplatesScreen`
- `ConditionalBuilder` (loading / error with retry / data).
- A 2-column grid of `ReportTemplateCard` (`label`, `description`), «تقرير فارغ» first and visually distinct.
- Below it «تقاريري المحفوظة»: the saved reports (`DocumentCardWidget` from documents if it fits; otherwise a small `ReportSavedTile`), tap → editor with the id.

### 7.3 `ReportEditorScreen`
Layout (scrollable, RTL):
1. Top bar: title, «معاينة» (preview sheet), «الإعدادات» (settings sheet), save state («تم الحفظ» / «جارٍ الحفظ…»).
2. Disabled «أنشئ بالذكاء الاصطناعي» button with «قريبًا».
3. `ReportTitleField` + `ReportMetaSection` (label/value rows, «+ سطر», delete).
4. `ReportBlocksList`: `ReorderableListView.builder` (`shrinkWrap`, `buildDefaultDragHandles: false`, a drag handle per card), key = `ValueKey(block.id)`.
   - `ReportBlockCard`: header (kind icon + label, drag handle, ⋮ menu «نسخ» / «حذف»; long press opens the same menu), red border + message when `blockErrors[index]` exists, body by kind:
     | Kind | Widget |
     |---|---|
     | heading | `ReportHeadingEditor` (one line) |
     | paragraph | `ReportParagraphEditor` (multiline, counter to 3000) |
     | list / checklist | `ReportItemsEditor` (reuse `PrimaryEditableList`), plus ordered toggle for list |
     | table | `ReportTableEditor`: a read-only preview grid; header cells editable in a sheet; **each row edited in a bottom sheet** (`ReportTableRowSheet`); add/remove column/row; «خط صغير» toggle |
     | kv | `ReportKvEditor` |
     | columns | `ReportColumnsEditor` (2/3 switch, each column: heading + items) |
     | images | `ReportImagesBlockEditor`: chips/thumbnails of `input.images` to toggle, 1–3 per row selector; hint when there are no photos yet |
     | chart | `ReportChartEditor`: title, labels list, per series a name + a value field per label (numbers only), «مختصر» toggle |
     | qr | `ReportQrEditor`: https url (validated) + caption, a small live `QrImageView` preview |
     | page_break | `ReportPageBreakDivider` («صفحة جديدة») |
     | unknown | `ReportUnsupportedBlockCard` |
   - A small «+» between blocks and «+ إضافة» at the end → `ReportAddBlockSheet` listing `block_kinds` (label + icon per kind).
   - Each card's `BlocBuilder` rebuilds only when **its** block or its error changes (`buildWhen` compares the block with the same id).
   - Text controllers: card editors that own controllers are small `StatefulWidget`s that only hold controllers, created from the block on `initState`, synced in `didUpdateWidget` only when the value differs (avoid cursor jumps). No logic in them.
5. `ReportPhotosSection`: `DocumentImagesSection(maxImages: limits.images)` + the hint «الصور غير المستخدمة في أي قسم تُطبع في آخر التقرير تحت «الشواهد»».
6. Bottom: `DocumentActionsBar` (save / export / attach) exactly like the strategy tool.

`ReportSettingsSheet`: `DocumentThemePicker`, signatures (≤ 4, title + name; defaults shown as hints), the element picker (section 3.5), `DocumentHeaderSection` overrides if the strategy tool shows them.

Listeners: `paymentRequired` → upgrade sheet; `error` → snackbar; `scrollToBlock` → `Scrollable.ensureVisible` on that card (give cards a `GlobalKey` map in the screen state, not in the cubit); `followUp` after save → `runDocumentFollowUp`.

`PopScope`: when dirty, save first (`saveIfDirty`), then pop. If the report was never saved and the title is empty, ask with `PrimaryConfirmDialog` («تجاهل التقرير؟»).

---

## 8. Translations
All new keys in **both** files, prefix `report_` (plus `document_type_report`, `document_type_report_subtitle`). At least:
`report_title`, `report_templates`, `report_blank`, `report_saved_reports`, `report_title_label`, `report_title_required`, `report_meta`, `report_meta_label`, `report_meta_value`, `report_add_line`, `report_add_block`, `report_duplicate`, `report_delete`, `report_delete_confirm`, `report_ai_draft`, `report_soon`, `report_preview`, `report_settings`, `report_saving`, `report_saved`, `report_signatures`, `report_signature_title`, `report_signature_name`, `report_photos`, `report_photos_hint`, `report_no_photos`, `report_new_page`, `report_unsupported_block`, `report_list_ordered`, `report_add_item`, `report_table_add_column`, `report_table_add_row`, `report_table_edit_row`, `report_table_compact`, `report_columns_count`, `report_column_heading`, `report_images_per_row`, `report_chart_title`, `report_chart_labels`, `report_chart_series`, `report_chart_value`, `report_chart_compact`, `report_qr_url`, `report_qr_url_invalid`, `report_qr_caption`, `report_image_not_in_report`, `report_limit_reached`, `report_discard_confirm`, and one label key per block kind (`report_kind_heading` … `report_kind_page_break`) used when the catalogue isn't loaded.

---

## 9. Tests (mocktail, under `test/features/reports/`)
- `report_block_test.dart`: `fromJson`/`toJson` round-trip for **every** kind; bad types; table row padding/trimming; chart value parsing; unknown kind kept as-is.
- `report_input_test.dart`: extra keys kept; empty meta values kept in the editor.
- `report_field_error_test.dart`: `blocks.3.items.0`, `blocks.5.url`, `title`, garbage.
- `report_editor_cubit_test.dart`: load from template / from document; add/duplicate/remove/reorder (ids stable, order correct both directions); limits respected; removing a photo removes it from images blocks; local validation blocks save (bad qr url, image not in report, no title); first save creates then patches; 422 fills `blockErrors` and `scrollToBlock`; 402 → `paymentRequired`; autosave debounce (use a short injectable duration).
- `report_templates_cubit_test.dart`: load success / failure.
- If you touched 422 parsing (3.4): a test for it.

Run `flutter analyze` (zero new issues) and `flutter test` before you finish. After editing the translation files, check that no existing key disappeared (compare key counts with `git show HEAD:assets/translations/ar.json`).

---

## 10. Order of work
1. Type, endpoints, models + tests.
2. Repository, templates cubit + screen.
3. Editor cubit (all logic) + tests.
4. Editor screen: title/meta, blocks list with the simple kinds, add sheet, reorder, duplicate/delete.
5. Table, chart, images, qr editors; photos section.
6. Settings sheet (+ element picker), save/autosave, export via `runDocumentFollowUp`, 422 highlighting.
7. Home chip, «مستنداتي» registration, translations, `flutter analyze`, tests.

## 11. Done when
- [ ] Each of the 11 templates opens, saves without editing, converts to PDF on the phone and downloads as Word.
- [ ] Reordering, duplicating and deleting blocks is kept after closing and reopening from «مستنداتي».
- [ ] A report with 6 photos, a table and a chart converts to PDF without running out of memory and shares with `share_plus`.
- [ ] A `422` highlights the right block and scrolls to it.
- [ ] Unplaced photos print at the end under «الشواهد».
- [ ] The AI button is visible, disabled, marked «قريبًا».
- [ ] No other feature changed behaviour; every string in `ar.json` and `en.json`; `flutter analyze` clean; tests pass.
