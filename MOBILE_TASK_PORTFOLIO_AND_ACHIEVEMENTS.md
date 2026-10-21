# Mobile app task: portfolio, achievement report, semester plan

The same three features as the website, in the Flutter app. The backend for the first two is done. The third uses an API that already exists.

**API reference:** `moeen-backend/docs/PORTFOLIO_AND_ACHIEVEMENTS_API.md`. Read it first. This file says what to build in the app. That one says exactly what each endpoint takes and returns.

**Order:** 1 → 2 → 3. Each can ship on its own.

Follow the existing structure: a `lib/features/<name>/` folder with `data/` and `presentation/` (cubit, screens, widgets). Endpoints go in `lib/core/network/remote/api_endpoints.dart`. Strings go in `assets/translations/ar.json` and `en.json`. Code comments in English.

---

## 1. Portfolio (ملف الإنجاز والشواهد)

New feature folder: `lib/features/portfolio/`.

### What it is
A teacher's job-performance portfolio. It's a list of evidence items, one per Ministry performance element. Each item holds photos, PDFs or links. The teacher fills it during the year, sees how complete it is, exports it as a PDF for their evaluation, and can share a public link.

### Screens
1. **Portfolios list** (from the home menu, «ملف الإنجاز»):
   - One card per portfolio from `GET /portfolios`: title, role label, a completion ring (`completion.percent`), and «ينقصه N بنود».
   - A «إنشاء ملف إنجاز» button opens a bottom sheet with a role picker (from `GET /portfolios/roles`) and an optional title, then calls `POST /portfolios`.
   - At 5 portfolios the API returns `422 portfolio_limit`. Show its `message`.
2. **Portfolio editor** (`GET /portfolios/{id}`):
   - **Header:**
     - title, editable;
     - completion ring and «أضف شواهد إلى N بنود»;
     - the missing items as chips, tapping one scrolls to it;
     - actions «PDF», «مشاركة» and «حذف الملف».
   - **«البيانات الأساسية»** (expandable):
     - **Role:** changing it calls `PATCH {role}`. Show «سيتم إضافة بنود الدور الجديد، ولن تُحذف بنودك الحالية».
     - **Fields:** name, specialty, stage, school, academic year, phone, email. They come prefilled.
     - **Signatures:** a list of `{title, name}`, up to 4.
     - **Save:** `PATCH {profile: {...changed}}`.
   - **«الشواهد»:** an expandable card per item, in `sort_order`:
     - an included checkbox (`PATCH {included}`), and a badge «بدون شواهد» or «N شواهد»;
     - expanded:
       - description, editable;
       - the title too, on the teacher's own items only (`item_key == null`);
       - a grid of thumbnails, with long-press to delete and drag to reorder (`PUT …/files/order` with all ids);
       - **«إضافة شاهد»** opens a sheet with three choices: «الكاميرا»، «الصور»، «ملف PDF»;
       - **«إضافة رابط»**, `https` only;
       - **«حذف البند»** on the teacher's own items only.
   - **«+ إضافة بند جديد»** at the bottom.
3. **Share sheet:**
   - **Off:** «إنشاء رابط مشاركة» calls `POST …/share`.
   - **On:**
     - show the link with copy;
     - a QR of it (add `qr_flutter`);
     - share it with `share_plus`;
     - «إيقاف المشاركة» calls `DELETE …/share`. Warn first: «سيتوقف الرابط الحالي نهائيًا».
   - Note under it: «يظهر في الرابط البنود المضمنة فقط، بدون رقم الجوال والبريد».

### Uploading a file
1. **Pick:**
   - Camera and photos: add `image_picker`. Use `imageQuality: 85` and `maxWidth: 2000`, so phone photos come out well under 10 MB.
   - PDF: `file_picker` (already installed), restricted to `pdf`.
   - **iOS HEIC:** `image_picker` with `imageQuality` set returns JPEG. Check the MIME type anyway. Only `image/jpeg`, `image/png`, `image/webp` and `application/pdf` are allowed, up to 10 MB.
2. **Get the URL:** `POST /portfolios/{id}/items/{itemId}/uploads {mime, byte_size}` returns `{upload_url, headers, storage_path}`.
3. **Upload:** `PUT upload_url` with the raw bytes as the body and exactly `headers`.
   - **Use a separate plain `Dio()` for this call,** not the app's API client. The API client adds the `Authorization` header and our interceptors; R2 rejects the request with them.
   - Use `onSendProgress` for a progress bar.
