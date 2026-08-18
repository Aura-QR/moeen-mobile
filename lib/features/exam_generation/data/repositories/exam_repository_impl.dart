import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/exam_models.dart';
import 'package:moean/features/exam_generation/data/models/exam_requests.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class ExamRepositoryImpl implements ExamRepository {
  @override
  Future<Either<Failure, ExamEntity>> generateExam({
    required String title,
    required String grade,
    required String subject,
    required List<Map<String, dynamic>> lessons,
  }) async {
    final request = GenerateExamRequest(
      title: title,
      grade: grade,
      subject: subject,
      lessons: lessons.map((e) => LessonRequest(
        lessonId: e['lesson_id'] as int? ?? 0,
        lessonName: e['lesson_name'] as String? ?? '',
        selectedQuestionIds: e['selected_question_ids'] != null ? List<int>.from(e['selected_question_ids']) : null,
        requestedCounts: RequestedCounts(
          mcq: e['requested_counts']?['mcq'] ?? 0,
          trueFalse: e['requested_counts']?['true_false'] ?? 0,
          fillBlank: e['requested_counts']?['fill_blank'] ?? 0,
          essay: e['requested_counts']?['essay'] ?? 0,
          matching: e['requested_counts']?['matching'] ?? 0,
        ),
      )).toList(),
    );

    final result = await ApiService.generateExam(request.toJson());

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true && data['exam'] != null) {
          try {
            final examModel = ExamModel.fromJson(data['exam']);
            return Right(examModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse generated exam: $e'));
          }
        } else {
          return Left(AiGenerationFailure(data['message']?.toString() ?? 'AI Generation Failed'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, ExamEntity>> getExam(int id) async {
    final result = await ApiService.getExam(id);

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true && data['exam'] != null) {
          try {
            final examModel = ExamModel.fromJson(data['exam']);
            return Right(examModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse exam: $e'));
          }
        } else {
          return const Left(NotFoundFailure('Exam not found'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, ExamEntity>> updateExamPoints(int id, List<Map<String, dynamic>> questions) async {
    final request = UpdateQuestionPointsRequest(
      questions: questions.map((e) => QuestionPoints(
        questionId: e['question_id'] as int? ?? 0,
        points: (e['points'] as num?)?.toDouble() ?? 0.0,
      )).toList(),
    );

    final result = await ApiService.updateExamPoints(id, request.toJson());

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true && data['exam'] != null) {
          try {
            final examModel = ExamModel.fromJson(data['exam']);
            return Right(examModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse exam: $e'));
          }
        } else {
          return const Left(ValidationFailure('Failed to update points', {}));
        }
      },
    );
  }

  @override
  Future<Either<Failure, ExamPaginationEntity>> getMyExams({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  }) async {
    final result = await ApiService.getMyExams(
      page: page,
      perPage: perPage,
      status: status,
      search: search,
    );

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true) {
          try {
            final paginationModel = ExamPaginationModel.fromJson(data);
            return Right(paginationModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse exams list: $e'));
          }
        } else {
          return Left(ServerFailure(data['message']?.toString() ?? 'Failed to fetch exams'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, ExamEntity>> publishExam(int id) async {
    final result = await ApiService.publishExam(id);

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true && data['exam'] != null) {
          try {
            final examModel = ExamModel.fromJson(data['exam']);
            return Right(examModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse published exam: $e'));
          }
        } else {
          return Left(ServerFailure(data['message']?.toString() ?? 'Failed to publish exam'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteExam(int id) async {
    final result = await ApiService.deleteExam(id);

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        return const Right(true);
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExams({int page = 1, int perPage = 20, String? status}) async {
    final result = await ApiService.getExams(page: page, perPage: perPage, status: status);

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true) {
          return Right(data);
        } else {
          return Left(ServerFailure(data['message']?.toString() ?? 'Failed to fetch exams'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, ExamEntity>> addManualQuestion(Map<String, dynamic> request) async {
    final result = await ApiService.addManualQuestion(request);

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true && data['exam'] != null) {
          try {
            final examModel = ExamModel.fromJson(data['exam']);
            return Right(examModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse exam: $e'));
          }
        } else {
          return const Left(ValidationFailure('Failed to add question', {}));
        }
      },
    );
  }

  Failure _parseApiError(String errorString) {
    if (errorString.startsWith('__402__:')) {
      final parts = errorString.split(':');
      final code = parts.length > 1 ? parts[1] : 'quota_exceeded';
      final msg = parts.length > 2 ? parts.sublist(2).join(':') : 'ترقية الحساب المطلوبة';
      return PaymentRequiredFailure(msg, code: code);
    }
    if (errorString.toLowerCase().contains('unauthenticated') || errorString.contains('401')) {
      return const UnauthorizedFailure('Unauthenticated');
    }
    if (errorString.contains('403')) {
      return const ForbiddenFailure('Access Denied');
    }
    if (errorString.contains('404')) {
      return const NotFoundFailure('Not Found');
    }
    if (errorString.contains('409')) {
      return const ExamLockedFailure('Exam is no longer a draft');
    }
    if (errorString.contains('422')) {
      return ValidationFailure(errorString, {});
    }
    if (errorString.contains('502')) {
      return const AiGenerationFailure('حدث خطأ أثناء انشاء الأسئلة، الرجاء المحاولة مرة أخرى لاحقاً');
    }
    if (errorString.contains('503') || errorString.contains('504') || errorString.contains('timeout')) {
      return const TimeoutFailure('Service unavailable or timed out');
    }
    return ServerFailure(errorString);
  }

  @override
  Future<Either<Failure, QuestionPaginationEntity>> getMyQuestions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? difficulty,
    String? reviewStatus,
    int? lessonId,
    String? search,
  }) async {
    final result = await ApiService.getMyQuestions(
      page: page,
      perPage: perPage,
      type: type,
      difficulty: difficulty,
      reviewStatus: reviewStatus,
      lessonId: lessonId,
      search: search,
    );

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (data) {
        if (data['success'] == true) {
          try {
            final paginationModel = QuestionPaginationModel.fromJson(data);
            return Right(paginationModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse questions list: $e'));
          }
        } else {
          return Left(ServerFailure(data['message']?.toString() ?? 'Failed to fetch questions'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, QuestionEntity>> updateCustomQuestion(int id, Map<String, dynamic> data) async {
    final result = await ApiService.updateCustomQuestion(id, data);

    return result.fold(
      (errorString) => Left(_parseApiError(errorString)),
      (dataResponse) {
        if (dataResponse['success'] == true && dataResponse['question'] != null) {
          try {
            final questionModel = QuestionModel.fromJson(dataResponse['question']);
            return Right(questionModel);
          } catch (e) {
            return Left(ServerFailure('Failed to parse updated question: $e'));
          }
        } else {
          return Left(ValidationFailure(dataResponse['message']?.toString() ?? 'Failed to update question', {}));
        }
      },
    );
  }
}
