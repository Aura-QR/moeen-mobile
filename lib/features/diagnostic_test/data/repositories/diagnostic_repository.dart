import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class DiagnosticRepository {
  Map<String, dynamic> _map(dynamic data) => Map<String, dynamic>.from(data as Map);

  Future<Either<Failure, List<CurriculumStageModel>>> getStages() => handleApiResponse(
        DioHelper.getData(url: subjectsApi),
        (data) => (data is List ? data : const [])
            .whereType<Map>()
            .map((e) => CurriculumStageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Future<Either<Failure, DiagnosticSource>> getSource(int subjectId) => handleApiResponse(
        DioHelper.getData(url: '$diagnosticTestsApi/source', query: {'subject_id': subjectId}),
        (data) => DiagnosticSource.fromJson(_map(data)),
      );

  Future<Either<Failure, DiagnosticJob>> start({
    required int subjectId,
    required int skills,
    required int perSkill,
    String notes = '',
  }) =>
      handleApiResponse(
        DioHelper.postData(url: diagnosticTestsApi, data: {
          'subject_id': subjectId,
          'skills': skills,
          'per_skill': perSkill,
          if (notes.trim().isNotEmpty) 'notes': notes.trim(),
        }),
        (data) => DiagnosticJob.fromJson(_map(data)),
      );

  Future<Either<Failure, DiagnosticJob>> getJob(int id) => handleApiResponse(
        DioHelper.getData(url: '$aiJobsApi/$id'),
        (data) => DiagnosticJob.fromJson(_map(data)),
      );

  /// Returns the new exam's id.
  Future<Either<Failure, int>> save({
    required int subjectId,
    required String title,
    required List<DiagnosticSkill> skills,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: '$diagnosticTestsApi/save', data: {
          'subject_id': subjectId,
          'title': title,
          'skills': skills.map((s) => s.toJson()).toList(),
        }),
        (body) => (_map(_map(body)['exam'])['id'] as num).toInt(),
        unwrapData: false,
      );

  Future<Either<Failure, Diagnosis>> getDiagnosis(int onlineTestId) => handleApiResponse(
        DioHelper.getData(url: '$onlineTestsApi/$onlineTestId/diagnosis'),
        (data) => Diagnosis.fromJson(_map(data)),
      );
}
