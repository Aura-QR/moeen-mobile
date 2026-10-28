import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

part 'lesson_picker_state.dart';

/// Four steps: pick a stage, then a grade, then a subject, then one of its
/// lessons. Each step filters the next from the curriculum tree.
class LessonPickerCubit extends Cubit<LessonPickerState> {
  static LessonPickerCubit get(BuildContext context) => BlocProvider.of(context);

  LessonPickerCubit(this._repo) : super(const LessonPickerState());

  final CurriculumLessonsRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: LessonPickerStatus.loading));
    final result = await _repo.getStages();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: LessonPickerStatus.failure, errorMessage: failure.message)),
      (stages) => emit(state.copyWith(status: LessonPickerStatus.success, stages: stages)),
    );
  }

  void search(String query) => emit(state.copyWith(query: query));

  /// Opens the stage's grades. Resets the search so the next list starts clean.
  void selectStage(CurriculumStageModel stage) =>
      emit(state.copyWith(stage: stage, clearGrade: true, clearSubject: true, query: ''));

  /// Opens the grade's subjects.
  void selectGrade(CurriculumGradeModel grade) =>
      emit(state.copyWith(grade: grade, clearSubject: true, query: ''));

  Future<void> openSubject(CurriculumSubjectModel subject) async {
    emit(state.copyWith(
      subject: subject,
      chapters: const [],
      lessonsStatus: LessonPickerStatus.loading,
      query: '',
    ));
    final result = await _repo.getChapters(subject.id);
    if (isClosed || !identical(state.subject, subject)) return;
    result.fold(
      (failure) => emit(state.copyWith(lessonsStatus: LessonPickerStatus.failure, errorMessage: failure.message)),
      (chapters) => emit(state.copyWith(lessonsStatus: LessonPickerStatus.success, chapters: chapters)),
    );
  }

  void backToStages() =>
      emit(state.copyWith(clearStage: true, clearGrade: true, clearSubject: true, query: ''));

  void backToGrades() => emit(state.copyWith(clearGrade: true, clearSubject: true, query: ''));

  void backToSubjects() => emit(state.copyWith(clearSubject: true, chapters: const [], query: ''));

  PickedLessonModel pick(CurriculumLessonModel lesson) {
    return PickedLessonModel(
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      subjectName: state.subject!.name,
      gradeName: state.grade!.name,
    );
  }
}
