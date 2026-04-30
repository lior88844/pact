import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../state/pact_state.dart';
import '../theme/tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PactState>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            18,
            MediaQuery.of(context).padding.top + 24,
            18,
            MediaQuery.of(context).padding.bottom + 110,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Title
              Text('Settings',
                      style: AppText.display(size: 30, weight: FontWeight.w700, color: AppColors.ink0))
                  .animate().fadeIn(duration: 320.ms).moveY(begin: 4, end: 0, duration: 320.ms),

              const SizedBox(height: 22),

              // Pact identity card
              _PactCard(
                currentUserName: state.currentUserName,
                partnerName: state.partnerName,
              )
                  .animate(delay: 40.ms)
                  .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                  .moveY(begin: 6, end: 0, duration: 320.ms),

              const SizedBox(height: 22),

              // Pact section
              _SectionLabel(label: 'PACT'),
              const SizedBox(height: 10),
              _SettingsGroup(
                rows: [
                  (icon: LucideIcons.user, label: 'Your profile', value: state.currentUserName),
                  (icon: LucideIcons.heart, label: 'Partner', value: state.partnerName),
                  (icon: LucideIcons.bell, label: 'Daily reminder', value: '7:00 AM'),
                  (icon: LucideIcons.lock, label: 'Privacy', value: null),
                ],
              ).animate(delay: 80.ms).fadeIn(duration: 300.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 22),

              // App section
              _SectionLabel(label: 'APP'),
              const SizedBox(height: 10),
              _SettingsGroup(
                rows: const [
                  (icon: LucideIcons.settings, label: 'Appearance', value: 'Light'),
                  (icon: LucideIcons.messageSquareQuote, label: 'Daily signals', value: 'On'),
                ],
              ).animate(delay: 120.ms).fadeIn(duration: 300.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 40),

              Center(
                child: Text(
                  'Pact · v1.0',
                  style: AppText.tracked(size: 11, color: AppColors.ink4),
                ),
              ).animate(delay: 160.ms).fadeIn(duration: 280.ms),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PactCard extends StatelessWidget {
  final String currentUserName;
  final String partnerName;

  const _PactCard({
    required this.currentUserName,
    required this.partnerName,
  });

  String _initialFor(String name, {required String fallback}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return fallback;
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currentInitial = _initialFor(currentUserName, fallback: 'Y');
    final partnerInitial = _initialFor(partnerName, fallback: 'P');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.2, -0.5),
                end: Alignment(-0.2, 0.5),
                colors: [AppColors.youSoft, AppColors.palSoft],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$currentInitial · $partnerInitial',
                style: AppText.display(size: 16, weight: FontWeight.w700, color: AppColors.ink0),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$currentUserName & $partnerName',
                    style: AppText.display(size: 17, weight: FontWeight.w600, color: AppColors.ink0)),
                const SizedBox(height: 2),
                Text('Pact since Apr 5 · 23-day streak',
                    style: AppText.body(size: 12, color: AppColors.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: AppText.tracked(size: 11, color: AppColors.ink3)),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<({IconData icon, String label, String? value})> rows;
  const _SettingsGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          return _SettingsRow(
            icon: r.icon,
            label: r.label,
            value: r.value,
            isFirst: i == 0,
          );
        }),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isFirst;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: isFirst
            ? null
            : const Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.ink1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: AppText.body(size: 14, weight: FontWeight.w500, color: AppColors.ink0)),
          ),
          if (value != null)
            Text(value!, style: AppText.body(size: 13, color: AppColors.ink2)),
          const SizedBox(width: 6),
          Icon(LucideIcons.chevronRight, size: 14, color: AppColors.ink3),
        ],
      ),
    );
  }
}
