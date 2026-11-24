import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_plan_input.dart';

const _catalogueJson = {
  'bands': [
    {'key': 'primary_early', 'label': 'الصفوف الأولية (1–3)', 'periods_per_year': 108, 'periods_per_week': 3},
  ],
  'programs': [
    {
      'key': 'citizenship',
      'label': 'المواطنة والحياة',
      'programs': [
        {
          'key': 'volunteering',
          'label': 'التطوع الطلابي',
          'periods': {'primary_early': 4, 'intermediate': 5},
          'outside_hours': false,
        },
        {
          'key': 'values',
          'label': 'قيمنا حياة',
          'periods': {'primary_early': 0, 'intermediate': 12},
          'outside_hours': false,
        },
      ],
    },
    {
      'key': 'scouts',
      'label': 'النشاط الكشفي',
      'programs': [
        {
          'key': 'navigation',
          'label': 'الملاحة على اليابس',
          'periods': {'primary_early': 0, 'intermediate': 3},
          'outside_hours': true,
        },
      ],
    },
  ],
  'occasions_domain': {'key': 'occasions', 'label': 'الأيام والمناسبات'},
  'extracurricular': [
    {'key': 'success_journey', 'label': 'رحلة نجاح', 'periods': {'primary_early': 11}},
  ],
  'official_days': [
    {'key': 'national_day', 'name': 'اليوم الوطني', 'date': '09-23', 'periods': {'primary_early': 4, 'intermediate': 4}},
    {'key': 'children_day', 'name': 'اليوم العالمي للطفل', 'date': '11-20', 'periods': {'primary_early': 2, 'intermediate': 0}},
  ],
  'ein_url': 'https://www.ien.edu.sa/#/studentactivities',
  'stages': [],
  'domains': [],
};

