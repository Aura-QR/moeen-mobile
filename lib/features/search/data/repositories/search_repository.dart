import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/search/data/models/search_result_model.dart';

class SearchRepository {
  Future<Either<String, List<SearchResultModel>>> search({
    required String query,
    String? type,
    int limit = 20,
  }) async {
    final response = await DioHelper.getData(
      url: searchApi,
      query: {
        'query': query,
        if (type != null && type.isNotEmpty) 'type': type,
        'limit': limit,
      },
    );

    return response.fold(
      (error) => Left(error),
      (res) {
        try {
          final data = res.data;
          final List<SearchResultModel> results = [];

          if (data is Map<String, dynamic>) {
            final dataBody = data['data'];

            if (dataBody is Map<String, dynamic>) {
              // Grouped response: { questions: [...], resources: [...], ... }
              final typeKeys = {
                'questions': 'questions',
                'resources': 'resources',
                'exams': 'exams',
                'lessons': 'lessons',
              };
              typeKeys.forEach((key, label) {
                final items = dataBody[key];
                if (items is List) {
                  for (final item in items) {
                    if (item is Map<String, dynamic>) {
                      results.add(SearchResultModel.fromJson(item, label));
                    }
                  }
                }
              });
            } else if (dataBody is List) {
              // Flat list response
              for (final item in dataBody) {
                if (item is Map<String, dynamic>) {
                  final itemType = (item['type'] ?? type ?? 'resources').toString();
                  results.add(SearchResultModel.fromJson(item, itemType));
                }
              }
            }
          }

          return Right(results);
        } catch (_) {
          return const Left('حدث خطأ أثناء معالجة البيانات');
        }
      },
    );
  }
}
