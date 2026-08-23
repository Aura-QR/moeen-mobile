import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';

/// Repository covering all 7 curriculum endpoints described in
/// CURRICULUM_DISTRIBUTION_AND_BOOKS.md § 6. API
class CurriculumRepository {
  // ── Public: Plans ──────────────────────────────────────────────────────────

  /// GET /api/curriculum/plans?subject_id=&semester=
  Future<Either<String, List<CurriculumPlanModel>>> getPlans({
    int? subjectId,
    int? semester,
  }) async {
    final query = <String, dynamic>{};
    if (subjectId != null) query['subject_id'] = subjectId;
    if (semester != null) query['semester'] = semester;

    final response = await DioHelper.getData(url: curriculumPlansApi, query: query);
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = res.data;
          final list = (data['data'] ?? data) as List<dynamic>;
          return Right(
            list
                .map((e) => CurriculumPlanModel.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  /// GET /api/curriculum/plans/{plan}?region=west
  Future<Either<String, CurriculumPlanDetailModel>> getPlanDetail(
    int planId, {
    String? region,
  }) async {
    final query = <String, dynamic>{};
    if (region != null) query['region'] = region;

    final response = await DioHelper.getData(
      url: curriculumPlanDetailApi(planId),
      query: query,
    );
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
          return Right(CurriculumPlanDetailModel.fromJson(data));
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  /// GET /api/curriculum/plans/{plan}/weeks/current?date=
  Future<Either<String, CurriculumWeekModel>> getCurrentWeek(
    int planId, {
    String? date,
  }) async {
    final query = <String, dynamic>{};
    if (date != null) query['date'] = date;

    final response = await DioHelper.getData(
      url: curriculumPlanCurrentWeekApi(planId),
      query: query,
    );
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
          return Right(CurriculumWeekModel.fromJson(data));
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  // ── Public: Books ──────────────────────────────────────────────────────────

  /// GET /api/curriculum/books?subject_id=|grade_id=
  Future<Either<String, List<CurriculumBookModel>>> getBooks({
    int? subjectId,
    int? gradeId,
  }) async {
    final query = <String, dynamic>{};
    if (subjectId != null) query['subject_id'] = subjectId;
    if (gradeId != null) query['grade_id'] = gradeId;

    final response = await DioHelper.getData(url: curriculumBooksApi, query: query);
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = res.data;
          final list = (data['data'] ?? data) as List<dynamic>;
          
          List<CurriculumBookModel> books = [];
          for (var item in list) {
            if (item is Map<String, dynamic>) {
              // If the item has a 'books' array, it means the response is grouped by subject
              if (item.containsKey('books') && item['books'] is List) {
                final subjectName = item['subject_name'] ?? item['name'] ?? '';
                for (var bookJson in item['books']) {
                  final b = bookJson as Map<String, dynamic>;
                  // Inject the subject name into the book json so the model parses it
                  b['subject_name'] = subjectName;
                  books.add(CurriculumBookModel.fromJson(b));
                }
              } else {
                // Otherwise, it's a flat list of books
                books.add(CurriculumBookModel.fromJson(item));
              }
            }
          }
          
          return Right(books);
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  /// GET /api/curriculum/books/{book}/download → { url, expires_at, file_name, size_mb }
  Future<Either<String, CurriculumBookDownloadModel>> getBookDownloadUrl(
    int bookId,
  ) async {
    final response = await DioHelper.getData(
      url: curriculumBookDownloadApi(bookId),
    );
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
          return Right(CurriculumBookDownloadModel.fromJson(data));
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  // ── Authenticated: Teacher-specific ───────────────────────────────────────

  /// GET /api/curriculum/progress?subject_id=&semester=
  Future<Either<String, CurriculumProgressModel>> getProgress({
    required int subjectId,
    required int semester,
  }) async {
    final response = await DioHelper.getData(
      url: curriculumProgressApi,
      query: {'subject_id': subjectId, 'semester': semester},
    );
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
          return Right(CurriculumProgressModel.fromJson(data));
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }

  /// POST /api/curriculum/plans/{plan}/weeks/{week}/prepare
  Future<Either<String, Map<String, dynamic>>> prepareWeek({
    required int planId,
    required int weekId,
  }) async {
    final response = await DioHelper.postData(
      url: curriculumPlanWeekPrepareApi(planId, weekId),
      data: {},
    );
    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
          return Right(data);
        } catch (e) {
          return Left(e.toString());
        }
      },
    );
  }
}
