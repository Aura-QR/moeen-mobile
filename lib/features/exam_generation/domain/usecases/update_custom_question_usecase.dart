import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class UpdateCustomQuestionUseCase {
  final ExamRepository repository;

  UpdateCustomQuestionUseCase(this.repository);

  Future<Either<Failure, QuestionEntity>> execute(int id, Map<String, dynamic> data) {
    return repository.updateCustomQuestion(id, data);
  }
}
