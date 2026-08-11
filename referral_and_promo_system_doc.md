# Documentation: Hader Referral Links, Referral Rewards & Promo Code System

This documentation details the architecture, business logic, qualification workflow, and API endpoints for the **Referral Links, Referral Rewards & Promo Code System** in the Hader (حّضر) backend.

---

## 1. System Overview & Business Logic

### Business Rules & Core Workflow
1. **Permanent Referral Code**: Every teacher automatically receives a unique referral code (e.g., `HAMDY7K2`) upon registration.
2. **Registration Attribution**: When a new user registers using `referral_code`, a `Referral` record is created with status `pending`. Rejects self-referrals and duplicates.
3. **Qualification Trigger**: Merely registering or visiting the website does **NOT** grant rewards. The referral becomes `qualified` and `rewarded` **only** when the referred teacher completes their **first successful lesson preparation**.
4. **15% Discount Pair**: Upon qualification, both the Referrer and Referred teacher receive a 15% discount voucher code (e.g. `REF-A8K29P`).
5. **Quota Limit**: Maximum of **5 qualified referrals** per teacher (`referral.max_referrals_per_user = 5`). Pending referrals do not consume the quota.
6. **Backend Calculation Authority**: Frontend NEVER sends payable amounts. Price calculation, discount verification, and final payable amount generation are performed strictly on the backend.
7. **Payment Integration**: The discount is applied to `orders.amount`. When payment succeeds (`PaymentPaid`), used rewards/promos transition to `used` and audit logs are recorded in `promo_redemptions`. If payment fails, the voucher remains `available`.

---

## 2. Database Schema Summary

### Tables
- `referral_codes`: `user_id` (unique), `code` (unique, 30 chars), `is_active`.
- `referrals`: `referrer_id`, `referred_user_id` (unique), `referral_code_id`, `status` (`pending`, `qualified`, `rewarded`, `cancelled`, `expired`), `registered_at`, `qualified_at`, `rewarded_at`.
- `referral_rewards`: `referral_id`, `user_id`, `type`, `discount_type` (`percentage`), `discount_value` (15.00), `status` (`available`, `used`, `expired`, `cancelled`), `promo_code` (unique), `used_at`, `expires_at`.
- `promo_codes`: `code` (unique), `name`, `description`, `discount_type` (`percentage`, `fixed_amount`), `discount_value`, `starts_at`, `expires_at`, `max_redemptions`, `max_redemptions_per_user`, `is_active`, `eligible_plans` (json), `user_target` (`all`, `new_users`, `existing_users`), `is_stackable`, `created_by`.
- `promo_redemptions`: `promo_code_id`, `referral_reward_id`, `user_id`, `order_id`, `payment_id`, `discount_type`, `discount_value`, `original_amount`, `discount_amount`, `final_amount`, `redeemed_at`.
- `orders`: Extended with `original_amount`, `discount_amount`, `promo_code_id`, `referral_reward_id`.

---

## 3. Public & Teacher API Endpoints

### 1. User Registration with Referral Code
Registers a new teacher account and attributes the referral if `referral_code` is provided.

- **Endpoint**: `POST /api/auth/register`
- **Auth**: Public

#### Request Body
```json
{
  "name": "أحمد علي",
  "email": "ahmed.ali@moe.edu.sa",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "0501234567",
  "referral_code": "HAMDY7K2"
}
```

#### Response `201 Created`
```json
{
  "user": {
    "id": 15,
    "name": "أحمد علي",
    "email": "ahmed.ali@moe.edu.sa",
    "role": "teacher"
  },
  "token": "15|sanctum_token_string_here",
  "teacher": {
    "id": 12,
    "user_id": 15,
    "is_active": true,
    "subscription": {
      "id": 1,
      "name": "مجاني",
      "slug": "free",
      "price": "0.00"
    },
    "can_prepare_lesson": true,
    "ai_quota_remaining": 20
  },
  "madrasati_connected": false
}
```

---

### 2. Teacher Referral Dashboard ("عزوة المدرسين")
Fetches referral code, shareable link, quota stats, available rewards, and referral history.

- **Endpoint**: `GET /api/referrals/me`
- **Auth**: Required (`auth:sanctum`)

#### Response `200 OK`
```json
{
  "referral_code": "HAMDY7K2",
  "referral_link": "https://haderedu.com/register?ref=HAMDY7K2",
  "max_referrals": 5,
  "qualified_referrals": 2,
  "remaining_referrals": 3,
  "rewards_available_count": 2,
  "rewards": [
    {
      "id": 10,
      "code": "REF-A8K29P",
      "discount_value": 15.00,
      "discount_type": "percentage",
      "expires_at": "2027-08-11T14:00:00Z"
    }
  ],
  "history": [
    {
      "id": 4,
      "referred_name": "محمد حسن",
      "status": "rewarded",
      "registered_at": "2026-08-10T10:00:00Z",
      "qualified_at": "2026-08-11T12:00:00Z"
    },
    {
      "id": 5,
      "referred_name": "خالد العتيبي",
      "status": "pending",
      "registered_at": "2026-08-11T13:30:00Z",
      "qualified_at": null
    }
  ]
}
```

---

### 3. Teacher Referral History
Returns referral invitation history.

- **Endpoint**: `GET /api/referrals/history`
- **Auth**: Required (`auth:sanctum`)

#### Response `200 OK`
```json
{
  "history": [
    {
      "id": 4,
      "referred_name": "محمد حسن",
      "status": "rewarded",
      "registered_at": "2026-08-10T10:00:00Z",
      "qualified_at": "2026-08-11T12:00:00Z"
    }
  ]
}
```

---

