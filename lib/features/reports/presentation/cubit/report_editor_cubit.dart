import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/models/report_field_error.dart';
import 'package:moean/features/reports/data/models/report_input.dart';
import 'package:moean/features/reports/data/models/role_ai_merge.dart';
import 'package:moean/features/reports/data/models/role_report_editor_args.dart';
import 'package:moean/features/reports/data/repositories/reports_repository.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/data/repositories/role_suites_repository.dart';

part 'report_editor_state.dart';

class _AiUndoSnapshot {
  final ReportInput input;
  final String title;
  final bool wasDirty;

  const _AiUndoSnapshot({required this.input, required this.title, required this.wasDirty});
}

/// T8 «التقارير والشواهد» & L1 «حقائب الأدوار» report editor.
class ReportEditorCubit extends Cubit<ReportEditorState> {
  static ReportEditorCubit get(BuildContext context) => BlocProvider.of(context);

  /// The template a new report starts from when none is picked.
  static const String blankTemplate = 'blank';

  /// Default portfolio item key when the template has no explicit element.
  static const String portfolioItemKey = 'duties';

  /// Open [documentId], start from [templateKey], or open [roleArgs] from «حقائب الأدوار».
  ReportEditorCubit({
    required ReportsRepository reports,
    required DocumentsRepository documents,
    required DeviceFilePicker picker,
    RoleSuitesRepository? roleSuites,
    AiJobsRepository? aiJobs,
    int? documentId,
    String? templateKey,
    RoleReportEditorArgs? roleArgs,
    Duration aiPollInterval = const Duration(seconds: 2),
    int maxAiPollAttempts = 45,
  }) : _reports = reports,
       _documents = documents,
       _picker = picker,
       _roleSuites = roleSuites,
       _aiJobs = aiJobs,
       _templateKey = templateKey ?? blankTemplate,
       _roleArgs = roleArgs,
       _aiPollInterval = aiPollInterval,
       _maxAiPollAttempts = maxAiPollAttempts,
       super(ReportEditorState(documentId: documentId, roleTemplate: roleArgs?.template)) {
    briefController.addListener(_onBriefChanged);
  }

  final ReportsRepository _reports;
  final DocumentsRepository _documents;
  final DeviceFilePicker _picker;
  final RoleSuitesRepository? _roleSuites;
  final AiJobsRepository? _aiJobs;
  final String _templateKey;
  final RoleReportEditorArgs? _roleArgs;
  final Duration _aiPollInterval;
  final int _maxAiPollAttempts;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController briefController = TextEditingController();
  final TextEditingController stageController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController occasionController = TextEditingController();

  int _lastId = 0;
  _AiUndoSnapshot? _aiUndoSnapshot;
  Map<String, dynamic>? _lastAiInput;

  int _nextId() => ++_lastId;

  String get activePortfolioItemKey {
    final element = state.roleTemplate?.element?.trim();
    return element != null && element.isNotEmpty ? element : portfolioItemKey;
  }

