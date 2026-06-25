import 'package:moean/core/models/user_model.dart';

class ProfileModel {
  final UserModel user;
  final bool madrasatiConnected;
  final int? aiQuotaRemaining;
  final String? subscriptionName;
  final String? phone;
  final String? role;

  ProfileModel({
    required this.user,
    required this.madrasatiConnected,
    this.aiQuotaRemaining,
    this.subscriptionName,
    this.phone,
    this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;
    return ProfileModel(
      user: UserModel.fromJson(userJson),
      madrasatiConnected: json['madrasati_connected'] as bool? ?? false,
      aiQuotaRemaining: json['teacher']?['ai_quota_remaining'] as int?,
      subscriptionName: json['teacher']?['subscription']?['name'] as String?,
      phone: userJson['phone'] as String?,
      role: userJson['role'] as String?,
    );
  }
}
