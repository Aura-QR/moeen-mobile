import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';

part 'new_outcomes_map_state.dart';

/// «خريطة جديدة»: Stage → (Track) → Grade → Subject → Semester, then «ابدأ»
/// builds the unit/lesson skeleton from the curriculum.
class NewOutcomesMapCubit extends Cubit<NewOutcomesMapState> {
  static NewOutcomesMapCubit get(BuildContext context) => BlocProvider.of(context);

  NewOutcomesMapCubit({required CurriculumLessonsRepository curriculumRepository})
      : _curriculum = curriculumRepository,
        super(const NewOutcomesMapState());

  final CurriculumLessonsRepository _curriculum;

  static int _stageWeight(String name) {
    if (name.contains('الابتدائية')) return 1;
    if (name.contains('المتوسطة')) return 2;
    if (name.contains('الثانوية')) return 3;
    return 4;
  }

  static List<CurriculumStageModel> _sortStages(List<CurriculumStageModel> items) =>
      [...items]..sort((a, b) => _stageWeight(a.name).compareTo(_stageWeight(b.name)));

  Future<void> loadStages() async {
    emit(state.copyWith(isStagesLoading: true, clearStagesError: true));
    final result = await _curriculum.getStages();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isStagesLoading: false, stagesError: failure.message)),
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
    if (state.selectedStage?.id == stage.id) return;
    emit(
      state.copyWith(
        selectedStage: stage,
        clearTrack: true,
        clearGrade: true,
        clearSubject: true,
        isLessonsLoading: false,
        clearLessonsError: true,
        chapters: const [],
      ),
    );
  }

  void selectTrack(String track) {
    if (state.selectedTrack == track) return;
    emit(
      state.copyWith(
        selectedTrack: track,
        clearGrade: true,
        clearSubject: true,
        isLessonsLoading: false,
        clearLessonsError: true,
        chapters: const [],
      ),
    );
  }

  void selectGrade(CurriculumGradeModel grade) {
    if (state.selectedGrade?.id == grade.id) return;
    emit(
      state.copyWith(
        selectedGrade: grade,
        clearSubject: true,
        isLessonsLoading: false,
        clearLessonsError: true,
        chapters: const [],
      ),
    );
  }

  Future<void> selectSubject(CurriculumSubjectModel subject) async {
    if (state.selectedSubject?.id == subject.id) return;
    emit(
      state.copyWith(
        selectedSubject: subject,
        isLessonsLoading: true,
        clearLessonsError: true,
        chapters: const [],
      ),
    );
    await _fetchChapters(subject.id);
  }

  Future<void> reloadLessons() async {
    final subject = state.selectedSubject;
    if (subject == null) return;
    emit(state.copyWith(isLessonsLoading: true, clearLessonsError: true, chapters: const []));
    await _fetchChapters(subject.id);
  }

  Future<void> _fetchChapters(int subjectId) async {
    final result = await _curriculum.getChapters(subjectId);
    if (isClosed || state.selectedSubject?.id != subjectId) return;
    result.fold(
      (failure) => emit(state.copyWith(isLessonsLoading: false, lessonsError: failure.message)),
      (chapters) => emit(
        state.copyWith(isLessonsLoading: false, chapters: chapters, clearLessonsError: true),
      ),
    );
  }

  void selectSemester(String semester) {
    if (state.semester == semester) return;
    emit(state.copyWith(semester: semester));
  }

  /// Builds the skeleton and signals the screen to open the editor.
  void start() {
    final subject = state.selectedSubject;
    if (subject == null || !state.canStart) return;
    final semesterName = appTranslation().get(OutcomesMapSemester.labelKey(state.semester));
    final title =
        '${appTranslation().get('outcomes_map_title')} — ${subject.name} — $semesterName';
    final input = OutcomesMapInput.fromSkeleton(
      subjectId: subject.id,
      semester: state.semester,
      title: title,
      chapters: state.chapters,
    );
    emit(state.copyWith(generatedInput: input));
  }
}
