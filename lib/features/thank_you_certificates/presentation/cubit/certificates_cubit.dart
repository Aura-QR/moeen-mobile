import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_header_overrides.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_catalogue_model.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_input.dart';
import 'package:moean/features/thank_you_certificates/data/models/role_certificate_prefill.dart';
import 'package:moean/features/thank_you_certificates/data/repositories/certificates_repository.dart';

part 'certificates_state.dart';

/// T3 «شهادات شكر»: one landscape certificate per name, saved as one document.
class CertificatesCubit extends Cubit<CertificatesState> {
  static CertificatesCubit get(BuildContext context) => BlocProvider.of(context);

  /// The reason whose certificates go under «تحسين نتائج المتعلمين».
  static const String improvementReason = 'improvement';

  CertificatesCubit({
    int? documentId,
    RoleCertificatePrefill? rolePrefill,
    required CertificatesRepository certificatesRepository,
    required DocumentsRepository documentsRepository,
    required ClassesRepository classesRepository,
    required DeviceFilePicker filePicker,
    DateTime Function() today = DateTime.now,
  }) : _rolePrefill = rolePrefill,
       _certificates = certificatesRepository,
       _documents = documentsRepository,
       _classes = classesRepository,
       _picker = filePicker,
       _today = today,
       super(CertificatesState(documentId: documentId, initialElement: rolePrefill?.element)) {
    titleController.addListener(_textChanged);
    textController.addListener(_textChanged);
  }

  final RoleCertificatePrefill? _rolePrefill;
  final CertificatesRepository _certificates;
  final DocumentsRepository _documents;
  final ClassesRepository _classes;
  final DeviceFilePicker _picker;
  final DateTime Function() _today;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final DocumentHeaderOverrides header = DocumentHeaderOverrides();

  /// `input` fields the app doesn't edit, sent back unchanged.
  Map<String, dynamic> _extra = const {};

  /// The portfolio item preselected when adding the certificates to a portfolio.
  String get portfolioItemKey {
    final custom = state.initialElement?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return state.reason == improvementReason ? 'learner_results' : 'learning_environment';
  }

  /// Whether the title or text differ from the reason's defaults.
  bool get isTextEdited =>
      titleController.text.trim() != state.defaultTitle || textController.text.trim() != state.defaultText;

