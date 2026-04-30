import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import '../theme/tokens.dart';

const _tabs = [
  (icon: LucideIcons.circleCheck, label: 'Today'),
  (icon: LucideIcons.calendarDays, label: 'History'),
  (icon: LucideIcons.settings, label: 'Settings'),
];

class BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(220),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.hairline, width: 1),
            boxShadow: AppShadows.nav,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final active = selected == i;
              return _NavItem(
                icon: tab.icon,
                label: tab.label,
                active: active,
                onTap: () { HapticFeedback.selectionClick(); onTap(i); },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.ink0 : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.ink2),
            if (active) ...[
              const SizedBox(width: 7),
              Text(label, style: AppText.body(size: 13, weight: FontWeight.w600, color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }
}
