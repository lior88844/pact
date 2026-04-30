import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../features/insights/insight_service.dart';
import '../features/insights/repositories/local_insight_repository.dart';
import '../models/models.dart';
import '../state/pact_state.dart';
import '../theme/tokens.dart';
import '../widgets/daily_insight_card.dart';
import '../widgets/identity_card.dart';
import '../widgets/mood_selector.dart';
import '../widgets/task_row.dart';
import '../widgets/user_toggle.dart';

const InsightService _insightService =
    InsightService(repository: LocalInsightRepository());

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PactState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final displayDate = DateTime.now().add(Duration(days: state.dayOffset));
        final dateStr = _formatDate(displayDate);
        final isToday = state.isToday;
        final isPast = state.isPast;
        final isYou = state.isYouView;
        final snap = state.pastSnapshot;
        final insight = _insightService.getInsightForDate(displayDate).text;

        final activeTasks = state.activeTasks;
        final youDone = state.youDone;
        final palDone = state.palDone;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                18,
                MediaQuery.of(context).padding.top + 24,
                18,
                // clearance for floating nav + safe area
                MediaQuery.of(context).padding.bottom + 110,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Header ───────────────────────────────────────────
                  _DateHeader(
                    label: isToday ? 'Today' : _dayName(displayDate),
                    dateStr: dateStr,
                    isPast: isPast,
                    dayOffset: state.dayOffset,
                    canGoBack: state.canGoBack,
                    onBack: () { HapticFeedback.lightImpact(); state.goToPreviousLoggedDay(); },
                    onForward: state.canGoForward
                        ? () { HapticFeedback.lightImpact(); state.goToNextAvailableDay(); }
                        : null,
                  )
                      .animate()
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                      .moveY(begin: 4, end: 0, duration: 320.ms),

                  const SizedBox(height: 18),

                  // ── You / Partner toggle ──────────────────────────────
                  UserToggle(
                    isYou: isYou,
                    onChanged: state.setView,
                    youLabel: state.currentUserName,
                    partnerLabel: state.partnerName,
                  )
                      .animate(delay: 40.ms)
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 14),

                  // ── Identity card (key changes on view switch + day) ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey('$isYou-${state.dayOffset}'),
                      child: isYou
                          ? IdentityCard(
                              name: state.currentUserName,
                              role: 'YOU',
                              color: AppColors.you,
                              glow: AppColors.youGlow,
                              done: youDone,
                              moodState: isPast ? snap?.youMood : state.youMood,
                              interactive: state.canEdit,
                            )
                          : IdentityCard(
                              name: state.partnerName,
                              role: 'PARTNER',
                              color: AppColors.pal,
                              glow: AppColors.palGlow,
                              done: palDone,
                              moodState: isPast ? snap?.palMood : state.palMood,
                              lastUpdate: isToday ? 'updated 4m ago' : null,
                              interactive: false,
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Mood selector ─────────────────────────────────────
                  MoodSelector(
                    selected: state.activeMood,
                    readOnly: !state.canEdit,
                    label: isYou
                        ? (isToday ? 'HOW ARE YOU TODAY?' : 'HOW YOU FELT')
                        : (isToday ? '${state.partnerName.toUpperCase()} IS FEELING…' : '${state.partnerName.toUpperCase()} FELT'),
                    onChanged: state.canEdit ? state.setYouMood : null,
                  )
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 14),

                  // ── Task list (key forces rebuild on view/day change) ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      child: child,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey('tasks-$isYou-${state.dayOffset}'),
                      child: TaskList(
                        tasks: activeTasks,
                        color: isYou ? AppColors.you : AppColors.pal,
                        interactive: state.canEdit,
                        onTextChanged: (pair) => state.updateTaskText(pair.$1, pair.$2),
                        onLabelChanged: (pair) => state.updateTaskLabel(pair.$1, pair.$2),
                        onToggle: state.toggleTask,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Daily signal ──────────────────────────────────────
                  DailyInsightCard(text: insight)
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic),

                  // ── Empty state hint ──────────────────────────────────
                  if (isToday && isYou && state.youTasks.every((t) => t.text.trim().isEmpty)) ...[
                    const SizedBox(height: 12),
                    Text(
                      'A new day. Five slots. Tap a category to rename it.',
                      textAlign: TextAlign.center,
                      style: AppText.body(
                        size: 12,
                        color: AppColors.ink3,
                        letterSpacing: -0.05,
                      ).copyWith(fontStyle: FontStyle.italic),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms),
                  ],
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime d) => '${_weekday(d)}, ${_month(d)} ${d.day}';
  String _dayName(DateTime d) => _weekday(d);

  String _weekday(DateTime d) => const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];
  String _month(DateTime d) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}

// ─── Date header with day-navigation arrows ───────────────────────────────────
class _DateHeader extends StatelessWidget {
  final String label;
  final String dateStr;
  final bool isPast;
  final int dayOffset;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback? onForward;

  const _DateHeader({
    required this.label,
    required this.dateStr,
    required this.isPast,
    required this.dayOffset,
    required this.canGoBack,
    required this.onBack,
    this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.display(size: 30, weight: FontWeight.w700, color: AppColors.ink0),
              ),
            ),
            const SizedBox(width: 8),
            // Back arrow
            _NavArrow(
              icon: LucideIcons.chevronLeft,
              enabled: canGoBack,
              onTap: onBack,
            ),
            const SizedBox(width: 6),
            // Forward arrow (only visible on past days)
            _NavArrow(
              icon: LucideIcons.chevronRight,
              enabled: onForward != null,
              onTap: onForward ?? () {},
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              dateStr,
              style: AppText.body(size: 12.5, color: AppColors.ink2),
            ),
            const SizedBox(width: 6),
            Text('·', style: AppText.body(size: 12.5, color: AppColors.ink4)),
            const SizedBox(width: 6),
            if (isPast)
              _PastBadge()
            else
              Text('clean slate', style: AppText.body(size: 12.5, color: AppColors.ink2)),
          ],
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: enabled ? AppColors.hairline : Colors.transparent,
            width: 1,
          ),
          boxShadow: enabled ? AppShadows.card : null,
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? AppColors.ink1 : AppColors.ink4,
        ),
      ),
    );
  }
}

class _PastBadge extends StatelessWidget {
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
          Text('Past day', style: AppText.tracked(size: 8.5, color: AppColors.ink2)),
        ],
      ),
    );
  }
}
