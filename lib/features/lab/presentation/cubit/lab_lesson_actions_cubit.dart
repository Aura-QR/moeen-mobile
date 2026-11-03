import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';

part 'lab_lesson_actions_state.dart';

/// Cubit for «اطلب تجربة» (`POST /lab/requests`) and «أنشئ تجربتك» (`POST /lab/experiments`).
class LabLessonActionsCubit extends Cubit<LabLessonActionsState> {
  static LabLessonActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  LabLessonActionsCubit({required LabRepository labRepository})
      : _labRepository = labRepository,
        super(const LabLessonActionsState());

  final LabRepository _labRepository;

  void selectDisplayMode(String mode) {
    if (mode == state.displayMode) return;
    emit(state.copyWith(displayMode: mode));
  }

  void setVariablesCount(int count) {
    final clamped = count.clamp(1, 5);
    if (clamped == state.variablesCount) return;
    emit(state.copyWith(variablesCount: clamped));
  }

  void setReadingsCount(int count) {
    final clamped = count.clamp(1, 4);
    if (clamped == state.readingsCount) return;
    emit(state.copyWith(readingsCount: clamped));
  }

  Future<bool> submitRequest({
    int? lessonId,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(
        feedback: const UiFeedback('lab_request_empty_error', isError: true),
      ));
      return false;
    }

    emit(state.copyWith(isSubmitting: true));
    final result = await _labRepository.requestExperiment(
      lessonId: lessonId,
      message: trimmed,
    );
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          feedback: UiFeedback(failure.message, isError: true),
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isSubmitting: false,
          feedback: const UiFeedback('lab_request_success', isError: false),
        ));
        return true;
      },
    );
  }

  Future<LabExperimentModel?> submitCreateExperiment(
    LabCreateExperimentInput input,
  ) async {
    if (input.name.trim().isEmpty ||
        input.variables.isEmpty ||
        input.readings.isEmpty ||
        input.variables.any((v) => v.label.trim().isEmpty) ||
        input.readings.any(
          (r) => r.label.trim().isEmpty || r.normalizedFormula.isEmpty,
        )) {
      emit(state.copyWith(
        feedback: const UiFeedback('lab_create_invalid_error', isError: true),
      ));
      return null;
    }

    if (input.variables.any((v) => v.min >= v.max)) {
      emit(state.copyWith(
        feedback: const UiFeedback('lab_create_minmax_error', isError: true),
      ));
      return null;
    }

    final allowedSymbols = input.variables.map((v) => v.symbol).toSet();
    final hasInvalidFormula = input.readings.any(
      (r) => !_isValidFormula(r.normalizedFormula, allowedSymbols),
    );
    if (hasInvalidFormula) {
      emit(state.copyWith(
        feedback: const UiFeedback('lab_create_formula_error', isError: true),
      ));
      return null;
    }

    emit(state.copyWith(isSubmitting: true));
    final result = await _labRepository.createExperiment(input);
    if (isClosed) return null;

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          feedback: UiFeedback(failure.message, isError: true),
        ));
        return null;
      },
      (experiment) {
        emit(state.copyWith(
          isSubmitting: false,
          createdExperiment: experiment,
          feedback: const UiFeedback('lab_create_success', isError: false),
        ));
        return experiment;
      },
    );
  }

  static const Set<String> _allowedMathIdentifiers = {
    'sin',
    'cos',
    'tan',
    'sqrt',
    'abs',
    'log',
    'ln',
    'exp',
    'min',
    'max',
    'pow',
    'pi',
    'e',
    'round',
    'floor',
    'ceil',
  };

  bool _isValidFormula(String formula, Set<String> allowedSymbols) {
    if (formula.isEmpty) return false;
    final allowedChars = RegExp(r'^[0-9a-zA-Z_+\-*/^().,\s]+$');
    if (!allowedChars.hasMatch(formula)) return false;

    final identifiers = RegExp(r'[a-zA-Z_][a-zA-Z0-9_]*')
        .allMatches(formula)
        .map((m) => m.group(0)!);
    for (final id in identifiers) {
      if (!allowedSymbols.contains(id) &&
          !_allowedMathIdentifiers.contains(id.toLowerCase())) {
        return false;
      }
    }
    return true;
  }
}
