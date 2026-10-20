import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

void main() {
  // Shaped like grade 5 Tajweed: one chapter tagged term 2 that holds
  // lessons from both terms, plus one all-year lesson.
  final chapter = CurriculumChapterModel.fromJson({
    'chapter_id': 558,
    'title': 'دروس المقرر',
    'semester': '2',
    'lessons': [
      {'id': 1, 'title': 'أحكام النون الساكنة والتنوين', 'semester': 'year'},
      {'id': 2, 'title': 'الإدغام', 'semester': '1'},
      {'id': 3, 'title': 'أحكام الميم الساكنة', 'semester': '2'},
    ],
  });

  List<int> ids(String? semester) =>
      chapter.lessonsInSemester(semester).map((l) => l.id).toList();

  test('term 1 uses the lesson term, not the chapter term', () {
    expect(ids('1'), [1, 2]);
  });

  test('term 2 leaves out the term 1 lessons', () {
    expect(ids('2'), [1, 3]);
  });

  test('no term filter keeps every lesson', () {
    expect(ids(null), [1, 2, 3]);
  });

  test('all-year chapters show in both terms', () {
    final yearChapter = CurriculumChapterModel.fromJson({
      'chapter_id': 1,
      'title': 'الفقه',
      'semester': 'year',
      'lessons': [
        {'id': 9, 'title': 'الطهارة', 'semester': 'year'},
      ],
    });
    expect(yearChapter.lessonsInSemester('1'), hasLength(1));
    expect(yearChapter.lessonsInSemester('2'), hasLength(1));
  });

  test('a lesson with no term keeps the old default of term 1', () {
    final chapter = CurriculumChapterModel.fromJson({
      'chapter_id': 2,
      'title': 'الرياضيات 1',
      'semester': null,
      'lessons': [
        {'id': 5, 'title': 'المجموعات'},
      ],
    });
    expect(chapter.lessonsInSemester('1'), hasLength(1));
    expect(chapter.lessonsInSemester('2'), isEmpty);
  });
}
