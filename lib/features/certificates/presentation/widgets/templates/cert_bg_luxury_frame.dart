import 'package:flutter/material.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';

/// Template 2 — "إطار فاخر" (Luxury Frame)
///
/// React reference:
/// ```
/// <div absolute inset-0 bg-soft />
/// <div absolute inset-8  rounded-[44px] border-[4px] border-accent/35 />
/// <div absolute inset-14 rounded-[34px] border border-accent/35 />
/// <div absolute left-10 top-10  h-24 w-24 rounded-br-[80px] border-l-[8px] border-t-[8px] border-accent />
/// <div absolute right-10 bottom-10 h-24 w-24 rounded-tl-[80px] border-b-[8px] border-r-[8px] border-accent />
/// ```
/// Tailwind scale: 1 unit = 4px.
///   inset-8  = 32px, inset-14 = 56px
///   h-24 w-24 = 96×96px, left-10 top-10 = 40px, rounded-*-[80px] = 80px radius
class CertBgLuxuryFrame extends StatelessWidget {
  final CertificateTemplateModel template;

  const CertBgLuxuryFrame({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final accent = template.primaryColor;

    return Stack(
      children: [
        // ── Base soft background ────────────────────────────────────────
        Positioned.fill(
          child: Container(color: template.bgColor),
        ),

        // ── Outer frame  inset-8 rounded-[44px] border-[4px] accent/35 ──
        Positioned(
          left: 32,
          right: 32,
          top: 32,
          bottom: 32,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 4,
              ),
            ),
          ),
        ),

        // ── Inner frame  inset-14 rounded-[34px] border-[1px] accent/35 ──
        Positioned(
          left: 56,
          right: 56,
          top: 56,
          bottom: 56,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
        ),

        // ── Top-left L-shaped corner accent ────────────────────────────
        // `h-24 w-24 rounded-br-[80px] border-l-[8px] border-t-[8px]`
        Positioned(
          left: 40,
          top: 40,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(80),
              ),
              border: Border(
                left: BorderSide(color: accent, width: 8),
                top: BorderSide(color: accent, width: 8),
              ),
            ),
          ),
        ),

        // ── Bottom-right L-shaped corner accent ────────────────────────
        // `h-24 w-24 rounded-tl-[80px] border-b-[8px] border-r-[8px]`
        Positioned(
          right: 40,
          bottom: 40,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(80),
              ),
              border: Border(
                right: BorderSide(color: accent, width: 8),
                bottom: BorderSide(color: accent, width: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
