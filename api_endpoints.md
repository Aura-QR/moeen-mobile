# Moeen API — Endpoints Reference

**Base URL:** `https://librechat-assiut-moeen-backend.tfgpna.easypanel.host/api`  
**Format:** All requests/responses are `application/json`  
**Auth:** `Authorization: Bearer <token>` (Laravel Sanctum)

---

## Standard Error Shape

Every error from the API follows this shape:

```json
{
  "message": "رسالة خطأ بالعربي",
  "code": "machine_readable_code",
  "status": 422,
  "errors": { "field": ["validation message"] },
  "action": "connect_madrasati | upgrade | null",
  "details": {}
}
```

| Code | HTTP | Meaning |
|------|------|---------|
| `unauthenticated` | 401 | Missing or invalid token |
| `account_suspended` | 403 | Account deactivated by admin |
| `forbidden` | 403 | Role not permitted |
| `not_found` | 404 | Resource does not exist |
| `validation_error` | 422 | Request body failed validation |
| `quota_exceeded` | 402 | Daily/monthly AI quota reached |
| `server_error` | 500 | Unexpected server error |

---

## 🔓 Public — No Authentication Required

### `GET /`
Health check.
```json
{ "message": "Welcome to Moeen API!" }
```

---

### `POST /auth/login`
Authenticate a teacher or admin.

**Body**
```json
{ "email": "teacher@example.com", "password": "password123" }
```

**Response `200`**
```json
{
  "user": {
    "id": 4,
    "name": "azza",
    "email": "azza@gmail.com",
    "role": "teacher",
    "phone": "0507028887",
    "is_active": true
  },
  "token": "330|bVUxXLj...",
  "teacher": {
    "id": 3,
    "is_active": true,
    "subscription": { "id": 1, "name": "مجاني", "slug": "free", "price": "0.00", "ai_quota_per_month": 20, "lesson_limit_per_day": 3 },
    "can_prepare_lesson": true,
    "ai_quota_remaining": 20
  },
  "madrasati_connected": false,
  "madrasati": {
    "connected": false,
    "school_id": null,
    "has_school_id": false,
    "expires_at": null,
    "cookie_count": 0,
    "has_auth_cookie": false
  }
}
```

**Errors**
| HTTP | `code` | Cause |
|------|--------|-------|
| `401` | — | Wrong email or password |
| `403` | `account_suspended` | Account deactivated by admin |

---

### `POST /auth/register`
Register a new teacher account. Automatically assigned the free subscription.

**Body**
```json
{ "name": "Ahmed Ali", "email": "ahmed@example.com", "password": "Password123", "password_confirmation": "Password123", "phone": "0501234567" }
```

**Response `201`** — Same shape as `/auth/login`.

---

### `GET /subscriptions`
List all available subscription plans (for the upgrade/pricing page).

**Response `200`**
```json
[{ "id": 1, "name": "مجاني", "slug": "free", "price": "0.00", "ai_quota_per_month": 20, "lesson_limit_per_day": 3, "is_active": true, "features": {} }]
```

---

### `GET /contact/types`
Returns the dropdown options for the contact form.

**Response `200`**
```json
{
  "types": [
    { "value": "technical_support", "label": "دعم فني" },
    { "value": "billing",           "label": "الفوترة والاشتراكات" },
    { "value": "feature_request",   "label": "اقتراح ميزة" },
    { "value": "general",           "label": "استفسار عام" },
    { "value": "other",             "label": "أخرى" }
  ]
}
```

---

### `POST /contact`
Submit a contact form. Works for guests and authenticated teachers (token optional — if sent, the ticket is linked to the user account).

**Body**
```json
{
  "name": "Ahmad",
  "email": "ahmad@example.com",
  "phone": "+966512345678",
  "type": "technical_support",
  "message": "أواجه مشكلة في صفحة الجدول..."
}
```

**Validation rules**
| Field | Rules |
|-------|-------|
| `name` | required, 2–100 chars |
| `email` | required, valid email |
| `phone` | optional, 7–20 chars |
| `type` | required, one of the `/contact/types` values |
| `message` | required, 10–2000 chars |

**Response `201`**
```json
{ "message": "تم إرسال طلبك بنجاح. سيتواصل معك فريقنا قريباً.", "request_id": 7 }
```

---

### `GET /madrasati/connectivity`
Test Madrasati reachability from the server (direct + via proxy). No auth needed.

---

## 🔐 Authenticated — Teacher & Admin
> **Header:** `Authorization: Bearer <token>`  
> All routes below check for `account_suspended` before running.

---

### `POST /auth/logout`
Revoke the current token.

**Response `200`**
```json
{ "success": true }
```

---

### `GET /auth/me`
Get the current user's profile, teacher info, and Madrasati status.

**Response `200`** — Same shape as `/auth/login` response.

