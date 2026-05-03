import 'package:flutter/material.dart';

/// Warm-top, cool-bottom gradient matching the HTML prototype `.pact-stage`.
class PactStageBackground extends StatelessWidget {
  const PactStageBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 1.0],
          colors: [
            Color(0xFFEFE8D4),
            Color(0xFFFAF9F6),
            Color(0xFFE5EBF3),
          ],
        ),
      ),
    );
  }
}
