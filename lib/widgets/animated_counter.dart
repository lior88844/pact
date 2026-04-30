import 'package:flutter/material.dart';

// Tweens an integer from its previous value to the new one
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, child) => Text(v.round().toString(), style: style),
    );
  }
}
