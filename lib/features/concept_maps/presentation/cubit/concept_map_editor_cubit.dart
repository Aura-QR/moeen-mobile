import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_field_error.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

part 'concept_map_editor_state.dart';

/// L9 «خرائط المفاهيم» editor cubit: outline editing, limits, validation, preview & save.
class ConceptMapEditorCubit extends Cubit<ConceptMapEditorState> {
  static ConceptMapEditorCubit get(BuildContext context) =>
      BlocProvider.of(context);

  static const String portfolioItemKey = 'teaching_strategies';

  ConceptMapEditorCubit({
    required DocumentsRepository documentsRepository,
    int? documentId,
    ConceptMapInput? initialInput,
  }) : _documents = documentsRepository,
       _initialInput = initialInput,
       super(
         ConceptMapEditorState(
           documentId: documentId,
           input: initialInput ?? ConceptMapInput.blank(),
           isDirty: initialInput != null,
         ),
       );

  final DocumentsRepository _documents;
  final ConceptMapInput? _initialInput;

  final TextEditingController titleController = TextEditingController();

  Future<void> load() async {
    emit(state.copyWith(status: ConceptMapEditorStatus.loading));
    final id = state.documentId;
    final defaultsFuture = _documents.getDefaults();
    final docFuture = id == null ? null : _documents.getDocument(id);

    final defaultsResult = await defaultsFuture;
    final docResult = await docFuture;
    if (isClosed) return;

    final docFailure = docResult?.fold((f) => f, (_) => null);
    if (docFailure != null) {
      emit(
        state.copyWith(
          status: ConceptMapEditorStatus.failure,
          errorMessage: docFailure.message,
        ),
      );
      return;
    }

    final defaults = defaultsResult.fold(
      (_) => const DocumentDefaultsModel(),
      (d) => d,
    );
    final saved = docResult?.fold((_) => null, (doc) => doc);

    if (saved != null) {
      final parsed = ConceptMapInput.fromJson(saved.input);
      final resolvedTitle = parsed.title.trim().isNotEmpty
          ? parsed.title
          : saved.title;
      final input = parsed.copyWith(title: resolvedTitle);
      titleController.text = input.title;
      emit(
        state.copyWith(
          status: ConceptMapEditorStatus.success,
          defaults: defaults,
          documentStatus: saved.status,
          input: input,
          isDirty: false,
        ),
      );
      return;
    }

    final starter = _initialInput ?? ConceptMapInput.blank();
    titleController.text = starter.title;
    emit(
      state.copyWith(
        status: ConceptMapEditorStatus.success,
        defaults: defaults,
        input: starter,
        isDirty: _initialInput != null,
      ),
    );
  }

  void markTitleEdited() {
    if (!state.isDirty || state.titleError != null) {
      emit(state.copyWith(isDirty: true, clearTitleError: true));
    }
  }

  void updateNode(String nodeId, {String? text, String? link, bool? blank}) {
    final nextErrors = Map<String, String>.from(state.nodeErrors)
      ..remove(nodeId);
    emit(
      state.copyWith(
        input: state.input.updateNode(
          nodeId,
          text: text,
          link: link,
          blank: blank,
        ),
        nodeErrors: nextErrors,
        isDirty: true,
      ),
    );
  }

  /// Adds a branch under [parentId] and opens its edit sheet.
  void addBranch(String parentId) {
    if (!state.input.canAddChild(parentId)) return;
    final newId = state.input.nextNodeId();
    final updated = state.input.addChild(parentId, id: newId);
    emit(state.copyWith(input: updated, isDirty: true, openNodeSheetId: newId));
  }

  /// Updates [input] when adding a branch from inside an already-open node sheet.
  void addChildQuietly(ConceptMapInput updated) {
    emit(state.copyWith(input: updated, isDirty: true));
  }

  void moveNodeUp(String nodeId) {
    if (!state.input.canMoveUp(nodeId)) return;
    emit(
      state.copyWith(
        input: state.input.moveSibling(nodeId, delta: -1),
        isDirty: true,
      ),
    );
  }

  void moveNodeDown(String nodeId) {
    if (!state.input.canMoveDown(nodeId)) return;
    emit(
      state.copyWith(
        input: state.input.moveSibling(nodeId, delta: 1),
        isDirty: true,
      ),
    );
  }

