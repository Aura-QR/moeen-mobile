import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/domain/entities/certificate_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

part 'certificate_state.dart';

class CertificateCubit extends Cubit<CertificateState> {
  CertificateCubit() : super(CertificateInitial());

  static CertificateCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController studentNamesController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController directorNameController = TextEditingController();
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController certTextController = TextEditingController();

  int selectedTemplate = 0;
  String selectedGender = 'male';
  DateTime selectedDate = DateTime.now();

  Future<void> loadTeacherProfile() async {
    emit(CertificateLoading());
    final result = await ApiService.getProfile();
    result.fold(
      (_) => emit(const CertificateLoaded()),
      (profile) {
        teacherNameController.text = profile.user.name;
        emit(const CertificateLoaded());
      },
    );
  }

  void selectTemplate(int index) {
    selectedTemplate = index;
    emit(CertificateTemplateSelected(index));
  }

  void selectGender(String gender) {
    selectedGender = gender;
    emit(CertificateGenderChanged(gender));
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    emit(CertificateDateChanged(date));
  }

  void selectReadyText(String text) {
    certTextController.text = text;
    emit(CertificateReadyTextSelected(text));
  }

  List<String> get studentNames => studentNamesController.text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> generatePdf() async {
    if (studentNames.isEmpty) {
      emit(const CertificateError('no_students'));
      return;
    }
    emit(CertificateGenerating());
    try {
      await Printing.layoutPdf(
        onLayout: (_) => _buildPdfBytes(),
        name: 'certificates',
      );
      emit(const CertificateLoaded());
    } catch (e) {
      emit(CertificateError(e.toString()));
    }
  }

  Future<Uint8List> _buildPdfBytes() async {
    final boldBytes =
        await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
    final regularBytes =
        await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final roaaBytes = await rootBundle.load('assets/images/roaa.png');
    final minstryBytes = await rootBundle.load('assets/images/minstry.jpg');

    final boldFont = pw.Font.ttf(boldBytes);
    final regularFont = pw.Font.ttf(regularBytes);
    final roaaImage = pw.MemoryImage(roaaBytes.buffer.asUint8List());
    final minstryImage = pw.MemoryImage(minstryBytes.buffer.asUint8List());

    final doc = pw.Document();
    final template = CertificateTemplateModel.all[selectedTemplate];
    final formattedDate =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    for (final name in studentNames) {
      final entity = CertificateEntity(
        studentName: name,
        gender: selectedGender,
        schoolName: schoolNameController.text,
        className: classNameController.text,
        directorName: directorNameController.text,
        teacherName: teacherNameController.text,
        certDate: formattedDate,
        certText: certTextController.text,
        templateIndex: selectedTemplate,
      );
      doc.addPage(_buildPage(entity, template, boldFont, regularFont, roaaImage, minstryImage));
    }
    return doc.save();
  }

