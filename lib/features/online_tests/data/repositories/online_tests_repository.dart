import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';

class OnlineTestsRepository {
  Map<String, dynamic> _map(dynamic data) => Map<String, dynamic>.from(data as Map);

  Future<Either<Failure, List<OnlineTest>>> getTests() => handleApiResponse(
        DioHelper.getData(url: onlineTestsApi),
        (data) => (data as List).map((e) => OnlineTest.fromJson(_map(e))).toList(),
      );

  Future<Either<Failure, OnlineTest>> create(NewOnlineTest test) => handleApiResponse(
        DioHelper.postData(url: onlineTestsApi, data: test.toJson()),
        (data) => OnlineTest.fromJson(_map(data)),
      );

  Future<Either<Failure, OnlineTest>> getTest(int id) => handleApiResponse(
        DioHelper.getData(url: '$onlineTestsApi/$id'),
        (data) => OnlineTest.fromJson(_map(data)),
      );

  Future<Either<Failure, OnlineTest>> setOpen(int id, bool open) => handleApiResponse(
        DioHelper.patchData(url: '$onlineTestsApi/$id', data: {'is_open': open}),
        (data) => OnlineTest.fromJson(_map(data)),
      );

  Future<Either<Failure, OnlineTest>> addGroup(int id, String name) => handleApiResponse(
        DioHelper.postData(url: '$onlineTestsApi/$id/groups', data: {'name': name}),
        (data) => OnlineTest.fromJson(_map(data)),
      );

  Future<Either<Failure, Unit>> delete(int id) => handleApiResponse(
        DioHelper.deleteData(url: '$onlineTestsApi/$id'),
        (_) => unit,
      );

  Future<Either<Failure, OnlineTestResults>> getResults(int id) => handleApiResponse(
        DioHelper.getData(url: '$onlineTestsApi/$id/results'),
        (data) => OnlineTestResults.fromJson(_map(data)),
      );

  Future<Either<Failure, SubmissionDetail>> getSubmission(int id, int submissionId) => handleApiResponse(
        DioHelper.getData(url: '$onlineTestsApi/$id/submissions/$submissionId'),
        (data) => SubmissionDetail.fromJson(_map(data)),
      );

  /// Marks per question id; null leaves it waiting for review.
  Future<Either<Failure, SubmissionDetail>> review(int id, int submissionId, Map<int, double?> marks) => handleApiResponse(
        DioHelper.patchData(
          url: '$onlineTestsApi/$id/submissions/$submissionId',
          data: {'marks': marks.map((k, v) => MapEntry('$k', v))},
        ),
        (data) => SubmissionDetail.fromJson(_map(data)),
      );

  Future<Either<Failure, Unit>> deleteSubmission(int id, int submissionId) => handleApiResponse(
        DioHelper.deleteData(url: '$onlineTestsApi/$id/submissions/$submissionId'),
        (_) => unit,
      );

  /// The «تحليل نتائج الطلاب» input filled with the scores, and how many answers still wait for review.
  Future<Either<Failure, ({Map<String, dynamic> input, int toReview})>> gradeAnalysisInput(int id) => handleApiResponse(
        DioHelper.getData(url: '$onlineTestsApi/$id/grade-analysis'),
        (data) => (input: _map(_map(data)['input']), toReview: (_map(data)['to_review'] as num?)?.toInt() ?? 0),
      );

  // AI-suggested marks (phase 2).
  Future<Either<Failure, AiGradingJob>> startAiGrading(int id) => handleApiResponse(
        DioHelper.postData(url: '$onlineTestsApi/$id/ai-grading', data: const <String, dynamic>{}),
        (data) => AiGradingJob.fromJson(_map(data)),
      );

  Future<Either<Failure, AiGradingJob>> getAiJob(int jobId) => handleApiResponse(
        DioHelper.getData(url: '$aiJobsApi/$jobId'),
        (data) => AiGradingJob.fromJson(_map(data)),
      );

  Future<Either<Failure, int>> acceptAiGrading(int id) => handleApiResponse(
        DioHelper.postData(url: '$onlineTestsApi/$id/ai-grading/accept', data: const <String, dynamic>{}),
        (data) => (_map(data)['accepted'] as num?)?.toInt() ?? 0,
      );
}
