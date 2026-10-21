import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:moean/core/utils/formatters/text_direction_detector.dart';
import 'package:moean/features/curriculum/data/services/semester_plan_content.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// «الخطة الفصلية» as a Word (.docx) file, with the same layout as the PDF:
/// A4 landscape, a header row that repeats on every page, and holiday and
/// exam weeks as merged shaded rows. Arabic tables run right to left.
class SemesterPlanWordService {
  static const String mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  static const String _green = '0B7F61';
  static const String _greenDark = '0A6B50';
  static const String _breakBg = 'EAF4EF';
  static const String _border = 'D5E6DF';
  static const String _ink = '1F2937';
  static const String _muted = '6B7280';
  static const String _font = 'Arial';

  /// A4 landscape in twips, with 0.5" margins.
  static const int _pageWidth = 16838;
  static const int _pageHeight = 11906;
  static const int _margin = 720;

  /// Week, date, lessons, notes, in reading order.
  static const List<double> _columnFlex = [0.7, 2, 9, 1.1];

  static Uint8List build(SemesterPlanContent content) {
    final archive = Archive();
    void add(String path, String xml) {
      final bytes = utf8.encode(xml);
      archive.addFile(ArchiveFile(path, bytes.length, bytes));
    }

    add('[Content_Types].xml', _contentTypes);
    add('_rels/.rels', _rootRels);
    add('word/_rels/document.xml.rels', _documentRels);
    add('word/styles.xml', _styles);
    add('word/document.xml', _document(content));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  /// Writes the file to the temp folder and opens the share sheet.
  static Future<void> share(SemesterPlanContent content, {required String fileName}) async {
    final directory = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${directory.path}/$safeName');
    await file.writeAsBytes(build(content));
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: mimeType, name: safeName)],
    ));
  }

  static String _document(SemesterPlanContent content) {
    final rtl = content.isArabic;
    final usable = _pageWidth - 2 * _margin;
    final totalFlex = _columnFlex.reduce((a, b) => a + b);
    final widths = [for (final flex in _columnFlex) (usable * flex / totalFlex).round()];
    // Visual side of the page where text starts: right in Arabic.
    final start = rtl ? 'right' : 'left';
    final end = rtl ? 'left' : 'right';

    final body = StringBuffer()
      ..write(_paragraph(content.title, rtl: rtl, align: 'center', bold: true, size: 36, color: _green))
      ..write(_paragraph(content.subjectLine, rtl: rtl, align: 'center', bold: true, size: 22, color: _ink))
      ..write(_paragraph(content.termLine, rtl: rtl, align: 'center', size: 19, color: _muted));
    if (content.peopleLine != null) {
      body.write(_paragraph(content.peopleLine!, rtl: rtl, align: end, size: 19, color: _muted, spaceAfter: 240));
    }

    body
      ..write('<w:tbl><w:tblPr>')
      ..write(rtl ? '<w:bidiVisual/>' : '')
      ..write('<w:tblW w:w="$usable" w:type="dxa"/><w:tblLayout w:type="fixed"/>')
      ..write('<w:tblBorders>')
      ..write(['top', 'left', 'bottom', 'right', 'insideH', 'insideV']
          .map((side) => '<w:$side w:val="single" w:sz="4" w:space="0" w:color="$_border"/>')
          .join())
      ..write('</w:tblBorders>')
      ..write('<w:tblCellMar><w:top w:w="120" w:type="dxa"/><w:left w:w="120" w:type="dxa"/>'
          '<w:bottom w:w="120" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tblCellMar>')
      ..write('</w:tblPr><w:tblGrid>')
      ..write(widths.map((w) => '<w:gridCol w:w="$w"/>').join())
      ..write('</w:tblGrid>')
      // Header row, repeated at the top of every page.
      ..write('<w:tr><w:trPr><w:tblHeader/><w:cantSplit/></w:trPr>');
    for (var i = 0; i < content.headers.length; i++) {
      body.write(_cell(
        [_paragraph(content.headers[i], rtl: rtl, align: start, bold: true, size: 20, color: 'FFFFFF')],
        width: widths[i],
        fill: _green,
      ));
    }
    body.write('</w:tr>');

    for (final row in content.rows) {
      body.write('<w:tr><w:trPr><w:cantSplit/></w:trPr>');
      if (row.isBreak) {
        body.write(_cell(
          [_paragraph(row.breakText, rtl: rtl, align: 'center', bold: true, size: 20, color: _greenDark)],
          width: usable,
          fill: _breakBg,
          span: content.headers.length,
        ));
      } else {
        // Lessons and notes follow their own language, aligned to the page side.
        String contentCell(String text) =>
            _paragraph(text, rtl: isRtlText(text, fallback: rtl), align: start, size: 18, color: _ink);
        body
          ..write(_cell([_paragraph(row.week, rtl: rtl, align: 'center', size: 18, color: _ink)], width: widths[0]))
          ..write(_cell([
            _paragraph(row.dateFirstLine, rtl: rtl, align: start, size: 18, color: _ink),
            _paragraph(row.dateSecondLine, rtl: rtl, align: start, size: 18, color: _ink),
          ], width: widths[1]))
          ..write(_cell([contentCell(row.lessons)], width: widths[2]))
          ..write(_cell([contentCell(row.notes)], width: widths[3]));
      }
      body.write('</w:tr>');
    }
    body.write('</w:tbl>');

    const gap = '          ';
    body.write(_paragraph(
      '${content.teacherSignature}$gap${content.principalSignature}',
      rtl: rtl,
      align: start,
      bold: true,
      size: 20,
      color: _ink,
      spaceBefore: 480,
    ));

    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>'
        '$body'
        '<w:sectPr><w:pgSz w:w="$_pageWidth" w:h="$_pageHeight" w:orient="landscape"/>'
        '<w:pgMar w:top="$_margin" w:right="$_margin" w:bottom="$_margin" w:left="$_margin" '
        'w:header="360" w:footer="360" w:gutter="0"/>${rtl ? '<w:bidi/>' : ''}</w:sectPr>'
        '</w:body></w:document>';
  }

  static String _cell(List<String> paragraphs, {required int width, String? fill, int span = 1}) {
    return '<w:tc><w:tcPr><w:tcW w:w="$width" w:type="dxa"/>'
        '${span > 1 ? '<w:gridSpan w:val="$span"/>' : ''}'
        '${fill != null ? '<w:shd w:val="clear" w:color="auto" w:fill="$fill"/>' : ''}'
        '<w:vAlign w:val="center"/></w:tcPr>${paragraphs.join()}</w:tc>';
  }

  /// One paragraph. [align] is the visual side: `left`, `right` or `center`.
  /// In a right-to-left paragraph Word reads `w:jc` left/right as start/end,
  /// so the value is swapped there to keep the visual side.
  static String _paragraph(
    String text, {
    required bool rtl,
    required String align,
    required int size,
    required String color,
    bool bold = false,
    int spaceBefore = 0,
    int spaceAfter = 80,
  }) {
    final jc = !rtl || align == 'center' ? align : (align == 'right' ? 'left' : 'right');
    final runRtl = isRtlText(text, fallback: rtl);
    return '<w:p><w:pPr>${rtl ? '<w:bidi/>' : ''}'
        '<w:spacing w:before="$spaceBefore" w:after="$spaceAfter"/><w:jc w:val="$jc"/></w:pPr>'
        '<w:r><w:rPr><w:rFonts w:ascii="$_font" w:hAnsi="$_font" w:cs="$_font"/>'
        '${bold ? '<w:b/><w:bCs/>' : ''}<w:color w:val="$color"/>'
        '<w:sz w:val="$size"/><w:szCs w:val="$size"/>'
        '${runRtl ? '<w:rtl/>' : ''}<w:lang w:val="${runRtl ? 'ar-SA' : 'en-US'}" w:bidi="ar-SA"/></w:rPr>'
        '<w:t xml:space="preserve">${_escape(text)}</w:t></w:r></w:p>';
  }

  static String _escape(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static const String _contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
      '</Types>';

  static const String _rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
      '</Relationships>';

  static const String _documentRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '</Relationships>';

  static const String _styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="$_font" w:hAnsi="$_font" w:cs="$_font"/>'
      '<w:sz w:val="18"/><w:szCs w:val="18"/><w:lang w:val="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>'
      '<w:pPrDefault><w:pPr><w:spacing w:after="80" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>'
      '</w:docDefaults>'
      '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>'
      '</w:styles>';
}
