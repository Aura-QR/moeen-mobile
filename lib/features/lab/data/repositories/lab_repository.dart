import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';

/// L8 «معمل حضر الافتراضي» Repository (LAB_API.md).
class LabRepository {
  Map<String, dynamic> _map(dynamic data) =>
      Map<String, dynamic>.from(data as Map);

  /// Fetch paginated experiments.
  Future<Either<Failure, LabExperimentsPage>> getExperiments({
    int page = 1,
    String? search,
    int? stageId,
    int? gradeId,
    int? subjectId,
    String? subjectGroup,
    int? lessonId,
    String sort = 'popular',
  }) {
    final query = <String, dynamic>{
      'page': page,
      'sort': sort,
      'stage_id': ?stageId,
      'grade_id': ?gradeId,
      'subject_id': ?subjectId,
      if (subjectGroup != null && subjectGroup.isNotEmpty)
        'subject_group': subjectGroup,
      'lesson_id': ?lessonId,
    };

    return handleApiResponse(
      DioHelper.getData(
        url: publicLabExperimentsApi,
        query: query,
        search: search?.isNotEmpty == true ? search : null,
      ),
      (data) => LabExperimentsPage.fromJson(_map(data)),
      unwrapData: false,
    );
  }

  /// Single experiment details including linked `lessons` from `GET /public/lab/experiments/{key}`.
  Future<Either<Failure, LabExperimentModel>> getExperimentDetails(
    String key,
  ) =>
      handleApiResponse(
        DioHelper.getData(url: publicLabExperimentApi(key)),
        (data) => LabExperimentModel.fromJson(_map(data)),
      );

  /// Curriculum filters tree from `GET /public/lab/filters`.
  Future<Either<Failure, LabFiltersModel>> getFilters() => handleApiResponse(
        DioHelper.getData(url: publicLabFiltersApi),
        (data) => LabFiltersModel.fromJson(_map(data)),
      );

  /// Experiments linked to a lesson from `GET /lessons/{lesson}/experiments`.
  Future<Either<Failure, List<LabExperimentModel>>> getLessonExperiments(
    int lessonId,
  ) =>
      handleApiResponse(
        DioHelper.getData(url: lessonExperimentsApi(lessonId)),
        (data) => (data as List)
            .map((e) => LabExperimentModel.fromJson(_map(e)))
            .toList(),
      );

  /// Report a mistake on an experiment `POST /lab/experiments/{key}/reports`.
  Future<Either<Failure, Unit>> reportMistake(String key, String message) =>
      handleApiResponse(
        DioHelper.postData(
          url: labExperimentReportsApi(key),
          data: {'message': message},
        ),
        (_) => unit,
      );

  /// Request a new experiment `POST /lab/requests` (`LAB_API.md` §2.5).
  Future<Either<Failure, Unit>> requestExperiment({
    int? lessonId,
    required String message,
  }) =>
      handleApiResponse(
        DioHelper.postData(
          url: labRequestExperimentApi,
          data: {
            if (lessonId != null && lessonId > 0) 'lesson_id': lessonId,
            'message': message,
          },
        ),
        (_) => unit,
      );

  /// Create a community experiment `POST /lab/experiments` (`LAB_API.md` §2.3).
  Future<Either<Failure, LabExperimentModel>> createExperiment(
    LabCreateExperimentInput input,
  ) =>
      handleApiResponse(
        DioHelper.postData(
          url: labCreateExperimentApi,
          data: input.toJson(),
        ),
        (data) => LabExperimentModel.fromJson(_map(data)),
      );
}
