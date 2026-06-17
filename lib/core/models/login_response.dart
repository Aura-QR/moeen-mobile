import 'package:moean/core/models/user_model.dart';
import 'package:moean/core/models/teacher_model.dart';

class LoginResponse {
  final UserModel user;
  final String token;
  final TeacherModel? teacher;
  final bool madrasatiConnected;

  LoginResponse({
    required this.user,
    required this.token,
    this.teacher,
    required this.madrasatiConnected,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'] as String,
      teacher: json['teacher'] != null ? TeacherModel.fromJson(json['teacher']) : null,
      madrasatiConnected: json['madrasati_connected'] as bool? ?? false,
    );
  }
}
