import 'dart:convert';
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
  static dynamic _decodeData(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  static Future<Either<String, RegisterResponse>> registerUser(RegisterRequest request) async {
    final response = await DioHelper.postData(
      url: registerApi,
      data: request.toJson(),
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(RegisterResponse.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, LoginResponse>> loginUser(LoginRequest request) async {
    final response = await DioHelper.postData(
      url: loginApi,
      data: request.toJson(),
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(LoginResponse.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, UserModel>> getMe() async {
    final response = await DioHelper.getData(
      url: meApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) {
        final data = _decodeData(res.data);
        return Right(UserModel.fromJson(data['user'] ?? data));
      },
    );
  }

  static Future<Either<String, ProfileModel>> getProfile() async {
    final response = await DioHelper.getData(
      url: meApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(ProfileModel.fromJson(_decodeData(res.data))),
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

  static Future<Either<String, bool>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await DioHelper.patchData(
      url: changePasswordApi,
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
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
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
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
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
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
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
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
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
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
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  // --- Contact API (Teacher) ---

  static Future<Either<String, Map<String, dynamic>>> getContactTypes() async {
    final response = await DioHelper.getData(
      url: contactTypesApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> submitContactRequest({
    required String name,
    required String email,
    String? phone,
    required String type,
    required String message,
  }) async {
    final response = await DioHelper.postData(
      url: contactApi,
      data: {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'type': type,
        'message': message,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getMyContactTickets() async {
    final response = await DioHelper.getData(
      url: contactMyApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getMyContactTicketDetails({
    required int id,
  }) async {
    final response = await DioHelper.getData(
      url: '$contactMyApi/$id',
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> replyContactTicket({
    required int id,
    required String body,
  }) async {
    final response = await DioHelper.postData(
      url: '$contactMyApi/$id/reply',
      data: {
        'body': body,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  // --- Admin Contact API ---

  static Future<Either<String, Map<String, dynamic>>> getAdminContactStats() async {
    final response = await DioHelper.getData(
      url: adminContactStatsApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getAdminContactTickets({
    String? status,
    String? type,
    String? search,
    int? hasUnread,
    int perPage = 20,
    int page = 1,
  }) async {
    final query = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (hasUnread != null) query['has_unread'] = hasUnread;

    final response = await DioHelper.getData(
      url: adminContactApi,
      query: query,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getAdminContactTicketDetails({
    required int id,
  }) async {
    final response = await DioHelper.getData(
      url: '$adminContactApi/$id',
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> updateAdminContactTicket({
    required int id,
    String? status,
    String? adminNotes,
  }) async {
    final response = await DioHelper.patchData(
      url: '$adminContactApi/$id',
      data: {
        if (status != null) 'status': status,
        if (adminNotes != null) 'admin_notes': adminNotes,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> replyAdminContactTicket({
    required int id,
    required String body,
  }) async {
    final response = await DioHelper.postData(
      url: '$adminContactApi/$id/reply',
      data: {
        'body': body,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, bool>> deleteAdminContactTicket({
    required int id,
  }) async {
    final response = await DioHelper.deleteData(
      url: '$adminContactApi/$id',
    );

    return response.fold(
      (error) => Left(error),
      (res) => const Right(true),
    );
  }

  // --- Educational Reports API ---

  static Future<Either<String, Map<String, dynamic>>> generateEducationalReport({
    required String reportType,
    required String grade,
    required dynamic subject,
    required List<String> selectedLessons,
  }) async {
    final response = await DioHelper.postData(
      url: educationalReportApi,
      data: {
        'reportType': reportType,
        'grade': grade,
        'subject': subject,
        'selectedLessons': selectedLessons,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }
}
