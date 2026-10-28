import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';

class NewLearningStyleState {
  final LearningStylesOptions? options;
  final List<SchoolClassModel> classes;
  final String version;
  final List<({String name, int? classId})> groups;
  final bool isSaving;
  final String? error;

  /// Set once the survey is created; the screen opens it.
  final int? createdId;

  const NewLearningStyleState({
    this.options,
    this.classes = const [],
    this.version = LearningStyleVersions.standard,
    this.groups = const [],
    this.isSaving = false,
    this.error,
    this.createdId,
  });

  int get maxGroups => options?.groupsLimit ?? LearningStylesLimits.maxGroups;
  bool get canStart => groups.isNotEmpty;

  NewLearningStyleState copyWith({
    LearningStylesOptions? options,
    List<SchoolClassModel>? classes,
    String? version,
    List<({String name, int? classId})>? groups,
    bool? isSaving,
    String? error,
    bool clearError = false,
    int? createdId,
  }) =>
      NewLearningStyleState(
        options: options ?? this.options,
        classes: classes ?? this.classes,
        version: version ?? this.version,
        groups: groups ?? this.groups,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        createdId: createdId ?? this.createdId,
      );
}

/// «استبانة جديدة»: the title, version, and one class link per group.
class NewLearningStyleCubit extends Cubit<NewLearningStyleState> {
  final LearningStylesRepository _repository;
  final ClassesRepository _classes;

  NewLearningStyleCubit({required LearningStylesRepository repository, required ClassesRepository classes})
      : _repository = repository,
        _classes = classes,
        super(const NewLearningStyleState());

  static NewLearningStyleCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> loadOptions() async {
    final result = await _repository.getOptions();
    if (isClosed) return;
    result.fold((_) {}, (options) => emit(state.copyWith(options: options)));
  }

  Future<void> loadClasses() async {
    final result = await _classes.getClasses();
    if (isClosed) return;
    result.fold((_) {}, (classes) => emit(state.copyWith(classes: classes)));
  }

  void setVersion(String version) => emit(state.copyWith(version: version));

  void addGroup(String name, {int? classId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.groups.length >= state.maxGroups) return;
    if (classId != null && state.groups.any((g) => g.classId == classId)) return;
    emit(state.copyWith(groups: [...state.groups, (name: trimmed, classId: classId)]));
  }

  void removeGroup(int index) => emit(state.copyWith(groups: [...state.groups]..removeAt(index)));

  Future<void> submit(String title) async {
    if (state.isSaving || state.groups.isEmpty) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = await _repository.create(NewLearningStyleSurvey(
      title: title.trim(),
      version: state.version,
      groups: state.groups,
    ));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: failure.message)),
      (survey) => emit(state.copyWith(isSaving: false, createdId: survey.id)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
