import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/data/utils/student_names.dart';

part 'class_editor_state.dart';

/// One class: its details and the student list, saved as a whole.
class ClassEditorCubit extends Cubit<ClassEditorState> {
  static ClassEditorCubit get(BuildContext context) => BlocProvider.of(context);

  ClassEditorCubit({
    int? classId,
    required ClassesRepository repository,
    required DeviceFilePicker filePicker,
  })  : _repo = repository,
        _picker = filePicker,
        super(ClassEditorState(
          classId: classId,
          status: classId == null ? ClassEditorStatus.success : ClassEditorStatus.loading,
        ));

  final ClassesRepository _repo;
  final DeviceFilePicker _picker;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  /// Loads the class when editing one; a new class has nothing to load.
  Future<void> load() async {
    final id = state.classId;
    if (id == null) return;
    emit(state.copyWith(status: ClassEditorStatus.loading));
    final result = await _repo.getClass(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: ClassEditorStatus.failure, errorMessage: failure.message)),
      (schoolClass) {
        nameController.text = schoolClass.name;
        gradeController.text = schoolClass.grade;
        subjectController.text = schoolClass.subject;
        emit(state.copyWith(status: ClassEditorStatus.success, students: schoolClass.students));
      },
    );
  }

  /// «إضافة أسماء»: one name per line, split on the device.
  void addNames(String text) => appendNames(splitStudentNames(text));

  /// Appends up to the 80-name limit; names over it are dropped with a message.
  void appendNames(List<String> names) {
    final cleaned = names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .map(_clip)
        .toList();
    if (cleaned.isEmpty) return;
    final room = ClassLimits.maxStudents - state.students.length;
    emit(state.copyWith(
      students: [...state.students, ...cleaned.take(room)],
      feedback: cleaned.length > room ? const UiFeedback('class_students_limit') : null,
    ));
  }

  /// Clearing a name removes it.
  void editStudent(int index, String name) {
    final value = name.trim();
    if (value.isEmpty) {
      removeStudent(index);
      return;
    }
    emit(state.copyWith(students: [...state.students]..[index] = _clip(value)));
  }

  void removeStudent(int index) => emit(state.copyWith(students: [...state.students]..removeAt(index)));

  /// [newIndex] is the final position, after removing the moved name.
  void reorderStudent(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final students = [...state.students];
    students.insert(newIndex, students.removeAt(oldIndex));
    emit(state.copyWith(students: students));
  }

  /// «استيراد من Excel»: the names come back in [ClassEditorState.importedNames]
  /// for review; [appendNames] adds them once the teacher confirms.
  Future<void> importFromFile() async {
    if (state.isImporting) return;
    final file = await _picker.pickSpreadsheet();
    if (file == null || isClosed) return;
    if (file.byteSize > ClassLimits.maxImportBytes) {
      emit(state.copyWith(feedback: const UiFeedback('class_import_too_large')));
      return;
    }

    emit(state.copyWith(isImporting: true));
    final result = await _repo.importNames(file);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isImporting: false, feedback: UiFeedback(failure.message))),
      (names) => emit(names.isEmpty
          ? state.copyWith(isImporting: false, feedback: const UiFeedback('class_import_empty'))
          : state.copyWith(isImporting: false, importedNames: names)),
    );
  }

  /// `POST` for a new class, `PUT` otherwise; either sends the whole list.
  Future<void> save() async {
    if (state.isSaving) return;
    final name = nameController.text.trim();
    if (name.isEmpty) {
      emit(state.copyWith(feedback: const UiFeedback('class_name_required')));
      return;
    }

    emit(state.copyWith(isSaving: true));
    final schoolClass = SchoolClassModel(
      name: name,
      grade: gradeController.text.trim(),
      subject: subjectController.text.trim(),
      students: state.students,
    );
    final id = state.classId;
    final result = id == null ? await _repo.createClass(schoolClass) : await _repo.updateClass(id, schoolClass);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: UiFeedback(failure.message))),
      (saved) => emit(state.copyWith(isSaving: false, classId: saved.id, isSaved: true)),
    );
  }

  static String _clip(String name) => name.length > ClassLimits.maxStudentNameLength
      ? name.substring(0, ClassLimits.maxStudentNameLength)
      : name;

  @override
  Future<void> close() {
    nameController.dispose();
    gradeController.dispose();
    subjectController.dispose();
    return super.close();
  }
}
