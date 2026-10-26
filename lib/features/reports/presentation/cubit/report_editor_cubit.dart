import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/models/report_field_error.dart';
import 'package:moean/features/reports/data/models/report_input.dart';
import 'package:moean/features/reports/data/repositories/reports_repository.dart';

part 'report_editor_state.dart';

/// T8 «التقارير والشواهد»: a report built from blocks, usually from a template.
class ReportEditorCubit extends Cubit<ReportEditorState> {
  static ReportEditorCubit get(BuildContext context) => BlocProvider.of(context);

  /// The template a new report starts from when none is picked.
  static const String blankTemplate = 'blank';

  /// For the attach sheet; the server sets the element from the template.
  static const String portfolioItemKey = 'duties';

  /// Open [documentId], or start from [templateKey].
  ReportEditorCubit({
    required ReportsRepository reports,
    required DocumentsRepository documents,
    required DeviceFilePicker picker,
    int? documentId,
    String? templateKey,
  })  : _reports = reports,
        _documents = documents,
        _picker = picker,
        _templateKey = templateKey ?? blankTemplate,
        super(ReportEditorState(documentId: documentId));

  final ReportsRepository _reports;
  final DocumentsRepository _documents;
  final DeviceFilePicker _picker;
  final String _templateKey;
  final TextEditingController titleController = TextEditingController();
  int _lastId = 0;

  int _nextId() => ++_lastId;

