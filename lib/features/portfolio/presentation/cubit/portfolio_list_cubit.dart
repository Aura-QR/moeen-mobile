import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

part 'portfolio_list_state.dart';

class PortfolioListCubit extends Cubit<PortfolioListState> {
  static PortfolioListCubit get(BuildContext context) => BlocProvider.of(context);

  PortfolioListCubit(this._repo) : super(const PortfolioListState());

  final PortfolioRepository _repo;

  Future<void> loadPortfolios() async {
    if (state.portfolios.isEmpty) {
      emit(state.copyWith(status: PortfolioListStatus.loading));
    }
    final result = await _repo.getPortfolios();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: PortfolioListStatus.failure,
        errorMessage: failure.message,
      )),
      (portfolios) => emit(state.copyWith(
        status: PortfolioListStatus.success,
        portfolios: portfolios,
      )),
    );
  }

  /// Roles are fetched once, when the create sheet first opens.
  Future<void> loadRoles() async {
    if (state.roles != null || state.isLoadingRoles) return;
    emit(state.copyWith(isLoadingRoles: true));
    final result = await _repo.getRoles();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoadingRoles: false, feedback: failure.message)),
      (roles) => emit(state.copyWith(isLoadingRoles: false, roles: roles)),
    );
  }

  Future<void> createPortfolio({required String role, String? title}) async {
    emit(state.copyWith(isCreating: true));
    final result = await _repo.createPortfolio(role: role, title: title?.trim());
    if (isClosed) return;
    result.fold(
      // Includes 422 portfolio_limit at 5 portfolios; the API message explains it.
      (failure) => emit(state.copyWith(isCreating: false, feedback: failure.message)),
      (portfolio) => emit(state.copyWith(
        isCreating: false,
        status: PortfolioListStatus.success,
        portfolios: [portfolio, ...state.portfolios],
        created: portfolio,
      )),
    );
  }
}
