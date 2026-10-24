import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';

class SubmissionReviewState {
  final SubmissionDetail? detail;

  /// The mark fields as typed, per question id ('' = waiting).
  final Map<int, String> marks;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool saved;
  final bool deleted;

  const SubmissionReviewState({
    this.detail,
    this.marks = const {},
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.saved = false,
    this.deleted = false,
  });

  SubmissionReviewState copyWith({
    SubmissionDetail? detail,
    Map<int, String>? marks,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool? saved,
    bool? deleted,
  }) =>
      SubmissionReviewState(
        detail: detail ?? this.detail,
        marks: marks ?? this.marks,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        saved: saved ?? this.saved,
        deleted: deleted ?? this.deleted,
      );
}

/// One student's answers. A mark still waiting is pre-filled with the AI suggestion; it counts only once saved.
class SubmissionReviewCubit extends Cubit<SubmissionReviewState> {
  final int testId;
  final int submissionId;
  final OnlineTestsRepository _repository;

  SubmissionReviewCubit({required this.testId, required this.submissionId, required OnlineTestsRepository repository})
      : _repository = repository,
        super(const SubmissionReviewState());

  static SubmissionReviewCubit get(BuildContext context) => BlocProvider.of(context);

  static Map<int, String> _fields(SubmissionDetail d) => {
        for (final a in d.answers)
          a.questionId: a.mark != null ? formatPoints(a.mark) : (a.aiMark != null ? formatPoints(a.aiMark) : ''),
      };

  Future<void> load() async {
    final result = await _repository.getSubmission(testId, submissionId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (detail) => emit(state.copyWith(isLoading: false, detail: detail, marks: _fields(detail))),
    );
  }

  void setMark(int questionId, String value) => emit(state.copyWith(marks: {...state.marks, questionId: value}));

  Future<void> save() async {
    final detail = state.detail;
    if (detail == null || state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true, saved: false));
    final payload = <int, double?>{
      for (final a in detail.answers)
        a.questionId: double.tryParse(_westernDigits(state.marks[a.questionId] ?? '')),
    };
    final result = await _repository.review(testId, submissionId, payload);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: failure.message)),
      (d) => emit(state.copyWith(isSaving: false, detail: d, marks: _fields(d), saved: true)),
    );
  }

  Future<void> delete() async {
    final result = await _repository.deleteSubmission(testId, submissionId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(deleted: true)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));

  /// «٢٫٥» → «2.5».
  static String _westernDigits(String text) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final ch in text.trim().split('')) {
      final i = arabic.indexOf(ch);
      buffer.write(i >= 0 ? '$i' : (ch == '٫' || ch == ',' ? '.' : ch));
    }
    return buffer.toString();
  }
}
