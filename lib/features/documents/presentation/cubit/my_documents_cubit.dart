import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

part 'my_documents_state.dart';

/// F3 «مستنداتي»: every saved document, newest first.
class MyDocumentsCubit extends Cubit<MyDocumentsState> {
  static MyDocumentsCubit get(BuildContext context) => BlocProvider.of(context);

  MyDocumentsCubit(
    this._repo, {
    Duration searchDebounce = const Duration(milliseconds: 400),
  })  : _searchDebounce = searchDebounce,
        super(const MyDocumentsState());

  final DocumentsRepository _repo;
  final Duration _searchDebounce;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  /// Reloads the first page with the current filter and search.
  Future<void> load() async {
    if (state.documents.isEmpty) emit(state.copyWith(status: MyDocumentsStatus.loading));
    final result = await _repo.getDocuments(type: state.type, search: searchController.text.trim());
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.documents.isEmpty
          ? state.copyWith(status: MyDocumentsStatus.failure, errorMessage: failure.message)
          : state.copyWith(feedback: UiFeedback(failure.message))),
      (page) => emit(state.copyWith(
        status: MyDocumentsStatus.success,
        documents: page.items,
        page: page.currentPage,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.status != MyDocumentsStatus.success) return;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _repo.getDocuments(
      page: state.page + 1,
      type: state.type,
      search: searchController.text.trim(),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, feedback: UiFeedback(failure.message))),
      (page) => emit(state.copyWith(
        isLoadingMore: false,
        documents: [...state.documents, ...page.items],
        page: page.currentPage,
        hasMore: page.hasMore,
      )),
    );
  }

  /// Null shows every type.
  Future<void> setType(String? type) async {
    if (type == state.type) return;
    emit(state.copyWith(type: type, clearType: type == null, documents: const []));
    await load();
  }

  void onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!isClosed) load();
    });
  }

  Future<void> duplicate(DocumentModel document) async {
    emit(state.copyWith(busyId: document.id));
    final result = await _repo.duplicateDocument(document.id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(clearBusy: true, feedback: UiFeedback(failure.message))),
      (copy) => emit(state.copyWith(
        clearBusy: true,
        documents: [copy, ...state.documents],
        feedback: const UiFeedback('document_duplicated', isError: false),
      )),
    );
  }

  Future<void> delete(DocumentModel document) async {
    emit(state.copyWith(busyId: document.id));
    final result = await _repo.deleteDocument(document.id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(clearBusy: true, feedback: UiFeedback(failure.message))),
      (_) => emit(state.copyWith(
        clearBusy: true,
        documents: state.documents.where((d) => d.id != document.id).toList(),
        feedback: const UiFeedback('document_deleted', isError: false),
      )),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
