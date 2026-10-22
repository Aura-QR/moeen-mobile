import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/presentation/cubit/madrasati_import_cubit.dart';

class MockClassesRepository extends Mock implements ClassesRepository {}

const _new = MadrasatiClassModel(madrasatiId: 'm1', name: 'خامس 1');
const _existing = MadrasatiClassModel(madrasatiId: 'm2', name: 'خامس 2', existingClassId: 7);

void main() {
  late MockClassesRepository repo;

  setUpAll(() => registerFallbackValue(const SchoolClassModel(name: '')));

  setUp(() {
    repo = MockClassesRepository();
    when(() => repo.getMadrasatiClasses()).thenAnswer((_) async => const Right([_new, _existing]));
    when(() => repo.readMadrasatiClass('m1')).thenAnswer((_) async => const Right(['سارة', 'أحمد']));
    when(() => repo.readMadrasatiClass('m2')).thenAnswer((_) async => const Right(['خالد']));
    when(() => repo.createClass(any())).thenAnswer((_) async => const Right(SchoolClassModel(id: 9, name: 'خامس 1')));
    when(() => repo.updateClass(7, any())).thenAnswer((_) async => const Right(SchoolClassModel(id: 7, name: 'خامس 2')));
  });

  Future<MadrasatiImportCubit> loaded() async {
    final cubit = MadrasatiImportCubit(repo);
    await cubit.load();
    return cubit;
  }

  test('load lists the Madrasati classes, all ticked', () async {
    final cubit = await loaded();

    expect(cubit.state.status, MadrasatiImportStatus.success);
    expect(cubit.state.rows.map((row) => row.isChecked), [true, true]);
    await cubit.close();
  });

  test('a load failure shows its message', () async {
    when(() => repo.getMadrasatiClasses()).thenAnswer((_) async => const Left(ServerFailure('اربط حساب مدرستي')));
    final cubit = await loaded();

    expect(cubit.state.status, MadrasatiImportStatus.failure);
    expect(cubit.state.errorMessage, 'اربط حساب مدرستي');
    await cubit.close();
  });

  test('only the ticked classes are read', () async {
    final cubit = await loaded();
    cubit.toggle(1);
    await cubit.read();

    expect(cubit.state.isRead, isTrue);
    expect(cubit.state.rows[0].students, ['سارة', 'أحمد']);
    expect(cubit.state.rows[1].status, MadrasatiRowStatus.idle);
    verifyNever(() => repo.readMadrasatiClass('m2'));
    await cubit.close();
  });

  test('classes cannot change after reading', () async {
    final cubit = await loaded();
    await cubit.read();
    cubit.toggle(0);

    expect(cubit.state.rows[0].isChecked, isTrue);
    await cubit.close();
  });

  test('a failed read marks that class and keeps the others', () async {
    when(() => repo.readMadrasatiClass('m1')).thenAnswer((_) async => const Left(ServerFailure('تعذرت القراءة')));
    final cubit = await loaded();
    await cubit.read();

    expect(cubit.state.rows[0].status, MadrasatiRowStatus.failed);
    expect(cubit.state.rows[1].status, MadrasatiRowStatus.read);
    expect(cubit.state.errorMessage, 'تعذرت القراءة');
    await cubit.close();
  });

  test('save creates new classes and replaces the names of existing ones', () async {
    final cubit = await loaded();
    await cubit.read();
    await cubit.save();

    final created = verify(() => repo.createClass(captureAny())).captured.single as SchoolClassModel;
    expect(created.name, 'خامس 1');
    expect(created.students, ['سارة', 'أحمد']);
    verify(() => repo.updateClass(7, any())).called(1);
    expect(cubit.state.isDone, isTrue);
    expect(cubit.state.savedAny, isTrue);
    await cubit.close();
  });

  test('a retry after a failed save skips the classes already saved', () async {
    var updates = 0;
    when(() => repo.updateClass(7, any())).thenAnswer(
      (_) async => ++updates == 1 ? const Left(ServerFailure('generic_error')) : const Right(SchoolClassModel(id: 7, name: 'خامس 2')),
    );
    final cubit = await loaded();
    await cubit.read();
    await cubit.save();

    expect(cubit.state.isDone, isFalse);
    expect(cubit.state.errorMessage, 'generic_error');
    expect(cubit.state.rows[0].status, MadrasatiRowStatus.saved);

    await cubit.save();
    verify(() => repo.createClass(any())).called(1);
    expect(cubit.state.isDone, isTrue);
    await cubit.close();
  });
}
