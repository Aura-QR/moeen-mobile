import 'package:moean/core/models/user_model.dart';

class LoginResponseModel {
  final String message;
  final String token;
  final UserModel user;
  final List<String> permissions;

  LoginResponseModel({
    required this.message,
    required this.token,
    required this.user,
    required this.permissions,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel.fromJson(json['user']);

    return LoginResponseModel(
      message: json['message'] as String,
      token: json['token'] as String,
      user: user.copyWith(
        permissions: List<String>.from(json['permissions'] ?? []),
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
}
