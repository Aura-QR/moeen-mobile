import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

part 'lesson_picker_state.dart';

/// Two steps: pick a subject, then one of its lessons.
class LessonPickerCubit extends Cubit<LessonPickerState> {
  static LessonPickerCubit get(BuildContext context) => BlocProvider.of(context);

  LessonPickerCubit(this._repo) : super(const LessonPickerState());

  final CurriculumLessonsRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: LessonPickerStatus.loading));
    final result = await _repo.getSubjects();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: LessonPickerStatus.failure, errorMessage: failure.message)),
      (subjects) => emit(state.copyWith(status: LessonPickerStatus.success, subjects: subjects)),
    );
  }

  void search(String query) => emit(state.copyWith(query: query));

  Future<void> openSubject(LessonPickerSubjectModel subject) async {
    emit(state.copyWith(
      subject: subject,
      chapters: const [],
      lessonsStatus: LessonPickerStatus.loading,
    ));
    final result = await _repo.getChapters(subject.subjectId);
    if (isClosed || state.subject != subject) return;
    result.fold(
      (failure) => emit(state.copyWith(lessonsStatus: LessonPickerStatus.failure, errorMessage: failure.message)),
      (chapters) => emit(state.copyWith(lessonsStatus: LessonPickerStatus.success, chapters: chapters)),
    );
  }

  void backToSubjects() => emit(state.copyWith(clearSubject: true, chapters: const []));

  PickedLessonModel pick(CurriculumLessonModel lesson) {
    final subject = state.subject!;
    return PickedLessonModel(
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      subjectName: subject.subjectName,
      gradeName: subject.gradeName,
    );
  }
}
