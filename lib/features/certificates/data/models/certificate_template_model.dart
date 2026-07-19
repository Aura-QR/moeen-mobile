import 'package:flutter/material.dart';

class CertificateTemplateModel {
  final int id;
  final Color primaryColor;
  final Color accentColor;
  final Color bgColor;
  final Color textColor;

  const CertificateTemplateModel({
    required this.id,
    required this.primaryColor,
    required this.accentColor,
    required this.bgColor,
    required this.textColor,
  });

  static const List<CertificateTemplateModel> all = [
    CertificateTemplateModel(
      id: 0,
      primaryColor: Color(0xFF0E7A5E),
      accentColor: Color(0xFF24B998),
      bgColor: Color(0xFFE8F5F1),
      textColor: Color(0xFF1E293B),
    ),
    CertificateTemplateModel(
      id: 1,
      primaryColor: Color(0xFF1E4D8C),
      accentColor: Color(0xFF3B7DD8),
      bgColor: Color(0xFFEAF0FB),
      textColor: Color(0xFF1E293B),
    ),
    CertificateTemplateModel(
      id: 2,
      primaryColor: Color(0xFFC9A227),
      accentColor: Color(0xFFF5D76E),
      bgColor: Color(0xFFFBF5E6),
      textColor: Color(0xFF1E293B),
    ),
    CertificateTemplateModel(
      id: 3,
      primaryColor: Color(0xFF5B2C8D),
      accentColor: Color(0xFF9B59B6),
      bgColor: Color(0xFFF4ECF7),
      textColor: Color(0xFF1E293B),
    ),
    CertificateTemplateModel(
      id: 4,
      primaryColor: Color(0xFF0D2A24),
      accentColor: Color(0xFF24B998),
      bgColor: Color(0xFF071C18),
      textColor: Color(0xFFF4FFFC),
    ),
    CertificateTemplateModel(
      id: 5,
      primaryColor: Color(0xFFC9A227),
      accentColor: Color(0xFFF5D76E),
      bgColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF1E293B),
    ),
  ];
}
