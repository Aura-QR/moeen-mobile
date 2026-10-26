import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/data/models/report_input.dart';
import 'package:moean/features/reports/data/models/role_ai_merge.dart';

void main() {
  group('mergeRoleAiResult', () {
    test('replaces title & blocks, preserves typed meta/kv where AI is empty, copies placed photos, keeps theme & signatures', () {
      var id = 10;
      int nextId() => ++id;

      const current = ReportInput(
        template: 'role_doc',
        title: 'تقرير مبدئي',
        meta: [
          ReportMetaRow(1, label: 'المدرسة', value: 'مدرسة الفيصل'),
          ReportMetaRow(2, label: 'التاريخ', value: '2026-10-20'),
        ],
        blocks: [
          KvBlock(
            3,
            pairs: [
              ReportPair(label: 'المستهدفون', value: 'الصف السادس'),
              ReportPair(label: 'عدد المشاركين', value: '28'),
            ],
          ),
          ImagesBlock(4, items: ['documents/p1.jpg', 'documents/p2.jpg'], columns: 2),
        ],
        signatures: [ReportSignature(title: 'رائد النشاط', name: 'أحمد')],
        theme: DocumentTheme.blue,
      );

      final aiResult = <String, dynamic>{
        'title': 'تقرير تنفيذ يوم المهنة',
        'meta': [
          {'label': 'المدرسة', 'value': ''},
          {'label': 'التاريخ', 'value': '2026-10-26'},
        ],
        'blocks': [
          {'kind': 'heading', 'text': 'ملخص البرنامج'},
          {
            'kind': 'kv',
            'pairs': [
              {'label': 'المستهدفون', 'value': 'طلاب الصفوف العليا'},
              {'label': 'عدد المشاركين', 'value': ''},
            ],
          },
          {'kind': 'images', 'items': <String>[], 'columns': 3},
        ],
      };

      final merged = mergeRoleAiResult(
        current: current,
        currentTitle: current.title,
        result: aiResult,
        nextId: nextId,
      );

      expect(merged.title, 'تقرير تنفيذ يوم المهنة');
      expect(merged.meta[0].value, 'مدرسة الفيصل');
      expect(merged.meta[1].value, '2026-10-26');

      final kv = merged.blocks[1] as KvBlock;
      expect(kv.pairs[0].value, 'طلاب الصفوف العليا');
      expect(kv.pairs[1].value, '28');

      final images = merged.blocks[2] as ImagesBlock;
      expect(images.items, ['documents/p1.jpg', 'documents/p2.jpg']);
      expect(images.columns, 3);

      expect(merged.signatures.single.name, 'أحمد');
      expect(merged.theme, DocumentTheme.blue);
    });
  });

  group('fillNamesColumn', () {
    test('fills names_column from the first empty cell, adds rows up to maxRows (40), and preserves other columns', () {
      const table = TableBlock(
        1,
        columns: ['م', 'اسم الطالب', 'اللجنة'],
        rows: [
          ['1', 'خالد', 'الإعلامية'],
          ['2', '', 'الثقافية'],
        ],
        namesColumn: 1,
      );

      final colIndex = resolveNamesColumnIndex(table.namesColumn, table.columns);
      expect(colIndex, 1);

      final filled = table.fillNamesColumn(colIndex!, ['سعد', 'فهد', 'عمر'], 40);
      expect(filled.rows, hasLength(4));
      expect(filled.rows[0], ['1', 'خالد', 'الإعلامية']);
      expect(filled.rows[1], ['2', 'سعد', 'الثقافية']);
      expect(filled.rows[2], ['', 'فهد', '']);
      expect(filled.rows[3], ['', 'عمر', '']);

      final capped = table.fillNamesColumn(
        colIndex,
        [for (var i = 0; i < 60; i++) 'طالب $i'],
        40,
      );
      expect(capped.rows, hasLength(40));
    });
  });
}
