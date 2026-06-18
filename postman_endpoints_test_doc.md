# Moeen Backend API - Postman Testing Documentation

This document serves as a complete reference for testing the Moeen API in Postman.

---

## 🔑 Global Headers
For all authenticated routes, configure these headers:
- `Accept`: `application/json`
- `Authorization`: `Bearer <your_sanctum_token>`

---

## 📂 1. Authentication Endpoints

### 1.1 Register a New Teacher
Create a new user and automatically associate a teacher profile under the `free` tier.

- **Method**: `POST`
- **Route**: `/api/auth/register`
- **Headers**:
  - `Accept: application/json`
- **Request Body (JSON)**:
  ```json
  {
    "name": "معلم جديد",
    "email": "teacher.new@moeen.sa",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "0509998887"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "user": {
      "id": 3,
      "name": "معلم جديد",
      "email": "teacher.new@moeen.sa"
    },
    "token": "3|t19bNXmN...",
    "teacher": {
      "id": 2,
      "user_id": 3,
      "subscription_id": 1,
      "can_prepare_lesson": true,
      "ai_quota_remaining": 20
    }
  }
  ```

---

### 1.2 User Login
Authenticate credentials and obtain a Sanctum access token.

- **Method**: `POST`
- **Route**: `/api/auth/login`
- **Headers**:
  - `Accept: application/json`
- **Request Body (JSON)**:
  ```json
  {
    "email": "teacher@moeen.sa",
    "password": "password"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "user": {
      "id": 2,
      "name": "معلم تجريبي",
      "email": "teacher@moeen.sa"
    },
    "token": "4|u8XaB98...",
    "teacher": {
      "id": 1,
      "user_id": 2,
      "subscription_id": 1,
      "can_prepare_lesson": true,
      "ai_quota_remaining": 20
    },
    "madrasati_connected": false
  }
  ```

---

### 1.3 Get Current User Profile (Me)
Retrieve the authenticated teacher profile stats.

- **Method**: `GET`
- **Route**: `/api/auth/me`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "user": {
      "id": 2,
      "name": "معلم تجريبي",
      "email": "teacher@moeen.sa"
    },
    "teacher": {
      "id": 1,
      "user_id": 2,
      "subscription_id": 1,
      "can_prepare_lesson": true,
      "ai_quota_remaining": 20
    },
    "madrasati_connected": false
  }
  ```

---

### 1.4 Logout
Revoke the current authentication token.

- **Method**: `POST`
- **Route**: `/api/auth/logout`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```

---

## 📂 2. Madrasati Account Connection

### 2.1 Connect Madrasati Account
Submit session cookies extracted by the Chrome extension to enable Laravel to act on behalf of the teacher.

- **Method**: `POST`
- **Route**: `/api/madrasati/connect`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Request Body (JSON)**:
  ```json
  {
    "session_cookie": "MicrosoftSeqCol=123; .AspNetCore.Cookies=XYZ;",
    "madrasati_school_id": "6E91EFB432214026DFC80BC935F660B6",
    "expires_at": "2026-06-25 18:00:00"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "تم ربط حساب منصة مدرستي بنجاح"
  }
  ```

---

### 2.2 Disconnect Madrasati Account
Invalidate active cookies and unlink the Madrasati session.

- **Method**: `DELETE`
- **Route**: `/api/madrasati/disconnect`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```

---

## 📂 3. Timetable & Schedule Management

### 3.1 Sync Timetable
Save/sync the teacher's weekly classroom schedule scraped from the Madrasati calendar page.

- **Method**: `POST`
- **Route**: `/api/schedule/sync`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Request Body (JSON)**:
  ```json
  {
    "week_date": "2026-06-21",
    "timetable": [
      {
        "real_school_id": "abc123abc123abc123abc123abc123ab",
        "time_table_id": "98765432",
        "subject_id": 86,
        "classroom_id": "classroom_a_12",
        "day_of_week": 1,
        "period_number": 2,
        "lesson_madrasati_id": "26143"
      }
    ]
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "synced": 1,
    "week_date": "2026-06-21"
  }
  ```

---

### 3.2 View Weekly Timetable
Retrieve the teacher's synced schedule.

- **Method**: `GET`
- **Route**: `/api/schedule?week=2026-06-21`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "week_start": "2026-06-21",
    "week_end": "2026-06-25",
    "schedule": {
      "1": [
        {
          "id": 1,
          "teacher_id": 1,
          "school_id": 2,
          "real_school_id": "abc123abc123abc123abc123abc123ab",
          "time_table_id": "98765432",
          "subject_id": 86,
          "classroom_id": "classroom_a_12",
          "day_of_week": 1,
          "period_number": 2,
          "lesson_title": "الحياة الاجتماعية -- مدخل الوحدة الرابعة"
        }
      ]
    }
  }
  ```

