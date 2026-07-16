import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/admin/exams/data/datasources/admin_exam_remote_data_source.dart';
import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';
import 'package:moean/features/admin/exams/domain/repositories/admin_exam_repository.dart';

class AdminExamRepositoryImpl implements AdminExamRepository {
  final AdminExamRemoteDataSource remoteDataSource;

  AdminExamRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AdminQuestionPaginationEntity>> getPendingQuestions({
    int page = 1,
    String? type,
    String? difficulty,
    int? lessonId,
  }) async {
    try {
      final result = await remoteDataSource.getPendingQuestions(
        page: page,
        type: type,
        difficulty: difficulty,
        lessonId: lessonId,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure(e.message ?? e.toString()));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminQuestionEntity>> reviewQuestion({
    required int questionId,
    required String decision,
    String? rejectionReason,
  }) async {
    try {
      final result = await remoteDataSource.reviewQuestion(
        questionId: questionId,
        decision: decision,
        rejectionReason: rejectionReason,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure(e.message ?? e.toString()));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
