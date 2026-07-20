import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';

/// Template selector card with a pixel-matched mini thumbnail.
///
/// The thumbnail replicates the React `TemplateThumbnail` component:
/// ```
/// Soft-bg base
/// Top gradient header  (h-12 of h-28 container ≈ 43%)
/// Two white/85% logo-box rects in the top corners
/// Two content-line placeholders in the center
/// Accent-colored strip bottom-left, dark-colored strip bottom-right
/// modernCorner: extra colored squares at corners
/// ```
class CertificateTemplateCardWidget extends StatelessWidget {
  final CertificateTemplateModel template;
  final bool isSelected;
  final VoidCallback onTap;

  const CertificateTemplateCardWidget({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 14 : 15),
          child: Column(
            children: [
              // Thumbnail takes most of the card height
              Expanded(
                child: _TemplateThumbnail(template: template),
              ),
              // Label row at the bottom
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: ColorsManager.mainText,
                            ),
                          ),
                          Text(
                            template.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ColorsManager.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini thumbnail matching the React TemplateThumbnail:
/// ```
/// <div relative h-28 overflow-hidden style={{background: soft}}>
///   <div absolute inset-x-0 top-0 h-12 gradient(accent→dark) />
///   <div absolute left-4  top-4 h-6 w-10 rounded-lg bg-white/85 />  ← logo box L
///   <div absolute right-4 top-4 h-6 w-10 rounded-lg bg-white/85 />  ← logo box R
///   <div absolute left-1/2 top-14  h-2.5 w-36 -translate-x-1/2 rounded-full bg-slate-300 />
///   <div absolute left-1/2 top-19  h-2   w-24 -translate-x-1/2 rounded-full bg-slate-200 />
///   <div absolute bottom-0 left-0  h-8 w-32 rounded-tr-[42px] accent/72 />
///   <div absolute bottom-0 right-0 h-8 w-32 rounded-tl-[42px] dark/72  />
///   {modernCorner: 2 extra colored squares at top-left and bottom-right}
/// </div>
/// ```
/// All px values are Tailwind 1-unit=4px: h-12=48, h-8=32, w-10=40, w-32=128,
/// h-6=24, h-2.5=10, h-2=8, w-36=144, w-24=96, top-14=56, top-19=76, left-4=16.
class _TemplateThumbnail extends StatelessWidget {
  final CertificateTemplateModel template;

  const _TemplateThumbnail({required this.template});

  bool get _isRoyalGold =>
      template.style == CertificateTemplateStyle.royalGold;

  bool get _isModernCorner =>
      template.style == CertificateTemplateStyle.modernCorner;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Scale factor from the React 200px-wide thumbnail reference
        final s = w / 200.0;

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Base background ──────────────────────────────────────
              Positioned.fill(
                child: Container(color: template.bgColor),
              ),

              // ── Top gradient header  h-12 (48px) ────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 48 * s,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: _isRoyalGold
                          ? [
                              template.darkColor,
                              const Color(0xFF4A3416),
                              template.primaryColor,
                            ]
                          : [template.primaryColor, template.darkColor],
                    ),
                  ),
                ),
              ),

              // ── Logo box left  left-4(16) top-4(16) h-6(24) w-10(40) ──
              Positioned(
                left: 16 * s,
                top: 16 * s,
                child: Container(
                  width: 40 * s,
                  height: 24 * s,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6 * s),
                  ),
                ),
              ),

              // ── Logo box right  right-4(16) top-4(16) h-6(24) w-10(40) ──
              Positioned(
                right: 16 * s,
                top: 16 * s,
                child: Container(
                  width: 40 * s,
                  height: 24 * s,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6 * s),
                  ),
                ),
              ),

              // ── Title line placeholder  top-14(56) h-2.5(10) w-36(144) ──
              Positioned(
                left: w / 2 - 72 * s,
                top: 56 * s,
                child: Container(
                  width: 144 * s,
                  height: 10 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(5 * s),
                  ),
                ),
              ),

              // ── Sub-line placeholder  top-19(76) h-2(8) w-24(96) ───
              Positioned(
                left: w / 2 - 48 * s,
                top: 76 * s,
                child: Container(
                  width: 96 * s,
                  height: 8 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4 * s),
                  ),
                ),
              ),

              // ── Bottom-left accent strip  h-8(32) w-32(128) rounded-tr-[42px] ──
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 128 * s,
                  height: 32 * s,
                  decoration: BoxDecoration(
                    color: template.primaryColor.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(42 * s),
                    ),
                  ),
                ),
              ),

              // ── Bottom-right dark strip  h-8(32) w-32(128) rounded-tl-[42px] ──
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 128 * s,
                  height: 32 * s,
                  decoration: BoxDecoration(
                    color: template.darkColor.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(42 * s),
                    ),
                  ),
                ),
              ),

              // ── modernCorner: extra colored squares ──────────────────
              if (_isModernCorner) ...[
                // top-left pink  h-14(56) w-14(56)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 56 * s,
                    height: 56 * s,
                    color: const Color(0xFFF4436C),
                  ),
                ),
                // bottom-right blue  h-14(56) w-14(56)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 56 * s,
                    height: 56 * s,
                    color: const Color(0xFF2377B8),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
