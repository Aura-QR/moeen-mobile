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

    return pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      textDirection: pw.TextDirection.rtl,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(
        children: [
          pw.Container(
            color: bg,
            width: double.infinity,
            height: double.infinity,
          ),
          pw.Container(
            height: 160,
            width: double.infinity,
            color: primary,
          ),
          pw.Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _imageLogoBox(roaaImage),
                pw.SizedBox(width: 24),
                _imageLogoBox(minstryImage),
              ],
            ),
          ),
          pw.Positioned.fill(
            top: 240,
            child: pw.Column(
              children: [
                pw.Text(
                  'شهادة شكر وتقدير',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 48,
                    color: primary,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  height: 1,
                  width: 600,
                  color: PdfColors.grey300,
                ),
                pw.SizedBox(height: 24),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'يسر إدارة مدرسة  ',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: boldFont, fontSize: 18, color: txtColor),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: primary,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                      ),
                      child: pw.Text(
                        entity.schoolName,
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: boldFont, fontSize: 18, color: white),
                      ),
                    ),
                    pw.Text(
                      '  أن تتقدم بوافر الشكر والتقدير',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: boldFont, fontSize: 18, color: txtColor),
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'الصف',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: boldFont, fontSize: 22, color: txtColor),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Container(
                      width: 110,
                      height: 110,
                      decoration: pw.BoxDecoration(
                        color: primary,
                        shape: pw.BoxShape.circle,
                        boxShadow: const [
                          pw.BoxShadow(
                            color: PdfColors.grey300,
                            blurRadius: 4,
                            offset: PdfPoint(0, 4),
                          ),
                        ],
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'الصف\n${entity.className.replaceAll(' ', '\n')}',
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: boldFont, fontSize: 18, color: white, lineSpacing: 4),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      decoration: pw.BoxDecoration(
                        color: primary,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(40)),
                        boxShadow: const [
                          pw.BoxShadow(
                            color: PdfColors.grey300,
                            blurRadius: 4,
                            offset: PdfPoint(0, 4),
                          ),
                        ],
                      ),
                      child: pw.Text(
                        entity.studentName,
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(font: boldFont, fontSize: 28, color: white),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Text(
                      entity.gender == 'female' ? 'للطالبة' : 'للطالب',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: boldFont, fontSize: 22, color: txtColor),
                    ),
                  ].reversed.toList(),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 60),
                  child: pw.Text(
                    entity.certText,
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 22, color: txtColor),
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    _signatureBox(entity.directorName, 'المدير', regularFont, boldFont, txtColor),
                    _signatureBox(entity.teacherName, 'المعلم', regularFont, boldFont, txtColor),
                  ],
                ),
                pw.SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _imageLogoBox(pw.ImageProvider image) {
    return pw.Container(
      width: 130,
      height: 130,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(24)),
        boxShadow: const [
          pw.BoxShadow(
            color: PdfColors.grey300,
            blurRadius: 8,
            offset: PdfPoint(0, 4),
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
