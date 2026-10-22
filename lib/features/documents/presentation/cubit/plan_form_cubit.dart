import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/models/plan_catalogue_model.dart';
import 'package:moean/features/documents/data/models/plan_form_input.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/repositories/plan_catalogue_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_header_overrides.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';

part 'plan_form_state.dart';

/// The form shared by T1 «الخطة العلاجية» and T2 «الخطة الإثرائية»,
/// saved as a document. [config] switches the parts only one of them has.
class PlanFormCubit extends Cubit<PlanFormState> {
  static PlanFormCubit get(BuildContext context) => BlocProvider.of(context);

  PlanFormCubit({
    required this.config,
    int? documentId,
    required PlanCatalogueRepository catalogueRepository,
    required DocumentsRepository documentsRepository,
    required DeviceFilePicker filePicker,
  })  : _catalogues = catalogueRepository,
        _documents = documentsRepository,
        _picker = filePicker,
        super(PlanFormState(
          documentId: documentId,
          planType: config.hasPlanType ? PlanFormInput.linked : null,
        ));

  final PlanToolConfig config;
  final PlanCatalogueRepository _catalogues;
  final DocumentsRepository _documents;
  final DeviceFilePicker _picker;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController periodController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final DocumentHeaderOverrides header = DocumentHeaderOverrides();

  /// `input` fields the app doesn't edit, sent back unchanged.
  Map<String, dynamic> _extra = const {};

  /// Loads the catalogue and defaults, and the document when reopening one.
  Future<void> load() async {
    emit(state.copyWith(status: PlanFormStatus.loading));
    final documentId = state.documentId;
    final catalogueRequest = _catalogues.getCatalogue();
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
      emit(state.copyWith(status: PlanFormStatus.failure, errorMessage: failure.message));
      return;
    }

