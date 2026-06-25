import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';

import 'package:moean/core/models/login_request.dart';
import 'package:moean/core/models/login_response.dart';
import 'package:moean/core/models/register_request.dart';
import 'package:moean/core/models/register_response.dart';
import 'package:moean/core/models/user_model.dart';
import 'package:moean/core/models/profile_model.dart';

class ApiService {
  static Future<Either<String, RegisterResponse>> registerUser(RegisterRequest request) async {
    final response = await DioHelper.postData(
      url: registerApi,
      data: request.toJson(),
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(RegisterResponse.fromJson(res.data)),
    );
  }

  static Future<Either<String, LoginResponse>> loginUser(LoginRequest request) async {
    final response = await DioHelper.postData(
      url: loginApi,
      data: request.toJson(),
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(LoginResponse.fromJson(res.data)),
    );
  }

  static Future<Either<String, UserModel>> getMe() async {
    final response = await DioHelper.getData(
      url: meApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(UserModel.fromJson(res.data['user'] ?? res.data)),
    );
  }

  static Future<Either<String, ProfileModel>> getProfile() async {
    final response = await DioHelper.getData(
      url: meApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(ProfileModel.fromJson(res.data)),
    );
  }

  static Future<Either<String, bool>> logout() async {
    final response = await DioHelper.postData(
      url: logoutApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => const Right(true),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getSchedule({
    required String weekDate,
  }) async {
    /*
    try {
      // Using Dio directly to avoid base URL conflict in DioHelper for the absolute mock URL
      final dio = Dio();
      final response = await dio.get('https://n8n.qraura.shop/webhook/mock-schedule');
      
      // Ensure we pass back a Map<String, dynamic>
      final data = response.data;
      if (data is String) {
        return Right(jsonDecode(data) as Map<String, dynamic>);
      }
      return Right(data as Map<String, dynamic>);
    } catch (e) {
      return Left(e.toString());
    }
    */

    final response = await DioHelper.getData(
      url: scheduleApi,
      query: {'week': weekDate},
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(res.data as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> syncSchedule({
    required String weekDate,
  }) async {
    final response = await DioHelper.getData(
      url: madrasatiScheduleApi,
      query: {'week_date': weekDate},
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(res.data as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> prepareLesson({
    required int lessonId,
    required int subjectId,
    required String classroomId,
    required String schoolMadrasatiId,
    required String timeTableId,
    required List<String> selectedModules,
    required String encryptedToken,
  }) async {
    final response = await DioHelper.postData(
      url: prepareApi,
      data: {
        'lesson_id': lessonId,
        'subject_id': subjectId,
        'classroom_id': classroomId,
        'school_madrasati_id': schoolMadrasatiId,
        'time_table_id': timeTableId,
        'selected_modules': selectedModules,
        'encrypted_token': encryptedToken,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(res.data as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getAvailableLessons({
    required String weekDate,
  }) async {
    final response = await DioHelper.getData(
      url: '$scheduleApi/available-lessons',
      query: {'week': weekDate},
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(res.data as Map<String, dynamic>),
    );
  }
  static Future<Either<String, Map<String, dynamic>>> checkPreparationStatus({
    required int preparationId,
  }) async {
    final response = await DioHelper.getData(
      url: '$prepareApi/$preparationId/status',
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(res.data as Map<String, dynamic>),
    );
  }
}
