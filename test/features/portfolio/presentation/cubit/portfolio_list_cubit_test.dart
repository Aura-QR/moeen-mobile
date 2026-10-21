import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_list_cubit.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

PortfolioModel _portfolio(int id) => PortfolioModel.fromJson({
      'id': id,
      'title': 'ملف $id',
      'role': 'teacher',
      'role_label': 'معلم',
      'completion': {'included': 11, 'complete': 0, 'percent': 0, 'missing': []},
    });

void main() {
  late MockPortfolioRepository repo;
  late PortfolioListCubit cubit;

  setUp(() {
    repo = MockPortfolioRepository();
    cubit = PortfolioListCubit(repo);
  });

  tearDown(() => cubit.close());

  test('loadPortfolios shows the list', () async {
    when(() => repo.getPortfolios()).thenAnswer((_) async => Right([_portfolio(1), _portfolio(2)]));
    await cubit.loadPortfolios();

    expect(cubit.state.status, PortfolioListStatus.success);
    expect(cubit.state.portfolios.length, 2);
  });

  test('loadPortfolios keeps the failure message', () async {
    when(() => repo.getPortfolios()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.loadPortfolios();

    expect(cubit.state.status, PortfolioListStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('loadRoles fetches once', () async {
    when(() => repo.getRoles()).thenAnswer((_) async => const Right(PortfolioRolesModel(roles: [])));
    await cubit.loadRoles();
    await cubit.loadRoles();

    verify(() => repo.getRoles()).called(1);
    expect(cubit.state.roles, isNotNull);
  });

  test('createPortfolio adds it first and hands it over once', () async {
    when(() => repo.getPortfolios()).thenAnswer((_) async => Right([_portfolio(1)]));
    when(() => repo.createPortfolio(role: 'teacher', title: 'جديد')).thenAnswer((_) async => Right(_portfolio(9)));
    await cubit.loadPortfolios();
    await cubit.createPortfolio(role: 'teacher', title: ' جديد ');

    expect(cubit.state.portfolios.map((p) => p.id), [9, 1]);
    expect(cubit.state.created?.id, 9);
    expect(cubit.state.isCreating, isFalse);
  });

  test('createPortfolio at the limit shows the API message', () async {
    when(() => repo.createPortfolio(role: 'teacher', title: ''))
        .thenAnswer((_) async => const Left(ServerFailure('وصلت للحد الأقصى: 5 ملفات')));
    await cubit.createPortfolio(role: 'teacher', title: '');

    expect(cubit.state.feedback, 'وصلت للحد الأقصى: 5 ملفات');
    expect(cubit.state.created, isNull);
  });
}
