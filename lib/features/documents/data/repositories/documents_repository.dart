import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/services/storage_client.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_export_models.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

/// The shared document engine every teacher tool saves through
/// (DOCUMENTS_API.md).
class DocumentsRepository {
  DocumentsRepository({StorageClient? storage}) : _storage = storage ?? StorageClient();

  final StorageClient _storage;

  /// The `resolved` defaults: stored values, with gaps filled from the account.
  Future<Either<Failure, DocumentDefaultsModel>> getDefaults() => handleApiResponse(
        DioHelper.getData(url: documentDefaultsApi),
        _resolvedDefaults,
      );

  /// Replaces the stored defaults with the whole form.
  Future<Either<Failure, DocumentDefaultsModel>> saveDefaults(DocumentDefaultsModel defaults) =>
      handleApiResponse(
        DioHelper.putData(url: documentDefaultsApi, data: defaults.toJson()),
        _resolvedDefaults,
      );

  Future<Either<Failure, DocumentsPageModel>> getDocuments({
    int page = 1,
    String? type,
    String? search,
  }) =>
      handleApiResponse(
        DioHelper.getData(url: documentsApi, query: {
          'page': page,
          if (type != null && type.isNotEmpty) 'type': type,
          if (search != null && search.isNotEmpty) 'search': search,
        }),
        (body) => DocumentsPageModel.fromJson(body as Map<String, dynamic>),
        unwrapData: false,
      );

  Future<Either<Failure, DocumentModel>> getDocument(int id) => handleApiResponse(
        DioHelper.getData(url: documentApi(id)),
        _document,
      );

  /// [status] is [DocumentStatus.draft] or [DocumentStatus.finalized].
  Future<Either<Failure, DocumentModel>> createDocument({
    required String type,
    required Map<String, dynamic> input,
    required String status,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: documentsApi, data: {'type': type, 'input': input, 'status': status}),
        _document,
      );

  /// A new `input` rebuilds the document on the server.
  Future<Either<Failure, DocumentModel>> updateDocument(
    int id,
    Map<String, dynamic> input, {
    required String status,
  }) =>
      handleApiResponse(
        DioHelper.patchData(url: documentApi(id), data: {'input': input, 'status': status}),
        _document,
      );

  /// Copies it as a draft titled «نسخة من …».
  Future<Either<Failure, DocumentModel>> duplicateDocument(int id) => handleApiResponse(
        DioHelper.postData(url: documentDuplicateApi(id), data: {}),
        _document,
      );

  Future<Either<Failure, Unit>> deleteDocument(int id) => handleApiResponse(
        DioHelper.deleteData(url: documentApi(id)),
        (_) => unit,
      );

  /// Signed URL, then PUT to R2. Returns the `storage_path` for
  /// `input.images` or a logo field.
  Future<Either<Failure, String>> uploadImage(DevicePickedFile file) async {
    final ticketResult = await handleApiResponse(
      DioHelper.postData(
        url: documentUploadsApi,
        data: {'mime': file.mime, 'byte_size': file.byteSize},
      ),
      (data) => StorageUploadTicketModel.fromJson(data as Map<String, dynamic>),
    );

    return ticketResult.fold(Left.new, (ticket) async {
      final putResult = await _storage.upload(ticket, file.bytes);
      return putResult.map((_) => ticket.storagePath);
    });
  }

  /// The saved version as one HTML page, for the on-device PDF.
  Future<Either<Failure, DocumentPrintModel>> getPrint(int id) => handleApiResponse(
        DioHelper.getData(url: documentPrintApi(id)),
        (data) => DocumentPrintModel.fromJson(data as Map<String, dynamic>),
      );

  /// `200` when this version's file exists, `202` while it renders.
  Future<Either<Failure, DocumentExportModel>> requestExport(int id, String format) =>
      handleApiResponse(
        DioHelper.postData(url: documentExportsApi(id), data: {'format': format}),
        _export,
      );

  Future<Either<Failure, DocumentExportModel>> getExport(int id, int exportId) => handleApiResponse(
        DioHelper.getData(url: documentExportApi(id, exportId)),
        _export,
      );

  Future<Either<Failure, Uint8List>> downloadFile(String url) => _storage.download(url);

  static DocumentDefaultsModel _resolvedDefaults(dynamic data) {
    final resolved = (data as Map<String, dynamic>)['resolved'];
    return DocumentDefaultsModel.fromJson(resolved is Map<String, dynamic> ? resolved : const {});
  }

  static DocumentModel _document(dynamic data) => DocumentModel.fromJson(data as Map<String, dynamic>);

  static DocumentExportModel _export(dynamic data) =>
      DocumentExportModel.fromJson(data as Map<String, dynamic>);
}
