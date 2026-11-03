import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';

class AdminLabRepository {
  Map<String, dynamic> _map(dynamic data) =>
      Map<String, dynamic>.from(data as Map);

  /// The server's maximum page size, enough for the whole catalogue.
  static const int _experimentsPerPage = 200;

  /// Fetch experiments for admin with status, reports count, and approval status.
  Future<Either<Failure, List<AdminLabExperimentModel>>> getExperiments({
    String? status,
    String? source,
    bool? featured,
    bool? hasReports,
    String? search,
  }) {
    final query = <String, dynamic>{
      'per_page': _experimentsPerPage,
      if (status != null && status.isNotEmpty) 'status': status,
      if (source != null && source.isNotEmpty) 'source': source,
      if (featured != null) 'featured': featured ? 1 : 0,
      if (hasReports != null && hasReports) 'has_reports': 1,
    };

    return handleApiResponse(
      DioHelper.getData(
        url: adminLabExperimentsApi,
        query: query,
        search: search?.isNotEmpty == true ? search : null,
      ),
      (data) {
        final list = data is List ? data : (data is Map && data['data'] is List ? data['data'] as List : []);
        return list.map((e) => AdminLabExperimentModel.fromJson(_map(e))).toList();
      },
    );
  }

  /// Update experiment status (published/hidden), approval (for community), or featured.
  Future<Either<Failure, Unit>> updateExperiment(
    String key, {
    String? status,
    bool? approve,
    bool? featured,
  }) {
    final body = <String, dynamic>{
      'status': ?status,
      'approve': ?approve,
      'featured': ?featured,
    };

    return handleApiResponse(
      DioHelper.patchData(
        url: adminLabExperimentApi(key),
        data: body,
      ),
      (_) => unit,
    );
  }

  /// Fetch mistake reports.
  Future<Either<Failure, List<AdminLabMistakeReportModel>>> getReports({
    String? status,
  }) {
    final query = <String, dynamic>{
      if (status != null && status.isNotEmpty) 'status': status,
    };

    return handleApiResponse(
      DioHelper.getData(
        url: adminLabReportsApi,
        query: query,
      ),
      (data) {
        final list = data is List ? data : (data is Map && data['data'] is List ? data['data'] as List : []);
        return list.map((e) => AdminLabMistakeReportModel.fromJson(_map(e))).toList();
      },
    );
  }

  /// Update mistake report status (`open` / `done`).
  Future<Either<Failure, Unit>> updateReportStatus(int id, String status) {
    return handleApiResponse(
      DioHelper.patchData(
        url: adminLabReportApi(id),
        data: {'status': status},
      ),
      (_) => unit,
    );
  }

  /// Fetch experiment requests from teachers.
  Future<Either<Failure, List<AdminLabRequestModel>>> getRequests({
    String? status,
  }) {
    final query = <String, dynamic>{
      if (status != null && status.isNotEmpty) 'status': status,
    };

    return handleApiResponse(
      DioHelper.getData(
        url: adminLabRequestsApi,
        query: query,
      ),
      (data) {
        final list = data is List ? data : (data is Map && data['data'] is List ? data['data'] as List : []);
        return list.map((e) => AdminLabRequestModel.fromJson(_map(e))).toList();
      },
    );
  }

  /// Update experiment request status (`open` / `done`).
  Future<Either<Failure, Unit>> updateRequestStatus(int id, String status) {
    return handleApiResponse(
      DioHelper.patchData(
        url: adminLabRequestApi(id),
        data: {'status': status},
      ),
      (_) => unit,
    );
  }
}
