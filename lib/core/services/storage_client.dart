import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';

/// Plain client for R2 uploads and signed downloads. The API client adds the
/// Authorization header and our interceptors, and R2 rejects signed requests
/// that carry them.
class StorageClient {
  StorageClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// PUTs [bytes] to the signed URL with exactly the ticket's headers.
  Future<Either<Failure, Unit>> upload(
    StorageUploadTicketModel ticket,
    Uint8List bytes, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      await _dio.put<void>(
        ticket.uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            ...ticket.headers,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      return const Right(unit);
    } on DioException {
      return const Left(ServerFailure('upload_failed'));
    }
  }

  /// PUTs the file at [path] to the signed URL without loading it into memory.
  Future<Either<Failure, Unit>> uploadFile(
    StorageUploadTicketModel ticket,
    String path,
    int byteSize, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.put<void>(
        ticket.uploadUrl,
        data: File(path).openRead(),
        cancelToken: cancelToken,
        options: Options(
          sendTimeout: const Duration(minutes: 30),
          headers: {
            ...ticket.headers,
            Headers.contentLengthHeader: byteSize,
          },
        ),
        onSendProgress: (sent, _) {
          if (byteSize > 0) onProgress?.call(sent / byteSize);
        },
      );
      return const Right(unit);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const Left(ServerFailure('qr_upload_cancelled'));
      }
      return const Left(ServerFailure('upload_failed'));
    } catch (_) {
      return const Left(ServerFailure('upload_failed'));
    }
  }

  /// Downloads a signed file URL.
  Future<Either<Failure, Uint8List>> download(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Right(Uint8List.fromList(response.data ?? const []));
    } on DioException {
      return const Left(ServerFailure('network_error'));
    }
  }
}
