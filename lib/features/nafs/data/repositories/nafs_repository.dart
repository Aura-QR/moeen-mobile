import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';

class NafsRepository {
  Map<String, dynamic> _map(dynamic data) => Map<String, dynamic>.from(data as Map);

  List<NafsGradeOption> _parseOptionsData(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => NafsGradeOption.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['grades'] is List) {
        return (map['grades'] as List)
            .whereType<Map>()
            .map((e) => NafsGradeOption.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (map['data'] != null) {
        return _parseOptionsData(map['data']);
      }
      // If map keys are grades e.g. {"primary_3": {...}, "primary_6": {...}}
      final result = <NafsGradeOption>[];
      for (final entry in map.entries) {
        if (entry.value is Map) {
          final gradeJson = Map<String, dynamic>.from(entry.value as Map);
          gradeJson['id'] = gradeJson['id'] ?? entry.key;
          result.add(NafsGradeOption.fromJson(gradeJson));
        }
      }
      if (result.isNotEmpty) return result;
    }
    return const [];
  }

  Future<Either<Failure, List<NafsGradeOption>>> getOptions() => handleApiResponse(
        DioHelper.getData(url: nafsOptionsApi),
        _parseOptionsData,
      );

  Future<Either<Failure, NafsJob>> generate({
    required String grade,
    required String subject,
    required List<int> subjectIds,
    required List<String> domainIds,
    required List<String> domains,
    required int questionsCount,
    bool isRealExam = false,
  }) =>
      handleApiResponse(
        DioHelper.postData(url: nafsApi, data: {
          'grade': grade,
          'subject': subject,
          'subject_ids': subjectIds,
          if (subjectIds.isNotEmpty) 'subject_id': subjectIds.first,
          'domain_ids': domainIds,
          'domains': domains,
          'questions': questionsCount,
          'questions_count': questionsCount,
          'real_exam': isRealExam,
        }),
        (data) => NafsJob.fromJson(_map(data)),
      );

  Future<Either<Failure, NafsJob>> getJob(int id) => handleApiResponse(
        DioHelper.getData(url: '$aiJobsApi/$id'),
        (data) => NafsJob.fromJson(_map(data)),
      );

  Future<Either<Failure, int>> save({
    required String grade,
    required String subject,
    required List<int> subjectIds,
    required String title,
    String? passage,
    required List<NafsDomain> domains,
  }) =>
      handleApiResponse(
        DioHelper.postData(
          url: nafsSaveApi,
          data: {
            'grade': grade,
            'subject': subject,
            'subject_ids': subjectIds,
            'subject_id': subjectIds.isNotEmpty ? subjectIds.first : null,
            'title': title.trim(),
            'passage': (passage != null && passage.trim().isNotEmpty) ? passage.trim() : null,
            'kind': 'nafs',
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
