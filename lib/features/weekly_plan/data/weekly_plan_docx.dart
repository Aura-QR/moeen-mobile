import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:hijri/hijri_calendar.dart';

/// One period on the ministry's weekly plan sheet. A period the teacher has
/// not prepared yet keeps its row but stays blank, for them to fill by hand.
class WeeklyPlanLesson {
  const WeeklyPlanLesson({
    required this.dayOfWeek,
    required this.periodNumber,
    this.subject = '',
    this.topic = '',
  });

  /// 0 = Sunday … 4 = Thursday, as the backend numbers them.
  final int dayOfWeek;
  final int periodNumber;
  final String subject;
  final String topic;
}

class WeeklyPlanInput {
  const WeeklyPlanInput({
    required this.weekStart,
    required this.lessons,
    this.teacherName,
    this.grade,
  });

  /// Sunday of the week being planned.
  final DateTime weekStart;
  final List<WeeklyPlanLesson> lessons;
  final String? teacherName;
  final String? grade;
}

/// Builds the Ministry of Education's «خطة التعلم الأسبوعية للصفوف الأولية»
/// as a Word file, pre-filled from the teacher's own week.
///
/// The same sheet the Hader site exports (moeen_front
/// src/lib/weeklyPlanDocx.ts): the day, the subject and the prepared lesson
/// are filled in, and skills, homework and notes are left blank to write
/// into. The layout follows the ministry template because the filled sheet
/// is handed to a principal to sign.
class WeeklyPlanDocx {
  static const List<String> days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];

  static const List<String> _headings = [
    'اليوم / التاريخ',
    'المادة',
    'الدرس',
    'المهارات المستهدفة',
    'الواجب المنزلي',
    'الملاحظات',
  ];

  /// Relative column widths in percent, matching the template's proportions.
  static const List<int> _widths = [14, 12, 26, 22, 14, 12];

  /// Usable width of an A4 page with the sheet's margins, in twips.
  static const int _tableWidth = 10600;

  static const String _ink = '1F3864';
  static const String _shade = 'EAF0F8';

  /// Formats a date as "23/04 1448هـ" in the Umm al-Qura calendar, the one the
  /// ministry's own forms and Madrasati print.
  static String hijri(DateTime date) {
    final h = HijriCalendar.fromDate(date);
    final day = h.hDay.toString().padLeft(2, '0');
    final month = h.hMonth.toString().padLeft(2, '0');
    return '$day/$month ${h.hYear}هـ';
  }

  static Uint8List build(WeeklyPlanInput input) {
    final archive = Archive();
    void add(String name, String xml) {
      final bytes = utf8.encode(xml);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add('[Content_Types].xml', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>''');
    add('_rels/.rels', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''');
    add('word/_rels/document.xml.rels', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''');
    add('word/styles.xml', '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/>
        <w:sz w:val="20"/>
        <w:szCs w:val="20"/>
        <w:lang w:val="en-US" w:bidi="ar-SA"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
</w:styles>''');
    add('word/document.xml', _document(input));

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static String _document(WeeklyPlanInput input) {
    final body = StringBuffer()
      ..write(_line('الإدارة العامة للتعليم بمنطقة .............', size: 22))
      ..write(_line('الصفوف الأولية'))
      ..write(_line(
          'المدرسة : ..............................     الصف : ${_orDots(input.grade, '...............')}'))
      ..write(_line(''))
      ..write(_line('نموذج لخطة التعلم الأسبوعية للصفوف الأولية', bold: true, size: 26))
      ..write(_line('الأسبوع ..................'))
      ..write(_line(''))
      ..write(_table(input))
      ..write(_line(''))
      ..write(_line(''))
      ..write(_line('اسم معلم/ة المادة : ${_orDots(input.teacherName, '...............................')}'))
      ..write(_line('توقيع مدير/ة المدرسة : ...............................'));

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="640" w:right="640" w:bottom="640" w:left="640" w:header="0" w:footer="0" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>''';
  }

  // Cells are written in logical order (day first) and laid out right to left
  // by writing each row in reverse. Word's own right-to-left table setting
  // (bidiVisual) is ignored by Apple's document preview, which is what
  // teachers on iPhone open the file in, and the sheet came out mirrored.
  static String _row(List<String> cells, {bool header = false}) =>
      '<w:tr>${header ? '<w:trPr><w:tblHeader/></w:trPr>' : ''}${cells.reversed.join()}</w:tr>';

  static String _table(WeeklyPlanInput input) {
    final rows = StringBuffer();

    // Header row, repeated on every page.
    rows.write(_row([
      for (var i = 0; i < _headings.length; i++)
        _cell([_paragraph(_headings[i], bold: true, color: 'FFFFFF')], width: _widths[i], fill: _ink),
    ], header: true));

    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final date = input.weekStart.add(Duration(days: dayIndex));
      final dayLessons = input.lessons.where((l) => l.dayOfWeek == dayIndex).toList()
        ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

      // A day with no lessons still gets a row, so the sheet keeps the
      // template's shape and the teacher can write into it.
      final entries = dayLessons.isEmpty ? <WeeklyPlanLesson?>[null] : dayLessons;

      for (var position = 0; position < entries.length; position++) {
        final lesson = entries[position];
        rows.write(_row([
          // The day cell spans the day's rows: Word merges it vertically.
          position == 0
              ? _cell([
                  _paragraph(days[dayIndex], bold: true),
                  _paragraph(hijri(date), size: 18),
                ], width: _widths[0], fill: _shade, merge: entries.length > 1 ? 'restart' : null)
              : _cell([_paragraph('')], width: _widths[0], fill: _shade, merge: 'continue'),
          _cell([_paragraph(lesson?.subject ?? '')], width: _widths[1]),
          _cell([_paragraph(lesson?.topic ?? '')], width: _widths[2]),
          for (var blank = 3; blank < _widths.length; blank++) _cell([_paragraph('')], width: _widths[blank]),
        ]));
      }
    }

    final grid = _widths.reversed.map((w) => '<w:gridCol w:w="${_twips(w)}"/>').join();
    return '''<w:tbl>
  <w:tblPr>
    <w:tblW w:w="$_tableWidth" w:type="dxa"/>
    <w:jc w:val="center"/>
    <w:tblLayout w:type="fixed"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="6" w:color="$_ink"/>
      <w:left w:val="single" w:sz="6" w:color="$_ink"/>
      <w:bottom w:val="single" w:sz="6" w:color="$_ink"/>
      <w:right w:val="single" w:sz="6" w:color="$_ink"/>
      <w:insideH w:val="single" w:sz="4" w:color="9BB0CC"/>
      <w:insideV w:val="single" w:sz="4" w:color="9BB0CC"/>
    </w:tblBorders>
    <w:tblCellMar>
      <w:top w:w="60" w:type="dxa"/>
      <w:left w:w="80" w:type="dxa"/>
      <w:bottom w:w="60" w:type="dxa"/>
      <w:right w:w="80" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <w:tblGrid>$grid</w:tblGrid>
  $rows
</w:tbl>''';
  }

  static String _cell(List<String> paragraphs, {required int width, String? fill, String? merge}) {
    final mergeXml = merge == null
        ? ''
        : merge == 'restart'
            ? '<w:vMerge w:val="restart"/>'
            : '<w:vMerge/>';
    final fillXml = fill == null ? '' : '<w:shd w:val="clear" w:color="auto" w:fill="$fill"/>';
    return '<w:tc><w:tcPr><w:tcW w:w="${_twips(width)}" w:type="dxa"/>$mergeXml$fillXml'
        '<w:vAlign w:val="center"/></w:tcPr>${paragraphs.join()}</w:tc>';
  }

  static int _twips(int percent) => (_tableWidth * percent / 100).round();

  static String _paragraph(String text, {bool bold = false, int size = 20, String? color}) {
    final boldXml = bold ? '<w:b/><w:bCs/>' : '';
    final colorXml = color == null ? '' : '<w:color w:val="$color"/>';
    return '<w:p><w:pPr><w:bidi/><w:spacing w:before="40" w:after="40"/><w:jc w:val="center"/></w:pPr>'
        '<w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/>$boldXml$colorXml'
        '<w:sz w:val="$size"/><w:szCs w:val="$size"/><w:rtl/></w:rPr>'
        '<w:t xml:space="preserve">${_escape(text)}</w:t></w:r></w:p>';
  }

  static String _line(String text, {bool bold = false, int size = 20}) =>
      _paragraph(text, bold: bold, size: size);

  static String _orDots(String? value, String dots) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? dots : trimmed;
  }

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
