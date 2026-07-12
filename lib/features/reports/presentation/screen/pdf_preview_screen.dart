import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Future<Uint8List> Function() buildPdf;
  final String title;

  const PdfPreviewScreen({
    super.key,
    required this.buildPdf,
    this.title = 'معاينة التقرير',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            title,
            style: TextStylesManager.bold18.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: ColorsManager.mainText),
            onPressed: () => context.pop(),
          ),
        ),
        body: PdfPreview(
          build: (format) => buildPdf(),
          allowPrinting: true,
          allowSharing: true,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName: 'report.pdf',
          loadingWidget: Center(
            child: CircularProgressIndicator(
              color: ColorsManager.primaryColor,
            ),
          ),
          scrollViewDecoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
          ),
          pdfPreviewPageDecoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
