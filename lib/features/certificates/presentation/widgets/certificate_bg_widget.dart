import 'package:flutter/material.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/presentation/widgets/templates/cert_bg_blue_academic.dart';
import 'package:moean/features/certificates/presentation/widgets/templates/cert_bg_luxury_frame.dart';
import 'package:moean/features/certificates/presentation/widgets/templates/cert_bg_minimal_stamp.dart';
import 'package:moean/features/certificates/presentation/widgets/templates/cert_bg_modern_corner.dart';
import 'package:moean/features/certificates/presentation/widgets/templates/cert_bg_national_ribbon.dart';
import 'package:moean/features/certificates/presentation/widgets/templates/cert_bg_royal_gold.dart';

/// Routes to the correct background widget based on [template.style].
/// Used as the bottom layer of [CertificatePreviewWidget].
class CertificateBgWidget extends StatelessWidget {
  final CertificateTemplateModel template;

  const CertificateBgWidget({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return switch (template.style) {
      CertificateTemplateStyle.nationalRibbon =>
        CertBgNationalRibbon(template: template),
      CertificateTemplateStyle.luxuryFrame =>
        CertBgLuxuryFrame(template: template),
      CertificateTemplateStyle.blueAcademic =>
        CertBgBlueAcademic(template: template),
      CertificateTemplateStyle.royalGold =>
        CertBgRoyalGold(template: template),
      CertificateTemplateStyle.modernCorner =>
        const CertBgModernCorner(),
      CertificateTemplateStyle.minimalStamp =>
        CertBgMinimalStamp(template: template),
    };
  }
}
