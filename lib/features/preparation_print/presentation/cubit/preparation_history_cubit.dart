import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/preparation_print/data/models/preparation_print_models.dart';
import 'package:moean/features/preparation_print/data/repositories/preparation_print_repository.dart';

class PreparationHistoryState {
  static const int maxPicked = 10;

  final List<PreparationItem> items;
  final List<int> picked;
  final int page;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool showAll;
  final bool isCreating;
  final String? error;

  /// Set once a document is ready; the screen opens it and clears this.
  final int? createdDocumentId;

  const PreparationHistoryState({
    this.items = const [],
    this.picked = const [],
    this.page = 0,
    this.lastPage = 1,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.showAll = false,
    this.isCreating = false,
    this.error,
    this.createdDocumentId,
  });

  bool get hasMore => page < lastPage;

  PreparationHistoryState copyWith({
    List<PreparationItem>? items,
    List<int>? picked,
    int? page,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? showAll,
    bool? isCreating,
    String? error,
    bool clearError = false,
    int? createdDocumentId,
    bool clearCreated = false,
  }) =>
      PreparationHistoryState(
        items: items ?? this.items,
        picked: picked ?? this.picked,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        showAll: showAll ?? this.showAll,
        isCreating: isCreating ?? this.isCreating,
        error: clearError ? null : error ?? this.error,
        createdDocumentId: clearCreated ? null : createdDocumentId ?? this.createdDocumentId,
      );
}

/// «تحضيراتي»: past preparations; tick up to 10 (in order) and print them as one document.
class PreparationHistoryCubit extends Cubit<PreparationHistoryState> {
  final PreparationPrintRepository _repository;

  PreparationHistoryCubit(this._repository) : super(const PreparationHistoryState());

  static PreparationHistoryCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, items: const [], page: 0, picked: const [], clearError: true));
    await _fetch(1);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(state.page + 1);
  }

  Future<void> _fetch(int page) async {
    final result = await _repository.getPreparations(page: page, onlyDone: !state.showAll);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, isLoadingMore: false, error: failure.message)),
      (data) => emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        items: [...state.items, ...data.items],
        page: data.currentPage,
        lastPage: data.lastPage,
      )),
    );
  }

  void toggleShowAll(bool value) {
    emit(state.copyWith(showAll: value));
    load();
  }

  void toggle(int id) {
    final picked = [...state.picked];
    if (picked.contains(id)) {
      picked.remove(id);
    } else if (picked.length < PreparationHistoryState.maxPicked) {
      picked.add(id);
    }
    emit(state.copyWith(picked: picked));
  }

  Future<void> print([List<int>? ids]) async {
    final chosen = ids ?? state.picked;
    if (chosen.isEmpty || state.isCreating) return;
    emit(state.copyWith(isCreating: true, clearError: true));
    final result = await _repository.createDocument(chosen);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isCreating: false, error: failure.message)),
      (doc) => emit(state.copyWith(isCreating: false, createdDocumentId: doc.id, picked: const [])),
    );
  }

  void clearCreated() => emit(state.copyWith(clearCreated: true));
  void clearError() => emit(state.copyWith(clearError: true));
}
