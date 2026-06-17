class TeacherModel {
  final int id;
  final int? userId;
  final int? subscriptionId;
  final bool canPrepareLesson;
  final int aiQuotaRemaining;

  TeacherModel({
    required this.id,
    this.userId,
    this.subscriptionId,
    required this.canPrepareLesson,
    required this.aiQuotaRemaining,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      subscriptionId: json['subscription_id'] as int? ?? (json['subscription'] != null ? json['subscription']['id'] as int? : null),
      canPrepareLesson: json['can_prepare_lesson'] as bool? ?? false,
      aiQuotaRemaining: json['ai_quota_remaining'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'subscription_id': subscriptionId,
    'can_prepare_lesson': canPrepareLesson,
    'ai_quota_remaining': aiQuotaRemaining,
  };
}
