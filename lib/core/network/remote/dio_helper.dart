import 'dart:convert';
import 'package:moean/core/di/injections.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
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
          'q': ?search,
          ...?query,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token?.isNotEmpty ?? false)
  'Authorization': 'Bearer $token',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = parseError(error);
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
      final msg = parseError(error);
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
      final msg = parseError(error);
      return Left(msg);
    } catch (e) {
      return const Left('something went wrong');
    }
  }

  static Future<Either<String, Response>> patchData({
    required String url,
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('🚀 PATCH Request: $url');
      final Response response = await getDio().patch(
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
      final msg = parseError(error);
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
      final msg = parseError(error);
      if (error.response?.statusCode == 401 && (msg == 'Error 401' || msg == 'Unauthenticated')) {
        return const Left('Unauthenticated');
      }
      return Left(msg);
    } catch (e) {
      return const Left('something went wrong');
    }
  }

  static String parseError(DioException error) {
    final response = error.response;
    if (response == null) return 'No response from server';

    if (response.statusCode == 402 && response.data is Map) {
      final map = response.data as Map;
      final code = map['code']?.toString() ?? 'quota_exceeded';
      final message = map['message']?.toString() ?? 'ترقية الحساب المطلوبة';
      return '__402__:$code:$message';
    }

    if (response.statusCode == 409 && response.data is Map) {
      final map = response.data as Map;
      final code = map['code']?.toString() ?? '';
      if (code == 'already_subscribed' || code == 'checkout_in_progress') {
        return '__409__:$code:${jsonEncode(map)}';
      }
    }

    if (response.data is Map) {
      final map = response.data as Map;

      // ── Detect Madrasati session expiry from error code ───────
      final errorCode = map['code']?.toString() ?? '';
      const sessionExpiredCodes = [
        'madrasati_session_expired',
        'madrasati_session_required',
      ];
      final fullMapStr = map.toString();
      final isSessionExpired = sessionExpiredCodes.contains(errorCode) ||
          fullMapStr.contains('معرف المدرسة غير موجود في الجلسة') ||
          fullMapStr.contains('أعد ربط حساب مدرستي');

      if (isSessionExpired) {
        debugPrint('🔴 DioHelper: detected session expired code or message');
        try {
          sl<MadrasatiSessionService>().notifySessionExpired();
        } catch (_) {}
      }
      // ─────────────────────────────────────────────────────────

      if (errorCode == 'account_suspended' ||
          (response.statusCode == 403 && (errorCode == 'account_suspended' || fullMapStr.contains('تعليق') || fullMapStr.contains('موقوف')))) {
        final message = map['message']?.toString() ?? 'account_suspended';
        return '__403__:account_suspended:$message';
      }

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

      return 'Error ${response.statusCode}: ${response.statusMessage}';
    }
    return 'Error: ${response.statusCode}: ${response.statusMessage}';
  }
}
