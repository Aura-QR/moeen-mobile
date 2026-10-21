part of 'portfolio_list_cubit.dart';

enum PortfolioListStatus { initial, loading, success, failure }

class PortfolioListState {
  final PortfolioListStatus status;
  final List<PortfolioModel> portfolios;
  final PortfolioRolesModel? roles;
  final bool isLoadingRoles;
  final bool isCreating;

  /// Translation key or API message for the last failed load.
  final String? errorMessage;

  /// One-shot: a failed action to show in a snackbar.
  final String? feedback;

  /// One-shot: the portfolio just created, to open in the editor.
  final PortfolioModel? created;

  const PortfolioListState({
    this.status = PortfolioListStatus.initial,
    this.portfolios = const [],
    this.roles,
    this.isLoadingRoles = false,
    this.isCreating = false,
    this.errorMessage,
    this.feedback,
    this.created,
  });

  /// One-shot fields ([feedback], [created]) are cleared unless passed.
  PortfolioListState copyWith({
    PortfolioListStatus? status,
    List<PortfolioModel>? portfolios,
    PortfolioRolesModel? roles,
    bool? isLoadingRoles,
    bool? isCreating,
    String? errorMessage,
    String? feedback,
    PortfolioModel? created,
  }) {
    return PortfolioListState(
      status: status ?? this.status,
      portfolios: portfolios ?? this.portfolios,
      roles: roles ?? this.roles,
      isLoadingRoles: isLoadingRoles ?? this.isLoadingRoles,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: errorMessage ?? this.errorMessage,
      feedback: feedback,
      created: created,
    );
  }
}
