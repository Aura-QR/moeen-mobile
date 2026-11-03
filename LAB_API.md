# API: L8 «معمل حضر الافتراضي» (Virtual Lab)

Interactive curriculum-linked science experiments where teachers and students adjust sliders (`variables`) and observe live formulas, charts, and animated SVG scenes (`readings`).

- **No runtime AI** and **no usage quotas**: experiments run client-side from structured formulas validated on the server (`App\Domain\Lab\Formula`).
- **Public showcase**: opening, browsing, and running experiments requires **no login** and **no active plan**.
- **Teacher & Admin endpoints** live under `/api` with a Sanctum Bearer token.

| Who | Method | Path | Throttle | What |
|---|---|---|---|---|
| public | GET | `/api/public/lab/experiments` | `120/min` | Paginated published experiments (24/page) with search & curriculum filters |
| public | GET | `/api/public/lab/experiments/{key}` | `120/min` | Full experiment definition + up to 10 linked lessons (`404` when hidden) |
| public | POST | `/api/public/lab/experiments/{key}/play` | `30/min` per IP | Increment `plays` counter (`204 No Content`) |
| public | GET | `/api/public/lab/filters` | `120/min` | Curriculum filter tree with counts, subject group chips, and stats totals (cached 10 min) |
| public | GET | `/api/public/lab/home` | `120/min` | `{ popular: 8, featured: 8, community: 8 }` card lists |
| teacher | GET | `/api/lessons/{lesson}/experiments` | — | Ordered published experiments linked to a lesson |
| teacher | POST | `/api/lab/experiments/{key}/reports` | `5/min` | Report a mistake (`≤ 500` chars); notifies admins by email |
| teacher | POST | `/api/lab/experiments` | `10/min` + `plan.active` | «أنشئ تجربتك» — create a community experiment (`c_xxxxxxxx`, max 50/teacher) |
| teacher | GET | `/api/lab/my-experiments` | — | Teacher's own community experiments |
| teacher | PATCH | `/api/lab/experiments/{key}` | — | Edit own community experiment (resets `approved` until re-approved) |
| teacher | DELETE | `/api/lab/experiments/{key}` | — | Delete own community experiment |
| teacher | POST | `/api/lab/requests` | `5/min` | «اطلب تجربة» — request an experiment (`≤ 1000` chars) |
| admin | GET | `/api/admin/lab/experiments` | — | All experiments (published & hidden) with `open_reports_count` |
| admin | PATCH | `/api/admin/lab/experiments/{key}` | — | Edit texts/formulas, hide/publish, feature, or approve community experiments |
| admin | GET | `/api/admin/lab/requests` | — | List teacher experiment requests |
| admin | PATCH | `/api/admin/lab/requests/{id}` | — | Mark a request `done` / `open` |
| admin | GET | `/api/admin/lab/reports` | — | List mistake reports with experiment & teacher details |
| admin | PATCH | `/api/admin/lab/reports/{id}` | — | Mark a report `done` / `open` |

---

## 1. Public Endpoints

### 1.1 List Experiments
`GET /api/public/lab/experiments`

**Query parameters (all optional):**
- `q`: searches experiment `name` and linked lesson titles.
- `stage_id`, `grade_id`, `subject_id`, `chapter_id`: filter through linked curriculum lessons.
- `subject_group`: `physics` | `chemistry` | `biology` | `science` | `earth` (matches the chips from `/public/lab/filters`).
- `lesson_id`: filters to experiments linked to that lesson and keeps the link's `position` order (unless `sort` is explicitly passed).
- `source`: `hader` | `community` (community experiments appear in lists only when approved by an admin).
- `featured`: `1` | `0`.
- `sort`: `popular` (default) | `name`.
- `page`: page number (`24` items per page).

