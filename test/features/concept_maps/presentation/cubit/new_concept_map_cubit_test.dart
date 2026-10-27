import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/concept_maps/presentation/cubit/new_concept_map_cubit.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class MockCurriculumLessonsRepository extends Mock
    implements CurriculumLessonsRepository {}

class MockAiJobsRepository extends Mock implements AiJobsRepository {}

void main() {
  late MockCurriculumLessonsRepository curriculum;
  late MockAiJobsRepository aiJobs;
  late NewConceptMapCubit cubit;

  final sampleLesson = CurriculumLessonModel(
    id: 101,
    title: 'حالات المادة',
    orderIndex: 1,
    semester: '1',
  );

  final sampleChapter = CurriculumChapterModel(
    chapterId: 5,
    title: 'الوحدة الأولى',
    semester: '1',
    lessons: [sampleLesson],
  );

  final sampleSubject = CurriculumSubjectModel(id: 42, name: 'العلوم');

  final sampleGrade = CurriculumGradeModel(
    id: 3,
    name: 'الصف الرابع',
    subjects: [sampleSubject],
  );

  final sampleStage = CurriculumStageModel(
    id: 1,
    name: 'المرحلة الابتدائية',
    grades: [sampleGrade],
  );

  setUp(() {
    curriculum = MockCurriculumLessonsRepository();
    aiJobs = MockAiJobsRepository();
    cubit = NewConceptMapCubit(
      curriculumRepository: curriculum,
      aiJobsRepository: aiJobs,
      pollInterval: const Duration(milliseconds: 5),
      maxPollAttempts: 3,
    );
  });

  tearDown(() => cubit.close());

  test('loadStages fetches stages and sorts them by school level', () async {
    final intermediate = CurriculumStageModel(
      id: 2,
      name: 'المرحلة المتوسطة',
      grades: const [],
    );
    when(
      () => curriculum.getStages(),
    ).thenAnswer((_) async => Right([intermediate, sampleStage]));

    await cubit.loadStages();

    expect(cubit.state.isStagesLoading, isFalse);
    expect(cubit.state.stages.length, 2);
    expect(cubit.state.stages.first.name, 'المرحلة الابتدائية');
    expect(cubit.state.stages.last.name, 'المرحلة المتوسطة');
  });

  test('selectStage resets lower cascade selections', () async {
    cubit.selectStage(sampleStage);
    expect(cubit.state.selectedStage?.id, 1);
    expect(cubit.state.selectedGrade, isNull);
    expect(cubit.state.selectedSubject, isNull);
    expect(cubit.state.selectedLesson, isNull);
  });

  test('selectSubject loads chapters and lessons', () async {
    when(
      () => curriculum.getChapters(42),
    ).thenAnswer((_) async => Right([sampleChapter]));

    await cubit.selectSubject(sampleSubject);

    expect(cubit.state.selectedSubject?.id, 42);
    expect(cubit.state.isLessonsLoading, isFalse);
    expect(cubit.state.chapters.length, 1);
    expect(cubit.state.chapters.first.lessons.first.title, 'حالات المادة');
  });

  test(
    'suggestMap opens immediately when AI job returns done (200 cached)',
    () async {
      when(
        () => aiJobs.start(AiJobKinds.conceptMap, {
          'lesson_ids': [101],
        }),
      ).thenAnswer(
        (_) async => const Right(
          AiJobModel(
            id: 1,
            kind: AiJobKinds.conceptMap,
            status: AiJobStatus.done,
            rawResult: {
              'title': 'حالات المادة',
              'nodes': [
                {'id': 'n1', 'text': 'المادة'},
                {'id': 'n2', 'parent_id': 'n1', 'text': 'صلبة', 'link': 'منها'},
              ],
            },
          ),
        ),
      );

      cubit.selectLesson(sampleLesson);
      await cubit.suggestMap();

      final generated = cubit.state.generatedInput;
      expect(generated, isNotNull);
      expect(generated!.lessonId, 101);
      expect(generated.layout, ConceptMapLayout.tree);
      expect(generated.nodes.length, 2);
    },
  );

  test('suggestMap polls pending job (202) until done', () async {
    when(
      () => aiJobs.start(AiJobKinds.conceptMap, {
        'lesson_ids': [101],
      }),
    ).thenAnswer(
      (_) async => const Right(
        AiJobModel(
          id: 9,
          kind: AiJobKinds.conceptMap,
          status: AiJobStatus.pending,
        ),
      ),
    );
    when(() => aiJobs.getJob(9)).thenAnswer(
      (_) async => const Right(
        AiJobModel(
          id: 9,
          kind: AiJobKinds.conceptMap,
          status: AiJobStatus.done,
          rawResult: {
            'nodes': [
              {'id': 'n1', 'text': 'المادة'},
            ],
          },
        ),
      ),
    );

    cubit.selectLesson(sampleLesson);
    await cubit.suggestMap();

    expect(cubit.state.generatedInput?.title, 'حالات المادة');
    verify(() => aiJobs.getJob(9)).called(1);
  });

  test('suggestMap surfaces 429 rate limit message', () async {
    when(
      () => aiJobs.start(AiJobKinds.conceptMap, {
        'lesson_ids': [101],
      }),
    ).thenAnswer(
      (_) async => const Left(RateLimitFailure('تجاوزت الحد اليومي')),
    );

    cubit.selectLesson(sampleLesson);
    await cubit.suggestMap();

    expect(cubit.state.aiStatus, ConceptMapAiStatus.rateLimited);
    expect(cubit.state.aiErrorMessage, 'تجاوزت الحد اليومي');
  });
}
