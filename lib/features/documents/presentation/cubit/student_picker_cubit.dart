import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/data/utils/student_names.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';

part 'student_picker_state.dart';

/// Picks the students for a plan: a «فصولي» class, whose names load all
/// ticked, or typed names.
class StudentPickerCubit extends Cubit<StudentPickerState> {
  static StudentPickerCubit get(BuildContext context) => BlocProvider.of(context);

  StudentPickerCubit(this._repo) : super(const StudentPickerState());

  final ClassesRepository _repo;

  final TextEditingController typedController = TextEditingController();

  /// Reopens where the form left off: the same class with the same ticks,
  /// or the typed names.
  Future<void> load({int? initialClassId, List<String> initialStudents = const []}) async {
    if (initialClassId == null && initialStudents.isNotEmpty) {
      typedController.text = initialStudents.join('\n');
      emit(state.copyWith(mode: StudentPickerMode.typed));
    }
    emit(state.copyWith(classesStatus: StudentPickerStatus.loading));
    final result = await _repo.getClasses();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(classesStatus: StudentPickerStatus.failure, errorMessage: failure.message)),
      (classes) => emit(state.copyWith(classesStatus: StudentPickerStatus.success, classes: classes)),
    );
    final initial = state.classes.where((c) => c.id == initialClassId).firstOrNull;
    if (initial != null) await openClass(initial, keep: initialStudents);
  }

  void setMode(StudentPickerMode mode) => emit(state.copyWith(mode: mode));

  /// Every name starts ticked, or only those in [keep] when reopening.
  Future<void> openClass(SchoolClassModel summary, {List<String> keep = const []}) async {
    final id = summary.id;
    if (id == null) return;
    emit(state.copyWith(selected: summary, classStatus: StudentPickerStatus.loading, checked: const []));
    final result = await _repo.getClass(id);
    if (isClosed || state.selected?.id != id) return;
    result.fold(
      (failure) => emit(state.copyWith(classStatus: StudentPickerStatus.failure, errorMessage: failure.message)),
      (schoolClass) => emit(state.copyWith(
        selected: schoolClass,
        classStatus: StudentPickerStatus.success,
        checked: [for (final name in schoolClass.students) keep.isEmpty || keep.contains(name)],
      )),
    );
  }

  void backToClasses() => emit(state.copyWith(clearSelected: true, checked: const []));

  void toggle(int index) => emit(state.copyWith(checked: [...state.checked]..[index] = !state.checked[index]));

  void setAll(bool checked) => emit(state.copyWith(checked: List.filled(state.checked.length, checked)));

  /// Null until there is something to return: a loaded class, or typed names.
  StudentPickerResult? result() {
    if (state.mode == StudentPickerMode.typed) {
      final names = splitStudentNames(typedController.text).take(ClassLimits.maxStudents).toList();
      return names.isEmpty ? null : StudentPickerResult(students: names);
    }
    final schoolClass = state.selected;
    if (schoolClass == null || state.classStatus != StudentPickerStatus.success) return null;
    return StudentPickerResult(
      classId: schoolClass.id,
      className: schoolClass.name,
      grade: schoolClass.grade,
      subject: schoolClass.subject,
      students: [
        for (var i = 0; i < schoolClass.students.length; i++)
          if (state.checked[i]) schoolClass.students[i],
      ],
    );
  }

  @override
  Future<void> close() {
    typedController.dispose();
    return super.close();
  }
}