**200 OK**
```json
{
  "data": [
    {
      "key": "ohm",
      "name": "قانون أوم",
      "area": "كهرباء",
      "kind": "formula",
      "display": "graph",
      "observe": "التيار يتناسب طرديًا مع الجهد وعكسيًا مع المقاومة",
      "approximate": false,
      "featured": true,
      "source": "hader",
      "author_name": null,
      "plays": 42,
      "lessons_count": 12,
      "variables": [
        { "symbol": "V", "label": "الجهد", "unit": "V", "min": 0, "max": 24, "default": 12 },
        { "symbol": "R", "label": "المقاومة", "unit": "Ω", "min": 1, "max": 100, "default": 10 }
      ],
      "readings": [
        { "label": "التيار", "unit": "A", "formula": "V/R" },
        { "label": "القدرة", "unit": "W", "formula": "V^2/R" }
      ],
      "first_lesson": {
        "id": 3601,
        "title": "التيار الكهربائي والدوائر الكهربائية",
        "subject": "الفيزياء 3",
        "grade": "الثالث الثانوي",
        "unit": "الكهرباء التيارية",
        "chapter": "دوائر التوالي والتوازي"
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 6,
    "per_page": 24,
    "total": 127
  }
}
```

### 1.2 Show One Experiment
`GET /api/public/lab/experiments/{key}`

- Returns `404` when `status` is `hidden` or `key` does not exist.
- Unapproved community experiments (`approved: false`) **do** open by their direct `{key}` link so teachers can share them immediately with students.

**200 OK**
```json
{
  "data": {
    "key": "ohm",
    "name": "قانون أوم",
    "area": "كهرباء",
    "kind": "formula",
    "display": "graph",
    "observe": "التيار يتناسب طرديًا مع الجهد وعكسيًا مع المقاومة",
    "approximate": false,
    "about": "حرّك الجهد والمقاومة وراقب التيار في الدائرة...",
    "examples": [
      { "title": "منظم الإضاءة", "text": "يغيّر المقاومة في دائرة المصباح، فيقل التيار ويخفت الضوء." }
    ],
    "featured": true,
    "variables": [
      { "symbol": "V", "label": "الجهد", "unit": "V", "min": 0, "max": 24, "default": 12 },
      { "symbol": "R", "label": "المقاومة", "unit": "Ω", "min": 1, "max": 100, "default": 10 }
    ],
    "readings": [
      { "label": "التيار", "unit": "A", "formula": "V/R" },
      { "label": "القدرة", "unit": "W", "formula": "V^2/R" }
    ],
    "source": "hader",
    "author_name": null,
    "approved": false,
    "plays": 42,
    "lessons_count": 12,
    "url": "https://haderedu.com/lab/ohm",
    "lessons": [
      {
        "id": 3601,
        "title": "التيار الكهربائي والدوائر الكهربائية",
        "subject": "الفيزياء 3",
        "grade": "الثالث الثانوي",
        "unit": "الكهرباء التيارية",
        "chapter": "دوائر التوالي والتوازي"
      }
    ]
  }
}
```
> **Variables with segmented choices** include `"choices": [{ "value": 0, "label": "لا" }, { "value": 1, "label": "نعم" }]`.
> **Readings with coded labels** include `"value_labels": [{ "value": 1, "label": "جليد" }, { "value": 2, "label": "ماء سائل" }]`.

### 1.3 Count a Play
`POST /api/public/lab/experiments/{key}/play`

- Call once after the visitor's first slider interaction.
- Throttled at `30` requests/minute per IP.
- Returns **`204 No Content`** (or `404` if hidden).

### 1.4 Curriculum Filters & Stats
`GET /api/public/lab/filters`

- Cached for 10 minutes (automatically invalidated on import or admin visibility changes).
- Includes only curriculum nodes with at least one publicly listed experiment; `experiments_count` at each level counts **distinct** experiments.

