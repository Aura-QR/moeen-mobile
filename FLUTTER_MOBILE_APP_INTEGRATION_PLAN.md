# Haddher Backend — Strict Flutter Mobile App Integration Plan

**Date:** 2026-06-25  
**Backend:** Laravel 11 + Sanctum Bearer tokens + Redis Queue + OpenRouter + Madrasati scraper  
**Target:** Flutter mobile app (iOS + Android)  
**Purpose:** Eliminate integration issues specific to Flutter. This is the authoritative, detailed contract.

---

## 1. Fundamental Architectural Reality for Flutter

**Recent backend improvements (as of June 2025) that affect mobile:**
- Standardized error responses (see section 7).
- Login and Register now return the exact same rich `madrasati` object as `/auth/me`.
- `/api/schedule` and `/api/madrasati/schedule` now reliably return `subject_name` resolved from `subjects_and_lessons.json` using `subject_id`.
- Better handling of `real_school_id` / `school_madrasati_id` aliases.

### 1.1 Authentication Model (Critical)
- **Pure Bearer Token** (Laravel Sanctum `createToken`).
- No cookies, no stateful sessions, no `/sanctum/csrf-cookie`.
- After successful login/register you receive a plain text token.
- **Every authenticated request must include:**
  ```http
  Authorization: Bearer <your-token>
  Accept: application/json
  Content-Type: application/json     // for all POST/PUT
  ```
- Tokens do **not** expire by default (`sanctum.expiration = null`).
- Logout deletes the token server-side.

**Flutter requirements:**
- Use `flutter_secure_storage` (never `SharedPreferences` or plain `getStorage` for the token).
- Store token immediately after login.
- Create a Dio interceptor (or equivalent) that automatically adds the `Authorization` header.
- On 401 → clear token + navigate to login.

### 1.2 No CORS Issues
Flutter native HTTP (Dio/http) does not have browser CORS. You can call the API directly.

### 1.3 JSON + Arabic
- All responses are JSON.
- Most user-facing messages are in Arabic.
- Use `Accept: application/json` on every request.

### 1.4 Core Flow (Teacher Journey)
1. Register or Login → get token + rich `madrasati` status.
2. If `madrasati.connected == false` → force Madrasati connection flow.
3. Call `GET /api/madrasati/schedule` → get rich cards (this is the source of truth).
4. Use fields from the card to call `POST /api/prepare`.
5. Poll `GET /api/prepare/{id}/status` every 3–5 seconds until `done` or `failed`.

---

## 2. Recommended Flutter HTTP Setup

**Strongly recommended stack:**
- `dio` + `dio_cookie_manager` (if ever needed) + interceptors
- `flutter_secure_storage`
- `pretty_dio_logger` (dev only)
- `connectivity_plus` + retry logic

**Example Interceptor pattern:**
```dart
class AuthInterceptor extends Interceptor {
  final String? token;
  AuthInterceptor(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

Always send `Accept: application/json`.

---

## 3. Madrasati Connection – The #1 Pain Point on Mobile

This is **much harder** on pure Flutter than on web.

### 3.1 Backend Rules (Strict)
- Must contain `.AspNetCore.Cookies` (the primary HttpOnly auth cookie). Other cookies help but this one is mandatory.
- `madrasati_school_id` (or `real_school_id`) **must** be exactly 32 hexadecimal characters.
- Best captured while the user is viewing the timetable/schedule page inside Madrasati.
- Backend will return 422 with `code: "missing_madrasati_auth_cookie"` if the main cookie is absent.

**Accepted payload formats for POST /api/madrasati/connect** (choose one):

**Preferred (array form):**
```json
{
  "cookies": [
    {"name": ".AspNetCore.Cookies", "value": "..."},
    {"name": ".AspNetCore.Antiforgery.XXX", "value": "..."}
  ],
  "madrasati_school_id": "6E91EFB432214026DFC80BC935F660B6",
  "csrf_token": "optional"
}
```

**Legacy string form:**
```json
{
  "session_cookie": ".AspNetCore.Cookies=...; other=...;",
  "madrasati_school_id": "6E91EFB4...",
  "csrf_token": "..."
}
```

### 3.2 How to Get Cookies in Flutter (Realistic Options)

**Option A – Recommended for production (In-App WebView)**
- Use `flutter_inappwebview`.
- Open `https://schools.madrasati.sa`.
- Let user log in inside the WebView.
- After successful login (detect by URL or cookie presence), extract cookies using `webViewController.getCookies()`.
- Filter important ones (`.AspNetCore.Cookies`, Antiforgery, etc.).
- Send to `/api/madrasati/connect` from Flutter.
- Also try to extract `RealSchoolId` or `SchoolId` from URL or page content.

