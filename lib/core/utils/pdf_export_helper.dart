import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:moean/core/theme/text_styles.dart';
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

      for (var pageWidget in pages) {
        final fullWidget = Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context),
            child: Material(
              color: ColorsManager.background,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: pageWidget,
              ),
            ),
          ),
        );

        final Uint8List imageBytes = await screenshotController.captureFromWidget(
          fullWidget,
          context: context,
          delay: const Duration(milliseconds: 100),
          pixelRatio: 2.0,
        );

        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
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
          SnackBar(content: Text('حدث خطأ أثناء التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
