# Agent guide: «كيواركود» (T6: link → QR, file → link + QR)

You are implementing a new feature in the Flutter app at the repo root (package name `moean`).
Read this whole file before writing code. Follow it exactly. When something here conflicts with
your own habits, this file wins. When it conflicts with `rules.md`, `rules.md` wins.

---

## 0. Ground rules (from `rules.md`, non-negotiable)

- **Cubit only.** Get a cubit with `XCubit.get(context)` (a `static XCubit get(BuildContext context) => BlocProvider.of(context);`). **Never** `context.read` / `context.watch`.
- Every `BlocBuilder` / `BlocConsumer` has a `buildWhen`.
- **One widget per file.** No private methods that return `Widget`. Pages ≤ 150 lines; split into widgets.
- **No hardcoded text.** Every string goes in **both** `assets/translations/ar.json` and `assets/translations/en.json`, read with `appTranslation().get('key')` (`lib/core/utils/constants/constants.dart`). All new keys start with `qr_`.
- Colors from `ColorsManager` (`lib/core/theme/colors.dart`), text styles from `TextStylesManager` (`lib/core/theme/text_styles.dart`), spacing from `lib/core/utils/constants/spacing.dart`. Never `Theme.of(context)` for colors or styles. Use `withValues(alpha:)`, never `withOpacity`.
- Repositories return `Either<Failure, T>` (dartz). Failures are in `lib/core/errors/failures.dart`. Never throw from a repository.
- Use `ConditionalBuilder` (`lib/core/utils/constants/primary/conditional_builder.dart`) when a screen has loading + error + empty + success.
- Reuse the shared widgets in `lib/core/utils/constants/primary/` (`PrimaryTextField`, `PrimaryElevatedButton`, `PrimarySectionCard`, `PrimaryChoiceChips`, `PrimaryConfirmDialog`, `PrimarySnackBar`, `PrimaryErrorView`, `NoDataWidget`, `PrimaryFileSourceSheet`, `UpgradePromptBottomSheet`). Do not copy them. A new widget that two features would use goes in that folder.
- Package versions are **pinned** (no `^`) for anything you add.
- Unit tests with `mocktail` for every cubit and every pure helper, under `test/` mirroring `lib/`.
- No dead code. Delete anything you add and stop using.

**Project deviation you must keep:** routes are constants in `lib/core/utils/constants/routes.dart` (class `Routes` + its route map), **not** in `lib/core/router/app_router.dart`. Navigate with `Navigator.pushNamed(context, Routes.x, arguments: …)`.

---

## 1. Do NOT touch the online tests feature

`lib/features/online_tests/` («الاختبارات الإلكترونية») already shows a QR per class link, and its home chip uses a QR icon. **It is a different feature** (sharing an exam with students). Its logic is not what this task needs:
- do not add this task's code there;
- do not change its screens, cubits, or repository;
- do not "reuse" its cubits for files.

You may only look at it as a style example. The new feature lives in its own folder: `lib/features/qr_codes/`.

---

## 2. What already exists and must be reused

