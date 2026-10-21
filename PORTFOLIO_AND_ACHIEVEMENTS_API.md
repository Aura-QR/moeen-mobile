# Teacher portfolio and achievement report: API

Two features for teachers, available on the website and the mobile app:

1. **Portfolio (ملف الإنجاز والشواهد):** the teacher builds their job-performance portfolio. It is a list of evidence items (one per Ministry performance element), each holding photos, PDFs or links. It shows a completion percentage, prints as a PDF, and can be shared through a public link.
2. **Achievement report (الإنجاز اليومي والأسبوعي والشهري):** what the teacher did in a day, a school week or a month: lessons prepared, exams, presentations, worksheets and reports.

All endpoints are under `/api`, use the normal `Authorization: Bearer <token>` header, and return errors in the usual shape `{ message, code, status }`. The only exception is the public portfolio endpoint, which needs no token.

---

## 1. Portfolio

### Concepts
- **Portfolio:** title, `role`, `profile` (the details printed on the cover), and items. A teacher can have up to 5.
- **Role:** decides the standard items a new portfolio starts with.

  | `role` | Label | Standard items |
  |---|---|---|
  | `teacher` | معلم | 11 |
  | `kindergarten_teacher` | معلمة روضة | 11 |
  | `activity_leader` | معلم مسند له نشاط طلابي | 15 (11 + 4 student-activity) |
  | `health_guide` | معلم مسند له توجيه صحي | 11 |
  | `lab_preparer`, `student_counselor`, `vice_principal`, `principal` | … | 0 for now; the teacher adds items |

  Get the live list from `GET /portfolios/roles`; don't hard-code it.
- **Item:** one evidence element. Standard items have an `item_key` and can't be deleted, only excluded (`included: false`). The teacher's own items have `item_key: null` and can be deleted.
- **File:** a piece of evidence inside an item.
  - `kind: "file"`: an uploaded image (JPEG, PNG, WebP) or PDF, up to 10 MB.
  - `kind: "link"`: an `https` URL. Use this for videos (YouTube, Drive). Video files are not uploaded.
- **Completion:** an item is complete when it is included and has at least one file.
  - `percent = floor(complete / included × 100)`.
  - `missing` lists the titles of included items with no evidence.

### Limits
| Limit | Value |
|---|---|
| Portfolios per teacher | 5 |
| Items per portfolio | 40 |
| Files per item | 10 |
| File size | 10 MB |
| File types | `image/jpeg`, `image/png`, `image/webp`, `application/pdf` |

`GET /portfolios/roles` also returns these as `limits` and `allowed_mimes`.

### Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/portfolios/roles` | Roles, their standard item titles, limits, allowed types |
| GET | `/portfolios` | The teacher's portfolios (summaries) |
| POST | `/portfolios` | Create |
| GET | `/portfolios/{id}` | Full portfolio with items and files |
| PATCH | `/portfolios/{id}` | Update title, role or profile |
| DELETE | `/portfolios/{id}` | Delete, with its stored files |
| POST | `/portfolios/{id}/share` | Turn the public link on |
| DELETE | `/portfolios/{id}/share` | Turn it off (the old link stops working for good) |
| POST | `/portfolios/{id}/items` | Add the teacher's own item |
| PATCH | `/portfolios/{id}/items/{itemId}` | Edit title, description, `included`, `sort_order` |
| DELETE | `/portfolios/{id}/items/{itemId}` | Delete the teacher's own item (422 `standard_item` for standard ones) |
| POST | `/portfolios/{id}/items/{itemId}/uploads` | Step 1 of an upload: get a signed URL |
| POST | `/portfolios/{id}/items/{itemId}/files` | Step 2: register the uploaded file, or add a link |
| PUT | `/portfolios/{id}/items/{itemId}/files/order` | Reorder files |
| DELETE | `/portfolios/{id}/items/{itemId}/files/{fileId}` | Delete a file |
| GET | `/public/portfolios/{token}` | **No auth.** The shared view |

A portfolio that isn't the caller's returns **404**.

