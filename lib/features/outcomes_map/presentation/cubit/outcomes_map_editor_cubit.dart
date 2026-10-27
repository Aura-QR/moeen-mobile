import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_field_error.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';

part 'outcomes_map_editor_state.dart';

/// L9 «خريطة نواتج التعلم» editor: unit/lesson/outcome editing, per-unit AI
/// suggestions, validation, preview & save.
class OutcomesMapEditorCubit extends Cubit<OutcomesMapEditorState> {
  static OutcomesMapEditorCubit get(BuildContext context) => BlocProvider.of(context);

  /// «يُحسب شاهدًا لـ»: a learning-outcomes map is planning evidence.
  static const String portfolioItemKey = 'teaching_strategies';

  OutcomesMapEditorCubit({
    required DocumentsRepository documentsRepository,
    required AiJobsRepository aiJobsRepository,
    int? documentId,
    OutcomesMapInput? initialInput,
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollAttempts = 30,
  })  : _documents = documentsRepository,
        _aiJobs = aiJobsRepository,
        _initialInput = initialInput,
        _pollInterval = pollInterval,
        _maxPollAttempts = maxPollAttempts,
        super(
          OutcomesMapEditorState(
            documentId: documentId,
            input: initialInput ?? const OutcomesMapInput(units: [OutcomeUnit()]),
            isDirty: initialInput != null,
          ),
        );

  final DocumentsRepository _documents;
  final AiJobsRepository _aiJobs;
  final OutcomesMapInput? _initialInput;
  final Duration _pollInterval;
  final int _maxPollAttempts;

  final TextEditingController titleController = TextEditingController();

