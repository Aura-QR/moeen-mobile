import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/data/models/exam_models.dart';

class ExamPdfService {
  static final PdfColor _primaryColor = PdfColor.fromHex('073F49');
  static final PdfColor _headerBg = PdfColor.fromHex('0B4A45');
  static final PdfColor _textDark = PdfColor.fromHex('1E293B');

  static Future<Uint8List> generatePdf({
    required ExamEntity exam,
    required bool showAnswers,
    required String teacherName,
    required String schoolName,
    required String educationOffice,
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

    final pw.TextStyle arabicRegular = pw.TextStyle(
      fontSize: 12,
      color: _textDark,
    );
    final pw.TextStyle arabicBold = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: _textDark,
    );
    final pw.TextStyle titleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: _primaryColor,
    );
    final pw.TextStyle headerWhite = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final questions = List<QuestionEntity>.from(exam.questions)
      ..sort((a, b) => a.questionOrder.compareTo(b.questionOrder));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Header
            _buildPageHeader(
              title: exam.title,
              teacherName: teacherName,
              schoolName: schoolName,
              educationOffice: educationOffice,
              date: exam.createdAt.split('T')[0],
              titleStyle: headerWhite.copyWith(fontSize: 16),
              headerStyle: headerWhite.copyWith(fontSize: 10, color: PdfColors.cyan200),
              arabicRegular: arabicRegular,
              ministryImage: ministryImage,
              logoImage: logoImage,
            ),
            pw.SizedBox(height: 20),
            
            pw.Center(child: pw.Text(exam.title, style: titleStyle, textDirection: pw.TextDirection.rtl)),
            pw.SizedBox(height: 20),

            // Questions
            ...questions.map((q) => _buildQuestion(q, arabicRegular, arabicBold, showAnswers)).toList(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPageHeader({
    required String title,
    required String teacherName,
    required String schoolName,
    required String educationOffice,
    required String date,
    required pw.TextStyle titleStyle,
    required pw.TextStyle headerStyle,
    required pw.TextStyle arabicRegular,
    required pw.MemoryImage ministryImage,
    required pw.MemoryImage logoImage,
  }) {
    return pw.Container(
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
              pw.Text(educationOffice.isNotEmpty ? educationOffice : 'الإدارة العامة للتعليم', style: titleStyle, textDirection: pw.TextDirection.rtl),
              pw.SizedBox(height: 4),
              pw.Text(schoolName.isNotEmpty ? schoolName : 'مواهب المملكة', style: headerStyle, textDirection: pw.TextDirection.rtl),
              pw.SizedBox(height: 12),
              pw.Text('المعلم: $teacherName', style: arabicRegular.copyWith(color: PdfColors.white, fontSize: 10), textDirection: pw.TextDirection.rtl),
              pw.Text('التاريخ: $date', style: arabicRegular.copyWith(color: PdfColors.white, fontSize: 10), textDirection: pw.TextDirection.rtl),
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
    );
  }

  static pw.Widget _buildQuestion(
      QuestionEntity q, pw.TextStyle regular, pw.TextStyle bold, bool showAnswers) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${q.questionOrder}. ', style: bold, textDirection: pw.TextDirection.rtl),
              pw.Expanded(
                child: pw.Text(q.questionText, style: bold, textDirection: pw.TextDirection.rtl),
              ),
              pw.Text('[${q.points} درجة]', style: regular.copyWith(color: PdfColors.grey700, fontSize: 10), textDirection: pw.TextDirection.rtl),
            ],
          ),
          pw.SizedBox(height: 10),
          _buildQuestionOptions(q, regular, bold, showAnswers),
          if (showAnswers && q.type != 'matching' && q.type != 'mcq') ...[
            pw.SizedBox(height: 10),
            pw.Text('الإجابة: ${q.correctAnswer}', style: bold.copyWith(color: PdfColors.green700), textDirection: pw.TextDirection.rtl),
          ]
        ],
      ),
    );
  }

  static pw.Widget _buildQuestionOptions(
      QuestionEntity q, pw.TextStyle regular, pw.TextStyle bold, bool showAnswers) {
    if (q.type == 'mcq') {
      final options = List<String>.from(q.options ?? []);
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: options.map((opt) {
          final isCorrect = opt == q.correctAnswer;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: PdfColors.grey),
                    color: (showAnswers && isCorrect) ? PdfColors.green700 : null,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    opt,
                    style: (showAnswers && isCorrect)
                        ? bold.copyWith(color: PdfColors.green700)
                        : regular,
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (q.type == 'true_false') {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 12,
                height: 12,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.grey),
                  color: (showAnswers && q.correctAnswer == 'صح') ? PdfColors.green700 : null,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text('صح', style: regular, textDirection: pw.TextDirection.rtl),
            ],
          ),
          pw.Row(
            children: [
              pw.Container(
                width: 12,
                height: 12,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.grey),
                  color: (showAnswers && q.correctAnswer == 'خطأ') ? PdfColors.green700 : null,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text('خطأ', style: regular, textDirection: pw.TextDirection.rtl),
            ],
          ),
        ],
      );
    } else if (q.type == 'matching') {
      List<String> columnA = [];
      List<String> columnB = [];
      
      if (q.options is MatchingOptionsModel) {
        columnA = (q.options as MatchingOptionsModel).columnA;
        columnB = (q.options as MatchingOptionsModel).columnB;
      } else if (q.options is Map) {
        columnA = List<String>.from(q.options['column_a'] ?? []);
        columnB = List<String>.from(q.options['column_b'] ?? []);
      }

      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: columnA.map((a) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text('• $a', style: regular, textDirection: pw.TextDirection.rtl))).toList(),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: columnB.map((b) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text('• $b', style: regular, textDirection: pw.TextDirection.rtl))).toList(),
            ),
          ),
        ],
      );
    } else if (q.type == 'essay') {
      return pw.Container(
        height: 60,
        width: double.infinity,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
      );
    }
    return pw.SizedBox();
  }
}
