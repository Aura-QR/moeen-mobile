import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_element_model.dart';

import 'performance_fixture.dart';

void main() {
  group('PerformanceModel', () {
    test('parses the view', () {
      final performance = PerformanceModel.fromJson(performanceJson());

      expect(performance.portfolioId, 7);
      expect(performance.ratingMax, 5);
      expect(performance.documentId, 55);
      expect(performance.rating.average, 4.33);
      expect(performance.rating.points, 13);
      expect(performance.items, hasLength(2));

      final item = performance.itemById(31)!;
      expect(item.number, 4);
      expect(item.selfRating, 4);
      expect(item.state, PerformanceEvidenceState.complete);
      expect(item.isRatable, isTrue);
      expect(item.files.single.isLink, isTrue);
      expect(item.documents.single.type, 'strategy_documentation');
      expect(item.documents.single.createdAt, isNotNull);
    });

    test('keeps only the filled CV fields', () {
      final performance = PerformanceModel.fromJson(performanceJson());

      expect(performance.cv, {'name': 'سارة', 'qualification': 'بكالوريوس'});
    });

    test('an item without a weight, unknown state and no documents', () {
      final item = PerformanceModel.fromJson(performanceJson()).itemById(32)!;

      expect(item.isRatable, isFalse);
      expect(item.included, isFalse);
      expect(item.state, PerformanceEvidenceState.none);
      expect(item.documents, isEmpty);
      expect(item.files, isEmpty);
    });

    test('average and percent stay null until something is rated', () {
      final rating = PerformanceModel.fromJson(performanceJson(average: null)).rating;

      expect(rating.rated, 0);
      expect(rating.average, isNull);
      expect(rating.percent, isNull);
    });

    test('copyWith can clear a rating', () {
      final item = PerformanceModel.fromJson(performanceJson()).itemById(31)!;

      expect(item.copyWith(clearRating: true).selfRating, isNull);
      expect(item.copyWith(selfRating: 2).selfRating, 2);
    });
  });

  group('official items', () {
    Map<String, dynamic> item(int id, {bool? official}) => {
          'id': id,
          'number': 3,
          'weight': 10,
          'title': 'إعداد وتنفيذ خطة التعلم',
          'official': ?official,
        };

    test('an item outside the role\'s form loses its number, weight and stars', () {
      final performance = PerformanceModel.fromJson({
        'items': [item(1, official: true), item(2, official: false)],
      });

      expect(performance.officialItems.single.id, 1);
      final extra = performance.extraItems.single;
      expect(extra.official, isFalse);
      expect(extra.number, isNull);
      expect(extra.weight, isNull);
      expect(extra.isRatable, isFalse);
    });

    test('an older server without official keeps every item in the form', () {
      final performance = PerformanceModel.fromJson({'items': [item(1)]});

      expect(performance.extraItems, isEmpty);
      expect(performance.officialItems.single.weight, 10);
    });
  });

  group('PortfolioElementsModel', () {
    const teacherForm = [
      {'key': 'duties', 'title': 'أداء الواجبات الوظيفية', 'number': 1, 'weight': 10},
      {'key': 'learning_plan', 'title': 'إعداد وتنفيذ خطة التعلم', 'number': 3, 'weight': 10},
    ];
    const kindergartenForm = [
      {'key': 'duties', 'title': 'أداء الواجبات الوظيفية', 'number': 1, 'weight': 5},
      {'key': 'play_corners', 'title': 'أركان التعلم', 'number': 2, 'weight': 5},
    ];
    final model = PortfolioElementsModel.fromJson({
      'data': [
        {'role': 'teacher', 'label': 'معلم', 'form': teacherForm},
        {'role': 'kindergarten_teacher', 'label': 'معلمة روضة', 'form': kindergartenForm},
        {'role': 'principal', 'label': 'مدير', 'form': []},
      ],
      'elements': [
        {'key': 'activity_plan', 'title': 'خطة النشاط', 'number': null, 'weight': null},
      ],
    });

    test('reads each role\'s form', () {
      expect(model.forms.keys, ['teacher', 'kindergarten_teacher', 'principal']);
      expect(model.forms['kindergarten_teacher']!.last.number, 2);
      expect(model.forms['principal'], isEmpty);
    });

    test('lists the role\'s form in order', () {
      final options = model.optionsFor('kindergarten_teacher', 'play_corners');

      expect(options.map((e) => e.key), ['duties', 'play_corners']);
      expect(options.first.weight, 5);
    });

    test('no portfolio shows the teacher\'s form', () {
      expect(model.optionsFor(null, null).map((e) => e.key), ['duties', 'learning_plan']);
    });

    test('a current element outside the form is added at the end, without a number', () {
      final options = model.optionsFor('kindergarten_teacher', 'learning_plan');

      expect(options.map((e) => e.key), ['duties', 'play_corners', 'learning_plan']);
      expect(options.last.title, 'إعداد وتنفيذ خطة التعلم');
      expect(options.last.number, isNull);
    });

    test('names an unknown key from elements, or by the key itself', () {
      expect(model.optionsFor('teacher', 'activity_plan').last.title, 'خطة النشاط');
      expect(model.optionsFor('teacher', 'gone').last.title, 'gone');
    });

    test('an old response without forms lists its flat elements', () {
      final old = PortfolioElementsModel.fromJson({
        'data': [
          {'role': 'teacher', 'label': 'معلم'},
        ],
        'elements': [
          {'key': 'duties', 'title': 'أداء الواجبات الوظيفية', 'number': 1, 'weight': 10},
        ],
      });

      expect(old.forms, isEmpty);
      expect(old.optionsFor('kindergarten_teacher', null).single.key, 'duties');
    });
  });
}
