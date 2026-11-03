part of 'lesson_experiments_chip_cubit.dart';

@immutable
class LessonExperimentsChipState {
  final int? lessonId;
  final int count;
  final bool isLoading;

  const LessonExperimentsChipState({
    this.lessonId,
    this.count = 0,
    this.isLoading = false,
  });
}
