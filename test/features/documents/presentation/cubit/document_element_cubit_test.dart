import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_element_cubit.dart';
import 'package:moean/features/portfolio/data/models/portfolio_element_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
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

const _elements = PortfolioElementsModel(elements: [], forms: {
  'teacher': [
    PortfolioElementModel(key: 'teaching_strategies', title: 'التنويع في استراتيجيات التدريس', number: 4, weight: 10),
    PortfolioElementModel(key: 'learner_results', title: 'تحسين نتائج المتعلمين', number: 5, weight: 10),
  ],
  'health_guide': [
    PortfolioElementModel(key: 'health_awareness', title: 'التوعية الصحية', number: 12, weight: 15),
  ],
  'activity_leader': [
    PortfolioElementModel(key: 'activity_plan', title: 'خطة النشاط', number: 12, weight: 5),
  ],
});

PortfolioModel _portfolio(String role, String updatedAt) => PortfolioModel.fromJson({
      'id': 1,
      'title': 'ملف',
      'role': role,
      'role_label': role,
      'updated_at': updatedAt,
    });

void main() {
  late MockDocumentsRepository documents;
  late MockPortfolioRepository portfolios;

  setUp(() {
    documents = MockDocumentsRepository();
    portfolios = MockPortfolioRepository();
    when(() => portfolios.getElements()).thenAnswer((_) async => const Right(_elements));
    when(() => portfolios.getPortfolios()).thenAnswer((_) async => const Right([]));
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

  test('no portfolio lists the teacher\'s form', () async {
    final c = cubit(known: true);

    await c.load();

    expect(c.state.options.map((e) => e.key), ['teaching_strategies', 'learner_results']);
    await c.close();
  });

  test('lists the form of the most recently updated portfolio\'s role', () async {
    when(() => portfolios.getPortfolios()).thenAnswer((_) async => Right([
          _portfolio('activity_leader', '2026-10-01T08:00:00+00:00'),
          _portfolio('health_guide', '2026-11-20T08:00:00+00:00'),
          _portfolio('teacher', '2026-09-01T08:00:00+00:00'),
        ]));
    final c = cubit(known: true);

    await c.load();

    expect(c.state.options.map((e) => e.key), ['health_awareness']);
    await c.close();
  });

  test('keeps the current element at the end when it isn\'t in the form', () async {
    when(() => portfolios.getPortfolios())
        .thenAnswer((_) async => Right([_portfolio('health_guide', '2026-11-20T08:00:00+00:00')]));
    final c = cubit(element: 'learner_results', known: true);

    await c.load();

    expect(c.state.options.map((e) => e.key), ['health_awareness', 'learner_results']);
    expect(c.state.current?.title, 'تحسين نتائج المتعلمين');
    expect(c.state.current?.number, isNull);
    await c.close();
  });

  test('a failed portfolios request shows the error', () async {
    when(() => portfolios.getPortfolios()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final c = cubit(known: true);

    await c.load();

    expect(c.state.status, DocumentElementStatus.failure);
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
