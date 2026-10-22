import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class MockCurriculumLessonsRepository extends Mock implements CurriculumLessonsRepository {}

const _science = LessonPickerSubjectModel(subjectId: 3, subjectName: 'العلوم', gradeName: 'الخامس الابتدائي');
const _math = LessonPickerSubjectModel(subjectId: 4, subjectName: 'الرياضيات', gradeName: 'السادس الابتدائي');

void main() {
  late MockCurriculumLessonsRepository repo;
  late LessonPickerCubit cubit;

  setUp(() {
    repo = MockCurriculumLessonsRepository();
    cubit = LessonPickerCubit(repo);
    when(() => repo.getSubjects()).thenAnswer((_) async => const Right([_science, _math]));
  });

  tearDown(() => cubit.close());

  test('search filters by subject or grade name', () async {
    await cubit.load();
    cubit.search('السادس');

    expect(cubit.state.visibleSubjects, [_math]);
  });

  test('openSubject loads its chapters, and pick returns the lesson', () async {
    final chapter = CurriculumChapterModel(
      chapterId: 1,
      title: 'الماء',
      semester: '1',
      lessons: [CurriculumLessonModel(id: 55, title: 'دورة الماء', orderIndex: 1, semester: '1')],
    );
    when(() => repo.getChapters(3)).thenAnswer((_) async => Right([chapter]));
    await cubit.load();
    await cubit.openSubject(_science);
    final picked = cubit.pick(chapter.lessons.single);

    expect(cubit.state.lessonsStatus, LessonPickerStatus.success);
    expect(picked.lessonId, 55);
    expect(picked.lessonTitle, 'دورة الماء');
    expect(picked.subjectName, 'العلوم');
    expect(picked.gradeName, 'الخامس الابتدائي');
  });

  test('a lessons failure keeps the subject open with the message', () async {
    when(() => repo.getChapters(3)).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.load();
    await cubit.openSubject(_science);

    expect(cubit.state.subject, _science);
    expect(cubit.state.lessonsStatus, LessonPickerStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('backToSubjects returns to step 1', () async {
    when(() => repo.getChapters(3)).thenAnswer((_) async => const Right([]));
    await cubit.load();
    await cubit.openSubject(_science);
    cubit.backToSubjects();

    expect(cubit.state.subject, isNull);
  });
}
