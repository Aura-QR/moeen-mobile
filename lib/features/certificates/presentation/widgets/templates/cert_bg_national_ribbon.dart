import 'package:flutter/material.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_dot_pattern_widget.dart';

/// Template 1 — "رسمي سعودي" (National Ribbon)
///
/// React reference:
/// ```
/// <div absolute inset-x-0 top-0 h-[215px] bg-gradient-to-br from-accent to-dark />
/// <div absolute inset-x-[-6%] top-[132px] h-[120px] rounded-[0_0_50%_50%] bg-white />
/// <div absolute inset-x-14 top-[236px] h-px bg-accent/25 />
/// <Pattern />
/// ```
/// All coordinates assume the 1080-base width; the parent scales via Transform.scale.
class CertBgNationalRibbon extends StatelessWidget {
  final CertificateTemplateModel template;

  const CertBgNationalRibbon({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    // The React cert is 1080×763.5. The arch is absolutely wider (-6% = -64.8px each side).
    // We hard-code the 1080-base arithmetic and let the parent Transform.scale handle display.
    const certWidth = 1080.0;
    const overdraw = certWidth * 0.06; // 64.8px

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Base background ─────────────────────────────────────────────
        Positioned.fill(
          child: Container(color: Colors.white),
        ),

        // ── Gradient header band  h-[215px] bg-gradient-to-br ──────────
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 215,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [template.primaryColor, template.darkColor],
              ),
            ),
          ),
        ),

        // ── White curved arch  top-[132px] h-[120px] rounded-[0_0_50%_50%] ──
        // Extends -6% beyond each side to create the elliptical curve at the bottom.
        Positioned(
          top: 132,
          left: -overdraw,
          right: -overdraw,
          child: LayoutBuilder(
            builder: (_, constraints) {
              final w = certWidth + overdraw * 2; // 1209.6
              return Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(w / 2, 120),
                    bottomRight: Radius.elliptical(w / 2, 120),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Thin horizontal divider  inset-x-14 top-[236px] h-px accent/25 ──
        Positioned(
          left: 56, // inset-x-14 = 14*4 = 56px
          right: 56,
          top: 236,
          child: Container(
            height: 1,
            color: template.primaryColor.withValues(alpha: 0.25),
          ),
        ),

        // ── Repeating dot pattern ──────────────────────────────────────
        const CertificateDotPatternWidget(),
      ],
    );
  }
}
