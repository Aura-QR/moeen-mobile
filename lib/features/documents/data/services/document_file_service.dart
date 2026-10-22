import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// On-device file work for exports: HTML → PDF, PDF → image, share, print.
/// The backend sends the finished page, so there is no layout code here.
class DocumentFileService {
  static const String pdfMime = 'application/pdf';
  static const String pngMime = 'image/png';
  static const String docxMime =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  /// Converts HTML to PDF in MainActivity (HtmlPdfConverter.kt).
  static const MethodChannel _androidHtmlPdf = MethodChannel('com.haderedu.app/html_pdf');

  /// Longer than the native 45 s timeout, so that one reports first.
  static const Duration _convertTimeout = Duration(seconds: 60);

  /// A4 PDF from the self-contained page `GET /documents/{id}/print` returns.
  /// On Android printing's convertHtml never completes (its WebView is never
  /// attached), so the app's own converter is used there. iOS keeps
  /// convertHtml, which printing 5.14 marks deprecated but still implements.
  Future<Either<Failure, Uint8List>> htmlToPdf(String html) => _guard(() async {
        final pdf = Platform.isAndroid
            ? await _androidHtmlPdf.invokeMethod<Uint8List>('convert', {'html': html})
            // ignore: deprecated_member_use
            : await Printing.convertHtml(format: PdfPageFormat.a4, html: html);
        if (pdf == null || pdf.isEmpty) throw StateError('empty PDF');
        return pdf;
      }).timeout(_convertTimeout, onTimeout: () => const Left(ServerFailure('document_export_failed')));

  /// The first page as a PNG, for sharing on WhatsApp.
  Future<Either<Failure, Uint8List>> firstPageAsPng(Uint8List pdf) => _guard(() async {
        final page = await Printing.raster(pdf, pages: const [0], dpi: 150).first;
        return page.toPng();
      });

  /// Writes the file to a temp folder and opens the share sheet.
  Future<Either<Failure, Unit>> share(
    Uint8List bytes, {
    required String fileName,
    required String mime,
  }) =>
      _guard(() async {
        final name = safeFileName(fileName);
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$name');
        await file.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path, mimeType: mime, name: name)],
        ));
        return unit;
      });

  Future<Either<Failure, Unit>> printPdf(Uint8List bytes, {required String name}) => _guard(() async {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: safeFileName(name));
        return unit;
      });

  /// Drops characters file systems reject; titles can hold «5/1» or quotes.
  static String safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\n\r\t]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.isEmpty ? 'document' : cleaned;
  }

  /// The printing and share plugins throw platform exceptions; callers get a [Failure].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } catch (_) {
      return const Left(ServerFailure('document_export_failed'));
    }
  }
}
