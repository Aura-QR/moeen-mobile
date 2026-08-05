# Lesson Presentation — Decoupling the Random Student Picker

## Context

The Moeen platform generates AI-written lesson presentations (PPTX slide outlines) for Saudi teachers, built from three pieces:

- **`moeen-backend`** (Laravel) — orchestrates generation, persists presentations/slides in Postgres.
- **`Lesson Presentation - AI Outline Generator`** (n8n workflow) — calls OpenRouter (GPT-4.1-mini) to generate the slide outline, validates it, resolves icons, merges it with fixed intro slides.
- **`moeen_front`** (Next.js) — lets teachers pick a lesson, trigger generation, preview slides, and export to PPTX.

The lesson content itself is meant to be generated **once per lesson** and reused. Teachers also want an in-class "random student picker" tool, and its roster changes every session — but currently that roster is entangled with the AI generation pipeline, which breaks the caching.

---

## The bug: every "generate" click re-runs the full AI pipeline

**File:** `moeen_front/src/app/presentations/page.tsx`, lines 768–770

```ts
const shouldRegenerate =
  presentationData?.status === "ready" ||
  presentationData?.status === "failed";
```

Once a presentation already exists for a lesson (`status: "ready"`), **every subsequent call** — including just opening the random-picker toggle and typing today's names — goes through `regenerateLessonPresentation()` instead of `generateLessonPresentation()`.

The backend distinguishes these two on purpose (`app/Application/Http/Controllers/PresentationController.php`):

- `POST /presentation/generate` — looks up the existing `Presentation` row by `(lesson_id, template_id)`. If it's already `ready`, **returns it straight from Postgres, no n8n call.**
- `POST /presentation/regenerate` — **always** deletes the old slides and re-triggers the n8n webhook, regardless of whether anything actually changed.

Because `shouldRegenerate` treats "presentation already exists" as "must regenerate," the frontend is calling the expensive, always-fresh endpoint on effectively every interaction after the first generation — including ones that only relate to the roster, not the lesson content.

The payload sent to both endpoints makes the entanglement explicit (same file, lines 783–787):

```ts
const payload = {
  template_id: templateId,
  include_random_picker: includeRandomPicker,
  student_names: studentNames,
};
```

`student_names` is currently treated as an input to the AI generation itself, flowing all the way through: Laravel → n8n webhook → `Build Prompt` node → `Merge Static + AI Slides` node, which bakes a `random_picker` slide (with the real names) into the persisted slide list.

**Even without the `shouldRegenerate` bug**, this design has a structural problem: since the DB cache key is only `(lesson_id, template_id)`, a second `generate` call with *different* student names would just return the *old* cached presentation with the *old* names. There's no way to keep the lesson content cached **and** get a fresh roster without a full regenerate — the two concerns can't both be right at the same time as long as they share one pipeline.

---

## The fix: two independent concerns, two independent paths

| Concern | Changes per | Should live in |
|---|---|---|
| Lesson content (slides) | Rarely — only when the lesson itself changes | Backend + n8n, generated once, cached in Postgres |
| Student roster / picker | Every class session | Frontend only, ephemeral, never touches the backend |

### 1. Frontend (`moeen_front`)

**`src/app/presentations/page.tsx`**
- Remove the `shouldRegenerate` logic shown above. Default every normal open/view action to `generateLessonPresentation()` — it already does the right thing (serve cached, or generate if missing).
- Reserve `regenerateLessonPresentation()` for one explicit action only: a dedicated "Regenerate" button the teacher clicks when they deliberately want the AI content rebuilt (e.g. after editing the lesson metadata). It should never fire as a side effect of the picker toggle.
- Drop `include_random_picker` and `student_names` from the payload sent to both `generate` and `regenerate` entirely.
- Keep `includeRandomPicker` / `studentNamesInput` as local component state only. Use them to:
  - Render an on-screen randomizer widget while presenting (pure client-side JS — no request needed), and/or
  - Inject a `random_picker` slide at **export time**, using the `addNameGrid()` function already implemented in `src/lib/presentations/presentation-pptx.ts`, built from the local names — not from anything fetched from the backend.

**`src/lib/api/presentations.ts`**
- `GeneratePresentationPayload` can drop `include_random_picker` / `student_names` (or keep them typed as unused/optional for backward compatibility, but stop populating them).

### 2. Backend (`moeen-backend`)

**`app/Application/Http/Controllers/PresentationController.php`**
- `generate()` / `regenerate()` can stop reading `include_random_picker` / `student_names` from the request, since the frontend will no longer send them.
- `app/Domain/Lessons/Jobs/GenerateLessonPresentation.php` — drop the `$includeRandomPicker` / `$studentNames` constructor args and whatever passes them into `LessonOutlineGenerator::generate()`, once nothing upstream sends them.

No changes needed to the caching logic itself (`Presentation::updateOrCreate` keyed on `lesson_id` + `template_id`, `isReady()` check) — that part was already correct.

### 3. n8n (`Lesson Presentation - AI Outline Generator`)

**`Merge Static + AI Slides` node**
- Remove section (ب) — the `includeRandomPicker` check and the `randomPickerSlide` block — entirely. The static intro slides + AI slides merge/renumber logic stays as-is.

**`Build Prompt` node**
- The `include_random_picker` / `student_names` passthrough in its output becomes unused; safe to delete once the payload from Laravel no longer includes them.

---

## Why this is the right split, not just a workaround

- The lesson content becomes a pure function of `(lesson_id, template_id)` — generated once, reused indefinitely, exactly matching what the `Presentation` DB schema and `generate()` caching logic were already built for.
- The roster becomes a pure function of "who's in class today" — never needs a network round trip, never invalidates the cached presentation, and updates instantly.
- No more wasted OpenRouter calls just to swap a name list.
- `regenerate` keeps a clear, single meaning: "the lesson content itself needs to be rebuilt" — not overloaded with "the roster changed."
