import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the printable portfolio: cover, contents, one section per
/// included item, and a signatures page.
class PortfolioPdfService {
  static final PdfColor _primary = PdfColor.fromHex('0E7A5E');
  static final PdfColor _primaryLight = PdfColor.fromHex('E8F5F1');
  static final PdfColor _border = PdfColor.fromHex('E2E8F0');
  static final PdfColor _muted = PdfColor.fromHex('64748B');

  /// [images] maps a file id to its downloaded bytes.
  static Future<Uint8List> build({
    required PortfolioModel portfolio,
    required Map<int, Uint8List> images,
  }) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    final t = appTranslation();
    final profile = portfolio.profile ?? const PortfolioProfileModel();
    final items = portfolio.includedItems;

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (_) => _cover(portfolio, profile),
    ));

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (_) => [
        _heading(t.get('portfolio_pdf_contents')),
        for (var i = 0; i < items.length; i++)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text('${i + 1}. ${items[i].title}', style: const pw.TextStyle(fontSize: 12)),
          ),
      ],
    ));

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (_) => [
        for (var i = 0; i < items.length; i++) ..._itemSection(i + 1, items[i], images),
      ],
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (_) => _signatures(profile.signatures),
    ));

    return doc.save();
  }

  static pw.Widget _cover(PortfolioModel portfolio, PortfolioProfileModel profile) {
    final t = appTranslation();
    final rows = <List<String?>>[
      [t.get('portfolio_field_name'), profile.name],
      [t.get('portfolio_role'), portfolio.roleLabel],
      [t.get('portfolio_field_specialty'), profile.specialty],
      [t.get('portfolio_field_stage'), profile.stage],
      [t.get('portfolio_field_school'), profile.schoolName],
      [t.get('portfolio_field_year'), profile.academicYear],
    ].where((row) => (row[1] ?? '').isNotEmpty);

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          t.get('portfolio_pdf_cover_title'),
          style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _primary),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(portfolio.title, style: pw.TextStyle(fontSize: 16, color: _muted)),
        pw.SizedBox(height: 32),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _border),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              for (final row in rows)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                  child: pw.Row(children: [
                    pw.SizedBox(
                      width: 110,
                      child: pw.Text(row[0]!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(child: pw.Text(row[1]!)),
                  ]),
                ),
            ],
          ),
        ),
        if (portfolio.isPublic && (portfolio.shareUrl ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 32),
          pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: portfolio.shareUrl!, width: 110, height: 110),
        ],
      ],
    );
  }

  static List<pw.Widget> _itemSection(int number, PortfolioItemModel item, Map<int, Uint8List> images) {
    final imageFiles = item.files.where((f) => images.containsKey(f.id)).toList();
    final otherFiles = item.files.where((f) => !images.containsKey(f.id)).toList();

    return [
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(color: _primaryLight, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Text(
          '$number. ${item.title}',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary),
        ),
      ),
      if ((item.description ?? '').isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(item.description!, style: pw.TextStyle(color: _muted)),
        ),
      if (item.files.isEmpty)
        pw.Text(appTranslation().get('portfolio_no_evidence'), style: pw.TextStyle(color: _muted)),
      // Two images per row; each row is its own child so pages can break between rows.
      for (var i = 0; i < imageFiles.length; i += 2)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(children: [
            for (final file in imageFiles.skip(i).take(2))
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                  child: pw.Image(pw.MemoryImage(images[file.id]!), height: 220, fit: pw.BoxFit.contain),
                ),
              ),
            if (imageFiles.length - i == 1) pw.Expanded(child: pw.SizedBox()),
          ]),
        ),
      for (final file in otherFiles)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(children: [
            pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: file.url, width: 44, height: 44),
            pw.SizedBox(width: 10),
            pw.Expanded(child: pw.Text(file.displayName)),
          ]),
        ),
    ];
  }

  static pw.Widget _signatures(List<PortfolioSignatureModel> signatures) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _heading(appTranslation().get('portfolio_signatures')),
        pw.SizedBox(height: 40),
        pw.Wrap(
          spacing: 40,
          runSpacing: 50,
          children: [
            for (final signature in signatures)
              pw.SizedBox(
                width: 220,
                child: pw.Column(children: [
                  pw.Text(signature.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text(signature.name ?? ''),
                  pw.SizedBox(height: 30),
                  pw.Divider(color: _muted),
                ]),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _heading(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primary)),
      );
}
