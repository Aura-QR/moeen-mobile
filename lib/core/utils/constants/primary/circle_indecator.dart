import 'package:flutter/material.dart';
import 'dart:math' as math;

class DiscreteCircle extends StatefulWidget {
  final double size;
  final Color color;
  final Color secondCircleColor;
  final Color thirdCircleColor;

  const DiscreteCircle({
    super.key,
    required this.color,
    required this.size,
    required this.secondCircleColor,
    required this.thirdCircleColor,
  });

  @override
  State<DiscreteCircle> createState() => _DiscreteCircleState();
}

class _DiscreteCircleState extends State<DiscreteCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // دالة بديلة للمكتبة الخارجية لعمل حسابات القيم بناءً على الوقت والمنحنى
  double _evalDouble({
    double from = 0.0,
    required double to,
    required double begin,
    required double end,
    Curve curve = Curves.linear,
  }) {
    final interval = Interval(begin, end, curve: curve);
    final progress = interval.transform(_controller.value);
    return from + (to - from) * progress;
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final double strokeWidth = size / 8;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bool isFirstHalf = _controller.value <= 0.5;
        final bool isSecondHalf = _controller.value >= 0.5;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: <Widget>[
              // الدائرة الثالثة
              if (isSecondHalf)
                Transform.rotate(
                  angle: _evalDouble(
                    to: 2 * math.pi,
                    begin: 0.68,
                    end: 0.95,
                    curve: Curves.easeOut,
                  ),
                  child: _Arc(
                    color: widget.thirdCircleColor,
                    strokeWidth: strokeWidth,
                    startAngle: -math.pi / 2,
                    sweepAngle: _evalDouble(
                      from: math.pi / 2,
                      to: math.pi / (size * size),
                      begin: 0.7,
                      end: 0.95,
                      curve: Curves.easeOutSine,
                    ),
                  ),
                ),

              // الدائرة الثانية
              if (isSecondHalf)
                _Arc(
                  color: widget.secondCircleColor,
                  strokeWidth: strokeWidth,
                  startAngle: -math.pi / 2,
                  sweepAngle: _evalDouble(
                    from: -2 * math.pi,
                    to: math.pi / (size * size),
                    begin: 0.6,
                    end: 0.95,
                    curve: Curves.easeOutSine,
                  ),
                ),

              // الدائرة الأساسية (النصف الأول من الحركة)
              if (isFirstHalf)
                Transform.rotate(
                  angle: _evalDouble(
                    to: math.pi * 0.06,
                    begin: 0.48,
                    end: 0.5,
                  ),
                  child: _Arc(
                    color: widget.color,
                    strokeWidth: strokeWidth,
                    startAngle: -math.pi / 2,
                    sweepAngle: _evalDouble(
                      from: math.pi / (size * size),
                      to: 1.94 * math.pi,
                      begin: 0.05,
                      end: 0.48,
                      curve: Curves.easeOutSine,
                    ),
                  ),
                ),

              // الدائرة الأساسية (النصف الثاني من الحركة)
              if (isSecondHalf)
                _Arc(
                  color: widget.color,
                  strokeWidth: strokeWidth,
                  startAngle: -math.pi / 2,
                  sweepAngle: _evalDouble(
                    from: -1.94 * math.pi,
                    to: math.pi / (size * size),
                    begin: 0.5,
                    end: 0.95,
                    curve: Curves.easeOutSine,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// Private Helper Widgets for Drawing (Standalone)
// ==========================================
class _Arc extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  const _Arc({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ArcPainter(
        color: color,
        strokeWidth: strokeWidth,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle;
  }
}