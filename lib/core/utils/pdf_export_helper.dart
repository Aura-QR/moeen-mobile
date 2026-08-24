import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:moean/core/theme/colors.dart';

class PdfExportHelper {
  static Future<void> exportWidgetsToPdfPages({
    required BuildContext context,
    required List<Widget> pages,
    required String title,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final screenshotController = ScreenshotController();
      final pdf = pw.Document();

      const double pageWidth = 840.0;
      const double pageHeight = 1188.0;

      for (var pageWidget in pages) {
        final fullWidget = Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: Colors.white,
            child: SizedBox(
              width: pageWidth,
              height: pageHeight,
              child: pageWidget,
            ),
          ),
        );

        final Uint8List imageBytes = await screenshotController.captureFromWidget(
          fullWidget,
          context: context,
          delay: const Duration(milliseconds: 150),
          pixelRatio: 2.0,
          targetSize: const Size(pageWidth, pageHeight),
        );

        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(image, fit: pw.BoxFit.fill),
              );
            },
          ),
        );
      }

      if (context.mounted) Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '$title.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التصدير: $e'),
            backgroundColor: ColorsManager.errorColor,
          ),
        );
      }
    }
  }
}
