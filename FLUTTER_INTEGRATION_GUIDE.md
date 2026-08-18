# 📱 دليل تكامل نظام التجربة المجانية والاشتراكات (Flutter Integration Guide)

> هذا الدليل موجه لمطور **Flutter (Mobile App)** لتوضيح كيفية التعامل مع نظام الفترة التجريبية المجانية (7 أيام)، قيود الاستخدام (التحضير والذكاء الاصطناعي)، ونقاط نهاية الـ API، مع النماذج البرمجية (Dart) والواجهات المقترحة.

---

## 📑 جدول المحتويات
1. [نظرة عامة على منطق العمل (Business Logic)](#1-نظرة-عامة-على-منطق-العمل)
2. [تحديثات استجابة الـ Authentication](#2-تحديثات-استجابة-الـ-authentication)
3. [نقاط النهاية للاشتراكات والاستخدام (Subscription APIs)](#3-نقاط-النهاية-للاشتراكات-والاستخدام)
4. [معالجة استجابات الخطأ (HTTP 402 Error Contract)](#4-معالجة-استجابات-الخطأ-http-402)
5. [نموذج Dart المقترح (Teacher & Subscription Models)](#5-نموذج-dart-المقترح)
6. [حساب الأيام المتبقية ديناميكياً (Dynamic Countdown)](#6-حساب-الأيام-المتبقية-ديناميكياً)
7. [الواجهات والمكونات المطلوبة في تطبيق الموبايل (UI Components)](#7-الواجهات-والمكونات-المطلوبة-في-تطبيق-الموبايل)
8. [Interceptor / Repository Error Handling في Flutter](#8-معالجة-الأخطاء-عبر-dio-interceptor)

---

## 1. نظرة عامة على منطق العمل

| الحالة (Status) | الشرط في الباك إند | السلوك في التطبيق |
| :--- | :--- | :--- |
| **في التجربة المجانية (Trial)** | `is_in_trial == true` و `trial_ends_at > now()` | • التحضير متاح (15 تحضير/يوم).<br>• الذكاء الاصطناعي متاح (200 توليد/شهر).<br>• يظهر شريط أخضر/برتقالي بالأيام المتبقية. |
| **مشترك باشتراك مدفوع (Subscribed)** | `is_subscribed == true` | • صلاحية كاملة حسب حدود الخطة المشترك بها.<br>• شريط التجربة مخفي تماماً. |
| **انتهت التجربة ولم يشترك (Expired)** | `is_in_trial == false` و `is_subscribed == false` | • **حظر كامل** لعمليات التحضير والتقارير والاختبارات والعروض برمز `402`.<br>• يظهر تنبيه ثابت/نافذة منبثقة بانتهاء التجربة وزر للاشتراك. |

---

## 2. تحديثات استجابة الـ Authentication

في جميع مسارات المصادقة:
- `POST /api/login`
- `POST /api/register`
- `GET /api/me`

يحتوي كائن المعلم `teacher` داخل الاستجابة على الحقول الجديدة التالية:

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

---

## 3. نقاط النهاية للاشتراكات والاستخدام

### 1) جلب حالة الاشتراك والاستخدام الحالي
`GET /api/subscription/current`
- **Headers:** `Authorization: Bearer <TOKEN>`
- **Response (200 OK - لمعلم في التجربة أو مشترك):**
```json
{
  "plan": {
    "id": 1,
    "name": "الخطة المجانية",
    "slug": "free",
    "price": 0,
    "lesson_limit_per_day": 15,
    "ai_quota_per_month": 200
  },
  "is_in_trial": true,
  "trial_ends_at": "2026-08-25T13:00:00.000000Z",
  "trial_days_remaining": 7,
  "usage": {
    "ai_used_this_month": 5,
    "lessons_prepared_today": 2,
    "ai_remaining": 195,
    "lessons_remaining_today": 13
  }
}
```
- **Response (402 Payment Required - لمعلم منتهي التجربة):**
```json
{
  "message": "انتهت فترتك التجريبية. اشترك للاستمرار في الاستخدام.",
  "code": "trial_expired",
  "status": 402,
  "action": "subscribe",
  "is_in_trial": false,
  "trial_ends_at": "2026-08-17T12:00:00.000000Z",
  "trial_days_remaining": 0,
  "details": {
    "upgrade_url": "/checkout"
  }
}
```

### 2) جلب باقات الاشتراك المتاحة
`GET /api/subscriptions` (لا يتطلب مصادقة)
- يُرجع قائمة الخطط المتاحة (فصلي، سنوي، ...إلخ) لعرضها في شاشة الاشتراكات (Pricing Screen).

### 3) إنشاء طلب ترقية / اشتراك
`POST /api/subscription/upgrade`
- **Body:**
```json
{
  "plan_slug": "semester",
  "promo_code": "DISCOUNT10"
}
```
- **Response (201 Created):** يُرجع كائن الطلب `order` مع معرف الطلب ورابط/بوابة الدفع.

---

## 4. معالجة استجابات الخطأ (HTTP 402)

عند استدعاء أي من المسارات المحمية:
1. `POST /api/prepare` (التحضير الفوري)
2. `POST /api/prepare/bulk` (التحضير المتعدد)
3. `POST /api/reports/educational/generate` (توليد التقارير التعليمية)
4. `POST /api/exams/generate` (توليد الاختبارات)
5. `POST /api/lessons/{id}/presentation/generate` (توليد العروض التقديمية)

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

## 5. نموذج Dart المقترح (Teacher & Subscription Models)

```dart
class TeacherModel {
  final int id;
  final bool isActive;
  final bool canPrepareLesson;
  final int aiQuotaRemaining;
  final bool isInTrial;
  final bool isSubscribed;
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
    this.trialEndsAt,
    required this.trialDaysRemaining,
    this.subscription,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      isActive: json['is_active'] ?? true,
      canPrepareLesson: json['can_prepare_lesson'] ?? false,
      aiQuotaRemaining: json['ai_quota_remaining'] ?? 0,
      isInTrial: json['is_in_trial'] ?? false,
      isSubscribed: json['is_subscribed'] ?? false,
      trialEndsAt: json['trial_ends_at'] != null 
          ? DateTime.tryParse(json['trial_ends_at']) 
          : null,
      trialDaysRemaining: json['trial_days_remaining'] ?? 0,
      subscription: json['subscription'] != null 
          ? SubscriptionPlan.fromJson(json['subscription']) 
          : null,
    );
  }

  /// حساب دقيق للأيام المتبقية ديناميكياً لتجنب ثبات الرقم عند بقاء التطبيق مفتوحاً
  int get dynamicTrialDaysRemaining {
    if (!isInTrial || trialEndsAt == null) return 0;
    final now = DateTime.now();
    if (trialEndsAt!.isBefore(now)) return 0;
    final diff = trialEndsAt!.difference(now);
    return (diff.inHours / 24).ceil();
  }

  /// هل المستخدم في اليوم الأخير من التجربة؟
  bool get isLastTrialDay => isInTrial && dynamicTrialDaysRemaining <= 1;

  /// هل انتهت التجربة وليس لديه اشتراك مدفوع؟
  bool get isTrialExpired => !isSubscribed && !isInTrial;
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

## 6. حساب الأيام المتبقية ديناميكياً

> ⚠️ **ملاحظة هامة جداً للمطور:**
> لا تعتمد فقط على قيمة `trial_days_remaining` المخزنة محلياً عند تسجيل الدخول؛ لأن المعلم قد يترك التطبيق مفتوحاً لأيام دون إعادة تسجيل الدخول.
> دائماً استخدم تاريخ `trialEndsAt` مع الوقت الحالي `DateTime.now()`:

```dart
int calculateRemainingDays(DateTime? trialEndsAt) {
  if (trialEndsAt == null) return 0;
  final difference = trialEndsAt.difference(DateTime.now());
  if (difference.isNegative) return 0;
  return (difference.inHours / 24).ceil();
}
```

---

## 7. الواجهات والمكونات المطلوبة في تطبيق الموبايل

### 1) شريط التنبيه العلوي (Trial Banner Widget)
يُعرض في أعلى الشاشة الرئيسية أو أعلى كل شاشة رئيسية (Dashboard, Schedule, Reports):
- **حالة التجربة (`isInTrial`):**
  - شريط أخضر/زمردي: `"🎉 أنت في التجربة المجانية — متبقي $days أيام [اشترك الآن]"`
  - في اليوم الأخير (`days <= 1`): شريط بلون كهرماني/تحذيري: `"⚠️ اليوم هو آخر يوم في تجربتك المجانية! [اشترك الآن]"`.
- **حالة انتهاء التجربة (`isTrialExpired`):**
  - شريط أحمر بارز غير قابل للإغلاق: `"⏰ انتهت فترتك التجريبية المجانية. [اشترك الآن]"`.
- **حالة المشترك (`isSubscribed`):**
  - إخفاء الشريط بالكامل.

### 2) نافذة الترقية المنبثقة (Upgrade BottomSheet / Dialog)
عند استلام خطأ `402 trial_expired` أو `quota_exceeded` من أي عملية:
- فتح BottomSheet يعرض:
  - أيقونة قفل 🔒 أو تاج 👑
  - رسالة الخطأ الواردة من السيرفر.
  - مميزات الاشتراك (تحضير غير محدود، توليد ذكاء اصطناعي، عروض تقديمية واختبارات).
  - زر عريض **"عرض باقات الاشتراك"** يوجه لشاشة الاشتراكات والدفع.

### 3) شاشة التسجيل (Registration Screen)
- توضيح بجانب زر التسجيل أو بطاقة توضيحية:
  `"✨ سجل الآن واحصل على تجربة مجانية كاملة لمدة 7 أيام بدون أي رسوم."`

---

## 8. معالجة الأخطاء عبر Dio Interceptor

يمكنك إضافة معالج أخطاء مركزي (Interceptor) في Flutter لفتح شاشة الدفع أو الـ BottomSheet تلقائياً عند تلقي رمز `402`:

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

- [ ] **تسجيل حساب جديد:** التحقق من حصول المعلم على 7 أيام تجربة وظهور `is_in_trial: true`.
- [ ] **العد التنازلي:** التأكد من تناقص الأيام تلقائياً كل 24 ساعة.
- [ ] **حساب منتهي التجربة (`expired@moeen.sa`):** التأكد من حظره برمز `402` عند طلب تحضير، تقرير، اختبار، أو عرض وفتح نافذة الاشتراك.
- [ ] **حساب مشترك (`subscribed@moeen.sa`):** التأكد من عمل جميع الميزات واختفاء شرائط التجربة.
- [ ] **استهلاك الحصص:** التأكد من تحديث العداد عند كل توليد بالذكاء الاصطناعي.
