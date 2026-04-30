import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';

class UserToggle extends StatelessWidget {
  final bool isYou;
  final ValueChanged<bool> onChanged;
  final String youLabel;
  final String partnerLabel;

  const UserToggle({
    super.key,
    required this.isYou,
    required this.onChanged,
    this.youLabel = 'You',
    this.partnerLabel = 'Partner',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final pillW = (constraints.maxWidth - 10) / 2;
        return Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.hairline),
            boxShadow: null,
          ),
          child: Stack(
            children: [
              // Sliding pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: const ElasticOutCurve(0.85),
                left: isYou ? 0 : pillW,
                top: 0,
                bottom: 0,
                width: pillW,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.ink0,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x4014120C),
                          blurRadius: 12,
                          spreadRadius: -3,
                          offset: Offset(0, 4)),
                    ],
                  ),
                ),
              ),
              // Buttons
              Row(
                children: [
                  _ToggleBtn(label: youLabel, color: AppColors.you, glow: AppColors.youGlow, active: isYou, onTap: () { HapticFeedback.selectionClick(); onChanged(true); }),
                  _ToggleBtn(label: partnerLabel, color: AppColors.pal, glow: AppColors.palGlow, active: !isYou, onTap: () { HapticFeedback.selectionClick(); onChanged(false); }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color glow;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.color,
    required this.glow,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? [BoxShadow(color: glow, spreadRadius: 3, blurRadius: 1)]
                      : null,
                ),
              ),
              const SizedBox(width: 7),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                style: AppText.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.ink2,
                  letterSpacing: -0.14,
                ),
                child: Text(label, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
