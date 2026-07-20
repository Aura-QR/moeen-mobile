# AI-Generated Lesson Presentations — Full Implementation Plan

## 1. Goal

For any lesson already in the curriculum database (stages → grades → subjects
→ units → chapters → lessons), generate a downloadable/viewable PowerPoint
(.pptx) presentation:
- Fully AI-authored text content (title, key points, explanations,
  examples) — **not scraped from any third-party site**.
- Illustrated using licensed stock icon/illustration libraries, not
  per-slide AI image generation (for cost control).
- Generated once per lesson and cached, not regenerated on every request.

This keeps you 100% legally clear (no third-party copyrighted content) and
keeps cost low (generate once, reuse many times).

---

## 2. High-Level Architecture

```
┌─────────────┐      ┌──────────────────┐      ┌────────────────────┐
│  Frontend/   │─────▶│  Backend API      │─────▶│  Presentation        │
│  Mobile App  │      │  (Laravel)        │      │  Generation Service  │
└─────────────┘      └──────────────────┘      └────────────────────┘
                             │                              │
                             ▼                              ▼
                      ┌─────────────┐              ┌──────────────────┐
                      │  Postgres    │              │  LLM API (text)   │
                      │  (existing   │              │  + pptx builder    │
                      │  curriculum  │              │  + icon library     │
                      │  schema)     │              └──────────────────┘
                      └─────────────┘                        │
                                                               ▼
                                                    ┌──────────────────┐
                                                    │  File storage      │
                                                    │  (S3-compatible)   │
                                                    └──────────────────┘
```

The Generation Service is a separate concern from the main request/response
cycle — it runs as a background job, not inline in an HTTP request (slide
generation can take 5–20 seconds; don't block the user's request on it).

---

## 3. Database Changes

Add two new tables. Both reference your **existing** `lessons` table — no
changes needed to the existing curriculum schema.

```sql
CREATE TABLE presentations (
    id              BIGSERIAL PRIMARY KEY,
    lesson_id       BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status          TEXT NOT NULL DEFAULT 'pending',
        -- 'pending' | 'generating' | 'ready' | 'failed'
    template_id     TEXT NOT NULL DEFAULT 'default',
        -- which visual template/theme was used
    file_path        TEXT,          -- storage path once generated (e.g. S3 key)
    slide_count      INTEGER,
    generated_at     TIMESTAMP,
    generation_error TEXT,           -- populated if status = 'failed'
    created_at       TIMESTAMP NOT NULL DEFAULT now(),
    updated_at       TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE (lesson_id, template_id)  -- one presentation per lesson+template combo
);

CREATE TABLE presentation_slides (
    id                BIGSERIAL PRIMARY KEY,
    presentation_id   BIGINT NOT NULL REFERENCES presentations(id) ON DELETE CASCADE,
    slide_order       INTEGER NOT NULL,
    slide_type        TEXT NOT NULL,
        -- 'title' | 'objectives' | 'content' | 'example' | 'summary' | 'quiz_prompt'
    title             TEXT,
    body_text         TEXT,          -- AI-generated content, plain text/markdown
    icon_keyword      TEXT,          -- keyword used to pick a stock icon (e.g. "frog")
    icon_asset_path   TEXT,          -- resolved icon file path/URL, once matched
    UNIQUE (presentation_id, slide_order)
);

CREATE INDEX idx_presentations_lesson_id ON presentations(lesson_id);
CREATE INDEX idx_presentations_status ON presentations(status);
CREATE INDEX idx_presentation_slides_presentation_id ON presentation_slides(presentation_id);
```

Why this shape:
- `presentations` tracks generation state per lesson (so the frontend can
  show "generating..." / "ready" / retry-on-failure).
- `presentation_slides` stores the actual AI-generated text **before** it's
  baked into a .pptx file — this lets you re-render the same content into a
  different visual template later without re-calling the LLM (saves cost),
  and lets you show slide content in-app (e.g. as a web preview) without
  needing to parse the .pptx file itself.
- The final `.pptx` binary lives in object storage (S3/Spaces/etc.), not in
  the database — only the `file_path` is stored.

---

## 4. Backend Plan (Laravel)

### 4.1 API Endpoints

