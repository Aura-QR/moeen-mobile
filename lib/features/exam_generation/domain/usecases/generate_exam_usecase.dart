import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';

class GenerateExamUseCase {
  final ExamRepository repository;

  GenerateExamUseCase(this.repository);

  Future<Either<Failure, ExamEntity>> execute({
    required String title,
    required String grade,
    required String subject,
    required List<Map<String, dynamic>> lessons,
  }) {
    return repository.generateExam(
      title: title,
      grade: grade,
      subject: subject,
      lessons: lessons,
    );
  }
}
