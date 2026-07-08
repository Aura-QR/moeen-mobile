import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/models/admin_teacher_model.dart';
import 'dart:convert';

class AdminTeachersRepository {
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

  static Future<Either<String, AdminTeacherPaginationModel>> getTeachers({
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final response = await DioHelper.getData(
      url: adminTeachersApi,
      query: queryParams,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(AdminTeacherPaginationModel.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, List<AdminTeacherSubscriptionModel>>> getSubscriptions() async {
    final response = await DioHelper.getData(
      url: subscriptionsApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) {
        final data = _decodeData(res.data) as List;
        return Right(data.map((e) => AdminTeacherSubscriptionModel.fromJson(e)).toList());
      },
    );
  }

  static Future<Either<String, AdminTeacherModel>> createTeacher({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int subscriptionId,
  }) async {
    final response = await DioHelper.postData(
      url: adminTeachersApi,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'subscription_id': subscriptionId,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(AdminTeacherModel.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, AdminTeacherModel>> updateTeacher({
    required int id,
    String? name,
    String? email,
    String? phone,
    bool? active,
    int? subscriptionId,
    String? subscriptionEndsAt,
    String? password,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (active != null) data['active'] = active;
    if (subscriptionId != null) data['subscription_id'] = subscriptionId;
    if (subscriptionEndsAt != null) data['subscription_ends_at'] = subscriptionEndsAt;
    if (password != null) data['password'] = password;

    final response = await DioHelper.patchData(
      url: '$adminTeachersApi/$id',
      data: data,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(AdminTeacherModel.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, AdminTeacherModel>> renewSubscription({
    required int id,
    int? subscriptionId,
    int? months,
  }) async {
    final data = <String, dynamic>{};
    if (subscriptionId != null) data['subscription_id'] = subscriptionId;
    if (months != null) data['months'] = months;

    final response = await DioHelper.postData(
      url: '$adminTeachersApi/$id/renew-subscription',
      data: data,
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(AdminTeacherModel.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, AdminTeacherModel>> removeSubscription({
    required int id,
  }) async {
    final response = await DioHelper.postData(
      url: '$adminTeachersApi/$id/remove-subscription',
    );

    return response.fold(
      (error) => Left(error),
      (res) => Right(AdminTeacherModel.fromJson(_decodeData(res.data))),
    );
  }

  static Future<Either<String, String>> resetPassword({
    required int id,
  }) async {
    final response = await DioHelper.postData(
      url: '$adminTeachersApi/$id/reset-password',
    );

    return response.fold(
      (error) => Left(error),
      (res) {
        final data = _decodeData(res.data);
        return Right(data['plain_password'] as String? ?? 'تمت إعادة التعيين بنجاح');
      },
    );
  }

  static Future<Either<String, bool>> deleteTeacher({
    required int id,
  }) async {
    final response = await DioHelper.deleteData(
      url: '$adminTeachersApi/$id',
    );

    return response.fold(
      (error) => Left(error),
      (res) => const Right(true),
    );
  }
}