  pw.Page _buildPage(
    CertificateEntity entity,
    CertificateTemplateModel template,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.ImageProvider roaaImage,
    pw.ImageProvider minstryImage,
  ) {
    final primary = PdfColor.fromInt(template.primaryColor.toARGB32());
    final bg = PdfColor.fromInt(template.bgColor.toARGB32());
    final txtColor = PdfColor.fromInt(template.textColor.toARGB32());
    final white = PdfColors.white;
    // Light version of primary for the class pill
    final lightPrimary = PdfColor(
      (primary.red * 0.25 + 0.75).clamp(0.0, 1.0),
      (primary.green * 0.25 + 0.75).clamp(0.0, 1.0),
      (primary.blue * 0.25 + 0.75).clamp(0.0, 1.0),
    );

    return pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      textDirection: pw.TextDirection.rtl,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(
        children: [
          // White/bg background
          pw.Container(
            color: bg,
            width: double.infinity,
            height: double.infinity,
          ),
          // Teal header bar
          pw.Container(
            height: 125,
            width: double.infinity,
            color: primary,
          ),
          // Logos overlapping below the header
          pw.Positioned(
            top: 78,
            left: 0,
            right: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _imageLogoBox(roaaImage),
                pw.SizedBox(width: 16),
                _imageLogoBox(minstryImage),
              ],
            ),
          ),
          // Main content
          pw.Positioned(
            top: 175,
            left: 50,
            right: 50,
            bottom: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 18),
                // Title
                pw.Text(
                  'شهادة شكر وتقدير',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 38,
                    color: primary,
                  ),
                ),
                pw.SizedBox(height: 8),
                // Thin divider full width
                pw.Container(
                  height: 1,
                  width: double.infinity,
                  color: PdfColors.grey300,
                ),
                pw.SizedBox(height: 12),
                // School line
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'يسر إدارة مدرسة  ',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: regularFont, fontSize: 16, color: txtColor),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: primary,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                      ),
                      child: pw.Text(
                        entity.schoolName,
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: boldFont, fontSize: 16, color: white),
                      ),
                    ),
                    pw.Text(
                      '  أن تتقدم بوافر الشكر والتقدير',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: regularFont, fontSize: 16, color: txtColor),
                    ),
                  ],
                ),
                pw.SizedBox(height: 14),
                // للطالب label – right-aligned
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    entity.gender == 'female' ? 'للطالبة' : 'للطالب',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: boldFont, fontSize: 18, color: txtColor),
                  ),
                ),
                pw.SizedBox(height: 6),
                // Student name – full-width dark pill
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 14),
                  decoration: pw.BoxDecoration(
                    color: primary,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(30)),
                  ),
                  child: pw.Text(
                    entity.studentName,
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 22, color: white),
                  ),
                ),
                pw.SizedBox(height: 8),
                // الصف label – right-aligned ABOVE class pill
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'الصف',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: regularFont, fontSize: 15, color: txtColor),
                  ),
                ),
                pw.SizedBox(height: 4),
                // Class – full-width light pill
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: lightPrimary,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(30)),
                  ),
                  child: pw.Text(
                    entity.className,
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 18, color: primary),
                  ),
                ),
                pw.SizedBox(height: 14),
                // Certificate body text
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                    entity.certText,
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 20, color: txtColor),
                  ),
                ),
                pw.Spacer(),
                // Signatures + circular seal
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    _signatureBox(entity.teacherName, 'المعلم', regularFont, boldFont, txtColor),
                    pw.Container(
                      width: 72,
                      height: 72,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: primary, width: 2),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'شهادة\nحضر',
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: boldFont, fontSize: 13, color: primary),
                      ),
                    ),
                    _signatureBox(entity.directorName, 'المدير', regularFont, boldFont, txtColor),
                  ],
                ),
                pw.SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _imageLogoBox(pw.ImageProvider image) {
    return pw.Container(
      width: 86,
      height: 86,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
        boxShadow: const [
          pw.BoxShadow(
            color: PdfColors.grey300,
            blurRadius: 6,
            offset: PdfPoint(0, 3),
          ),
        ],
      ),
      child: pw.Image(image, fit: pw.BoxFit.contain),
    );
  }

  pw.Widget _signatureBox(String name, String label, pw.Font regular,
      pw.Font bold, PdfColor txtColor) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(font: regular, fontSize: 14, color: txtColor),
        ),
        pw.SizedBox(height: 4),
        pw.Container(width: 120, height: 1, color: PdfColors.grey),
        pw.SizedBox(height: 4),
        pw.Text(
          name,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(font: bold, fontSize: 14, color: txtColor),
        ),
      ],
    );
  }

  @override
  Future<void> close() {
    studentNamesController.dispose();
    schoolNameController.dispose();
    classNameController.dispose();
    directorNameController.dispose();
    teacherNameController.dispose();
    certTextController.dispose();
    return super.close();
  }
}
