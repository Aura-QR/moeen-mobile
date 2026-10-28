import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';

class LearningStylesListState {
  final List<LearningStyleSurvey> surveys;
  final bool isLoading;
  final String? error;

  const LearningStylesListState({this.surveys = const [], this.isLoading = true, this.error});
}

/// «استباناتي» — the teacher's learning-style surveys.
class LearningStylesListCubit extends Cubit<LearningStylesListState> {
  final LearningStylesRepository _repository;

  LearningStylesListCubit(this._repository) : super(const LearningStylesListState());

  static LearningStylesListCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    emit(LearningStylesListState(surveys: state.surveys));
    final result = await _repository.getSurveys();
    if (isClosed) return;
    result.fold(
      (failure) => emit(LearningStylesListState(surveys: state.surveys, isLoading: false, error: failure.message)),
      (surveys) => emit(LearningStylesListState(surveys: surveys, isLoading: false)),
    );
  }
}
