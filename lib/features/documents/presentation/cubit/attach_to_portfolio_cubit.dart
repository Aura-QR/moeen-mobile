import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

part 'attach_to_portfolio_state.dart';

/// Picks a portfolio and an item, then attaches a saved document as evidence.
class AttachToPortfolioCubit extends Cubit<AttachToPortfolioState> {
  static AttachToPortfolioCubit get(BuildContext context) => BlocProvider.of(context);

  AttachToPortfolioCubit({
    required this.documentId,
    required PortfolioRepository repository,
    this.suggestedItemKey,
  })  : _repo = repository,
        super(const AttachToPortfolioState());

  final int documentId;

  /// The item this tool's documents usually belong to; preselected if present.
  final String? suggestedItemKey;
  final PortfolioRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: AttachToPortfolioStatus.loading));
    final result = await _repo.getPortfolios();
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(state.copyWith(status: AttachToPortfolioStatus.failure, errorMessage: failure.message)),
      (portfolios) async {
        emit(state.copyWith(status: AttachToPortfolioStatus.success, portfolios: portfolios));
        if (portfolios.length == 1) await selectPortfolio(portfolios.first.id);
      },
    );
  }

  /// The list has no items, so this fetches the full portfolio.
  Future<void> selectPortfolio(int id) async {
    if (state.portfolio?.id == id) return;
    emit(state.copyWith(isLoadingItems: true, clearPortfolio: true, clearItem: true));
    final result = await _repo.getPortfolio(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoadingItems: false, feedback: UiFeedback(failure.message))),
      (portfolio) {
        final suggested = portfolio.items.where((item) => item.itemKey == suggestedItemKey).firstOrNull;
        emit(state.copyWith(
          isLoadingItems: false,
          portfolio: portfolio,
          selectedItemId: (suggested ?? portfolio.items.firstOrNull)?.id,
        ));
      },
    );
  }

  void selectItem(int itemId) => emit(state.copyWith(selectedItemId: itemId));

  Future<void> attach() async {
    final portfolio = state.portfolio;
    final itemId = state.selectedItemId;
    if (portfolio == null || itemId == null || state.isAttaching) return;

    emit(state.copyWith(isAttaching: true));
    final result = await _repo.attachDocument(
      portfolioId: portfolio.id,
      itemId: itemId,
      documentId: documentId,
    );
    if (isClosed) return;
    result.fold(
      // Includes 422 document_already_attached; the API message explains it.
      (failure) => emit(state.copyWith(isAttaching: false, feedback: UiFeedback(failure.message))),
      (_) => emit(state.copyWith(isAttaching: false, attached: true)),
    );
  }
}
