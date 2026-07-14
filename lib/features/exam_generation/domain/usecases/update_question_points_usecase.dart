import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class UpdateQuestionPointsUseCase {
  final ExamRepository repository;

  UpdateQuestionPointsUseCase(this.repository);

  Future<Either<Failure, ExamEntity>> execute(int examId, List<Map<String, dynamic>> questions) {
    return repository.updateExamPoints(examId, questions);
  }
}
