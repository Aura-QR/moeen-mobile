# Exam Generation Frontend Integration

This document explains how the frontend should call the AI-powered exam generation API and render the returned exam preview.

## Authentication

All exam endpoints require an authenticated teacher and these headers:

```http
Authorization: Bearer <sanctum-token>
Accept: application/json
```

## 1. Generate an Exam

```http
POST /api/exams/generate
Authorization: Bearer <sanctum-token>
Content-Type: application/json
Accept: application/json
```

This endpoint is for authenticated teachers only.

## Request Body

Send the selected grade, subject, lessons, and how many questions are needed per type.

All five question-type keys are required for every lesson, even when the value is `0`.

```json
{
  "title": "Midterm Science Exam",
  "grade": "Grade 7",
  "subject": "Science",
  "difficulty": "hard",
  "lessons": [
    {
      "lesson_id": 101,
      "lesson_name": "Cell Structure",
      "requested_counts": {
        "mcq": 3,
        "true_false": 2,
        "fill_blank": 1,
        "essay": 1,
        "matching": 1
      }
    }
  ]
}
```

`title` is optional. If omitted, the backend generates a default title using subject, grade, and date.

`difficulty` is optional and accepts only `easy`, `medium`, or `hard`. It defaults to `medium`. The backend:

- reuses only bank questions with the requested difficulty;
- forwards `difficulty` to the n8n generation webhook;
- saves generated questions with that difficulty.

The difficulty applies to random/AI questions requested through `requested_counts`. Questions explicitly supplied through `selected_question_ids` keep their own stored difficulty.

### Detailed mode: select exact bank questions

`selected_question_ids` is optional and additive. Selected IDs are attached exactly as supplied; `requested_counts` asks for additional random/AI questions on top of them.

```json
{
  "grade": "Grade 7",
  "subject": "Science",
  "difficulty": "hard",
  "lessons": [
    {
      "lesson_id": 101,
      "lesson_name": "Cell Structure",
      "selected_question_ids": [9001, 9007],
      "requested_counts": {
        "mcq": 1,
        "true_false": 0,
        "fill_blank": 0,
        "essay": 0,
        "matching": 0
      }
    }
  ]
}
```

Selected questions are excluded from the random pool. They must belong to the supplied lesson and must either be approved for sharing or owned by the authenticated teacher. Omit `selected_question_ids` for the original quick mode.

## Question Types

| Type | Frontend label | Notes |
|---|---|---|
| `mcq` | Multiple choice | Render `options` as choices. |
| `true_false` | True / False | `correct_answer` is `صح` or `خطأ`. |
| `fill_blank` | Fill in the blank | `question_text` contains `____`. |
| `essay` | Essay | Render a free-text answer area in preview/print mode. |
| `matching` | Matching | Render `options.column_a` and `options.column_b` as two columns. |

## Success Response

```json
{
  "success": true,
  "exam": {
    "id": 44,
    "teacher_id": 7,
    "title": "Midterm Science Exam",
    "status": "draft",
    "total_points": 2,
    "created_at": "2026-07-13T10:30:00+00:00",
    "updated_at": "2026-07-13T10:30:00+00:00",
    "questions": [
      {
        "id": 901,
        "lesson_id": 101,
        "type": "mcq",
        "difficulty": "hard",
        "question_text": "Which part controls cell entry and exit?",
        "options": ["Nucleus", "Cell membrane", "Cytoplasm", "Mitochondria"],
        "correct_answer": "Cell membrane",
        "source": "ai_generated",
        "usage_count": 1,
        "question_order": 1,
        "points": 1
      },
      {
        "id": 902,
        "lesson_id": 101,
        "type": "matching",
        "difficulty": "hard",
        "question_text": "Match each item with its function.",
        "options": {
          "column_a": ["1. Cell membrane", "2. Nucleus"],
          "column_b": ["A. Controls activities", "B. Controls entry and exit", "C. Makes proteins"]
        },
        "correct_answer": "1-B, 2-A",
        "source": "ai_generated",
        "usage_count": 1,
        "question_order": 2,
        "points": 1
      }
    ]
  },
  "meta": {
    "requested_count": 2,
    "reused_count": 0,
    "generated_count": 2,
    "manually_selected_count": 0
  }
}
```

Use `exam.questions` sorted by `question_order` for preview and printing.
Every generated question starts with `1.00` point. Points belong to the question inside this exam, so reusing the same question in another exam does not reuse its point value.

