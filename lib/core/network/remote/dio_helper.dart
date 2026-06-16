import 'package:moean/core/di/injections.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';

class DioHelper {
  static Dio getDio() => sl<Dio>();

  static Future<Either<String, Response>> getData({
    required String url,
    Map<String, dynamic>? query,
    String? search,
  }) async {
    try {
      debugPrint('🚀 GET Request: $url');
      debugPrint('🔑 Sending Token: $token');

      final Response response = await getDio().get(
        url,
        queryParameters: {
          'q': search,
          ...?query,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null && token!.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = _parseError(error);
      if (error.response?.statusCode == 401 && (msg == 'Error 401' || msg == 'Unauthenticated')) {
        return const Left('Unauthenticated');
      }
      return Left(msg);
    } catch (e) {
      return const Left('something went wrong');
    }
  }

  static Future<Either<String, Response>> postData({
    required String url,
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('🚀 POST Request: $url');
      debugPrint('🔑 Sending Token: $token');
      final Response response = await getDio().post(
        url,
        data: data,
        queryParameters: query,
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (data is! FormData) 'Content-Type': 'application/json',
            if (token != null && token!.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = _parseError(error);
      if (error.response?.statusCode == 401 && (msg == 'Error 401' || msg == 'Unauthenticated')) {
        return const Left('Unauthenticated');
      }
      return Left(msg);
    } catch (e) {
      return const Left('something went wrong');
    }
  }

  static Future<Either<String, Response>> putData({
    required String url,
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('🚀 PUT Request: $url');
      final Response response = await getDio().put(
        url,
        data: data,
        queryParameters: query,
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (data is! FormData) 'Content-Type': 'application/json',
            if (token != null && token!.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = _parseError(error);
      return Left(msg);
    } catch (e) {
      return const Left('something went wrong');
    }
  }

  static Future<Either<String, Response>> deleteData({
    required String url,
  }) async {
    try {
      debugPrint('🚀 DELETE Request: $url');
      final Response response = await getDio().delete(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null && token!.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = _parseError(error);
      if (error.response?.statusCode == 401 && (msg == 'Error 401' || msg == 'Unauthenticated')) {
        return const Left('Unauthenticated');
      }
      return Left(msg);
    } catch (e) {
      return const Left('something went wrong');
    }
  }

  static String _parseError(DioException error) {
    final response = error.response;
    if (response == null) return 'No response from server';
    if (response.data is Map) {
      final map = response.data as Map;
      final errors = map['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final buffer = <String>[];
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            buffer.add(value.join(', '));
          } else if (value != null) {
            buffer.add(value.toString());
          }
        });
        if (buffer.isNotEmpty) {
          return buffer.join('\n');
        }
      }

      final errorObj = map['error'];
      if (errorObj is Map && errorObj['detail'] != null) {
        final detailStr = errorObj['detail'].toString();
        if (detailStr.isNotEmpty) {
          return detailStr;
        }
      }

      final message = map['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      return 'Error ${response.statusCode}';
    }
    return 'Error: ${response.statusCode}';
  }
}
