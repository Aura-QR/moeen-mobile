import 'package:moean/core/models/user_model.dart';
import 'package:moean/core/models/teacher_model.dart';

class LoginResponse {
  final UserModel user;
  final String token;
  final TeacherModel? teacher;
  final bool madrasatiConnected;

  /// The Madrasati school ID extracted from the login response.
  /// Populated when [madrasatiConnected] is true.
  /// Needed for HeadlessWebView session refresh.
  final String? madrasatiSchoolId;

  LoginResponse({
    required this.user,
    required this.token,
    this.teacher,
    required this.madrasatiConnected,
    this.madrasatiSchoolId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Extract school_id from the nested madrasati object
    final madrasatiMap = json['madrasati'] as Map<String, dynamic>?;
    final schoolId = madrasatiMap?['school_id'] as String? ??
        madrasatiMap?['real_school_id'] as String? ??
        madrasatiMap?['school_madrasati_id'] as String?;

    return LoginResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'] as String,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'])
          : null,
      madrasatiConnected: json['madrasati_connected'] as bool? ?? false,
      madrasatiSchoolId: schoolId,
    );
  }
}
