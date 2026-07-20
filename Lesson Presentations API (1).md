# Lesson Presentations API — Postman Testing Guide

> **Architecture Note**: The backend generates and stores structured **slide JSON only** — no PPTX file is created on the server. The frontend is responsible for building the PPTX (e.g. using [pptxgenjs](https://gitbrent.github.io/PptxGenJS/)) from the returned JSON data.

---

## 1. Setup & Authentication

All presentation endpoints are protected by Laravel Sanctum (`auth:sanctum`). You must obtain a Bearer token by logging in first.

### Login
- **Method**: `POST`
- **URL**: `{{base_url}}/api/auth/login`
- **Headers**: `Content-Type: application/json`, `Accept: application/json`
- **Body**:
  ```json
  {
    "email": "teacher@moeen.sa",
    "password": "your_password"
  }
  ```
- Copy the `token` from the response and set it as **Bearer Token** in the Authorization tab of your collection or request.

---

## 2. Collection Variables

Set these in your Postman Collection **Variables** tab:

| Variable | Example Value |
|---|---|
| `base_url` | `https://librechat-assiut-moeen-backend.tfgpna.easypanel.host` |
| `token` | *(paste from login response)* |
| `lesson_id` | `795` |
| `template_id` | `emerald-green` |

---

## 3. Endpoints

### 3.1 — Generate Presentation
Kicks off asynchronous AI generation via the n8n webhook. Returns immediately with `status: pending`.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `{{base_url}}/api/lessons/{{lesson_id}}/presentation/generate` |
| **Auth** | Bearer `{{token}}` |

**Body (JSON)** *(optional — defaults to `"default"`)*:
```json
{
  "template_id": "emerald-green"
}
```

> **Supported `template_id` values:** `default` · `emerald-green` · `warm-orange`

**Response — `202 Accepted`** *(new generation started)*:
```json
{
  "status": "pending",
  "presentation": {
    "id": 5,
    "lesson_id": 795,
    "status": "pending",
    "template_id": "emerald-green",
    "slide_count": null,
    "generated_at": null,
    "generation_error": null,
    "slides": []
  }
}
```

**Response — `200 OK`** *(already ready or still generating)*:
```json
{
  "status": "ready",
  "presentation": { ... }
}
```

---

### 3.2 — Get Presentation & Slides (Poll)
Retrieves the current status and the full slide JSON. Poll this endpoint until `status` is `"ready"`.

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `{{base_url}}/api/lessons/{{lesson_id}}/presentation?template_id={{template_id}}` |
| **Auth** | Bearer `{{token}}` |

**Response — `404 Not Found`** *(generation not started yet)*:
```json
{
  "message": "لم يتم إنشاء عرض تقديمي لهذا الدرس بعد",
  "status": "not_found"
}
```

**Response — `200 OK`** *(still generating)*:
```json
{
  "id": 5,
  "lesson_id": 795,
  "status": "generating",
  "template_id": "emerald-green",
  "slide_count": null,
  "generated_at": null,
  "generation_error": null,
  "slides": []
}
```

**Response — `200 OK`** *(ready — use `slides` array to build PPTX on the frontend)*:
```json
{
  "id": 8,
  "lesson_id": 795,
  "status": "ready",
  "template_id": "emerald-green",
  "slide_count": 11,
  "generated_at": "2026-07-20T11:12:36+00:00",
  "generation_error": null,
  "slides": [
    {
      "id": 1,
      "slide_order": 0,
      "slide_type": "objectives",
      "title": "أهداف الدرس ومخرجات التعلم",
      "body_text": "- هدف أول\n- هدف ثاني\n- هدف ثالث",
      "icon_keyword": "target"
    },
    {
      "id": 2,
      "slide_order": 1,
      "slide_type": "content",
      "title": "مفهوم الدرس",
      "body_text": "- نقطة أولى في الشرح\n- نقطة ثانية في الشرح",
      "icon_keyword": "book"
    }
  ]
}
```

#### Slide Types Reference

| `slide_type` | Description |
|---|---|
| `title` | Opening title slide |
| `objectives` | Learning objectives list |
| `content` | Main explanation slide |
| `example` | Worked example |
| `summary` | End-of-lesson recap |
| `quiz_prompt` | Assessment / reflection questions |

#### Polling Strategy
```
POST /generate  →  status: pending
  ↓  (wait 5s)
GET /presentation  →  status: generating
  ↓  (wait 5s)
GET /presentation  →  status: ready  ✅  → use slides[] to build PPTX
```

> **Tip:** In Postman, use the **Collection Runner** or a **Pre-request Script** with `pm.sendRequest` to poll automatically.

---

### 3.3 — Force Regenerate
Clears existing slides and triggers a completely fresh generation. Use this when content needs updating.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `{{base_url}}/api/lessons/{{lesson_id}}/presentation/regenerate` |
| **Auth** | Bearer `{{token}}` |

**Body (JSON)**:
```json
{
  "template_id": "emerald-green"
}
```

**Response — `202 Accepted`**:
```json
{
  "status": "pending",
  "presentation": {
    "id": 8,
    "lesson_id": 795,
    "status": "pending",
    "template_id": "emerald-green",
    "slide_count": null,
    "generated_at": null,
    "generation_error": null,
    "slides": []
  }
}
```

---

## 4. Frontend Icon Rendering (`icon_keyword`)

The backend sends back a raw `icon_keyword` for each slide (e.g., `"tennis"`, `"calculator"`, `"target"`, `"book"`, etc.). 

Since the frontend is generating the PPTX, it should map these keywords to a front-end icon library (such as **Lucide Icons**, **FontAwesome**, or **Heroicons**), or fallback to a default icon when no exact match is found.

### Example React mapping helper:
```javascript
import { 
  Target, BookOpen, Lightbulb, HelpCircle, 
  HelpCircle as DefaultIcon, Activity, Flame 
} from 'lucide-react';

const ICON_MAP = {
  'target': Target,
  'objectives': Target,
  'book': BookOpen,
  'content': BookOpen,
  'example': Lightbulb,
  'practice': Lightbulb,
  'quiz_prompt': HelpCircle,
  'questions': HelpCircle,
  'tennis': Activity,
  'soccer': Activity,
  // Add other mappings as your n8n webhook returns them
};

export function getSlideIcon(keyword) {
  const normalized = (keyword || '').toLowerCase().trim();
  return ICON_MAP[normalized] || DefaultIcon;
}
```

---

## 5. n8n Webhook — Payload Reference

The backend sends this JSON to the n8n webhook automatically when a generation job runs:

```json
{
  "lesson_id": 795,
  "template_id": "emerald-green",
  "stage": "المرحلة المتوسطة",
  "track": "",
  "grade": "الصف الأول المتوسط",
  "semester": "2",
  "subject": "التربية البدنية",
  "unit": "رياضة التنس",
  "chapter": "الإرسال في التنس",
  "lesson_title": "الإرسال المستقيم من أعلى"
}
```

The n8n workflow **must respond** with this JSON shape:

```json
{
  "slides": [
    {
      "type": "title",
      "title": "عنوان الدرس",
      "body": "نص افتتاحي",
      "icon_keyword": "star"
    },
    {
      "type": "objectives",
      "title": "أهداف الدرس",
      "body": ["هدف أول", "هدف ثاني", "هدف ثالث"],
      "icon_keyword": "target"
    }
  ]
}
```

> **Note:** `body` can be a **string** or an **array of strings** — the backend normalizes both into newline-separated bullet points automatically.

---

## 6. Error States

| `status` | Meaning | Action |
|---|---|---|
| `pending` | Job queued, not started yet | Poll again in a few seconds |
| `generating` | Webhook call is in progress (takes ~25s) | Poll again in 5–10 seconds |
| `ready` | Slides available — use `slides[]` | Build PPTX on frontend |
| `failed` | An error occurred | Check `generation_error` field, then call `/regenerate` |
