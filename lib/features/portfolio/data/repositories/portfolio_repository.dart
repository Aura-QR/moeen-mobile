import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/services/storage_client.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';

/// Repository for the portfolio endpoints in
/// PORTFOLIO_AND_ACHIEVEMENTS_API.md § 1.
class PortfolioRepository {
  PortfolioRepository({StorageClient? storage}) : _storage = storage ?? StorageClient();

  final StorageClient _storage;

  Future<Either<Failure, PortfolioRolesModel>> getRoles() => handleApiResponse(
        DioHelper.getData(url: portfolioRolesApi),
        PortfolioRolesModel.fromJson,
      );

  Future<Either<Failure, List<PortfolioModel>>> getPortfolios() => handleApiResponse(
        DioHelper.getData(url: portfoliosApi),
        (data) => (data as List)
            .whereType<Map<String, dynamic>>()
            .map(PortfolioModel.fromJson)
            .toList(),
      );

  Future<Either<Failure, PortfolioModel>> createPortfolio({
    required String role,
    String? title,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: portfoliosApi, data: {
          'role': role,
          if (title != null && title.isNotEmpty) 'title': title,
        }),
        (data) => PortfolioModel.fromJson(data as Map<String, dynamic>),
      );

  Future<Either<Failure, PortfolioModel>> getPortfolio(int id) => handleApiResponse(
        DioHelper.getData(url: portfolioApi(id)),
        (data) => PortfolioModel.fromJson(data as Map<String, dynamic>),
      );

  /// `profile` is merged by the API; changing `role` adds that role's items.
  Future<Either<Failure, Unit>> updatePortfolio(
    int id, {
    String? title,
    String? role,
    PortfolioProfileModel? profile,
  }) =>
      handleApiResponse(
        DioHelper.patchData(url: portfolioApi(id), data: {
          'title': ?title,
          'role': ?role,
          if (profile != null) 'profile': profile.toJson(),
        }),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> deletePortfolio(int id) => handleApiResponse(
        DioHelper.deleteData(url: portfolioApi(id)),
        (_) => unit,
      );

  /// Returns the share URL. Calling it again keeps the same link.
  Future<Either<Failure, String>> enableShare(int id) => handleApiResponse(
        DioHelper.postData(url: portfolioShareApi(id), data: {}),
        (data) => (data as Map<String, dynamic>)['share_url']?.toString() ?? '',
      );

  /// Retires the token for good; sharing again makes a new link.
  Future<Either<Failure, Unit>> disableShare(int id) => handleApiResponse(
        DioHelper.deleteData(url: portfolioShareApi(id)),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> addItem(
    int id, {
    required String title,
    String? description,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: portfolioItemsApi(id), data: {
          'title': title,
          if (description != null && description.isNotEmpty) 'description': description,
        }),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> updateItem(
    int id,
    int itemId, {
    String? title,
    String? description,
    bool? included,
  }) =>
      handleApiResponse(
        DioHelper.patchData(url: portfolioItemApi(id, itemId), data: {
          'title': ?title,
          'description': ?description,
          'included': ?included,
        }),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> deleteItem(int id, int itemId) => handleApiResponse(
        DioHelper.deleteData(url: portfolioItemApi(id, itemId)),
        (_) => unit,
      );

  /// Runs the two-step upload: signed URL, PUT to R2, then register.
  Future<Either<Failure, Unit>> uploadFile({
    required int portfolioId,
    required int itemId,
    required DevicePickedFile file,
    void Function(double progress)? onProgress,
  }) async {
    final ticketResult = await handleApiResponse(
      DioHelper.postData(
        url: portfolioItemUploadsApi(portfolioId, itemId),
        data: {'mime': file.mime, 'byte_size': file.byteSize},
      ),
      (data) => StorageUploadTicketModel.fromJson(data as Map<String, dynamic>),
    );

    return ticketResult.fold(Left.new, (ticket) async {
      final putResult = await _storage.upload(ticket, file.bytes, onProgress: onProgress);
      return putResult.fold(
        Left.new,
        (_) => handleApiResponse(
          DioHelper.postData(
            url: portfolioItemFilesApi(portfolioId, itemId),
            data: {
              'kind': 'file',
              'storage_path': ticket.storagePath,
              'original_name': file.name,
            },
          ),
          (_) => unit,
        ),
      );
    });
  }

  Future<Either<Failure, Unit>> addLink({
    required int portfolioId,
    required int itemId,
    required String url,
    String? title,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: portfolioItemFilesApi(portfolioId, itemId), data: {
          'kind': 'link',
          'url': url,
          if (title != null && title.isNotEmpty) 'title': title,
        }),
        (_) => unit,
      );

  /// Adds a saved teacher document as evidence (DOCUMENTS_API.md § 6). The
  /// file's `url` stays null until the queue has built it.
  Future<Either<Failure, Unit>> attachDocument({
    required int portfolioId,
    required int itemId,
    required int documentId,
  }) =>
      handleApiResponse(
        DioHelper.postData(
          url: portfolioItemDocumentsApi(portfolioId, itemId),
          data: {'document_id': documentId},
        ),
        (_) => unit,
      );

  /// [ids] must hold every file id of the item, in the new order.
  Future<Either<Failure, Unit>> reorderFiles(int id, int itemId, List<int> ids) =>
      handleApiResponse(
        DioHelper.putData(url: portfolioItemFilesOrderApi(id, itemId), data: {'ids': ids}),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> deleteFile(int id, int itemId, int fileId) => handleApiResponse(
        DioHelper.deleteData(url: portfolioItemFileApi(id, itemId, fileId)),
        (_) => unit,
      );

  /// Downloads a signed file URL, used for the PDF images.
  Future<Either<Failure, Uint8List>> downloadBytes(String url) => _storage.download(url);
}
