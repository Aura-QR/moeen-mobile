import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';

/// Maps a [DioHelper] call to [Failure] or a parsed value.
///
/// By default [parse] gets the body's `data`; pass [unwrapData] false when it
/// also needs siblings such as `meta`.
Future<Either<Failure, T>> handleApiResponse<T>(
  Future<Either<String, Response>> request,
  T Function(dynamic data) parse, {
  bool unwrapData = true,
}) async {
  final response = await request;
  return response.fold(
    (error) => Left(failureFromApiError(error)),
    (res) {
      try {
        final body = res.data;
        final data = unwrapData && body is Map<String, dynamic> && body.containsKey('data')
            ? body['data']
            : body;
        return Right(parse(data));
      } catch (_) {
        return const Left(ServerFailure('generic_error'));
      }
    },
  );
}
