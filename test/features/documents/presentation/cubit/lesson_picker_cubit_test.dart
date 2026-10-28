import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class MockCurriculumLessonsRepository extends Mock implements CurriculumLessonsRepository {}

final _science = CurriculumSubjectModel(id: 3, name: 'العلوم');
final _math = CurriculumSubjectModel(id: 4, name: 'الرياضيات');
final _grade5 = CurriculumGradeModel(id: 5, name: 'الخامس الابتدائي', subjects: [_science, _math]);
final _grade6 = CurriculumGradeModel(id: 6, name: 'السادس الابتدائي', subjects: [_math]);
final _primary = CurriculumStageModel(id: 1, name: 'الابتدائية', grades: [_grade5, _grade6]);
final _secondary = CurriculumStageModel(id: 2, name: 'الثانوية', grades: const []);

void main() {
  late MockCurriculumLessonsRepository repo;
  late LessonPickerCubit cubit;

  setUp(() {
    repo = MockCurriculumLessonsRepository();
    cubit = LessonPickerCubit(repo);
    when(() => repo.getStages()).thenAnswer((_) async => Right([_primary, _secondary]));
  });

  tearDown(() => cubit.close());

  test('load fills the stages and starts on the stages step', () async {
    await cubit.load();

    expect(cubit.state.status, LessonPickerStatus.success);
    expect(cubit.state.step, LessonPickerStep.stages);
    expect(cubit.state.stages, [_primary, _secondary]);
  });

  test('search filters the current step by name', () async {
    await cubit.load();
    cubit.search('الثانوية');
    expect(cubit.state.visibleStages, [_secondary]);

    cubit.selectStage(_primary);
    expect(cubit.state.query, isEmpty, reason: 'navigating resets the search');
    cubit.search('الخامس');
    expect(cubit.state.visibleGrades, [_grade5]);
  });

  test('cascades stage → grade → subject and pick returns the named lesson', () async {
    final chapter = CurriculumChapterModel(
      chapterId: 1,
      title: 'الماء',
      semester: '1',
      lessons: [CurriculumLessonModel(id: 55, title: 'دورة الماء', orderIndex: 1, semester: '1')],
    );
    when(() => repo.getChapters(3)).thenAnswer((_) async => Right([chapter]));
    await cubit.load();

    cubit.selectStage(_primary);
    expect(cubit.state.step, LessonPickerStep.grades);
    expect(cubit.state.visibleGrades, [_grade5, _grade6]);

    cubit.selectGrade(_grade5);
    expect(cubit.state.step, LessonPickerStep.subjects);
    expect(cubit.state.visibleSubjects, [_science, _math]);

    await cubit.openSubject(_science);
    expect(cubit.state.step, LessonPickerStep.lessons);
    expect(cubit.state.lessonsStatus, LessonPickerStatus.success);

    final picked = cubit.pick(chapter.lessons.single);
    expect(picked.lessonId, 55);
    expect(picked.lessonTitle, 'دورة الماء');
    expect(picked.subjectName, 'العلوم');
    expect(picked.gradeName, 'الخامس الابتدائي');
  });

  test('a lessons failure keeps the subject open with the message', () async {
    when(() => repo.getChapters(3)).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.load();
    cubit.selectStage(_primary);
    cubit.selectGrade(_grade5);
    await cubit.openSubject(_science);

    expect(cubit.state.subject, _science);
    expect(cubit.state.lessonsStatus, LessonPickerStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('back navigation unwinds the steps one at a time', () async {
    when(() => repo.getChapters(3)).thenAnswer((_) async => const Right([]));
    await cubit.load();
    cubit.selectStage(_primary);
    cubit.selectGrade(_grade5);
    await cubit.openSubject(_science);

    cubit.backToSubjects();
    expect(cubit.state.step, LessonPickerStep.subjects);

    cubit.backToGrades();
    expect(cubit.state.step, LessonPickerStep.grades);

    cubit.backToStages();
    expect(cubit.state.step, LessonPickerStep.stages);
  });
}
