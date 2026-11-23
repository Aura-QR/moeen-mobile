import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/models/report_template_details.dart';

/// T8 catalogue (DOCUMENTS_API.md § 12). Saving and printing go through
/// [DocumentsRepository] like every tool.
class ReportsRepository {
  Future<Either<Failure, ReportCatalogueModel>> getCatalogue() => handleApiResponse(
        DioHelper.getData(url: reportsToolApi),
        (data) => ReportCatalogueModel.fromJson(data as Map<String, dynamic>),
      );

  /// The template's `input` (the editor's starting form, loaded as is) and its AI flags.
  Future<Either<Failure, ReportTemplateDetails>> getTemplate(String key) => handleApiResponse(
        DioHelper.getData(url: reportTemplateApi(key)),
        (data) => ReportTemplateDetails.fromJson(data as Map<String, dynamic>),
      );
}