**200 OK**
```json
{
  "data": {
    "stages": [
      {
        "id": 3,
        "name": "الثانوية العامة",
        "experiments_count": 98,
        "grades": [
          {
            "id": 10,
            "name": "الثاني الثانوي - المسار العام",
            "track": "المسار العام",
            "experiments_count": 44,
            "subjects": [
              {
                "id": 41,
                "name": "الفيزياء 2",
                "experiments_count": 21,
                "chapters": [
                  {
                    "id": 210,
                    "name": "الحركة الدورانية",
                    "unit_id": 55,
                    "unit_name": "الميكانيكا",
                    "semester": "1",
                    "experiments_count": 2,
                    "lessons": [
                      { "id": 3292, "title": "وصف الحركة الدورانية", "experiments_count": 2 }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ],
    "subject_groups": [
      { "key": "physics", "name": "الفيزياء", "experiments_count": 70 },
      { "key": "chemistry", "name": "الكيمياء", "experiments_count": 33 },
      { "key": "biology", "name": "الأحياء", "experiments_count": 16 },
      { "key": "science", "name": "العلوم", "experiments_count": 83 },
      { "key": "earth", "name": "علوم الأرض والفضاء", "experiments_count": 17 }
    ],
    "totals": {
      "experiments": 127,
      "lessons": 690,
      "grades": 18
    }
  }
}
```

### 1.5 Lab Home Sections
`GET /api/public/lab/home`

**200 OK**
```json
{
  "data": {
    "popular": [ /* up to 8 experiment cards */ ],
    "featured": [ /* up to 8 experiment cards with featured=true */ ],
    "community": [ /* up to 8 approved community experiment cards with author_name */ ]
  }
}
```

---

## 2. Teacher Endpoints (`auth:sanctum`, `suspended`)

### 2.1 Lesson Interactive Experiments Chip
`GET /api/lessons/{lesson}/experiments`

Returns published experiments linked to `{lesson}` in `position` order (`0` = best match).

**200 OK**
```json
{
  "data": [ /* experiment cards */ ]
}
```

### 2.2 Report a Mistake
`POST /api/lab/experiments/{key}/reports` (`throttle:5,1`)

**Request**
```json
{ "message": "وحدة التيار في القراءة الثانية تحتاج مراجعة." }
```

**201 Created**
```json
{
  "data": {
    "id": 1,
    "message": "وحدة التيار في القراءة الثانية تحتاج مراجعة.",
    "status": "open",
    "experiment": { "id": 15, "key": "ohm", "name": "قانون أوم", "status": "published" },
    "teacher_name": "أحمد المعلم",
    "user": { "id": 7, "name": "أحمد المعلم", "email": "teacher@school.sa" },
    "created_at": "2026-11-03T11:00:00+03:00",
    "updated_at": "2026-11-03T11:00:00+03:00"
  }
}
```

### 2.3 Create a Community Experiment («أنشئ تجربتك»)
`POST /api/lab/experiments` (`plan.active`, `throttle:10,1`)

- Requires an active trial or paid subscription.
- Limit: **50** community experiments per teacher (the 51st returns `422` with `code: "lab_experiments_limit"`).
- `variables`: 1–5 items (`min < max`; `default` is optional and defaults to `(min + max) / 2`).
- `readings`: 1–4 items (`formula` ≤ 300 chars, validated against the grammar in `docs/lab/README.md` §3; invalid formulas return `422` with an Arabic message under `errors["readings.{i}.formula"]`).

**Request**
```json
{
  "name": "حساب الوزن على القمر",
  "display": "bars",
  "about": "غيّر الكتلة ولاحظ تغير الوزن على سطح القمر.",
  "observe": "الوزن على القمر يعادل سدس الوزن على الأرض تقريبًا.",
  "lesson_id": 3259,
  "variables": [
    { "symbol": "a", "label": "الكتلة", "unit": "kg", "min": 1, "max": 100, "default": 50 }
  ],
  "readings": [
    { "label": "الوزن على القمر", "unit": "N", "formula": "a * 1.62" }
  ]
}
```