---

## 📂 4. Catalogue & Lessons

### 4.1 Get All Subjects
Fetch list of subjects mapped in the catalogue.

- **Method**: `GET`
- **Route**: `/api/subjects`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  [
    {
      "subject_id": 86,
      "title": "الحياة الاجتماعية",
      "title_ar": "الحياة الاجتماعية",
      "grade_level": null,
      "lesson_count": 88
    }
  ]
  ```

---

### 4.2 Get Lessons of a Subject
Fetch all lesson topics of a specific subject grouped by chapter.

- **Method**: `GET`
- **Route**: `/api/subjects/86/lessons`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "subject_id": 86,
    "chapters": [
      {
        "chapter_id": 26087,
        "title": "الحياة الاجتماعية -- مدخل الوحدة الرابعة",
        "lessons": [
          {
            "id": 26143,
            "subject_id": 86,
            "chapter_id": 26087,
            "title": "الحياة الاجتماعية -- مدخل الوحدة الرابعة",
            "title_ar": "الحياة الاجتماعية -- مدخل الوحدة الرابعة"
          }
        ]
      }
    ]
  }
  ```

---

## 📂 5. Lesson Preparation Flow

### 5.1 Start Lesson Preparation
Initiate lesson preparation. This triggers an asynchronous queue worker to scraping pages and generate AI content.

- **Method**: `POST`
- **Route**: `/api/prepare`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Request Body (JSON)**:
  ```json
  {
    "lesson_id": 26143,
    "subject_id": 86,
    "classroom_id": "classroom_a_12",
    "school_madrasati_id": "abc123abc123abc123abc123abc123ab",
    "time_table_id": "98765432",
    "selected_modules": ["assignment", "enrichment", "homework", "exam"],
    "encrypted_token": "aHR0cHM6Ly9zY2hvb2xzLm1hZHJhc2F0aS5zYS8..."
  }
  ```
  - Note: `encrypted_token` is optional (string, min:16). When provided, it is used for resolving numeric school and timetable IDs via `MlutiLessonPlan`.
  - Note: `selected_modules` supports `assignment`, `homework`, `enrichment`, and `exam`.
- **Response (202 Accepted)**:
  ```json
  {
    "success": true,
    "preparation_id": 1,
    "status": "pending",
    "message": "Lesson preparation started. Poll /prepare/{id}/status for updates."
  }
  ```

---

### 5.2 Poll Preparation Status
Check the status of an ongoing preparation job in real-time.

- **Method**: `GET`
- **Route**: `/api/prepare/1/status`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "id": 1,
    "status": "processing",
    "progress_steps": [
      {
        "step_name": "fetch_goals",
        "status": "done",
        "updated_at": "2026-06-16 14:26:00"
      },
      {
        "step_name": "extract_digital_content",
        "status": "done",
        "updated_at": "2026-06-16 14:26:02"
      },
      {
        "step_name": "generate_ai_content",
        "status": "running",
        "updated_at": "2026-06-16 14:26:03"
      }
    ],
    "error": null,
    "completed_at": null,
    "madrasati_event": null
  }
  ```

---

### 5.3 View Preparation History
List previous lesson preparation attempts made by the teacher.

- **Method**: `GET`
- **Route**: `/api/preparations`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "teacher_id": 1,
        "lesson_id": 26143,
        "status": "done",
        "completed_at": "2026-06-16 14:26:15",
        "lesson": {
          "id": 26143,
          "title": "الحياة الاجتماعية -- مدخل الوحدة الرابعة"
        }
      }
    ]
  }
  ```

---

### 5.4 Get Preparation Details
Retrieve detailed information for a specific preparation, including progress steps.

