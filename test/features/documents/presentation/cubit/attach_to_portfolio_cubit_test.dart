import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/presentation/cubit/attach_to_portfolio_cubit.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

PortfolioModel _portfolio(int id, {bool withItems = false}) => PortfolioModel.fromJson({
      'id': id,
      'title': 'ملف $id',
      'role': 'teacher',
      'role_label': 'معلم',
      'completion': {'included': 2, 'complete': 0, 'percent': 0, 'missing': []},
      if (withItems)
        'items': [
          {'id': 1, 'item_key': 'duties', 'title': 'أداء الواجبات', 'sort_order': 1, 'files': []},
          {'id': 2, 'item_key': 'teaching_strategies', 'title': 'التنويع في الاستراتيجيات', 'sort_order': 2, 'files': []},
        ],
    });

void main() {
  late MockPortfolioRepository repo;
  late AttachToPortfolioCubit cubit;

  setUp(() {
    repo = MockPortfolioRepository();
    cubit = AttachToPortfolioCubit(documentId: 12, repository: repo, suggestedItemKey: 'teaching_strategies');
  });

  tearDown(() => cubit.close());

  test('one portfolio is selected with the suggested item preselected', () async {
    when(() => repo.getPortfolios()).thenAnswer((_) async => Right([_portfolio(5)]));
    when(() => repo.getPortfolio(5)).thenAnswer((_) async => Right(_portfolio(5, withItems: true)));
    await cubit.load();

    expect(cubit.state.portfolio?.id, 5);
    expect(cubit.state.selectedItemId, 2);
  });

  test('several portfolios wait for the teacher to pick', () async {
    when(() => repo.getPortfolios()).thenAnswer((_) async => Right([_portfolio(5), _portfolio(6)]));
    await cubit.load();

    expect(cubit.state.portfolios.length, 2);
    expect(cubit.state.portfolio, isNull);
    verifyNever(() => repo.getPortfolio(any()));
  });

  test('without the suggested item the first one is selected', () async {
    final noSuggested = AttachToPortfolioCubit(documentId: 12, repository: repo);
    when(() => repo.getPortfolio(5)).thenAnswer((_) async => Right(_portfolio(5, withItems: true)));
    await noSuggested.selectPortfolio(5);

    expect(noSuggested.state.selectedItemId, 1);
    await noSuggested.close();
  });

  test('attach sends the document to the chosen item', () async {
    when(() => repo.getPortfolio(5)).thenAnswer((_) async => Right(_portfolio(5, withItems: true)));
    when(() => repo.attachDocument(portfolioId: 5, itemId: 1, documentId: 12)).thenAnswer((_) async => const Right(unit));
    await cubit.selectPortfolio(5);
    cubit.selectItem(1);
    await cubit.attach();

    expect(cubit.state.attached, isTrue);
  });

  test('already attached shows the API message', () async {
    when(() => repo.getPortfolio(5)).thenAnswer((_) async => Right(_portfolio(5, withItems: true)));
    when(() => repo.attachDocument(portfolioId: 5, itemId: 2, documentId: 12))
        .thenAnswer((_) async => const Left(ServerFailure('هذا المستند مضاف بالفعل لهذا البند.')));
    await cubit.selectPortfolio(5);
    await cubit.attach();

    expect(cubit.state.attached, isFalse);
    expect(cubit.state.feedback?.message, 'هذا المستند مضاف بالفعل لهذا البند.');
    expect(cubit.state.isAttaching, isFalse);
  });
}
