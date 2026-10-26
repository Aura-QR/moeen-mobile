import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/data/repositories/role_suites_repository.dart';
import 'package:moean/features/role_suites/presentation/cubit/role_suites_cubit.dart';

class MockRoleSuitesRepository extends Mock implements RoleSuitesRepository {}

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

const _roles = [
  RoleSuiteSummary(key: 'vice_principal', label: 'وكيل شؤون الطلاب', documentsCount: 10),
  RoleSuiteSummary(key: 'activity_leader', label: 'رائد النشاط', documentsCount: 15),
  RoleSuiteSummary(key: 'health_guide', label: 'الموجه الصحي', documentsCount: 12),
  RoleSuiteSummary(key: 'student_counsellor', label: 'الموجه الطلابي', documentsCount: 18),
];

PortfolioModel _portfolio(String role) => PortfolioModel.fromJson({
      'id': 1,
      'title': 'ملفي',
      'role': role,
    });

void main() {
  late MockRoleSuitesRepository rolesRepo;
  late MockPortfolioRepository portfolioRepo;

  setUp(() {
    rolesRepo = MockRoleSuitesRepository();
    portfolioRepo = MockPortfolioRepository();
    when(() => rolesRepo.getRoles()).thenAnswer((_) async => const Right(_roles));
    when(() => portfolioRepo.getPortfolios()).thenAnswer((_) async => const Right([]));
  });

  test('loads the 4 role cards and puts the teacher portfolio role first', () async {
    when(() => portfolioRepo.getPortfolios()).thenAnswer(
      (_) async => Right([_portfolio('student_counselor')]),
    );
    final cubit = RoleSuitesCubit(rolesRepository: rolesRepo, portfolioRepository: portfolioRepo);

    await cubit.load();

    expect(cubit.state.status, RoleSuitesStatus.success);
    expect(cubit.state.matchedRoleKey, 'student_counsellor');
    expect(cubit.state.roles.first.key, 'student_counsellor');
    expect(cubit.state.roles, hasLength(4));
    await cubit.close();
  });

  test('still shows all 4 roles when loading portfolios fails', () async {
    when(() => portfolioRepo.getPortfolios()).thenAnswer(
      (_) async => const Left(ServerFailure('network_error')),
    );
    final cubit = RoleSuitesCubit(rolesRepository: rolesRepo, portfolioRepository: portfolioRepo);

    await cubit.load();

    expect(cubit.state.status, RoleSuitesStatus.success);
    expect(cubit.state.matchedRoleKey, isNull);
    expect(cubit.state.roles.map((r) => r.key).toList(), [
      'vice_principal',
      'activity_leader',
      'health_guide',
      'student_counsellor',
    ]);
    await cubit.close();
  });

  test('emits failure when GET /tools/roles fails', () async {
    when(() => rolesRepo.getRoles()).thenAnswer(
      (_) async => const Left(ServerFailure('network_error')),
    );
    final cubit = RoleSuitesCubit(rolesRepository: rolesRepo, portfolioRepository: portfolioRepo);

    await cubit.load();

    expect(cubit.state.status, RoleSuitesStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
    await cubit.close();
  });
}
