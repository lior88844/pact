import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/progress_ring.dart';
import '../widgets/animated_counter.dart';

class IdentityCard extends StatelessWidget {
  final String name;
  final String role;
  final Color color;
  final Color glow;
  final int done;
  final int max;
  final MoodState? moodState;
  final String? lastUpdate;
  final bool interactive;

  const IdentityCard({
    super.key,
    required this.name,
    required this.role,
    required this.color,
    required this.glow,
    required this.done,
    this.max = 5,
    this.moodState,
    this.lastUpdate,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? done / max : 0.0;
    final meta = moodState != null ? moodMeta[moodState!] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: identity ─────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role row
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: glow, spreadRadius: 3, blurRadius: 1),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(role, style: AppText.tracked(color: AppColors.ink3)),
                        if (!interactive) ...[
                          const SizedBox(width: 8),
                          _ViewOnlyBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Name
                    Text(
                      name,
                      style: AppText.display(
                        size: 22,
                        weight: FontWeight.w700,
                        color: AppColors.ink0,
                      ),
                    ),
                    // Keep a stable vertical footprint even before a mood is set.
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 18,
                      child: Row(
                        children: [
                          if (meta != null) ...[
                            Icon(meta.icon, size: 12, color: color),
                            const SizedBox(width: 5),
                            Text(
                              meta.label,
                              style: AppText.body(size: 12, weight: FontWeight.w500, color: AppColors.ink1),
                            ),
                          ],
                          if (meta != null && lastUpdate != null) ...[
                            const SizedBox(width: 8),
                            Text('·', style: AppText.body(size: 12, color: AppColors.ink4)),
                            const SizedBox(width: 8),
                          ],
                          if (lastUpdate != null)
                            Text(lastUpdate!, style: AppText.body(size: 12, color: AppColors.ink2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Right: small ring + count ──────────────────────────
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedCounter(
                            value: done,
                            style: AppText.display(
                              size: 22,
                              weight: FontWeight.w700,
                              color: AppColors.ink1,
                            ),
                          ),
                          Text(
                            '/$max',
                            style: AppText.display(
                              size: 22,
                              weight: FontWeight.w500,
                              color: AppColors.ink3,
                            ),
                          ),
                        ],
                      ),
                      Text('complete', style: AppText.tracked(size: 8.5, color: AppColors.ink3)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ProgressRing(
                    value: pct,
                    size: 38,
                    strokeWidth: 3,
                    color: color,
                    trackColor: AppColors.bg3,
                  ),
                ],
              ),
            ],
          ),

          // ── Thin progress rail ──────────────────────────────────────
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 2,
              child: LayoutBuilder(
                builder: (_, constraints) => TweenAnimationBuilder<double>(
                  tween: Tween(end: pct),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, p, child) => Stack(
                    children: [
                      Container(color: AppColors.bg2),
                      Container(
                        width: constraints.maxWidth * p,
                        color: color.withAlpha(153),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ViewOnlyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.lock, size: 8, color: AppColors.ink3),
          const SizedBox(width: 4),
          Text('View only', style: AppText.tracked(size: 8.5, color: AppColors.ink2)),
        ],
      ),
    );
  }
}