### 4. Validate Promo / Reward Code
Validates either an Admin Promo Code or a Referral Reward Code for a specific plan **without consuming it**. Returns live discount calculation.

- **Endpoint**: `POST /api/promo-codes/validate`
- **Auth**: Required (`auth:sanctum`)

#### Request Body
```json
{
  "code": "REF-A8K29P",
  "plan_slug": "full_year"
}
```
*(or pass `"plan_id": 2`)*

#### Response `200 OK`
```json
{
  "valid": true,
  "discount": {
    "type": "percentage",
    "value": 15.00,
    "amount": 26.85
  },
  "original_amount": 179.00,
  "final_amount": 152.15,
  "code_source": "referral_reward"
}
```

#### Error Response `422 Unprocessable Entity`
```json
{
  "message": "رمز الخصم غير مفعل حالياً أو منتهي الصلاحية",
  "errors": {
    "promo_code": ["رمز الخصم منتهي الصلاحية"]
  }
}
```

---

### 5. Create Order / Upgrade Subscription with Promo Code
Creates a subscription order with calculated discount applied.

- **Endpoint**: `POST /api/subscription/upgrade` OR `POST /api/orders`
- **Auth**: Required (`auth:sanctum`)

#### Request Body (`POST /api/subscription/upgrade`)
```json
{
  "plan_slug": "full_year",
  "promo_code": "REF-A8K29P"
}
```

#### Request Body (`POST /api/orders`)
```json
{
  "service_id": 2,
  "promo_code": "REF-A8K29P"
}
```

#### Response `201 Created`
```json
{
  "message": "تم إنشاء طلب الترقية بنجاح",
  "order": {
    "id": 105,
    "service_id": 2,
    "original_amount": "179.00",
    "discount_amount": "26.85",
    "amount": "152.15",
    "currency": "SAR",
    "status": "pending",
    "promo_code_id": null,
    "referral_reward_id": 10,
    "service": {
      "id": 2,
      "name": "سنة كاملة",
      "slug": "full_year",
      "price": "179.00"
    }
  }
}
```

---

## 4. Admin API Endpoints

### 1. List Admin Promo Codes
- **Endpoint**: `GET /api/admin/promo-codes?page=1`
- **Auth**: Admin (`auth:sanctum`, `role:admin`)

#### Response `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "code": "WELCOME20",
      "name": "خصم ترحيبي 20%",
      "description": "خصم المعلمين الجدد",
      "discount_type": "percentage",
      "discount_value": "20.00",
      "starts_at": null,
      "expires_at": null,
      "max_redemptions": 500,
      "max_redemptions_per_user": 1,
      "is_active": true,
      "eligible_plans": ["semester", "full_year"],
      "user_target": "new_users",
      "is_stackable": false,
      "redemptions_count": 42
    }
  ],
  "total": 1
}
```

---

### 2. Create Admin Promo Code
- **Endpoint**: `POST /api/admin/promo-codes`
- **Auth**: Admin (`auth:sanctum`, `role:admin`)

#### Request Body
```json
{
  "code": "BACK2SCHOOL",
  "name": "خصم العودة للمدارس",
  "description": "خصم 30 ريال على باقة السنة",
  "discount_type": "fixed_amount",
  "discount_value": 30.00,
  "starts_at": "2026-08-15T00:00:00Z",
  "expires_at": "2026-09-15T23:59:59Z",
  "max_redemptions": 1000,
  "max_redemptions_per_user": 1,
  "is_active": true,
  "eligible_plans": ["full_year"],
  "user_target": "all"
}
```

#### Response `201 Created`
```json
{
  "message": "تم إنشاء كود الخصم بنجاح",
  "promo": {
    "id": 2,
    "code": "BACK2SCHOOL",
    "name": "خصم العودة للمدارس",
    "discount_type": "fixed_amount",
    "discount_value": "30.00",
    "is_active": true
  }
}
```

---

### 3. Activate / Deactivate Promo Code
- **Endpoint**: `POST /api/admin/promo-codes/{id}/activate` OR `POST /api/admin/promo-codes/{id}/deactivate`
- **Auth**: Admin (`auth:sanctum`, `role:admin`)

#### Response `200 OK`
```json
{
  "message": "تم تفعيل كود الخصم",
  "promo": {
    "id": 2,
    "code": "BACK2SCHOOL",
    "is_active": true
  }
}
```

---

### 4. Referral Program Statistics & Analytics
Returns global system statistics for the "عزوة المدرسين" referral program.

- **Endpoint**: `GET /api/admin/referrals/statistics`
- **Auth**: Admin (`auth:sanctum`, `role:admin`)

#### Response `200 OK`
```json
{
  "total_referral_links": 340,
  "total_registrations": 185,
  "qualified_referrals": 94,
  "rewards_generated": 188,
  "rewards_used": 62,
  "conversion_rate_pct": 50.81,
  "config": {
    "max_referrals_per_user": 5,
    "referrer_discount_percentage": 15.0,
    "referred_discount_percentage": 15.0
  }
}
```

---

### 5. List All System Referrals
- **Endpoint**: `GET /api/admin/referrals?page=1`
- **Auth**: Admin (`auth:sanctum`, `role:admin`)

#### Response `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "referrer_id": 3,
      "referred_user_id": 15,
      "status": "rewarded",
      "registered_at": "2026-08-10T10:00:00Z",
      "qualified_at": "2026-08-11T12:00:00Z",
      "referrer": {
        "id": 3,
        "name": "محمد علي",
        "email": "m.ali@moe.edu.sa"
      },
      "referred_user": {
        "id": 15,
        "name": "أحمد علي",
        "email": "ahmed.ali@moe.edu.sa"
      }
    }
  ]
}
```
