import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the printable portfolio. Mirrors the website's shared view
/// (`haderedu.com/portfolio/{token}`): cover, index, one chapter per included
/// item with its evidence two per row, and a signatures page.
class PortfolioPdfService {
  // Tailwind colors used by the website.
  static final PdfColor _ink = PdfColor.fromHex('102138');
  static final PdfColor _emerald800 = PdfColor.fromHex('065F46');
  static final PdfColor _emerald700 = PdfColor.fromHex('047857');
  static final PdfColor _emerald600 = PdfColor.fromHex('059669');
  static final PdfColor _emerald100 = PdfColor.fromHex('D1FAE5');
  static final PdfColor _emerald50 = PdfColor.fromHex('ECFDF5');
  static final PdfColor _slate800 = PdfColor.fromHex('1E293B');
  static final PdfColor _slate700 = PdfColor.fromHex('334155');
  static final PdfColor _slate600 = PdfColor.fromHex('475569');
  static final PdfColor _slate500 = PdfColor.fromHex('64748B');
  static final PdfColor _slate400 = PdfColor.fromHex('94A3B8');
  static final PdfColor _slate200 = PdfColor.fromHex('E2E8F0');
  static final PdfColor _slate50 = PdfColor.fromHex('F8FAFC');

  static const double _margin = 12 * PdfPageFormat.mm;

