import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockAiJobsRepository extends Mock implements AiJobsRepository {}

void main() {
  late MockDocumentsRepository documents;
  late MockAiJobsRepository aiJobs;

  const twoUnits = OutcomesMapInput(
    subjectId: 1,
    title: 'خريطة',
    units: [
      OutcomeUnit(name: 'وحدة ١', lessons: [OutcomeLesson(lessonId: 1, title: 'درس ١')]),
      OutcomeUnit(name: 'وحدة ٢', lessons: [OutcomeLesson(lessonId: 2, title: 'درس ٢')]),
    ],
  );

  OutcomesMapEditorCubit build(OutcomesMapInput input) => OutcomesMapEditorCubit(
        documentsRepository: documents,
        aiJobsRepository: aiJobs,
        initialInput: input,
        pollInterval: const Duration(milliseconds: 5),
        maxPollAttempts: 3,
      );

  AiJobModel done(int lessonId, List<String> outcomes) => AiJobModel(
        id: lessonId,
        kind: AiJobKinds.lessonOutcomes,
        status: AiJobStatus.done,
        rawResult: {
          'lessons': [
            {'lesson_id': lessonId, 'outcomes': outcomes},
          ],
        },
      );

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    documents = MockDocumentsRepository();
    aiJobs = MockAiJobsRepository();
  });

  test('suggestAllOutcomes fills every unit from cached jobs', () async {
    when(() => aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': [1]}))
        .thenAnswer((_) async => Right(done(1, ['أ', 'ب'])));
    when(() => aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': [2]}))
        .thenAnswer((_) async => Right(done(2, ['ج'])));

    final cubit = build(twoUnits);
    await cubit.suggestAllOutcomes();

    expect(cubit.state.input.units.first.lessons.single.outcomes, ['أ', 'ب']);
    expect(cubit.state.input.units.last.lessons.single.outcomes, ['ج']);
    expect(cubit.state.unitStatus(0), UnitAiStatus.done);
    expect(cubit.state.unitStatus(1), UnitAiStatus.done);
    expect(cubit.state.isSuggestingAll, isFalse);
    await cubit.close();
  });

  test('suggestAllOutcomes polls a pending (202) job until done', () async {
    when(() => aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': [1]})).thenAnswer(
      (_) async => const Right(AiJobModel(id: 7, kind: AiJobKinds.lessonOutcomes, status: AiJobStatus.pending)),
    );
    when(() => aiJobs.getJob(7)).thenAnswer((_) async => Right(done(1, ['ناتج'])));
    when(() => aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': [2]}))
        .thenAnswer((_) async => Right(done(2, ['ناتج ٢'])));

    final cubit = build(twoUnits);
    await cubit.suggestAllOutcomes();

    expect(cubit.state.input.units.first.lessons.single.outcomes, ['ناتج']);
    verify(() => aiJobs.getJob(7)).called(1);
    await cubit.close();
  });

  test('a 429 stops the run and leaves later units untouched', () async {
    when(() => aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': [1]}))
        .thenAnswer((_) async => const Left(RateLimitFailure('تجاوزت الحد')));

    final cubit = build(twoUnits);
    await cubit.suggestAllOutcomes();

    expect(cubit.state.unitStatus(0), UnitAiStatus.failed);
    expect(cubit.state.unitStatus(1), UnitAiStatus.idle);
    expect(cubit.state.isSuggestingAll, isFalse);
    expect(cubit.state.feedback?.message, 'تجاوزت الحد');
    verifyNever(() => aiJobs.start(AiJobKinds.lessonOutcomes, {'lesson_ids': [2]}));
    await cubit.close();
  });

  test('save refuses a lesson with no outcomes and opens its sheet', () async {
    final cubit = build(twoUnits);
    cubit.titleController.text = 'عنوان';

    await cubit.save();

    expect(cubit.state.openLesson, const LessonRef(0, 0));
    expect(cubit.state.lessonErrors[const LessonRef(0, 0).key], 'outcomes_map_lesson_needs_outcome');
    verifyNever(() => documents.createDocument(
          type: any(named: 'type'),
          input: any(named: 'input'),
          status: any(named: 'status'),
          element: any(named: 'element'),
          keepFieldErrors: any(named: 'keepFieldErrors'),
        ));
    await cubit.close();
  });

  test('save persists a valid map and keeps the new id', () async {
    const valid = OutcomesMapInput(
      subjectId: 1,
      title: 'خريطة',
      units: [
        OutcomeUnit(name: 'وحدة', lessons: [OutcomeLesson(lessonId: 1, title: 'درس', outcomes: ['ناتج'])]),
      ],
    );
    when(() => documents.createDocument(
          type: any(named: 'type'),
          input: any(named: 'input'),
          status: any(named: 'status'),
          element: any(named: 'element'),
          keepFieldErrors: any(named: 'keepFieldErrors'),
        )).thenAnswer(
      (_) async => const Right(
        DocumentModel(id: 55, type: DocumentTypes.outcomesMap, title: 'خريطة', status: 'draft'),
      ),
    );

    final cubit = build(valid);
    cubit.titleController.text = 'خريطة';
    await cubit.save();

    expect(cubit.state.documentId, 55);
    expect(cubit.state.isDirty, isFalse);
    expect(cubit.state.feedback?.message, 'document_saved');
    await cubit.close();
  });
}
