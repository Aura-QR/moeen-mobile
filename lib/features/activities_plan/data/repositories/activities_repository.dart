import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_plan_input.dart';

/// The read-only catalogue and suggested grid the T5 form is built from.
class ActivitiesRepository {
  /// The official layout's bands and programs, and the old layout's stages and domains.
  Future<Either<Failure, ActivitiesCatalogueModel>> getCatalogue() => handleApiResponse(
    DioHelper.getData(url: activitiesToolApi),
    (data) => ActivitiesCatalogueModel.fromJson(data as Map<String, dynamic>),
  );

  /// The old layout's suggested grid, for saved documents. A null [region] uses the teacher's `region_calendar`.
  Future<Either<Failure, ActivitiesGridModel>> getGrid({
    required String stage,
    required int term,
    required List<String> domains,
    String? region,
  }) => handleApiResponse(
    DioHelper.getData(
      url: activitiesPlanApi,
      query: {
        'stage': stage,
        'term': term,
        // Dio repeats the key for each value: domains[]=a&domains[]=b.
        'domains[]': domains,
        'region': ?region,
      },
    ),
    (data) => ActivitiesGridModel.fromJson(data as Map<String, dynamic>),
  );

  /// The official layout's suggested grid. A null [periodsPerWeek] uses the
  /// band's default, and a null [region] the teacher's `region_calendar`.
  Future<Either<Failure, ActivitiesGridModel>> getOfficialGrid({
    required String band,
    required int term,
    int? periodsPerWeek,
    String? region,
  }) => handleApiResponse(
    DioHelper.getData(
      url: activitiesPlanApi,
      query: {
        'layout': ActivitiesPlanInput.official,
        'band': band,
        'term': term,
        'periods_per_week': ?periodsPerWeek,
        'region': ?region,
      },
    ),
    (data) => ActivitiesGridModel.fromJson(data as Map<String, dynamic>),
  );
}