#### Create
```http
POST /api/portfolios
{ "role": "teacher", "title": "ملف الإنجاز 1448", "profile": { "specialty": "رياضيات", "stage": "ابتدائي" } }
```
- `title` and `profile` are optional.
- The profile is prefilled from the account: name, phone, email, the primary school name, and academic year `1448`. Two signatures are added: the role and the teacher's name, and «مدير المدرسة» with the name empty.
- Fields you send override the prefill.

Response `201`, the full portfolio:
```json
{
  "data": {
    "id": 7,
    "title": "ملف الإنجاز 1448",
    "role": "teacher",
    "role_label": "معلم",
    "is_public": false,
    "completion": { "included": 11, "complete": 0, "percent": 0, "missing": ["أداء الواجبات الوظيفية", "…"] },
    "updated_at": "2026-10-21T08:00:00+00:00",
    "profile": {
      "name": "…", "specialty": "رياضيات", "stage": "ابتدائي", "school_name": "…",
      "academic_year": "1448", "phone": "…", "email": "…",
      "signatures": [ { "title": "معلم", "name": "…" }, { "title": "مدير المدرسة", "name": null } ]
    },
    "share_url": null,
    "items": [
      {
        "id": 31, "item_key": "duties", "title": "أداء الواجبات الوظيفية", "description": null,
        "included": true, "sort_order": 1,
        "files": []
      }
    ]
  }
}
```
Errors: `422 portfolio_limit` when the teacher already has 5.

`GET /portfolios` returns summaries: the same fields without `profile`, `share_url` and `items`.

#### Update
```http
PATCH /api/portfolios/7
{ "title": "…", "role": "activity_leader", "profile": { "specialty": "علوم", "signatures": [ … ] } }
```
- **`profile`** is merged: send only the fields you change. Unknown profile fields are dropped.
- **Changing `role`** adds the new role's standard items. Existing items and their evidence stay.

#### Uploading a file: two steps
Files go straight from the device to storage (Cloudflare R2). They never pass through our server.

**Step 1: get a signed URL**
```http
POST /api/portfolios/7/items/31/uploads
{ "mime": "image/png", "byte_size": 482113 }
```
```json
{
  "data": {
    "upload_url": "https://<account>.r2.cloudflarestorage.com/moeen-books/portfolios/12/7/2f1c….png?X-Amz-…",
    "headers": { "Content-Type": "image/png" },
    "storage_path": "portfolios/12/7/2f1c….png",
    "expires_at": "2026-10-21T08:10:00+00:00"
  }
}
```
Errors: `422` for an unsupported type or size over 10 MB (validation), and `422 portfolio_files_limit` when the item already has 10 files.

**Upload:** `PUT` the raw file bytes to `upload_url`, with exactly the `headers` returned. No auth header, no JSON, no multipart. The URL works for 10 minutes.

**Step 2: register it**
```http
POST /api/portfolios/7/items/31/files
{ "kind": "file", "storage_path": "portfolios/12/7/2f1c….png", "original_name": "خطة الأسبوع.png", "title": "خطة الأسبوع الثالث" }
```
Response `201`:
```json
{ "data": { "id": 90, "kind": "file", "title": "خطة الأسبوع الثالث", "mime": "image/png", "byte_size": 482113, "original_name": "خطة الأسبوع.png", "url": "https://…signed…", "sort_order": 1 } }
```
Errors:
- `422 upload_not_found`: the PUT didn't happen, or the path isn't one this portfolio was given.
- `422 upload_already_registered`: that path is already registered.
- `422 file_too_large`: the stored file is over the limit. It is deleted.

**Adding a link instead**
```http
POST /api/portfolios/7/items/31/files
{ "kind": "link", "url": "https://youtu.be/…", "title": "حصة تطبيقية" }
```
Only `https` URLs are accepted.

**About `url` on files:** for stored files it's a signed link that **expires after 60 minutes**. Don't cache it. Reload the portfolio (`GET /portfolios/{id}`) to get fresh links. For links it's the URL as given.

