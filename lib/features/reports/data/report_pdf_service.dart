import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPdfService {
  static final PdfColor _primaryColor = PdfColor.fromHex('073F49');
  static final PdfColor _headerBg = PdfColor.fromHex('0B4A45');
  static final PdfColor _subHeaderBg = PdfColor.fromHex('E8F5F1');
  static final PdfColor _lightGray = PdfColor.fromHex('F8FAFC');
  static final PdfColor _borderColor = PdfColor.fromHex('E2E8F0');
  static final PdfColor _textDark = PdfColor.fromHex('1E293B');
  static final PdfColor _textMuted = PdfColor.fromHex('64748B');

  static String _fixArabic(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll('مسار إداري', 'مسار\u00A0إداري')
        .replaceAll('مسار ادارى', 'مسار\u00A0ادارى')
        .replaceAll('مسار اداري', 'مسار\u00A0اداري')
        .replaceAll('مسار إدارى', 'مسار\u00A0إدارى');
  }


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

    final ByteData ministryImageData = await rootBundle.load('assets/images/minstry.jpg');
    final pw.MemoryImage ministryImage = pw.MemoryImage(ministryImageData.buffer.asUint8List());

    final ByteData logoImageData = await rootBundle.load('assets/images/logo_icon-removebg-preview.png');
    final pw.MemoryImage logoImage = pw.MemoryImage(logoImageData.buffer.asUint8List());

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
              teacherName: _fixArabic(teacherName),
              grade: _fixArabic(grade),
              subject: _fixArabic(subject),
              unit: unit,
              semester: semester,
              schoolName: schoolName,
              educationOffice: educationOffice,
              reportType: reportType,
              reportDate: reportDate,
              lessonsCount: selectedLessons.length.toString(),
              titleStyle: titleStyle,
              headerStyle: headerStyle,
              arabicRegular: arabicRegular,
              arabicBold: arabicBold,
              ministryImage: ministryImage,
              logoImage: logoImage,
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
    required String lessonsCount,
    required pw.TextStyle titleStyle,
    required pw.TextStyle headerStyle,
    required pw.TextStyle arabicRegular,
    required pw.TextStyle arabicBold,
    required pw.MemoryImage ministryImage,
    required pw.MemoryImage logoImage,
  }) {
    return pw.Column(
      children: [
        // Top dark header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: pw.BoxDecoration(
            color: _headerBg,
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(16),
              bottomRight: pw.Radius.circular(16),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('الإدارة العامة للتعليم', style: titleStyle.copyWith(fontSize: 16)),
                  pw.SizedBox(height: 4),
                  pw.Text('مواهب المملكة', style: headerStyle.copyWith(fontSize: 10, color: PdfColors.cyan200)),
                  pw.SizedBox(height: 12),
                  pw.Directionality(
                    textDirection: pw.TextDirection.ltr,
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('Moean', style: arabicRegular.copyWith(color: PdfColors.white, fontSize: 8)),
                        pw.SizedBox(width: 4),
                        pw.Directionality(
                          textDirection: pw.TextDirection.rtl,
                          child: pw.Text('للإدارة (مسار\u00A0إداري)', style: arabicRegular.copyWith(color: PdfColors.white, fontSize: 8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 48,
                    height: 48,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Container(
  width: 48,
  height: 48,
  decoration: const pw.BoxDecoration(
    color: PdfColors.white,
    shape: pw.BoxShape.circle,
  ),
  child: pw.ClipOval(
    child: pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Image(
        ministryImage,
        fit: pw.BoxFit.cover,
      ),
    ),
  ),
),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // Titles
        pw.Text('تقرير $reportType', style: titleStyle.copyWith(color: _primaryColor, fontSize: 16)),
        if (reportType != 'خطة') pw.SizedBox(height: 4),
        if (reportType != 'خطة') pw.Text('بيانات التقرير الأساسية', style: arabicRegular.copyWith(color: _textMuted)),
        
        pw.SizedBox(height: 12),
        // Basic Info Table
        if (reportType != 'خطة') _buildBasicInfoTable(
          teacherName: teacherName,
          grade: grade,
          subject: subject,
          semester: semester,
          reportDate: reportDate,
          lessonsCount: lessonsCount,
          regular: arabicRegular,
          bold: arabicBold,
        ),
      ],
    );
  }

  static pw.Widget _buildBasicInfoTable({
    required String teacherName,
    required String grade,
    required String subject,
    required String semester,
    required String reportDate,
    required String lessonsCount,
    required pw.TextStyle regular,
    required pw.TextStyle bold,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: ['اسم المعلم', 'الصف', 'المادة', 'الفصل', 'تاريخ التقرير', 'عدد الحصص'],
      data: [
        [teacherName, grade, subject, semester, reportDate, lessonsCount]
      ],
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      headerStyle: bold.copyWith(color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: _primaryColor),
      cellStyle: regular,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.TextStyle headerStyle) {
    return pw.Center(
      child: pw.Text(
        title,
        style: headerStyle.copyWith(color: _primaryColor, fontSize: 14),
      ),
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
                _fixArabic(r['lesson'] ?? ''),
                _fixArabic(r['description'] ?? ''),
                _fixArabic(r['participation'] ?? ''),
                _fixArabic(r['understanding'] ?? ''),
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
                _fixArabic(r['lesson'] ?? ''),
                _fixArabic(r['concepts'] ?? ''),
                _fixArabic(r['objectives'] ?? ''),
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
                _fixArabic(r['lesson'] ?? ''),
                _fixArabic(r['goal'] ?? ''),
                _fixArabic(r['targetUnderstanding'] ?? ''),
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
                _fixArabic(r['lesson'] ?? ''),
                _fixArabic(r['challenge'] ?? ''),
                _fixArabic(r['plan'] ?? ''),
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
                _fixArabic(r['lesson'] ?? ''),
                _fixArabic(r['method'] ?? ''),
                _fixArabic(r['result'] ?? ''),
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
                _fixArabic(r['lesson'] ?? ''),
                _fixArabic(r['modelingMethod'] ?? ''),
                _fixArabic(r['notes'] ?? ''),
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
                _fixArabic(r['strategy'] ?? ''),
                _fixArabic(r['description'] ?? ''),
                _fixArabic(r['appliedLessons'] ?? ''),
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
