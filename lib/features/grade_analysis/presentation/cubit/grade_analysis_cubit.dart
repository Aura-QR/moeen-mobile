import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_header_overrides.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_input.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/models/grade_sheet_import.dart';
import 'package:moean/features/grade_analysis/data/repositories/grade_analysis_repository.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_classes_editor.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_form_fields.dart';

part 'grade_analysis_state.dart';

/// T7 «تحليل نتائج الطلاب»: one test's grades for 1 to 5 classes, saved as
/// a document. The numbers come from the backend (see GradeResultsCubit).
class GradeAnalysisCubit extends Cubit<GradeAnalysisState> {
  static GradeAnalysisCubit get(BuildContext context) => BlocProvider.of(context);

  /// «تحليل نتائج المتعلمين وتشخيص مستوياتهم», preselected when adding to a portfolio.
  static const String portfolioItemKey = 'results_analysis';

  /// Empty rows a new class starts with.
  static const int newClassRows = 5;

  GradeAnalysisCubit({
    int? documentId,
    required GradeAnalysisRepository gradesRepository,
    required DocumentsRepository documentsRepository,
    required DeviceFilePicker filePicker,
    DateTime Function() today = DateTime.now,
  }) : _grades = gradesRepository,
       _documents = documentsRepository,
       _picker = filePicker,
       _today = today,
       super(GradeAnalysisState(documentId: documentId)) {
    totalMarkController.addListener(_numbersChanged);
    passMarkController.addListener(_numbersChanged);
  }

  final GradeAnalysisRepository _grades;
  final DocumentsRepository _documents;
  final DeviceFilePicker _picker;
  final DateTime Function() _today;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController testNameController = TextEditingController();
  final TextEditingController totalMarkController = TextEditingController();
  final TextEditingController passMarkController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final DocumentHeaderOverrides header = DocumentHeaderOverrides();
  late final GradeClassesEditor editor = GradeClassesEditor(onChanged: _numbersChanged);

  /// `input` fields the app doesn't edit, sent back unchanged.
  Map<String, dynamic> _extra = const {};

  double? get totalMark => parseGrade(totalMarkController.text);

