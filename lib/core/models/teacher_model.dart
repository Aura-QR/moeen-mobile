import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

class TeacherModel {
  final int id;
  final int? userId;
  final int? subscriptionId;
  final bool canPrepareLesson;
  final int aiQuotaRemaining;
  final bool isInTrial;
  final bool isSubscribed;
  final DateTime? subscriptionEndsAt;
  final DateTime? trialEndsAt;
  final int trialDaysRemaining;
  final SubscriptionPlanModel? subscription;

  TeacherModel({
    required this.id,
    this.userId,
    this.subscriptionId,
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
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      subscriptionId: json['subscription_id'] as int? ?? (json['subscription'] != null ? json['subscription']['id'] as int? : null),
      canPrepareLesson: json['can_prepare_lesson'] as bool? ?? false,
      aiQuotaRemaining: json['ai_quota_remaining'] as int? ?? 0,
      isInTrial: json['is_in_trial'] as bool? ?? false,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      subscriptionEndsAt: json['subscription_ends_at'] != null
          ? DateTime.tryParse(json['subscription_ends_at'])
          : null,
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.tryParse(json['trial_ends_at']) : null,
      trialDaysRemaining: json['trial_days_remaining'] as int? ?? 0,
      subscription: json['subscription'] != null ? SubscriptionPlanModel.fromJson(json['subscription']) : null,
    );
  }

  /// تاريخ انتهاء الصلاحية الفعلي (سواء للاشتراك المدفوع أو التجربة)
  DateTime? get effectiveEndsAt => isSubscribed ? subscriptionEndsAt : trialEndsAt;

  /// حساب الأيام المتبقية ديناميكياً
  int get dynamicDaysRemaining {
    final endsAt = effectiveEndsAt;
    if (endsAt == null) return 0;
    final now = DateTime.now();
    if (endsAt.isBefore(now)) return 0;
    return (endsAt.difference(now).inHours / 24).ceil();
  }

  int get dynamicTrialDaysRemaining => dynamicDaysRemaining;

  bool get isLastTrialDay => isInTrial && dynamicTrialDaysRemaining <= 1;

  /// هل انتهت الصلاحية تماماً؟
  bool get isExpired {
    if (isSubscribed) {
      return subscriptionEndsAt != null && subscriptionEndsAt!.isBefore(DateTime.now());
    }
    return !isInTrial || dynamicTrialDaysRemaining <= 0;
  }

  bool get isTrialExpired => !isSubscribed && !isInTrial;

  /// عنوان الخطة الحالي
  String get planTitle {
    if (isSubscribed) return subscription?.name ?? 'اشتراك مدفوع';
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'subscription_id': subscriptionId,
    'can_prepare_lesson': canPrepareLesson,
    'ai_quota_remaining': aiQuotaRemaining,
    'is_in_trial': isInTrial,
    'is_subscribed': isSubscribed,
    'subscription_ends_at': subscriptionEndsAt?.toIso8601String(),
    'trial_ends_at': trialEndsAt?.toIso8601String(),
    'trial_days_remaining': trialDaysRemaining,
    if (subscription != null) 'subscription': subscription,
  };
}
