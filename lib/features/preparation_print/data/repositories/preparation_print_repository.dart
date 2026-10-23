import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/preparation_print/data/models/preparation_print_models.dart';

class PreparationPrintRepository {
  /// [onlyDone] lists only the preparations that can be printed.
  Future<Either<Failure, PreparationsPage>> getPreparations({int page = 1, bool onlyDone = true}) => handleApiResponse(
        DioHelper.getData(url: preparationsApi, query: {'page': page, if (onlyDone) 'status': 'done'}),
        (body) => PreparationsPage.fromJson(body as Map<String, dynamic>),
        unwrapData: false,
      );

  /// A new editable `lesson_preparation` document, one page per id, in this order.
  Future<Either<Failure, DocumentModel>> createDocument(List<int> preparationIds) => handleApiResponse(
        DioHelper.postData(url: preparationDocumentApi, data: {'preparation_ids': preparationIds}),
        (data) => DocumentModel.fromJson(data as Map<String, dynamic>),
      );
}
