import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';

import 'package:moean/core/models/login_request.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moean/core/models/register_request.dart';
import 'package:moean/core/models/register_response.dart';
import 'package:moean/core/models/login_response.dart';
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

  // --- Payment & Subscription API ---

  static Future<Either<String, List<dynamic>>> getSubscriptions() async {
    final response = await DioHelper.getData(url: subscriptionsApi);
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as List<dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getCurrentSubscription() async {
    final response = await DioHelper.getData(url: subscriptionCurrentApi);
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> createOrder(int serviceId) async {
    final response = await DioHelper.postData(
      url: ordersApi,
      data: {'service_id': serviceId},
    );
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getOrderCheckout(int orderId) async {
    final response = await DioHelper.postData(url: '$ordersApi/$orderId/pay');
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> savePaymentReference({
    required int orderId,
    required String moyasarPaymentId,
  }) async {
    final response = await DioHelper.postData(
      url: paymentsSaveReferenceApi,
      data: {
        'order_id': orderId,
        'moyasar_payment_id': moyasarPaymentId,
      },
    );
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> verifyPayment(String paymentId) async {
    final response = await DioHelper.getData(
      url: paymentsVerifyApi,
      query: {'id': paymentId},
    );
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getBankTransferInfo() async {
    final response = await DioHelper.getData(url: paymentsBankTransferInfoApi);
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> uploadManualReceipt({
    required int orderId,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'order_id': orderId.toString(),
      'receipt': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await DioHelper.postData(
      url: paymentsManualApi,
      data: formData,
    );
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getPaymentHistory() async {
    final response = await DioHelper.getData(url: paymentsHistoryApi);
    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  // ===========================================================================
  // Curriculum APIs (Subjects & Lessons)
  // ===========================================================================

  static Future<Either<Failure, List<CurriculumStageModel>>> getSubjects() async {
    try {
      final responseEither = await DioHelper.getData(url: subjectsApi);
      return responseEither.fold(
        (error) => Left(ServerFailure(error)),
        (response) {
          final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
          return Right(data.map((e) => CurriculumStageModel.fromJson(e)).toList());
        },
      );
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  static Future<Either<Failure, SubjectDetailsModel>> getSubjectLessons(int subjectId) async {
    try {
      final responseEither = await DioHelper.getData(url: subjectLessonsApi(subjectId));
      return responseEither.fold(
        (error) => Left(ServerFailure(error)),
        (response) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return Right(SubjectDetailsModel.fromJson(data));
          }
          return Left(ServerFailure('Invalid data format'));
        },
      );
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  // ===========================================================================
  // Exam Generation
  // ===========================================================================

  static Future<Either<String, Map<String, dynamic>>> generateExam(Map<String, dynamic> request) async {
    try {
      final options = Options(
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 120),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await DioHelper.getDio().post(
        examsGenerateApi,
        data: request,
        options: options,
      );
      
      return Right(_decodeData(response.data) as Map<String, dynamic>);
    } on DioException catch (error) {
      // Return the error so our new repository logic can parse it
      return Left(DioHelper.parseError(error));
      // Actually we will handle DioException in repository, but since api_service returns String, we'll let api_service return error string.
    } catch (e) {
      return Left(e.toString());
    }
  }

  static Future<Either<String, Map<String, dynamic>>> getExam(int id) async {
    final response = await DioHelper.getData(
      url: examDetailsApi(id),
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> updateExamPoints(int id, Map<String, dynamic> request) async {
    final response = await DioHelper.patchData(
      url: examPointsApi(id),
      data: request,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getMyExams({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await DioHelper.getData(
      url: examsApi,
      query: query,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> publishExam(int id) async {
    final response = await DioHelper.postData(
      url: examPublishApi(id),
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, bool>> deleteExam(int id) async {
    final response = await DioHelper.deleteData(
      url: examDetailsApi(id),
    );

    return response.fold(
      (error) => Left(error),
      (res) => const Right(true),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getExams({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;

    final response = await DioHelper.getData(
      url: examsApi,
      query: query,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> addManualQuestion(Map<String, dynamic> request) async {
    final response = await DioHelper.postData(
      url: questionsApi,
      data: request,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getLessonQuestions({
    required int lessonId,
    String? type,
    String? difficulty,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (difficulty != null && difficulty.isNotEmpty) query['difficulty'] = difficulty;

    final response = await DioHelper.getData(
      url: lessonQuestionsApi(lessonId),
      query: query,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> getMyQuestions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? difficulty,
    String? reviewStatus,
    int? lessonId,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (difficulty != null && difficulty.isNotEmpty) query['difficulty'] = difficulty;
    if (reviewStatus != null && reviewStatus.isNotEmpty) query['review_status'] = reviewStatus;
    if (lessonId != null) query['lesson_id'] = lessonId;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await DioHelper.getData(
      url: questionsMyApi,
      query: query,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }

  static Future<Either<String, Map<String, dynamic>>> updateCustomQuestion(int id, Map<String, dynamic> data) async {
    final response = await DioHelper.patchData(
      url: questionUpdateApi(id),
      data: data,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(_decodeData(res.data) as Map<String, dynamic>),
    );
  }
}

