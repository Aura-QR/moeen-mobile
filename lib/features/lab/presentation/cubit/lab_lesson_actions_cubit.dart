import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/utils/constants/constants.dart';
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
        // ignore: prefer_const_constructors
        feedback: UiFeedback('lab_request_empty_error', isError: true),
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
          // ignore: prefer_const_constructors
          feedback: UiFeedback('lab_request_success', isError: false),
        ));
        return true;
      },
    );
  }

  String _tr(String key, String fallback) {
    try {
      final val = appTranslation().get(key);
      if (val != key && val.isNotEmpty) return val;
    } catch (_) {}
    return fallback;
  }

  /// Returns all human-readable reasons why [input] cannot be submitted.
  List<String> validateCreateExperiment(LabCreateExperimentInput input) {
    final errors = <String>[];

    if (input.name.trim().isEmpty) {
      errors.add(_tr('lab_create_err_name_empty', '• يرجى إدخال عنوان التجربة'));
    }

    if (input.variables.isEmpty) {
      errors.add(_tr('lab_create_err_no_variables', '• يجب إضافة متغير واحد على الأقل'));
    } else {
      for (final v in input.variables) {
        if (v.label.trim().isEmpty) {
          errors.add(
            _tr('lab_create_err_var_label_empty', '• يرجى إدخال اسم المتغير ({symbol})')
                .replaceAll('{symbol}', v.symbol),
          );
        }
        if (v.min >= v.max) {
          errors.add(
            _tr(
              'lab_create_err_var_minmax',
              '• في المتغير ({symbol}): القيمة الأدنى ({min}) يجب أن تكون أصغر من القيمة الأعلى ({max})',
            )
                .replaceAll('{symbol}', v.symbol)
                .replaceAll('{min}', '${v.min}')
                .replaceAll('{max}', '${v.max}'),
          );
        }
      }
    }

    final allowedSymbols = input.variables.map((v) => v.symbol).toSet();
    if (input.readings.isEmpty) {
      errors.add(_tr('lab_create_err_no_readings', '• يجب إضافة قراءة واحدة على الأقل'));
    } else {
      for (var i = 0; i < input.readings.length; i++) {
        final r = input.readings[i];
        final idx = '${i + 1}';
        if (r.label.trim().isEmpty) {
          errors.add(
            _tr('lab_create_err_reading_label_empty', '• يرجى إدخال اسم القراءة ({index})')
                .replaceAll('{index}', idx),
          );
        }
        final formula = r.normalizedFormula;
        if (formula.isEmpty) {
          errors.add(
            _tr('lab_create_err_formula_empty', '• يرجى إدخال المعادلة في القراءة ({index})')
                .replaceAll('{index}', idx),
          );
        } else {
          final formulaErr = _describeFormulaError(formula, allowedSymbols, idx);
          if (formulaErr != null) {
            errors.add(formulaErr);
          }
        }
      }
    }
    return errors;
  }

  Future<LabExperimentModel?> submitCreateExperiment(
    LabCreateExperimentInput input,
  ) async {
    final detailedErrors = validateCreateExperiment(input);

    if (input.name.trim().isEmpty ||
        input.variables.isEmpty ||
        input.readings.isEmpty ||
        input.variables.any((v) => v.label.trim().isEmpty) ||
        input.readings.any(
          (r) => r.label.trim().isEmpty || r.normalizedFormula.isEmpty,
        )) {
      emit(state.copyWith(
        // ignore: prefer_const_constructors
        feedback: UiFeedback('lab_create_invalid_error', isError: true),
        validationErrors: detailedErrors,
      ));
      return null;
    }

    if (input.variables.any((v) => v.min >= v.max)) {
      emit(state.copyWith(
        // ignore: prefer_const_constructors
        feedback: UiFeedback('lab_create_minmax_error', isError: true),
        validationErrors: detailedErrors,
      ));
      return null;
    }

    if (detailedErrors.isNotEmpty) {
      emit(state.copyWith(
        // ignore: prefer_const_constructors
        feedback: UiFeedback('lab_create_formula_error', isError: true),
        validationErrors: detailedErrors,
      ));
      return null;
    }

    emit(state.copyWith(isSubmitting: true, validationErrors: const []));
    final result = await _labRepository.createExperiment(input);
    if (isClosed) return null;

    return result.fold(
      (failure) {
        final rawMsg = (failure is UnauthorizedFailure && failure.message == 'generic_error')
            ? _tr('lab_create_err_login_required', 'يرجى تسجيل الدخول أولاً لإنشاء تجربة')
            : _tr(failure.message, failure.message);
        final serverErrors = rawMsg
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        emit(state.copyWith(
          isSubmitting: false,
          feedback: UiFeedback(failure.message, isError: true),
          validationErrors: serverErrors,
        ));
        return null;
      },
      (experiment) {
        emit(state.copyWith(
          isSubmitting: false,
          createdExperiment: experiment,
          validationErrors: const [],
          // ignore: prefer_const_constructors
          feedback: UiFeedback('lab_create_success', isError: false),
        ));
        return experiment;
      },
    );
  }

  static const Set<String> _allowedMathIdentifiers = {
    'sin', 'cos', 'tan', 'sqrt', 'abs', 'log', 'ln', 'exp',
    'min', 'max', 'pow', 'pi', 'e', 'round', 'floor', 'ceil',
  };

  String? _describeFormulaError(
    String formula,
    Set<String> allowedSymbols,
    String indexStr,
  ) {
    if (formula.length > 300) {
      return _tr(
        'lab_create_err_formula_too_long',
        '• المعادلة في القراءة ({index}) تتجاوز الحد الأقصى (300 حرف)',
      ).replaceAll('{index}', indexStr);
    }
    final allowedChars = RegExp(r'^[0-9a-zA-Z_+\-*/^().,\s]+$');
    if (!allowedChars.hasMatch(formula)) {
      return _tr(
        'lab_create_err_formula_chars',
        '• المعادلة في القراءة ({index}) تحتوي على حروف أو رموز غير مدعومة (استخدم الرموز {symbols} والعمليات + - * / ^ فقط بدون علامة =)',
      )
          .replaceAll('{index}', indexStr)
          .replaceAll('{symbols}', allowedSymbols.join(', '));
    }

    var depth = 0;
    for (final code in formula.codeUnits) {
      if (code == 40) depth++;
      if (code == 41) {
        depth--;
        if (depth < 0) break;
      }
    }
    if (depth != 0 || formula.contains('()')) {
      return _tr(
        'lab_create_err_formula_parens',
        '• المعادلة في القراءة ({index}) تحتوي على أقواس غير مكتملة الإغلاق ()',
      ).replaceAll('{index}', indexStr);
    }

    final unknownIds = <String>[];
    for (final m in RegExp(r'[a-zA-Z_][a-zA-Z0-9_]*').allMatches(formula)) {
      final id = m.group(0)!;
      if (!allowedSymbols.contains(id) &&
          !_allowedMathIdentifiers.contains(id.toLowerCase())) {
        if (!unknownIds.contains(id)) unknownIds.add(id);
      }
    }
    if (unknownIds.isNotEmpty) {
      return _tr(
        'lab_create_err_formula_unknown_symbol',
        '• في القراءة ({index}): الرمز ({unknown}) غير معرّف — الرموز المتاحة هي ({symbols})',
      )
          .replaceAll('{index}', indexStr)
          .replaceAll('{unknown}', unknownIds.join(', '))
          .replaceAll('{symbols}', allowedSymbols.join(', '));
    }

    if (RegExp(r'(^[*/^])|([+\-*/^]$)').hasMatch(formula.trim())) {
      return _tr(
        'lab_create_err_formula_incomplete',
        '• المعادلة في القراءة ({index}) غير مكتملة رياضياً',
      ).replaceAll('{index}', indexStr);
    }
    return null;
  }
}
