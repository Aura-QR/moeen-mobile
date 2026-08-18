import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

class TeacherModel {
  final int id;
  final int? userId;
  final int? subscriptionId;
  final bool canPrepareLesson;
  final int aiQuotaRemaining;
  final bool isInTrial;
  final bool isSubscribed;
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
    this.trialEndsAt,
    required this.trialDaysRemaining,
    this.subscription,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      subscriptionId: json['subscription_id'] as int? ?? (json['subscription'] != null ? json['subscription']['id'] as int? : null),
      canPrepareLesson: json['can_prepare_lesson'] as bool? ?? false,
      aiQuotaRemaining: json['ai_quota_remaining'] as int? ?? 0,
      isInTrial: json['is_in_trial'] as bool? ?? false,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.tryParse(json['trial_ends_at']) : null,
      trialDaysRemaining: json['trial_days_remaining'] as int? ?? 0,
      subscription: json['subscription'] != null ? SubscriptionPlanModel.fromJson(json['subscription']) : null,
    );
  }

  int get dynamicTrialDaysRemaining {
    if (!isInTrial || trialEndsAt == null) return 0;

    final now = DateTime.now();

    if (trialEndsAt!.isBefore(now)) {
      return 0;
    }

    final difference = trialEndsAt!.difference(now);

    return (difference.inHours / 24).ceil();
  }

  bool get isLastTrialDay => isInTrial && dynamicTrialDaysRemaining <= 1;

  bool get isTrialExpired => !isSubscribed && !isInTrial;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'subscription_id': subscriptionId,
    'can_prepare_lesson': canPrepareLesson,
    'ai_quota_remaining': aiQuotaRemaining,
    'is_in_trial': isInTrial,
    'is_subscribed': isSubscribed,
    'trial_ends_at': trialEndsAt?.toIso8601String(),
    'trial_days_remaining': trialDaysRemaining,
    if (subscription != null) 'subscription': subscription, // Depends on SubscriptionPlanModel having toJson if needed, but not strictly required if we only use it in memory
  };
}
