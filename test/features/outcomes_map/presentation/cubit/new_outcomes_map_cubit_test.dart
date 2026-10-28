import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/new_outcomes_map_cubit.dart';

class MockCurriculumLessonsRepository extends Mock implements CurriculumLessonsRepository {}

void main() {
  late MockCurriculumLessonsRepository curriculum;
  late NewOutcomesMapCubit cubit;

  final sampleChapter = CurriculumChapterModel(
    chapterId: 5,
    title: 'الوحدة الأولى',
    unitId: 'u1',
    unitName: 'الوحدة الأولى',
    semester: '1',
    lessons: [
      CurriculumLessonModel(id: 101, title: 'الدرس الأول', orderIndex: 1, semester: '1'),
    ],
  );

  final sampleSubject = CurriculumSubjectModel(id: 42, name: 'العلوم');
  final sampleGrade = CurriculumGradeModel(id: 3, name: 'الصف الرابع', subjects: [sampleSubject]);
  final sampleStage = CurriculumStageModel(id: 1, name: 'المرحلة الابتدائية', grades: [sampleGrade]);

  setUp(() {
    curriculum = MockCurriculumLessonsRepository();
    cubit = NewOutcomesMapCubit(curriculumRepository: curriculum);
  });

  tearDown(() => cubit.close());

  test('loadStages sorts by school level', () async {
    final intermediate = CurriculumStageModel(id: 2, name: 'المرحلة المتوسطة', grades: const []);
    when(() => curriculum.getStages()).thenAnswer((_) async => Right([intermediate, sampleStage]));

    await cubit.loadStages();

    expect(cubit.state.stages.first.name, 'المرحلة الابتدائية');
    expect(cubit.state.stages.last.name, 'المرحلة المتوسطة');
  });

  test('selectSubject loads chapters and enables start', () async {
    when(() => curriculum.getChapters(42)).thenAnswer((_) async => Right([sampleChapter]));

    await cubit.selectSubject(sampleSubject);

    expect(cubit.state.selectedSubject?.id, 42);
    expect(cubit.state.chapters.length, 1);
    expect(cubit.state.semesterLessonCount, 1);
    expect(cubit.state.canStart, isTrue);
  });

  test('start builds the skeleton and emits generatedInput', () async {
    when(() => curriculum.getChapters(42)).thenAnswer((_) async => Right([sampleChapter]));
    await cubit.selectSubject(sampleSubject);

    cubit.start('خريطة نواتج التعلم — العلوم — الفصل الأول');

    final generated = cubit.state.generatedInput;
    expect(generated, isNotNull);
    expect(generated!.subjectId, 42);
    expect(generated.semester, '1');
    expect(generated.units.single.lessons.single.lessonId, 101);
    expect(generated.title, contains('العلوم'));
  });

  test('cannot start before a subject with lessons is picked', () {
    cubit.start('أي عنوان');
    expect(cubit.state.generatedInput, isNull);
  });
}
