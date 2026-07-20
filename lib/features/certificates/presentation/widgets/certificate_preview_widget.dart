import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/domain/entities/certificate_data.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_bg_widget.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_logo_slot_widget.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_signature_widget.dart';

/// Full-fidelity live certificate preview.
///
/// Matches the React `CertificatePreview` component pixel-for-pixel:
///   - aspect ratio 1.414 : 1  (A4 landscape)
///   - built internally at 1080 × 763.5 px (React base size)
///   - scaled via [Transform.scale] to fit the available width
///   - minimum display width 680 px with horizontal scroll support
///
/// The parent must wrap this widget in a [SingleChildScrollView] with
/// `scrollDirection: Axis.horizontal` to allow the minimum width on narrow
/// screens.
class CertificatePreviewWidget extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;
  final double availableWidth;

  const CertificatePreviewWidget({
    super.key,
    required this.template,
    required this.data,
    required this.availableWidth,
  });

  // ── Geometry constants (all in React / 1080-base pixels) ──────────────
  static const double _baseWidth = 1080.0;
  static const double _baseHeight = _baseWidth / 1.414; // ≈ 763.5 px

  /// Minimum display width (px) before the preview becomes horizontally
  /// scrollable. Chosen so text remains legible at the resulting scale.
  static const double _minDisplayWidth = 680.0;

  @override
  Widget build(BuildContext context) {
    final displayWidth = math.max(availableWidth, _minDisplayWidth);
    final scale = displayWidth / _baseWidth;
    final displayHeight = _baseHeight * scale;

    return SizedBox(
      width: displayWidth,
      height: displayHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: _baseWidth,
          height: _baseHeight,
          child: ClipRect(
            child: _CertificateCanvas(
              template: template,
              data: data,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Canvas (built at 1080×763.5 base) ─────────────────────────────────────

class _CertificateCanvas extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;

  const _CertificateCanvas({
    required this.template,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Layer 0: Template background ──────────────────────────────
        Positioned.fill(
          child: CertificateBgWidget(template: template),
        ),

        // ── Layer 1: Content (z-10 in React) ──────────────────────────
        Positioned.fill(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              // px-20 py-12 → horizontal 80px, vertical 48px
              padding: const EdgeInsets.symmetric(
                horizontal: 80,
                vertical: 48,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 920, // 1080 (baseWidth) - 160 (horizontal padding)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _LogoRow(template: template),
                      const SizedBox(height: 32),
                      _TitleBlock(template: template, data: data),
                      const SizedBox(height: 32),
                      _StudentRow(template: template, data: data),
                      const SizedBox(height: 40),
                      _ReasonText(data: data),
                      const SizedBox(height: 24),
                      _FooterRow(template: template, data: data),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Logo row ───────────────────────────────────────────────────────────────

/// React: `dir="ltr"` row with Vision-2030 on the left, Ministry on the right.
/// `gap-5` = 20px between logos.
class _LogoRow extends StatelessWidget {
  final CertificateTemplateModel template;

  const _LogoRow({required this.template});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // رؤية 2030 — left slot
          CertificateLogoSlotWidget(
            assetPath: 'assets/images/roaa.png',
            imageWidth: 104,
            imageHeight: 72,
            fallbackLine1: 'رؤية',
            fallbackLine2: '2030',
            template: template,
          ),
          const SizedBox(width: 20),
          // وزارة التعليم — right slot
          CertificateLogoSlotWidget(
            assetPath: 'assets/images/minstry.jpg',
            imageWidth: 112,
            imageHeight: 78,
            fallbackLine1: 'وزارة',
            fallbackLine2: 'التعليم',
            template: template,
          ),
        ],
      ),
    );
  }
}

// ── Title + school line ────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;

  const _TitleBlock({required this.template, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // "شهادة شكر وتقدير" — text-5xl (48px) font-black, color=dark, drop-shadow
        Text(
          'شهادة شكر وتقدير',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: template.darkColor,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // School line — text-2xl (24px) font-bold
        _SchoolLine(template: template, data: data),
      ],
    );
  }
}

/// React: `"يسر إدارة مدرسة" + pill(schoolName) + "أن تتقدم بوافر الشكر والتقدير"`
/// pill: min-w-[285px] justify-center rounded-full bg-accent px-8 py-2 text-white shadow-md mx-3
class _SchoolLine extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;

  const _SchoolLine({required this.template, required this.data});

  @override
  Widget build(BuildContext context) {
    const slateStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xFF475569),
      fontFamily: 'Tajawal',
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text('يسر إدارة مدرسة', style: slateStyle),

        // school name pill
        Container(
          constraints: const BoxConstraints(minWidth: 285),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
            color: template.primaryColor,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: template.primaryColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            data.schoolName,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        Text('أن تتقدم بوافر الشكر والتقدير', style: slateStyle),
      ],
    );
  }
}

// ── Student row ────────────────────────────────────────────────────────────

/// React: 4-column grid `[1fr auto 1.25fr auto]`, text-2xl, gap-5.
/// Columns (RTL order, right→left):
///   "للطالب/ة"  |  name pill (min-w 420)  |  class pill (1.25fr)  |  "الصف"
class _StudentRow extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;

  const _StudentRow({required this.template, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Col 1 — "للطالب/ة"  (1fr, text-left in RTL = align start)
        Expanded(
          flex: 4,
          child: Text(
            data.studentLabel,
            textAlign: TextAlign.start,
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Col 2 — student name pill  min-w-[420px] gradient rounded-full
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 420),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [template.primaryColor, template.darkColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: template.darkColor.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              data.studentName,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Col 3 — class pill  (1.25fr, rounded-full, bg-accent)
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: template.primaryColor,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: template.primaryColor.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              data.className,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Col 4 — "الصف" label  (auto)
        Text(
          'الصف',
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

// ── Reason / certificate body text ────────────────────────────────────────

/// React: `mx-auto mt-10 max-w-[850px] text-center text-3xl font-bold
///          leading-[1.85] text-slate-800`
class _ReasonText extends StatelessWidget {
  final CertificateData data;

  const _ReasonText({required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Text(
          data.certText,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.85,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}

// ── Footer row ─────────────────────────────────────────────────────────────

/// React: `mt-auto grid grid-cols-3 items-end gap-8`
///   Col1: Signature(principal)
///   Col2: circular seal + date pill (centered)
///   Col3: Signature(teacher)
class _FooterRow extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;

  const _FooterRow({required this.template, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Principal signature
        Expanded(
          child: Center(
            child: CertificateSignatureWidget(
              title: 'المدير',
              name: data.principalName,
              template: template,
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Seal + date
        _SealAndDate(template: template, data: data),
        const SizedBox(width: 32),

        // Teacher signature
        Expanded(
          child: Center(
            child: CertificateSignatureWidget(
              title: 'المعلم',
              name: data.teacherName,
              template: template,
            ),
          ),
        ),
      ],
    );
  }
}

/// React:
/// ```
/// <div h-24 w-24 rounded-full border-[5px] border-accent bg-white/70 shadow-xl
///      text-11px font-black leading-5 text-dark>شهادة<br/>حضّر</div>
/// <p rounded-full bg-soft px-5 py-2 text-sm font-black text-dark>{date}</p>
/// ```
class _SealAndDate extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateData data;

  const _SealAndDate({required this.template, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular seal
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.70),
            border: Border.all(
              color: template.primaryColor,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'شهادة\nحضّر',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.5,
              color: template.darkColor,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Date pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: template.bgColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            data.certDate,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: template.darkColor,
            ),
          ),
        ),
      ],
    );
  }
}
