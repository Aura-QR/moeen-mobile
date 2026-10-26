import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/data/repositories/role_suites_repository.dart';

part 'role_suites_state.dart';

/// L1 «حقائب الأدوار»: loads the 4 role suites and orders the teacher's
/// portfolio role first when it matches.
class RoleSuitesCubit extends Cubit<RoleSuitesState> {
  static RoleSuitesCubit get(BuildContext context) => BlocProvider.of(context);

  RoleSuitesCubit({
    required RoleSuitesRepository rolesRepository,
    required PortfolioRepository portfolioRepository,
  }) : _roles = rolesRepository,
       _portfolios = portfolioRepository,
       super(const RoleSuitesState());

  final RoleSuitesRepository _roles;
  final PortfolioRepository _portfolios;

  Future<void> load() async {
    emit(state.copyWith(status: RoleSuitesStatus.loading));
    final rolesRequest = _roles.getRoles();
    final portfoliosRequest = _portfolios.getPortfolios();
    final rolesResult = await rolesRequest;
    final portfoliosResult = await portfoliosRequest;
    if (isClosed) return;

    rolesResult.fold(
      (failure) => emit(state.copyWith(status: RoleSuitesStatus.failure, errorMessage: failure.message)),
      (roles) {
        final portfolioRoles = portfoliosResult.fold(
          (_) => const <String>[],
          (portfolios) => portfolios.map((p) => p.role).toList(),
        );
        final matched = matchedRoleSuiteKey(roles, portfolioRoles);
        final sorted = sortRolesByPortfolio(roles, portfolioRoles);
        emit(
          state.copyWith(
            status: RoleSuitesStatus.success,
            roles: sorted,
            matchedRoleKey: matched,
            clearMatchedRole: matched == null,
          ),
        );
      },
    );
  }
}
