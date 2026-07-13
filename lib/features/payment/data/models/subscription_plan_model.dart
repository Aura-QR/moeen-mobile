class SubscriptionPlanModel {
  final int id;
  final String name;
  final String slug;
  final String price;
  final int aiQuotaPerMonth;
  final int lessonLimitPerDay;
  final Map<String, dynamic> features;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.aiQuotaPerMonth,
    required this.lessonLimitPerDay,
    required this.features,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      aiQuotaPerMonth: json['ai_quota_per_month'] as int? ?? 0,
      lessonLimitPerDay: json['lesson_limit_per_day'] as int? ?? 0,
      features: json['features'] as Map<String, dynamic>? ?? {},
    );
  }
}
