import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

part 'outcomes_maps_state.dart';

/// L9 «خريطة نواتج التعلم»: saved maps list (`GET /documents?type=outcomes_map`).
class OutcomesMapsCubit extends Cubit<OutcomesMapsState> {
  static OutcomesMapsCubit get(BuildContext context) => BlocProvider.of(context);

  OutcomesMapsCubit({
    required DocumentsRepository documentsRepository,
    Duration searchDebounce = const Duration(milliseconds: 400),
  })  : _documents = documentsRepository,
        _searchDebounce = searchDebounce,
        super(const OutcomesMapsState());

  final DocumentsRepository _documents;
  final Duration _searchDebounce;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  Future<void> load() async {
    if (state.documents.isEmpty) {
      emit(state.copyWith(status: OutcomesMapsStatus.loading));
    }
    final result = await _documents.getDocuments(
      type: DocumentTypes.outcomesMap,
      search: searchController.text.trim(),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.documents.isEmpty
            ? state.copyWith(
                status: OutcomesMapsStatus.failure,
                errorMessage: failure.message,
              )
            : state.copyWith(feedback: UiFeedback(failure.message)),
      ),
      (page) => emit(
        state.copyWith(
          status: OutcomesMapsStatus.success,
          documents: page.items,
          page: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != OutcomesMapsStatus.success) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final result = await _documents.getDocuments(
      page: state.page + 1,
      type: DocumentTypes.outcomesMap,
      search: searchController.text.trim(),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, feedback: UiFeedback(failure.message)),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingMore: false,
          documents: [...state.documents, ...page.items],
          page: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  void onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!isClosed) load();
    });
  }

  Future<void> duplicate(int id) async {
    if (state.busyDocumentId != null) return;
    emit(state.copyWith(busyDocumentId: id));
    final result = await _documents.duplicateDocument(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(clearBusyDocument: true, feedback: UiFeedback(failure.message)),
      ),
      (copy) => emit(
        state.copyWith(
          clearBusyDocument: true,
          documents: [copy, ...state.documents],
          feedback: const UiFeedback('document_duplicated', isError: false),
        ),
      ),
    );
  }

  Future<void> deleteDocument(int id) async {
    if (state.busyDocumentId != null) return;
    emit(state.copyWith(busyDocumentId: id));
    final result = await _documents.deleteDocument(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(clearBusyDocument: true, feedback: UiFeedback(failure.message)),
      ),
      (_) => emit(
        state.copyWith(
          clearBusyDocument: true,
          documents: state.documents.where((doc) => doc.id != id).toList(),
          feedback: const UiFeedback('document_deleted', isError: false),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
