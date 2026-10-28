import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_maps_cubit.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

void main() {
  late MockDocumentsRepository documents;
  late OutcomesMapsCubit cubit;

  const sampleDoc = DocumentModel(
    id: 10,
    type: DocumentTypes.outcomesMap,
    title: 'خريطة نواتج التعلم',
    status: DocumentStatus.draft,
  );

  setUp(() {
    documents = MockDocumentsRepository();
    cubit = OutcomesMapsCubit(
      documentsRepository: documents,
      searchDebounce: const Duration(milliseconds: 10),
    );
  });

  tearDown(() => cubit.close());

  test('load fetches outcomes_map documents', () async {
    when(() => documents.getDocuments(type: DocumentTypes.outcomesMap, search: '')).thenAnswer(
      (_) async => const Right(
        DocumentsPageModel(items: [sampleDoc], currentPage: 1, lastPage: 1, total: 1),
      ),
    );

    await cubit.load();

    expect(cubit.state.status, OutcomesMapsStatus.success);
    expect(cubit.state.documents.single.id, 10);
  });

  test('deleteDocument removes it from the list', () async {
    when(() => documents.getDocuments(type: DocumentTypes.outcomesMap, search: '')).thenAnswer(
      (_) async => const Right(
        DocumentsPageModel(items: [sampleDoc], currentPage: 1, lastPage: 1, total: 1),
      ),
    );
    when(() => documents.deleteDocument(10)).thenAnswer((_) async => const Right(unit));

    await cubit.load();
    await cubit.deleteDocument(10);

    expect(cubit.state.documents, isEmpty);
    expect(cubit.state.feedback?.message, 'document_deleted');
  });
}
