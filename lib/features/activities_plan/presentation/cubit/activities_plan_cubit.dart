import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_plan_input.dart';
import 'package:moean/features/activities_plan/data/repositories/activities_repository.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_header_overrides.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

part 'activities_plan_state.dart';

/// T5 «خطة النشاط الطلابي»: a suggested grid of the term's weeks, with the
/// teacher's changes laid over it, saved as a document.
class ActivitiesPlanCubit extends Cubit<ActivitiesPlanState> {
  static ActivitiesPlanCubit get(BuildContext context) => BlocProvider.of(context);

  /// «إعداد خطة زمنية معتمدة لبرامج وفعاليات النشاط الطلابي», preselected when adding to a portfolio.
  static const String portfolioItemKey = 'activity_plan';

  ActivitiesPlanCubit({
    int? documentId,
    required ActivitiesRepository activitiesRepository,
    required DocumentsRepository documentsRepository,
    required DeviceFilePicker filePicker,
  })  : _activities = activitiesRepository,
        _documents = documentsRepository,
        _picker = filePicker,
        super(ActivitiesPlanState(documentId: documentId));

  final ActivitiesRepository _activities;
  final DocumentsRepository _documents;
  final DeviceFilePicker _picker;

  final TextEditingController activityLeaderController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final DocumentHeaderOverrides header = DocumentHeaderOverrides();

  /// `input` fields the app doesn't edit, sent back unchanged.
  Map<String, dynamic> _extra = const {};

  /// Only the latest grid request may land; earlier ones are for old choices.
  int _gridRequest = 0;

  /// Loads the catalogue and defaults, and the document when reopening one,
  /// then the grid for its choices.
  Future<void> load() async {
    emit(state.copyWith(status: ActivitiesPlanStatus.loading));
    final documentId = state.documentId;
    final catalogueRequest = _activities.getCatalogue();
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
      emit(state.copyWith(status: ActivitiesPlanStatus.failure, errorMessage: failure.message));
      return;
    }

    emit(state.copyWith(
      status: ActivitiesPlanStatus.success,
      catalogue: catalogue.getOrElse(() => const ActivitiesCatalogueModel()),
      defaults: defaults.getOrElse(() => const DocumentDefaultsModel()),
    ));
    final saved = document?.fold((_) => null, (doc) => doc);
    if (saved != null) _applyDocument(saved);
    await loadGrid();
  }

  /// After «تعديل بيانات الترويسة», so the read-only header is current.
  Future<void> reloadDefaults() async {
    final result = await _documents.getDefaults();
    if (isClosed) return;
    result.fold((_) {}, (defaults) => emit(state.copyWith(defaults: defaults)));
  }

  void setStage(String stage) => _changeChoice(state.copyWith(stage: stage));

  void setTerm(int term) => _changeChoice(state.copyWith(term: term));

  void setRegion(String region) => _changeChoice(state.copyWith(region: region));

  /// Adds the domain as the last column, or removes it.
  void toggleDomain(String key) {
    final domains = state.domains.contains(key)
        ? state.domains.where((domain) => domain != key).toList()
        : [...state.domains, key];
    _changeChoice(state.copyWith(domains: domains));
  }

  /// [newIndex] is the final position, after removing the moved domain.
  void reorderDomain(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final domains = [...state.domains];
    domains.insert(newIndex, domains.removeAt(oldIndex));
    _changeChoice(state.copyWith(domains: domains));
  }

  /// The suggested grid for the current choices. The teacher's changed
  /// cells stay; untouched cells follow the new suggestions.
  Future<void> loadGrid() async {
    final stage = state.stage;
    if (stage == null || state.domains.isEmpty) return;
    final request = ++_gridRequest;
    emit(state.copyWith(gridStatus: ActivitiesGridStatus.loading));
    final result = await _activities.getGrid(
      stage: stage,
      term: state.term,
      domains: state.domains,
      region: state.region,
    );
    if (isClosed || request != _gridRequest) return;
    result.fold(
      (failure) => emit(state.copyWith(gridStatus: ActivitiesGridStatus.failure, gridError: failure.message)),
      (grid) => emit(state.copyWith(gridStatus: ActivitiesGridStatus.success, grid: grid)),
    );
  }

  /// Text equal to the suggestion clears the change; empty text empties the cell.
  void setCell(int week, String column, String text) {
    final value = text.trim();
    final suggestion = state.grid?.weekNumber(week)?.cells[column]?.trim() ?? '';
    if (value == suggestion) {
      resetCell(week, column);
      return;
    }
    emit(state.copyWith(cells: {
      ...state.cells,
      week: {...?state.cells[week], column: value},
    }));
  }

  /// «استعادة المقترح».
  void resetCell(int week, String column) {
    final row = {...?state.cells[week]}..remove(column);
    emit(state.copyWith(cells: {...state.cells, week: row}..removeWhere((_, cells) => cells.isEmpty)));
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
  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> _save(DocumentFollowUp? followUp) async {
    if (state.isSaving || state.isUploadingImage) return;
    final error = state.stage == null
        ? 'activities_plan_stage_required'
        : state.domains.isEmpty
            ? 'activities_plan_domains_required'
            : null;
    if (error != null) {
      emit(state.copyWith(feedback: UiFeedback(error)));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final input = _buildInput().toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.activitiesPlan,
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

  /// Changes for removed domains are left out, so a domain added back starts
  /// from its suggestions.
  ActivitiesPlanInput _buildInput() {
    final columns = {...state.domains, ActivitiesColumns.occasion};
    return ActivitiesPlanInput(
      stage: state.stage!,
      domains: state.domains,
      term: state.term,
      region: state.region,
      activityLeader: activityLeaderController.text.trim(),
      academicYear: academicYearController.text.trim(),
      cells: {
        for (final week in state.cells.entries)
          week.key: {
            for (final cell in week.value.entries)
              if (columns.contains(cell.key)) cell.key: cell.value,
          },
      },
      notes: notesController.text.trim(),
      theme: state.theme,
      header: state.isOverridingHeader ? header.toJson(state.defaults) : const {},
      images: state.images.map((image) => image.storagePath).toList(),
      extra: _extra,
    );
  }

  void _applyDocument(DocumentModel document) {
    final input = ActivitiesPlanInput.fromJson(document.input);
    _extra = input.extra;
    activityLeaderController.text = input.activityLeader;
    academicYearController.text = input.academicYear;
    notesController.text = input.notes;
    if (input.header.isNotEmpty) {
      header.fill(input.header);
      header.prefill(state.defaults);
    }
    emit(state.copyWith(
      stage: input.stage.isEmpty ? null : input.stage,
      domains: input.domains,
      term: input.term,
      region: input.region,
      cells: input.cells,
      theme: input.theme,
      documentStatus: document.status,
      isOverridingHeader: input.header.isNotEmpty,
      images: document.images,
    ));
  }

  void _changeChoice(ActivitiesPlanState next) {
    emit(next);
    loadGrid();
  }

  @override
  Future<void> close() {
    activityLeaderController.dispose();
    academicYearController.dispose();
    notesController.dispose();
    header.dispose();
    return super.close();
  }
}
