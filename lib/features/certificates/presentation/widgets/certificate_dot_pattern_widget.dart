import 'package:flutter/material.dart';

/// Repeating radial dot pattern matching the React `Pattern` component:
/// `radial-gradient(circle_at_20px_20px, #000 2px, transparent 0)`
/// repeated at 42px × 42px intervals, opacity 0.08.
class CertificateDotPatternWidget extends StatelessWidget {
  const CertificateDotPatternWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DotPatternPainter(),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const spacing = 42.0;
    const dotRadius = 2.0;

    for (double x = spacing * 0.5; x < size.width + spacing; x += spacing) {
      for (double y = spacing * 0.5; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
