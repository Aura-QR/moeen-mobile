import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';

void main() {
  group('LabExperimentModel', () {
    test('parses from JSON correctly', () {
      final json = {
        'key': 'ohm',
        'name': 'قانون أوم',
        'area': 'كهرباء',
        'kind': 'formula',
        'display': 'graph',
        'observe': 'التيار يتناسب طرديًا مع الجهد',
        'approximate': true,
        'featured': true,
        'source': 'hader',
        'author_name': 'أحمد',
        'plays': 42,
        'lessons_count': 12,
        'url': 'https://haderedu.com/lab/ohm',
      };

      final model = LabExperimentModel.fromJson(json);

      expect(model.key, 'ohm');
      expect(model.name, 'قانون أوم');
      expect(model.area, 'كهرباء');
      expect(model.approximate, isTrue);
      expect(model.featured, isTrue);
      expect(model.plays, 42);
      expect(model.lessonsCount, 12);
      expect(model.authorName, 'أحمد');
    });

    test('parses LabExperimentsPage correctly', () {
      final json = {
        'data': [
          {'key': 'ohm', 'name': 'قانون أوم', 'plays': 10},
          {'key': 'density', 'name': 'الكثافة', 'plays': 20},
        ],
        'meta': {
          'current_page': 1,
          'last_page': 3,
          'total': 50,
          'per_page': 24,
        },
      };

      final page = LabExperimentsPage.fromJson(json);

      expect(page.items.length, 2);
      expect(page.currentPage, 1);
      expect(page.lastPage, 3);
      expect(page.hasMore, isTrue);
      expect(page.total, 50);
    });
  });

  group('LabFiltersModel', () {
    test('parses stages, subject groups and totals', () {
      final json = {
        'stages': [
          {
            'id': 3,
            'name': 'الثانوية',
            'experiments_count': 98,
            'grades': [
              {
                'id': 10,
                'name': 'الثاني الثانوي',
                'experiments_count': 44,
                'subjects': [
                  {
                    'id': 41,
                    'name': 'الفيزياء 2',
                    'experiments_count': 21,
                  }
                ]
              }
            ]
          }
        ],
        'subject_groups': [
          {'key': 'physics', 'name': 'الفيزياء', 'experiments_count': 70},
        ],
        'totals': {
          'experiments': 127,
          'lessons': 690,
          'grades': 18,
        }
      };

      final model = LabFiltersModel.fromJson(json);

      expect(model.stages.length, 1);
      expect(model.stages.first.grades.length, 1);
      expect(model.stages.first.grades.first.subjects.length, 1);
      expect(model.subjectGroups.length, 1);
      expect(model.subjectGroups.first.key, 'physics');
      expect(model.totalExperiments, 127);
    });
  });
}
