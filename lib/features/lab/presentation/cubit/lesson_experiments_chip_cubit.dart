import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';

part 'lesson_experiments_chip_state.dart';

/// Cubit that checks `GET /lessons/{id}/experiments` and exposes the count
/// for [LessonExperimentsLoaderChip].
class LessonExperimentsChipCubit extends Cubit<LessonExperimentsChipState> {
  static LessonExperimentsChipCubit get(BuildContext context) =>
      BlocProvider.of(context);

  LessonExperimentsChipCubit({required LabRepository labRepository})
      : _labRepository = labRepository,
        super(const LessonExperimentsChipState());

  final LabRepository _labRepository;

  Future<void> loadForLesson(int? lessonId) async {
    if (lessonId == null || lessonId <= 0) {
      emit(LessonExperimentsChipState(lessonId: lessonId));
      return;
    }
    if (state.lessonId == lessonId && (state.isLoading || state.count > 0)) {
      return;
    }

    emit(LessonExperimentsChipState(lessonId: lessonId, isLoading: true));
    final result = await _labRepository.getLessonExperiments(lessonId);
    if (isClosed || state.lessonId != lessonId) return;

    result.fold(
      (_) => emit(LessonExperimentsChipState(lessonId: lessonId)),
      (items) => emit(
        LessonExperimentsChipState(
          lessonId: lessonId,
          count: items.length,
        ),
      ),
    );
  }
}
