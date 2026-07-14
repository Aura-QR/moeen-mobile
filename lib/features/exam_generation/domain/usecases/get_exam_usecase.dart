import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class GetExamUseCase {
  final ExamRepository repository;

  GetExamUseCase(this.repository);

  Future<Either<Failure, ExamEntity>> execute(int id) {
    return repository.getExam(id);
  }
}
