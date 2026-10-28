import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_field_error.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';

void main() {
  group('OutcomesMapInput.fromSkeleton', () {
    CurriculumChapterModel chapter(String unitId, String unitName, List<int> ids, String semester) =>
        CurriculumChapterModel(
          chapterId: ids.first,
          title: unitName,
          unitId: unitId,
          unitName: unitName,
          semester: semester,
          lessons: [
            for (final id in ids)
              CurriculumLessonModel(id: id, title: 'درس $id', orderIndex: id, semester: semester),
          ],
        );

    test('groups chapters sharing a unit_id into one unit', () {
      final input = OutcomesMapInput.fromSkeleton(
        subjectId: 7,
        semester: '1',
        title: 'خريطة',
        chapters: [
          chapter('u1', 'الوحدة الأولى', [1, 2], '1'),
          chapter('u1', 'الوحدة الأولى', [3], '1'),
          chapter('u2', 'الوحدة الثانية', [4], '1'),
        ],
      );

      expect(input.subjectId, 7);
      expect(input.units.length, 2);
      expect(input.units.first.name, 'الوحدة الأولى');
      expect(input.units.first.lessons.map((l) => l.lessonId), [1, 2, 3]);
      expect(input.units.last.lessons.single.lessonId, 4);
    });

    test('keeps only the picked semester lessons', () {
      final input = OutcomesMapInput.fromSkeleton(
        subjectId: 7,
        semester: '2',
        title: 'خريطة',
        chapters: [
          chapter('u1', 'وحدة', [1], '1'),
          chapter('u2', 'وحدة ٢', [2], '2'),
        ],
      );
      expect(input.units.length, 1);
      expect(input.units.single.lessons.single.lessonId, 2);
    });
  });

  group('structure mutations respect limits', () {
    test('cannot add a 13th unit', () {
      var input = const OutcomesMapInput(units: []);
      for (var i = 0; i < OutcomesMapLimits.maxUnits + 2; i++) {
        input = input.addUnit();
      }
      expect(input.units.length, OutcomesMapLimits.maxUnits);
    });

    test('cannot add a 5th outcome', () {
      var input = const OutcomesMapInput(units: [OutcomeUnit(lessons: [OutcomeLesson()])]);
      for (var i = 0; i < OutcomesMapLimits.maxOutcomesPerLesson + 2; i++) {
        input = input.addOutcome(0, 0);
      }
      expect(input.units.first.lessons.first.outcomes.length, OutcomesMapLimits.maxOutcomesPerLesson);
    });
  });

  group('fillUnitFromAi', () {
    test('fills only lessons that have no outcomes yet', () {
      const input = OutcomesMapInput(
        units: [
          OutcomeUnit(
            lessons: [
              OutcomeLesson(lessonId: 1, outcomes: ['ناتج المعلم']),
              OutcomeLesson(lessonId: 2),
            ],
          ),
        ],
      );

      final filled = input.fillUnitFromAi(0, {
        1: ['يجب ألا يُكتب'],
        2: ['ناتج مقترح أ', 'ناتج مقترح ب'],
      });

      expect(filled.units.first.lessons.first.outcomes, ['ناتج المعلم']);
      expect(filled.units.first.lessons.last.outcomes, ['ناتج مقترح أ', 'ناتج مقترح ب']);
    });

    test('caps AI outcomes at the maximum', () {
      const input = OutcomesMapInput(units: [OutcomeUnit(lessons: [OutcomeLesson(lessonId: 9)])]);
      final filled = input.fillUnitFromAi(0, {9: ['a', 'b', 'c', 'd', 'e', 'f']});
      expect(filled.units.first.lessons.single.outcomes.length, OutcomesMapLimits.maxOutcomesPerLesson);
    });
  });

  test('toJson drops empty outcomes and emits the signatures list', () {
    const input = OutcomesMapInput(
      subjectId: 3,
      semester: '1',
      title: '  خريطة  ',
      layout: OutcomesMapLayout.tree,
      units: [
        OutcomeUnit(
          name: 'وحدة',
          lessons: [
            OutcomeLesson(lessonId: 5, title: 'درس', outcomes: ['ناتج', '  ', '']),
          ],
        ),
      ],
      signatures: {OutcomesMapSignature.teacher},
    );

    final json = input.toJson();
    expect(json['subject_id'], 3);
    expect(json['title'], 'خريطة');
    expect(json['layout'], 'tree');
    expect(json['signatures'], ['teacher']);
    final lesson = (json['units'] as List).first['lessons'][0] as Map<String, dynamic>;
    expect(lesson['lesson_id'], 5);
    expect(lesson['outcomes'], ['ناتج']);
  });

  test('fromJson round-trips a saved map', () {
    final parsed = OutcomesMapInput.fromJson({
      'subject_id': 3,
      'semester': '2',
      'title': 'خريطة',
      'layout': 'table',
      'signatures': ['principal'],
      'units': [
        {
          'name': 'وحدة',
          'lessons': [
            {'lesson_id': 5, 'title': 'درس', 'outcomes': ['أ', 'ب']},
          ],
        },
      ],
    });

    expect(parsed.semester, '2');
    expect(parsed.layout, OutcomesMapLayout.table);
    expect(parsed.signatures, {OutcomesMapSignature.principal});
    expect(parsed.units.single.lessons.single.outcomes, ['أ', 'ب']);
  });

  group('OutcomesMapFieldError.parse', () {
    test('parses a lesson key', () {
      final error = OutcomesMapFieldError.parse('units.1.lessons.2.outcomes', ['مطلوب']);
      expect(error!.isLesson, isTrue);
      expect(error.unitIndex, 1);
      expect(error.lessonIndex, 2);
      expect(error.message, 'مطلوب');
    });

    test('parses a unit and a title key', () {
      expect(OutcomesMapFieldError.parse('input.units.0.name', 'x')!.unitIndex, 0);
      expect(OutcomesMapFieldError.parse('title', 'x')!.isTitle, isTrue);
      expect(OutcomesMapFieldError.parse('something.else', 'x'), isNull);
    });
  });
}
