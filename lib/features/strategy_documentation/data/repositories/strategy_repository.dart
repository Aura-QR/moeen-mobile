import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';

/// The read-only strategies catalogue the T4 form is built from.
class StrategyRepository {
  Future<Either<Failure, StrategyCatalogueModel>> getCatalogue() => handleApiResponse(
        DioHelper.getData(url: strategiesApi),
        (data) => StrategyCatalogueModel.fromJson(data as Map<String, dynamic>),
      );

  Future<Either<Failure, StrategyDetailsModel>> getStrategy(String key) => handleApiResponse(
        DioHelper.getData(url: strategyApi(key)),
        (data) => StrategyDetailsModel.fromJson(data as Map<String, dynamic>),
      );
}
