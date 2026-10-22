import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';

/// AI suggestions for the document tools (AI_JOBS_API.md).
class AiJobsRepository {
  /// [input] depends on [kind], e.g. `{lesson_ids: […]}` for the plans. Done at
  /// once when the answer is cached, pending otherwise.
  Future<Either<Failure, AiJobModel>> start(String kind, Map<String, dynamic> input) => handleApiResponse(
        DioHelper.postData(url: aiJobsApi, data: {'kind': kind, 'input': input}),
        _job,
      );

  Future<Either<Failure, AiJobModel>> getJob(int id) => handleApiResponse(
        DioHelper.getData(url: aiJobApi(id)),
        _job,
      );

  static AiJobModel _job(dynamic data) => AiJobModel.fromJson(data as Map<String, dynamic>);
}
