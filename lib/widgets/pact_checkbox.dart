import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PactCheckbox extends StatefulWidget {
  final bool checked;
  final bool interactive;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const PactCheckbox({
    super.key,
    required this.checked,
    this.interactive = true,
    required this.color,
    this.size = 24,
    this.onTap,
  });

  @override
  State<PactCheckbox> createState() => _PactCheckboxState();
}

class _PactCheckboxState extends State<PactCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.interactive) return;
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.checked ? widget.color : Colors.transparent,
            border: Border.all(
              color: widget.checked ? widget.color : const Color(0xFFBAB9C8),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(widget.size),
          ),
          child: AnimatedOpacity(
            opacity: widget.checked ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              LucideIcons.check,
              size: widget.size * 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