---

### `PATCH /auth/password`
Update the current authenticated user's password. Teachers use this to change their own password.

**Body**
```json
{
  "current_password": "OldPassword123",
  "password": "NewPassword123",
  "password_confirmation": "NewPassword123"
}
```

**Response `200`**
```json
{ "message": "Password updated successfully." }
```

**Notes**
- Requires the current password.
- Revokes the user's other active tokens after the password changes.

---

## 🗓️ Madrasati Integration

### `POST /madrasati/connect`
Link a Madrasati session to the current teacher account.

**Body (option A — cookie array from Extension)**
```json
{
  "cookies": [{ "name": ".AspNetCore.Cookies", "value": "..." }, ...],
  "madrasati_school_id": "E7F07D5AB1E7A8BAA59F6FC2BA80190B",
  "expires_at": "2026-07-25T18:00:00Z"
}
```

**Body (option B — raw cookie string from Bookmarklet)**
```json
{
  "session_cookie": ".AspNetCore.Cookies=ABC; _ga=...",
  "madrasati_school_id": "E7F07D5AB1E7A8BAA59F6FC2BA80190B"
}
```

**Response `200`**
```json
{
  "success": true,
  "message": "تم ربط حساب منصة مدرستي بنجاح",
  "cookies_stored": 27,
  "has_auth_cookie": true,
  "madrasati_school_id": "E7F07D5...",
  "madrasati": { "connected": true, ... }
}
```

---

### `DELETE /madrasati/disconnect`
Remove Madrasati session from this account.

**Response `200`** `{ "success": true }`

---

### `GET /madrasati/bookmarklet`
Returns a personalised JavaScript bookmarklet string for the teacher to use in their browser.

---

### `POST /madrasati/refresh-session`
Re-validate and refresh the stored Madrasati session cookies.

---

### `GET /madrasati/schedule`
⚠️ Requires `madrasati.session` middleware — teacher must be connected.  
Fetch the live weekly timetable directly from Madrasati and auto-sync locally.

---

## 📅 Schedule

### `GET /schedule`
Return the teacher's locally-stored weekly timetable.

### `GET /schedule/available-lessons`
Return lessons from the timetable that have not yet been prepared.

### `POST /schedule/sync`
⚠️ Requires `madrasati.session`.  
Force a full sync of the teacher's timetable from Madrasati.

---

## 📚 Lesson Catalogue

### `GET /subjects`
List all subjects.

### `GET /subjects/{id}/lessons`
List all lessons within a subject.

### `GET /lessons/{id}`
Get full details for a single lesson.

---

## 🤖 Lesson Preparation

### `POST /prepare`
⚠️ Requires `madrasati.session` + `lesson.quota` middleware.  
Start an AI lesson preparation job.

**Body**
```json
{ "lesson_id": 42, "options": {} }
```

**Response `202`**
```json
{ "job_id": "uuid-...", "message": "جاري التحضير..." }
```

---

### `GET /prepare/{jobId}/status`
Poll the status of a running preparation job.

**Response `200`**
```json
{ "status": "processing | completed | failed", "progress": 60, "result": {} }
```

---

### `GET /preparations`
List all past preparations for the current teacher (paginated).

### `GET /preparations/{id}`
Full detail of a single preparation.

### `POST /preparations/{id}/retry`
⚠️ Requires `madrasati.session`.  
Retry a failed preparation.

### `POST /prepare/bulk`
⚠️ Requires `madrasati.session` + `lesson.quota`.  
Prepare multiple lessons in one request.

**Body**
```json
{ "lesson_ids": [1, 2, 3] }
```

---

## 🗂️ Content Bank

### `GET /content`
List all content items saved by the teacher.

### `POST /content`
Create a new content item.

### `GET /content/{id}`
Get a single content item.

### `PUT /content/{id}`
Replace a content item.

### `PATCH /content/{id}`
Partially update a content item.

### `DELETE /content/{id}`
Delete a content item.

### `POST /content/{id}/clone`
Duplicate a content item.

---

## 💳 Subscription

### `GET /subscription/current`
Get the current teacher's active subscription details.

### `POST /subscription/upgrade`
Request a subscription upgrade.

---

## 💬 Contact — Teacher (own tickets)

### `GET /contact/my`
List all contact tickets submitted by the authenticated teacher.

**Response `200`**
```json
{
  "data": [{
    "id": 5,
    "name": "Ahmad",
    "email": "ahmad@example.com",
    "type": "technical_support",
    "type_label": "دعم فني",
    "message": "...",
    "status": "in_progress",
    "status_label": "جاري المعالجة",
    "unread_by_client_count": 2,
    "replies_count": 4,
    "resolved_at": null,
    "created_at": "2026-07-06T12:00:00+03:00",
    "updated_at": "2026-07-06T14:00:00+03:00"
  }]
}
```