```
POST   /api/lessons/{lesson_id}/presentation/generate
       → Enqueues a generation job if one doesn't already exist/isn't
         already 'ready'. Returns { status: 'pending' | 'generating' | 'ready' }.

GET    /api/lessons/{lesson_id}/presentation
       → Returns presentation metadata + status + slides (for preview)
         + download URL if status = 'ready'.

GET    /api/lessons/{lesson_id}/presentation/download
       → Streams/redirects to the .pptx file (signed URL from storage).

POST   /api/lessons/{lesson_id}/presentation/regenerate
       → Force regeneration (e.g. teacher didn't like the result, or you
         updated the template).
```

### 4.2 Generation Job (Queued)

Use Laravel's queue system (`php artisan queue:work`) so generation never
blocks a request:

```php
class GenerateLessonPresentation implements ShouldQueue
{
    public function __construct(public int $lessonId, public string $templateId = 'default') {}

    public function handle(): void
    {
        $lesson = Lesson::with('chapter.subject.grade.stage')->findOrFail($this->lessonId);

        $presentation = Presentation::updateOrCreate(
            ['lesson_id' => $lesson->id, 'template_id' => $this->templateId],
            ['status' => 'generating']
        );

        try {
            // Step 1: ask the LLM for structured slide content
            $slidesData = app(LessonOutlineGenerator::class)->generate($lesson);

            // Step 2: persist slide records
            foreach ($slidesData as $order => $slide) {
                PresentationSlide::updateOrCreate(
                    ['presentation_id' => $presentation->id, 'slide_order' => $order],
                    [
                        'slide_type' => $slide['type'],
                        'title' => $slide['title'],
                        'body_text' => $slide['body'],
                        'icon_keyword' => $slide['icon_keyword'] ?? null,
                    ]
                );
            }

            // Step 3: resolve icons for each slide (stock library lookup)
            app(IconResolver::class)->resolveForPresentation($presentation);

            // Step 4: render to .pptx and upload to storage
            $filePath = app(PptxRenderer::class)->render($presentation);

            $presentation->update([
                'status' => 'ready',
                'file_path' => $filePath,
                'slide_count' => count($slidesData),
                'generated_at' => now(),
            ]);
        } catch (\Throwable $e) {
            $presentation->update(['status' => 'failed', 'generation_error' => $e->getMessage()]);
            throw $e; // let the queue retry per your retry policy
        }
    }
}
```

### 4.3 `LessonOutlineGenerator` (LLM call)

Prompts the LLM with the lesson's context (from your existing schema: stage
name, grade, subject, chapter, semester) and asks for a structured JSON
response (slide type, title, body text, a suggested icon keyword per
slide). Using structured output (JSON mode / forced schema) avoids parsing
headaches.

Example prompt shape (pseudocode):

```
System: You are an expert Saudi curriculum instructional designer creating
a presentation outline for a K-12 lesson. Output strict JSON matching this
schema: [{type, title, body, icon_keyword}, ...]. 6-10 slides. Age-
appropriate language for {grade}. Content must be original, not copied from
any source.

User: Stage: {stage}. Grade: {grade}. Subject: {subject}. Chapter: {chapter}.
Lesson: {lesson.title}.
```

### 4.4 `IconResolver`

