import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

part 'new_concept_map_state.dart';

/// Dedicated cubit for «خريطة جديدة»: Stage → Grade → Subject → Lesson + AI map suggestion.
class NewConceptMapCubit extends Cubit<NewConceptMapState> {
  static NewConceptMapCubit get(BuildContext context) =>
      BlocProvider.of(context);

  NewConceptMapCubit({
    required CurriculumLessonsRepository curriculumRepository,
    required AiJobsRepository aiJobsRepository,
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollAttempts = 30,
  }) : _curriculum = curriculumRepository,
       _aiJobs = aiJobsRepository,
       _pollInterval = pollInterval,
       _maxPollAttempts = maxPollAttempts,
       super(const NewConceptMapState());

  final CurriculumLessonsRepository _curriculum;
  final AiJobsRepository _aiJobs;
  final Duration _pollInterval;
  final int _maxPollAttempts;

  final TextEditingController lessonSearchController = TextEditingController();

  static int _stageWeight(String name) {
    if (name.contains('الابتدائية')) return 1;
    if (name.contains('المتوسطة')) return 2;
    if (name.contains('الثانوية')) return 3;
    return 4;
  }

  static List<CurriculumStageModel> _sortStages(
    List<CurriculumStageModel> items,
  ) {
    return [...items]
      ..sort((a, b) => _stageWeight(a.name).compareTo(_stageWeight(b.name)));
  }

  Future<void> loadStages() async {
    emit(state.copyWith(isStagesLoading: true, clearStagesError: true));
    final result = await _curriculum.getStages();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isStagesLoading: false, stagesError: failure.message),
      ),
      (stages) => emit(
        state.copyWith(
          isStagesLoading: false,
          stages: _sortStages(stages),
          clearStagesError: true,
        ),
      ),
    );
  }

  void selectStage(CurriculumStageModel stage) {
    if (state.isGeneratingAi || state.selectedStage?.id == stage.id) return;
    lessonSearchController.clear();
    emit(
      state.copyWith(
        selectedStage: stage,
        clearTrack: true,
        clearGrade: true,
        clearSubject: true,
        isLessonsLoading: false,
        clearLessonsError: true,
        chapters: const [],
        lessonSearch: '',
        clearSelectedLesson: true,
        aiStatus: ConceptMapAiStatus.idle,
        clearAiError: true,
      ),
    );
  }

  void selectTrack(String track) {
    if (state.isGeneratingAi || state.selectedTrack == track) return;
    lessonSearchController.clear();
    emit(
      state.copyWith(
        selectedTrack: track,
        clearGrade: true,
        clearSubject: true,
        isLessonsLoading: false,
        clearLessonsError: true,
        chapters: const [],
        lessonSearch: '',
        clearSelectedLesson: true,
        aiStatus: ConceptMapAiStatus.idle,
        clearAiError: true,
      ),
    );
  }

  void selectGrade(CurriculumGradeModel grade) {
    if (state.isGeneratingAi || state.selectedGrade?.id == grade.id) return;
    lessonSearchController.clear();
    emit(
      state.copyWith(
        selectedGrade: grade,
        clearSubject: true,
        isLessonsLoading: false,
        clearLessonsError: true,
        chapters: const [],
        lessonSearch: '',
        clearSelectedLesson: true,
        aiStatus: ConceptMapAiStatus.idle,
        clearAiError: true,
      ),
    );
  }

  Future<void> selectSubject(CurriculumSubjectModel subject) async {
    if (state.isGeneratingAi || state.selectedSubject?.id == subject.id) return;
    lessonSearchController.clear();
    emit(
      state.copyWith(
        selectedSubject: subject,
        isLessonsLoading: true,
        clearLessonsError: true,
        chapters: const [],
        lessonSearch: '',
        clearSelectedLesson: true,
        aiStatus: ConceptMapAiStatus.idle,
        clearAiError: true,
      ),
    );
    await _fetchChapters(subject.id);
  }

  Future<void> reloadLessons() async {
    final subject = state.selectedSubject;
    if (subject == null || state.isGeneratingAi) return;
    emit(
      state.copyWith(
        isLessonsLoading: true,
        clearLessonsError: true,
        chapters: const [],
      ),
    );
    await _fetchChapters(subject.id);
  }

  Future<void> _fetchChapters(int subjectId) async {
    final result = await _curriculum.getChapters(subjectId);
    if (isClosed || state.selectedSubject?.id != subjectId) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isLessonsLoading: false, lessonsError: failure.message),
      ),
      (chapters) => emit(
        state.copyWith(
          isLessonsLoading: false,
          chapters: chapters,
          clearLessonsError: true,
        ),
      ),
    );
  }

  void updateLessonSearch(String query) {
    emit(state.copyWith(lessonSearch: query));
  }

  void selectLesson(CurriculumLessonModel lesson) {
    if (state.isGeneratingAi) return;
    emit(
      state.copyWith(
        selectedLesson: lesson,
        aiStatus: ConceptMapAiStatus.idle,
        clearAiError: true,
      ),
    );
  }

  Future<void> suggestMap() async {
    final lesson = state.selectedLesson;
    if (lesson == null || state.isGeneratingAi) return;
    emit(
      state.copyWith(
        aiStatus: ConceptMapAiStatus.generating,
        clearAiError: true,
      ),
    );

    final outcome = await _waitForAiJob({
      'lesson_ids': [lesson.id],
    });
    if (isClosed) return;

    outcome.fold(
      (failure) {
        if (failure is PaymentRequiredFailure) {
          emit(
            state.copyWith(
              aiStatus: ConceptMapAiStatus.idle,
              paymentRequired: failure,
            ),
          );
        } else if (failure is RateLimitFailure) {
          emit(
            state.copyWith(
              aiStatus: ConceptMapAiStatus.rateLimited,
              aiErrorMessage: failure.message,
            ),
          );
        } else {
          emit(
            state.copyWith(
              aiStatus: ConceptMapAiStatus.failed,
              aiErrorMessage: failure.message,
            ),
          );
        }
      },
      (job) {
        final input = ConceptMapInput.fromAiResult(
          job.rawResult,
          lessonId: lesson.id,
          fallbackTitle: lesson.title,
        );
        emit(
          state.copyWith(
            aiStatus: ConceptMapAiStatus.idle,
            clearAiError: true,
            generatedInput: input,
          ),
        );
      },
    );
  }

  Future<Either<Failure, AiJobModel>> _waitForAiJob(
    Map<String, dynamic> payload,
  ) async {
    final started = await _aiJobs.start(AiJobKinds.conceptMap, payload);
    return started.fold(Left.new, (first) async {
      var job = first;
      for (var attempt = 0; job.isPending; attempt++) {
        if (attempt >= _maxPollAttempts || isClosed) {
          return const Left(ServerFailure('concept_map_ai_timeout'));
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
        return Left(ServerFailure(job.error ?? 'concept_map_ai_failed'));
      }
      return Right(job);
    });
  }

  @override
  Future<void> close() {
    lessonSearchController.dispose();
    return super.close();
  }
}
