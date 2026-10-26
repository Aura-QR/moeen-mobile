import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/data/repositories/role_suites_repository.dart';

part 'role_documents_state.dart';

/// L1 `/tools/roles/{role}`: categories, instant label search, and opening a document.
class RoleDocumentsCubit extends Cubit<RoleDocumentsState> {
  static RoleDocumentsCubit get(BuildContext context) => BlocProvider.of(context);

  RoleDocumentsCubit({
    required String roleKey,
    String initialLabel = '',
    required RoleSuitesRepository repository,
  }) : _repository = repository,
       super(RoleDocumentsState(roleKey: roleKey, roleLabel: initialLabel));

  final RoleSuitesRepository _repository;
  final TextEditingController searchController = TextEditingController();

  Future<void> load() async {
    emit(state.copyWith(status: RoleDocumentsStatus.loading));
    final result = await _repository.getRole(state.roleKey);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: RoleDocumentsStatus.failure, errorMessage: failure.message)),
      (detail) => emit(
        state.copyWith(
          status: RoleDocumentsStatus.success,
          roleLabel: detail.label.isNotEmpty ? detail.label : state.roleLabel,
          categories: detail.categories,
          clearSelectedCategory: true,
        ),
      ),
    );
  }

  void selectCategory(int? index) {
    if (index == null) {
      emit(state.copyWith(clearSelectedCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryIndex: index));
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// «فتح»: loads `GET /tools/roles/{role}/{doc}` and emits [RoleDocumentsState.openedTemplate].
  Future<void> openDocument(String docKey) async {
    if (state.isOpening || docKey.isEmpty) return;
    emit(state.copyWith(openingDocKey: docKey));
    final result = await _repository.getDocument(state.roleKey, docKey);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(clearOpeningDoc: true, feedback: UiFeedback(failure.message))),
      (template) => emit(state.copyWith(clearOpeningDoc: true, openedTemplate: template)),
    );
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
