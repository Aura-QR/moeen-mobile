# Curriculum Distribution & School Textbooks

**Feature:** توزيع المناهج والكتب الدراسية
**Status:** shipped
**Scope:** backend (`moeen-backend`) + web frontend (`moeen_front`)

This document covers the whole feature: where the data came from, how it is
stored, the decisions behind the schema, and the traps that will bite you if you
change it. Read the **Gotchas** section before touching the matching or the
calendar code.

---

## 1. What the feature is

The lesson catalogue (`stages → grades → subjects → units → chapters → lessons`)
knows **what** is taught and in what order. It has no idea **when**. This feature
adds the missing time dimension:

> "Lesson X is taught in week N of semester S" — plus the school breaks and exam
> weeks that sit between those teaching weeks, and the student textbook PDFs for
> each subject.

`/curriculum` on the web app is a **public catalogue**. Any visitor can browse any
subject in any stage. Only two things need an account: the personalised export
(school/teacher/manager names → print to PDF) and the teacher-specific progress
and bulk-prepare endpoints.

---

## 2. Where the data came from

The dataset was scraped once from `tahdiri.com`, the same source the existing
lesson catalogue came from. **Nothing calls tahdiri at request time** and nothing
should — see [Gotcha 6](#6-never-proxy-to-tahdiri-at-request-time).

### 2.1 The API and its encoding

Endpoints return JSON whose body is **scrambled base64**. To decode, apply in
order:

```
chunkReverse(7) → chunkReverse(2) → chunkReverse(5) → reverse()
→ chunkReverse(4) → chunkReverse(9) → chunkReverse(8)
→ chunkReverse(7) → chunkReverse(6) → chunkReverse(5)
→ base64-decode as UTF-8
```

`chunkReverse(s, n)` splits the string into `n`-character chunks and reverses
each chunk. The site's own JS calls this `b64DecodeUnicode`.

| Endpoint | Returns |
|---|---|
| `q.tahdiri.com/tt/get.php?stage_id=1\|2\|3` | grades, or tracks for secondary |
| `q.tahdiri.com/tt/get.php?educational_level_id=5\|6` | continuing education / special education |
| `q.tahdiri.com/tt/get.php?track_id=N` | grades under a secondary track |
| `q.tahdiri.com/tt/get.php?grade_id=N` | semesters (`term_id`) |
| `q.tahdiri.com/tt/get.php?term_id=N` | subjects **+ student book PDFs** |
| `k.tahdiri.com/t/get.php?term_id=N&term=first\|second` | subjects for the distribution |
| `k.tahdiri.com/t/get.php?p_subj2=S&ex_sem_id=T&a=p` | **array of 17 HTML strings, index = week** |

Walk the tree using each node's `code_type`: `TRK → track_id`, `STG → stage_id`,
`K → grade_id`, `SM → term_id`.

### 2.2 The scraper

`scraper/tahdiri/scrape_tahdiri.py` — pure Python, no browser, caches every
response to `tahdiri_data/cache/`, safe to re-run.

```bash
python3 scraper/tahdiri/scrape_tahdiri.py
```

Produces (committed to the repo, needed by the import commands):

| File | Contents |
|---|---|
| `scraper/tahdiri/distributions.json` | 913 rows (subject × semester), **704 with actual content**, 19,580 lesson entries |
| `scraper/tahdiri/books.json` | 349 subject rows, **350 PDF links** |
| `scraper/tahdiri/terms.json` | 35 semesters with their full tree path |
| `scraper/tahdiri/books_sizes.json` | byte size per PDF (measured with Range requests) |

`scraper/tahdiri/match_seed.py` is a diagnostic: it reports how many
distribution entries can be matched onto `seed.sql` without touching a database.

### 2.3 The textbook PDFs

**~32 GB across 346 files**, average 92 MB, largest 428 MB. They are Ministry of
Education textbooks; tahdiri only mirrors them.

They live in **Cloudflare R2**, not on the app server. This is deliberate: a
teacher downloading a 92 MB PDF must never touch the box running the API and
Postgres. Uploads stream from source to R2 without ever hitting local disk:

```bash
export R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... R2_ENDPOINT=... R2_BUCKET=moeen-books
./scraper/tahdiri/upload_books_to_r2.sh
```

Safe to re-run — files already in the bucket are skipped, so an interrupted
transfer resumes. **Run it on the server, not a laptop:** the transfer is
bandwidth-bound; a home uplink takes ~26 hours, a datacentre one takes about one.

---

## 3. Schema

Three migrations, all dated `2026_08_21`.

```
curriculum_plans              one distribution = subject + academic year + semester
  └─ curriculum_plan_weeks         week 1..N
       └─ curriculum_plan_items    the lessons inside that week

curriculum_books              student textbooks, attached to a SUBJECT

teacher_plan_entries          a teacher's own copy: lesson + period + date
```

### 3.1 `curriculum_plans`

Keyed for re-import on `(source, source_subject_id, source_term_id, semester)`,
so running the importer again updates in place instead of duplicating.
`subject_id` is nullable — a few source rows describe subjects we do not carry.

### 3.2 `curriculum_plan_items`

`lesson_id` is **nullable on purpose**. Roughly one entry in three has no
counterpart row in `lessons`:

- English distributions list skills (`Grammar`, `Writing`, `Reading`) rather than
  lesson titles — these can never match anything.
- Special-education curricula are not in our catalogue at all.
- Some entries are pacing markers (`مراجعة`, `اختبار`).

Every item therefore keeps `raw_text`, `raw_unit_title` and `raw_lesson_title`
regardless of matching, plus `match_method` and `match_confidence` so a bad link
can be found later. **The UI must render the raw title and use `can_prepare`, not
the presence of a title, to decide what is actionable.**

### 3.3 `curriculum_books`

A book belongs to a **subject**, not a lesson — one PDF covers a whole subject for
a grade and semester. `storage_disk` + `storage_path` mean the library can move
between R2 / S3 / local without touching rows.

### 3.4 `teacher_plan_entries`

The join between three things that move independently: the shared distribution,
the teacher's timetable, and what they actually prepared.

Design points that are load-bearing:

1. `teacher_id` is on every row — the tenant key, no join needed to scope.
2. `timetable_id` is **nullable with `nullOnDelete`**. A schedule re-scrape can
   truncate and rebuild `timetables` without destroying a teacher's plan.
   **Never make this column required.**
3. `day_of_week` / `period_number` / `scheduled_date` / `classroom_label` are
   denormalised so the plan works *before* any timetable exists and survives a
   change of timetable source.
4. `curriculum_plan_item_id` and `lesson_id` are independent and both nullable:
   an entry can come from the distribution, be picked manually, or be free text.

---

## 4. Importing

Run in this order, after `php artisan migrate --force`:

```bash
php artisan curriculum:import-distribution --dry-run   # report only, writes nothing
php artisan curriculum:import-distribution
php artisan curriculum:import-books
```

Both are idempotent.

### Current results

```
curriculum_plans          704
curriculum_plan_weeks  11,968
curriculum_plan_items  19,580   → 13,382 linked to a lesson (68.3%)
curriculum_books          346   → 343 linked to a subject   (99.1%)
```

The 31.7% unlinked breaks down as:

| Cause | Entries | Fixable? |
|---|---:|---|
| Special education (curriculum absent from our catalogue) | 2,579 | only by scraping that curriculum |
| English (skills, not lessons) | 2,115 | no — nothing to link to |
| Genuine misses | ~1,504 | yes, with better matching |

Of the entries that *could* match, ~90% do.

---

## 5. The academic timeline

This is the part most likely to be misunderstood, so read it before changing
`config/academic.php`.

The distribution source only ever returns **taught** weeks — 17 of them. It has
no idea that the autumn break sits between week 13 and week 14. The official
printed sheet has **21 cards**: 19 numbered weeks plus two break cards.

`AcademicTimelineService::build()` walks the calendar week by week:

- a break that overlaps the current week emits a holiday card **and pushes every
  teaching week after it forward**;
- when taught content runs out, the configured `closing_weeks` (oral/practical
  exams, final exams) continue the numbering;
- an `inline` holiday (National Day) does **not** consume a week — it is attached
  as a note inside the week that contains it.

Configuration lives in `config/academic.php` under each semester:

```php
'holidays' => [
    ['name' => 'إجازة اليوم الوطني', 'starts_at' => '2026-09-23', 'ends_at' => '2026-09-23', 'inline' => true],
    ['name' => 'إجازة الخريف',       'starts_at' => '2026-11-22', 'ends_at' => '2026-11-26'],
    ['name' => 'إجازة منتصف العام',  'starts_at' => '2027-01-08', 'ends_at' => '2027-01-16'],
],
'closing_weeks' => [
    ['name' => 'اختبارات شفهية وعملية', 'kind' => 'exam'],
    ['name' => 'اختبارات نهائية',       'kind' => 'exam'],
],
```

Verified output for semester 1 matches the official sheet exactly:

```
weeks 1-13 → إجازة الخريف → weeks 14-17 → week 18 (oral/practical)
→ week 19 (finals) → إجازة منتصف العام
```

### Regions

Schools in Makkah / Madinah / Jeddah / Taif start a week later
(`starts_at_excepted_regions`). Pass `?region=west` to
`GET /curriculum/plans/{plan}` and the **whole sheet** shifts, not just the first
card.

### Hijri dates

`AcademicTimelineService::toHijri()` uses `ext-intl` with the
`islamic-umalqura` calendar — the official Saudi calendar, exact against the
printed sheets. Without `ext-intl` it falls back to the arithmetic (Kuwaiti)
algorithm, which was measured against Umm al-Qura over the school year:

```
exact match: 77 / 306 days (25%)   |   maximum deviation: 2 days
```

**Install `php-intl` in production.** The fallback exists so the field is not
blank, but a two-day error on a sheet a teacher submits is a real problem.

```bash
apt install php8.3-intl && systemctl restart php8.3-fpm
# or in the Dockerfile:  docker-php-ext-install intl
```

---

## 6. API

### Public — the catalogue

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/curriculum/plans?subject_id=&semester=` | plans available for a subject |
| `GET` | `/api/curriculum/plans/{plan}?region=west` | the full merged timeline |
| `GET` | `/api/curriculum/plans/{plan}/weeks/current?date=` | shortcut for "this week" |
| `GET` | `/api/curriculum/books?subject_id=\|grade_id=` | books grouped by subject |
| `GET` | `/api/curriculum/books/{book}/download` | fresh signed R2 URL, valid 1 hour |

### Authenticated — teacher-specific

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/curriculum/progress?subject_id=&semester=` | ahead / behind indicator |
| `POST` | `/api/curriculum/plans/{plan}/weeks/{week}/prepare` | resolves lesson ids for bulk prepare |

### Week shape

Every slot — teaching week, break, exam week — comes back in one shape so the
client does not need to know which came from where:

```jsonc
{
  "type": "teaching",            // teaching | holiday | exam
  "week_number": 14,             // null for a break
  "title": null,                 // set for breaks, exam weeks, and the review week
  "starts_on": "2026-11-29",
  "ends_on": "2026-12-03",
  "starts_on_hijri": "19-06-1448",
  "ends_on_hijri": "23-06-1448",
  "is_current": false,
  "notes": [],                   // e.g. National Day inside a normal week
  "items": [
    {
      "id": 812,
      "title": "الجمع إلى الصفر",
      "unit": "الجمع",
      "kind": "lesson",          // lesson | review | exam | intro | activity
      "lesson_id": 1487,         // null when unmatched
      "can_prepare": true
    }
  ]
}
```

Book downloads are **not** redirects — they return a JSON `{ url, expires_at,
file_name, size_mb }` so native mobile clients can hand the URL to a downloader.
Fetch it at click time; the signed URL expires in an hour.

---

## 7. Frontend

Page: `/curriculum` (`src/app/curriculum/page.tsx`). Public — listed in
`AuthGuard`'s `PUBLIC_EXACT_ROUTES`, not in `middleware.ts`.

| Component | Role |
|---|---|
| `SubjectPicker` | stage → grade → subject |
| `CurriculumBooksCard` | textbooks, above the grid |
| `CurriculumWeekTable` | the 21-card grid, 2 cols mobile → 6 cols on 2xl |
| `CurriculumExportPanel` | names + region + print, **gated behind login** |
| `CurriculumSheetHeader` | official sheet header/footer, print only |
| `src/lib/api/curriculum.ts` | typed API layer |

### Conventions to follow

The codebase uses `useState` + `useEffect` + `apiRequest`. `@tanstack/react-query`
and `sonner` are in `package.json` but **used nowhere** — do not introduce them
here without a wider decision.

### PDF export

No PDF library. `window.print()` plus a print stylesheet in `globals.css`
(A4 landscape, `break-inside: avoid` on cards, `.no-print` on everything that is
not the sheet). The browser produces searchable-text PDFs at higher quality than
a canvas screenshot, and adds zero dependencies.

---

## 8. Gotchas

### 1. Grade names are not unique
After the track migration, `السنة الثانية` exists **once per secondary track**, and
`الصف الأول الابتدائي` exists in both general and special education. Matching on
`(grade, subject)` silently binds a distribution to whichever subject sorts
first. Always key on `(track, grade, subject)`, falling back to the track-less key
only when it resolves to exactly one subject. See
`ImportCurriculumDistribution::buildSubjectIndex()`.

### 2. Arabic normalisation is easy to get catastrophically wrong
The diacritics character class must be written with explicit escapes:

```php
'[\x{064B}-\x{065F}\x{0670}\x{06D6}-\x{06ED}\x{0640}]'
```

A literal range like `[ؐ-ًؚ-ٰٟۖ-ۭـ]` looks right but spans `U+061A–U+0670`, which
swallows the **entire Arabic alphabet**. Every title then normalises to an empty
string, everything "matches", and the reported match rate is meaningless. This
happened during development and inflated the measured rate to 76.8% before it was
caught. See `ArabicTitleMatcher`.

### 3. Naive week arithmetic drifts
`semester_start + (n-1) weeks` is wrong as soon as a holiday lands: after the
autumn break every date is a week out, and the progress indicator tells a teacher
they are behind when they are not. Use `AcademicTimelineService`.

### 4. Breaks must not jump ahead of exam weeks
End-of-term exams run before the holiday that follows them. Without an explicit
guard, the western region — which starts a week later — pushes final exams into
the mid-year break and the sheet renders the vacation card ahead of week 19.

### 5. Tailwind gradients survive `dark:bg-*`
`bg-gradient-to-l` sets `background-image`; `dark:bg-[#0B2E26]` sets
`background-color`. The gradient paints **on top**, so in dark mode a light
gradient sits behind light text and the text disappears. Add `dark:bg-none`.
This affected five places across the site.

### 6. Never proxy to tahdiri at request time
Import once into our database and serve from there. Live calls leave your server
IP in their logs and make the product fail the moment they change their API —
which they obfuscate deliberately.

### 7. Books attach to subjects, not lessons
One PDF covers a whole subject. Do not try to link them to `lessons`.

### 8. Pin the PHP platform in Composer
`composer.json` sets `config.platform.php = 8.3.33` to match production.
Installing a package on a machine with a newer PHP will otherwise resolve
dependencies the server cannot run — this broke a deploy once
(`symfony/filesystem` requiring PHP ≥ 8.4.1). Use `composer install` on the
server, never `composer update`.

---

## 9. Known gaps / next steps

| Item | Notes |
|---|---|
| **Second semester holidays** | `config/academic.php` has empty `holidays` / `closing_weeks` for `second`. Left empty deliberately — a wrong date shifts every week after it. Fill from the official calendar. |
| **Western region end-of-term** | Start date shifts correctly, but exam and vacation dates are the general-region ones. Needs official west-region dates; the config supports it as a data change. |
| **`ext-intl` in production** | Until installed, Hijri dates use the approximate fallback. |
| **Teacher guides** | The source reports 436 teacher guides; no endpoint was found for them. Only student books are imported. |
| **Special education curriculum** | Not in our catalogue, so 2,579 distribution entries cannot link. |
| **`teacher_plan_entries` is unused so far** | Schema and `TeacherPlanBuilder` exist and are tested, waiting on the in-house timetable scraper. `attachToPeriods()` accepts anything exposing `(subject_id, day_of_week, period_number, week_date)` — it is not tied to Madrasati. |
| **Prepare-week button** | Removed from `/curriculum` (it is a public catalogue; preparation happens elsewhere). The endpoint and `resolveWeekForPreparation()` still exist if you want it on the teacher dashboard. |

---

## 10. Runbook

```bash
# server
git pull
composer install --no-dev --optimize-autoloader     # NOT composer update
php artisan migrate --force
php artisan config:clear && php artisan route:clear

php artisan curriculum:import-distribution --dry-run
php artisan curriculum:import-distribution
php artisan curriculum:import-books
```

Required `.env` keys (documented in `.env.example`):

```
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_DEFAULT_REGION=auto
R2_BUCKET=moeen-books
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_USE_PATH_STYLE_ENDPOINT=true
```

The R2 token only needs write access for the one-time upload. Give the
application a **read-only** token.