#### Reorder files
```http
PUT /api/portfolios/7/items/31/files/order
{ "ids": [92, 90, 91] }
```
Send every file id of that item, in the new order. Anything else returns `422 order_mismatch`.

#### Items
- `POST /portfolios/7/items` with `{ "title": "دورات تدريبية", "description": "…" }` adds the teacher's own item. It returns `422 portfolio_items_limit` at 40.
- `PATCH /portfolios/7/items/31` with any of `title`, `description`, `included`, `sort_order`.
- `DELETE /portfolios/7/items/40` deletes it, with its files. Standard items return `422 standard_item`; exclude them with `included: false` instead.

#### Sharing
- `POST /portfolios/7/share` returns `{ "data": { "share_url": "https://haderedu.com/portfolio/<40-char token>", "is_public": true } }`. Calling it again keeps the same link.
- `DELETE /portfolios/7/share` turns the link off **and retires the token**. Sharing again makes a new link.
- `GET /public/portfolios/{token}` needs no auth and is rate-limited to 60 per minute. It returns `title`, `role_label`, `profile` **without `phone` and `email`**, and only included items with their files. A disabled or unknown token returns `404 portfolio_not_found`.

---

## 2. Achievement report

```http
GET /api/reports/achievements?period=week&date=2026-10-21
```
| Param | Values | Default |
|---|---|---|
| `period` | `day`, `week`, `month` | `week` |
| `date` | `YYYY-MM-DD`, any day inside the period | today |

- Windows are in **Saudi time**.
- A week runs **Sunday to Saturday**.
- A month is the Gregorian calendar month.

Response:
```json
{
  "data": {
    "period": "week",
    "from": "2026-10-18",
    "to": "2026-10-24",
    "totals": { "lessons_prepared": 12, "exams": 2, "educational_reports": 1, "presentations": 3, "worksheets": 2 },
    "by_day": [ { "date": "2026-10-18", "lessons_prepared": 3 }, "… one entry per day …" ],
    "lessons": [
      { "id": 501, "lesson_id": 88, "title": "جمل الطرح", "classroom_id": "…", "completed_at": "2026-10-18T09:12:00+03:00" }
    ]
  }
}
```
**What each total counts:**
- `lessons_prepared`: preparations that finished successfully.
- `exams`: exams created.
- `educational_reports`: AI educational reports.
- `presentations` and `worksheets`: generations recorded for usage limits.

`lessons` is capped at 300 entries; `totals.lessons_prepared` is always the full count. An invalid `period` or `date` returns 422.

---

## 3. Deploying (backend owner)

1. **Fix the R2 settings first.** Portfolio files use the same `r2` disk as the textbooks. In production, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` and `R2_ENDPOINT` hold `CHANGE_ME` placeholders that override the real `AWS_*` values. Delete those three lines, or set them to the real values. Until then, uploads and file links point at a host that doesn't exist.
2. **The R2 key needs write access.** Signed upload URLs are signed with the app's key, so it needs **Object Read & Write** on the bucket. Files go under `portfolios/` in the same bucket (`moeen-books`). To use a separate bucket, add a disk in `config/filesystems.php` and set `PORTFOLIO_DISK`.
3. **Allow uploads from the website (CORS).** In Cloudflare: R2 → the bucket → Settings → CORS policy:
   ```json
   [
     {
       "AllowedOrigins": ["https://haderedu.com"],
       "AllowedMethods": ["PUT", "GET"],
       "AllowedHeaders": ["Content-Type"],
       "MaxAgeSeconds": 3600
     }
   ]
   ```
   The mobile app doesn't need CORS.
4. **Run the migration:** `php artisan migrate --force` (`2026_10_21_000001_create_teacher_portfolios_tables`).
5. **Optional env:**
   - `PORTFOLIO_SHARE_BASE_URL`: default `https://haderedu.com/portfolio`, or `FRONTEND_URL` + `/portfolio`.
   - `PORTFOLIO_ACADEMIC_YEAR`: default `1448`.

**Privacy:** portfolio files are teacher uploads stored in Cloudflare R2, and a teacher can make them public with a link. The privacy policy should mention user-uploaded files and the share link before this launches.
