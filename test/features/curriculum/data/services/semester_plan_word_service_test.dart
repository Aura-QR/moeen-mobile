import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/curriculum/data/services/semester_plan_content.dart';
import 'package:moean/features/curriculum/data/services/semester_plan_word_service.dart';

import 'semester_plan_test_data.dart';

void main() {
  String documentXml({required bool isArabic}) {
    final content = SemesterPlanContent.from(samplePlan(),
        school: 'الحريه', teacher: 'azza', isArabic: isArabic, translate: fakeTranslate);
    final archive = ZipDecoder().decodeBytes(SemesterPlanWordService.build(content));
    expect(
      archive.files.map((f) => f.name),
      containsAll(['[Content_Types].xml', '_rels/.rels', 'word/_rels/document.xml.rels', 'word/styles.xml', 'word/document.xml']),
    );
    return utf8.decode(archive.findFile('word/document.xml')!.content as List<int>);
  }

  test('Arabic runs the table and the section right to left', () {
    final xml = documentXml(isArabic: true);
    expect(xml, contains('<w:bidiVisual/>'));
    expect(xml, contains('<w:bidi/></w:sectPr>'));
  });

  test('English runs left to right', () {
    final xml = documentXml(isArabic: false);
    expect(xml, isNot(contains('<w:bidiVisual/>')));
    expect(xml, isNot(contains('<w:bidi/></w:sectPr>')));
  });

  test('pages are landscape and the header row repeats', () {
    final xml = documentXml(isArabic: true);
    expect(xml, contains('w:orient="landscape"'));
    expect(xml, contains('<w:tblHeader/>'));
  });

  test('holiday and exam weeks are one merged shaded row each', () {
    final xml = documentXml(isArabic: true);
    expect('<w:gridSpan w:val="4"/>'.allMatches(xml).length, 2);
    expect(xml, contains('إجازة الخريف'));
  });

  test('text is escaped for XML', () {
    expect(documentXml(isArabic: true), contains('Listening &amp; Pronunciation'));
  });
}
