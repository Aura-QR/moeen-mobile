import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';

class LearningStyleSurveyState {
  final LearningStyleSurvey? survey;
  final LearningStylesResults? results;
  final bool isLoading;
  final bool isBusy;

  /// A one-off message (translation key or API text) for a snack bar.
  final String? message;
  final bool messageIsError;
  final String? loadError;

  /// One-off signals the screen reacts to.
  final int? reportDocumentId;
  final bool deleted;

  const LearningStyleSurveyState({
    this.survey,
    this.results,
    this.isLoading = true,
    this.isBusy = false,
    this.message,
    this.messageIsError = false,
    this.loadError,
    this.reportDocumentId,
    this.deleted = false,
  });

  LearningStyleSurveyState copyWith({
    LearningStyleSurvey? survey,
    LearningStylesResults? results,
    bool? isLoading,
    bool? isBusy,
    String? message,
    bool messageIsError = false,
    bool clearMessage = false,
    String? loadError,
    int? reportDocumentId,
    bool clearReport = false,
    bool? deleted,
  }) =>
      LearningStyleSurveyState(
        survey: survey ?? this.survey,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        isBusy: isBusy ?? this.isBusy,
        message: clearMessage ? null : message ?? this.message,
        messageIsError: message != null ? messageIsError : this.messageIsError,
        loadError: loadError,
        reportDocumentId: clearReport ? null : reportDocumentId ?? this.reportDocumentId,
        deleted: deleted ?? this.deleted,
      );
}

/// One survey: the links and QR per class, the results, and the report.
class LearningStyleSurveyCubit extends Cubit<LearningStyleSurveyState> {
  final int surveyId;
  final LearningStylesRepository _repository;

  LearningStyleSurveyCubit({required this.surveyId, required LearningStylesRepository repository})
      : _repository = repository,
        super(const LearningStyleSurveyState());

  static LearningStyleSurveyCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    final result = await _repository.getSurvey(surveyId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, loadError: failure.message)),
      (survey) => emit(state.copyWith(isLoading: false, survey: survey)),
    );
    await refreshResults();
  }

  Future<void> refreshResults() async {
    final result = await _repository.getResults(surveyId);
    if (isClosed) return;
    result.fold((_) {}, (results) => emit(state.copyWith(results: results)));
  }

  Future<void> toggleOpen() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final result = await _repository.setOpen(surveyId, !(state.survey?.isOpen ?? true));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message, messageIsError: true)),
      (survey) => emit(state.copyWith(isBusy: false, survey: survey)),
    );
  }

  Future<void> delete() async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final result = await _repository.delete(surveyId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message, messageIsError: true)),
      (_) => emit(state.copyWith(isBusy: false, deleted: true)),
    );
  }

  Future<void> deleteResponse(int responseId) async {
    final result = await _repository.deleteResponse(surveyId, responseId);
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(state.copyWith(message: failure.message, messageIsError: true)),
      (_) async {
        await refreshResults();
        if (!isClosed) emit(state.copyWith(message: 'learning_styles_response_deleted'));
      },
    );
  }

  /// Saves/refreshes the report document; the screen opens its export sheet.
  Future<void> saveReport() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final result = await _repository.saveReport(surveyId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message, messageIsError: true)),
      (document) => emit(state.copyWith(isBusy: false, reportDocumentId: document.id)),
    );
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));
  void clearReport() => emit(state.copyWith(clearReport: true));
}