void main() {
  group('ActivitiesCatalogueModel (official)', () {
    final catalogue = ActivitiesCatalogueModel.fromJson(_catalogueJson);

    test('reads the bands, programs, non-class programs, days and the Ein link', () {
      expect(catalogue.bands.single.periodsPerWeek, 3);
      expect(catalogue.programDomains.map((d) => d.key), ['citizenship', 'scouts']);
      expect(catalogue.programDomains.first.programs.first.periodsFor('intermediate'), 5);
      expect(catalogue.programDomains.last.programs.single.outsideHours, isTrue);
      expect(catalogue.extracurricular.single.key, 'success_journey');
      expect(catalogue.officialDays, hasLength(2));
      expect(catalogue.einUrl, 'https://www.ien.edu.sa/#/studentactivities');
      expect(catalogue.bandOf('primary_early')?.label, 'الصفوف الأولية (1–3)');
      expect(catalogue.bandOf('missing'), isNull);
    });

    test('the domain picker offers the 5 domains then «الأيام والمناسبات»', () {
      expect(catalogue.officialDomains.map((d) => d.key), ['citizenship', 'scouts', 'occasions']);
      expect(catalogue.officialDomainLabel('occasions'), 'الأيام والمناسبات');
      expect(catalogue.officialDomainLabel('unknown'), 'unknown');
    });

    test('a band never sees a program with 0 periods for it', () {
      expect(catalogue.programOptions('citizenship', 'primary_early').map((p) => p.label), ['التطوع الطلابي']);
      expect(catalogue.programOptions('citizenship', 'intermediate').map((p) => p.label), ['التطوع الطلابي', 'قيمنا حياة']);
      expect(catalogue.programOptions('scouts', 'primary_early'), isEmpty);
      expect(catalogue.programOptions('scouts', 'intermediate').single.outsideHours, isTrue);
      expect(catalogue.programOptions('citizenship', null), isEmpty);
    });

    test('«الأيام والمناسبات» offers the official days with periods for the band', () {
      final options = catalogue.programOptions('occasions', 'intermediate');
      expect(options.map((o) => o.label), ['اليوم الوطني']);
      expect(options.single.periods, 4);
      expect(catalogue.programOptions('occasions', 'primary_early'), hasLength(2));
    });

    test('a program outside the list is a local program; «(تابع)» and joined days are still official', () {
      expect(catalogue.isOfficialProgram('التطوع الطلابي'), isTrue);
      expect(catalogue.isOfficialProgram('التطوع الطلابي (تابع)'), isTrue);
      expect(catalogue.isOfficialProgram('اليوم الوطني، اليوم العالمي للطفل'), isTrue);
      expect(catalogue.isOfficialProgram('برنامج المدرسة'), isFalse);
      expect(ActivitiesCatalogueModel.baseProgram('التطوع الطلابي (تابع)'), 'التطوع الطلابي');
    });

    test('the non-class program is stored by key and shown by label', () {
      expect(catalogue.extracurricularLabel('success_journey'), 'رحلة نجاح');
      expect(catalogue.extracurricularLabel('other'), 'other');
    });

    test('an old catalogue without the official fields still reads', () {
      final old = ActivitiesCatalogueModel.fromJson(const {'stages': [], 'domains': []});
      expect(old.bands, isEmpty);
      expect(old.occasionsDomain.key, ActivitiesCatalogueModel.occasionsKey);
      expect(old.einUrl, isEmpty);
    });
  });

  group('ActivitiesGridModel (official)', () {
    test('reads the summary and finds a column label', () {
      final grid = ActivitiesGridModel.fromJson(const {
        'term': 1,
        'region': 'general',
        'columns': [
          {'key': 'domain', 'label': 'المجال'},
        ],
        'weeks': [],
        'summary': {
          'domains': [
            {'key': 'citizenship', 'label': 'المواطنة والحياة', 'periods': 10},
          ],
          'total': 47,
          'target': 54,
        },
      });

      expect(grid.summary?.total, 47);
      expect(grid.summary?.target, 54);
      expect(grid.summary?.domains.single.periods, 10);
      expect(grid.columnLabel('domain'), 'المجال');
      expect(grid.columnLabel('program'), 'program');
    });

    test('the old grid has no summary', () {
      expect(ActivitiesGridModel.fromJson(const {'term': 1}).summary, isNull);
    });
  });

  group('ActivitiesPlanInput (official)', () {
    test('toJson sends layout, band and periods per week, and no stage or domains', () {
      const input = ActivitiesPlanInput(
        layout: ActivitiesPlanInput.official,
        band: 'primary_early',
        periodsPerWeek: 3,
        term: 1,
        cells: {
          2: {'program': 'الخط العربي', 'periods': '2'},
        },
      );
      final json = input.toJson();

      expect(json['layout'], 'official');
      expect(json['band'], 'primary_early');
      expect(json['periods_per_week'], 3);
      expect(json.containsKey('stage'), isFalse);
      expect(json.containsKey('domains'), isFalse);
      expect(json['cells'], {
        '2': {'program': 'الخط العربي', 'periods': '2'},
      });
    });

    test('an empty periods per week is left out, so the band default applies', () {
      const input = ActivitiesPlanInput(layout: ActivitiesPlanInput.official, band: 'secondary', term: 1);
      expect(input.toJson().containsKey('periods_per_week'), isFalse);
    });

    test('reads a saved official input, and keeps layout out of the extra fields', () {
      final input = ActivitiesPlanInput.fromJson(const {
        'layout': 'official',
        'band': 'secondary',
        'periods_per_week': '2',
        'term': 1,
        'date_hijri': 'يُحفظ',
      });

      expect(input.isOfficial, isTrue);
      expect(input.band, 'secondary');
      expect(input.periodsPerWeek, 2);
      expect(input.extra, {'date_hijri': 'يُحفظ'});
    });

    test('an input without a layout is the old one and stays old when saved again', () {
      final input = ActivitiesPlanInput.fromJson(const {
        'stage': 'primary',
        'domains': ['citizenship'],
        'term': 1,
      });
      final json = input.toJson();

      expect(input.isOfficial, isFalse);
      expect(json.containsKey('layout'), isFalse);
      expect(json.containsKey('band'), isFalse);
      expect(json['stage'], 'primary');
      expect(json['domains'], ['citizenship']);
    });
  });
}
