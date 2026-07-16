import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';
import 'package:moean/features/admin/exams/domain/repositories/admin_exam_repository.dart';

class GetPendingQuestionsUseCase {
  final AdminExamRepository repository;

  GetPendingQuestionsUseCase(this.repository);

  Future<Either<Failure, AdminQuestionPaginationEntity>> call({
    int page = 1,
    String? type,
    String? difficulty,
    int? lessonId,
  }) {
    return repository.getPendingQuestions(
      page: page,
      type: type,
      difficulty: difficulty,
      lessonId: lessonId,
    );
  }
}
