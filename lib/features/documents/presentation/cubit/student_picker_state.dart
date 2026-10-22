part of 'student_picker_cubit.dart';

enum StudentPickerMode { fromClass, typed }

enum StudentPickerStatus { loading, success, failure }

class StudentPickerState {
  final StudentPickerMode mode;
  final StudentPickerStatus classesStatus;
  final List<SchoolClassModel> classes;

  /// The open class; null on the classes step.
  final SchoolClassModel? selected;
  final StudentPickerStatus classStatus;

  /// One tick per name of [selected], in order.
  final List<bool> checked;
  final String? errorMessage;

  const StudentPickerState({
    this.mode = StudentPickerMode.fromClass,
    this.classesStatus = StudentPickerStatus.loading,
    this.classes = const [],
    this.selected,
    this.classStatus = StudentPickerStatus.loading,
    this.checked = const [],
    this.errorMessage,
  });

  int get checkedCount => checked.where((isChecked) => isChecked).length;

  StudentPickerState copyWith({
    StudentPickerMode? mode,
    StudentPickerStatus? classesStatus,
    List<SchoolClassModel>? classes,
    SchoolClassModel? selected,
    bool clearSelected = false,
    StudentPickerStatus? classStatus,
    List<bool>? checked,
    String? errorMessage,
  }) {
    return StudentPickerState(
      mode: mode ?? this.mode,
      classesStatus: classesStatus ?? this.classesStatus,
      classes: classes ?? this.classes,
      selected: clearSelected ? null : (selected ?? this.selected),
      classStatus: classStatus ?? this.classStatus,
      checked: checked ?? this.checked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
