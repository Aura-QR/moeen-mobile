import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class GetMyQuestionsUseCase {
  final ExamRepository repository;

  GetMyQuestionsUseCase(this.repository);

  Future<Either<Failure, QuestionPaginationEntity>> execute({
    int page = 1,
    int perPage = 20,
    String? type,
    String? difficulty,
    String? reviewStatus,
    int? lessonId,
    String? search,
  }) {
    return repository.getMyQuestions(
      page: page,
      perPage: perPage,
      type: type,
      difficulty: difficulty,
      reviewStatus: reviewStatus,
      lessonId: lessonId,
      search: search,
    );
  }
}
