import 'package:flutter/material.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_dot_pattern_widget.dart';

/// Template 6 — "ختم بسيط" (Minimal Stamp)
///
/// React reference (same default structure as blueAcademic, different colors):
/// ```
/// <div absolute inset-0 bg-soft />
/// <div absolute inset-8 rounded-[40px] border-[3px] border-accent/30 />
/// <div absolute inset-x-0 top-0 h-28 bg-gradient-to-l from-accent to-dark />
/// <Pattern />
/// ```
/// Tailwind: h-28 = 112px, inset-8 = 32px.
class CertBgMinimalStamp extends StatelessWidget {
  final CertificateTemplateModel template;

  const CertBgMinimalStamp({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Base soft background ────────────────────────────────────────
        Positioned.fill(
          child: Container(color: template.bgColor),
        ),

        // ── Border frame  inset-8 rounded-[40px] border-[3px] accent/30 ──
        Positioned(
          left: 32,
          right: 32,
          top: 32,
          bottom: 32,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: template.primaryColor.withValues(alpha: 0.30),
                width: 3,
              ),
            ),
          ),
        ),

        // ── Top gradient bar  h-28 from-accent(right) to-dark(left) ────
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 112, // h-28
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [template.primaryColor, template.darkColor],
              ),
            ),
          ),
        ),

        // ── Repeating dot pattern ──────────────────────────────────────
        const CertificateDotPatternWidget(),
      ],
    );
  }
}
