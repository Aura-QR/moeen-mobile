import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';

/// Signature block used in the certificate footer.
///
/// Matches the React `Signature` component:
/// ```
/// <p text-2xl font-bold>{title}</p>
/// <div mx-auto mt-3 h-1 w-56 rounded-full bg-accent />
/// <p mt-4 text-2xl font-bold>{name}</p>
/// ```
/// All dimensions are at the 1080-base scale (no scaling needed — the parent
/// [CertificatePreviewWidget] applies Transform.scale).
class CertificateSignatureWidget extends StatelessWidget {
  final String title;
  final String name;
  final CertificateTemplateModel template;

  const CertificateSignatureWidget({
    super.key,
    required this.title,
    required this.name,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 224,
          height: 4,
          decoration: BoxDecoration(
            color: template.primaryColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
