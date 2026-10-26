import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrExportService {
  Future<Uint8List> pngBytes({
    required String data,
    ui.Image? logo,
    double size = 1024,
  }) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel:
          logo == null ? QrErrorCorrectLevel.M : QrErrorCorrectLevel.H,
      embeddedImage: logo,
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(size * 0.22, size * 0.22),
      ),
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;

    // White quiet zone margin
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);

    const double marginRatio = 0.08;
    final margin = size * marginRatio;
    final qrSize = size - (margin * 2);

    canvas.save();
    canvas.translate(margin, margin);
    qrPainter.paint(canvas, Size(qrSize, qrSize));
    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> pdfBytes({
    required Uint8List qrPng,
    String? caption,
    required String link,
  }) async {
    pw.Font? regular;
    pw.Font? bold;
    try {
      regular =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'));
      bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    } catch (_) {}

    final doc = pw.Document(
      theme: regular != null && bold != null
          ? pw.ThemeData.withFont(base: regular, bold: bold)
          : null,
    );

    final qrImage = pw.MemoryImage(qrPng);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(
                  width: 220,
                  height: 220,
                  child: pw.Image(qrImage),
                ),
                if (caption != null && caption.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 24),
                  pw.Text(
                    caption.trim(),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                pw.SizedBox(height: 16),
                pw.Text(
                  link,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                  textDirection: pw.TextDirection.ltr,
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  Future<bool> saveToGallery(Uint8List png, String name) async {
    try {
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) return false;
      await Gal.putImageBytes(png, name: name);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> sharePng(
    Uint8List png, {
    required String link,
    String? filename,
  }) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${filename ?? 'qr_code.png'}';
    final file = File(filePath);
    await file.writeAsBytes(png);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: link,
      ),
    );
  }
}
