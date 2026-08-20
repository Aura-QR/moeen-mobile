import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_state.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PrivacyPolicyCubit extends Cubit<PrivacyPolicyState> {
  PrivacyPolicyCubit() : super(const PrivacyPolicyInitial());

  static PrivacyPolicyCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final Map<int, GlobalKey> sectionKeys = {
    0: GlobalKey(),
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
    4: GlobalKey(),
    5: GlobalKey(),
    6: GlobalKey(),
    7: GlobalKey(),
    8: GlobalKey(),
  };

  int? activeSection = 0;
  String searchQuery = '';

  void setActiveSection(int index) {
    activeSection = index;
    if (!isClosed) {
      emit(PrivacyPolicyStateUpdated(
        activeSection: activeSection,
        searchQuery: searchQuery,
      ));
    }
  }

  void onSearchChanged(String query) {
    searchQuery = query.trim().toLowerCase();
    if (!isClosed) {
      emit(PrivacyPolicyStateUpdated(
        activeSection: activeSection,
        searchQuery: searchQuery,
      ));
    }
  }

  void scrollToSection(int index) {
    setActiveSection(index);
    final key = sectionKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> shareLink() async {
    final text = appTranslation().get('privacy_share_text');
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> printPdf() async {
    if (!isClosed) emit(const PrivacyPolicyPdfGenerating());
    try {
      final doc = pw.Document();
      final fontData =
          await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
      final boldFontData =
          await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
      final font = pw.Font.ttf(fontData);
      final boldFont = pw.Font.ttf(boldFontData);

      final title = appTranslation().get('privacy_hero_title');
      final desc = appTranslation().get('privacy_hero_desc');
      final updated = appTranslation().get('privacy_last_updated');

      final sections = [
        (
          appTranslation().get('privacy_sec1_title'),
          '${appTranslation().get('privacy_sec1_p1')}\n\n${appTranslation().get('privacy_sec1_p2')}\n\n${appTranslation().get('privacy_sec1_highlight')}'
        ),
        (
          appTranslation().get('privacy_sec2_title'),
          '${appTranslation().get('privacy_sec2_intro')}\n- ${appTranslation().get('privacy_sec2_card1_title')}: ${appTranslation().get('privacy_sec2_card1_desc')}\n- ${appTranslation().get('privacy_sec2_card2_title')}: ${appTranslation().get('privacy_sec2_card2_desc')}\n- ${appTranslation().get('privacy_sec2_card3_title')}: ${appTranslation().get('privacy_sec2_card3_desc')}\n- ${appTranslation().get('privacy_sec2_card4_title')}: ${appTranslation().get('privacy_sec2_card4_desc')}'
        ),
        (
          appTranslation().get('privacy_sec3_title'),
          '${appTranslation().get('privacy_sec3_intro')}\n- ${appTranslation().get('privacy_sec3_check1')}\n- ${appTranslation().get('privacy_sec3_check2')}\n- ${appTranslation().get('privacy_sec3_check3')}'
        ),
        (
          appTranslation().get('privacy_sec4_title'),
          '${appTranslation().get('privacy_sec4_intro')}\n- ${appTranslation().get('privacy_sec4_bullet1')}\n- ${appTranslation().get('privacy_sec4_bullet2')}\n- ${appTranslation().get('privacy_sec4_bullet3')}\n- ${appTranslation().get('privacy_sec4_bullet4')}'
        ),
        (
          appTranslation().get('privacy_sec5_title'),
          '${appTranslation().get('privacy_sec5_intro')}\n- ${appTranslation().get('privacy_sec5_card1_title')}: ${appTranslation().get('privacy_sec5_card1_desc')}\n- ${appTranslation().get('privacy_sec5_card2_title')}: ${appTranslation().get('privacy_sec5_card2_desc')}\n- ${appTranslation().get('privacy_sec5_card3_title')}: ${appTranslation().get('privacy_sec5_card3_desc')}'
        ),
        (
          appTranslation().get('privacy_sec6_title'),
          '${appTranslation().get('privacy_sec6_alert_title')}: ${appTranslation().get('privacy_sec6_alert_desc')}\n\n${appTranslation().get('privacy_sec6_p1')}'
        ),
        (
          appTranslation().get('privacy_sec7_title'),
          '${appTranslation().get('privacy_sec7_intro')}\n1. ${appTranslation().get('privacy_sec7_item1')}\n2. ${appTranslation().get('privacy_sec7_item2')}\n3. ${appTranslation().get('privacy_sec7_item3')}'
        ),
        (
          appTranslation().get('privacy_sec8_title'),
          '${appTranslation().get('privacy_sec8_intro')}\n- ${appTranslation().get('privacy_sec8_item1')}\n- ${appTranslation().get('privacy_sec8_item2')}\n- ${appTranslation().get('privacy_sec8_item3')}'
        ),
        (
          appTranslation().get('privacy_sec9_title'),
          '${appTranslation().get('privacy_sec9_p1')}\n\n${appTranslation().get('privacy_sec9_box_title')}: ${appTranslation().get('privacy_sec9_box_desc')}\n${appTranslation().get('privacy_sec9_email')}'
        ),
      ];

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 20,
                      color: PdfColors.teal800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    desc,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    updated,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                ],
              ),
            ),
            ...sections.map(
              (s) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      s.$1,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      s.$2,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        lineSpacing: 2,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey200),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'privacy_policy',
        format: PdfPageFormat.a4,
      );

      if (!isClosed) emit(const PrivacyPolicyPdfGenerated());
    } catch (e) {
      if (!isClosed) emit(PrivacyPolicyPdfError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    searchController.dispose();
    return super.close();
  }
}
