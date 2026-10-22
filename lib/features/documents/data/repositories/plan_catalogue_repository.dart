import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/documents/data/models/plan_catalogue_model.dart';

/// The read-only ready options a plan form is built from.
class PlanCatalogueRepository {
  /// [catalogueUrl] is `remedialToolApi` or `enrichmentToolApi`.
  const PlanCatalogueRepository(this.catalogueUrl);

  final String catalogueUrl;

  Future<Either<Failure, PlanCatalogueModel>> getCatalogue() => handleApiResponse(
        DioHelper.getData(url: catalogueUrl),
        (data) => PlanCatalogueModel.fromJson(data as Map<String, dynamic>),
      );
}
