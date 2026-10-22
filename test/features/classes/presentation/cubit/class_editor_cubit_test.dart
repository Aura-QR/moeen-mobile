import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/presentation/cubit/class_editor_cubit.dart';

class MockClassesRepository extends Mock implements ClassesRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

DevicePickedFile _sheet(int bytes) => DevicePickedFile(bytes: Uint8List(bytes), name: 'class.xlsx', mime: null);

void main() {
  late MockClassesRepository repo;
  late MockDeviceFilePicker picker;

  ClassEditorCubit build({int? classId}) =>
      ClassEditorCubit(classId: classId, repository: repo, filePicker: picker);

  setUpAll(() {
    registerFallbackValue(const SchoolClassModel(name: ''));
    registerFallbackValue(_sheet(0));
  });

  setUp(() {
    repo = MockClassesRepository();
    picker = MockDeviceFilePicker();
  });

  test('a new class needs no loading', () async {
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, ClassEditorStatus.success);
    verifyNever(() => repo.getClass(any()));
    await cubit.close();
  });

  test('editing loads the class into the form', () async {
    when(() => repo.getClass(3)).thenAnswer(
      (_) async => const Right(SchoolClassModel(id: 3, name: 'خامس 1', grade: 'الخامس', students: ['سارة'])),
    );
    final cubit = build(classId: 3);
    await cubit.load();

    expect(cubit.nameController.text, 'خامس 1');
    expect(cubit.gradeController.text, 'الخامس');
    expect(cubit.state.students, ['سارة']);
    await cubit.close();
  });

  test('pasted names are split on the device and appended', () async {
    final cubit = build();
    cubit.addNames('1. أحمد\n\nسارة ');
    cubit.addNames('خالد');

    expect(cubit.state.students, ['أحمد', 'سارة', 'خالد']);
    await cubit.close();
  });

  test('names over 80 are dropped with a message', () async {
    final cubit = build();
    cubit.appendNames([for (var i = 0; i < 85; i++) 'طالب $i']);

    expect(cubit.state.students.length, ClassLimits.maxStudents);
    expect(cubit.state.isFull, isTrue);
    expect(cubit.state.feedback?.message, 'class_students_limit');
    await cubit.close();
  });

  test('edit, clear-to-remove and reorder', () async {
    final cubit = build();
    cubit.appendNames(['أ', 'ب', 'ج']);
    cubit.editStudent(0, ' أحمد ');
    cubit.reorderStudent(2, 0);
    cubit.editStudent(1, '');

    expect(cubit.state.students, ['ج', 'ب']);
    await cubit.close();
  });

  test('an imported sheet comes back for review', () async {
    when(() => picker.pickSpreadsheet()).thenAnswer((_) async => _sheet(10));
    when(() => repo.importNames(any())).thenAnswer((_) async => const Right(['سارة', 'أحمد']));
    final cubit = build();
    final states = <ClassEditorState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.importFromFile();
    await pumpEventQueue();
    await sub.cancel();

    expect(states.last.importedNames, ['سارة', 'أحمد']);
    expect(cubit.state.isImporting, isFalse);
    expect(cubit.state.students, isEmpty);
    await cubit.close();
  });

  test('a sheet over 2 MB is refused before uploading', () async {
    when(() => picker.pickSpreadsheet()).thenAnswer((_) async => _sheet(ClassLimits.maxImportBytes + 1));
    final cubit = build();
    await cubit.importFromFile();

    expect(cubit.state.feedback?.message, 'class_import_too_large');
    verifyNever(() => repo.importNames(any()));
    await cubit.close();
  });

  test('a sheet without names says so', () async {
    when(() => picker.pickSpreadsheet()).thenAnswer((_) async => _sheet(10));
    when(() => repo.importNames(any())).thenAnswer((_) async => const Right([]));
    final cubit = build();
    await cubit.importFromFile();

    expect(cubit.state.feedback?.message, 'class_import_empty');
    await cubit.close();
  });

  test('save needs a name', () async {
    final cubit = build();
    await cubit.save();

    expect(cubit.state.feedback?.message, 'class_name_required');
    verifyNever(() => repo.createClass(any()));
    await cubit.close();
  });

  test('saving a new class posts the whole list', () async {
    when(() => repo.createClass(any())).thenAnswer((_) async => const Right(SchoolClassModel(id: 9, name: 'خامس 1')));
    final cubit = build();
    cubit.nameController.text = ' خامس 1 ';
    cubit.appendNames(['سارة', 'أحمد']);
    await cubit.save();

    final sent = verify(() => repo.createClass(captureAny())).captured.single as SchoolClassModel;
    expect(sent.name, 'خامس 1');
    expect(sent.students, ['سارة', 'أحمد']);
    expect(cubit.state.isSaved, isTrue);
    expect(cubit.state.classId, 9);
    await cubit.close();
  });

  test('saving an existing class replaces it with PUT', () async {
    when(() => repo.getClass(3)).thenAnswer((_) async => const Right(SchoolClassModel(id: 3, name: 'خامس 1')));
    when(() => repo.updateClass(3, any())).thenAnswer((_) async => const Right(SchoolClassModel(id: 3, name: 'خامس 1')));
    final cubit = build(classId: 3);
    await cubit.load();
    await cubit.save();

    verify(() => repo.updateClass(3, any())).called(1);
    verifyNever(() => repo.createClass(any()));
    await cubit.close();
  });

  test('a failed save stays on the form with the error', () async {
    when(() => repo.createClass(any())).thenAnswer((_) async => const Left(ServerFailure('وصلت للحد الأقصى لعدد الفصول.')));
    final cubit = build();
    cubit.nameController.text = 'خامس 1';
    await cubit.save();

    expect(cubit.state.isSaved, isFalse);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.feedback?.message, 'وصلت للحد الأقصى لعدد الفصول.');
    await cubit.close();
  });
}
