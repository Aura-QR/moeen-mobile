import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_upload_models.dart';

/// Repository for the portfolio endpoints in
/// PORTFOLIO_AND_ACHIEVEMENTS_API.md § 1.
class PortfolioRepository {
  PortfolioRepository({Dio? storageDio}) : _storageDio = storageDio ?? Dio();

  /// Plain client for R2. The API client adds the Authorization header and
  /// our interceptors, and R2 rejects signed requests that carry them.
  final Dio _storageDio;

  Future<Either<Failure, PortfolioRolesModel>> getRoles() => _handle(
        DioHelper.getData(url: portfolioRolesApi),
        PortfolioRolesModel.fromJson,
      );

  Future<Either<Failure, List<PortfolioModel>>> getPortfolios() => _handle(
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
      _handle(
        DioHelper.postData(url: portfoliosApi, data: {
          'role': role,
          if (title != null && title.isNotEmpty) 'title': title,
        }),
        (data) => PortfolioModel.fromJson(data as Map<String, dynamic>),
      );

  Future<Either<Failure, PortfolioModel>> getPortfolio(int id) => _handle(
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
      _handle(
        DioHelper.patchData(url: portfolioApi(id), data: {
          'title': ?title,
          'role': ?role,
          if (profile != null) 'profile': profile.toJson(),
        }),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> deletePortfolio(int id) => _handle(
        DioHelper.deleteData(url: portfolioApi(id)),
        (_) => unit,
      );

  /// Returns the share URL. Calling it again keeps the same link.
  Future<Either<Failure, String>> enableShare(int id) => _handle(
        DioHelper.postData(url: portfolioShareApi(id), data: {}),
        (data) => (data as Map<String, dynamic>)['share_url']?.toString() ?? '',
      );

  /// Retires the token for good; sharing again makes a new link.
  Future<Either<Failure, Unit>> disableShare(int id) => _handle(
        DioHelper.deleteData(url: portfolioShareApi(id)),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> addItem(
    int id, {
    required String title,
    String? description,
  }) =>
      _handle(
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
      _handle(
        DioHelper.patchData(url: portfolioItemApi(id, itemId), data: {
          'title': ?title,
          'description': ?description,
          'included': ?included,
        }),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> deleteItem(int id, int itemId) => _handle(
        DioHelper.deleteData(url: portfolioItemApi(id, itemId)),
        (_) => unit,
      );

  /// Runs the two-step upload: signed URL, PUT to R2, then register.
  Future<Either<Failure, Unit>> uploadFile({
    required int portfolioId,
    required int itemId,
    required PortfolioPickedFile file,
    void Function(double progress)? onProgress,
  }) async {
    final ticketResult = await _handle(
      DioHelper.postData(
        url: portfolioItemUploadsApi(portfolioId, itemId),
        data: {'mime': file.mime, 'byte_size': file.byteSize},
      ),
      (data) => PortfolioUploadTicketModel.fromJson(data as Map<String, dynamic>),
    );

    return ticketResult.fold(Left.new, (ticket) async {
      final putResult = await _putToStorage(ticket, file.bytes, onProgress);
      return putResult.fold(
        Left.new,
        (_) => _handle(
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
      _handle(
        DioHelper.postData(url: portfolioItemFilesApi(portfolioId, itemId), data: {
          'kind': 'link',
          'url': url,
          if (title != null && title.isNotEmpty) 'title': title,
        }),
        (_) => unit,
      );

  /// [ids] must hold every file id of the item, in the new order.
  Future<Either<Failure, Unit>> reorderFiles(int id, int itemId, List<int> ids) =>
      _handle(
        DioHelper.putData(url: portfolioItemFilesOrderApi(id, itemId), data: {'ids': ids}),
        (_) => unit,
      );

  Future<Either<Failure, Unit>> deleteFile(int id, int itemId, int fileId) => _handle(
        DioHelper.deleteData(url: portfolioItemFileApi(id, itemId, fileId)),
        (_) => unit,
      );

  /// Downloads a signed file URL, used for the PDF images.
  Future<Either<Failure, Uint8List>> downloadBytes(String url) async {
    try {
      final response = await _storageDio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Right(Uint8List.fromList(response.data ?? const []));
    } on DioException {
      return const Left(ServerFailure('network_error'));
    }
  }

  Future<Either<Failure, Unit>> _putToStorage(
    PortfolioUploadTicketModel ticket,
    Uint8List bytes,
    void Function(double progress)? onProgress,
  ) async {
    try {
      await _storageDio.put<void>(
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
      return const Left(ServerFailure('portfolio_upload_failed'));
    }
  }

  /// Unwraps `{ data: ... }` and maps errors to [Failure].
  Future<Either<Failure, T>> _handle<T>(
    Future<Either<String, Response>> request,
    T Function(dynamic data) parse,
  ) async {
    final response = await request;
    return response.fold(
      (error) => Left(failureFromApiError(error)),
      (res) {
        try {
          final body = res.data;
          final data = body is Map<String, dynamic> && body.containsKey('data')
              ? body['data']
              : body;
          return Right(parse(data));
        } catch (_) {
          return const Left(ServerFailure('generic_error'));
        }
      },
    );
  }
}
