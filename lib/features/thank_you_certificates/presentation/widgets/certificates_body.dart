import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_design_section.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_header_section.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_names_section.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_preview_card.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_reason_section.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_text_section.dart';

/// The four steps (names, design, data, text), then the preview and the header.
class CertificatesBody extends StatelessWidget {
  const CertificatesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const CertificatesNamesSection(),
        verticalSpace14,
        const CertificatesDesignSection(),
        verticalSpace14,
        const CertificatesReasonSection(),
        verticalSpace14,
        const CertificatesTextSection(),
        verticalSpace14,
        const CertificatesPreviewCard(),
        verticalSpace14,
        const CertificatesHeaderSection(),
      ],
    );
  }
}
