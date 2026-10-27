import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_maps_cubit.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

void main() {
  late MockDocumentsRepository documents;
  late ConceptMapsCubit cubit;

  const sampleDoc = DocumentModel(
    id: 10,
    type: DocumentTypes.conceptMap,
    title: 'خريطة المادة',
    status: DocumentStatus.draft,
  );

  setUp(() {
    documents = MockDocumentsRepository();
    cubit = ConceptMapsCubit(
      documentsRepository: documents,
      searchDebounce: const Duration(milliseconds: 10),
    );
  });

  tearDown(() => cubit.close());

  test('load fetches concept_map documents', () async {
    when(
      () => documents.getDocuments(type: DocumentTypes.conceptMap, search: ''),
    ).thenAnswer(
      (_) async => const Right(
        DocumentsPageModel(
          items: [sampleDoc],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ),
      ),
    );

    await cubit.load();

    expect(cubit.state.status, ConceptMapsStatus.success);
    expect(cubit.state.documents.single.id, 10);
  });

  test('duplicate prepends copied document', () async {
    const copy = DocumentModel(
      id: 11,
      type: DocumentTypes.conceptMap,
      title: 'خريطة المادة (نسخة)',
      status: DocumentStatus.draft,
    );
    when(
      () => documents.getDocuments(type: DocumentTypes.conceptMap, search: ''),
    ).thenAnswer(
      (_) async => const Right(
        DocumentsPageModel(
          items: [sampleDoc],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ),
      ),
    );
    when(
      () => documents.duplicateDocument(10),
    ).thenAnswer((_) async => const Right(copy));

    await cubit.load();
    await cubit.duplicate(10);

    expect(cubit.state.documents.length, 2);
    expect(cubit.state.documents.first.id, 11);
  });

  test('deleteDocument removes document from state', () async {
    when(
      () => documents.getDocuments(type: DocumentTypes.conceptMap, search: ''),
    ).thenAnswer(
      (_) async => const Right(
        DocumentsPageModel(
          items: [sampleDoc],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ),
      ),
    );
    when(
      () => documents.deleteDocument(10),
    ).thenAnswer((_) async => const Right(unit));

    await cubit.load();
    await cubit.deleteDocument(10);

    expect(cubit.state.documents, isEmpty);
  });
}
