import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';

/// Asks the server for a one-time link that opens the website's checkout
/// already signed in as the current teacher.
class WebCheckoutRepository {
  /// The site page the link lands on. [serviceId] preselects a plan.
  static String checkoutPath({int? serviceId}) =>
      serviceId == null ? '/checkout' : '/checkout?service_id=$serviceId';

  /// The link works once and for about two minutes, and it carries a sign-in
  /// code: the caller opens it straight away and never stores or logs it.
  Future<Either<Failure, String>> createHandoffUrl({int? serviceId}) async {
    try {
      final response = await DioHelper.postData(
        url: webHandoffApi,
        data: {'next': checkoutPath(serviceId: serviceId)},
      );
      return response.fold<Either<Failure, String>>(
        (error) => Left(failureFromApiError(error)),
        (res) {
          final url = handoffUrlFrom(res.data);
          return url == null
              ? const Left(ServerFailure('generic_error'))
              : Right(url);
        },
      );
    } catch (_) {
      return const Left(ServerFailure('generic_error'));
    }
  }

  /// Reads `data.url` from `{"data": {"url": "...", "expires_in": 120}}`.
  static String? handoffUrlFrom(Object? body) {
    final decoded = body is String ? _tryDecode(body) : body;
    if (decoded is! Map) return null;
    final data = decoded['data'];
    if (data is! Map) return null;
    final url = data['url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  static Object? _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}
