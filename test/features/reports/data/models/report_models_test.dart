import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/data/models/report_field_error.dart';
import 'package:moean/features/reports/data/models/report_input.dart';

void main() {
  group('ReportBlock', () {
    test('every kind round-trips', () {
      final blocks = <Map<String, dynamic>>[
        {'kind': 'heading', 'text': 'العنوان'},
        {'kind': 'paragraph', 'text': 'فقرة'},
        {'kind': 'list', 'items': ['أ', 'ب'], 'ordered': true},
        {'kind': 'checklist', 'items': ['تم']},
        {
          'kind': 'table',
          'columns': ['م', 'الاسم'],
          'rows': [
            ['1', 'سارة'],
          ],
          'widths': [1.0, 3.0],
          'compact': false,
        },
        {
          'kind': 'kv',
          'pairs': [
            {'label': 'المدرسة', 'value': 'الأولى'},
          ],
        },
        {
          'kind': 'columns',
          'columns': [
            {'heading': 'نقاط القوة', 'items': ['أ']},
            {'heading': 'التحسين', 'items': <String>[]},
          ],
        },
        {'kind': 'images', 'items': ['documents/1/a.jpg'], 'columns': 3},
        {
          'kind': 'chart',
          'chart': 'bar',
          'title': 'النتائج',
          'labels': ['أ', 'ب'],
          'series': [
            {
              'name': 'الفصل',
              'values': [3.0, 4.5],
            },
          ],
          'compact': true,
        },
        {'kind': 'qr', 'url': 'https://example.com', 'caption': 'امسح'},
        {'kind': 'page_break'},
      ];
      for (final (i, json) in blocks.indexed) {
        expect(ReportBlock.fromJson(json, i).toJson(), json, reason: json['kind'] as String);
      }
    });

    test('an unknown kind is sent back unchanged', () {
      final raw = {'kind': 'timeline', 'events': [1, 2]};
      final block = ReportBlock.fromJson(raw, 1);
      expect(block, isA<UnknownBlock>());
      expect(block.toJson(), raw);
    });

    test('a table squares its rows to the columns and drops stale widths', () {
      final table = TableBlock(1, columns: const ['أ', 'ب'], rows: const [
        ['1'],
        ['1', '2', '3'],
      ], widths: const [1, 2]);
      expect(table.toJson()['rows'], [
        ['1', ''],
        ['1', '2'],
      ]);
      expect(table.addColumn(8).toJson().containsKey('widths'), isFalse);
    });

    test('a chart pads its values to the labels', () {
      const chart = ChartBlock(1, labels: ['أ', 'ب', 'ج'], series: [ReportSeries(name: 'س', values: [5])]);
      expect((chart.toJson()['series'] as List).first['values'], [5.0, 0.0, 0.0]);
    });

    test('new blocks have what the server requires', () {
      expect((ReportBlock.empty('table', 1) as TableBlock).columns, hasLength(2));
      expect((ReportBlock.empty('columns', 1) as ColumnsBlock).columns, hasLength(2));
      expect((ReportBlock.empty('chart', 1) as ChartBlock).series, hasLength(1));
    });
  });

  group('edits', () {
    test('lines respect the limit and move to the final position', () {
      expect(['أ'].addLine(' ب ', 2), ['أ', 'ب']);
      expect(['أ', 'ب'].addLine('ج', 2), ['أ', 'ب']);
      expect(['أ', 'ب', 'ج'].moveLine(0, 2), ['ب', 'ج', 'أ']);
    });

    test('a table keeps one column', () {
      final table = TableBlock(1, columns: const ['أ'], rows: const [
        ['1'],
      ]);
      expect(table.removeColumn(0), table);
      expect(table.addColumn(8).addRow(40).squaredRows, [
        ['1', ''],
        ['', ''],
      ]);
    });

    test('columns stay between two and three', () {
      final block = ReportBlock.empty('columns', 1) as ColumnsBlock;
      expect(block.setCount(3).columns, hasLength(3));
      expect(block.setCount(3).setCount(1).columns, hasLength(2));
    });

    test('chart values accept Arabic digits and refuse negatives', () {
      final chart = (ReportBlock.empty('chart', 1) as ChartBlock).setLabels(['أ', 'ب', 'ج']);
      expect(chart.setSeries(0, ' س ', ['٤٫٥', '-2', 'x']).series.first, const ReportSeries(name: 'س', values: [4.5, 0, 0]));
    });

    test('images toggle in and out', () {
      const block = ImagesBlock(1);
      expect(block.toggle('a').items, ['a']);
      expect(block.toggle('a').toggle('a').items, isEmpty);
    });

    test('only https links with a host pass', () {
      expect(isHttpsUrl('https://example.com/x'), isTrue);
      expect(isHttpsUrl('http://example.com'), isFalse);
      expect(isHttpsUrl('https://'), isFalse);
    });
  });

  group('ReportInput', () {
    test('keeps keys it does not edit and drops untitled signatures', () {
      var id = 0;
      final input = ReportInput.fromJson({
        'template': 'lesson',
        'title': ' تقرير ',
        'meta': [
          {'label': 'المادة', 'value': 'علوم'},
        ],
        'blocks': [
          {'kind': 'heading', 'text': 'أ'},
        ],
        'signatures': [
          {'title': 'المعلم', 'name': ''},
          {'title': ' ', 'name': 'x'},
        ],
        'images': ['p.jpg'],
        'future_key': 1,
      }, () => ++id);

      final json = input.toJson();
      expect(json['future_key'], 1);
      expect(json['template'], 'lesson');
      expect(json['title'], 'تقرير');
      expect(json['signatures'], [
        {'title': 'المعلم', 'name': ''},
      ]);
      expect(input.meta.first.id != input.blocks.first.id, isTrue);
    });
  });

  group('ReportFieldError', () {
    test('points at the block or the title', () {
      expect(ReportFieldError.parse('input.blocks.3.items.0', ['خطأ'])!.blockIndex, 3);
      expect(ReportFieldError.parse('blocks.0', 'خطأ')!.message, 'خطأ');
      expect(ReportFieldError.parse('input.title', ['مطلوب'])!.isTitle, isTrue);
      expect(ReportFieldError.parse('input.images.0', ['x']), isNull);
    });
  });
}