  /// Loads the catalogue and defaults, and the document when reopening one.
  Future<void> load() async {
    emit(state.copyWith(status: CertificatesStatus.loading));
    final documentId = state.documentId;
    final catalogueRequest = _certificates.getCatalogue();
    final defaultsRequest = _documents.getDefaults();
    final documentRequest = documentId == null ? null : _documents.getDocument(documentId);
    final catalogue = await catalogueRequest;
    final defaults = await defaultsRequest;
    final document = await documentRequest;
    if (isClosed) return;

    final failure =
        catalogue.fold((f) => f, (_) => null) ??
        defaults.fold((f) => f, (_) => null) ??
        document?.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: CertificatesStatus.failure, errorMessage: failure.message));
      return;
    }

    final options = catalogue.getOrElse(() => const CertificatesCatalogueModel());
    final teacher = defaults.getOrElse(() => const DocumentDefaultsModel());
    final saved = document?.fold((_) => null, (doc) => doc);
    final prefill = saved == null && _rolePrefill != null ? CertificatesInput.fromJson(_rolePrefill.input) : null;
    final input = saved == null ? prefill : CertificatesInput.fromJson(saved.input);
    _extra = input?.extra ?? const {};
    if (input != null && input.header.isNotEmpty) {
      header.fill(input.header);
      header.prefill(teacher);
    }
    emit(
      state.copyWith(
        status: CertificatesStatus.success,
        catalogue: options,
        defaults: teacher,
        names: input?.names,
        classId: input?.classId,
        audience: input?.audience.isNotEmpty == true ? input!.audience : teacher.genderForm.name,
        reason: _known(input?.reason, options.reasons.map((reason) => reason.key)),
        design: _known(input?.design, options.designs.map((design) => design.key)),
        date: saved == null ? (prefill?.date ?? _today()) : input?.date,
        clearDate: saved != null && input?.date == null,
        isOverridingHeader: input?.header.isNotEmpty ?? false,
      ),
    );
    // Empty saved text follows the reason's default, so it's shown as that.
    titleController.text = input?.title.isNotEmpty == true ? input!.title : state.defaultTitle;
    textController.text = input?.text.isNotEmpty == true ? input!.text : state.defaultText;
  }

  /// After «تعديل بيانات الترويسة», so the read-only header is current.
  Future<void> reloadDefaults() async {
    final result = await _documents.getDefaults();
    if (isClosed) return;
    result.fold((_) {}, (defaults) => _changed(state.copyWith(defaults: defaults)));
  }

  /// The picked class or typed names replace the list.
  void setNames(StudentPickerResult result) {
    _changed(
      state.copyWith(
        names: result.students.take(state.catalogue.limits.names).toList(),
        classId: result.classId,
        clearClassId: result.classId == null,
      ),
    );
  }

  void removeName(int index) => _changed(state.copyWith(names: [...state.names]..removeAt(index)));

  /// «استيراد من Excel»: the names come back in [CertificatesState.importedNames]
  /// for review; [addImportedNames] adds them.
  Future<void> importFromFile() async {
    if (state.isImporting) return;
    final file = await _picker.pickSpreadsheet();
    if (file == null || isClosed) return;
    if (file.byteSize > ClassLimits.maxImportBytes) {
      emit(state.copyWith(feedback: const UiFeedback('class_import_too_large')));
      return;
    }

    emit(state.copyWith(isImporting: true));
    final result = await _classes.importNames(file);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isImporting: false, feedback: UiFeedback(failure.message))),
      (names) => emit(
        names.isEmpty
            ? state.copyWith(isImporting: false, feedback: const UiFeedback('class_import_empty'))
            : state.copyWith(isImporting: false, importedNames: names),
      ),
    );
  }

  /// Added after the current names, up to the limit. They aren't a «فصولي» class.
  void addImportedNames(List<String> names) {
    final all = [...state.names, ...names];
    final limit = state.catalogue.limits.names;
    _changed(
      state.copyWith(
        names: all.take(limit).toList(),
        clearClassId: true,
        feedback: all.length > limit ? const UiFeedback('certificates_names_limit') : null,
      ),
    );
  }

  /// The title and text follow the new choice unless the teacher edited them.
  void setAudience(String audience) => _changeDefaults(() => state.copyWith(audience: audience));

  void setReason(String reason) => _changeDefaults(() => state.copyWith(reason: reason));

  void setDesign(String design) => _changed(state.copyWith(design: design));

  /// «استعادة النص الافتراضي».
  void restoreDefaultText() {
    titleController.text = state.defaultTitle;
    textController.text = state.defaultText;
  }

  /// «إدراج الاسم»: `{name}` at the cursor, or at the end when the field
  /// was never focused. Ignored when it would pass the limit.
  void insertNamePlaceholder() {
    const placeholder = CertificatesInput.namePlaceholder;
    final value = textController.value;
    if (value.text.length + placeholder.length > state.catalogue.limits.textChars) {
      emit(state.copyWith(feedback: const UiFeedback('certificates_text_full')));
      return;
    }
    final selection = value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
    textController.value = TextEditingValue(
      text: value.text.replaceRange(selection.start, selection.end, placeholder),
      selection: TextSelection.collapsed(offset: selection.start + placeholder.length),
    );
  }

  void setDate(DateTime date) => _changed(state.copyWith(date: date));

  void clearDate() => _changed(state.copyWith(clearDate: true));

  void setHeaderOverride(bool enabled) {
    if (enabled) header.prefill(state.defaults);
    _changed(state.copyWith(isOverridingHeader: enabled));
  }

  /// The form for one certificate: [name], or the first name, or [fallbackName]
  /// before any name is added. Null until a reason and a design are chosen.
  Map<String, dynamic>? previewInput({String? name, required String fallbackName}) {
    final input = _buildInput();
    if (input == null) return null;
    final shown = name ?? state.names.firstOrNull ?? fallbackName;
    return input.withNames([shown]).toJson();
  }

  Future<void> save() => _save(null);

  /// Exports always use the saved version, so this saves first.
  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> _save(DocumentFollowUp? followUp) async {
    if (state.isSaving || state.isImporting) return;
    final input = _buildInput();
    final error = state.names.isEmpty
        ? 'certificates_names_required'
        : input == null
        ? 'certificates_design_required'
        : null;
    if (error != null) {
      emit(state.copyWith(feedback: UiFeedback(error)));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final id = state.documentId;
    final json = input!.toJson();
    final element = state.initialElement?.trim();
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.certificates,
            input: json,
            status: DocumentStatus.draft,
            element: element == null || element.isEmpty ? null : element,
          )
        : await _documents.updateDocument(id, json, status: DocumentStatus.draft);
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

  /// Null without a reason or a design. A title or text equal to the
  /// default is sent empty, so it keeps following the reason.
  CertificatesInput? _buildInput() {
    final reason = state.reason;
    final design = state.design;
    if (reason == null || design == null) return null;
    final title = titleController.text.trim();
    final text = textController.text.trim();
    return CertificatesInput(
      names: state.names,
      classId: state.classId,
      reason: reason,
      design: design,
      audience: state.audience,
      title: title == state.defaultTitle ? '' : title,
      text: text == state.defaultText ? '' : text,
      date: state.date,
      header: state.isOverridingHeader ? header.toJson(state.defaults) : const {},
      extra: _extra,
    );
  }

  void _changeDefaults(CertificatesState Function() next) {
    final keepTitle = titleController.text.trim() != state.defaultTitle;
    final keepText = textController.text.trim() != state.defaultText;
    _changed(next());
    if (!keepTitle) titleController.text = state.defaultTitle;
    if (!keepText) textController.text = state.defaultText;
  }

  void _changed(CertificatesState next) => emit(next.copyWith(revision: state.revision + 1, feedback: next.feedback));

  void _textChanged() {
    if (!isClosed && state.status == CertificatesStatus.success) _changed(state);
  }

  /// [saved] when the catalogue still has it, else the first option.
  static String? _known(String? saved, Iterable<String> keys) => keys.contains(saved) ? saved : keys.firstOrNull;

  @override
  Future<void> close() {
    titleController.dispose();
    textController.dispose();
    header.dispose();
    return super.close();
  }
}
