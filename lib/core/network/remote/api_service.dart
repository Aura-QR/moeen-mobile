import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';

import 'package:moean/core/models/login_request.dart';
import 'package:moean/core/models/login_response.dart';
import 'package:moean/core/models/register_request.dart';
import 'package:moean/core/models/register_response.dart';
import 'package:moean/core/models/user_model.dart';

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

  static Future<Either<String, bool>> logout() async {
    final response = await DioHelper.postData(
      url: logoutApi,
    );

    return response.fold(
      (error) => Left(error),
      (res) => const Right(true),
    );
  }
}
