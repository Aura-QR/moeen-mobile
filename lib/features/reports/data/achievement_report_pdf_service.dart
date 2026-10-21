import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/presentation/utils/achievement_date_format.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The printable achievement report, matching the website's print view:
/// brand header, period and teacher box, five totals, the lessons card,
/// and signature columns for the teacher and the principal.
class AchievementReportPdfService {
  static final PdfColor _ink = PdfColor.fromHex('102138');
  static final PdfColor _green = PdfColor.fromHex('0B5D45');
  static final PdfColor _greenSoft = PdfColor.fromHex('F1F8F5');
  static final PdfColor _greenBorder = PdfColor.fromHex('D5E9E1');
  static final PdfColor _border = PdfColor.fromHex('E2E8F0');
  static final PdfColor _muted = PdfColor.fromHex('64748B');
  static final PdfColor _line = PdfColor.fromHex('94A3B8');

  static Future<Uint8List> build({
    required AchievementReportModel report,
    required String teacherName,
  }) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    final black = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-ExtraBold.ttf'));
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    final t = appTranslation().get;
    final range = formatFullDateRange(report.from, report.to, t);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      textDirection: pw.TextDirection.rtl,
      build: (_) => [
        _header(report, range, black),
        pw.SizedBox(height: 18),
        _periodBox(report, range, teacherName, black),
        pw.SizedBox(height: 14),
        _totals(report.totals, black),
        pw.SizedBox(height: 14),
        ..._lessons(report, black),
        pw.SizedBox(height: 36),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _signature(t('achievement_pdf_subject_teacher'), teacherName)),
            pw.SizedBox(width: 36),
            pw.Expanded(child: _signature(t('achievement_principal'), '')),
          ],
        ),
        pw.SizedBox(height: 28),
        pw.Divider(color: _border, thickness: 0.8),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(t('achievement_pdf_footer'), style: pw.TextStyle(fontSize: 8, color: _muted)),
        ),
      ],
    ));

    return doc.save();
  }

  static pw.Widget _header(AchievementReportModel report, String range, pw.Font black) {
    final t = appTranslation().get;
    return pw.Column(children: [
      pw.Text(t('portfolio_pdf_brand'), style: pw.TextStyle(font: black, fontSize: 24, color: _green)),
      pw.Text(t('achievement_pdf_tagline'), style: pw.TextStyle(fontSize: 8, color: _muted)),
      pw.SizedBox(height: 22),
      pw.Text(t('achievement_pdf_title'), style: pw.TextStyle(font: black, fontSize: 21, color: _ink)),
      pw.SizedBox(height: 8),
      pw.Text(
        '${t('achievement_pdf_report_${report.period}')} | $range',
        style: pw.TextStyle(fontSize: 10, color: _muted),
      ),
      pw.SizedBox(height: 16),
      pw.Container(height: 2, color: _green),
    ]);
  }

  static pw.Widget _periodBox(AchievementReportModel report, String range, String teacherName, pw.Font black) {
    final t = appTranslation().get;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: pw.BoxDecoration(
        color: _greenSoft,
        border: pw.Border.all(color: _greenBorder),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(t('achievement_pdf_period_label'), style: pw.TextStyle(fontSize: 8, color: _muted)),
              pw.SizedBox(height: 4),
              pw.Text(range, style: pw.TextStyle(font: black, fontSize: 12, color: _ink)),
              pw.SizedBox(height: 4),
              pw.Text(t('achievement_pdf_caption_${report.period}'), style: pw.TextStyle(fontSize: 8, color: _muted)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(t('achievement_pdf_teacher_name'), style: pw.TextStyle(fontSize: 8, color: _muted)),
              pw.SizedBox(height: 8),
              pw.Text(teacherName.isEmpty ? '—' : teacherName, style: pw.TextStyle(font: black, fontSize: 11, color: _ink)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _totals(AchievementTotalsModel totals, pw.Font black) {
    final t = appTranslation().get;
    final cards = [
      ('achievement_lessons_prepared', totals.lessonsPrepared),
      ('achievement_exams', totals.exams),
      ('achievement_presentations', totals.presentations),
      ('achievement_worksheets', totals.worksheets),
      ('achievement_educational_reports', totals.educationalReports),
    ];
    return pw.Row(children: [
      for (var i = 0; i < cards.length; i++) ...[
        if (i > 0) pw.SizedBox(width: 7),
        pw.Expanded(
          child: pw.Container(
            height: 62,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _border),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('${cards[i].$2}', style: pw.TextStyle(font: black, fontSize: 15, color: _green)),
                pw.SizedBox(height: 4),
                pw.Text(t(cards[i].$1), style: pw.TextStyle(fontSize: 8, color: _muted)),
              ],
            ),
          ),
        ),
      ],
    ]);
  }

  /// The card header and the lessons table; rows are separate children so a
  /// long list breaks across pages.
  static List<pw.Widget> _lessons(AchievementReportModel report, pw.Font black) {
    final t = appTranslation().get;
    final count = report.totals.lessonsPrepared;
    final side = pw.BorderSide(color: _border);
    final header = pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: side, left: side, right: side, bottom: report.lessons.isEmpty ? pw.BorderSide.none : side),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(t('achievement_pdf_lessons_details'), style: pw.TextStyle(font: black, fontSize: 12, color: _ink)),
          pw.Text(
            t('achievement_pdf_lessons_count').replaceAll('{n}', '$count'),
            style: pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );

    if (report.lessons.isEmpty) {
      return [
        header,
        pw.Container(
          padding: const pw.EdgeInsets.only(top: 22, bottom: 34),
          decoration: pw.BoxDecoration(border: pw.Border(left: side, right: side, bottom: side)),
          alignment: pw.Alignment.center,
          child: pw.Text(t('achievement_no_lessons'), style: pw.TextStyle(fontSize: 10, color: _muted)),
        ),
      ];
    }

    pw.Widget row(List<String> cells, {bool isHeader = false}) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: pw.BoxDecoration(
            color: isHeader ? _greenSoft : null,
            border: pw.Border(left: side, right: side, bottom: side),
          ),
          child: pw.Row(children: [
            for (final (i, flex) in const [(0, 1), (1, 6), (2, 3), (3, 2)])
              pw.Expanded(
                flex: flex,
                child: pw.Text(
                  cells[i],
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: isHeader ? _green : _ink,
                    font: isHeader ? black : null,
                  ),
                ),
              ),
          ]),
        );

    return [
      header,
      row(['#', t('achievement_lesson'), t('achievement_date'), t('achievement_time')], isHeader: true),
      for (var i = 0; i < report.lessons.length; i++)
        row([
          '${i + 1}',
          report.lessons[i].title,
          report.lessons[i].completedAt == null
              ? ''
              : '${formatDayMonth(report.lessons[i].completedAt!, t)} ${report.lessons[i].completedAt!.year}',
          report.lessons[i].completedAt == null ? '' : formatTime(report.lessons[i].completedAt!),
        ]),
    ];
  }

  static pw.Widget _signature(String title, String name) {
    final t = appTranslation().get;
    final dots = '..............................';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(height: 0.8, color: _line),
        pw.SizedBox(height: 14),
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _ink)),
        pw.SizedBox(height: 12),
        pw.Text('${t('achievement_pdf_name')} ${name.isEmpty ? dots : name}', style: pw.TextStyle(fontSize: 8, color: _ink)),
        pw.SizedBox(height: 12),
        pw.Text('${t('achievement_pdf_signature')} $dots', style: pw.TextStyle(fontSize: 8, color: _ink)),
      ],
    );
  }
}
