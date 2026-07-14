import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

abstract class ExamRepository {
  Future<Either<Failure, ExamEntity>> generateExam({
    required String title,
    required String grade,
    required String subject,
    required List<Map<String, dynamic>> lessons,
  });

  Future<Either<Failure, ExamEntity>> getExam(int id);

  Future<Either<Failure, ExamEntity>> updateExamPoints(int id, List<Map<String, dynamic>> questions);

  Future<Either<Failure, Map<String, dynamic>>> getExams({int page = 1, int perPage = 20, String? status});

  Future<Either<Failure, ExamPaginationEntity>> getMyExams({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  });

  Future<Either<Failure, ExamEntity>> publishExam(int id);

  Future<Either<Failure, bool>> deleteExam(int id);

  Future<Either<Failure, ExamEntity>> addManualQuestion(Map<String, dynamic> request);
}
