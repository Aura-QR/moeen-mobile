import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/weekly_plan/data/weekly_plan_docx.dart';

/// The weekly plan sheet is handed to a principal to sign, so it has to open
/// in Word with the ministry's layout: every teaching day present, the Hijri
/// date Madrasati prints, and only prepared lessons filled in.
void main() {
  final sunday = DateTime(2026, 10, 4);

  String documentXml(WeeklyPlanInput input) {
    final archive = ZipDecoder().decodeBytes(WeeklyPlanDocx.build(input));
    final file = archive.findFile('word/document.xml')!;
    return utf8.decode(file.content as List<int>);
  }

  test('dates match the Hijri period Madrasati shows for the week', () {
    expect(WeeklyPlanDocx.hijri(sunday), '23/04 1448هـ');
    expect(WeeklyPlanDocx.hijri(sunday.add(const Duration(days: 4))), '27/04 1448هـ');
  });

  test('every teaching day gets a row, even with no lessons', () {
    final xml = documentXml(WeeklyPlanInput(weekStart: sunday, lessons: const []));
    for (final day in WeeklyPlanDocx.days) {
      expect(xml, contains('>$day<'));
    }
  });

  test('a day with several periods merges its day cell', () {
    final xml = documentXml(WeeklyPlanInput(
      weekStart: sunday,
      lessons: const [
        WeeklyPlanLesson(dayOfWeek: 1, periodNumber: 2, subject: 'الرياضيات', topic: 'الأنماط'),
        WeeklyPlanLesson(dayOfWeek: 1, periodNumber: 1),
      ],
    ));
    expect('w:vMerge w:val="restart"'.allMatches(xml).length, 1);
    expect('<w:vMerge/>'.allMatches(xml).length, 1);
    expect(xml, contains('>الأنماط<'));
  });

  test('the day column is the rightmost, whatever app opens the file', () {
    final xml = documentXml(WeeklyPlanInput(weekStart: sunday, lessons: const []));
    final header = RegExp(r'<w:tr><w:trPr><w:tblHeader/>.*?</w:tr>').firstMatch(xml)!.group(0)!;
    final headings = RegExp(r'<w:t xml:space="preserve">([^<]*)</w:t>').allMatches(header).map((m) => m.group(1)).toList();
    expect(headings.first, 'الملاحظات');
    expect(headings.last, 'اليوم / التاريخ');
  });

  test('text is escaped', () {
    final xml = documentXml(WeeklyPlanInput(
      weekStart: sunday,
      teacherName: 'أ. <سارة> & فريقها',
      lessons: const [],
    ));
    expect(xml, contains('أ. &lt;سارة&gt; &amp; فريقها'));
  });

  test('writes a file macOS can open as a Word document', () async {
    if (!Platform.isMacOS) return;
    final dir = await Directory.systemTemp.createTemp('weekly_plan');
    final docx = File('${dir.path}/plan.docx')
      ..writeAsBytesSync(WeeklyPlanDocx.build(WeeklyPlanInput(
        weekStart: sunday,
        lessons: const [WeeklyPlanLesson(dayOfWeek: 0, periodNumber: 1, subject: 'الرياضيات', topic: 'التهيئة')],
      )));
    final result = await Process.run('textutil', ['-convert', 'txt', '-stdout', docx.path]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout as String, contains('التهيئة'));
    expect(result.stdout as String, contains('نموذج لخطة التعلم الأسبوعية'));
  });
}
