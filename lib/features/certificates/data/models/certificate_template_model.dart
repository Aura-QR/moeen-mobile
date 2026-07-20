import 'package:flutter/material.dart';

/// Visual style of each certificate template background.
enum CertificateTemplateStyle {
  nationalRibbon,
  luxuryFrame,
  blueAcademic,
  royalGold,
  modernCorner,
  minimalStamp,
}

class CertificateTemplateModel {
  final int id;

  /// Primary accent colour (top gradient, pills, borders).
  final Color primaryColor;

  /// Darker shade of primary (gradient end, corner accents).
  final Color darkColor;

  /// Soft / light background colour.
  final Color bgColor;

  /// Gold accent colour (arc borders, frame borders).
  final Color goldColor;

  /// Main text colour.
  final Color textColor;

  /// Kept for backward-compatibility with the PDF generation layer.
  final Color accentColor;

  /// Background visual style applied by [CertificateBgWidget].
  final CertificateTemplateStyle style;

  /// Short Arabic name shown in the selector (e.g. "قالب 1").
  final String name;

  /// Descriptive Arabic label shown below the name (e.g. "رسمي سعودي").
  final String label;

  const CertificateTemplateModel({
    required this.id,
    required this.primaryColor,
    required this.darkColor,
    required this.bgColor,
    required this.goldColor,
    required this.textColor,
    required this.accentColor,
    required this.style,
    required this.name,
    required this.label,
  });

  /// All 6 certificate templates matching the React design reference.
  static const List<CertificateTemplateModel> all = [
    // ── Template 1 ── nationalRibbon ──────────────────────────────────────
    CertificateTemplateModel(
      id: 0,
      primaryColor: Color(0xFF0E9F86),
      darkColor: Color(0xFF065F55),
      bgColor: Color(0xFFF4FFFB),
      goldColor: Color(0xFFE2AD3B),
      textColor: Color(0xFF1E293B),
      accentColor: Color(0xFF24B998),
      style: CertificateTemplateStyle.nationalRibbon,
      name: 'قالب 1',
      label: 'رسمي سعودي',
    ),
    // ── Template 2 ── luxuryFrame ─────────────────────────────────────────
    CertificateTemplateModel(
      id: 1,
      primaryColor: Color(0xFF238B83),
      darkColor: Color(0xFF163E47),
      bgColor: Color(0xFFF8FCFB),
      goldColor: Color(0xFFCFA44A),
      textColor: Color(0xFF1E293B),
      accentColor: Color(0xFF2FB8AD),
      style: CertificateTemplateStyle.luxuryFrame,
      name: 'قالب 2',
      label: 'إطار فاخر',
    ),
    // ── Template 3 ── blueAcademic ────────────────────────────────────────
    CertificateTemplateModel(
      id: 2,
      primaryColor: Color(0xFF2377B8),
      darkColor: Color(0xFF153B5B),
      bgColor: Color(0xFFF4FAFF),
      goldColor: Color(0xFFE2AD3B),
      textColor: Color(0xFF1E293B),
      accentColor: Color(0xFF3B8FD8),
      style: CertificateTemplateStyle.blueAcademic,
      name: 'قالب 3',
      label: 'تعليمي أزرق',
    ),
    // ── Template 4 ── royalGold ───────────────────────────────────────────
    CertificateTemplateModel(
      id: 3,
      primaryColor: Color(0xFFD7A13B),
      darkColor: Color(0xFF20242B),
      bgColor: Color(0xFFFFF9EC),
      goldColor: Color(0xFFF0C96A),
      textColor: Color(0xFF1E293B),
      accentColor: Color(0xFFEDBC5A),
      style: CertificateTemplateStyle.royalGold,
      name: 'قالب 4',
      label: 'ذهبي ملكي',
    ),
    // ── Template 5 ── modernCorner ────────────────────────────────────────
    CertificateTemplateModel(
      id: 4,
      primaryColor: Color(0xFF16A085),
      darkColor: Color(0xFF123C4A),
      bgColor: Color(0xFFFFFDF8),
      goldColor: Color(0xFFF4BE3B),
      textColor: Color(0xFF1E293B),
      accentColor: Color(0xFF24B998),
      style: CertificateTemplateStyle.modernCorner,
      name: 'قالب 5',
      label: 'زوايا حديثة',
    ),
    // ── Template 6 ── minimalStamp ────────────────────────────────────────
    CertificateTemplateModel(
      id: 5,
      primaryColor: Color(0xFF0E7A5E),
      darkColor: Color(0xFF075244),
      bgColor: Color(0xFFF7FCFA),
      goldColor: Color(0xFFE2AD3B),
      textColor: Color(0xFF1E293B),
      accentColor: Color(0xFF1A9E7A),
      style: CertificateTemplateStyle.minimalStamp,
      name: 'قالب 6',
      label: 'ختم بسيط',
    ),
  ];
}
