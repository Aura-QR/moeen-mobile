import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPdfService {
  static final PdfColor _primaryColor = PdfColor.fromHex('0E7A5E');
  static final PdfColor _headerBg = PdfColor.fromHex('0E7A5E');
  static final PdfColor _subHeaderBg = PdfColor.fromHex('E8F5F1');
  static final PdfColor _lightGray = PdfColor.fromHex('F8FAFC');
  static final PdfColor _borderColor = PdfColor.fromHex('E2E8F0');
  static final PdfColor _textDark = PdfColor.fromHex('1E293B');
  static final PdfColor _textMuted = PdfColor.fromHex('64748B');
  static final PdfColor _sectionBg = PdfColor.fromHex('064E3B');

  static Future<Uint8List> generatePdf({
    required Map<String, dynamic> reportData,
    required String teacherName,
    required String grade,
    required String subject,
    required String unit,
    required String semester,
    required String schoolName,
    required String educationOffice,
    required String reportType,
    required String reportDate,
    required List<String> selectedLessons,
  }) async {
    final ByteData fontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final pw.Font ttf = pw.Font.ttf(fontData);

    final ByteData boldFontData = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
    final pw.Font ttfBold = pw.Font.ttf(boldFontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttfBold,
      ),
    );

    final List<Map<String, dynamic>> achievementRows =
        List<Map<String, dynamic>>.from(reportData['achievementRows'] ?? []);
    final List<Map<String, dynamic>> lessonPlanRows =
        List<Map<String, dynamic>>.from(reportData['lessonPlanRows'] ?? []);
    final List<Map<String, dynamic>> goalRows =
        List<Map<String, dynamic>>.from(reportData['goalRows'] ?? []);
    final List<Map<String, dynamic>> challengeRows =
        List<Map<String, dynamic>>.from(reportData['challengeRows'] ?? []);
    final List<Map<String, dynamic>> checkUnderstandingRows =
        List<Map<String, dynamic>>.from(reportData['checkUnderstandingRows'] ?? []);
    final List<Map<String, dynamic>> modelingRows =
        List<Map<String, dynamic>>.from(reportData['modelingRows'] ?? []);
    final List<Map<String, dynamic>> strategySections =
        List<Map<String, dynamic>>.from(reportData['strategySections'] ?? []);

    final pw.TextStyle arabicRegular = pw.TextStyle(
      fontSize: 9,
      color: _textDark,
    );
    final pw.TextStyle arabicBold = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: _textDark,
    );
    final pw.TextStyle headerStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final pw.TextStyle titleStyle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    // Build pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // ── Page Header ──
            _buildPageHeader(
              teacherName: teacherName,
              grade: grade,
              subject: subject,
              unit: unit,
              semester: semester,
              schoolName: schoolName,
              educationOffice: educationOffice,
              reportType: reportType,
              reportDate: reportDate,
              titleStyle: titleStyle,
              headerStyle: headerStyle,
              arabicRegular: arabicRegular,
              arabicBold: arabicBold,
            ),
            pw.SizedBox(height: 12),

            // ── Achievement Rows Table ──
            if (achievementRows.isNotEmpty) ...[
              _buildSectionTitle('بيانات الإنجاز التعليمي', headerStyle),
              pw.SizedBox(height: 6),
              _buildAchievementTable(achievementRows, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Lesson Plan Table ──
            if (lessonPlanRows.isNotEmpty) ...[
              _buildSectionTitle('خطة الدرس', headerStyle),
              pw.SizedBox(height: 6),
              _buildLessonPlanTable(lessonPlanRows, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Goals Table ──
            if (goalRows.isNotEmpty) ...[
              _buildSectionTitle('الأهداف', headerStyle),
              pw.SizedBox(height: 6),
              _buildGoalTable(goalRows, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Challenges Table ──
            if (challengeRows.isNotEmpty) ...[
              _buildSectionTitle('التحديات والخطط المقترحة', headerStyle),
              pw.SizedBox(height: 6),
              _buildChallengeTable(challengeRows, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Check Understanding Table ──
            if (checkUnderstandingRows.isNotEmpty) ...[
              _buildSectionTitle('التحقق من الفهم', headerStyle),
              pw.SizedBox(height: 6),
              _buildCheckUnderstandingTable(
                  checkUnderstandingRows, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Modeling Rows Table ──
            if (modelingRows.isNotEmpty) ...[
              _buildSectionTitle('النمذجة', headerStyle),
              pw.SizedBox(height: 6),
              _buildModelingTable(modelingRows, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Strategy Sections ──
            if (strategySections.isNotEmpty) ...[
              _buildSectionTitle('مقاطع الاستراتيجية', headerStyle),
              pw.SizedBox(height: 6),
              _buildStrategyTable(strategySections, arabicRegular, arabicBold),
              pw.SizedBox(height: 12),
            ],

            // ── Footer ──
            _buildFooter(arabicRegular),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────
  static pw.Widget _buildPageHeader({
    required String teacherName,
    required String grade,
    required String subject,
    required String unit,
    required String semester,
    required String schoolName,
    required String educationOffice,
    required String reportType,
    required String reportDate,
    required pw.TextStyle titleStyle,
    required pw.TextStyle headerStyle,
    required pw.TextStyle arabicRegular,
    required pw.TextStyle arabicBold,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        children: [
          // Top green bar with logo + title
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _headerBg,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('الإدارة العامة للتعليم', style: titleStyle),
                    pw.SizedBox(height: 2),
                    pw.Text('مكتب المملكة', style: headerStyle.copyWith(fontSize: 8)),
                  ],
                ),
                pw.Container(
                  width: 40,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'ME',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Secondary teal bar
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: _sectionBg,
            child: pw.Text(
              'التقرير $reportType الإشرافي — $reportDate',
              style: headerStyle.copyWith(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),

          // Info grid
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            color: _lightGray,
            child: pw.Column(
              children: [
                _buildInfoRow('اسم المعلم', teacherName, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('المادة', subject, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('الوحدة / المجال', unit, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('الصف', grade, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('الفصل', semester, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('نوع التقرير', reportType, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('اسم المدرسة', schoolName, arabicBold, arabicRegular),
                _buildDivider(),
                _buildInfoRow('مكتب التعليم', educationOffice, arabicBold, arabicRegular),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.TextStyle bold,
    pw.TextStyle regular,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label, style: bold),
          ),
          pw.Expanded(
            child: pw.Text(value, style: regular),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDivider() {
    return pw.Divider(height: 1, color: _borderColor, thickness: 0.5);
  }

  static pw.Widget _buildSectionTitle(String title, pw.TextStyle headerStyle) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _headerBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(title, style: headerStyle),
    );
  }

  // ─────────────────────────────────────────────────────
  // Tables
  // ─────────────────────────────────────────────────────

  static pw.Widget _buildAchievementTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headers: ['الدرس', 'وصف الإنجاز', 'المشاركة', 'مستوى الفهم'],
      data: rows
          .map((r) => [
                r['lesson'] ?? '',
                r['description'] ?? '',
                r['participation'] ?? '',
                r['understanding'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
      },
    );
  }

  static pw.Widget _buildLessonPlanTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['الدرس', 'المفاهيم', 'الأهداف'],
      data: rows
          .map((r) => [
                r['lesson'] ?? '',
                r['concepts'] ?? '',
                r['objectives'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(3),
      },
    );
  }

  static pw.Widget _buildGoalTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['الدرس', 'الهدف', 'مستوى الفهم المستهدف'],
      data: rows
          .map((r) => [
                r['lesson'] ?? '',
                r['goal'] ?? '',
                r['targetUnderstanding'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
    );
  }

  static pw.Widget _buildChallengeTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['الدرس', 'التحدي', 'الخطة المقترحة'],
      data: rows
          .map((r) => [
                r['lesson'] ?? '',
                r['challenge'] ?? '',
                r['plan'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
    );
  }

  static pw.Widget _buildCheckUnderstandingTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['الدرس', 'أسلوب التحقق', 'النتيجة'],
      data: rows
          .map((r) => [
                r['lesson'] ?? '',
                r['method'] ?? '',
                r['result'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
    );
  }

  static pw.Widget _buildModelingTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['الدرس', 'أسلوب النمذجة', 'الملاحظات'],
      data: rows
          .map((r) => [
                r['lesson'] ?? '',
                r['modelingMethod'] ?? '',
                r['notes'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
    );
  }

  static pw.Widget _buildStrategyTable(
    List<Map<String, dynamic>> rows,
    pw.TextStyle regular,
    pw.TextStyle bold,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['الاستراتيجية', 'الوصف', 'الدروس المطبقة'],
      data: rows
          .map((r) => [
                r['strategy'] ?? '',
                r['description'] ?? '',
                r['appliedLessons'] ?? '',
              ])
          .toList(),
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      oddRowDecoration: pw.BoxDecoration(color: _lightGray),
    );
  }

  // ─────────────────────────────────────────────────────
  // Footer
  // ─────────────────────────────────────────────────────
  static pw.Widget _buildFooter(pw.TextStyle regular) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _subHeaderBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'تم التوليد بواسطة نظام معين التعليمي',
            style: regular.copyWith(color: _textMuted, fontSize: 8),
          ),
          pw.Text(
            DateTime.now().toLocal().toString().substring(0, 10),
            style: regular.copyWith(color: _textMuted, fontSize: 8),
          ),
        ],
      ),
    );
  }
}
