import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

class SubscriptionCurrentModel {
  final SubscriptionPlanModel? plan;
  final bool isInTrial;
  final bool isSubscribed;
  final DateTime? trialEndsAt;
  final DateTime? subscriptionEndsAt;
  final int trialDaysRemaining;
  final SubscriptionUsageModel usage;

  SubscriptionCurrentModel({
    this.plan,
    required this.isInTrial,
    required this.isSubscribed,
    this.trialEndsAt,
    this.subscriptionEndsAt,
    required this.trialDaysRemaining,
    required this.usage,
  });

  factory SubscriptionCurrentModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCurrentModel(
      plan: json['plan'] != null ? SubscriptionPlanModel.fromJson(json['plan']) : null,
      isInTrial: json['is_in_trial'] as bool? ?? false,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.tryParse(json['trial_ends_at']) : null,
      subscriptionEndsAt: json['subscription_ends_at'] != null ? DateTime.tryParse(json['subscription_ends_at']) : null,
      trialDaysRemaining: json['trial_days_remaining'] as int? ?? 0,
      usage: SubscriptionUsageModel.fromJson(
        json['usage'] is Map<String, dynamic> ? json['usage'] as Map<String, dynamic> : {},
      ),
    );
  }

  /// تاريخ انتهاء الصلاحية الفعلي (سواء للاشتراك المدفوع أو التجربة)
  DateTime? get effectiveEndsAt => isSubscribed ? subscriptionEndsAt : trialEndsAt;

  int get dynamicTrialDaysRemaining => dynamicDaysRemaining;

  /// حساب الأيام المتبقية ديناميكياً
  int get dynamicDaysRemaining {
    final endsAt = effectiveEndsAt;
    if (endsAt == null) return 0;
    final now = DateTime.now();
    if (endsAt.isBefore(now)) return 0;
    return (endsAt.difference(now).inHours / 24).ceil();
  }

  bool get isLastTrialDay => isInTrial && dynamicTrialDaysRemaining <= 1;

  bool get isSubscriptionExpired {
    if (isSubscribed && subscriptionEndsAt != null) {
      return subscriptionEndsAt!.isBefore(DateTime.now());
    }
    return false;
  }

  /// هل انتهت الصلاحية تماماً؟
  bool get isExpired {
    if (isSubscribed) {
      return subscriptionEndsAt != null && subscriptionEndsAt!.isBefore(DateTime.now());
    }
    return !isInTrial || dynamicTrialDaysRemaining <= 0;
  }

  /// عنوان الخطة الحالي
  String get planTitle {
    if (isSubscribed) return plan?.name ?? 'اشتراك مدفوع';
    if (isInTrial) return 'تجربة مجانية (7 أيام)';
    return 'انتهت التجربة';
  }

  /// نص موعد الانتهاء
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

class SubscriptionUsageModel {
  final int aiUsedThisMonth;
  final int lessonsPreparedToday;
  final int aiRemaining;
  final int lessonsRemainingToday;

  SubscriptionUsageModel({
    required this.aiUsedThisMonth,
    required this.lessonsPreparedToday,
    required this.aiRemaining,
    required this.lessonsRemainingToday,
  });

  factory SubscriptionUsageModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionUsageModel(
      aiUsedThisMonth: json['ai_used_this_month'] as int? ?? 0,
      lessonsPreparedToday: json['lessons_prepared_today'] as int? ?? 0,
      aiRemaining: json['ai_remaining'] as int? ?? 0,
      lessonsRemainingToday: json['lessons_remaining_today'] as int? ?? 0,
    );
  }
}
