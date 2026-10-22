import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/presentation/cubit/classes_cubit.dart';

class MockClassesRepository extends Mock implements ClassesRepository {}

const _first = SchoolClassModel(id: 1, name: 'خامس 1', studentsCount: 20);
const _second = SchoolClassModel(id: 2, name: 'خامس 2', studentsCount: 25);

void main() {
  late MockClassesRepository repo;

  setUp(() {
    repo = MockClassesRepository();
    when(() => repo.getClasses()).thenAnswer((_) async => const Right([_first, _second]));
  });

  test('load lists the classes', () async {
    final cubit = ClassesCubit(repo);
    await cubit.load();

    expect(cubit.state.status, ClassesStatus.success);
    expect(cubit.state.classes.map((c) => c.id), [1, 2]);
    expect(cubit.state.isFull, isFalse);
    await cubit.close();
  });

  test('load failure shows the error', () async {
    when(() => repo.getClasses()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = ClassesCubit(repo);
    await cubit.load();

    expect(cubit.state.status, ClassesStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
    await cubit.close();
  });

  test('delete removes the class once the server confirms', () async {
    when(() => repo.deleteClass(1)).thenAnswer((_) async => const Right(unit));
    final cubit = ClassesCubit(repo);
    await cubit.load();
    await cubit.delete(_first);

    expect(cubit.state.classes.map((c) => c.id), [2]);
    expect(cubit.state.busyId, isNull);
    expect(cubit.state.feedback?.message, 'class_deleted');
    await cubit.close();
  });

  test('a failed delete keeps the class', () async {
    when(() => repo.deleteClass(1)).thenAnswer((_) async => const Left(ServerFailure('generic_error')));
    final cubit = ClassesCubit(repo);
    await cubit.load();
    await cubit.delete(_first);

    expect(cubit.state.classes.length, 2);
    expect(cubit.state.feedback?.isError, isTrue);
    await cubit.close();
  });

  test('40 classes is full', () async {
    when(() => repo.getClasses()).thenAnswer(
      (_) async => Right([for (var i = 0; i < ClassLimits.maxClasses; i++) SchoolClassModel(id: i, name: '$i')]),
    );
    final cubit = ClassesCubit(repo);
    await cubit.load();

    expect(cubit.state.isFull, isTrue);
    await cubit.close();
  });
}
