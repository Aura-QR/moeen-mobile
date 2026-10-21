import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:moean/core/utils/formatters/text_direction_detector.dart';
import 'package:moean/features/curriculum/data/services/semester_plan_content.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// «الخطة الفصلية» as PDF, matching the website's export: a centered header,
/// one table row per week (its header repeats on every page), holiday and
/// exam weeks as full-width shaded rows, and signature lines at the end.
/// Arabic prints right to left; English left to right.
class SemesterPlanPdfService {
  static final PdfColor _green = PdfColor.fromHex('0B7F61');
  static final PdfColor _greenDark = PdfColor.fromHex('0A6B50');
  static final PdfColor _breakBg = PdfColor.fromHex('EAF4EF');
  static final PdfColor _border = PdfColor.fromHex('D5E6DF');
  static final PdfColor _ink = PdfColor.fromHex('1F2937');
  static final PdfColor _muted = PdfColor.fromHex('6B7280');

  /// Week, date, lessons, notes, in reading order.
  static const List<double> _columnFlex = [0.7, 2, 9, 1.1];

  static Future<Uint8List> build(SemesterPlanContent content) async {
    // IBM Plex Sans Arabic: clear Arabic-Indic digits and good Latin, for
    // English subjects.
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'));
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    final direction = content.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      textDirection: direction,
      // The page title is on the first page only; later pages restart with
      // the table header.
      header: (context) => context.pageNumber == 1 ? pw.SizedBox() : _tableHeader(content),
      build: (_) => [
        _title(content),
        pw.SizedBox(height: 18),
        _tableHeader(content),
        for (final row in content.rows) row.isBreak ? _breakRow(row) : _weekRow(row, content),
        pw.SizedBox(height: 24),
        pw.Row(children: [
          pw.Text(content.teacherSignature, style: _signatureStyle),
          pw.SizedBox(width: 48),
          pw.Text(content.principalSignature, style: _signatureStyle),
        ]),
      ],
    ));

    return doc.save();
  }

  static pw.TextStyle get _signatureStyle =>
      pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _ink);

  static pw.Widget _title(SemesterPlanContent content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          content.title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _green),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          content.subjectLine,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _ink),
        ),
        pw.SizedBox(height: 6),
        pw.Text(content.termLine, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9.5, color: _muted)),
        if (content.peopleLine != null) ...[
          pw.SizedBox(height: 10),
          pw.Text(content.peopleLine!, textAlign: pw.TextAlign.end, style: pw.TextStyle(fontSize: 9.5, color: _muted)),
        ],
      ],
    );
  }

  static pw.Widget _tableHeader(SemesterPlanContent content) {
    return _row(
      [
        for (final header in content.headers)
          pw.Text(header, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
      ],
      isArabic: content.isArabic,
      background: _green,
      borderColor: PdfColors.white,
      top: true,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 14),
    );
  }

  static pw.Widget _weekRow(SemesterPlanRow row, SemesterPlanContent content) {
    final cell = pw.TextStyle(fontSize: 9, color: _ink);
    // Lessons and notes follow their own language, so an English subject
    // reads left to right inside an Arabic table, aligned to the page side.
    pw.Widget contentText(String text) => pw.Text(
          text,
          textDirection: isRtlText(text, fallback: content.isArabic) ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          textAlign: content.isArabic ? pw.TextAlign.right : pw.TextAlign.left,
          style: cell,
        );

    return _row(
      [
        pw.Center(child: pw.Text(row.week, style: cell)),
        pw.Text('${row.dateFirstLine}\n${row.dateSecondLine}', style: cell),
        contentText(row.lessons),
        contentText(row.notes),
      ],
      isArabic: content.isArabic,
      borderColor: _border,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
  }

  /// A holiday or exam week: one merged, shaded cell across the table.
  static pw.Widget _breakRow(SemesterPlanRow row) {
    final side = pw.BorderSide(color: _border);
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 14),
      decoration: pw.BoxDecoration(color: _breakBg, border: pw.Border(left: side, right: side, bottom: side)),
      child: pw.Text(
        row.breakText,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _greenDark),
      ),
    );
  }

  /// One table row. [cells] are in reading order; `pw.Table` always lays
  /// columns out left to right, so Arabic reverses them.
  static pw.Widget _row(
    List<pw.Widget> cells, {
    required bool isArabic,
    required PdfColor borderColor,
    required pw.EdgeInsets padding,
    PdfColor? background,
    bool top = false,
  }) {
    final ordered = isArabic ? cells.reversed.toList() : cells;
    final flex = isArabic ? _columnFlex.reversed.toList() : _columnFlex;
    final direction = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final side = pw.BorderSide(color: borderColor, width: 0.7);
    final outer = pw.BorderSide(color: _border, width: 0.7);

    return pw.Table(
      border: pw.TableBorder(
        left: outer,
        right: outer,
        top: top ? outer : pw.BorderSide.none,
        bottom: outer,
        verticalInside: side,
      ),
      columnWidths: {for (var i = 0; i < flex.length; i++) i: pw.FlexColumnWidth(flex[i])},
      children: [
        pw.TableRow(
          decoration: background == null ? null : pw.BoxDecoration(color: background),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            for (final cell in ordered)
              pw.Padding(padding: padding, child: pw.Directionality(textDirection: direction, child: cell)),
          ],
        ),
      ],
    );
  }
}
