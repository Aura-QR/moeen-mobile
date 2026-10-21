import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/curriculum/data/services/semester_plan_content.dart';

import 'semester_plan_test_data.dart';

void main() {
  SemesterPlanContent build({bool isArabic = true, String school = 'الحريه', String teacher = 'azza'}) =>
      SemesterPlanContent.from(samplePlan(),
          school: school, teacher: teacher, isArabic: isArabic, translate: fakeTranslate);

  test('Arabic rows use Arabic-Indic digits and two date lines', () {
    final row = build().rows.first;
    expect(row.week, '٥');
    expect(row.dateFirstLine, 'من ٢٠٢٦/٠٩/٢٠ إلى');
    expect(row.dateSecondLine, '٢٠٢٦/٠٩/٢٤');
  });

  test('English keeps Western digits', () {
    expect(build(isArabic: false).rows.first.dateSecondLine, '2026/09/24');
  });

  test('lessons are "unit — title", joined by the comma of their language', () {
    final rows = build().rows;
    expect(rows[0].lessons, 'الأعداد الصحيحة — التهيئة، الأعداد الصحيحة — القيمة المطلقة');
    expect(rows[2].lessons, 'Is There A View? — Grammar, Is There A View? — Listening & Pronunciation');
  });

  test('a holiday is one break row with its dates', () {
    final row = build().rows[1];
    expect(row.isBreak, isTrue);
    expect(row.breakText, 'إجازة الخريف   |   من ٢٠٢٦/١١/٢٢ إلى ٢٠٢٦/١١/٢٦');
  });

  test('an exam week without a title falls back to the exams label', () {
    expect(build().rows.last.breakText, startsWith('اختبارات'));
  });

  test('empty lessons and notes print a dash', () {
    final row = build().rows[3];
    expect(row.lessons, '—');
    expect(row.notes, '—');
  });

  test('the people line is left out when nothing was entered', () {
    expect(build(school: '', teacher: '').peopleLine, isNull);
  });

  test('the year falls back to 1448 and the file is named after the subject', () {
    final content = build();
    expect(content.termLine, contains('١٤٤٨'));
    expect(content.fileBaseName, 'الخطة الفصلية - الرياضيات');
  });
}
