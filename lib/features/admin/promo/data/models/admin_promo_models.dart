class AdminPromoCodeModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final bool isActive;
  final String userTarget;
  final int? maxRedemptions;
  final int? maxRedemptionsPerUser;
  final int redemptionsCount;
  final String? startsAt;
  final String? expiresAt;

  const AdminPromoCodeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
    required this.userTarget,
    this.maxRedemptions,
    this.maxRedemptionsPerUser,
    required this.redemptionsCount,
    this.startsAt,
    this.expiresAt,
  });

  factory AdminPromoCodeModel.fromJson(Map<String, dynamic> json) {
    return AdminPromoCodeModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'percentage',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      userTarget: json['user_target']?.toString() ?? 'all',
      maxRedemptions: json['max_redemptions'] != null ? int.tryParse(json['max_redemptions'].toString()) : null,
      maxRedemptionsPerUser: json['max_redemptions_per_user'] != null ? int.tryParse(json['max_redemptions_per_user'].toString()) : null,
      redemptionsCount: int.tryParse(json['redemptions_count']?.toString() ?? '0') ?? 0,
      startsAt: json['starts_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }
}

class AdminReferralStatsModel {
  final int totalReferralLinks;
  final int totalRegistrations;
  final int qualifiedReferrals;
  final int rewardsGenerated;
  final int rewardsUsed;
  final double conversionRatePct;

  const AdminReferralStatsModel({
    required this.totalReferralLinks,
    required this.totalRegistrations,
    required this.qualifiedReferrals,
    required this.rewardsGenerated,
    required this.rewardsUsed,
    required this.conversionRatePct,
  });

  factory AdminReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminReferralStatsModel(
      totalReferralLinks: int.tryParse(json['total_referral_links']?.toString() ?? '0') ?? 0,
      totalRegistrations: int.tryParse(json['total_registrations']?.toString() ?? '0') ?? 0,
      qualifiedReferrals: int.tryParse(json['qualified_referrals']?.toString() ?? '0') ?? 0,
      rewardsGenerated: int.tryParse(json['rewards_generated']?.toString() ?? '0') ?? 0,
      rewardsUsed: int.tryParse(json['rewards_used']?.toString() ?? '0') ?? 0,
      conversionRatePct: double.tryParse(json['conversion_rate_pct']?.toString() ?? '0') ?? 0.0,
    );
  }
}
