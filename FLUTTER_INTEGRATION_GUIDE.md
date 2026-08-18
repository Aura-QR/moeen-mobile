# 📱 دليل تكامل نظام التجربة المجانية والاشتراكات (Flutter Integration Guide)

> هذا الدليل موجه لمطور **Flutter (Mobile App)** لتوضيح كيفية التعامل مع نظام الفترة التجريبية المجانية (7 أيام)، عرض تواريخ انتهاء الخطة والاشتراك، قيود الاستخدام (التحضير والذكاء الاصطناعي)، ونقاط نهاية الـ API، مع النماذج البرمجية (Dart) والواجهات المقترحة.

---

## 📑 جدول المحتويات
1. [نظرة عامة على منطق العمل (Business Logic)](#1-نظرة-عامة-على-منطق-العمل)
2. [تحديثات استجابة الـ Authentication والـ Profile](#2-تحديثات-استجابة-الـ-authentication-والـ-profile)
3. [نقاط النهاية للاشتراكات والاستخدام (Subscription APIs)](#3-نقاط-النهاية-للاشتراكات-والاستخدام)
4. [معالجة استجابات الخطأ (HTTP 402 Error Contract)](#4-معالجة-استجابات-الخطأ-http-402)
5. [نموذج Dart المحدث (TeacherModel مع تواريخ وحالة الخطة)](#5-نموذج-dart-المحدث)
6. [حساب الأيام المتبقية وتنسيق التاريخ (Dynamic Countdown & Date Formatting)](#6-حساب-الأيام-المتبقية-وتنسيق-التاريخ)
7. [الواجهات والمكونات المطلوبة في تطبيق الموبايل (UI Components)](#7-الواجهات-والمكونات-المطلوبة-في-تطبيق-الموبايل)
8. [Interceptor / Repository Error Handling في Flutter](#8-معالجة-الأخطاء-عبر-dio-interceptor)

---

## 1. نظرة عامة على منطق العمل

| الحالة (Status) | الشرط في الباك إند | السلوك في تطبيق الموبايل | ما يظهر في شاشة الحساب/الملف الشخصي |
| :--- | :--- | :--- | :--- |
| **في التجربة المجانية (Trial)** | `is_in_trial == true` و `trial_ends_at > now()` | • التحضير متاح (15 تحضير/يوم).<br>• الذكاء الاصطناعي متاح (200 توليد/شهر).<br>• يظهر شريط أخضر/برتقالي بالأيام المتبقية. | • الخطة: **تجربة مجانية (7 أيام)**<br>• الصلاحية: `تنتهي في: DD/MM/YYYY`<br>• المتبقي: `متبقي X أيام` |
| **مشترك باشتراك مدفوع (Subscribed)** | `is_subscribed == true` | • صلاحية كاملة حسب حدود الخطة المشترك بها.<br>• شريط التجربة مخفي تماماً. | • الخطة: **[اسم الخطة e.g. فصل دراسي]**<br>• الصلاحية: `ينتهي في: DD/MM/YYYY`<br>• المتبقي: `متبقي X يوم` |
| **انتهت التجربة ولم يشترك (Expired)** | `is_in_trial == false` و `is_subscribed == false` | • **حظر كامل** لعمليات التحضير والتقارير والاختبارات والعروض برمز `402`.<br>• يظهر تنبيه ثابت/نافذة منبثقة بانتهاء التجربة وزر للاشتراك. | • الخطة: **انتهت التجربة المجانية**<br>• الحالة: `انتهت في: DD/MM/YYYY`<br>• زر بارز: **اشترك الآن ⚡** |

---

## 2. تحديثات استجابة الـ Authentication والـ Profile

في جميع مسارات المصادقة وجلب بيانات المستخدم:
- `POST /api/login`
- `POST /api/register`
- `GET /api/me`

يحتوي كائن المعلم `teacher` على الحقول التالية التي تحدد الخطة وموعد انتهائها:

```json
{
  "token": "1|xxxxxxxxxxxxxxxxxxxxxxxx",
  "teacher": {
    "id": 12,
    "is_active": true,
    "can_prepare_lesson": true,
    "ai_quota_remaining": 195,
    "is_in_trial": true,
    "is_subscribed": false,
    "subscription_ends_at": null,
    "trial_ends_at": "2026-08-25T13:00:00.000000Z",
    "trial_days_remaining": 7,
    "subscription": {
      "id": 1,
      "name": "الخطة المجانية",
      "slug": "free",
      "price": "0.00",
      "lesson_limit_per_day": 15,
      "ai_quota_per_month": 200
    }
  }
}
```

> **ملاحظة:** إذا كان المعلم مشتركاً باشتراك مدفوع (مثل باقة الفصل الدراسي):
> - `is_subscribed`: `true`
> - `is_in_trial`: `false`
> - `subscription_ends_at`: `"2027-02-17T12:00:00.000000Z"` (تاريخ الانتهاء الفعلي)
> - `subscription.name`: `"باقة الفصل الدراسي"`

---

## 3. نقاط النهاية للاشتراكات والاستخدام

### 1) جلب حالة الاشتراك والاستخدام الحالي
`GET /api/subscription/current`
- **Headers:** `Authorization: Bearer <TOKEN>`
- **Response (200 OK):**
```json
{
  "plan": {
    "id": 2,
    "name": "باقة الفصل الدراسي",
    "slug": "semester",
    "price": 149,
    "lesson_limit_per_day": 25,
    "ai_quota_per_month": 500
  },
  "is_in_trial": false,
  "trial_ends_at": null,
  "trial_days_remaining": 0,
  "usage": {
    "ai_used_this_month": 12,
    "lessons_prepared_today": 4,
    "ai_remaining": 488,
    "lessons_remaining_today": 21
  }
}
```

### 2) جلب باقات الاشتراك المتاحة
`GET /api/subscriptions` (لا يتطلب مصادقة)
- يُرجع قائمة الخطط المتاحة (فصلي، سنوي، ...إلخ) لعرضها في شاشة باقات الأسعار (Pricing / Checkout Screen).

### 3) إنشاء طلب ترقية / اشتراك
`POST /api/subscription/upgrade`
- **Body:** `{"plan_slug": "semester", "promo_code": "DISCOUNT10"}`
- **Response (201 Created):** يُرجع كائن الطلب `order` مع معرف الطلب ورابط/بوابة الدفع.

---

## 4. معالجة استجابات الخطأ (HTTP 402 Error Contract)

عند استدعاء أي من المسارات المحمية (`/api/prepare`, `/api/reports/educational/generate`, `/api/exams/generate`, `/api/lessons/{id}/presentation/generate`):

إذا لم تكن العملية مسموحة، يرجع السيرفر كود `402` بهيكل موحد:

### أ) حالة انتهاء التجربة (`trial_expired`):
```json
{
  "message": "انتهت فترتك التجريبية المجانية. اشترك الآن للاستمرار في استخدام ميزات الذكاء الاصطناعي.",
  "code": "trial_expired",
  "status": 402,
  "action": "subscribe",
  "details": {
    "upgrade_url": "/checkout",
    "trial_ended": true
  }
}
```

### ب) حالة استنفاد الحصة اليومية/الشهرية (`quota_exceeded`):
```json
{
  "message": "تجاوزت الحد اليومي لإعداد الدروس",
  "code": "quota_exceeded",
  "status": 402,
  "action": "upgrade",
  "details": {
    "upgrade_url": "/checkout",
    "trial_active": true
  }
}
```

---

## 5. نموذج Dart المحدث (Teacher & Subscription Models)

```dart
class TeacherModel {
  final int id;
  final bool isActive;
  final bool canPrepareLesson;
  final int aiQuotaRemaining;
  final bool isInTrial;
  final bool isSubscribed;
  final DateTime? subscriptionEndsAt;
  final DateTime? trialEndsAt;
  final int trialDaysRemaining;
  final SubscriptionPlan? subscription;

  TeacherModel({
    required this.id,
    required this.isActive,
    required this.canPrepareLesson,
    required this.aiQuotaRemaining,
    required this.isInTrial,
    required this.isSubscribed,
    this.subscriptionEndsAt,
    this.trialEndsAt,
    required this.trialDaysRemaining,
    this.subscription,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      isActive: json['is_active'] ?? json['active'] ?? true,
      canPrepareLesson: json['can_prepare_lesson'] ?? false,
      aiQuotaRemaining: json['ai_quota_remaining'] ?? 0,
      isInTrial: json['is_in_trial'] ?? false,
      isSubscribed: json['is_subscribed'] ?? false,
      subscriptionEndsAt: json['subscription_ends_at'] != null
          ? DateTime.tryParse(json['subscription_ends_at'])
          : null,
      trialEndsAt: json['trial_ends_at'] != null 
          ? DateTime.tryParse(json['trial_ends_at']) 
          : null,
      trialDaysRemaining: json['trial_days_remaining'] ?? 0,
      subscription: json['subscription'] != null 
          ? SubscriptionPlan.fromJson(json['subscription']) 
          : null,
    );
  }

  // ─── Helpers لعرض بيانات الخطة والانتهاء للمستخدم ───

  /// تاريخ انتهاء الصلاحية الفعلي (سواء للاشتراك المدفوع أو التجربة)
  DateTime? get effectiveEndsAt => isSubscribed ? subscriptionEndsAt : trialEndsAt;

  /// حساب الأيام المتبقية ديناميكياً لتجنب ثبات الرقم عند بقاء التطبيق مفتوحاً
  int get dynamicDaysRemaining {
    final endsAt = effectiveEndsAt;
    if (endsAt == null) return 0;
    final now = DateTime.now();
    if (endsAt.isBefore(now)) return 0;
    return (endsAt.difference(now).inHours / 24).ceil();
  }

  /// هل انتهت الصلاحية تماماً؟
  bool get isExpired {
    if (isSubscribed) {
      return subscriptionEndsAt != null && subscriptionEndsAt!.isBefore(DateTime.now());
    }
    return !isInTrial;
  }

  /// عنوان الخطة الحالي المعروض في الواجهة
  String get planTitle {
    if (isSubscribed) return subscription?.name ?? 'اشتراك مدفوع';
    if (isInTrial) return 'تجربة مجانية (7 أيام)';
    return 'انتهت التجربة';
  }

  /// نص موعد الانتهاء المعروض للمستخدم
  String get expirationSubtitle {
    final endsAt = effectiveEndsAt;
    if (endsAt == null) return 'بدون تاريخ انتهاء';
    final formattedDate = "${endsAt.year}/${endsAt.month.toString().padLeft(2, '0')}/${endsAt.day.toString().padLeft(2, '0')}";
    
    if (isSubscribed) {
      return 'ينتهي في $formattedDate (متبقي $dynamicDaysRemaining يوم)';
    }
    if (isInTrial) {
      return 'تنتهي في $formattedDate (متبقي $dynamicDaysRemaining ${dynamicDaysRemaining == 1 ? "يوم" : "أيام"})';
    }
    return 'انتهت الصلاحية في $formattedDate';
  }
}

class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final double price;
  final int lessonLimitPerDay;
  final int aiQuotaPerMonth;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.lessonLimitPerDay,
    required this.aiQuotaPerMonth,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      lessonLimitPerDay: json['lesson_limit_per_day'] ?? 0,
      aiQuotaPerMonth: json['ai_quota_per_month'] ?? 0,
    );
  }

  bool get isFreePlan => slug == 'free' || price == 0.0;
}
```

---

## 6. حساب الأيام المتبقية وتنسيق التاريخ

> ⚠️ **تنبيه هام:** لا تعتمد على قيمة `trial_days_remaining` المخزنة محلياً عند تسجيل الدخول لأنها تصبح قديمة مع مرور الأيام. استخدم `dynamicDaysRemaining` المحسوبة من `DateTime.now()` وتاريخ `trial_ends_at` أو `subscription_ends_at`.

---

## 7. الواجهات والمكونات المطلوبة في تطبيق الموبايل

### 1) كارت الخطة في الملف الشخصي / الإعدادات (Profile / Settings Card)

```dart
class SubscriptionInfoCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback onUpgradeTap;

  const SubscriptionInfoCard({
    super.key,
    required this.teacher,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscribed = teacher.isSubscribed;
    final isInTrial = teacher.isInTrial;
    final isExpired = teacher.isExpired;

    final Color badgeBg = isSubscribed
        ? const Color(0xFFEAF7F2)
        : (isInTrial ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2));
    final Color badgeText = isSubscribed
        ? const Color(0xFF0E7A5E)
        : (isInTrial ? const Color(0xFFB45309) : const Color(0xFFDC2626));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDEEE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSubscribed ? Icons.bolt : (isInTrial ? Icons.hourglass_top : Icons.lock_clock),
                    color: badgeText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    teacher.planTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSubscribed ? 'نشط' : (isInTrial ? 'تجربة' : 'منتهي'),
                  style: TextStyle(color: badgeText, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  teacher.expirationSubtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (!isSubscribed) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradeTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E7A5E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  isInTrial ? 'ترقية الخطة الآن ⚡' : 'اشترك لمتابعة الاستخدام ⚡',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 2) شريط التنبيه العلوي (Trial Banner Widget)
- **في التجربة (`isInTrial`):** شريط أخضر/كهرماني `"🎉 متبقي $days أيام على التجربة المجانية [اشترك الآن]"`
- **في اليوم الأخير (`days <= 1`):** `"⚠️ آخر يوم في تجربتك المجانية! [اشترك الآن]"`
- **انتهت التجربة (`isExpired`):** شريط أحمر `"⏰ انتهت فترتك التجريبية المجانية. [اشترك الآن]"`
- **مشترك مدفوع (`isSubscribed`):** مخفي.

### 3) نافذة الترقية عند الخطأ 402 (Upgrade BottomSheet)
تُفتح تلقائياً عند اعتراض كود `402` لتوجيه المعلم لشاشة الدفع.

---

## 8. معالجة الأخطاء عبر Dio Interceptor

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SubscriptionInterceptor extends Interceptor {
  final GlobalKey<NavigatorState> navigatorKey;

  SubscriptionInterceptor({required this.navigatorKey});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 402) {
      final data = err.response?.data;
      final code = data is Map ? data['code'] : null;
      final message = data is Map ? data['message'] : 'يرجى ترقية اشتراكك للمتابعة';

      final context = navigatorKey.currentContext;
      if (context != null) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => UpgradePromptBottomSheet(
            code: code,
            message: message,
          ),
        );
      }
    }
    super.onError(err, handler);
  }
}
```

---

## 📌 ملخص التحقق للاختبار (QA Checklist)

- [ ] **تسجيل حساب جديد:** المعلم يحصل على 7 أيام تجربة (`is_in_trial: true`).
- [ ] **العد التنازلي:** الأيام تتناقص تلقائياً كل 24 ساعة من تاريخ `trial_ends_at`.
- [ ] **عرض موعد الانتهاء:** شاشة الحساب تعرض تاريخ الانتهاء الدقيق مع عدد الأيام المتبقية.
- [ ] **حساب منتهي التجربة (`expired@moeen.sa`):** حظر أي تحضير أو توليد برمز 402 وفتح نافذة الاشتراك.
- [ ] **حساب مشترك (`subscribed@moeen.sa`):** عرض تاريخ انتهاء الاشتراك الفعلي واختفاء شريط التجربة.
