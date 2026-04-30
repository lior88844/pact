import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

class MoodSelector extends StatelessWidget {
  final MoodState? selected;
  final bool readOnly;
  final String label;
  final ValueChanged<MoodState>? onChanged;

  const MoodSelector({
    super.key,
    this.selected,
    this.readOnly = false,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.tracked(color: AppColors.ink3)),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: MoodState.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final mood = MoodState.values[i];
              final active = selected == mood;
              return _MoodChip(
                mood: mood,
                active: active,
                readOnly: readOnly,
                onTap: readOnly
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onChanged?.call(mood);
                      },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MoodChip extends StatefulWidget {
  final MoodState mood;
  final bool active;
  final bool readOnly;
  final VoidCallback? onTap;

  const _MoodChip({
    required this.mood,
    required this.active,
    required this.readOnly,
    this.onTap,
  });

  @override
  State<_MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<_MoodChip> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _pressed = false);
    });
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final meta = moodMeta[widget.mood]!;
    final active = widget.active;

    final targetScale = _pressed ? 1.10 : (active ? 1.03 : 1.0);
    final duration = _pressed
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 280);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: targetScale,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: active ? AppColors.ink0 : AppColors.hairline,
              width: 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(color: AppColors.youGlow, spreadRadius: 4, blurRadius: 1),
                    const BoxShadow(color: Color(0x2E14120C), blurRadius: 16, spreadRadius: -6, offset: Offset(0, 6)),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: widget.readOnly && !active ? 0.35 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  meta.icon,
                  size: 14,
                  color: active ? AppColors.ink0 : AppColors.ink3,
                ),
              ),
              const SizedBox(width: 7),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppText.body(
                  size: 13,
                  weight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppColors.ink0 : AppColors.ink2,
                  letterSpacing: -0.065,
                ),
                child: Opacity(
                  opacity: widget.readOnly && !active ? 0.35 : 1.0,
                  child: Text(meta.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