- **Method**: `GET`
- **Route**: `/api/preparations/{id}`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "id": 1,
    "teacher_id": 1,
    "lesson_id": 26143,
    "subject_id": 86,
    "classroom_id": "classroom_a_12",
    "school_madrasati_id": "abc123abc123abc123abc123abc123ab",
    "time_table_id": "98765432",
    "selected_modules": ["assignment"],
    "status": "done",
    "error_message": null,
    "completed_at": "2026-06-16 14:26:15",
    "madrasati_event_id": "123456",
    "steps": [
      {
        "id": 1,
        "preparation_id": 1,
        "step_name": "fetch_goals",
        "status": "done",
        "metadata": {}
      }
    ]
  }
  ```

---

### 5.5 Retry Lesson Preparation
Retry a failed lesson preparation attempt. Re-queues the preparation job using stored details and credentials.

- **Method**: `POST`
- **Route**: `/api/preparations/{id}/retry`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Preparation queued for retry."
  }
  ```

---

### 5.6 Bulk Start Lesson Preparation
Prepare multiple lessons concurrently (e.g. for a full week timetable). Each lesson can optionally have an `encrypted_token`. Jobs are staggered to prevent rate limiting.

- **Method**: `POST`
- **Route**: `/api/prepare/bulk`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Request Body (JSON)**:
  ```json
  {
    "lessons": [
      {
        "lesson_id": 26143,
        "subject_id": 86,
        "classroom_id": "classroom_a_12",
        "school_madrasati_id": "abc123abc123abc123abc123abc123ab",
        "time_table_id": "98765432",
        "selected_modules": ["assignment", "enrichment"],
        "encrypted_token": "aHR0cHM6Ly9zY2hvb2xzLm1hZHJhc2F0aS5zYS8..."
      },
      {
        "lesson_id": 26144,
        "subject_id": 86,
        "classroom_id": "classroom_a_12",
        "school_madrasati_id": "abc123abc123abc123abc123abc123ab",
        "time_table_id": "98765433",
        "selected_modules": ["assignment"],
        "encrypted_token": null
      }
    ]
  }
  ```
- **Response (202 Accepted)**:
  ```json
  {
    "success": true,
    "preparation_ids": [1, 2],
    "total": 2
  }
  ```

---

## 📂 6. Content Bank Endpoints

### 6.1 List Content Items
Fetch templates, exams, or homework in the content bank.

- **Method**: `GET`
- **Route**: `/api/content?type=assignment`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "data": [
      {
        "id": 1,
        "type": "assignment",
        "title": "واجب سورة البقرة",
        "content_json": {
          "questions": ["ما هي أطول آية في القرآن الكريم؟"]
        },
        "subject_id": 86,
        "is_shared": false
      }
    ]
  }
  ```

---

### 6.2 Add Content Item
- **Method**: `POST`
- **Route**: `/api/content`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Request Body (JSON)**:
  ```json
  {
    "type": "assignment",
    "title": "واجب سورة البقرة",
    "content_json": {
      "questions": ["ما هي أطول آية في القرآن الكريم؟"]
    },
    "subject_id": 86,
    "chapter_id": 26087,
    "grade_level": "Grade 5",
    "is_shared": true
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "id": 2,
    "type": "assignment",
    "title": "واجب سورة البقرة",
    "content_json": {
      "questions": ["ما هي أطول آية في القرآن الكريم؟"]
    },
    "subject_id": 86,
    "is_shared": true
  }
  ```

---

### 6.3 Clone Content Item
Duplicate a shared item to the teacher's private library.

- **Method**: `POST`
- **Route**: `/api/content/2/clone`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "new_id": 3
  }
  ```

---

## 📂 7. Subscription Plans & Quotas

### 7.1 List All Plans
- **Method**: `GET`
- **Route**: `/api/subscriptions`
- **Headers**:
  - `Accept: application/json`
- **Response (200 OK)**:
  ```json
  [
    {
      "id": 1,
      "name": "مجاني",
      "slug": "free",
      "price": 0,
      "ai_quota_per_month": 20,
      "lesson_limit_per_day": 3,
      "features": {
        "basic_preparation": true
      }
    }
  ]
  ```

---

### 7.2 Get Current Usage Stats
Get teacher's remaining AI and daily lesson preparation quotas.

- **Method**: `GET`
- **Route**: `/api/subscription/current`
- **Headers**:
  - `Accept: application/json`
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "plan": {
      "name": "مجاني",
      "slug": "free",
      "price": 0
    },
    "usage": {
      "ai_used_this_month": 5,
      "lessons_prepared_today": 1,
      "ai_remaining": 15,
      "lessons_remaining_today": 2
    }
  }
  ```
