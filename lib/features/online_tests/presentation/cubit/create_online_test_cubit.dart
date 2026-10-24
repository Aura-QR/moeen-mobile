import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';

class CreateOnlineTestState {
  static const int maxGroups = 10;
  static const int maxFields = 3;

  final List<SchoolClassModel> classes;
  final List<({String name, int? classId})> groups;
  final bool showScore;
  final bool shuffleQuestions;
  final bool shuffleOptions;
  final int? timeLimitMinutes;
  final List<String> studentFields;
  final bool isSaving;
  final String? error;

  /// Set once the test is created; the screen opens it.
  final int? createdId;

  const CreateOnlineTestState({
    this.classes = const [],
    this.groups = const [],
    this.showScore = true,
    this.shuffleQuestions = false,
    this.shuffleOptions = false,
    this.timeLimitMinutes,
    this.studentFields = const [],
    this.isSaving = false,
    this.error,
    this.createdId,
  });

  CreateOnlineTestState copyWith({
    List<SchoolClassModel>? classes,
    List<({String name, int? classId})>? groups,
    bool? showScore,
    bool? shuffleQuestions,
    bool? shuffleOptions,
    int? timeLimitMinutes,
    bool clearTimeLimit = false,
    List<String>? studentFields,
    bool? isSaving,
    String? error,
    bool clearError = false,
    int? createdId,
  }) =>
      CreateOnlineTestState(
        classes: classes ?? this.classes,
        groups: groups ?? this.groups,
        showScore: showScore ?? this.showScore,
        shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
        shuffleOptions: shuffleOptions ?? this.shuffleOptions,
        timeLimitMinutes: clearTimeLimit ? null : timeLimitMinutes ?? this.timeLimitMinutes,
        studentFields: studentFields ?? this.studentFields,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        createdId: createdId ?? this.createdId,
      );
}

/// «شارك إلكترونيًا»: one link per class for an exam from the exam generator.
class CreateOnlineTestCubit extends Cubit<CreateOnlineTestState> {
  final int examId;
  final OnlineTestsRepository _repository;
  final ClassesRepository _classes;

  CreateOnlineTestCubit({required this.examId, required OnlineTestsRepository repository, required ClassesRepository classes})
      : _repository = repository,
        _classes = classes,
        super(const CreateOnlineTestState());

  static CreateOnlineTestCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> loadClasses() async {
    final result = await _classes.getClasses();
    if (isClosed) return;
    result.fold((_) {}, (classes) => emit(state.copyWith(classes: classes)));
  }

  void addGroup(String name, {int? classId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.groups.length >= CreateOnlineTestState.maxGroups) return;
    if (classId != null && state.groups.any((g) => g.classId == classId)) return;
    emit(state.copyWith(groups: [...state.groups, (name: trimmed, classId: classId)]));
  }

  void removeGroup(int index) => emit(state.copyWith(groups: [...state.groups]..removeAt(index)));

  void setShowScore(bool v) => emit(state.copyWith(showScore: v));
  void setShuffleQuestions(bool v) => emit(state.copyWith(shuffleQuestions: v));
  void setShuffleOptions(bool v) => emit(state.copyWith(shuffleOptions: v));

  void setTimeLimit(String text) {
    final minutes = int.tryParse(text.trim());
    emit(minutes == null || minutes <= 0 ? state.copyWith(clearTimeLimit: true) : state.copyWith(timeLimitMinutes: minutes.clamp(1, 240)));
  }

  void addField(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty || state.studentFields.length >= CreateOnlineTestState.maxFields) return;
    emit(state.copyWith(studentFields: [...state.studentFields, trimmed]));
  }

  void removeField(int index) => emit(state.copyWith(studentFields: [...state.studentFields]..removeAt(index)));

  Future<void> submit(String title) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = await _repository.create(NewOnlineTest(
      examId: examId,
      title: title,
      groups: state.groups.isEmpty ? [(name: 'الفصل 1', classId: null)] : state.groups,
      showScore: state.showScore,
      shuffleQuestions: state.shuffleQuestions,
      shuffleOptions: state.shuffleOptions,
      timeLimitMinutes: state.timeLimitMinutes,
      studentFields: state.studentFields,
    ));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: failure.message)),
      (test) => emit(state.copyWith(isSaving: false, createdId: test.id)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
