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

  group('PortfolioElementsModel', () {
    test('reads elements and the scale beside data', () {
      final model = PortfolioElementsModel.fromJson({
        'data': [],
        'elements': [
          {'key': 'duties', 'title': 'أداء الواجبات الوظيفية', 'number': 1, 'weight': 10},
          {'key': 'activity_plan', 'title': 'خطة النشاط', 'number': null, 'weight': null},
        ],
        'rating_scale': {'min': 1, 'max': 4},
      });

      expect(model.elements, hasLength(2));
      expect(model.byKey('duties')!.number, 1);
      expect(model.byKey('activity_plan')!.weight, isNull);
      expect(model.byKey('missing'), isNull);
      expect(model.ratingMax, 4);
    });

    test('an old response without elements', () {
      final model = PortfolioElementsModel.fromJson({'data': []});

      expect(model.elements, isEmpty);
      expect(model.ratingMin, 1);
      expect(model.ratingMax, 5);
    });
  });
}
