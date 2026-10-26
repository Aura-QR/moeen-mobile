import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_element_cubit.dart';
import 'package:moean/features/portfolio/data/models/portfolio_element_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

DocumentModel _document(String? element) => DocumentModel.fromJson({
      'id': 12,
      'type': 'strategy_documentation',
      'title': 'توثيق جيكسو',
      'status': 'draft',
      'element': element,
    });

const _elements = PortfolioElementsModel(elements: [
  PortfolioElementModel(key: 'teaching_strategies', title: 'التنويع في استراتيجيات التدريس', number: 4, weight: 10),
  PortfolioElementModel(key: 'learner_results', title: 'تحسين نتائج المتعلمين', number: 5, weight: 10),
]);

void main() {
  late MockDocumentsRepository documents;
  late MockPortfolioRepository portfolios;

  setUp(() {
    documents = MockDocumentsRepository();
    portfolios = MockPortfolioRepository();
    when(() => portfolios.getElements()).thenAnswer((_) async => const Right(_elements));
  });

  DocumentElementCubit cubit({String? element, bool known = false}) => DocumentElementCubit(
        documentId: 12,
        documents: documents,
        portfolios: portfolios,
        element: element,
        elementKnown: known,
      );

  test('loads the document for its element when it isn\'t known', () async {
    when(() => documents.getDocument(12)).thenAnswer((_) async => Right(_document('teaching_strategies')));
    final c = cubit();

    await c.load();

    expect(c.state.status, DocumentElementStatus.ready);
    expect(c.state.current?.number, 4);
    await c.close();
  });

  test('a known element skips the document request', () async {
    final c = cubit(element: 'learner_results', known: true);

    await c.load();

    verifyNever(() => documents.getDocument(any()));
    expect(c.state.element, 'learner_results');
    await c.close();
  });

  test('a failed load shows the error', () async {
    when(() => portfolios.getElements()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final c = cubit(known: true);

    await c.load();

    expect(c.state.status, DocumentElementStatus.failure);
    expect(c.state.errorMessage, 'network_error');
    await c.close();
  });

  test('change moves the document to another element', () async {
    when(() => documents.setElement(12, 'learner_results')).thenAnswer((_) async => Right(_document('learner_results')));
    final c = cubit(element: 'teaching_strategies', known: true);
    await c.load();

    await c.change('learner_results');

    expect(c.state.element, 'learner_results');
    expect(c.state.changed, isTrue);
    await c.close();
  });

  test('change to none keeps it out of the file', () async {
    when(() => documents.setElement(12, null)).thenAnswer((_) async => Right(_document(null)));
    final c = cubit(element: 'teaching_strategies', known: true);
    await c.load();

    await c.change(null);

    expect(c.state.element, isNull);
    expect(c.state.changed, isTrue);
    await c.close();
  });

  test('the same element is not sent again', () async {
    final c = cubit(element: 'teaching_strategies', known: true);
    await c.load();

    await c.change('teaching_strategies');

    verifyNever(() => documents.setElement(any(), any()));
    await c.close();
  });
}
