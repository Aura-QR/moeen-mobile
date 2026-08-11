class ReferralRewardModel {
  final int id;
  final String code;
  final double discountValue;
  final String discountType;
  final String? expiresAt;

  const ReferralRewardModel({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.discountType,
    this.expiresAt,
  });

  factory ReferralRewardModel.fromJson(Map<String, dynamic> json) {
    return ReferralRewardModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String? ?? 'percentage',
      expiresAt: json['expires_at'] as String?,
    );
  }
}

class ReferralHistoryItemModel {
  final int id;
  final String referredName;
  final String status;
  final String registeredAt;
  final String? qualifiedAt;

  const ReferralHistoryItemModel({
    required this.id,
    required this.referredName,
    required this.status,
    required this.registeredAt,
    this.qualifiedAt,
  });

  factory ReferralHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryItemModel(
      id: json['id'] as int? ?? 0,
      referredName: json['referred_name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      registeredAt: json['registered_at'] as String? ?? '',
      qualifiedAt: json['qualified_at'] as String?,
    );
  }
}

class ReferralDashboardModel {
  final String referralCode;
  final String referralLink;
  final int maxReferrals;
  final int qualifiedReferrals;
  final int remainingReferrals;
  final int rewardsAvailableCount;
  final List<ReferralRewardModel> rewards;
  final List<ReferralHistoryItemModel> history;

  const ReferralDashboardModel({
    required this.referralCode,
    required this.referralLink,
    required this.maxReferrals,
    required this.qualifiedReferrals,
    required this.remainingReferrals,
    required this.rewardsAvailableCount,
    required this.rewards,
    required this.history,
  });

  factory ReferralDashboardModel.fromJson(Map<String, dynamic> json) {
    final rewardsList = (json['rewards'] as List<dynamic>? ?? [])
        .map((e) => ReferralRewardModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final historyList = (json['history'] as List<dynamic>? ?? [])
        .map((e) => ReferralHistoryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ReferralDashboardModel(
      referralCode: json['referral_code'] as String? ?? '',
      referralLink: json['referral_link'] as String? ?? '',
      maxReferrals: json['max_referrals'] as int? ?? 5,
      qualifiedReferrals: json['qualified_referrals'] as int? ?? 0,
      remainingReferrals: json['remaining_referrals'] as int? ?? 5,
      rewardsAvailableCount: json['rewards_available_count'] as int? ?? 0,
      rewards: rewardsList,
      history: historyList,
    );
  }
}
