import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';

/// L3 «أنماط التعلم» (LEARNING_STYLES_API.md), teacher side.
class LearningStylesRepository {
  Map<String, dynamic> _map(dynamic data) => Map<String, dynamic>.from(data as Map);

  Future<Either<Failure, LearningStylesOptions>> getOptions() => handleApiResponse(
        DioHelper.getData(url: learningStylesOptionsApi),
        (data) => LearningStylesOptions.fromJson(_map(data)),
      );

  /// The first page of my surveys (20).
  Future<Either<Failure, List<LearningStyleSurvey>>> getSurveys() => handleApiResponse(
        DioHelper.getData(url: learningStylesApi),
        (data) => (data as List).map((e) => LearningStyleSurvey.fromJson(_map(e))).toList(),
      );

  Future<Either<Failure, LearningStyleSurvey>> getSurvey(int id) => handleApiResponse(
        DioHelper.getData(url: learningStyleApi(id)),
        (data) => LearningStyleSurvey.fromJson(_map(data)),
      );

  Future<Either<Failure, LearningStyleSurvey>> create(NewLearningStyleSurvey survey) => handleApiResponse(
        DioHelper.postData(url: learningStylesApi, data: survey.toJson()),
        (data) => LearningStyleSurvey.fromJson(_map(data)),
      );

  Future<Either<Failure, LearningStyleSurvey>> setOpen(int id, bool open) => handleApiResponse(
        DioHelper.patchData(url: learningStyleApi(id), data: {'is_open': open}),
        (data) => LearningStyleSurvey.fromJson(_map(data)),
      );

  Future<Either<Failure, Unit>> delete(int id) => handleApiResponse(
        DioHelper.deleteData(url: learningStyleApi(id)),
        (_) => unit,
      );

  Future<Either<Failure, LearningStylesResults>> getResults(int id) => handleApiResponse(
        DioHelper.getData(url: learningStyleResultsApi(id)),
        (data) => LearningStylesResults.fromJson(_map(data)),
      );

  Future<Either<Failure, Unit>> deleteResponse(int id, int responseId) => handleApiResponse(
        DioHelper.deleteData(url: learningStyleResponseApi(id, responseId)),
        (_) => unit,
      );

  /// Saves or refreshes the printable `learning_styles` report document.
  Future<Either<Failure, DocumentModel>> saveReport(int id) => handleApiResponse(
        DioHelper.postData(url: learningStyleReportApi(id), data: const <String, dynamic>{}),
        (data) => DocumentModel.fromJson(_map(data)),
      );
}
