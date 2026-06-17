import 'package:moean/core/models/user_model.dart';
import 'package:moean/core/models/teacher_model.dart';

class RegisterResponse {
  final UserModel user;
  final String token;
  final TeacherModel? teacher;

  RegisterResponse({
    required this.user,
    required this.token,
    this.teacher,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'] as String,
      teacher: json['teacher'] != null ? TeacherModel.fromJson(json['teacher']) : null,
    );
  }
}