## 2. Get an Exam

Use this endpoint to reload an exam and its saved question points.

```http
GET /api/exams/{exam_id}
Authorization: Bearer <sanctum-token>
Accept: application/json
```

Success response:

```json
{
  "success": true,
  "exam": {
    "id": 44,
    "teacher_id": 7,
    "title": "Midterm Science Exam",
    "status": "draft",
    "total_points": 5.5,
    "created_at": "2026-07-13T10:30:00+00:00",
    "updated_at": "2026-07-14T09:15:00+00:00",
    "questions": [
      {
        "id": 901,
        "lesson_id": 101,
        "type": "mcq",
        "difficulty": "hard",
        "question_text": "Which part controls cell entry and exit?",
        "options": ["Nucleus", "Cell membrane", "Cytoplasm", "Mitochondria"],
        "correct_answer": "Cell membrane",
        "source": "ai_generated",
        "usage_count": 1,
        "question_order": 1,
        "points": 2
      },
      {
        "id": 902,
        "lesson_id": 101,
        "type": "matching",
        "difficulty": "hard",
        "question_text": "Match each item with its function.",
        "options": {
          "column_a": ["1. Cell membrane", "2. Nucleus"],
          "column_b": ["A. Controls activities", "B. Controls entry and exit"]
        },
        "correct_answer": "1-B, 2-A",
        "source": "ai_generated",
        "usage_count": 1,
        "question_order": 2,
        "points": 3.5
      }
    ]
  }
}
```

`total_points` is calculated by the backend from all question points.

## 3. Update Question Points

Use one bulk request to save the teacher's selected points. The request may contain one question or multiple questions. Questions not included in the request keep their current values.

```http
PATCH /api/exams/{exam_id}/questions/points
Authorization: Bearer <sanctum-token>
Content-Type: application/json
Accept: application/json
```

Request:

```json
{
  "questions": [
    {
      "question_id": 901,
      "points": 2
    },
    {
      "question_id": 902,
      "points": 3.5
    }
  ]
}
```

Rules:

- At least one question is required.
- `question_id` must be unique in the request and must belong to this exam.
- `points` must be greater than `0`, no more than `1000`, and have at most two decimal places.
- Only the teacher who owns the exam can update it.
- Points can only be changed while the exam status is `draft`.
- The update is atomic: either all submitted point changes are saved or none are saved.

The success response uses the same `{ "success": true, "exam": { ... } }` shape as `GET /api/exams/{exam_id}` and contains the recalculated `total_points`.

## 4. Publish an Exam

Every generated exam starts with `status: "draft"`. Publishing finalizes it and locks question-point and manual-question changes.

```http
POST /api/exams/{exam_id}/publish
Authorization: Bearer <sanctum-token>
Accept: application/json
```

No request body is required. The exam must belong to the authenticated teacher and contain at least one question.

```json
{
  "success": true,
  "exam": {
    "id": 44,
    "title": "Midterm Science Exam",
    "status": "published",
    "total_points": 20.5,
    "questions": []
  }
}
```

The actual response contains the complete exam questions. Publishing is idempotent: retrying the endpoint for an already published exam returns the same published exam successfully.

Lifecycle rules:

- `draft`: points can be changed and manual questions can be added.
- `published`: the exam can still be opened, previewed, and printed, but points and manual questions are locked.
- An empty exam cannot be published.
- There is currently no unpublish endpoint.

## 5. Delete an Exam

Deletes an exam owned by the authenticated teacher.

```http
DELETE /api/exams/{exam_id}
Authorization: Bearer <sanctum-token>
Accept: application/json
```

Both draft and published exams can be deleted. Deletion permanently removes the exam and its question attachments, but does not delete shared question-bank records. Question `usage_count` values are decremented automatically.

```json
{
  "success": true,
  "message": "تم حذف الاختبار بنجاح"
}
```

A teacher cannot delete another teacher's exam (`exam_forbidden`, status `403`). Requesting an exam ID that does not exist returns `not_found`, status `404`.

Frontend action: require confirmation before calling this endpoint, remove the row from "My Exams" after success, and close the preview screen if the deleted exam is currently open.

## 6. List My Exams

```http
GET /api/exams?page=1&per_page=20&status=draft&search=midterm
Authorization: Bearer <sanctum-token>
Accept: application/json
```