  Future<void> load() async {
    emit(state.copyWith(status: ReportEditorStatus.loading));
    final id = state.documentId;
    final roleArgs = _roleArgs;
    final catalogueRequest = _reports.getCatalogue();
    final documentRequest = id == null ? null : _documents.getDocument(id);
    final roleDocRequest = id == null && roleArgs != null
        ? (roleArgs.template != null
              ? Future.value(Right<Failure, RoleDocumentTemplateModel>(roleArgs.template!))
              : _roleSuites!.getDocument(roleArgs.role, roleArgs.doc))
        : null;
    final templateRequest = id == null && roleArgs == null ? _reports.getTemplate(_templateKey) : null;
    final defaultsRequest = roleArgs != null ? _documents.getDefaults() : null;

    final catalogue = await catalogueRequest;
    final document = await documentRequest;
    final roleDocResult = await roleDocRequest;
    final template = await templateRequest;
    var defaultsResult = await defaultsRequest;
    if (isClosed) return;

    final failure =
        catalogue.fold((f) => f, (_) => null) ??
        document?.fold((f) => f, (_) => null) ??
        roleDocResult?.fold((f) => f, (_) => null) ??
        template?.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: ReportEditorStatus.failure, errorMessage: failure.message));
      return;
    }

    final saved = document?.fold((_) => null, (doc) => doc);
    var roleTemplate = roleDocResult?.fold((_) => null, (doc) => doc);

    // Reopening a saved role document from «مستنداتي»: restore role metadata if available.
    if (saved != null && roleTemplate == null && _roleSuites != null) {
      final savedRole = saved.input['role']?.toString() ?? '';
      final savedDoc = saved.input['doc']?.toString() ?? '';
      if (savedRole.isNotEmpty && savedDoc.isNotEmpty) {
        final reopenedMeta = await _roleSuites.getDocument(savedRole, savedDoc);
        defaultsResult ??= await _documents.getDefaults();
        if (isClosed) return;
        roleTemplate = reopenedMeta.fold((_) => null, (doc) => doc);
      }
    }

    final Map<String, dynamic> json =
        saved?.input ??
        roleTemplate?.input ??
        template!.fold<Map<String, dynamic>>((_) => const {}, (input) => input);
    final parsedInput = ReportInput.fromJson(json, _nextId);
    final resolvedTitle = parsedInput.title.trim().isNotEmpty
        ? parsedInput.title
        : (roleTemplate?.label ?? '');
    final input = parsedInput.copyWith(title: resolvedTitle);
    titleController.text = input.title;
    final defaults = defaultsResult?.fold((_) => const DocumentDefaultsModel(), (d) => d) ?? state.defaults;

    emit(
      state.copyWith(
        status: ReportEditorStatus.success,
        catalogue: catalogue.fold((_) => null, (c) => c),
        roleTemplate: roleTemplate,
        defaults: defaults,
        input: input,
        images: saved?.images ?? [for (final path in input.images) DocumentImageModel(storagePath: path)],
        documentStatus: saved?.status,
      ),
    );
  }

  ReportLimitsModel get _limits => state.catalogue?.limits ?? const ReportLimitsModel();

  void _onBriefChanged() {
    final len = briefController.text.length;
    if (!isClosed && len != state.briefLength) {
      emit(state.copyWith(briefLength: len));
    }
  }

  void setAiDate(DateTime date) {
    final formatted = isoDate(date);
    dateController.text = formatted;
    emit(state.copyWith(aiDate: formatted));
  }

  void clearAiDate() {
    dateController.clear();
    emit(state.copyWith(aiDate: ''));
  }

  // «✨ اكتب لي» (role_document AI flow).

  Future<void> writeWithAi() async {
    final roleDoc = state.roleTemplate;
    final brief = briefController.text.trim();
    if (roleDoc == null || !state.canUseAi || state.isAiWriting || brief.isEmpty) return;
    final stage = stageController.text.trim();
    final grade = gradeController.text.trim();
    final date = dateController.text.trim();
    final occasion = occasionController.text.trim();
    final payload = <String, dynamic>{
      'role': roleDoc.role,
      'doc': roleDoc.doc,
      'brief': brief,
      if (stage.isNotEmpty) 'stage': stage,
      if (grade.isNotEmpty) 'grade': grade,
      if (date.isNotEmpty) 'date': date,
      if (occasion.isNotEmpty) 'occasion': occasion,
      'gender': state.defaults.genderForm.name,
      if (roleDoc.term != null && '${roleDoc.term}'.isNotEmpty) 'term': roleDoc.term,
      if (roleDoc.region != null && '${roleDoc.region}'.isNotEmpty) 'region': roleDoc.region,
    };
    _lastAiInput = payload;
    await _runAiJob(payload);
  }

  Future<void> retryWriteWithAi() async {
    final payload = _lastAiInput;
    if (payload == null || state.isAiWriting) return;
    await _runAiJob(payload);
  }

  Future<void> _runAiJob(Map<String, dynamic> payload) async {
    final aiRepo = _aiJobs;
    if (aiRepo == null) return;
    emit(state.copyWith(aiStatus: RoleAiStatus.writing, clearAiError: true));
    final outcome = await _pollAiJob(aiRepo, payload);
    if (isClosed) return;
    outcome.fold(
      (failure) {
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(aiStatus: RoleAiStatus.idle, paymentRequired: failure));
        } else if (failure is RateLimitFailure) {
          emit(state.copyWith(aiStatus: RoleAiStatus.rateLimited, aiErrorMessage: failure.message));
        } else {
          emit(state.copyWith(aiStatus: RoleAiStatus.failed, aiErrorMessage: failure.message));
        }
      },
      (job) {
        _aiUndoSnapshot = _AiUndoSnapshot(
          input: state.input,
          title: titleController.text,
          wasDirty: state.isDirty,
        );
        final merged = mergeRoleAiResult(
          current: state.input,
          currentTitle: titleController.text,
          result: job.rawResult,
          nextId: _nextId,
        );
        titleController.text = merged.title;
        emit(
          state.copyWith(
            input: merged,
            isDirty: true,
            aiStatus: RoleAiStatus.done,
            clearAiError: true,
            canUndoAi: true,
            clearTitleError: true,
            blockErrors: const {},
          ),
        );
      },
    );
  }

  Future<Either<Failure, AiJobModel>> _pollAiJob(
    AiJobsRepository aiRepo,
    Map<String, dynamic> payload,
  ) async {
    final started = await aiRepo.start(AiJobKinds.roleDocument, payload);
    return started.fold(Left.new, (first) async {
      var job = first;
      for (var attempt = 0; job.isPending; attempt++) {
        if (attempt >= _maxAiPollAttempts || isClosed) {
          return const Left(ServerFailure('role_ai_timeout'));
        }
        await Future<void>.delayed(_aiPollInterval);
        final next = await aiRepo.getJob(job.id);
        final failure = next.fold<Failure?>((f) => f, (polled) {
          job = polled;
          return null;
        });
        if (failure != null) return Left(failure);
      }
      if (job.isFailed) {
        final msg = job.error?.trim() ?? '';
        return Left(ServerFailure(msg.isNotEmpty ? msg : 'role_ai_failed'));
      }
      return Right(job);
    });
  }

  /// «تراجع»: restores the document state from right before the last AI merge.
  void undoAiMerge() {
    final snapshot = _aiUndoSnapshot;
    if (snapshot == null) return;
    _aiUndoSnapshot = null;
    titleController.text = snapshot.title;
    emit(
      state.copyWith(
        input: snapshot.input,
        isDirty: snapshot.wasDirty,
        aiStatus: RoleAiStatus.idle,
        clearAiError: true,
        canUndoAi: false,
      ),
    );
  }

  // Member lists & sign-in sheets («من فصولي» -> names_column).

  void fillTableNames(int blockId, List<String> names) {
    final block = state.input.blocks.whereType<TableBlock>().where((b) => b.id == blockId).firstOrNull;
    if (block == null) return;
    final colIndex = state.namesColumnFor(block);
    if (colIndex == null) return;
    updateBlock(block.fillNamesColumn(colIndex, names, _limits.tableRows));
  }

  // Meta rows.

  void addMeta(String label, String value) {
    if (state.input.meta.length >= _limits.meta || label.trim().isEmpty) return;
    final effectiveValue = state.isSensitive ? '' : value.trim();
    _setInput(
      state.input.copyWith(
        meta: [...state.input.meta, ReportMetaRow(_nextId(), label: label.trim(), value: effectiveValue)],
      ),
    );
  }

  void updateMeta(int id, String label, String value) {
    final effectiveValue = state.isSensitive ? '' : value.trim();
    _setInput(
      state.input.copyWith(
        meta: [
          for (final row in state.input.meta)
            row.id == id ? ReportMetaRow(id, label: label.trim(), value: effectiveValue) : row,
        ],
      ),
    );
  }

  void removeMeta(int id) =>
      _setInput(state.input.copyWith(meta: state.input.meta.where((row) => row.id != id).toList()));

  // Blocks.

  /// [index] null adds at the end.
  void addBlock(String kind, {int? index}) {
    if (state.isSensitive && kind == ReportBlockKinds.images) return;
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
    _setInput(state.input.copyWith(blocks: [for (final b in state.input.blocks) b.id == block.id ? block : b]));
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
    if (state.isSensitive) return;
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
      (path) => emit(
        state.copyWith(
          isUploadingImage: false,
          isDirty: true,
          images: [...state.images, DocumentImageModel(storagePath: path, bytes: file.bytes)],
        ),
      ),
    );
  }

  /// Also takes the photo out of every images block.
  void removeImage(int index) {
    final path = state.images[index].storagePath;
    emit(state.copyWith(images: [...state.images]..removeAt(index)));
    _setInput(
      state.input.copyWith(
        blocks: [
          for (final block in state.input.blocks)
            block is ImagesBlock && block.items.contains(path) ? block.toggle(path) : block,
        ],
      ),
    );
  }

  // Settings.

  void setTheme(DocumentTheme theme) => _setInput(state.input.copyWith(theme: theme));

  void setDocumentStatus(String status) => emit(state.copyWith(documentStatus: status, isDirty: true));

  void addSignature(String title, String name) {
    if (state.input.signatures.length >= ReportEditorState.maxSignatures || title.trim().isEmpty) return;
    _setInput(
      state.input.copyWith(
        signatures: [...state.input.signatures, ReportSignature(title: title.trim(), name: name.trim())],
      ),
    );
  }

  void updateSignature(int index, String title, String name) => _setInput(
    state.input.copyWith(
      signatures: [...state.input.signatures]
        ..[index] = ReportSignature(title: title.trim(), name: name.trim()),
    ),
  );

  void removeSignature(int index) =>
      _setInput(state.input.copyWith(signatures: [...state.input.signatures]..removeAt(index)));

  void markTitleEdited() {
    if (!state.isDirty || state.titleError != null) {
      emit(state.copyWith(isDirty: true, clearTitleError: true));
    }
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
      emit(
        state.copyWith(
          blockErrors: errors,
          scrollToBlockId: errors.keys.first,
          feedback: UiFeedback(errors.values.first),
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true));
    final input = state.input
        .copyWith(
          title: titleController.text.trim(),
          images: state.isSensitive ? const [] : state.images.map((i) => i.storagePath).toList(),
        )
        .toJson();
    final id = state.documentId;
    final initialElement = state.roleTemplate?.element?.trim();
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.report,
            input: input,
            status: state.documentStatus,
            element: initialElement == null || initialElement.isEmpty ? null : initialElement,
            keepFieldErrors: true,
          )
        : await _documents.updateDocument(id, input, status: state.documentStatus, keepFieldErrors: true);
    if (isClosed) return;
    result.fold(
      (failure) => emit(_failed(failure)),
      (document) => emit(
        state.copyWith(
          isSaving: false,
          isDirty: false,
          documentId: document.id,
          blockErrors: const {},
          clearTitleError: true,
          followUp: followUp,
          feedback: followUp == null && !quiet ? const UiFeedback('document_saved', isError: false) : null,
        ),
      ),
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
      if (index != null && index < blocks.length) {
        blockErrors.putIfAbsent(blocks[index].id, () => error.message);
      }
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
    briefController.removeListener(_onBriefChanged);
    titleController.dispose();
    briefController.dispose();
    stageController.dispose();
    gradeController.dispose();
    dateController.dispose();
    occasionController.dispose();
    return super.close();
  }
}
