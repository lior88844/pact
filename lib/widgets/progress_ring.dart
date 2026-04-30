import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

// Animated SVG-style progress ring using CustomPainter + TweenAnimationBuilder
class ProgressRing extends StatelessWidget {
  final double value;  // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final Duration duration;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 96,
    this.strokeWidth = 7,
    this.color = AppColors.you,
    this.trackColor = AppColors.bg3,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => CustomPaint(
        size: Size(size, size),
        painter: _RingPainter(
          progress: progress,
          color: color,
          trackColor: trackColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // Progress arc — starts from top (−π/2)
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [color.withAlpha(230), color.withAlpha(178)],
          tileMode: TileMode.clamp,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
