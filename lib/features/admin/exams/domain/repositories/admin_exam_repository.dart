import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';

abstract class AdminExamRepository {
  Future<Either<Failure, AdminQuestionPaginationEntity>> getPendingQuestions({
    int page = 1,
    String? type,
    String? difficulty,
    int? lessonId,
  });

  Future<Either<Failure, AdminQuestionEntity>> reviewQuestion({
    required int questionId,
    required String decision,
    String? rejectionReason,
  });
}
