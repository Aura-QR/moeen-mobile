import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';

class TahsiliRepository {
  Map<String, dynamic> _map(dynamic data) => Map<String, dynamic>.from(data as Map);

  Future<Either<Failure, TahsiliOptions>> getOptions() => handleApiResponse(
        DioHelper.getData(url: tahsiliOptionsApi),
        (data) => TahsiliOptions.fromJson(data),
        unwrapData: false,
      );

  Future<Either<Failure, TahsiliJob>> generate({
    required String subject,
    required List<String> domainIds,
    required int questionsCount,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: tahsiliApi, data: {
          'subject': subject,
          'domain_ids': domainIds,
          'domains': domainIds,
          'questions': questionsCount,
          'questions_count': questionsCount,
        }),
        (data) => TahsiliJob.fromJson(_map(data)),
      );

  Future<Either<Failure, TahsiliJob>> getJob(int id) => handleApiResponse(
        DioHelper.getData(url: '$aiJobsApi/$id'),
        (data) => TahsiliJob.fromJson(_map(data)),
      );

  Future<Either<Failure, int>> save({
    required String subject,
    required String title,
    required List<TahsiliDomain> domains,
  }) =>
      handleApiResponse(
        DioHelper.postData(
          url: tahsiliSaveApi,
          data: {
            'subject': subject,
            'title': title.trim(),
            'kind': 'tahsili',
            'skills': domains.map((d) => d.toJson()).toList(),
            'domains': domains.map((d) => d.toJson()).toList(),
          },
          keepFieldErrors: true,
        ),
        (body) {
          final m = _map(body);
          if (m['exam'] is Map) {
            return (_map(m['exam'])['id'] as num).toInt();
          }
          if (m['id'] is num) {
            return (m['id'] as num).toInt();
          }
          if (m['data'] is Map && _map(m['data'])['id'] is num) {
            return (_map(m['data'])['id'] as num).toInt();
          }
          return 0;
        },
        unwrapData: false,
      );
}
