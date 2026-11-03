import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';

part 'lab_experiment_state.dart';

/// L8 «معمل حضر الافتراضي»: Experiment WebView, details, and reporting cubit.
class LabExperimentCubit extends Cubit<LabExperimentState> {
  static LabExperimentCubit get(BuildContext context) =>
      BlocProvider.of(context);

  LabExperimentCubit({
    required LabRepository labRepository,
    required String experimentKey,
  })  : _labRepository = labRepository,
        _experimentKey = experimentKey,
        super(const LabExperimentState());

  final LabRepository _labRepository;
  final String _experimentKey;

  Future<void> loadDetails() async {
    final key = _experimentKey.trim();
    if (key.isEmpty) return;

    emit(state.copyWith(isLoadingDetails: true));
    final result = await _labRepository.getExperimentDetails(key);
    if (isClosed) return;

    result.fold(
      (_) => emit(state.copyWith(isLoadingDetails: false)),
      (experiment) => emit(
        state.copyWith(
          experiment: experiment,
          isLoadingDetails: false,
        ),
      ),
    );
  }

  void onWebViewStarted() {
    emit(state.copyWith(webViewStatus: LabWebViewStatus.loading));
  }

  void onWebViewReady() {
    emit(state.copyWith(webViewStatus: LabWebViewStatus.ready));
  }

  void onWebViewError() {
    emit(state.copyWith(webViewStatus: LabWebViewStatus.error));
  }

  void retryLoad() {
    emit(state.copyWith(webViewStatus: LabWebViewStatus.loading));
  }

  Future<bool> reportMistake(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(
        feedback: const UiFeedback('lab_report_empty_error', isError: true),
      ));
      return false;
    }

    emit(state.copyWith(isReporting: true, reportSuccess: false));
    final result = await _labRepository.reportMistake(_experimentKey, trimmed);
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isReporting: false,
          reportSuccess: false,
          reportError: failure.message,
          feedback: UiFeedback(failure.message, isError: true),
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isReporting: false,
          reportSuccess: true,
          feedback: const UiFeedback('lab_report_success', isError: false),
        ));
        return true;
      },
    );
  }
}
