import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';
import 'package:moean/features/learning_styles/presentation/cubit/learning_styles_list_cubit.dart';

class MockLearningStylesRepository extends Mock implements LearningStylesRepository {}

void main() {
  late MockLearningStylesRepository repository;
  late LearningStylesListCubit cubit;

  const sample = LearningStyleSurvey(id: 1, title: 'أنماط التعلم — خامس', responses: 3);

  setUp(() {
    repository = MockLearningStylesRepository();
    cubit = LearningStylesListCubit(repository);
  });

  tearDown(() => cubit.close());

  test('load emits the surveys on success', () async {
    when(() => repository.getSurveys()).thenAnswer((_) async => const Right([sample]));

    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.surveys.single.id, 1);
    expect(cubit.state.error, isNull);
  });

  test('load keeps the old list and sets the error on failure', () async {
    when(() => repository.getSurveys()).thenAnswer((_) async => const Left(ServerFailure('تعذّر الجلب')));

    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.error, 'تعذّر الجلب');
  });
}