  /// Loads the options and defaults, and the document when reopening one.
  Future<void> load() async {
    emit(state.copyWith(status: GradeAnalysisStatus.loading));
    final documentId = state.documentId;
    final optionsRequest = _grades.getOptions();
    final defaultsRequest = _documents.getDefaults();
    final documentRequest = documentId == null ? null : _documents.getDocument(documentId);
    final options = await optionsRequest;
    final defaults = await defaultsRequest;
    final document = await documentRequest;
    if (isClosed) return;

    final failure =
        options.fold((f) => f, (_) => null) ??
        defaults.fold((f) => f, (_) => null) ??
        document?.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: GradeAnalysisStatus.failure, errorMessage: failure.message));
      return;
    }

    final loaded = options.getOrElse(() => const GradeOptionsModel());
    final saved = document?.fold((_) => null, (doc) => doc);
    for (final layout in state.classes) {
      editor.remove(layout);
    }
    emit(
      state.copyWith(
        status: GradeAnalysisStatus.success,
        options: loaded,
        defaults: defaults.getOrElse(() => const DocumentDefaultsModel()),
        bands: loaded.bands,
        date: _today(),
        classes: [_emptyClass()],
        activeClass: 0,
      ),
    );
    if (saved != null) _applyDocument(saved);
    _changed(state);
  }

  /// After «تعديل بيانات الترويسة», so the read-only header is current.
  Future<void> reloadDefaults() async {
    final result = await _documents.getDefaults();
    if (isClosed) return;
    result.fold((_) {}, (defaults) => emit(state.copyWith(defaults: defaults)));
  }

  /// A detailed report needs names, so grade-only classes go back to rows.
  void setReportType(String type) {
    final classes = type == GradeReportTypes.detailed
        ? [for (final layout in state.classes) editor.setGradesOnly(layout, false)]
        : state.classes;
    _changed(state.copyWith(reportType: type, classes: classes));
  }

  void setDate(DateTime date) => emit(state.copyWith(date: date));

  void selectClass(int index) => emit(state.copyWith(activeClass: index));

  /// «+ فصل للمقارنة».
  void addClass() {
    if (!state.canAddClass) return;
    final classes = [...state.classes, _emptyClass()];
    _changed(state.copyWith(classes: classes, activeClass: classes.length - 1));
  }

  void removeClass(int index) {
    if (state.classes.length <= 1) return;
    editor.remove(state.classes[index]);
    final classes = [...state.classes]..removeAt(index);
    _changed(state.copyWith(classes: classes, activeClass: index.clamp(0, classes.length - 1)));
  }

  void addRow() {
    final active = state.active;
    if (active == null) return;
    if (active.rowIds.length >= state.options.limits.students) {
      emit(state.copyWith(feedback: const UiFeedback('grades_students_limit')));
      return;
    }
    _setActive(editor.addRow(active));
  }

  void removeRow(int rowId) {
    final active = state.active;
    if (active != null) _setActive(editor.removeRow(active, rowId));
  }

  /// «إدخال الدرجات فقط», quick reports only.
  void setGradesOnly(bool gradesOnly) {
    final active = state.active;
    if (active == null || (gradesOnly && state.isDetailed)) return;
    _setActive(editor.setGradesOnly(active, gradesOnly));
  }

  /// The grade field «التالي» moves to, or null on the last student.
  FocusNode? nextGradeFocus(int rowId) {
    final active = state.active;
    return active == null ? null : editor.nextGradeFocus(active, rowId);
  }

  /// «اختيار من فصولي»: the names replace the rows; a name already there keeps its grade.
  void setClassStudents(StudentPickerResult result) {
    final active = state.active;
    if (active == null) return;
    _fillIfEmpty(editor.classFields(active.id).name, result.className);
    _fillIfEmpty(subjectController, result.subject);
    _fillIfEmpty(gradeController, result.grade);
    _setActive(
      editor.replaceRows(
        active,
        [for (final name in result.students.take(state.options.limits.students)) GradeStudentInput(name: name)],
        keepGrades: true,
        classId: result.classId,
      ),
    );
  }

  /// «رفع ملف Excel»: the rows come back in [GradeAnalysisState.importedSheet]
  /// for review; [applyImport] uses them.
  Future<void> importSheet() async {
    if (state.isImporting) return;
    final file = await _picker.pickSpreadsheet();
    if (file == null || isClosed) return;
    if (file.byteSize > ClassLimits.maxImportBytes) {
      emit(state.copyWith(feedback: const UiFeedback('class_import_too_large')));
      return;
    }

    emit(state.copyWith(isImporting: true));
    final result = await _grades.importSheet(file);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isImporting: false, feedback: UiFeedback(failure.message))),
      (sheet) => emit(
        sheet.rows.isEmpty
            ? state.copyWith(isImporting: false, feedback: const UiFeedback('class_import_empty'))
            : state.copyWith(isImporting: false, importedSheet: sheet),
      ),
    );
  }

  /// The reviewed rows replace the active class's rows.
  void applyImport(GradeSheetImport sheet) {
    final active = state.active;
    if (active == null) return;
    _setActive(editor.replaceRows(active, sheet.rows.take(state.options.limits.students).toList()));
  }

  /// [min] is a percentage. Levels stay highest first, and the lowest starts at 0.
  void setBand(int index, String label, String min) {
    final band = _band(label, min);
    if (band != null) _setBands([...state.bands]..[index] = band);
  }

  void addBand(String label, String min) {
    if (state.bands.length >= state.options.limits.bands) return;
    final band = _band(label, min);
    if (band != null) _setBands([...state.bands, band]);
  }

  void removeBand(int index) {
    if (state.bands.length <= GradeLimits.minBands) return;
    _setBands([...state.bands]..removeAt(index));
  }

  void resetBands() => _setBands(state.options.bands);

  void toggleRecommendation(int index) {
    final toggled = state.recommendations.toggle(index);
    if (identical(toggled, state.recommendations)) {
      emit(state.copyWith(feedback: const UiFeedback('grades_recommendations_limit')));
      return;
    }
    emit(state.copyWith(recommendations: toggled));
  }

  void addRecommendation(String text) {
    if (state.recommendations.isFull) {
      emit(state.copyWith(feedback: const UiFeedback('grades_recommendations_limit')));
      return;
    }
    emit(state.copyWith(recommendations: state.recommendations.addCustom(text)));
  }

  void editRecommendation(int index, String text) =>
      emit(state.copyWith(recommendations: state.recommendations.editCustom(index, text)));

  void removeRecommendation(int index) =>
      emit(state.copyWith(recommendations: state.recommendations.removeCustom(index)));

  /// «اقترح توصيات»: added unticked, marked «مقترح».
  void addSuggestions(List<String> lines) {
    final section = state.recommendations.addSuggestions(lines);
    emit(
      state.copyWith(
        recommendations: section,
        feedback: identical(section, state.recommendations)
            ? const UiFeedback('ai_suggestions_empty')
            : const UiFeedback('ai_suggestions_added', isError: false),
      ),
    );
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
      (path) => emit(
        state.copyWith(
          isUploadingImage: false,
          images: [
            ...state.images,
            DocumentImageModel(storagePath: path, bytes: file.bytes),
          ],
        ),
      ),
    );
  }

  void removeImage(int index) => emit(state.copyWith(images: [...state.images]..removeAt(index)));

  void setTheme(DocumentTheme theme) => emit(state.copyWith(theme: theme));

  /// [DocumentStatus.draft] or [DocumentStatus.finalized]; sent with the next save.
  void setDocumentStatus(String status) => emit(state.copyWith(documentStatus: status));

  /// Why the numbers can't be worked out yet, as a translation key, or null.
  String? get analysisIssue {
    final total = totalMark;
    if (total == null || total < 1 || total > GradeLimits.maxTotalMark) return 'grades_issue_total';
    final pass = parseGrade(passMarkController.text);
    if (passMarkController.text.trim().isNotEmpty && (pass == null || pass < 0 || pass > total)) {
      return 'grades_issue_pass_mark';
    }
    for (final layout in state.classes) {
      final issue = editor.issue(layout, total: total, namesRequired: state.isDetailed);
      if (issue != null) return issue;
    }
    return null;
  }

  /// The form as `input`, or null while [analysisIssue] says it isn't ready.
  Map<String, dynamic>? analysisInput() => analysisIssue == null ? _buildInput().toJson() : null;

  Future<void> save() => _save(null);

  /// Exports always use the saved version, so this saves first.
  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> _save(DocumentFollowUp? followUp) async {
    if (state.isBusy) return;
    final issue = analysisIssue;
    if (issue != null) {
      emit(state.copyWith(feedback: UiFeedback(issue)));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final input = _buildInput().toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(type: DocumentTypes.gradeAnalysis, input: input, status: state.documentStatus)
        : await _documents.updateDocument(id, input, status: state.documentStatus);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: UiFeedback(failure.message))),
      (document) => emit(
        state.copyWith(
          isSaving: false,
          documentId: document.id,
          followUp: followUp,
          feedback: followUp == null ? const UiFeedback('document_saved', isError: false) : null,
        ),
      ),
    );
  }

  /// «حذف كل بيانات التحليل»: every saved analysis, this one too. The form stays,
  /// so saving again makes a new document.
  Future<void> deleteAll() async {
    if (state.isBusy) return;
    emit(state.copyWith(isDeletingAll: true));
    final result = await _grades.deleteAll();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isDeletingAll: false, feedback: UiFeedback(failure.message))),
      (_) => emit(
        state.copyWith(
          isDeletingAll: false,
          clearDocumentId: true,
          feedback: const UiFeedback('grades_delete_all_done', isError: false),
        ),
      ),
    );
  }

  GradeAnalysisInput _buildInput() => GradeAnalysisInput(
    reportType: state.reportType,
    subject: subjectController.text.trim(),
    grade: gradeController.text.trim(),
    testName: testNameController.text.trim(),
    date: state.date,
    totalMark: totalMark ?? 0,
    passMark: parseGrade(passMarkController.text),
    bands: state.bands,
    classes: [for (final layout in state.classes) editor.build(layout)],
    recommendations: state.recommendations.checkedTexts,
    notes: notesController.text.trim(),
    theme: state.theme,
    header: state.isOverridingHeader ? header.toJson(state.defaults) : const {},
    images: state.images.map((image) => image.storagePath).toList(),
    extra: _extra,
  );

  void _applyDocument(DocumentModel document) {
    final input = GradeAnalysisInput.fromJson(document.input);
    _extra = input.extra;
    subjectController.text = input.subject;
    gradeController.text = input.grade;
    testNameController.text = input.testName;
    totalMarkController.text = input.totalMark > 0 ? formatGrade(input.totalMark) : '';
    passMarkController.text = input.passMark == null ? '' : formatGrade(input.passMark!);
    notesController.text = input.notes;
    if (input.header.isNotEmpty) {
      header.fill(input.header);
      header.prefill(state.defaults);
    }
    for (final layout in state.classes) {
      editor.remove(layout);
    }
    final quick = input.reportType == GradeReportTypes.quick;
    emit(
      state.copyWith(
        reportType: input.reportType,
        date: input.date,
        bands: input.bands.isEmpty ? null : input.bands,
        classes: input.classes.isEmpty
            ? [_emptyClass()]
            : [
                for (final saved in input.classes)
                  // Grades saved without any name were typed one per line.
                  editor.create(saved, gradesOnly: quick && saved.students.every((row) => row.name.isEmpty)),
              ],
        recommendations: ChecklistSection.fromCatalogue(
          const ChecklistCatalogueSection(key: GradeAnalysisState.recommendationsKey, label: ''),
          saved: input.recommendations,
          maxChecked: GradeLimits.recommendations,
          maxLength: GradeLimits.recommendationLength,
        ),
        theme: input.theme,
        documentStatus: document.status,
        isOverridingHeader: input.header.isNotEmpty,
        images: document.images,
      ),
    );
  }

  GradeClassLayout _emptyClass() =>
      editor.create(GradeClassInput(students: List.filled(newClassRows, const GradeStudentInput())));

  void _setActive(GradeClassLayout layout) =>
      _changed(state.copyWith(classes: [...state.classes]..[state.activeClass] = layout));

  /// Null, with a message, unless [label] is filled and [min] is 0 to 100.
  GradeBand? _band(String label, String min) {
    final value = parseGrade(min);
    if (label.trim().isEmpty || value == null || value < 0 || value > 100) {
      emit(state.copyWith(feedback: const UiFeedback('grades_band_invalid')));
      return null;
    }
    return GradeBand(label: label.trim(), min: value);
  }

  void _setBands(List<GradeBand> bands) {
    final sorted = [...bands]..sort((a, b) => b.min.compareTo(a.min));
    if (sorted.isNotEmpty) sorted.last = GradeBand(label: sorted.last.label, min: 0);
    _changed(state.copyWith(bands: sorted));
  }

  void _changed(GradeAnalysisState next) => emit(next.copyWith(revision: state.revision + 1, feedback: next.feedback));

  void _numbersChanged() {
    if (!isClosed && state.status == GradeAnalysisStatus.success) _changed(state);
  }

  static void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.isNotEmpty) controller.text = value;
  }

  @override
  Future<void> close() {
    for (final controller in [
      subjectController,
      gradeController,
      testNameController,
      totalMarkController,
      passMarkController,
      notesController,
    ]) {
      controller.dispose();
    }
    header.dispose();
    editor.dispose();
    return super.close();
  }
}
