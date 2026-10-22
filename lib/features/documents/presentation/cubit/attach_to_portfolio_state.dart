part of 'attach_to_portfolio_cubit.dart';

enum AttachToPortfolioStatus { loading, success, failure }

class AttachToPortfolioState {
  final AttachToPortfolioStatus status;
  final List<PortfolioModel> portfolios;
  final String? errorMessage;

  /// The chosen portfolio, with its items.
  final PortfolioModel? portfolio;
  final bool isLoadingItems;
  final int? selectedItemId;
  final bool isAttaching;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final UiFeedback? feedback;
  final bool attached;

  const AttachToPortfolioState({
    this.status = AttachToPortfolioStatus.loading,
    this.portfolios = const [],
    this.errorMessage,
    this.portfolio,
    this.isLoadingItems = false,
    this.selectedItemId,
    this.isAttaching = false,
    this.feedback,
    this.attached = false,
  });

  AttachToPortfolioState copyWith({
    AttachToPortfolioStatus? status,
    List<PortfolioModel>? portfolios,
    String? errorMessage,
    PortfolioModel? portfolio,
    bool clearPortfolio = false,
    bool? isLoadingItems,
    int? selectedItemId,
    bool clearItem = false,
    bool? isAttaching,
    UiFeedback? feedback,
    bool attached = false,
  }) {
    return AttachToPortfolioState(
      status: status ?? this.status,
      portfolios: portfolios ?? this.portfolios,
      errorMessage: errorMessage ?? this.errorMessage,
      portfolio: clearPortfolio ? null : (portfolio ?? this.portfolio),
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      selectedItemId: clearItem ? null : (selectedItemId ?? this.selectedItemId),
      isAttaching: isAttaching ?? this.isAttaching,
      feedback: feedback,
      attached: attached,
    );
  }
}
