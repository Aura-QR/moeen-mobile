import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

part 'performance_state.dart';

/// «الأداء الوظيفي»: the portfolio by performance element, with the
/// self-ratings and the CV (T9).
class PerformanceCubit extends Cubit<PerformanceState> {
  static PerformanceCubit get(BuildContext context) => BlocProvider.of(context);

  PerformanceCubit({required this.portfolioId, required PortfolioRepository repository})
      : _repo = repository,
        super(const PerformanceState());

  final int portfolioId;
  final PortfolioRepository _repo;

  Future<void> load() async {
    if (state.performance == null) emit(state.copyWith(status: PerformanceStatus.loading));
    await refresh();
  }

  /// Keeps what's on screen when it fails after the first load.
  Future<void> refresh() async {
    final result = await _repo.getPerformance(portfolioId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.performance == null
          ? state.copyWith(status: PerformanceStatus.failure, errorMessage: failure.message)
          : state.copyWith(feedback: UiFeedback(failure.message))),
      (performance) => emit(state.copyWith(status: PerformanceStatus.success, performance: performance)),
    );
  }

  /// Tapping the current rating again clears it. The summary comes from the
  /// server, so the view reloads after the change.
  Future<void> rate(PerformanceItemModel item, int rating) async {
    if (!item.isRatable || state.ratingItemId != null) return;
    final next = item.selfRating == rating ? null : rating;
    _replaceItem(next == null ? item.copyWith(clearRating: true) : item.copyWith(selfRating: next));
    emit(state.copyWith(ratingItemId: item.id));

    final result = await _repo.setSelfRating(portfolioId, item.id, next);
    if (isClosed) return;
    await result.fold(
      (failure) async {
        _replaceItem(item);
        emit(state.copyWith(clearRatingItem: true, feedback: UiFeedback(failure.message)));
      },
      (_) async {
        await refresh();
        if (!isClosed) emit(state.copyWith(clearRatingItem: true));
      },
    );
  }

  /// [values] is field → text for [PerformanceCvFields.all]; empty clears it.
  Future<void> saveCv(Map<String, String> values) async {
    emit(state.copyWith(isSavingCv: true));
    final cv = {
      for (final field in PerformanceCvFields.all)
        field: (values[field] ?? '').trim().isEmpty ? null : values[field]!.trim(),
    };
    final result = await _repo.updateCv(portfolioId, cv);
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(state.copyWith(isSavingCv: false, feedback: UiFeedback(failure.message))),
      (_) async {
        await refresh();
        if (!isClosed) {
          emit(state.copyWith(
            isSavingCv: false,
            feedback: const UiFeedback('performance_cv_saved', isError: false),
          ));
        }
      },
    );
  }

  void _replaceItem(PerformanceItemModel updated) {
    final performance = state.performance;
    if (performance == null) return;
    emit(state.copyWith(
      performance: performance.copyWith(
        items: performance.items.map((item) => item.id == updated.id ? updated : item).toList(),
      ),
    ));
  }
}