---

### `GET /contact/my/{id}`
Full ticket detail + reply thread.  
**Side effect:** Auto-marks all unread admin replies as read (`read_at = now()`).

**Response `200`**
```json
{
  "id": 5,
  "name": "Ahmad",
  "status": "in_progress",
  "status_label": "جاري المعالجة",
  "replies": [
    { "id": 1, "sender_type": "client", "sender_name": "Ahmad", "body": "لدي مشكلة...", "is_read": true, "read_at": "2026-07-06T12:05:00+03:00", "created_at": "..." },
    { "id": 2, "sender_type": "admin",  "sender_name": "مدير النظام", "body": "سنعالج مشكلتك...", "is_read": true, "read_at": "...", "created_at": "..." }
  ]
}
```

> **Note:** `admin_notes` is **never** included in the teacher view.

---

### `POST /contact/my/{id}/reply`
Teacher sends a follow-up message on their own ticket.

**Body**
```json
{ "body": "هل تم حل المشكلة؟" }
```

**Response `201`**
```json
{ "message": "تم إرسال ردك بنجاح.", "reply": { "id": 3, "sender_type": "client", ... } }
```

**Error `422`** if ticket status is `resolved` or `closed`.

---

## 🛡️ Admin Panel
> **Required:** `Authorization: Bearer <admin-token>` with role `admin`  
> Prefix: `/admin/...`

---

## 👩‍🏫 Teacher Management

### `GET /admin/teachers`
Paginated list of all teachers.

**Query params**
| Param | Example | Description |
|-------|---------|-------------|
| `search` | `ahmed` | Filter by name or email |
| `status` | `active` / `inactive` | Filter by `teachers.active` |
| `per_page` | `20` | Items per page (default 20) |

**Response `200`** — Paginated list of teacher objects.

---

### `POST /admin/teachers`
Create a new teacher account.

**Body**
```json
{
  "name": "Sara",
  "email": "sara@school.sa",
  "phone": "0501234567",
  "password": "Password123",
  "subscription_id": 2
}
```

**Response `201`** — Teacher object + `plain_password` field (only returned once).

---

### `GET /admin/teachers/{id}`
Get full detail of a single teacher.

---

### `PATCH /admin/teachers/{id}`
Update teacher fields.

**Body** (all fields optional)
```json
{
  "name": "Sara Mohammed",
  "phone": "0507654321",
  "active": true,
  "subscription_id": 2,
  "subscription_ends_at": "2027-01-01"
}
```

---

### `DELETE /admin/teachers/{id}`
Soft-delete the teacher (the underlying user is soft-deleted; data is preserved).

---

### `POST /admin/teachers/{id}/reset-password`
Reset a teacher password. If no body is sent, the API generates a new random 12-character password. If `password` is sent, the admin-provided password is used.

**Body (optional)**
```json
{
  "password": "NewPassword123",
  "password_confirmation": "NewPassword123"
}
```

**Response `200`**
```json
{ "message": "Password reset successfully.", "plain_password": "xK9mP2qLtR7n" }
```

**Notes**
- `plain_password` is returned once so the admin can share it with the teacher.
- All teacher tokens are revoked after the reset.

---

### `POST /admin/teachers/{id}/renew-subscription`
Renew or extend the teacher's subscription.

**Body**
```json
{ "subscription_id": 2, "months": 6 }
```

---

### `POST /admin/teachers/{id}/remove-subscription`
Demote teacher back to the free tier.

---

### `POST /admin/teachers/{id}/suspend`
**Suspend** a teacher account.

Effects:
- `teachers.active = false`
- `users.active = false`
- **All Sanctum tokens deleted** (teacher is immediately logged out)
- All Madrasati sessions invalidated

**Response `200`**
```json
{ "message": "تم تعليق حساب المعلم بنجاح.", "teacher": { ... } }
```

---

### `POST /admin/teachers/{id}/unsuspend`
**Re-activate** a suspended teacher. They can log in again immediately.

**Response `200`**
```json
{ "message": "تم رفع التعليق عن حساب المعلم بنجاح.", "teacher": { ... } }
```

---

## 📬 Contact Management (Admin)

### `GET /admin/contact/stats`
Dashboard summary widget.

**Response `200`**
```json
{
  "total": 42,
  "unread_total": 5,
  "by_status": {
    "pending": 10,
    "in_progress": 8,
    "resolved": 20,
    "closed": 4
  },
  "by_type": { "technical_support": 25, "billing": 7, ... }
}
```

---

### `GET /admin/contact`
Paginated list of all contact tickets.

**Query params**
| Param | Example | Description |
|-------|---------|-------------|
| `status` | `pending` | Filter by status |
| `type` | `technical_support` | Filter by request type |
| `search` | `ahmed` | Search name / email / message body |
| `has_unread` | `1` | Only tickets with unread client messages |
| `per_page` | `20` | Items per page (max 100) |

