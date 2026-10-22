import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/documents/presentation/cubit/student_picker_cubit.dart';

class MockClassesRepository extends Mock implements ClassesRepository {}

const _summary = SchoolClassModel(id: 3, name: 'خامس 1', studentsCount: 3);
const _class = SchoolClassModel(
  id: 3,
  name: 'خامس 1',
  grade: 'الخامس',
  subject: 'رياضيات',
  students: ['سارة', 'أحمد', 'خالد'],
);

void main() {
  late MockClassesRepository repo;

  setUp(() {
    repo = MockClassesRepository();
    when(() => repo.getClasses()).thenAnswer((_) async => const Right([_summary]));
    when(() => repo.getClass(3)).thenAnswer((_) async => const Right(_class));
  });

  test('a picked class loads with every name ticked', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load();
    await cubit.openClass(_summary);

    expect(cubit.state.checked, [true, true, true]);
    expect(cubit.result()?.students, ['سارة', 'أحمد', 'خالد']);
    await cubit.close();
  });

  test('unticked names are left out, and the class details come along', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load();
    await cubit.openClass(_summary);
    cubit.toggle(1);
    final result = cubit.result()!;

    expect(result.students, ['سارة', 'خالد']);
    expect(result.classId, 3);
    expect(result.className, 'خامس 1');
    expect(result.subject, 'رياضيات');
    await cubit.close();
  });

  test('tick all and untick all', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load();
    await cubit.openClass(_summary);
    cubit.setAll(false);
    expect(cubit.state.checkedCount, 0);
    cubit.setAll(true);
    expect(cubit.state.checkedCount, 3);
    await cubit.close();
  });

  test('reopening opens the same class with the same ticks', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load(initialClassId: 3, initialStudents: const ['خالد']);

    expect(cubit.state.selected?.id, 3);
    expect(cubit.state.checked, [false, false, true]);
    await cubit.close();
  });

  test('typed names reopen in the typed mode', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load(initialStudents: const ['سارة', 'أحمد']);

    expect(cubit.state.mode, StudentPickerMode.typed);
    expect(cubit.typedController.text, 'سارة\nأحمد');
    await cubit.close();
  });

  test('typed names are split, with no class', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load();
    cubit.setMode(StudentPickerMode.typed);
    cubit.typedController.text = '1. سارة\n\nأحمد';
    final result = cubit.result()!;

    expect(result.students, ['سارة', 'أحمد']);
    expect(result.classId, isNull);
    await cubit.close();
  });

  test('nothing to return before a class or names', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load();

    expect(cubit.result(), isNull);
    cubit.setMode(StudentPickerMode.typed);
    expect(cubit.result(), isNull);
    await cubit.close();
  });

  test('back to the classes clears the open class', () async {
    final cubit = StudentPickerCubit(repo);
    await cubit.load();
    await cubit.openClass(_summary);
    cubit.backToClasses();

    expect(cubit.state.selected, isNull);
    expect(cubit.result(), isNull);
    await cubit.close();
  });
}
