import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/class_sheets/data/models/class_sheets_catalogue_model.dart';

class ClassSheetsRepository {
  /// Loads the sheet kinds and default configs from the backend.
  Future<Either<Failure, List<SheetKindModel>>> getCatalogue() async {
    final response = await handleApiResponse(
      DioHelper.getData(url: sheetsToolApi),
      (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(SheetKindModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic>) {
          final list = data['sheets'] ?? data['kinds'] ?? data['data'];
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map(SheetKindModel.fromJson)
                .toList();
          }
        }
        return SheetKindModel.fallbackKinds;
      },
    );

    return response.fold(
      (_) => const Right(SheetKindModel.fallbackKinds),
      (kinds) => Right(kinds.isEmpty ? SheetKindModel.fallbackKinds : kinds),
    );
  }
}
