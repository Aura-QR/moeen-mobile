import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/my_documents_cubit.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

DocumentModel _doc(int id) => DocumentModel(
      id: id,
      type: DocumentTypes.strategyDocumentation,
      title: 'مستند $id',
      status: DocumentStatus.draft,
    );

DocumentsPageModel _page(List<int> ids, {int page = 1, int lastPage = 1}) => DocumentsPageModel(
      items: ids.map(_doc).toList(),
      currentPage: page,
      lastPage: lastPage,
      total: ids.length,
    );

void main() {
  late MockDocumentsRepository repo;
  late MyDocumentsCubit cubit;

  setUp(() {
    repo = MockDocumentsRepository();
    cubit = MyDocumentsCubit(repo, searchDebounce: Duration.zero);
  });

  tearDown(() => cubit.close());

  test('load shows the first page', () async {
    when(() => repo.getDocuments(type: null, search: '')).thenAnswer((_) async => Right(_page([1, 2], lastPage: 2)));
    await cubit.load();

    expect(cubit.state.status, MyDocumentsStatus.success);
    expect(cubit.state.documents.map((d) => d.id), [1, 2]);
    expect(cubit.state.hasMore, isTrue);
  });

  test('load failure on an empty list shows the error view', () async {
    when(() => repo.getDocuments(type: null, search: ''))
        .thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.load();

    expect(cubit.state.status, MyDocumentsStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('loadMore appends the next page and stops at the last', () async {
    when(() => repo.getDocuments(type: null, search: '')).thenAnswer((_) async => Right(_page([1], lastPage: 2)));
    when(() => repo.getDocuments(page: 2, type: null, search: ''))
        .thenAnswer((_) async => Right(_page([2], page: 2, lastPage: 2)));
    await cubit.load();
    await cubit.loadMore();
    await cubit.loadMore();

    expect(cubit.state.documents.map((d) => d.id), [1, 2]);
    verify(() => repo.getDocuments(page: 2, type: null, search: '')).called(1);
  });

  test('setType reloads with the filter', () async {
    when(() => repo.getDocuments(type: DocumentTypes.strategyDocumentation, search: ''))
        .thenAnswer((_) async => Right(_page([7])));
    await cubit.setType(DocumentTypes.strategyDocumentation);

    expect(cubit.state.type, DocumentTypes.strategyDocumentation);
    expect(cubit.state.documents.single.id, 7);
  });

  test('search waits for the debounce, then sends the trimmed query', () async {
    when(() => repo.getDocuments(type: null, search: 'جيكسو')).thenAnswer((_) async => Right(_page([3])));
    cubit.searchController.text = ' جيكسو ';
    cubit.onSearchChanged(' جيكسو ');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state.documents.single.id, 3);
  });

  test('duplicate puts the copy first', () async {
    when(() => repo.getDocuments(type: null, search: '')).thenAnswer((_) async => Right(_page([1])));
    when(() => repo.duplicateDocument(1)).thenAnswer((_) async => Right(_doc(9)));
    await cubit.load();
    await cubit.duplicate(_doc(1));

    expect(cubit.state.documents.map((d) => d.id), [9, 1]);
    expect(cubit.state.busyId, isNull);
    expect(cubit.state.feedback?.isError, isFalse);
  });

  test('delete removes it; a failure keeps it', () async {
    when(() => repo.getDocuments(type: null, search: '')).thenAnswer((_) async => Right(_page([1, 2])));
    when(() => repo.deleteDocument(1)).thenAnswer((_) async => const Right(unit));
    when(() => repo.deleteDocument(2)).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.load();
    await cubit.delete(_doc(1));
    await cubit.delete(_doc(2));

    expect(cubit.state.documents.map((d) => d.id), [2]);
    expect(cubit.state.feedback?.message, 'network_error');
  });
}
