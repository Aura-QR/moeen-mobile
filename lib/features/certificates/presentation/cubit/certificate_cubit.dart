import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/domain/entities/certificate_data.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_preview_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';

part 'certificate_state.dart';

class CertificateCubit extends Cubit<CertificateState> {
  CertificateCubit() : super(CertificateInitial()) {
    _addControllerListeners();
  }

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

  Future<void> generatePdf(BuildContext context) async {
    if (studentNames.isEmpty) {
      emit(const CertificateError('no_students'));
      return;
    }
    emit(CertificateGenerating());
    try {
      await Printing.layoutPdf(
        onLayout: (_) => _buildPdfBytes(context),
        name: 'certificates',
        format: PdfPageFormat.a4,
      );
      emit(const CertificateLoaded());
    } catch (e) {
      emit(CertificateError(e.toString()));
    }
  }

  Future<Uint8List> _buildPdfBytes(BuildContext context) async {
    final doc = pw.Document();
    final template = CertificateTemplateModel.all[selectedTemplate];
    final formattedDate =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    final screenshotController = ScreenshotController();

    for (final name in studentNames) {
      final data = CertificateData(
        studentName: name,
        schoolName: schoolNameController.text,
        className: classNameController.text,
        teacherName: teacherNameController.text,
        principalName: directorNameController.text,
        certDate: formattedDate,
        certText: certTextController.text,
        gender: selectedGender,
      );

      final widget = Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.white,
          child: RotatedBox(
            quarterTurns: 1,
            child: CertificatePreviewWidget(
              template: template,
              data: data,
              availableWidth: 1080.0,
            ),
          ),
        ),
      );

      // Render image at 1.5 pixel ratio for high print quality
      final imageBytes = await screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 150),
        pixelRatio: 1.5,
        context: context,
        targetSize: const Size(1080.0 / 1.414, 1080.0),
      );

      final pdfImage = pw.MemoryImage(imageBytes);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pdfImage, fit: pw.BoxFit.fill),
            );
          },
        ),
      );
    }
    
    return doc.save();
  }

  // ── Listeners ──────────────────────────────────────────────────────────

  void _addControllerListeners() {
    studentNamesController.addListener(_onPreviewChange);
    schoolNameController.addListener(_onPreviewChange);
    classNameController.addListener(_onPreviewChange);
    directorNameController.addListener(_onPreviewChange);
    teacherNameController.addListener(_onPreviewChange);
    certTextController.addListener(_onPreviewChange);
  }

  void _removeControllerListeners() {
    studentNamesController.removeListener(_onPreviewChange);
    schoolNameController.removeListener(_onPreviewChange);
    classNameController.removeListener(_onPreviewChange);
    directorNameController.removeListener(_onPreviewChange);
    teacherNameController.removeListener(_onPreviewChange);
    certTextController.removeListener(_onPreviewChange);
  }

  void _onPreviewChange() => emit(const CertificatePreviewUpdated());

  // ── Preview data ───────────────────────────────────────────────────────

  /// Builds a [CertificateData] snapshot from the current form state for the
  /// live certificate preview. Shows placeholder text when fields are empty.
  CertificateData buildPreviewData() {
    final names = studentNames;
    final date = selectedDate;
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return CertificateData(
      studentName: names.isNotEmpty ? names.first : 'اسم الطالب',
      schoolName: schoolNameController.text.isNotEmpty
          ? schoolNameController.text
          : 'مدرسة حضّر النموذجية',
      className: classNameController.text.isNotEmpty
          ? classNameController.text
          : 'الصف الأول المتوسط',
      teacherName: teacherNameController.text.isNotEmpty
          ? teacherNameController.text
          : 'اسم المعلم',
      principalName: directorNameController.text.isNotEmpty
          ? directorNameController.text
          : 'اسم المدير',
      certDate: formattedDate,
      certText: certTextController.text.isNotEmpty
          ? certTextController.text
          : 'لتفوقه الدراسي وسمو أخلاقه، ونتمنى له دوام التفوق والنجاح بإذن الله.',
      gender: selectedGender,
    );
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _removeControllerListeners();
    studentNamesController.dispose();
    schoolNameController.dispose();
    classNameController.dispose();
    directorNameController.dispose();
    teacherNameController.dispose();
    certTextController.dispose();
    return super.close();
  }
}