| Need | Existing code | How to use it |
|---|---|---|
| HTTP to our API | `DioHelper` (`lib/core/network/remote/dio_helper.dart`) + `handleApiResponse` (`lib/core/network/remote/api_response_handler.dart`) | Every repository method is `handleApiResponse(DioHelper.getData/postData/patchData/deleteData(...), parser)`. Look at `lib/features/online_tests/data/repositories/online_tests_repository.dart` for the style. |
| `meta` beside `data` | `handleApiResponse(..., unwrapData: false)` | Needed for `GET /shared-files` (it returns `data` **and** `meta`). |
| Error → Failure | `failureFromApiError` in `failures.dart` | Already does: API `message` kept as-is (Arabic, show it), `402` → `PaymentRequiredFailure`. **Show `appTranslation().get(failure.message)`** (it returns the message itself when it isn't a key). |
| 402 (no plan) | `UpgradePromptBottomSheet.show(...)` | Same call as in `lib/features/exam_generation/presentation/screens/manual_exam_screen.dart`. |
| Signed upload to R2 | `StorageClient` (`lib/core/services/storage_client.dart`) | Uses a **plain** `Dio()` with no `Authorization` header and no interceptors. Correct for R2. But it takes `Uint8List` (whole file in memory). You will add a streaming method (section 4.1). |
| Upload ticket model | `StorageUploadTicketModel` (`lib/core/models/upload_models.dart`) | `{upload_url, headers, storage_path}`. Reuse it for `POST /shared-files/uploads`. |
| Same 3-step flow | `PortfolioRepository.uploadFile` (`lib/features/portfolio/data/repositories/portfolio_repository.dart`) | Copy its shape: ticket → PUT → register. |
| File picking | `DeviceFilePicker` (`lib/core/services/device_file_picker.dart`) | Reads the whole file into memory (`withData: true`) and only knows jpg/png/webp/pdf. You will add path-based methods (section 4.2). Do not change the existing methods (other features use them). |
| QR on screen | `QrImageView` from `qr_flutter` (already in pubspec, `4.1.0`) | See `lib/features/portfolio/presentation/widgets/portfolio_share_link_widget.dart`. |
| Share | `SharePlus.instance.share(ShareParams(text: ..., files: [XFile...]))` (`share_plus`) | Same as `online_test_links_tab.dart`. |
| PDF + print | `pdf` + `printing` (in pubspec) | `Printing.layoutPdf(onLayout: (_) => bytes)` for «طباعة», `Printing.sharePdf` for share. Do **not** use `Printing.convertHtml` (broken on Android in this app). Build the PDF with `pw.Document` directly. |
| Arabic font in PDF | look at `lib/features/portfolio/data/services/portfolio_pdf_service.dart` | Load the same Arabic font the same way, `textDirection: pw.TextDirection.rtl`. |
| Endpoints | `lib/core/network/remote/api_endpoints.dart` | Add the constants there (section 3). |
| Logged-in check | home chips use `token != null && token!.isNotEmpty` | Same source of the token. |

### Packages
- Already present: `qr_flutter 4.1.0`, `share_plus`, `printing`, `pdf`, `file_picker`, `image_picker 1.2.4`, `dio`, `path_provider`.
- **Add (pinned):** `gal: 2.3.1` to save the QR image to the gallery.
  - Android: nothing extra for API 29+; add `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>` to `android/app/src/main/AndroidManifest.xml`.
  - iOS: add `NSPhotoLibraryAddUsageDescription` to `ios/Runner/Info.plist` (Arabic text, like the existing `NSPhotoLibraryUsageDescription`).
  - Call `Gal.requestAccess()` before `Gal.putImageBytes(bytes, name: ...)`.
- Do not add any other package.

---

## 3. API contract (backend: `moeen-backend/docs/SHARED_FILES_API.md`)

Base URL and auth are already handled by `DioHelper`. Errors: `{message, code, status}`; `message` is Arabic and ready to show.

Add to `api_endpoints.dart`:
```dart
const String sharedFilesApi = '/shared-files';
const String sharedFileUploadsApi = '/shared-files/uploads';
String sharedFileApi(int id) => '/shared-files/$id';
```

| Call | Body | Response |
|---|---|---|
| `GET /shared-files` | – | `{data: [file…], meta: {used_bytes, quota_bytes, max_file_bytes, expiry_days: [7,30,90,365], default_expiry_days: 30, types: [{mime, ext, kind}]}}` (list items have **no** `qr_png`) |
| `POST /shared-files/uploads` | `{mime, byte_size}` | `{upload_url, headers, storage_path, expires_at}`. `422` codes `file_too_large`, `shared_files_quota`. `402` no plan. |
| `PUT upload_url` | raw bytes, **exactly** `headers` + `Content-Length`, **no `Authorization`** | 200. Link valid 30 min. |
| `POST /shared-files` | `{storage_path, original_name, title?, expires_in_days?}` | `201 {data: file}`. `422` codes `upload_not_found`, `upload_already_registered`, `file_type_not_allowed`, `file_too_large`, `shared_files_quota`. |
| `GET /shared-files/{id}` | – | `{data: file}` with `qr_png` |
| `PATCH /shared-files/{id}` | `{title?, expires_in_days?}` | `{data: file}`. Extends **from today** and reopens an expired link. `402` no plan. |
| `DELETE /shared-files/{id}` | – | 200/204 |

File object:
```json
{ "id": 12, "title": "ملخص الوحدة", "file_name": "درس الكسور.pdf", "mime": "application/pdf",
  "kind": "pdf", "byte_size": 482113, "downloads": 3,
  "expires_at": "2026-11-23T10:00:00+00:00", "is_expired": false,
  "share_url": "https://haderedu.com/f/Xk3…", "qr_png": "data:image/png;base64,…",
  "created_at": "2026-10-24T10:00:00+00:00" }
```
- `kind` ∈ `pdf | image | word | excel | powerpoint | video` (for the icon). `title` may be null → show `file_name`.
- Accepted: PDF; jpeg/png/webp/gif/heic; doc/docx/xls/xlsx/ppt/pptx; mp4/quicktime(.mov)/webm. ≤ `max_file_bytes` (100 MB).
- Mime: take it from `meta.types` by extension (lower-case). `.mov` → `video/quicktime`, `.heic` → `image/heic`. Unknown extension → refuse locally with a translated message, do not call the API.

---

## 4. Core changes (small, additive)

### 4.1 `StorageClient.uploadFile` (streaming)
Add, do not replace `upload`:
```dart
/// PUTs the file at [path] to the signed URL without loading it into memory.
Future<Either<Failure, Unit>> uploadFile(
  StorageUploadTicketModel ticket,
  String path,
  int byteSize, {
  void Function(double progress)? onProgress,
  CancelToken? cancelToken,
})
```
- `data: File(path).openRead()`, headers `{...ticket.headers, Headers.contentLengthHeader: byteSize}`.
- `onSendProgress: (sent, total) => onProgress?.call(sent / byteSize)`.
- Catch `DioException`: cancelled → `Left(ServerFailure('qr_upload_cancelled'))`, else `Left(ServerFailure('upload_failed'))`.
- Use a long `sendTimeout` for this call only (e.g. 30 minutes) via `Options(sendTimeout: …)`.

### 4.2 Path-based picking
In `lib/core/models/upload_models.dart` add:
```dart
/// A picked file read from disk when uploaded, for files too big to hold in memory.
class DevicePickedPath {
  final String path;
  final String name;
  final int byteSize;
  const DevicePickedPath({required this.path, required this.name, required this.byteSize});
  String get extension => …; // lower-case, without the dot, '' when none
}
```
In `DeviceFilePicker` add:
- `Future<DevicePickedPath?> pickFilePath(List<String> extensions)` → `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: extensions, withData: false)`; use `file.path` and `file.size`.
- `Future<DevicePickedPath?> pickMediaPath()` → `ImagePicker().pickMedia()` (photo **or** video, **no** `imageQuality` / `maxWidth`, so originals and HEIC/MOV stay as they are); size from `File(x.path).length()`.

The allowed extensions list comes from `meta.types` (`ext`), so the picker and the backend agree.

---

## 5. Feature folder

```
lib/features/qr_codes/
├── data/
│   ├── models/
│   │   ├── shared_file_model.dart        # SharedFileModel (+ fromJson), SharedFileKind enum
│   │   └── shared_files_meta_model.dart  # SharedFilesMetaModel, SharedFileTypeModel; mimeForExtension(ext)
│   ├── repositories/
│   │   └── shared_files_repository.dart
│   └── services/
│       └── qr_export_service.dart        # PNG bytes, PDF bytes, save to gallery
├── presentation/
│   ├── cubit/
│   │   ├── link_qr_cubit.dart + link_qr_state.dart
│   │   ├── shared_file_upload_cubit.dart + shared_file_upload_state.dart
│   │   ├── shared_files_list_cubit.dart + shared_files_list_state.dart
│   │   └── qr_export_cubit.dart + qr_export_state.dart
│   ├── screens/
│   │   ├── qr_codes_screen.dart          # 2 tabs: «رابط» / «ملف»
│   │   ├── shared_file_result_screen.dart
│   │   └── shared_files_screen.dart      # «ملفاتي المشتركة»
│   └── widgets/                          # one widget per file, all prefixed qr_ / shared_file_
```

### 5.1 Models
- `SharedFileModel`: `id, title?, fileName, mime, kind (SharedFileKind), byteSize, downloads, expiresAt (DateTime?), isExpired, shareUrl, qrPng (String?), createdAt`. Getter `displayName => title?.isNotEmpty == true ? title! : fileName`. Getter `qrPngBytes` decodes the `data:image/png;base64,` prefix (null if absent).
- `SharedFileKind.fromApi(String)` with a fallback (e.g. `other`) for unknown values; never crash on a new kind.
- `SharedFilesMetaModel`: `usedBytes, quotaBytes, maxFileBytes, expiryDays (List<int>), defaultExpiryDays, types (List<SharedFileTypeModel>)`; `double get usedRatio` clamped 0..1; `String? mimeForExtension(String ext)` (with the `.mov`/`.heic` fallbacks); `List<String> get extensions`.
- A pure helper `formatBytes(int bytes)` → «50 ميجابايت» / «2 جيجابايت» style via translation keys (`qr_unit_kb`, `qr_unit_mb`, `qr_unit_gb`). Put it in `lib/features/qr_codes/data/models/` or a `utils/` file in the feature, **with a unit test**.

### 5.2 `SharedFilesRepository`
Constructor takes optional `StorageClient` (like `DocumentsRepository({StorageClient? storage})`).
```dart
Future<Either<Failure, ({List<SharedFileModel> files, SharedFilesMetaModel meta})>> getFiles();
Future<Either<Failure, SharedFileModel>> getFile(int id);
Future<Either<Failure, SharedFileModel>> upload({
  required DevicePickedPath file,
  required String mime,
  String? title,
  int? expiresInDays,
  void Function(double progress)? onProgress,
  CancelToken? cancelToken,
}); // ticket → storage.uploadFile → POST /shared-files
Future<Either<Failure, SharedFileModel>> update(int id, {String? title, int? expiresInDays});
Future<Either<Failure, Unit>> delete(int id);
```

### 5.3 `QrExportService` (no state, plain class, injected into `QrExportCubit`)
- `Future<Uint8List> pngBytes({required String data, ui.Image? logo, double size = 1024})`:
  `QrPainter(data: data, version: QrVersions.auto, errorCorrectionLevel: logo == null ? QrErrorCorrectLevel.M : QrErrorCorrectLevel.H, embeddedImage: logo, embeddedImageStyle: QrEmbeddedImageStyle(size: Size(size * 0.22, size * 0.22)), gapless: true, eyeStyle/dataModuleStyle black on white)` → `toImageData(size, format: ui.ImageByteFormat.png)`. Paint a **white background with a quiet zone** (draw the QR onto a canvas with ~4 modules of white margin), otherwise phone cameras fail in dark mode.
- `Future<Uint8List> pdfBytes({required Uint8List qrPng, String? caption, required String link})`: one A4 page, QR centred (~8 cm), caption under it, the link as text under that. Arabic font + RTL.
- `Future<bool> saveToGallery(Uint8List png, String name)` via `gal`.
- Share PNG: write to a temp file (`path_provider` `getTemporaryDirectory()`) and `SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'image/png')], text: link))`.

---

## 6. Screens and cubits

### 6.1 Entry
- Add `Routes.qrCodes = '/qr-codes'`, `Routes.sharedFileResult = '/qr-codes/result'`, `Routes.sharedFiles = '/qr-codes/files'` in `routes.dart` with their builders and `BlocProvider`s (repositories created in the builder, like the online tests routes).
- Add a home chip «كيواركود» in `lib/features/home/presentation/widgets/home_features_section_widget.dart`, next to the others, icon `Icons.qr_code_scanner_rounded` (the online tests chip already uses `qr_code_2_outlined`; do not change it). **It opens `Routes.qrCodes` even for guests** (the link tab works without login). Pass `isLoggedIn` as the route argument. (This legacy file has known violations; only add your chip, do not refactor it.)

### 6.2 `QrCodesScreen` – tab «رابط» (works without login, no API)
`LinkQrCubit` state: `url`, `caption`, `logo (ui.Image?)`, `logoBytes`, `isValid`.
- URL field (`PrimaryTextField`, keyboard `url`). Valid = `Uri.tryParse` with scheme `http`/`https` and a host; if the teacher types `haderedu.com/x`, prepend `https://`. Show the error text only after the first edit.
- Caption field (optional, ≤ 60 chars).
- «إضافة شعار» → pick an image (`DeviceFilePicker.pick(DeviceFileSource.gallery)`), decode to `ui.Image`; «إزالة الشعار».
- Live preview: `QrImageView(data: url, errorCorrectionLevel: logo == null ? M : H, embeddedImage: MemoryImage(logoBytes), embeddedImageStyle: …, backgroundColor: Colors.white from ColorsManager)`, caption under it. Empty/invalid URL → a placeholder card, not a broken QR. Debounce the preview ~300 ms in the cubit.
- Actions (`QrExportCubit`): «حفظ في المعرض», «مشاركة الصورة», «مشاركة PDF», «طباعة». Disabled while invalid. Success/failure → `PrimarySnackBar`.

### 6.3 `QrCodesScreen` – tab «ملف» (logged in)
- Guest: show a card «سجّل الدخول لمشاركة الملفات» + button to `Routes.login`. No API calls.
- Logged in: `SharedFileUploadCubit`. On open it calls `getFiles()` once to get `meta` (limits, types, expiry options, used space).
  State: `status (idle | loadingMeta | ready | uploading | registering | done | failed)`, `meta`, `file (DevicePickedPath?)`, `mime`, `title`, `expiryDays`, `progress (0..1)`, `error`, `paymentRequired (PaymentRequiredFailure?)`, `result (SharedFileModel?)`.
  1. «اختيار ملف» → `PrimaryFileSourceSheet`-style choice: «من الملفات» (`pickFilePath(meta.extensions)`) or «صورة أو فيديو من المعرض» (`pickMediaPath()`).
  2. **Validate locally before any call:** `mime = meta.mimeForExtension(ext)`; null → error `qr_error_type`. `byteSize > meta.maxFileBytes` → error `qr_error_too_big` (show the limit with `formatBytes`). `byteSize > quota - used` → error `qr_error_quota`.
  3. Show the picked file card (icon by kind, name, size), a title field (≤ 120), and expiry chips from `meta.expiryDays` (`PrimaryChoiceChips`, default `defaultExpiryDays`; labels «7 أيام», «30 يومًا», «90 يومًا», «سنة»).
  4. «رفع ومشاركة» → `repository.upload(...)`. Progress bar with percent while uploading; «إلغاء» cancels the `CancelToken`. Lock the form during upload. Keep the screen awake is **not** required.
  5. Done → `Navigator.pushReplacementNamed(context, Routes.sharedFileResult, arguments: result)`.
  6. `PaymentRequiredFailure` → `UpgradePromptBottomSheet.show`. Any other failure → show `appTranslation().get(failure.message)` and keep the picked file so the teacher can retry.
- A link at the top: «ملفاتي المشتركة» → `Routes.sharedFiles`.

### 6.4 `SharedFileResultScreen` (argument: `SharedFileModel`)
- QR: `qrPngBytes` if present (`Image.memory`), else `QrImageView(data: shareUrl)`.
- Title, file name, size, «ينتهي في …» (date formatted in Arabic).
- `share_url` in a selectable row with «نسخ الرابط» (`Clipboard.setData` + snackbar).
- «مشاركة الرابط» (`share_plus`, text = displayName + newline + shareUrl).
- «حفظ رمز QR» → gallery. Use the API PNG if present, otherwise `QrExportService.pngBytes(data: shareUrl)`.
- «طباعة» → `QrExportService.pdfBytes(qrPng, caption: displayName, link: shareUrl)` → `Printing.layoutPdf`.
- Reuse the same action widgets as the link tab (one shared `qr_actions_row.dart` in the feature).

### 6.5 `SharedFilesScreen` «ملفاتي المشتركة»
`SharedFilesListCubit`: `load()`, `refresh()`, `extend(id, days)`, `delete(id)`, `openQr(id)` (calls `getFile` for `qr_png`).
- `ConditionalBuilder` for loading / error (`PrimaryErrorView` with retry) / empty (`NoDataWidget`) / list. Pull-to-refresh.
- Header: used-space bar `LinearProgressIndicator(value: meta.usedRatio)` + «استخدمت {used} من {quota}» (keys with placeholders, replace in the widget).
- Row (`shared_file_tile.dart`): icon by `kind` (pdf, image, word, excel, powerpoint, video, other), `displayName`, size, «{n} تحميل», expiry («ينتهي بعد X يوم» or a red «منتهي» badge when `isExpired`).
- Row actions (popup or trailing buttons):
  - «عرض الرمز» → load the file, then open `Routes.sharedFileResult` with it.
  - «تمديد» (always for expired, optional for active) → bottom sheet with `meta.expiryDays` chips → `PATCH {expires_in_days}` → replace the row with the response. `402` → upgrade sheet.
  - «حذف» → `PrimaryConfirmDialog` → `DELETE` → remove the row and reload `meta` (used space changes).
- Re-load the list when coming back from the result screen.

---

## 7. Translations
Add every key to **both** files, same key names. Minimum set (add more as needed, all prefixed `qr_`):
`qr_title`, `qr_tab_link`, `qr_tab_file`, `qr_url_label`, `qr_url_invalid`, `qr_caption_label`, `qr_add_logo`, `qr_remove_logo`, `qr_preview_empty`, `qr_save_gallery`, `qr_share_image`, `qr_share_pdf`, `qr_print`, `qr_saved`, `qr_save_failed`, `qr_login_needed`, `qr_pick_file`, `qr_from_files`, `qr_from_gallery`, `qr_file_title_label`, `qr_expiry_label`, `qr_days_7`, `qr_days_30`, `qr_days_90`, `qr_days_365`, `qr_upload_share`, `qr_uploading`, `qr_cancel`, `qr_upload_cancelled`, `qr_error_type`, `qr_error_too_big`, `qr_error_quota`, `qr_copy_link`, `qr_link_copied`, `qr_share_link`, `qr_expires_on`, `qr_my_files`, `qr_used_space`, `qr_downloads`, `qr_expired`, `qr_extend`, `qr_show_code`, `qr_delete`, `qr_delete_confirm`, `qr_files_empty`, `qr_unit_kb`, `qr_unit_mb`, `qr_unit_gb`.

---

## 8. Tests (mocktail, under `test/features/qr_codes/` + `test/core/services/`)
- `shared_file_model_test.dart`: `fromJson` with full JSON, with `title: null`, without `qr_png`, unknown `kind`; `qrPngBytes` decoding.
- `shared_files_meta_model_test.dart`: `mimeForExtension` (pdf, MOV upper-case, heic, unknown → null), `usedRatio` clamping.
- `format_bytes_test.dart`.
- `link_qr_cubit_test.dart`: valid/invalid URLs, auto `https://`, logo add/remove.
- `shared_file_upload_cubit_test.dart` (mock repository + picker): type refused, too big, over quota (no repository call in those three), progress emitted, success → `result`, `402` → `paymentRequired`, other failure keeps the file.
- `shared_files_list_cubit_test.dart`: load, extend replaces the row, delete removes it and reloads meta.

Run `flutter analyze` (zero new issues) and `flutter test` before you finish.

---

## 9. Order of work
1. `gal` + permissions, endpoints, models + their tests.
2. `StorageClient.uploadFile`, picker additions, `SharedFilesRepository`.
3. `QrExportService` + link tab (`LinkQrCubit`, `QrExportCubit`) — test on a device that it scans.
4. File tab + result screen.
5. «ملفاتي المشتركة».
6. Routes + home chip, translations check, tests, `flutter analyze`.

## 10. Done when
- [ ] A QR made from a link scans with another phone's camera, with and without a logo (logo ⇒ level H).
- [ ] The link tab works logged out; the file tab asks to log in.
- [ ] A 100 MB video uploads with a moving progress bar and **no** memory spike (the file is streamed from its path).
- [ ] Wrong type / too big / over quota are refused before any network call.
- [ ] Scanning the file QR opens `haderedu.com/f/{token}` in the browser and the button downloads the file (no screen for this in the app).
- [ ] Extending an expired file reopens its link; deleting updates the used-space bar.
- [ ] `402` shows the upgrade sheet; other errors show the API `message`.
- [ ] Share / save / print work on Android **and** iOS.
- [ ] Every string is in `ar.json` and `en.json`; `flutter analyze` clean; tests pass; `lib/features/online_tests/` unchanged.
