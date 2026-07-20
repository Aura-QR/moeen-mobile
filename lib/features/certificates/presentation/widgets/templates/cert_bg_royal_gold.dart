import 'package:flutter/material.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_dot_pattern_widget.dart';

/// Template 4 — "ذهبي ملكي" (Royal Gold)
///
/// React reference:
/// ```
/// <div absolute inset-0 bg-soft />
/// <div absolute inset-x-0 top-0 h-36 bg-gradient-to-l from-dark via-#3B2F1E to-dark />
/// <div absolute inset-x-20 top-12 h-28 rounded-b-[100px] border-b-[12px] border-gold />
/// <div absolute inset-10 rounded-[42px] border-[3px] border-gold/75 />
/// <Pattern />
/// ```
/// Tailwind:
///   h-36 = 144px,  inset-x-20 = 80px,  top-12 = 48px,  h-28 = 112px,
///   rounded-b-[100px] = 100px bottom radius only,  border-b-[12px] = 12px bottom border only,
///   inset-10 = 40px.
class CertBgRoyalGold extends StatelessWidget {
  final CertificateTemplateModel template;

  const CertBgRoyalGold({super.key, required this.template});

  static const Color _midBrown = Color(0xFF3B2F1E);

  @override
  Widget build(BuildContext context) {
    final dark = template.darkColor;
    final gold = template.goldColor;

    return Stack(
      children: [
        // ── Base soft background ────────────────────────────────────────
        Positioned.fill(
          child: Container(color: template.bgColor),
        ),

        // ── Dark header  h-36 gradient from-dark via-midBrown to-dark ──
        // `bg-gradient-to-l from-dark via-#3B2F1E to-dark` (symmetric)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 144, // h-36
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [dark, _midBrown, dark],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── Gold arc  inset-x-20 top-12 h-28 rounded-b-[100px] border-b-[12px] gold ──
        // Only the bottom border and bottom border-radius is drawn — creating a
        // "U-shaped" gold arc that peeks below the dark header.
        Positioned(
          left: 80, // inset-x-20 = 80px
          right: 80,
          top: 48, // top-12 = 48px
          child: Container(
            height: 112, // h-28
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
              border: Border(
                bottom: BorderSide(color: gold, width: 12),
              ),
            ),
          ),
        ),

        // ── Gold full frame  inset-10 rounded-[42px] border-[3px] gold/75 ──
        Positioned(
          left: 40, // inset-10 = 40px
          right: 40,
          top: 40,
          bottom: 40,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(42),
              border: Border.all(
                color: gold.withValues(alpha: 0.75),
                width: 3,
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