    final options = catalogue.getOrElse(() => const PlanCatalogueModel());
    final saved = document?.fold((_) => null, (doc) => doc);
    final input = saved == null
        ? null
        : PlanFormInput.fromJson(saved.input, sectionKeys: options.sections.map((section) => section.key));
    emit(state.copyWith(
      status: PlanFormStatus.success,
      catalogue: options,
      defaults: defaults.getOrElse(() => const DocumentDefaultsModel()),
      sections: [
        for (final section in options.sections)
          ChecklistSection.fromCatalogue(section, saved: input?.sections[section.key] ?? const []),
      ],
      targetGroups: ChecklistSection.fromCatalogue(
        ChecklistCatalogueSection(key: PlanFormState.targetGroupsKey, label: '', options: options.targetGroups),
        saved: input?.targetGroups ?? const [],
        maxChecked: PlanToolConfig.maxTargetGroups,
        maxLength: PlanToolConfig.maxTargetGroupLength,
      ),
    ));
    if (saved != null && input != null) _applyDocument(saved, input);
  }

  /// After «تعديل بيانات الترويسة», so the read-only header is current.
  Future<void> reloadDefaults() async {
    final result = await _documents.getDefaults();
    if (isClosed) return;
    result.fold((_) {}, (defaults) => emit(state.copyWith(defaults: defaults)));
  }

  /// [PlanFormInput.linked] or [PlanFormInput.general].
  void setPlanType(String planType) => emit(state.copyWith(planType: planType));

  /// Up to five, each once. The first fills «المادة» and «الصف» when empty.
  void addLesson(PickedLessonModel lesson) {
    if (state.lessons.any((picked) => picked.lessonId == lesson.lessonId)) return;
    if (state.lessons.length >= PlanToolConfig.maxLessons) {
      emit(state.copyWith(feedback: const UiFeedback('plan_lessons_limit')));
      return;
    }
    _fillIfEmpty(subjectController, lesson.subjectName);
    _fillIfEmpty(gradeController, lesson.gradeName);
    emit(state.copyWith(lessons: [...state.lessons, lesson]));
  }

  void removeLesson(int index) => emit(state.copyWith(lessons: [...state.lessons]..removeAt(index)));

  void setDate(DateTime date) => emit(state.copyWith(date: date));

  /// The picked names; a «فصولي» class also fills the empty class details.
  void setStudents(StudentPickerResult result) {
    _fillIfEmpty(classController, result.className);
    _fillIfEmpty(gradeController, result.grade);
    _fillIfEmpty(subjectController, result.subject);
    emit(state.copyWith(students: result.students, classId: result.classId, clearClassId: result.classId == null));
  }

  void clearStudents() => emit(state.copyWith(students: const [], clearClassId: true));

  /// [key] is a section key or [PlanFormState.targetGroupsKey].
  void toggleLine(String key, int index) {
    final section = state.sectionOf(key);
    if (section == null) return;
    final toggled = section.toggle(index);
    if (identical(toggled, section)) {
      emit(state.copyWith(feedback: UiFeedback(_limitMessage(key))));
      return;
    }
    _setSection(toggled);
  }

  /// «إضافة بند آخر»: added ticked.
  void addCustomLine(String key, String text) {
    final section = state.sectionOf(key);
    if (section == null || text.trim().isEmpty) return;
    if (section.isFull) {
      emit(state.copyWith(feedback: UiFeedback(_limitMessage(key))));
      return;
    }
    _setSection(section.addCustom(text));
  }

  void editCustomLine(String key, int index, String text) {
    final section = state.sectionOf(key);
    if (section != null) _setSection(section.editCustom(index, text));
  }

  void removeCustomLine(String key, int index) {
    final section = state.sectionOf(key);
    if (section != null) _setSection(section.removeCustom(index));
  }

  /// Adds each list to the section with the same key, unticked.
  void addSuggestions(Map<String, List<String>> result) {
    final sections = [
      for (final section in state.sections) section.addSuggestions(result[section.key] ?? const []),
    ];
    final added = sections.indexed.any((entry) => !identical(entry.$2, state.sections[entry.$1]));
    emit(state.copyWith(
      sections: sections,
      feedback: added
          ? const UiFeedback('ai_suggestions_added', isError: false)
          : const UiFeedback('ai_suggestions_empty'),
    ));
  }

  /// Tapping the chosen level again clears it.
  void setImprovement(String level) =>
      emit(state.copyWith(improvement: level == state.improvement ? '' : level));

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
  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> _save(DocumentFollowUp? followUp) async {
    if (state.isSaving || state.isUploadingImage) return;
    if (config.hasPlanType && state.usesLessons && state.lessons.isEmpty) {
      emit(state.copyWith(feedback: const UiFeedback('plan_lessons_required')));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final input = _buildInput().toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(type: config.documentType, input: input, status: state.documentStatus)
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

  PlanFormInput _buildInput() => PlanFormInput(
        planType: state.planType,
        lessonIds: state.aiLessonIds,
        subject: subjectController.text.trim(),
        grade: gradeController.text.trim(),
        className: classController.text.trim(),
        date: state.date,
        period: periodController.text.trim(),
        classId: state.classId,
        students: state.students,
        sections: {for (final section in state.sections) section.key: section.checkedTexts},
        improvement: config.hasImprovement ? state.improvement : '',
        targetGroups: config.hasTargetGroups ? state.targetGroups.checkedTexts : const [],
        notes: notesController.text.trim(),
        theme: state.theme,
        header: state.isOverridingHeader ? header.toJson(state.defaults) : const {},
        images: state.images.map((image) => image.storagePath).toList(),
        extra: _extra,
      );

  void _applyDocument(DocumentModel document, PlanFormInput input) {
    _extra = input.extra;
    subjectController.text = input.subject;
    gradeController.text = input.grade;
    classController.text = input.className;
    periodController.text = input.period;
    notesController.text = input.notes;
    if (input.header.isNotEmpty) {
      header.fill(input.header);
      header.prefill(state.defaults);
    }

    emit(state.copyWith(
      planType: config.hasPlanType ? (input.planType ?? PlanFormInput.linked) : null,
      lessons: savedLessons(input.lessonIds, document.meta),
      date: input.date,
      classId: input.classId,
      students: input.students,
      improvement: input.improvement,
      theme: input.theme,
      documentStatus: document.status,
      isOverridingHeader: input.header.isNotEmpty,
      images: document.images,
    ));
  }

  /// `input` keeps only the ids; the titles come from the printed meta row
  /// («الدرس» or «الدروس», joined by «، »).
  @visibleForTesting
  static List<PickedLessonModel> savedLessons(List<int> ids, Map<String, String> meta) {
    final joined = meta['الدروس'] ?? meta['الدرس'] ?? '';
    final titles = ids.length == 1 ? [joined] : joined.split('، ');
    return [
      for (var i = 0; i < ids.length; i++)
        PickedLessonModel(
          lessonId: ids[i],
          lessonTitle: titles.length == ids.length ? titles[i].trim() : '',
          subjectName: '',
          gradeName: '',
        ),
    ];
  }

  String _limitMessage(String key) =>
      key == PlanFormState.targetGroupsKey ? 'plan_target_groups_limit' : 'plan_section_limit';

  void _setSection(ChecklistSection section) {
    if (section.key == PlanFormState.targetGroupsKey) {
      emit(state.copyWith(targetGroups: section));
      return;
    }
    emit(state.copyWith(sections: [
      for (final existing in state.sections) existing.key == section.key ? section : existing,
    ]));
  }

  static void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.isNotEmpty) controller.text = value;
  }

  @override
  Future<void> close() {
    for (final controller in [
      subjectController,
      gradeController,
      classController,
      periodController,
      notesController,
    ]) {
      controller.dispose();
    }
    header.dispose();
    return super.close();
  }
}