All filters are optional. `status` accepts `draft` or `published`; `per_page` accepts `1` through `100`. Results are always restricted to the authenticated teacher.

```json
{
  "success": true,
  "data": [
    {
      "id": 44,
      "title": "Midterm Science Exam",
      "status": "draft",
      "questions_count": 8,
      "total_points": 20.5,
      "created_at": "2026-07-13T10:30:00+00:00",
      "updated_at": "2026-07-14T09:15:00+00:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 20,
    "total": 1
  }
}
```

Open a row through `GET /api/exams/{exam_id}` to reuse the existing preview/reprint screen.

## 7. Browse Lesson Questions

```http
GET /api/lessons/{lesson_id}/questions?type=mcq&difficulty=hard&page=1&per_page=20
Authorization: Bearer <sanctum-token>
Accept: application/json
```

`type` is optional and accepts `mcq`, `true_false`, `fill_blank`, `essay`, or `matching`. `difficulty` is optional and accepts `easy`, `medium`, or `hard`. The response includes approved shared questions plus the authenticated teacher's own pending or rejected questions. Another teacher's unapproved questions are never returned.

```json
{
  "success": true,
  "lesson_id": 101,
  "type": "mcq",
  "data": [
    {
      "id": 9001,
      "lesson_id": 101,
      "creator_teacher_id": null,
      "type": "mcq",
      "difficulty": "hard",
      "question_text": "Which part controls cell entry and exit?",
      "options": ["Nucleus", "Cell membrane", "Cytoplasm", "Mitochondria"],
      "correct_answer": "Cell membrane",
      "source": "ai_generated",
      "review_status": "approved",
      "usage_count": 12,
      "created_at": "2026-07-13T10:30:00+00:00",
      "updated_at": "2026-07-13T10:30:00+00:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 20,
    "total": 1
  }
}
```

## 8. Add a Manual Question

Creates a private pending question and immediately attaches it to the teacher's draft exam. Approval is not required for use in that exam.

```http
POST /api/questions
Authorization: Bearer <sanctum-token>
Content-Type: application/json
Accept: application/json
```

```json
{
  "exam_id": 44,
  "lesson_id": 101,
  "type": "mcq",
  "difficulty": "hard",
  "question_text": "Which organelle produces energy?",
  "options": ["Nucleus", "Mitochondria", "Ribosome", "Cell wall"],
  "correct_answer": "Mitochondria",
  "points": 2.5
}
```

The exam must belong to the teacher and have `draft` status. `difficulty` is optional and defaults to `medium`; it accepts `easy`, `medium`, or `hard`. `points` is optional and defaults to `1`. For `mcq`, at least two options are required and `correct_answer` must match one option. For `matching`, `options.column_a` and `options.column_b` are required.

Response status is `201`:

```json
{
  "success": true,
  "question": {
    "id": 9100,
    "source": "manual",
    "difficulty": "hard",
    "review_status": "pending",
    "creator_teacher_id": 7
  },
  "exam": {
    "id": 44,
    "total_points": 23,
    "questions": []
  }
}
```

The actual response contains the complete question and exam objects.

## 9. List Questions Pending Admin Review

Admin authentication and the `admin` role are required.

```http
GET /api/admin/questions/pending-review?type=mcq&difficulty=hard&lesson_id=101&page=1&per_page=20
Authorization: Bearer <admin-token>
Accept: application/json
```

All filters are optional. `difficulty` accepts `easy`, `medium`, or `hard`. The paginated `data` items use the same question shape as the browse endpoint and additionally contain:

```json
{
  "creator": {
    "teacher_id": 7,
    "name": "Teacher Name",
    "email": "teacher@example.com"
  }
}
```

## 10. Approve or Reject a Manual Question

```http
PATCH /api/admin/questions/{question_id}/review
Authorization: Bearer <admin-token>
Content-Type: application/json
Accept: application/json
```

```json
{
  "decision": "approved"
}
```

`decision` accepts `approved` or `rejected`. Approved questions enter the shared bank. Rejected questions remain available only to their creator. Neither decision removes the question from exams that already contain it.

```json
{
  "success": true,
  "question": {
    "id": 9100,
    "source": "manual",
    "review_status": "approved"
  }
}
```

## Error Responses

### Validation Error

Returned when required fields or counts are missing/invalid.

```json
{
  "message": "خطأ في البيانات",
  "code": "validation_error",
  "status": 422,
  "errors": {
    "lessons.0.requested_counts.essay": ["The lessons.0.requested_counts.essay field is required."]
  }
}
```

