import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/core/utils/formatters/localized_digits.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_header_overrides.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_documentation_input.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';
import 'package:moean/features/strategy_documentation/data/repositories/strategy_repository.dart';

part 'strategy_documentation_state.dart';

/// T4 «توثيق استراتيجيات التعلم»: the form, saved as a document.
class StrategyDocumentationCubit extends Cubit<StrategyDocumentationState> {
  static StrategyDocumentationCubit get(BuildContext context) => BlocProvider.of(context);

  /// «التنويع في استراتيجيات التدريس», preselected when adding to a portfolio.
  static const String portfolioItemKey = 'teaching_strategies';

  StrategyDocumentationCubit({
    int? documentId,
    required StrategyRepository strategyRepository,
    required DocumentsRepository documentsRepository,
    required DeviceFilePicker filePicker,
  })  : _strategies = strategyRepository,
        _documents = documentsRepository,
        _picker = filePicker,
        super(StrategyDocumentationState(documentId: documentId)) {
    lessonController.addListener(_onLessonEdited);
  }

  final StrategyRepository _strategies;
  final DocumentsRepository _documents;
  final DeviceFilePicker _picker;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController lessonController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController studentsController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final DocumentHeaderOverrides header = DocumentHeaderOverrides();

  /// Set while the lesson text is the one picked from the curriculum.
  int? _lessonId;
  String? _pickedLessonTitle;

  /// `input` fields the app doesn't edit, sent back unchanged.
  Map<String, dynamic> _extra = const {};

