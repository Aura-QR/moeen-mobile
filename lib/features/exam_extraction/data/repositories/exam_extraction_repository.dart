import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_job_model.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';

class ExamExtractionRepository {
  Map<String, dynamic> _map(dynamic data) =>
      Map<String, dynamic>.from(data as Map);

  Future<Either<Failure, ExtractionJobModel>> start({
    required List<ExtractionPageModel> pages,
    required int count,
    String? notes,
  }) async {
    final formData = FormData.fromMap({
      'count': count,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });

    for (final page in pages) {
      formData.files.add(
        MapEntry(
          'files[]',
          MultipartFile.fromBytes(
            page.bytes,
            filename: page.name,
            contentType: DioMediaType.parse(page.mime),
          ),
        ),
      );
    }

    return handleApiResponse(
      DioHelper.postData(url: examExtractionsApi, data: formData),
      (data) => ExtractionJobModel.fromJson(_map(data)),
    );
  }

  Future<Either<Failure, ExtractionJobModel>> getJob(int id) {
    return handleApiResponse(
      DioHelper.getData(url: aiJobApi(id)),
      (data) => ExtractionJobModel.fromJson(_map(data)),
    );
  }

  Future<Either<Failure, Unit>> saveExam({
    required String title,
    required int lessonId,
    required List<ExtractedQuestionModel> questions,
  }) {
    final payload = {
      'title': title,
      'lesson_id': lessonId,
      'questions': questions.map((q) => q.toSaveJson()).toList(),
    };

    return handleApiResponse(
      DioHelper.postData(url: examsFromQuestionsApi, data: payload),
      (_) => unit,
    );
  }
}
