import 'package:flutter/material.dart';

/// A [CustomPainter] that draws a uniform dot-grid pattern.
/// Used as a decorative background element across multiple screens.
class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double dotRadius;

  const DotGridPainter({
    required this.color,
    this.spacing = 16.0,
    this.dotRadius = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.dotRadius != dotRadius;
  }
}