  void deleteNode(String nodeId) {
    if (!state.input.canDelete(nodeId)) return;
    final removedIds = state.input.subtreeIds(nodeId);
    final nextErrors = {
      for (final entry in state.nodeErrors.entries)
        if (!removedIds.contains(entry.key)) entry.key: entry.value,
    };
    emit(
      state.copyWith(
        input: state.input.deleteSubtree(nodeId),
        nodeErrors: nextErrors,
        isDirty: true,
      ),
    );
  }

  void setLayout(ConceptMapLayout layout) {
    if (layout == state.input.layout) return;
    emit(
      state.copyWith(
        input: state.input.copyWith(layout: layout),
        isDirty: true,
      ),
    );
  }

  void setShowAnswers(bool enabled) {
    if (enabled == state.input.showAnswers) return;
    emit(
      state.copyWith(
        input: state.input.copyWith(showAnswers: enabled),
        isDirty: true,
      ),
    );
  }

  void setTheme(DocumentTheme theme) {
    if (theme == state.input.theme) return;
    emit(
      state.copyWith(input: state.input.copyWith(theme: theme), isDirty: true),
    );
  }

  void setDocumentStatus(String status) {
    if (status == state.documentStatus) return;
    emit(state.copyWith(documentStatus: status, isDirty: true));
  }

  Map<String, dynamic> buildPreviewPayload() =>
      state.input.copyWith(title: titleController.text.trim()).toJson();

  Future<void> save() => _save(null);

  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> saveIfDirty() async {
    if (!state.isDirty || state.status != ConceptMapEditorStatus.success) {
      return;
    }
    if (titleController.text.trim().isEmpty) return;
    if (state.input.nodes.any((n) => n.text.trim().isEmpty)) return;
    await _save(null, quiet: true);
  }

  Future<void> _save(DocumentFollowUp? followUp, {bool quiet = false}) async {
    if (state.isSaving) return;
    final trimmedTitle = titleController.text.trim();
    if (trimmedTitle.isEmpty) {
      emit(
        state.copyWith(
          titleError: 'concept_map_title_required',
          feedback: const UiFeedback('concept_map_title_required'),
        ),
      );
      return;
    }

    final emptyNode = state.input.nodes
        .where((n) => n.text.trim().isEmpty)
        .firstOrNull;
    if (emptyNode != null) {
      emit(
        state.copyWith(
          nodeErrors: {
            ...state.nodeErrors,
            emptyNode.id: 'concept_map_node_text_required',
          },
          openNodeSheetId: emptyNode.id,
          feedback: const UiFeedback('concept_map_node_text_required'),
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true));
    final payload = state.input.copyWith(title: trimmedTitle).toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.conceptMap,
            input: payload,
            status: state.documentStatus,
            keepFieldErrors: true,
          )
        : await _documents.updateDocument(
            id,
            payload,
            status: state.documentStatus,
            keepFieldErrors: true,
          );
    if (isClosed) return;

    result.fold(
      (failure) => emit(_handleSaveFailure(failure)),
      (saved) => emit(
        state.copyWith(
          isSaving: false,
          isDirty: false,
          documentId: saved.id,
          nodeErrors: const {},
          clearTitleError: true,
          followUp: followUp,
          feedback: followUp == null && !quiet
              ? const UiFeedback('document_saved', isError: false)
              : null,
        ),
      ),
    );
  }

  ConceptMapEditorState _handleSaveFailure(Failure failure) {
    if (failure is PaymentRequiredFailure) {
      return state.copyWith(isSaving: false, paymentRequired: failure);
    }
    if (failure is! ValidationFailure) {
      return state.copyWith(
        isSaving: false,
        feedback: UiFeedback(failure.message),
      );
    }

    final nodes = state.input.nodes;
    final nodeErrors = <String, String>{};
    String? titleError;
    String? firstNodeId;

    for (final entry in failure.errors.entries) {
      final parsed = ConceptMapFieldError.parse(entry.key, entry.value);
      if (parsed == null) continue;
      if (parsed.isTitle) titleError ??= parsed.message;
      final index = parsed.nodeIndex;
      if (index != null && index >= 0 && index < nodes.length) {
        final nodeId = nodes[index].id;
        nodeErrors.putIfAbsent(nodeId, () => parsed.message);
        firstNodeId ??= nodeId;
      }
    }

    return state.copyWith(
      isSaving: false,
      titleError: titleError,
      nodeErrors: nodeErrors,
      openNodeSheetId: firstNodeId,
      feedback: UiFeedback(failure.message),
    );
  }

  @override
  Future<void> close() {
    titleController.dispose();
    return super.close();
  }
}
