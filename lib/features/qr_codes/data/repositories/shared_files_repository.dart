import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/services/storage_client.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';

class SharedFilesRepository {
  final StorageClient _storage;

  SharedFilesRepository({StorageClient? storage})
      : _storage = storage ?? StorageClient();

  Map<String, dynamic> _map(dynamic data) =>
      Map<String, dynamic>.from(data as Map);

  Future<Either<Failure, ({List<SharedFileModel> files, SharedFilesMetaModel meta})>>
      getFiles() {
    return handleApiResponse(
      DioHelper.getData(url: sharedFilesApi),
      (body) {
        final map = _map(body);
        final rawFiles = map['data'];
        final files = rawFiles is List
            ? rawFiles
                .whereType<Map<String, dynamic>>()
                .map(SharedFileModel.fromJson)
                .toList()
            : <SharedFileModel>[];

        final rawMeta = map['meta'];
        final meta = rawMeta is Map<String, dynamic>
            ? SharedFilesMetaModel.fromJson(rawMeta)
            : const SharedFilesMetaModel();

        return (files: files, meta: meta);
      },
      unwrapData: false,
    );
  }

  Future<Either<Failure, SharedFileModel>> getFile(int id) {
    return handleApiResponse(
      DioHelper.getData(url: sharedFileApi(id)),
      (data) => SharedFileModel.fromJson(_map(data)),
    );
  }

  Future<Either<Failure, SharedFileModel>> upload({
    required DevicePickedPath file,
    required String mime,
    String? title,
    int? expiresInDays,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Step 1: Request upload ticket
    final ticketRes = await handleApiResponse(
      DioHelper.postData(
        url: sharedFileUploadsApi,
        data: {
          'mime': mime,
          'byte_size': file.byteSize,
        },
      ),
      (data) => StorageUploadTicketModel.fromJson(_map(data)),
    );

    return ticketRes.fold(
      (failure) => Left(failure),
      (ticket) async {
        // Step 2: Stream file to signed URL
        final uploadRes = await _storage.uploadFile(
          ticket,
          file.path,
          file.byteSize,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );

        return uploadRes.fold(
          (failure) => Left(failure),
          (_) async {
            // Step 3: Register upload
            final payload = {
              'storage_path': ticket.storagePath,
              'original_name': file.name,
              if (title != null && title.trim().isNotEmpty)
                'title': title.trim(),
              'expires_in_days': ?expiresInDays,
            };

            return handleApiResponse(
              DioHelper.postData(url: sharedFilesApi, data: payload),
              (data) => SharedFileModel.fromJson(_map(data)),
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, SharedFileModel>> update(
    int id, {
    String? title,
    int? expiresInDays,
  }) {
    final payload = {
      if (title != null) 'title': title.trim(),
      'expires_in_days': ?expiresInDays,
    };

    return handleApiResponse(
      DioHelper.patchData(url: sharedFileApi(id), data: payload),
      (data) => SharedFileModel.fromJson(_map(data)),
    );
  }

  Future<Either<Failure, Unit>> delete(int id) {
    return handleApiResponse(
      DioHelper.deleteData(url: sharedFileApi(id)),
      (_) => unit,
    );
  }
}
