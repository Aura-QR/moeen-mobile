import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';
import 'package:moean/features/learning_styles/presentation/cubit/new_learning_style_cubit.dart';

class MockLearningStylesRepository extends Mock implements LearningStylesRepository {}

class MockClassesRepository extends Mock implements ClassesRepository {}

void main() {
  late MockLearningStylesRepository repository;
  late MockClassesRepository classes;
  late NewLearningStyleCubit cubit;

  const createdSurvey = LearningStyleSurvey(id: 9, title: 'أنماط التعلم');

  setUpAll(() => registerFallbackValue(const NewLearningStyleSurvey(title: 'x')));

  setUp(() {
    repository = MockLearningStylesRepository();
    classes = MockClassesRepository();
    cubit = NewLearningStyleCubit(repository: repository, classes: classes);
  });

  tearDown(() => cubit.close());

  test('loadOptions and loadClasses fill the state', () async {
    when(() => repository.getOptions()).thenAnswer(
      (_) async => const Right(LearningStylesOptions(groupsLimit: 10)),
    );
    when(() => classes.getClasses()).thenAnswer(
      (_) async => const Right([SchoolClassModel(id: 5, name: 'خامس ١')]),
    );

    await cubit.loadOptions();
    await cubit.loadClasses();

    expect(cubit.state.maxGroups, 10);
    expect(cubit.state.classes.single.id, 5);
  });

  test('addGroup ignores a duplicate class and respects the limit', () {
    cubit.addGroup('خامس ١', classId: 5);
    cubit.addGroup('خامس ١ مكرر', classId: 5);

    expect(cubit.state.groups.length, 1);
    expect(cubit.state.canStart, isTrue);
  });

  test('submit sends the groups and keeps the new id', () async {
    when(() => repository.create(any())).thenAnswer((_) async => const Right(createdSurvey));

    cubit.setVersion(LearningStyleVersions.simple);
    cubit.addGroup('خامس ١', classId: 5);
    await cubit.submit('أنماط التعلم');

    final captured = verify(() => repository.create(captureAny())).captured.single as NewLearningStyleSurvey;
    expect(captured.version, LearningStyleVersions.simple);
    expect(captured.groups.single.classId, 5);
    expect(cubit.state.createdId, 9);
  });

  test('submit surfaces the error and does not set an id', () async {
    when(() => repository.create(any())).thenAnswer((_) async => const Left(ValidationFailure('خطأ', {})));

    cubit.addGroup('خامس ١');
    await cubit.submit('عنوان');

    expect(cubit.state.error, 'خطأ');
    expect(cubit.state.createdId, isNull);
  });

  test('cannot submit with no groups', () async {
    await cubit.submit('عنوان');
    verifyNever(() => repository.create(any()));
  });
}