Frontend action: highlight the invalid form fields and keep the user on the generation screen.

### AI Generation Failed

Returned when n8n cannot generate a valid response after its internal retries.

```json
{
  "success": false,
  "message": "حدث خطأ أثناء انشاء الأسئلة، الرجاء المحاولة مرة أخرى لاحقاً",
  "code": "exam_generation_ai_failed",
  "status": 502
}
```

Frontend action: show a retry-friendly message and allow the teacher to submit again.

### Webhook Missing / Unreachable

Possible codes:

| Code | Status | Meaning |
|---|---:|---|
| `exam_generation_webhook_missing` | 503 | Backend n8n URL is not configured. |
| `exam_generation_webhook_unreachable` | 504 | n8n timed out or could not be reached. |
| `exam_generation_webhook_failed` | 502 | n8n returned a non-success HTTP status. |
| `invalid_exam_generation_response` | 502 | n8n returned malformed JSON. |
| `incomplete_exam_generation_response` | 502 | n8n response did not satisfy the requested counts. |
| `selected_question_invalid` | 422 | A selected question is unavailable, private to another teacher, or belongs to another lesson. |
| `selected_question_duplicate` | 422 | The same question was selected more than once. |

### Exam Access and Point Update Errors

| Code | Status | Meaning | Frontend action |
|---|---:|---|---|
| `unauthenticated` | 401 | Token is missing or invalid. | Return to login. |
| `teacher_profile_missing` | 403 | User has no teacher profile. | Show an account support message. |
| `exam_forbidden` | 403 | Exam belongs to another teacher. | Do not display or edit the exam. |
| `not_found` | 404 | Exam ID does not exist. | Show exam-not-found state. |
| `question_not_in_exam` | 422 | A submitted question is not attached to the exam. | Reload the exam before retrying. |
| `validation_error` | 422 | IDs or point values failed validation. | Display field errors from `errors`. |
| `exam_not_editable` | 409 | Exam is no longer a draft. | Disable point inputs and reload the exam. |
| `exam_empty` | 422 | The teacher attempted to publish an exam without questions. | Keep it in draft and require at least one question. |
| `question_not_reviewable` | 409 | Admin attempted to review a non-manual question. | Reload the review queue. |

Backend configuration note: the exam webhook key can be supplied through `N8N_EXAM_WEBHOOK_KEY`. If the same shared key is used for reports and exams, the backend also accepts `N8N_EDUCATIONAL_REPORT_API_KEY` as a fallback.

## Rendering Notes

- Always show `question_text`.
- Use `question_order` for display order.
- Show an editable numeric `points` input beside each question while the exam is a draft.
- Allow decimal input with a step such as `0.5` or `0.25`; the API accepts up to two decimal places.
- Display `total_points` from the API instead of calculating the authoritative value only on the client.
- Keep `correct_answer` available for answer toggle/teacher preview.
- For student print mode, hide answers by default.
- For teacher preview mode, allow toggling answer visibility.
- For `mcq`, render each option as a separate choice.
- For `true_false`, render `صح / خطأ` choices even though `options` is empty.
- For `fill_blank`, preserve the `____` placeholder in the question text.
- For `essay`, render the model answer only when answers are visible.
- For `matching`, render `options.column_a` and `options.column_b` as two separate columns. `column_b` may include one extra distractor item.

## Example Frontend Flow

1. Teacher selects grade, subject, and lessons.
2. For quick mode, teacher enters counts for all five question types. For detailed mode, first browse questions, select IDs, and use counts only for additional questions.
3. Frontend sends `POST /api/exams/generate`.
4. Show a loading state. The request can take up to 90 seconds when n8n retries internally.
5. On success, render the returned `exam.questions`.
6. Let the teacher edit the `points` value beside each question and show a live provisional total.
7. Save changed values through `PATCH /api/exams/{exam_id}/questions/points` and replace local exam state with the returned exam.
8. Use `GET /api/exams/{exam_id}` whenever the screen is reopened or needs to be refreshed.
9. Let the teacher adjust preview settings such as font size and answer visibility.
10. When the teacher confirms the exam, call `POST /api/exams/{exam_id}/publish` and replace local state with the returned published exam.
11. Disable point and manual-question controls after publication.
12. Print/export the preview to PDF and show each question's points and the exam's `total_points`.
