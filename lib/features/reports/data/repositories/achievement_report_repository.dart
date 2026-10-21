import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/reports/data/models/achievement_period.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';

class AchievementReportRepository {
  /// GET /api/reports/achievements?period=&date=
  Future<Either<Failure, AchievementReportModel>> getReport({
    required AchievementPeriod period,
    required DateTime date,
  }) async {
    final response = await DioHelper.getData(
      url: achievementReportApi,
      query: {'period': period.apiValue, 'date': formatApiDate(date)},
    );
    return response.fold(
      (error) => Left(failureFromApiError(error)),
      (res) {
        try {
          final body = res.data as Map<String, dynamic>;
          return Right(AchievementReportModel.fromJson(body['data'] as Map<String, dynamic>));
        } catch (_) {
          return const Left(ServerFailure('generic_error'));
        }
      },
    );
  }
}