**201 Created**
```json
{
  "data": {
    "key": "c_8f3k29ab",
    "name": "حساب الوزن على القمر",
    "area": "الفيزياء 2",
    "kind": "formula",
    "display": "bars",
    "observe": "الوزن على القمر يعادل سدس الوزن على الأرض تقريبًا.",
    "approximate": false,
    "about": "غيّر الكتلة ولاحظ تغير الوزن على سطح القمر.",
    "examples": [],
    "featured": false,
    "variables": [
      { "symbol": "a", "label": "الكتلة", "unit": "kg", "min": 1, "max": 100, "default": 50 }
    ],
    "readings": [
      { "label": "الوزن على القمر", "unit": "N", "formula": "a * 1.62" }
    ],
    "source": "community",
    "author_name": "أحمد المعلم",
    "approved": false,
    "plays": 0,
    "lessons_count": 1,
    "url": "https://haderedu.com/lab/c_8f3k29ab",
    "lessons": [
      { "id": 3259, "title": "الجاذبية وقوانين كبلر", "subject": "الفيزياء 2", "grade": "الثاني الثانوي", "unit": "الميكانيكا", "chapter": "الجاذبية" }
    ],
    "id": 168,
    "status": "published",
    "approved_at": null,
    "lesson_id": 3259,
    "open_reports_count": 0,
    "user": { "id": 7, "name": "أحمد المعلم", "email": "teacher@school.sa" },
    "created_at": "2026-11-03T11:05:00+03:00",
    "updated_at": "2026-11-03T11:05:00+03:00"
  }
}
```

### 2.4 My Community Experiments, Update & Delete
- `GET /api/lab/my-experiments` → `{ "data": [ /* full community experiments owned by caller */ ] }`
- `PATCH /api/lab/experiments/{key}` → partial update (`name`, `display`, `variables`, `readings`, `about`, `observe`, `examples`, `lesson_id`). Resets `approved` to `false` until reviewed again by an admin. `403` if owned by another user.
- `DELETE /api/lab/experiments/{key}` → `{ "data": { "deleted": true } }`.

### 2.5 Request an Experiment («اطلب تجربة»)
`POST /api/lab/requests` (`throttle:5,1`)

**Request**
```json
{
  "lesson_id": 3259,
  "message": "نحتاج تجربة تفاعلية لتوضيح القانون الثاني لكبلر والمساحات المتساوية."
}
```

**201 Created**
```json
{
  "data": {
    "id": 1,
    "lesson_id": 3259,
    "lesson": { "id": 3259, "title": "الجاذبية وقوانين كبلر", "subject": "الفيزياء 2", "grade": "الثاني الثانوي", "unit": "الميكانيكا", "chapter": "الجاذبية" },
    "message": "نحتاج تجربة تفاعلية لتوضيح القانون الثاني لكبلر والمساحات المتساوية.",
    "status": "open",
    "teacher_name": "أحمد المعلم",
    "user": { "id": 7, "name": "أحمد المعلم", "email": "teacher@school.sa" },
    "created_at": "2026-11-03T11:10:00+03:00",
    "updated_at": "2026-11-03T11:10:00+03:00"
  }
}
```

---

## 3. Admin Endpoints (`auth:sanctum`, `role:admin`)

### 3.1 List & Edit Experiments
- `GET /api/admin/lab/experiments?status=published|hidden&source=hader|community&featured=1|0&has_reports=1&q=&per_page=50`
  Returns `{ "data": [ /* full experiments including status, approved_at, open_reports_count */ ], "meta": { ... } }`, ordered with open reports first.
- `PATCH /api/admin/lab/experiments/{key}`
  Accepts any subset of:
  ```json
  {
    "name": "قانون أوم",
    "observe": "...",
    "about": "...",
    "examples": [{ "title": "...", "text": "..." }],
    "approximate": false,
    "featured": true,
    "status": "published",
    "display": "graph",
    "variables": [ ... ],
    "readings": [ ... ],
    "approve": true
  }
  ```
  - `status: "hidden"` hides the experiment immediately from all public pages and caches.
  - `approve: true` sets `approved_at` so a community experiment appears in «تجارب المجتمع».
  - `variables` and `readings` are validated against `App\Domain\Lab\Formula`; invalid formulas return `422` with the Arabic error message.

### 3.2 Manage Requests & Mistake Reports
- `GET /api/admin/lab/requests?status=open|done` → paginated `{ "data": [...], "meta": {...} }`
- `PATCH /api/admin/lab/requests/{id}` `{ "status": "done" }` (also supports `PATCH /api/admin/lab/requests` `{ "id": 1, "status": "done" }`)
- `GET /api/admin/lab/reports?status=open|done` → paginated `{ "data": [...], "meta": {...} }`
- `PATCH /api/admin/lab/reports/{id}` `{ "status": "done" }`
