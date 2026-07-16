import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/admin/exams/data/models/admin_exam_models.dart';

abstract class AdminExamRemoteDataSource {
  Future<AdminQuestionPaginationModel> getPendingQuestions({
    int page = 1,
    String? type,
    String? difficulty,
    int? lessonId,
  });

  Future<AdminQuestionModel> reviewQuestion({
    required int questionId,
    required String decision,
    String? rejectionReason,
  });
}

class AdminExamRemoteDataSourceImpl implements AdminExamRemoteDataSource {
  AdminExamRemoteDataSourceImpl();

  @override
  Future<AdminQuestionPaginationModel> getPendingQuestions({
    int page = 1,
    String? type,
    String? difficulty,
    int? lessonId,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };
    if (type != null) queryParameters['type'] = type;
    if (difficulty != null) queryParameters['difficulty'] = difficulty;
    if (lessonId != null) queryParameters['lesson_id'] = lessonId;

    final response = await DioHelper.getData(
      url: adminPendingQuestionsApi,
      query: queryParameters,
    );

    return response.fold(
      (error) => throw Exception(error),
      (data) => AdminQuestionPaginationModel.fromJson(data.data),
    );
  }

  @override
  Future<AdminQuestionModel> reviewQuestion({
    required int questionId,
    required String decision,
    String? rejectionReason,
  }) async {
    final response = await DioHelper.patchData(
      url: adminReviewQuestionApi(questionId),
      data: {
        'decision': decision,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );

    return response.fold(
      (error) => throw Exception(error),
      (data) => AdminQuestionModel.fromJson(data.data['question']),
    );
  }
}