Given each slide's `icon_keyword` (e.g. "frog", "fraction", "map"), search a
pre-indexed local catalog of licensed stock icons (downloaded once from a
provider like Flaticon/Storyset under a commercial license, stored in your
own storage — don't hotlink to a third party at runtime) and pick the best
match. Fallback to a generic subject-themed icon if no keyword match found.

### 4.5 `PptxRenderer`

Use a PHP pptx library (e.g. `PhpOffice/PHPPresentation`) or shell out to a
Node.js microservice using `PptxGenJS` if you prefer — either works fine
from Laravel via a queued job. Apply one of a small set of pre-built visual
templates (color scheme + layout) based on `template_id`.

### 4.6 Cost & Caching Strategy

- **Generate on first request, not upfront for all ~13,000 lessons.** Most
  lessons will never be requested; pre-generating everything wastes money.
- Once `status = 'ready'`, all future requests for that lesson are free
  (just serve the cached file).
- Track generation cost per lesson (LLM tokens used) in a simple log table
  or just via your LLM provider's dashboard — no need to over-engineer this
  early on.
- Rough cost order of magnitude: a single lesson outline (short JSON, a few
  hundred output tokens) costs a small fraction of a cent per generation
  with most current LLM pricing. Even fully generating for every lesson in
  your ~13,000-lesson dataset would be inexpensive in LLM terms — the
  bigger cost driver is usually image/icon licensing and storage, both of
  which this plan keeps cheap (reused icon library, not per-slide AI
  images).

---

## 5. Frontend Plan (Web)

### 5.1 UI Flow

1. Teacher navigates: stage → grade → (track, if secondary) → subject →
   unit/chapter → lesson (your existing cascading selectors).
2. On the lesson detail page, show a **"Presentation" tab/section**:
   - If no presentation exists yet: a "Generate Presentation" button →
     calls `POST /presentation/generate`, shows a loading/progress state
     (poll `GET /presentation` every few seconds, or use a websocket/SSE
     channel if you want real-time updates).
   - If `status = 'ready'`: show a slide-by-slide preview (using the
     `presentation_slides` data — render as simple cards, no need to parse
     the actual .pptx file for preview) + a "Download .pptx" button.
   - If `status = 'failed'`: show a retry button.
3. Optional: a "Regenerate" button for teachers who want different content
   (e.g. different tone/depth) — could support passing generation options
   (grade-level adjustment, more/fewer slides) as parameters to the
   generate endpoint.

### 5.2 Components (framework-agnostic naming)

- `LessonPresentationPanel` — orchestrates state (pending/generating/ready/failed)
- `SlidePreviewCard` — renders one slide's title/body/icon
- `PresentationDownloadButton`
- `GenerationProgressIndicator`

### 5.3 API integration

Use polling (simplest) initially:

```js
async function pollPresentationStatus(lessonId) {
  const res = await fetch(`/api/lessons/${lessonId}/presentation`);
  const data = await res.json();
  if (data.status === 'ready' || data.status === 'failed') return data;
  await new Promise(r => setTimeout(r, 2000));
  return pollPresentationStatus(lessonId);
}
```

---

## 6. Mobile Plan

Same API, same flow — the mobile app is just another client of the same
backend endpoints described above.

- **iOS/Android (native or React Native/Flutter)**: reuse the exact same
  4 endpoints. No mobile-specific backend work needed.
- Downloading: on mobile, "Download .pptx" should either (a) open the file
  in the OS's native PowerPoint/Office viewer app if installed, or (b)
  offer an in-app slide preview using the `presentation_slides` JSON data
  (title/body/icon per slide) rendered as native views — this avoids
  needing a .pptx renderer on-device at all, and reuses the same preview
  data the web frontend already uses.
- Offline: cache the downloaded .pptx (or the slide JSON, for the
  lightweight in-app preview) locally so a teacher who generated a
  presentation once can view it without a connection later.

---

## 7. Rollout Phases

| Phase | Scope | Goal |
|---|---|---|
| **1. Prototype** | 1 template, 1 subject, ~10 lessons, manual trigger only | Validate LLM output quality + pptx rendering end-to-end |
| **2. Backend MVP** | Full API (4 endpoints), queued generation, 1 template | Any lesson in the DB can generate a presentation on demand |
| **3. Web frontend** | Presentation panel on lesson pages | Teachers can generate/preview/download from the web app |
| **4. Icon library integration** | Replace placeholder icons with real licensed matches | Presentations look polished, not generic |
| **5. Mobile** | Same endpoints wired into the mobile app | Feature parity across platforms |
| **6. Templates & polish** | 2–3 visual themes, teacher can pick one | Differentiation / product polish |

Recommended order: **1 → 2 → 3** first (get the core loop working and
visible before investing in mobile/multiple templates), then 4–6 as
follow-ups.

---

## 8. Summary of What NOT to Do (per our earlier discussion)

- ❌ Do not scrape tahdiri's (or any other platform's) actual slide
  text/images via automated session bypass, even for "reference only" use
  at scale.
- ❌ Do not generate a unique AI image per slide for every lesson (cost).
- ✅ Do use your own already-scraped lesson **titles/structure** (which is
  organizational metadata, already established as low-risk) as the input
  context for the LLM.
- ✅ Do use a licensed stock icon/illustration library, resolved by keyword
  matching, not live AI generation, for visuals.
- ✅ Do generate once per lesson and cache — never regenerate on every
  view.
