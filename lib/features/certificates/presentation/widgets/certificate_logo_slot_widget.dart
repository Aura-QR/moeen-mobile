import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';

/// A 128×96 white rounded box that shows either an image asset or a text
/// fallback — matching the React `LogoSlot` component exactly.
///
/// Container spec: `h-24 w-32 rounded-3xl bg-white/95 p-2 shadow-xl ring-1 ring-black/5`
/// All dimensions are at the 1080-base scale.
class CertificateLogoSlotWidget extends StatelessWidget {
  final String assetPath;
  final double imageWidth;
  final double imageHeight;
  final String fallbackLine1;
  final String fallbackLine2;
  final CertificateTemplateModel template;

  const CertificateLogoSlotWidget({
    super.key,
    required this.assetPath,
    required this.imageWidth,
    required this.imageHeight,
    required this.fallbackLine1,
    required this.fallbackLine2,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 96,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        assetPath,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Text(
          '$fallbackLine1\n$fallbackLine2',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: template.darkColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