  /// Loads the catalogue and defaults, and the document when reopening one.
  Future<void> load() async {
    emit(state.copyWith(status: StrategyDocumentationStatus.loading));
    final documentId = state.documentId;
    final catalogueRequest = _strategies.getCatalogue();
    final defaultsRequest = _documents.getDefaults();
    final documentRequest = documentId == null ? null : _documents.getDocument(documentId);
    final catalogue = await catalogueRequest;
    final defaults = await defaultsRequest;
    final document = await documentRequest;
    if (isClosed) return;

    final failure = catalogue.fold((f) => f, (_) => null) ??
        defaults.fold((f) => f, (_) => null) ??
        document?.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: StrategyDocumentationStatus.failure, errorMessage: failure.message));
      return;
    }

    emit(state.copyWith(
      status: StrategyDocumentationStatus.success,
      catalogue: catalogue.getOrElse(() => const StrategyCatalogueModel()),
      defaults: defaults.getOrElse(() => const DocumentDefaultsModel()),
    ));
    final saved = document?.fold((_) => null, (doc) => doc);
    if (saved != null) await _applyDocument(saved);
  }

  /// After «تعديل بيانات الترويسة», so the read-only header is current.
  Future<void> reloadDefaults() async {
    final result = await _documents.getDefaults();
    if (isClosed) return;
    result.fold((_) {}, (defaults) => emit(state.copyWith(defaults: defaults)));
  }

  /// Picking a strategy fills «محتوى الاستراتيجية» with the catalogue text.
  Future<void> selectStrategy(String key) async {
    if (key == state.strategyKey && state.strategy != null) return;
    emit(state.copyWith(strategyKey: key, isLoadingStrategy: true, clearStrategy: true));
    await _loadStrategy(key, overwrite: true);
  }

  void pickLesson(PickedLessonModel lesson) {
    _lessonId = lesson.lessonId;
    _pickedLessonTitle = lesson.lessonTitle;
    lessonController.text = lesson.lessonTitle;
    if (subjectController.text.trim().isEmpty) subjectController.text = lesson.subjectName;
    if (gradeController.text.trim().isEmpty) gradeController.text = lesson.gradeName;
  }

  void setExecutionDate(DateTime date) => emit(state.copyWith(executionDate: date));

  void addListItem(StrategyListSection section, String text) {
    final value = text.trim();
    final items = state.listOf(section);
    if (value.isEmpty || items.length >= section.maxItems) return;
    _setList(section, [...items, value]);
  }

  /// Clearing a line's text removes it.
  void editListItem(StrategyListSection section, int index, String text) {
    final value = text.trim();
    if (value.isEmpty) {
      removeListItem(section, index);
      return;
    }
    _setList(section, [...state.listOf(section)]..[index] = value);
  }

  void removeListItem(StrategyListSection section, int index) =>
      _setList(section, [...state.listOf(section)]..removeAt(index));

  /// [newIndex] is the final position, after removing the moved line.
  void reorderListItem(StrategyListSection section, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final items = [...state.listOf(section)];
    items.insert(newIndex, items.removeAt(oldIndex));
    _setList(section, items);
  }

  /// «استعادة النص الأصلي».
  void resetList(StrategyListSection section) {
    final original = state.strategy?.lists[section];
    if (original != null) _setList(section, [...original]);
  }

  void resetDefinition() {
    final original = state.strategy?.definition;
    if (original != null) definitionController.text = original;
  }

  void setHeaderOverride(bool enabled) {
    if (enabled) header.prefill(state.defaults);
    emit(state.copyWith(isOverridingHeader: enabled));
  }

  Future<void> addImage(DeviceFileSource source) async {
    if (state.images.length >= DocumentUploadRules.maxImagesPerDocument) {
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
        images: [...state.images, DocumentImageModel(storagePath: path, bytes: file.bytes)],
      )),
    );
  }

  void removeImage(int index) => emit(state.copyWith(images: [...state.images]..removeAt(index)));

  void setTheme(DocumentTheme theme) => emit(state.copyWith(theme: theme));

  /// [DocumentStatus.draft] or [DocumentStatus.finalized]; sent with the next save.
  void setDocumentStatus(String status) => emit(state.copyWith(documentStatus: status));

  Future<void> save() => _save(null);

  /// Exports always use the saved version, so this saves first.
  Future<void> saveAndExport() => _save(StrategyFollowUp.export);

  Future<void> saveAndAttach() => _save(StrategyFollowUp.attachToPortfolio);

  Future<void> _save(StrategyFollowUp? followUp) async {
    if (state.isSaving || state.isUploadingImage) return;
    final error = _validate();
    if (error != null) {
      emit(state.copyWith(feedback: UiFeedback(error)));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final input = _buildInput().toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.strategyDocumentation,
            input: input,
            status: state.documentStatus,
          )
        : await _documents.updateDocument(id, input, status: state.documentStatus);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: UiFeedback(failure.message))),
      (document) => emit(state.copyWith(
        isSaving: false,
        documentId: document.id,
        followUp: followUp,
        feedback: followUp == null ? const UiFeedback('document_saved', isError: false) : null,
      )),
    );
  }

  String? _validate() {
    if (state.strategyKey == null) return 'strategy_required';
    final students = latinDigits(studentsController.text.trim());
    if (students.isEmpty) return null;
    final count = int.tryParse(students);
    return count == null || count < 1 || count > 200 ? 'strategy_students_invalid' : null;
  }

  StrategyDocumentationInput _buildInput() => StrategyDocumentationInput(
        strategyKey: state.strategyKey!,
        subject: subjectController.text.trim(),
        grade: gradeController.text.trim(),
        lessonId: _lessonId,
        lessonTitle: lessonController.text.trim(),
        className: classController.text.trim(),
        studentsCount: int.tryParse(latinDigits(studentsController.text.trim())),
        executionDate: state.executionDate,
        definition: definitionController.text.trim(),
        lists: state.lists,
        notes: notesController.text.trim(),
        theme: state.theme,
        header: state.isOverridingHeader ? header.toJson(state.defaults) : const {},
        images: state.images.map((image) => image.storagePath).toList(),
        extra: _extra,
      );

  Future<void> _applyDocument(DocumentModel document) async {
    final input = StrategyDocumentationInput.fromJson(document.input);
    _extra = input.extra;
    _lessonId = input.lessonId;
    _pickedLessonTitle = input.lessonId == null ? null : input.lessonTitle;
    subjectController.text = input.subject;
    gradeController.text = input.grade;
    lessonController.text = input.lessonTitle;
    classController.text = input.className;
    studentsController.text = input.studentsCount?.toString() ?? '';
    definitionController.text = input.definition;
    notesController.text = input.notes;
    if (input.header.isNotEmpty) {
      header.fill(input.header);
      header.prefill(state.defaults);
    }

    emit(state.copyWith(
      strategyKey: input.strategyKey,
      isLoadingStrategy: true,
      lists: {for (final section in StrategyListSection.values) section: input.lists[section] ?? const []},
      executionDate: input.executionDate,
      theme: input.theme,
      documentStatus: document.status,
      isOverridingHeader: input.header.isNotEmpty,
      images: document.images,
    ));
    await _loadStrategy(input.strategyKey, overwrite: false);
  }

  /// [overwrite] replaces the content; otherwise only empty parts are filled,
  /// matching what the server prints for them.
  Future<void> _loadStrategy(String key, {required bool overwrite}) async {
    final result = await _strategies.getStrategy(key);
    if (isClosed || state.strategyKey != key) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoadingStrategy: false, feedback: UiFeedback(failure.message))),
      (strategy) {
        if (overwrite || definitionController.text.trim().isEmpty) {
          definitionController.text = strategy.definition;
        }
        emit(state.copyWith(
          isLoadingStrategy: false,
          strategy: strategy,
          lists: {
            for (final section in StrategyListSection.values)
              section: overwrite || state.listOf(section).isEmpty
                  ? [...?strategy.lists[section]]
                  : state.listOf(section),
          },
        ));
      },
    );
  }

  void _setList(StrategyListSection section, List<String> items) =>
      emit(state.copyWith(lists: {...state.lists, section: items}));

  /// Typing over a picked lesson makes it free text, so `lesson_id` goes.
  void _onLessonEdited() {
    if (_lessonId != null && lessonController.text.trim() != _pickedLessonTitle) {
      _lessonId = null;
      _pickedLessonTitle = null;
    }
  }

  @override
  Future<void> close() {
    for (final controller in [
      subjectController,
      gradeController,
      lessonController,
      classController,
      studentsController,
      definitionController,
      notesController,
    ]) {
      controller.dispose();
    }
    header.dispose();
    return super.close();
  }
}