  /// [images] maps a file id to its downloaded bytes.
  static Future<Uint8List> build({
    required PortfolioModel portfolio,
    required Map<int, Uint8List> images,
  }) async {
    final fonts = _Fonts(
      regular: pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Regular.ttf')),
      semiBold: pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Medium.ttf')),
      bold: pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Bold.ttf')),
      black: pw.Font.ttf(await rootBundle.load('assets/fonts/Tajawal-Black.ttf')),
    );
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold));
    final profile = portfolio.profile ?? const PortfolioProfileModel();
    final items = portfolio.includedItems;

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      textDirection: pw.TextDirection.rtl,
      build: (_) => _cover(portfolio, profile, fonts),
    ));

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(_margin),
      textDirection: pw.TextDirection.rtl,
      build: (_) => [
        _sectionTitle('portfolio_pdf_contents_label', 'portfolio_pdf_index', fonts, size: 24),
        pw.SizedBox(height: 18),
        for (var i = 0; i < items.length; i++) _indexRow(i, items[i], isFirst: i == 0, fonts: fonts),
      ],
    ));

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(_margin),
      textDirection: pw.TextDirection.rtl,
      build: (_) => [
        for (var i = 0; i < items.length; i++) ..._chapter(i + 1, items[i], images, fonts),
      ],
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(_margin),
      textDirection: pw.TextDirection.rtl,
      build: (_) => _signatures(profile.signatures, fonts),
    ));

    return doc.save();
  }

  static pw.Widget _cover(PortfolioModel portfolio, PortfolioProfileModel profile, _Fonts fonts) {
    final t = appTranslation().get;
    final year = profile.academicYear ?? '';
    final fields = [
      ('portfolio_pdf_teacher_name', profile.name),
      ('portfolio_pdf_role', portfolio.roleLabel),
      ('portfolio_field_specialty', profile.specialty),
      ('portfolio_field_stage', profile.stage),
      ('portfolio_field_school', profile.schoolName),
      ('portfolio_field_year', profile.academicYear),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(height: 9, color: _emerald700),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(40, 28, 40, 28),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 14),
                  decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _emerald100))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(t('portfolio_pdf_brand'), style: pw.TextStyle(font: fonts.black, fontSize: 18, color: _emerald700)),
                      pw.Text(
                        t('portfolio_pdf_year').replaceAll('{year}', year.isEmpty ? '—' : year),
                        style: pw.TextStyle(font: fonts.semiBold, fontSize: 10.5, color: _slate500),
                      ),
                    ],
                  ),
                ),
                pw.Column(children: [
                  pw.Container(
                    width: 60,
                    height: 60,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: _emerald50,
                      border: pw.Border.all(color: _emerald100),
                      borderRadius: pw.BorderRadius.circular(18),
                    ),
                    child: pw.Text(t('portfolio_pdf_brand'), style: pw.TextStyle(font: fonts.black, fontSize: 13.5, color: _emerald700)),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(t('portfolio_pdf_cover_title'), style: pw.TextStyle(font: fonts.bold, fontSize: 13.5, color: _emerald700)),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    portfolio.title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: fonts.black, fontSize: 27, color: _ink, lineSpacing: 6),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(portfolio.roleLabel, style: pw.TextStyle(fontSize: 13.5, color: _slate600)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 84,
                    height: 3,
                    decoration: pw.BoxDecoration(color: _emerald600, borderRadius: pw.BorderRadius.circular(2)),
                  ),
                ]),
                pw.Container(
                  padding: const pw.EdgeInsets.all(18),
                  decoration: pw.BoxDecoration(
                    color: _slate50,
                    border: pw.Border.all(color: _slate200),
                    borderRadius: pw.BorderRadius.circular(18),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(t('portfolio_basic_info'), style: pw.TextStyle(font: fonts.black, fontSize: 13.5, color: _ink)),
                      pw.SizedBox(height: 14),
                      for (var i = 0; i < fields.length; i += 2)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 14),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              for (final (labelKey, value) in fields.skip(i).take(2))
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(t(labelKey), style: pw.TextStyle(fontSize: 9, color: _slate500)),
                                      pw.SizedBox(height: 3),
                                      pw.Text(
                                        (value ?? '').isEmpty ? '—' : value!,
                                        style: pw.TextStyle(font: fonts.bold, fontSize: 10.5, color: _slate800),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 12),
                  decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _emerald100))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(t('portfolio_pdf_footer_platform'), style: pw.TextStyle(fontSize: 9, color: _slate500)),
                      pw.Text(t('portfolio_pdf_footer_title'), style: pw.TextStyle(fontSize: 9, color: _slate500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// A small emerald label above a large black heading, underlined.
  static pw.Widget _sectionTitle(String labelKey, String titleKey, _Fonts fonts, {required double size}) {
    final t = appTranslation().get;
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _emerald700, width: 2))),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(t(labelKey), style: pw.TextStyle(font: fonts.bold, fontSize: 10.5, color: _emerald700)),
          pw.SizedBox(height: 6),
          pw.Text(t(titleKey), style: pw.TextStyle(font: fonts.black, fontSize: size, color: _ink)),
        ],
      ),
    );
  }

  /// Each row carries its own borders so a long index can break across pages.
  static pw.Widget _indexRow(int index, PortfolioItemModel item, {required bool isFirst, required _Fonts fonts}) {
    final side = pw.BorderSide(color: _slate200);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: isFirst ? side : pw.BorderSide.none,
          left: side,
          right: side,
          bottom: side,
        ),
      ),
      child: pw.Row(children: [
        pw.Container(
          width: 24,
          height: 24,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(color: _emerald50, borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Text(
            '${index + 1}'.padLeft(2, '0'),
            style: pw.TextStyle(font: fonts.black, fontSize: 10, color: _emerald700),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Text(item.title, style: pw.TextStyle(font: fonts.semiBold, fontSize: 11, color: _slate700)),
        ),
      ]),
    );
  }

  static List<pw.Widget> _chapter(int number, PortfolioItemModel item, Map<int, Uint8List> images, _Fonts fonts) {
    return [
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 6, bottom: 14),
        padding: const pw.EdgeInsets.only(bottom: 9),
        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _emerald100, width: 2))),
        child: pw.Row(children: [
          pw.Container(
            width: 30,
            height: 30,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(color: _emerald700, borderRadius: pw.BorderRadius.circular(9)),
            child: pw.Text('$number', style: pw.TextStyle(font: fonts.black, fontSize: 12, color: PdfColors.white)),
          ),
          pw.SizedBox(width: 9),
          pw.Expanded(
            child: pw.Text(item.title, style: pw.TextStyle(font: fonts.black, fontSize: 15, color: _ink)),
          ),
        ]),
      ),
      if ((item.description ?? '').isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 14),
          child: pw.Text(item.description!, style: pw.TextStyle(fontSize: 10.5, color: _slate700, lineSpacing: 4)),
        ),
      if (item.files.isEmpty)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _slate200, style: pw.BorderStyle.dashed),
            borderRadius: pw.BorderRadius.circular(9),
          ),
          child: pw.Text(appTranslation().get('portfolio_pdf_no_evidence'), style: pw.TextStyle(fontSize: 10.5, color: _slate500)),
        ),
      // Two proofs per row; each row is its own child so pages break between rows.
      for (var i = 0; i < item.files.length; i += 2)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4 * PdfPageFormat.mm),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _proof(item.files[i], _decode(images[item.files[i].id]), fonts)),
              pw.SizedBox(width: 4 * PdfPageFormat.mm),
              pw.Expanded(
                child: i + 1 < item.files.length
                    ? _proof(item.files[i + 1], _decode(images[item.files[i + 1].id]), fonts)
                    : pw.SizedBox(),
              ),
            ],
          ),
        ),
      pw.SizedBox(height: 8 * PdfPageFormat.mm),
    ];
  }

  /// Null when the bytes are missing or not an image, so one broken file
  /// shows as a link card instead of failing the whole PDF.
  static pw.MemoryImage? _decode(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  /// An image with its caption, or a card linking to a PDF or a URL.
  static pw.Widget _proof(PortfolioFileModel file, pw.MemoryImage? image, _Fonts fonts) {
    final t = appTranslation().get;
    final name = (file.title?.isNotEmpty ?? false)
        ? file.title!
        : (file.originalName?.isNotEmpty ?? false)
            ? file.originalName!
            : t(file.isLink ? 'portfolio_pdf_link_fallback' : 'portfolio_pdf_file_fallback');

    return pw.Container(
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _slate200),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: image != null
          ? pw.Column(children: [
              pw.UrlLink(
                destination: file.url,
                child: pw.Container(
                  height: 65 * PdfPageFormat.mm,
                  decoration: pw.BoxDecoration(color: _slate50, borderRadius: pw.BorderRadius.circular(9)),
                  child: pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
                ),
              ),
              pw.SizedBox(height: 9),
              pw.Text(name, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fonts.semiBold, fontSize: 10.5, color: _slate700)),
            ])
          : pw.Container(
              constraints: const pw.BoxConstraints(minHeight: 84),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(color: _emerald50, borderRadius: pw.BorderRadius.circular(9)),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(color: _emerald100, borderRadius: pw.BorderRadius.circular(6)),
                    child: pw.Text(
                      t(file.isLink ? 'portfolio_pdf_link_badge' : 'portfolio_pdf_file_badge'),
                      style: pw.TextStyle(font: fonts.black, fontSize: 9, color: _emerald800),
                    ),
                  ),
                  pw.SizedBox(height: 9),
                  pw.UrlLink(
                    destination: file.url,
                    child: pw.Text(
                      name,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonts.bold,
                        fontSize: 10,
                        color: _emerald800,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    t(file.isLink ? 'portfolio_pdf_link_label' : 'portfolio_pdf_file_label'),
                    style: pw.TextStyle(fontSize: 9, color: _slate500),
                  ),
                ],
              ),
            ),
    );
  }

  static pw.Widget _signatures(List<PortfolioSignatureModel> signatures, _Fonts fonts) {
    final t = appTranslation().get;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(height: 2, color: _emerald700),
        pw.SizedBox(height: 26),
        pw.Text(t('portfolio_pdf_approval'), style: pw.TextStyle(font: fonts.bold, fontSize: 10.5, color: _emerald700)),
        pw.SizedBox(height: 6),
        pw.Text(t('portfolio_signatures'), style: pw.TextStyle(font: fonts.black, fontSize: 18, color: _ink)),
        pw.SizedBox(height: 30),
        for (var i = 0; i < signatures.length; i += 2)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Row(children: [
              pw.Expanded(child: _signatureCard(signatures[i], fonts)),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: i + 1 < signatures.length ? _signatureCard(signatures[i + 1], fonts) : pw.SizedBox(),
              ),
            ]),
          ),
      ],
    );
  }

  static pw.Widget _signatureCard(PortfolioSignatureModel signature, _Fonts fonts) {
    final name = signature.name ?? '';
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _slate200),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(children: [
        pw.Text(signature.title, style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: _ink)),
        pw.SizedBox(height: 20),
        pw.Text(name.isEmpty ? '................................' : name, style: pw.TextStyle(fontSize: 10.5, color: _ink)),
        pw.SizedBox(height: 28),
        pw.Container(height: 0.8, color: _slate400),
        pw.SizedBox(height: 6),
        pw.Text(appTranslation().get('portfolio_pdf_signature'), style: pw.TextStyle(fontSize: 9, color: _slate500)),
      ]),
    );
  }
}

class _Fonts {
  final pw.Font regular;
  final pw.Font semiBold;
  final pw.Font bold;
  final pw.Font black;

  const _Fonts({required this.regular, required this.semiBold, required this.bold, required this.black});
}