  Future<void> load() async {
    emit(state.copyWith(status: ReportEditorStatus.loading));
    final id = state.documentId;
    final catalogueRequest = _reports.getCatalogue();
    final documentRequest = id == null ? null : _documents.getDocument(id);
    final templateRequest = id == null ? _reports.getTemplate(_templateKey) : null;
    final catalogue = await catalogueRequest;
    final document = await documentRequest;
    final template = await templateRequest;
    if (isClosed) return;

    final failure = catalogue.fold((f) => f, (_) => null) ??
        document?.fold((f) => f, (_) => null) ??
        template?.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: ReportEditorStatus.failure, errorMessage: failure.message));
      return;
    }

    final saved = document?.fold((_) => null, (doc) => doc);
    final Map<String, dynamic> json =
        saved?.input ?? template!.fold<Map<String, dynamic>>((_) => const {}, (input) => input);
    final input = ReportInput.fromJson(json, _nextId);
    titleController.text = input.title;
    emit(state.copyWith(
      status: ReportEditorStatus.success,
      catalogue: catalogue.fold((_) => null, (c) => c),
      input: input,
      images: saved?.images ?? [for (final path in input.images) DocumentImageModel(storagePath: path)],
      documentStatus: saved?.status,
    ));
  }

  ReportLimitsModel get _limits => state.catalogue?.limits ?? const ReportLimitsModel();

  // Meta rows.

  void addMeta(String label, String value) {
    if (state.input.meta.length >= _limits.meta || label.trim().isEmpty) return;
    _setInput(state.input.copyWith(meta: [...state.input.meta, ReportMetaRow(_nextId(), label: label.trim(), value: value.trim())]));
  }

  void updateMeta(int id, String label, String value) => _setInput(state.input.copyWith(
        meta: [
          for (final row in state.input.meta)
            row.id == id ? ReportMetaRow(id, label: label.trim(), value: value.trim()) : row,
        ],
      ));

  void removeMeta(int id) => _setInput(state.input.copyWith(meta: state.input.meta.where((row) => row.id != id).toList()));

  // Blocks.

  /// [index] null adds at the end.
  void addBlock(String kind, {int? index}) {
    final blocks = state.input.blocks;
    if (blocks.length >= _limits.blocks) {
      emit(state.copyWith(feedback: const UiFeedback('report_limit_reached')));
      return;
    }
    final block = ReportBlock.empty(kind, _nextId());
    final at = (index ?? blocks.length).clamp(0, blocks.length);
    _setInput(state.input.copyWith(blocks: [...blocks]..insert(at, block)), scrollTo: block.id);
  }

  void updateBlock(ReportBlock block) {
    _setInput(state.input.copyWith(
      blocks: [for (final b in state.input.blocks) b.id == block.id ? block : b],
    ));
    if (state.blockErrors.containsKey(block.id)) {
      emit(state.copyWith(blockErrors: {...state.blockErrors}..remove(block.id)));
    }
  }

  void duplicateBlock(int id) {
    final blocks = state.input.blocks;
    final index = blocks.indexWhere((b) => b.id == id);
    if (index < 0) return;
    if (blocks.length >= _limits.blocks) {
      emit(state.copyWith(feedback: const UiFeedback('report_limit_reached')));
      return;
    }
    final copy = blocks[index].withId(_nextId());
    _setInput(state.input.copyWith(blocks: [...blocks]..insert(index + 1, copy)), scrollTo: copy.id);
  }

  void removeBlock(int id) {
    _setInput(state.input.copyWith(blocks: state.input.blocks.where((b) => b.id != id).toList()));
    if (state.blockErrors.containsKey(id)) emit(state.copyWith(blockErrors: {...state.blockErrors}..remove(id)));
  }

  /// [newIndex] is the final position, after removing the moved block.
  void moveBlock(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final blocks = [...state.input.blocks];
    blocks.insert(newIndex, blocks.removeAt(oldIndex));
    _setInput(state.input.copyWith(blocks: blocks));
  }

  // Photos.

  Future<void> addImage(DeviceFileSource source) async {
    if (state.images.length >= _limits.images) {
      emit(state.copyWith(feedback: const UiFeedback('document_images_limit')));
      return;
    }
    final file = await _picker.pick(source);
    if (file == null || isClosed) return;
    final error = DocumentUploadRules.validate(file);
    if (error != null) {
      emit(state.copyWith(feedback: UiFeedback(error)));
      return;
    }

    emit(state.copyWith(isUploadingImage: true));
    final result = await _documents.uploadImage(file);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isUploadingImage: false, feedback: UiFeedback(failure.message))),
      (path) => emit(state.copyWith(
        isUploadingImage: false,
        isDirty: true,
        images: [...state.images, DocumentImageModel(storagePath: path, bytes: file.bytes)],
      )),
    );
  }

  /// Also takes the photo out of every images block.
  void removeImage(int index) {
    final path = state.images[index].storagePath;
    emit(state.copyWith(images: [...state.images]..removeAt(index)));
    _setInput(state.input.copyWith(
      blocks: [
        for (final block in state.input.blocks)
          block is ImagesBlock && block.items.contains(path) ? block.toggle(path) : block,
      ],
    ));
  }

  // Settings.

  void setTheme(DocumentTheme theme) => _setInput(state.input.copyWith(theme: theme));

  void setDocumentStatus(String status) => emit(state.copyWith(documentStatus: status, isDirty: true));

  void addSignature(String title, String name) {
    if (state.input.signatures.length >= ReportEditorState.maxSignatures || title.trim().isEmpty) return;
    _setInput(state.input.copyWith(
      signatures: [...state.input.signatures, ReportSignature(title: title.trim(), name: name.trim())],
    ));
  }

  void updateSignature(int index, String title, String name) => _setInput(state.input.copyWith(
        signatures: [...state.input.signatures]..[index] = ReportSignature(title: title.trim(), name: name.trim()),
      ));

  void removeSignature(int index) =>
      _setInput(state.input.copyWith(signatures: [...state.input.signatures]..removeAt(index)));

  void markTitleEdited() {
    if (!state.isDirty || state.titleError != null) emit(state.copyWith(isDirty: true, clearTitleError: true));
  }

  // Saving.

  Future<void> save() => _save(null);

  /// Exports always use the saved version, so this saves first.
  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  /// Leaving the screen: saves quietly if anything changed and the form is valid.
  Future<void> saveIfDirty() async {
    if (!state.isDirty || state.status != ReportEditorStatus.success) return;
    if (_localErrors().isNotEmpty || titleController.text.trim().isEmpty) return;
    await _save(null, quiet: true);
  }

  Future<void> _save(DocumentFollowUp? followUp, {bool quiet = false}) async {
    if (state.isSaving || state.isUploadingImage) return;
    if (titleController.text.trim().isEmpty) {
      emit(state.copyWith(titleError: 'report_title_required', feedback: const UiFeedback('report_title_required')));
      return;
    }
    final errors = _localErrors();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        blockErrors: errors,
        scrollToBlockId: errors.keys.first,
        feedback: UiFeedback(errors.values.first),
      ));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final input = state.input
        .copyWith(title: titleController.text.trim(), images: state.images.map((i) => i.storagePath).toList())
        .toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.report,
            input: input,
            status: state.documentStatus,
            keepFieldErrors: true,
          )
        : await _documents.updateDocument(id, input, status: state.documentStatus, keepFieldErrors: true);
    if (isClosed) return;
    result.fold(
      (failure) => emit(_failed(failure)),
      (document) => emit(state.copyWith(
        isSaving: false,
        isDirty: false,
        documentId: document.id,
        blockErrors: const {},
        clearTitleError: true,
        followUp: followUp,
        feedback: followUp == null && !quiet ? const UiFeedback('document_saved', isError: false) : null,
      )),
    );
  }

  /// Field errors point at their block; the first one is scrolled to.
  ReportEditorState _failed(Failure failure) {
    if (failure is! ValidationFailure) {
      return state.copyWith(isSaving: false, feedback: UiFeedback(failure.message));
    }
    final blocks = state.input.blocks;
    final blockErrors = <int, String>{};
    String? titleError;
    for (final entry in failure.errors.entries) {
      final error = ReportFieldError.parse(entry.key, entry.value);
      if (error == null) continue;
      if (error.isTitle) titleError ??= error.message;
      final index = error.blockIndex;
      if (index != null && index < blocks.length) blockErrors.putIfAbsent(blocks[index].id, () => error.message);
    }
    return state.copyWith(
      isSaving: false,
      blockErrors: blockErrors,
      titleError: titleError,
      scrollToBlockId: blockErrors.keys.firstOrNull,
      feedback: UiFeedback(failure.message),
    );
  }

  /// What the server would refuse, found before sending: block id → message key.
  Map<int, String> _localErrors() => {
        for (final block in state.input.blocks)
          if (block is QrBlock && block.url.trim().isNotEmpty && !isHttpsUrl(block.url)) block.id: 'report_qr_url_invalid',
      };

  void _setInput(ReportInput input, {int? scrollTo}) =>
      emit(state.copyWith(input: input, isDirty: true, scrollToBlockId: scrollTo));

  @override
  Future<void> close() {
    titleController.dispose();
    return super.close();
  }
}