4. **Register:** `POST …/items/{itemId}/files {kind: "file", storage_path, original_name}`. Add the returned file to the grid.

**Errors:** `portfolio_files_limit` (10 per item), `upload_not_found` (retry from step 2), and `file_too_large`. Show the API's `message`.

**File URLs expire after 60 minutes.** Don't cache them across sessions. Refetch the portfolio when the screen reopens, before building the PDF, or when an image fails to load. Show cached thumbnails from memory only.

### PDF export
Build it in the app with the `pdf` and `printing` packages, already used by the privacy policy screen with the Tajawal fonts. Open it with `Printing.layoutPdf` or share it.
- **Cover:** title «ملف الإنجاز والشواهد الوظيفية», name, role, specialty, stage, school, year, and a QR of the share link if it's public.
- **Contents:** the included items.
- **One section per included item:** title, description, images two per row, and PDFs and links as their title plus a small QR.
- **Signatures page:** from `profile.signatures`.
- **Images:** download them before building, from the signed `url`s. They expire after 60 minutes, so refetch the portfolio first.

The public link opens on the website (`https://haderedu.com/portfolio/<token>`). The app doesn't need a public screen.

---

## 2. Achievement report (الإنجاز اليومي والأسبوعي والشهري)

Add it to the existing `lib/features/reports/` as a new screen, «تقرير الإنجاز», reachable from the reports entry point.

- **Period:** segmented control for يومي / أسبوعي / شهري (`period=day|week|month`), with arrows for the previous and next period. Move `date` by a day, 7 days or a month, sent as `YYYY-MM-DD`.
- **Range:** «من 18 أكتوبر إلى 24 أكتوبر 2026», from `from` and `to`.
- **Totals cards:** دروس محضّرة، اختبارات، عروض تقديمية، أوراق عمل، تقارير تعليمية.
- **Chart:** a simple bar chart of `by_day` (lessons prepared per day). Plain widgets are enough; no chart package needed.
- **Lessons list:** from `lessons`, with title and date and time. When empty: «لم يتم تحضير دروس في هذه الفترة».
- **«مشاركة PDF»:** with the `pdf` package. Include the teacher's name, the period, totals, the lessons table, and signature lines for the teacher and «مدير المدرسة».

---

## 3. Semester plan (الخطة الفصلية): no backend changes

In `lib/features/curriculum/presentation/screens/curriculum_distribution_screen.dart`, add «تحميل الخطة الفصلية».

- **Data:** the plan already loaded, `GET /curriculum/plans/{plan}`: weeks with numbers, dates and lessons, holidays and exam weeks.
  Each entry in `weeks` has:
  - `type`: `teaching`, `holiday` or `exam`;
  - `week_number`, which is null for breaks, and `title`, which is set for breaks and exam weeks;
  - `starts_on` / `ends_on`, plus `starts_on_hijri` / `ends_on_hijri`;
  - `notes`, such as National Day falling inside a normal week;
  - `items[].title` (the lesson) and `items[].unit`.
- **Build:** a PDF with the `pdf` package, A4 landscape, right-to-left, Tajawal fonts.
- **Header:** «الخطة الفصلية», subject, grade, semester, year 1448, plus the teacher's name and school.
- **Table:** الأسبوع | التاريخ | الدروس | ملاحظات. Holiday and exam weeks show as one shaded row («إجازة اليوم الوطني», «اختبارات»).
- **Footer:** signature lines for «معلم المادة» and «مدير المدرسة».
- **Delivery:** open with `Printing.layoutPdf`, or share as `الخطة الفصلية - <subject>.pdf`.

The website exports Word for this; PDF is the right choice in the app.

---

## Done when
- [ ] A portfolio can be created for each role and shows the right standard items.
- [ ] Camera, gallery and PDF uploads work on Android and iOS, with progress. Oversized or unsupported files get a clear message.
- [ ] Completion updates after each upload or delete.
- [ ] The PDF has the cover, contents, items with images and signatures, and opens in the share sheet.
- [ ] The share link is copied, shown as a QR and shared. After «إيقاف المشاركة» it no longer opens on the website.
- [ ] The achievement report switches periods and moves through them.
- [ ] The semester plan PDF lists every week of the semester correctly.