**Response `200`** — Paginated list. Each item includes `unread_by_admin_count` and `replies_count`.

---

### `GET /admin/contact/{id}`
Full ticket detail + complete reply thread.  
**Side effect:** Auto-marks all unread **client** messages as read.

**Response `200`**
```json
{
  "id": 5,
  "name": "Ahmad",
  "email": "ahmad@example.com",
  "phone": "+966512345678",
  "type": "technical_support",
  "type_label": "دعم فني",
  "message": "Original message body...",
  "status": "in_progress",
  "status_label": "جاري المعالجة",
  "admin_notes": "Internal note visible only to admins",
  "unread_by_admin_count": 0,
  "unread_by_client_count": 1,
  "replies_count": 3,
  "user": { "id": 4, "name": "Ahmad", "email": "ahmad@example.com", "phone": "..." },
  "resolved_by": null,
  "resolved_at": null,
  "created_at": "2026-07-06T12:00:00+03:00",
  "updated_at": "2026-07-06T14:00:00+03:00",
  "replies": [
    { "id": 1, "sender_type": "client", "sender_name": "Ahmad",        "body": "لدي مشكلة...", "is_read": true, "read_at": "...", "created_at": "..." },
    { "id": 2, "sender_type": "admin",  "sender_name": "مدير النظام", "body": "سنعالج مشكلتك...", "is_read": false, "read_at": null, "created_at": "..." }
  ]
}
```

---

### `PATCH /admin/contact/{id}`
Update ticket status and/or internal admin notes.

**Body** (all fields optional)
```json
{ "status": "in_progress", "admin_notes": "Escalated to DevOps team." }
```

**Status values:** `pending` | `in_progress` | `resolved` | `closed`

> Auto-sets `resolved_by` and `resolved_at` when status → `resolved` or `closed`.  
> Clears those fields when status is reverted to an open state.

**Response `200`**
```json
{ "message": "تم تحديث الطلب بنجاح.", "request": { ... } }
```

---

### `POST /admin/contact/{id}/reply`
Admin sends a reply message to the teacher/client.

**Body**
```json
{ "body": "مرحباً، سنتواصل معك خلال 24 ساعة." }
```

**Side effect:** If ticket status is `pending`, it is automatically moved to `in_progress`.

**Response `201`**
```json
{
  "message": "تم إرسال الرد على العميل بنجاح.",
  "reply": {
    "id": 3,
    "sender_type": "admin",
    "sender_name": "مدير النظام",
    "body": "مرحباً، سنتواصل معك خلال 24 ساعة.",
    "is_read": false,
    "read_at": null,
    "created_at": "2026-07-06T15:00:00+03:00"
  }
}
```

---

### `GET /admin/contact/{id}/replies`
Returns the raw reply thread **without** marking anything as read.  
Use this for lightweight polling/refresh from the admin UI.

**Response `200`**
```json
{
  "contact_request_id": 5,
  "status": "in_progress",
  "replies": [ { ... }, { ... } ]
}
```

---

### `DELETE /admin/contact/{id}`
Permanently delete a ticket and all its replies.

**Response `204`** — No content.

---

## 🧰 Debug / Diagnostic

### `GET /debug/proxy`
Test the Madrasati proxy connection. Returns the server's exit IP and a live Madrasati ping result.

**Query params**
| Param | Description |
|-------|-------------|
| `teacher_id` | Optional — use a specific teacher's sticky proxy token |

---

## 🔁 Conversation Flow Diagram

```
Teacher submits ticket        POST /contact
  └─ Admin sees it            GET  /admin/contact         (unread_by_admin_count > 0)
  └─ Admin opens it           GET  /admin/contact/{id}    (auto-marks client msgs read)
  └─ Admin replies            POST /admin/contact/{id}/reply
  └─ Teacher sees badge       GET  /contact/my            (unread_by_client_count > 0)
  └─ Teacher opens it         GET  /contact/my/{id}       (auto-marks admin msgs read)
  └─ Teacher replies back     POST /contact/my/{id}/reply
  └─ Admin resolves it        PATCH /admin/contact/{id}   { status: "resolved" }
```

---

## 📋 Middleware Legend

| Middleware | Applied To | Behaviour |
|-----------|-----------|-----------|
| `auth:sanctum` | All protected routes | Validates Bearer token |
| `suspended` | All teacher routes | 403 if `teacher.active = false` or `user.active = false` |
| `role:admin` | All `/admin/*` routes | 403 if user role ≠ admin |
| `madrasati.session` | Schedule sync, Prepare, Retry | 422 if no valid Madrasati session stored |
| `lesson.quota` | Prepare, Bulk prepare | 402 if daily lesson limit reached |
