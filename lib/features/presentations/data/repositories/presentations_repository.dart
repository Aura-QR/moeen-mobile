import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/presentations/data/models/presentation_models.dart';

class PresentationsRepository {
  Future<Either<String, PresentationModel>> generatePresentation({
    required int lessonId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await DioHelper.postData(
      url: lessonPresentationGenerateApi(lessonId),
      data: payload,
    );

    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          return Right(PresentationModel.fromJson(res.data));
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  Future<Either<String, PresentationModel>> getPresentation({
    required int lessonId,
    required String templateId,
  }) async {
    final response = await DioHelper.getData(
      url: lessonPresentationApi(lessonId),
      query: {
        'template_id': templateId,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          return Right(PresentationModel.fromJson(res.data));
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }
}
