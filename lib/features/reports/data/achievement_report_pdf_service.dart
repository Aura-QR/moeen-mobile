import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/presentation/utils/achievement_date_format.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The printable achievement report: teacher, period, totals, the lessons
/// table, and signature lines for the teacher and the principal.
class AchievementReportPdfService {
  static final PdfColor _primary = PdfColor.fromHex('0E7A5E');
  static final PdfColor _primaryLight = PdfColor.fromHex('E8F5F1');
  static final PdfColor _border = PdfColor.fromHex('E2E8F0');
  static final PdfColor _muted = PdfColor.fromHex('64748B');

  static Future<Uint8List> build({
    required AchievementReportModel report,
    required String teacherName,
  }) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    final t = appTranslation().get;
    final totals = report.totals;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (_) => [
        pw.Text(
          t('achievement_report_title'),
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _primary),
        ),
        pw.SizedBox(height: 6),
        pw.Text('${t('achievement_teacher')}: $teacherName'),
        pw.Text(
          '${t('achievement_period_${report.period}')} · ${formatAchievementRange(report.from, report.to, t)}',
          style: pw.TextStyle(color: _muted),
        ),
        pw.SizedBox(height: 16),
        _table(
          headers: [t('achievement_metric'), t('achievement_count')],
          rows: [
            [t('achievement_lessons_prepared'), '${totals.lessonsPrepared}'],
            [t('achievement_exams'), '${totals.exams}'],
            [t('achievement_presentations'), '${totals.presentations}'],
            [t('achievement_worksheets'), '${totals.worksheets}'],
            [t('achievement_educational_reports'), '${totals.educationalReports}'],
          ],
          widths: const [3, 1],
        ),
        pw.SizedBox(height: 18),
        pw.Text(t('achievement_lessons'), style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (report.lessons.isEmpty)
          pw.Text(t('achievement_no_lessons'), style: pw.TextStyle(color: _muted))
        else
          _table(
            headers: ['#', t('achievement_lesson'), t('achievement_date'), t('achievement_time')],
            rows: [
              for (var i = 0; i < report.lessons.length; i++)
                [
                  '${i + 1}',
                  report.lessons[i].title,
                  report.lessons[i].completedAt == null ? '' : formatDayMonth(report.lessons[i].completedAt!, t),
                  report.lessons[i].completedAt == null ? '' : formatTime(report.lessons[i].completedAt!),
                ],
            ],
            widths: const [0.5, 4, 1.6, 1],
          ),
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _signature(t('achievement_teacher'), teacherName),
            _signature(t('achievement_principal'), ''),
          ],
        ),
      ],
    ));

    return doc.save();
  }

  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required List<double> widths,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: _border),
      columnWidths: {for (var i = 0; i < widths.length; i++) i: pw.FlexColumnWidth(widths[i])},
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _primaryLight),
          children: [for (final h in headers) _cell(h, isHeader: true)],
        ),
        for (final row in rows) pw.TableRow(children: [for (final value in row) _cell(value)]),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 10, fontWeight: isHeader ? pw.FontWeight.bold : null),
        ),
      );

  static pw.Widget _signature(String title, String name) => pw.SizedBox(
        width: 200,
        child: pw.Column(children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(name),
          pw.SizedBox(height: 28),
          pw.Divider(color: _muted),
        ]),
      );
}
