import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_plan_input.dart';

const _gridJson = {
  'term': 2,
  'region': 'general',
  'region_verified': true,
  'columns': [
    {'key': 'citizenship', 'label': 'المواطنة والحياة'},
    {'key': 'occasion', 'label': 'المناسبات'},
  ],
  'weeks': [
    {
      'week': 1,
      'type': 'teaching',
      'title': null,
      'start': '2027-01-17',
      'end': '2027-01-21',
      'start_hijri': '09-08-1448',
      'end_hijri': '13-08-1448',
      'cells': {'citizenship': 'إذاعة مدرسية', 'occasion': ''},
    },
    {'week': null, 'type': 'holiday', 'title': 'إجازة عيد الفطر', 'start': '2027-02-28', 'end': '2027-03-11', 'cells': {}},
    {
      'week': 19,
      'type': 'exam',
      'title': 'اختبارات نهائية',
      'start': '2027-05-30',
      'end': '2027-06-03',
      'start_hijri': null,
      'end_hijri': null,
      'cells': {'occasion': ''},
    },
  ],
};

void main() {
  group('ActivitiesGridModel', () {
    final grid = ActivitiesGridModel.fromJson(_gridJson);

    test('reads the columns and the three kinds of rows', () {
      expect(grid.term, 2);
      expect(grid.regionVerified, isTrue);
      expect(grid.columns.map((c) => c.key), ['citizenship', ActivitiesColumns.occasion]);
      expect(grid.weeks.map((w) => w.type), [
        ActivitiesWeekType.teaching,
        ActivitiesWeekType.holiday,
        ActivitiesWeekType.exam,
      ]);
      expect(grid.weeks[1].week, isNull);
      expect(grid.weeks[1].title, 'إجازة عيد الفطر');
    });

    test('a teaching week edits every column, an exam week only the occasions, a holiday none', () {
      expect(grid.columnsOf(grid.weeks[0]).map((c) => c.key), ['citizenship', 'occasion']);
      expect(grid.columnsOf(grid.weeks[2]).map((c) => c.key), ['occasion']);
      expect(grid.columnsOf(grid.weeks[1]), isEmpty);
    });

    test('the Hijri range is shown when both dates exist, else the Gregorian', () {
      expect(grid.weeks[0].hijriRange, '09-08-1448 – 13-08-1448');
      expect(grid.weeks[2].hijriRange, isNull);
      expect(grid.weeks[2].gregorianRange, '2027-05-30 – 2027-06-03');
    });

    test('finds a week by number', () {
      expect(grid.weekNumber(19)?.title, 'اختبارات نهائية');
      expect(grid.weekNumber(4), isNull);
    });

    test('an unknown region is unverified only when the API says so', () {
      expect(ActivitiesGridModel.fromJson(const {'region_verified': false}).regionVerified, isFalse);
      expect(ActivitiesGridModel.fromJson(const {}).regionVerified, isTrue);
    });
  });

  test('ActivitiesCatalogueModel reads stages and domains', () {
    final catalogue = ActivitiesCatalogueModel.fromJson(const {
      'stages': [
        {'key': 'primary', 'label': 'ابتدائي', 'name': 'المرحلة الابتدائية'},
      ],
      'domains': [
        {'key': 'citizenship', 'label': 'المواطنة والحياة'},
      ],
    });

    expect(catalogue.stages.single.name, 'المرحلة الابتدائية');
    expect(catalogue.domainLabel('citizenship'), 'المواطنة والحياة');
    expect(catalogue.domainLabel('missing'), 'missing');
  });

  group('ActivitiesPlanInput', () {
    test('reads the saved input with its changed cells and extra fields', () {
      final input = ActivitiesPlanInput.fromJson(const {
        'stage': 'primary',
        'domains': ['citizenship', 'sports_health'],
        'term': '2',
        'region': '',
        'activity_leader': ' نورة ',
        'cells': {
          '3': {'citizenship': 'نشاطي', 'occasion': null},
          'x': {'citizenship': 'يتجاهل'},
        },
        'date_hijri': 'يُحفظ',
      });

      expect(input.term, 2);
      expect(input.region, isNull);
      expect(input.activityLeader, 'نورة');
      expect(input.cells, {
        3: {'citizenship': 'نشاطي', 'occasion': ''},
      });
      expect(input.extra, {'date_hijri': 'يُحفظ'});
    });

    test('toJson sends the changed cells keyed by week, and empties as ""', () {
      const input = ActivitiesPlanInput(
        stage: 'primary',
        domains: ['citizenship'],
        term: 1,
        region: ActivitiesPlanInput.western,
        cells: {
          3: {'citizenship': 'نشاطي\nسطر ثان', 'occasion': ''},
          4: {},
        },
        extra: {'date_hijri': 'يُحفظ'},
      );
      final json = input.toJson();

      expect(json['region'], 'western');
      expect(json['cells'], {
        '3': {'citizenship': 'نشاطي\nسطر ثان', 'occasion': ''},
      });
      expect(json['date_hijri'], 'يُحفظ');
      expect(json.containsKey('activity_leader'), isFalse);
    });

    test('no region is left out, so the teacher calendar is used', () {
      const input = ActivitiesPlanInput(stage: 'primary', domains: ['citizenship'], term: 1);

      expect(input.toJson().containsKey('region'), isFalse);
      expect(input.toJson().containsKey('cells'), isFalse);
    });
  });
}
