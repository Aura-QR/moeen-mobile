import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/repositories/grade_analysis_repository.dart';

part 'grade_results_state.dart';

/// «النتائج»: the live numbers for the form, from `POST /tools/grades/analyze`,
/// asked a moment after the teacher stops typing. Nothing is saved.
class GradeResultsCubit extends Cubit<GradeResultsState> {
  static GradeResultsCubit get(BuildContext context) => BlocProvider.of(context);

  GradeResultsCubit(this._repo, {Duration debounce = const Duration(milliseconds: 600)})
    : _debounce = debounce,
      super(const GradeResultsState());

  final GradeAnalysisRepository _repo;
  final Duration _debounce;
  Timer? _timer;

  /// Only the latest answer may land; earlier ones are for an older form.
  int _request = 0;

  /// Analyses [input] once the form has been still for the debounce time.
  void schedule(Map<String, dynamic> input) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => analyze(input));
  }

  /// The form isn't ready ([issue] says why); pending answers are dropped.
  void wait(String issue) {
    _timer?.cancel();
    _request++;
    emit(GradeResultsState(issue: issue));
  }

  Future<void> analyze(Map<String, dynamic> input) async {
    _timer?.cancel();
    final request = ++_request;
    emit(GradeResultsState(status: GradeResultsStatus.loading, result: state.result));
    final result = await _repo.analyze(input);
    if (isClosed || request != _request) return;
    result.fold(
      // A 422 explains which grade is wrong, e.g. «الدرجة أكبر من الدرجة الكلية».
      (failure) => emit(GradeResultsState(status: GradeResultsStatus.failure, errorMessage: failure.message)),
      (analysis) => emit(GradeResultsState(status: GradeResultsStatus.success, result: analysis)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
