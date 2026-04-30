import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/pact_state.dart';
import '../theme/tokens.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PactState>(
      builder: (context, state, _) {
        final entries = state.historyEntries;
        final youAvg = entries.isEmpty
            ? 0.0
            : entries
                    .map((e) => e.tasks.where((t) => t.done).length / e.tasks.length)
                    .reduce((a, b) => a + b) /
                entries.length;

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
                  Text(
                    'History',
                    style: AppText.display(
                      size: 30,
                      weight: FontWeight.w700,
                      color: AppColors.ink0,
                    ),
                  ).animate().fadeIn(duration: 320.ms).moveY(begin: 4, end: 0, duration: 320.ms),
                  const SizedBox(height: 6),
                  Text(
                    'Your recent daily entries',
                    style: AppText.body(size: 13, color: AppColors.ink2),
                  ).animate(delay: 40.ms).fadeIn(duration: 280.ms),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: cardDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Average completion',
                            style: AppText.body(
                              size: 13,
                              color: AppColors.ink2,
                            ),
                          ),
                        ),
                        Text(
                          '${(youAvg * 100).round()}%',
                          style: AppText.display(
                            size: 20,
                            weight: FontWeight.w700,
                            color: AppColors.you,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (entries.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: cardDecoration(),
                      child: Text(
                        'No history yet. Complete today and come back tomorrow.',
                        style: AppText.body(size: 13, color: AppColors.ink2),
                      ),
                    ),
                  if (entries.isNotEmpty)
                    Container(
                      decoration: cardDecoration(),
                      child: Column(
                        children: entries.map((entry) {
                          final done = entry.tasks.where((t) => t.done).length;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.hairline, width: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.date,
                                    style: AppText.body(
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: AppColors.ink0,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$done/5',
                                  style: AppText.body(
                                    size: 13,
                                    color: AppColors.ink2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}
