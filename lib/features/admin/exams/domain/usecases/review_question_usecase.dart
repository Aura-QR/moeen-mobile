import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';
import 'package:moean/features/admin/exams/domain/repositories/admin_exam_repository.dart';

class ReviewQuestionUseCase {
  final AdminExamRepository repository;

  ReviewQuestionUseCase(this.repository);

  Future<Either<Failure, AdminQuestionEntity>> call({
    required int questionId,
    required String decision,
  }) {
    return repository.reviewQuestion(
      questionId: questionId,
      decision: decision,
    );
  }
}