**Option B – Manual copy-paste (quick & dirty)**
- Tell user to open Madrasati in Chrome/Safari on same device.
- Log in → go to timetable.
- Use dev tools or a small JS snippet to copy cookies.
- Paste into a multiline TextField in your app.
- Parse into the array or string format.

**Option C – Hybrid**
- Open external browser with a custom scheme or universal link.
- User comes back to app after connecting.
- This is complex.

**Important:** The existing `GET /api/madrasati/bookmarklet` is **not useful** for native Flutter (it's a browser bookmarklet).

### 3.3 After Successful Connect
1. Call `GET /api/auth/me` (or trust the connect response).
2. Immediately call `GET /api/madrasati/schedule` (this is the key call).
3. Store the rich cards locally.

### 3.4 Error Responses on Connect
Use the standardized error shape:
- `code: "missing_madrasati_auth_cookie"` + `action: "use_extension"` (but on mobile this means "use WebView").
- `code: "madrasati_school_id_missing"`
- `code: "madrasati_session_rejected"`

---

## 4. Authentication Endpoints – Exact Contracts

### 4.1 POST /api/auth/login
**Request:**
```json
{
  "email": "teacher@Haddher.sa",
  "password": "password"
}
```

**Success 200 (now consistent with /me):**
```json
{
  "user": { "id": 2, "name": "...", "email": "...", "role": "teacher", "phone": null },
  "token": "4|u8XaB98...",
  "teacher": {
    "id": 1,
    "subscription": { ... },
    "can_prepare_lesson": true,
    "ai_quota_remaining": 15
  },
  "madrasati_connected": false,
  "madrasati": {
    "connected": false,
    "school_id": null,
    ...
  }
}
```

**Store the `token` securely immediately.**

### 4.2 POST /api/auth/register
Same response shape (201). `madrasati` will be disconnected.

### 4.3 GET /api/auth/me
Call this on app startup, after token restore, after connect/disconnect.

Response shape is identical to what login now returns (without the token).

### 4.4 POST /api/auth/logout
```json
{ "success": true }
```
Clear local token + navigate to login.

---

## 5. Schedule Endpoints (Most Important Data Source)

### 5.1 GET /api/madrasati/schedule?week_date=2026-06-21 (or ?week=1)

**This is the endpoint Flutter should call after connecting.**

It returns live data + auto-syncs locally.

**Key fields in each period/card (copy these exactly when calling /prepare):**
- `encrypted_token` (long string, often starts with aHR0... – this is critical)
- `time_table_id`
- `subject_id`
- `subject_name`
- `real_school_id` (or `school_madrasati_id`)
- `classroom_id`
- `lesson_madrasati_id`
- `day_of_week`
- `period_number`

Example period from `/madrasati/schedule`:
```json
{
  "encrypted_token": "aHR0cHM6Ly9zY2hvb2xzLm1hZH...",
  "time_table_id": "17886178",
  "subject_id": 95,
  "subject_name": "العلم وتفاعلات الأجسام",
  "real_school_id": "6E91EFB432214026DFC80BC935F660B6",
  "classroom_id": "classroom_a_12",
  "lesson_madrasati_id": "95",
  "day_of_week": 0,
  "period_number": 1
}
```

**Error cases (403):**
- `code: "madrasati_session_required"`
- `code: "madrasati_school_id_missing"`
- `code: "madrasati_session_expired"`

**Special success case (live failed):**
Returns 200 with:
```json
{
  "from_cache": true,
  "live_fetch_failed": true,
  "days": [... last synced data ...]
}
```
Show a yellow banner "Showing cached schedule".

### 5.2 GET /api/schedule?week=2026-06-21

Returns locally stored data (enriched with preparation status).

Now always includes `subject_name` resolved from `subjects_and_lessons.json`.

---

## 6. Lesson Preparation Flow (The Core Feature)

### 6.1 POST /api/prepare

**You must send data that came from a schedule card.**

Required fields:
```json
{
  "subject_id": 86,
  "classroom_id": "classroom_a_12",
  "time_table_id": "17886178",
  "school_madrasati_id": "6E91EFB4...32hex...",   // or real_school_id
  "real_school_id": "...",                        // accepted alias
  "encrypted_token": "aHR0cHM6Ly9zY2hvb2xzLm1hZH...",  // critical
  "lesson_madrasati_id": "95",
  "lesson_title": "optional",
  "chapter_id": 26087,
  "selected_modules": ["assignment", "enrichment", "homework", "exam"]  // default ["assignment"]
}
```

**Response (202 Accepted):**
```json
{
  "success": true,
  "preparation_id": 42,
  "status": "pending",
  "message": "Lesson preparation started. Poll /prepare/{id}/status for updates."
}
```

**Exact status polling response (`GET /api/prepare/{id}/status`):**
```json
{
  "id": 42,
  "status": "processing",
  "progress_steps": [
    { "step_name": "fetch_goals", "status": "done", "updated_at": "..." },
    { "step_name": "generate_ai_content", "status": "running", "updated_at": "..." }
  ],
  "error": null,
  "completed_at": null,
  "madrasati_event": "123456"
}
```

### 6.2 Polling – GET /api/prepare/{id}/status

**Poll every 3–5 seconds** while status is `pending` or `processing`.

Response:
```json
{
  "id": 42,
  "status": "processing",   // pending | processing | done | failed
  "progress_steps": [
    {"step_name": "fetch_goals", "status": "done", "updated_at": "..."},
    {"step_name": "generate_ai_content", "status": "running", ...},
    ...
  ],
  "error": null,
  "completed_at": null,
  "madrasati_event": null
}
```

**Known step names** (map these to nice UI labels in Arabic):
- `fetch_goals`
- `extract_digital_content`
- `generate_ai_content`
- `before_snapshot` (conditional)
- `create_activity`
- `create_enrichment`
- `create_homework`
- `create_exam`
- `resolve_project_id`
- `fetch_lesson_form`
- `build_payload`
- `submit_to_madrasati`

Stop polling when status is `done` or `failed`. You can safely cancel the timer when you receive a terminal status.

### 6.3 Bulk
`POST /api/prepare/bulk` accepts up to 10 lessons. Jobs are staggered by 5s.

### 6.4 Retry
`POST /api/preparations/{id}/retry` (only for failed ones).

---

## 7. Standardized Error Shape (Use This!)

All errors now follow:

```json
{
  "message": "Human message (Arabic)",
  "code": "machine_code",
  "status": 403,
  "errors": null | { "field": ["msg"] },
  "action": "connect_madrasati" | "upgrade" | "use_extension" | null,
  "details": { ... extra help ... }
}
```

**Critical codes for Flutter:**
- `unauthenticated` (401)
- `quota_exceeded` (402) → `action: "upgrade"`
- `madrasati_session_required` (403) → `action: "connect_madrasati"`
- `madrasati_school_id_missing`
- `madrasati_session_expired`
- `validation_error`
- `invalid_school_id`
- `missing_madrasati_auth_cookie`

Create one centralized error handler in Flutter that looks at `code` + `action` first.

---

## 8. Other Important Endpoints

- `GET /api/subjects`
- `GET /api/subjects/{id}/lessons`
- `GET /api/subscription/current`
- Content bank (optional for v1)

---

## 9. Recommended Flutter App Architecture

- **Auth state**: Riverpod / Bloc / GetX – global auth provider holding token + user + madrasati status.
- **Schedule state**: Fetch once after connect, cache, allow refresh.
- **Preparation flow**: Separate provider that holds current preparation + polling timer.
- **Connect flow**: Dedicated screen + WebView screen.
- Use `CancelToken` in Dio for polling so you can stop when user leaves screen.

**Polling best practice:**
- Use a periodic timer (3-4 seconds).
- Cancel timer when status is terminal.
- Handle app background/foreground (pause polling in background).

---

## 10. Common Flutter-Specific Pitfalls

1. **Storing token insecurely** → use `flutter_secure_storage`.
2. **Forgetting to send `Accept: application/json`** on some requests.
3. **Not sending the exact `encrypted_token`, `real_school_id`, `time_table_id` from the schedule card** to `/prepare`.
4. **Polling too aggressively** (every 1s) or never stopping.
5. **Not handling the 200 + `from_cache: true`** case on schedule.
6. **Assuming you can get cookies easily** like on web.
7. **Not handling 402 quota errors gracefully**.
8. **Ignoring `action` field** in errors.
9. **Week date handling** – weeks start on Sunday.
10. **Long preparation times** (can be 60-120+ seconds) – show good progress UI using the steps.
11. **Network timeouts** on Madrasati proxy calls – set reasonable timeouts (30-60s).
12. **Arabic RTL** layout issues in schedule/prep screens.

---

## 11. Recommended User Flow in Flutter App

1. Splash → restore token from secure storage.
2. If no token → Login/Register screen.
3. After login → call `/auth/me`.
4. If not `madrasati.connected` ��� Madrasati Connect screen (WebView or paste option).
5. On successful connect → `GET /api/madrasati/schedule`.
6. Show weekly schedule using the rich cards.
7. On tap "Prepare Lesson" → collect card fields + selected modules → `POST /api/prepare`.
8. Navigate to Preparation Status screen and start polling.
9. On done → show success + option to view history.

---

## 12. Caching & Offline Strategy

- Cache the last successful `/madrasati/schedule` response.
- When live fetch fails, still render the cached version with a warning (the backend already does this).
- Consider local DB (Isar / Hive / Drift) for schedule + preparation history.

---

## 13. Suggested Dart Data Models (Flutter)

```dart
class MadrasatiStatus {
  final bool connected;
  final String? schoolId;
  final bool hasSchoolId;
  final bool hasAuthCookie;
  // ...
}

class SchedulePeriod {
  final String? encryptedToken;           // CRITICAL for prepare
  final String timeTableId;
  final int subjectId;
  final String? subjectName;              // Now reliably populated
  final String? realSchoolId;
  final String classroomId;
  final String? lessonMadrasatiId;
  // ...
}

class PreparationStatus {
  final int id;
  final String status;                    // pending | processing | done | failed
  final List<ProgressStep> progressSteps;
  final String? error;
  final String? madrasatiEvent;
}
```

## 14. Testing Checklist for Flutter Team

- [ ] Login → token stored securely → `/me` returns rich `madrasati` object.
- [ ] No connection → connect flow appears.
- [ ] Connect with missing main cookie → clear error + `action`.
- [ ] Successful connect → `/madrasati/schedule` returns cards with `encrypted_token` + `subject_name`.
- [ ] Prepare single lesson using exact fields from a card.
- [ ] Polling shows all steps and eventually reaches `done`.
- [ ] Bulk prepare works.
- [ ] Quota exceeded (402) shows upgrade prompt.
- [ ] Expired session (403 with code) forces reconnect.
- [ ] Cached schedule shows warning banner.
- [ ] Token cleared on logout and 401.

---

## 14. Quick Reference – Most Used Calls

| Purpose                        | Method + Endpoint                          | Notes |
|--------------------------------|--------------------------------------------|-------|
| Login                          | POST /auth/login                           | Store token |
| Check status                   | GET /auth/me                               | After login, after connect |
| Connect Madrasati              | POST /madrasati/connect                    | Hardest part on mobile |
| Get live cards (use these!)    | GET /madrasati/schedule                    | Source of truth for prepare |
| Prepare lesson                 | POST /prepare                              | 202 + poll |
| Poll status                    | GET /prepare/{id}/status                   | Every 3-5s |
| Local schedule (with prep status) | GET /schedule                           | Good for UI |

---

This plan is deliberately verbose and strict. Treat the field names, error codes, exact request shapes, and polling contract as law.

If you share specific errors you are seeing in Flutter (request + response + Dio error), I can give the exact fix.

Update this document whenever the backend changes.