import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';
import 'package:moean/features/learning_styles/presentation/cubit/learning_style_survey_cubit.dart';

class MockLearningStylesRepository extends Mock implements LearningStylesRepository {}

void main() {
  late MockLearningStylesRepository repository;

  const survey = LearningStyleSurvey(id: 1, title: 'أنماط التعلم', isOpen: true, responses: 2);
  const results = LearningStylesResults(survey: survey, overall: StyleSummary(count: 2));

  LearningStyleSurveyCubit build() =>
      LearningStyleSurveyCubit(surveyId: 1, repository: repository);

  setUp(() {
    repository = MockLearningStylesRepository();
    when(() => repository.getSurvey(1)).thenAnswer((_) async => const Right(survey));
    when(() => repository.getResults(1)).thenAnswer((_) async => const Right(results));
  });

  test('load fetches the survey and its results', () async {
    final cubit = build();
    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.survey?.id, 1);
    expect(cubit.state.results?.overall.count, 2);
    await cubit.close();
  });

  test('toggleOpen flips is_open through the repository', () async {
    when(() => repository.setOpen(1, false)).thenAnswer(
      (_) async => const Right(LearningStyleSurvey(id: 1, title: 'أنماط التعلم', isOpen: false)),
    );

    final cubit = build();
    await cubit.load();
    await cubit.toggleOpen();

    verify(() => repository.setOpen(1, false)).called(1);
    expect(cubit.state.survey?.isOpen, isFalse);
    await cubit.close();
  });

  test('deleteResponse refreshes and reports success', () async {
    when(() => repository.deleteResponse(1, 7)).thenAnswer((_) async => const Right(unit));

    final cubit = build();
    await cubit.load();
    await cubit.deleteResponse(7);

    verify(() => repository.deleteResponse(1, 7)).called(1);
    expect(cubit.state.message, 'learning_styles_response_deleted');
    await cubit.close();
  });

  test('saveReport exposes the report document id', () async {
    when(() => repository.saveReport(1)).thenAnswer(
      (_) async => const Right(DocumentModel(id: 42, type: DocumentTypes.learningStyles, title: 'تقرير', status: 'draft')),
    );

    final cubit = build();
    await cubit.load();
    await cubit.saveReport();

    expect(cubit.state.reportDocumentId, 42);
    await cubit.close();
  });

  test('saveReport surfaces a 422 when nobody answered', () async {
    when(() => repository.saveReport(1)).thenAnswer((_) async => const Left(ValidationFailure('لا توجد إجابات بعد.', {})));

    final cubit = build();
    await cubit.load();
    await cubit.saveReport();

    expect(cubit.state.reportDocumentId, isNull);
    expect(cubit.state.message, 'لا توجد إجابات بعد.');
    expect(cubit.state.messageIsError, isTrue);
    await cubit.close();
  });

  test('delete marks the survey deleted', () async {
    when(() => repository.delete(1)).thenAnswer((_) async => const Right(unit));

    final cubit = build();
    await cubit.load();
    await cubit.delete();

    expect(cubit.state.deleted, isTrue);
    await cubit.close();
  });
}
