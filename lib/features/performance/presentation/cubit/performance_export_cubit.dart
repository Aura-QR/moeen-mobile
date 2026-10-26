import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

part 'performance_export_state.dart';

/// «تصدير ملف الأداء الوظيفي»: rebuilds the portfolio's performance file
/// right before it's printed, so the file matches the portfolio.
class PerformanceExportCubit extends Cubit<PerformanceExportState> {
  static PerformanceExportCubit get(BuildContext context) => BlocProvider.of(context);

  PerformanceExportCubit({required this.portfolioId, required PortfolioRepository repository})
      : _repo = repository,
        super(const PerformanceExportState());

  final int portfolioId;
  final PortfolioRepository _repo;

  void setIncludeRatings(bool value) => emit(state.copyWith(includeRatings: value));

  void setTheme(DocumentTheme theme) => emit(state.copyWith(theme: theme));

  Future<void> export() async {
    if (state.isExporting) return;
    emit(state.copyWith(isExporting: true));
    final result = await _repo.exportPerformanceFile(
      portfolioId,
      includeRatings: state.includeRatings,
      theme: state.theme.name,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isExporting: false, errorMessage: failure.message)),
      (documentId) => emit(state.copyWith(isExporting: false, documentId: documentId)),
    );
  }
}
