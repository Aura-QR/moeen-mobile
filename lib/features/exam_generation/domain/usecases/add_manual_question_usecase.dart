import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class AddManualQuestionUseCase {
  final ExamRepository repository;

  AddManualQuestionUseCase(this.repository);

  Future<Either<Failure, ExamEntity>> call(Map<String, dynamic> request) async {
    return await repository.addManualQuestion(request);
  }
}