  Future<void> load() async {
    emit(state.copyWith(status: OutcomesMapEditorStatus.loading));
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
          status: OutcomesMapEditorStatus.failure,
          errorMessage: docFailure.message,
        ),
      );
      return;
    }

    final defaults = defaultsResult.fold((_) => const DocumentDefaultsModel(), (d) => d);
    final saved = docResult?.fold((_) => null, (doc) => doc);

    if (saved != null) {
      final parsed = OutcomesMapInput.fromJson(saved.input);
      final resolvedTitle = parsed.title.trim().isNotEmpty ? parsed.title : saved.title;
      final input = parsed.copyWith(title: resolvedTitle);
      titleController.text = input.title;
      emit(
        state.copyWith(
          status: OutcomesMapEditorStatus.success,
          defaults: defaults,
          documentStatus: saved.status,
          input: input,
          isDirty: false,
        ),
      );
      return;
    }

    final starter = _initialInput ?? const OutcomesMapInput(units: [OutcomeUnit()]);
    titleController.text = starter.title;
    emit(
      state.copyWith(
        status: OutcomesMapEditorStatus.success,
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

  // --- Structure editing --------------------------------------------------

  void addUnit() {
    if (!state.input.canAddUnit) return;
    emit(state.copyWith(input: state.input.addUnit(), isDirty: true));
  }

  void deleteUnit(int unitIndex) {
    emit(
      state.copyWith(
        input: state.input.deleteUnit(unitIndex),
        unitErrors: const {},
        lessonErrors: const {},
        unitAiStatus: const {},
        isDirty: true,
      ),
    );
  }

  void updateUnitName(int unitIndex, String name) {
    final nextErrors = Map<int, String>.from(state.unitErrors)..remove(unitIndex);
    emit(
      state.copyWith(
        input: state.input.updateUnitName(unitIndex, name),
        unitErrors: nextErrors,
        isDirty: true,
      ),
    );
  }

  void addLesson(int unitIndex) {
    if (!state.input.canAddLesson(unitIndex)) return;
    emit(state.copyWith(input: state.input.addLesson(unitIndex), isDirty: true));
  }

  void deleteLesson(int unitIndex, int lessonIndex) {
    final nextErrors = Map<String, String>.from(state.lessonErrors)
      ..remove(LessonRef(unitIndex, lessonIndex).key);
    emit(
      state.copyWith(
        input: state.input.deleteLesson(unitIndex, lessonIndex),
        lessonErrors: nextErrors,
        isDirty: true,
      ),
    );
  }

  void updateLessonTitle(int unitIndex, int lessonIndex, String title) {
    emit(
      state.copyWith(
        input: state.input.updateLessonTitle(unitIndex, lessonIndex, title),
        isDirty: true,
      ),
    );
  }

  void addOutcome(int unitIndex, int lessonIndex) {
    if (!state.input.canAddOutcome(unitIndex, lessonIndex)) return;
    emit(state.copyWith(input: state.input.addOutcome(unitIndex, lessonIndex), isDirty: true));
  }

  void updateOutcome(int unitIndex, int lessonIndex, int outcomeIndex, String text) {
    final nextErrors = Map<String, String>.from(state.lessonErrors)
      ..remove(LessonRef(unitIndex, lessonIndex).key);
    emit(
      state.copyWith(
        input: state.input.updateOutcome(unitIndex, lessonIndex, outcomeIndex, text),
        lessonErrors: nextErrors,
        isDirty: true,
      ),
    );
  }

  void deleteOutcome(int unitIndex, int lessonIndex, int outcomeIndex) {
    emit(
      state.copyWith(
        input: state.input.deleteOutcome(unitIndex, lessonIndex, outcomeIndex),
        isDirty: true,
      ),
    );
  }

  void setLayout(OutcomesMapLayout layout) {
    if (layout == state.input.layout) return;
    emit(state.copyWith(input: state.input.copyWith(layout: layout), isDirty: true));
  }

  void toggleSignature(OutcomesMapSignature signature, bool enabled) {
    final next = {...state.input.signatures};
    if (enabled) {
      next.add(signature);
    } else {
      next.remove(signature);
    }
    emit(state.copyWith(input: state.input.copyWith(signatures: next), isDirty: true));
  }

  void setDocumentStatus(String status) {
    if (status == state.documentStatus) return;
    emit(state.copyWith(documentStatus: status, isDirty: true));
  }

  // --- AI «اقترح النواتج» -------------------------------------------------

  /// One job per unit (chunked at 8 lessons), run one after another.
  Future<void> suggestAllOutcomes() async {
    if (state.isAiBusy) return;
    emit(
      state.copyWith(
        isSuggestingAll: true,
        aiTotalUnits: state.input.units.length,
        aiCurrentUnit: 0,
        unitAiStatus: const {},
      ),
    );

    for (var index = 0; index < state.input.units.length; index++) {
      if (isClosed) return;
      emit(state.copyWith(aiCurrentUnit: index + 1));
      if (state.input.units[index].fillableLessonIds.isEmpty) {
        _markUnit(index, UnitAiStatus.done);
        continue;
      }
      final result = await _runUnit(index);
      if (isClosed) return;
      if (result == _UnitRunResult.stop) {
        emit(state.copyWith(isSuggestingAll: false));
        return;
      }
    }
    emit(state.copyWith(isSuggestingAll: false));
  }

  /// Retries a single unit from its card's «إعادة».
  Future<void> suggestUnit(int unitIndex) async {
    if (state.isAiBusy) return;
    if (unitIndex < 0 || unitIndex >= state.input.units.length) return;
    emit(state.copyWith(isSuggestingAll: true, aiTotalUnits: 1, aiCurrentUnit: 1));
    await _runUnit(unitIndex);
    if (isClosed) return;
    emit(state.copyWith(isSuggestingAll: false));
  }

  /// Runs «✨ اقترح لهذا الدرس» for one lesson.
  Future<void> suggestLesson(int unitIndex, int lessonIndex) async {
    final lesson = state.input.lessonAt(unitIndex, lessonIndex);
    if (lesson == null || lesson.lessonId == null || state.isAiBusy) return;
    emit(state.copyWith(aiBusyLesson: LessonRef(unitIndex, lessonIndex)));
    final outcome = await _waitForAiJob([lesson.lessonId!]);
    if (isClosed) return;
    outcome.fold(
      (failure) => emit(_aiFailureState(failure)),
      (job) {
        final parsed = _parseJob(job);
        final outcomes = parsed[lesson.lessonId];
        emit(
          state.copyWith(
            input: outcomes == null || outcomes.isEmpty
                ? state.input
                : state.input.fillUnitFromAi(unitIndex, {lesson.lessonId!: outcomes}),
            isDirty: outcomes != null && outcomes.isNotEmpty ? true : state.isDirty,
          ),
        );
      },
    );
  }

  Future<_UnitRunResult> _runUnit(int unitIndex) async {
    _markUnit(unitIndex, UnitAiStatus.running);
    final ids = state.input.units[unitIndex].fillableLessonIds;
    if (ids.isEmpty) {
      _markUnit(unitIndex, UnitAiStatus.done);
      return _UnitRunResult.ok;
    }

    final collected = <int, List<String>>{};
    for (final chunk in _chunk(ids, OutcomesMapLimits.aiLessonsPerJob)) {
      final outcome = await _waitForAiJob(chunk);
      if (isClosed) return _UnitRunResult.stop;
      Failure? failure;
      outcome.fold((f) => failure = f, (job) => collected.addAll(_parseJob(job)));
      if (failure != null) {
        _markUnit(unitIndex, UnitAiStatus.failed);
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(paymentRequired: failure as PaymentRequiredFailure));
          return _UnitRunResult.stop;
        }
        if (failure is RateLimitFailure) {
          emit(state.copyWith(feedback: UiFeedback(failure!.message)));
          return _UnitRunResult.stop;
        }
        return _UnitRunResult.failed;
      }
    }

    emit(
      state.copyWith(
        input: state.input.fillUnitFromAi(unitIndex, collected),
        isDirty: true,
      ),
    );
    _markUnit(unitIndex, UnitAiStatus.done);
    return _UnitRunResult.ok;
  }

  void _markUnit(int index, UnitAiStatus status) {
    emit(state.copyWith(unitAiStatus: {...state.unitAiStatus, index: status}));
  }

  OutcomesMapEditorState _aiFailureState(Failure failure) {
    if (failure is PaymentRequiredFailure) {
      return state.copyWith(paymentRequired: failure);
    }
    return state.copyWith(feedback: UiFeedback(failure.message));
  }

  Future<Either<Failure, AiJobModel>> _waitForAiJob(List<int> lessonIds) async {
    final started = await _aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': lessonIds});
    return started.fold(Left.new, (first) async {
      var job = first;
      for (var attempt = 0; job.isPending; attempt++) {
        if (attempt >= _maxPollAttempts || isClosed) {
          return const Left(ServerFailure('outcomes_map_ai_timeout'));
        }
        await Future<void>.delayed(_pollInterval);
        final next = await _aiJobs.getJob(job.id);
        final failure = next.fold<Failure?>((failure) => failure, (polled) {
          job = polled;
          return null;
        });
        if (failure != null) return Left(failure);
      }
      if (job.isFailed) {
        return Left(ServerFailure(job.error ?? 'outcomes_map_ai_failed'));
      }
      return Right(job);
    });
  }

  static Map<int, List<String>> _parseJob(AiJobModel job) {
    final lessons = job.rawResult['lessons'];
    final map = <int, List<String>>{};
    if (lessons is List) {
      for (final item in lessons.whereType<Map>()) {
        final id = int.tryParse((item['lesson_id'] ?? item['id'])?.toString() ?? '');
        if (id == null) continue;
        final outcomes = item['outcomes'];
        if (outcomes is List) {
          map[id] = [
            for (final outcome in outcomes)
              if (outcome.toString().trim().isNotEmpty) outcome.toString().trim(),
          ];
        }
      }
    }
    return map;
  }

  static List<List<int>> _chunk(List<int> items, int size) => [
        for (var i = 0; i < items.length; i += size)
          items.sublist(i, i + size > items.length ? items.length : i + size),
      ];

  // --- Preview & save -----------------------------------------------------

  Map<String, dynamic> buildPreviewPayload() =>
      state.input.copyWith(title: titleController.text.trim()).toJson();

  Future<void> save() => _save(null);

  Future<void> saveAndExport() => _save(DocumentFollowUp.export);

  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> saveIfDirty() async {
    if (!state.isDirty || state.status != OutcomesMapEditorStatus.success) return;
    if (titleController.text.trim().isEmpty) return;
    if (state.input.hasEmptyLesson) return;
    await _save(null, quiet: true);
  }

  Future<void> _save(DocumentFollowUp? followUp, {bool quiet = false}) async {
    if (state.isSaving || state.isAiBusy) return;
    final trimmedTitle = titleController.text.trim();
    if (trimmedTitle.isEmpty) {
      emit(
        state.copyWith(
          titleError: 'outcomes_map_title_required',
          feedback: const UiFeedback('outcomes_map_title_required'),
        ),
      );
      return;
    }

    final emptyLesson = _firstEmptyLesson();
    if (emptyLesson != null) {
      emit(
        state.copyWith(
          lessonErrors: {
            ...state.lessonErrors,
            emptyLesson.key: 'outcomes_map_lesson_needs_outcome',
          },
          openLesson: emptyLesson,
          feedback: const UiFeedback('outcomes_map_lesson_needs_outcome'),
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true));
    final payload = state.input.copyWith(title: trimmedTitle).toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.outcomesMap,
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
          unitErrors: const {},
          lessonErrors: const {},
          clearTitleError: true,
          followUp: followUp,
          feedback: followUp == null && !quiet
              ? const UiFeedback('document_saved', isError: false)
              : null,
        ),
      ),
    );
  }

  LessonRef? _firstEmptyLesson() {
    for (var u = 0; u < state.input.units.length; u++) {
      final lessons = state.input.units[u].lessons;
      for (var l = 0; l < lessons.length; l++) {
        if (!lessons[l].hasOutcomes) return LessonRef(u, l);
      }
    }
    return null;
  }

  OutcomesMapEditorState _handleSaveFailure(Failure failure) {
    if (failure is PaymentRequiredFailure) {
      return state.copyWith(isSaving: false, paymentRequired: failure);
    }
    if (failure is! ValidationFailure) {
      return state.copyWith(isSaving: false, feedback: UiFeedback(failure.message));
    }

    final unitErrors = <int, String>{};
    final lessonErrors = <String, String>{};
    String? titleError;
    LessonRef? firstLesson;

    for (final entry in failure.errors.entries) {
      final parsed = OutcomesMapFieldError.parse(entry.key, entry.value);
      if (parsed == null) continue;
      if (parsed.isTitle) {
        titleError ??= parsed.message;
      } else if (parsed.isLesson) {
        final ref = LessonRef(parsed.unitIndex!, parsed.lessonIndex!);
        if (state.input.lessonAt(ref.unitIndex, ref.lessonIndex) != null) {
          lessonErrors.putIfAbsent(ref.key, () => parsed.message);
          firstLesson ??= ref;
        }
      } else if (parsed.unitIndex != null) {
        unitErrors.putIfAbsent(parsed.unitIndex!, () => parsed.message);
      }
    }

    return state.copyWith(
      isSaving: false,
      titleError: titleError,
      unitErrors: unitErrors,
      lessonErrors: lessonErrors,
      openLesson: firstLesson,
      feedback: UiFeedback(failure.message),
    );
  }

  @override
  Future<void> close() {
    titleController.dispose();
    return super.close();
  }
}

enum _UnitRunResult { ok, failed, stop }
