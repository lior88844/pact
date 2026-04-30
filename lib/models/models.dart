import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/tokens.dart';
export 'daily_entry.dart';
export 'pair.dart';
export 'task_item.dart';
export 'user_profile.dart';

// ─── Task ─────────────────────────────────────────────────────────────────────
class Task {
  final String id;
  final String label;
  final String text;
  final bool done;

  const Task({
    required this.id,
    required this.label,
    this.text = '',
    this.done = false,
  });

  Task copyWith({String? label, String? text, bool? done}) => Task(
        id: id,
        label: label ?? this.label,
        text: text ?? this.text,
        done: done ?? this.done,
      );
}

// ─── Mood state ───────────────────────────────────────────────────────────────
enum MoodState {
  focused,
  driven,
  calm,
  lowEnergy,
  strategic,
  struggling,
}

class MoodMeta {
  final String label;
  final IconData icon;
  final Color accent;

  const MoodMeta({required this.label, required this.icon, required this.accent});
}

const Map<MoodState, MoodMeta> moodMeta = {
  MoodState.focused: MoodMeta(label: 'Focused', icon: LucideIcons.target, accent: AppColors.ink0),
  MoodState.driven: MoodMeta(label: 'Driven', icon: LucideIcons.flame, accent: AppColors.warn),
  MoodState.calm: MoodMeta(label: 'Calm', icon: LucideIcons.leaf, accent: AppColors.ok),
  MoodState.lowEnergy: MoodMeta(label: 'Low energy', icon: LucideIcons.batteryLow, accent: AppColors.ink3),
  MoodState.strategic: MoodMeta(label: 'Strategic', icon: LucideIcons.compass, accent: AppColors.pal),
  MoodState.struggling: MoodMeta(label: 'Struggling', icon: LucideIcons.circleAlert, accent: AppColors.ink2),
};

// ─── Past day snapshot ────────────────────────────────────────────────────────
class DaySnapshot {
  final List<Task> youTasks;
  final List<Task> palTasks;
  final MoodState? youMood;
  final MoodState? palMood;

  const DaySnapshot({
    required this.youTasks,
    required this.palTasks,
    this.youMood,
    this.palMood,
  });
}

// Static demo snapshots keyed by negative offset (-1 = yesterday, etc.)
final Map<int, DaySnapshot> pastDayData = {
  -1: DaySnapshot(
    youMood: MoodState.focused,
    palMood: MoodState.driven,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Finish Q2 strategy doc', done: true),
      Task(id: 'y1', label: 'WORK', text: 'Review team PRs', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Client call with Lena', done: true),
      Task(id: 'y3', label: 'BODY', text: 'Gym · upper body', done: true),
      Task(id: 'y4', label: 'MIND', text: 'Read · 30 pages', done: false),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'Ship the Q2 plan', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Review Eng candidates', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Outline next OKRs', done: true),
      Task(id: 'p3', label: 'BODY', text: 'Run · 6 km', done: true),
      Task(id: 'p4', label: 'MIND', text: 'Meditate · 15 min', done: false),
    ],
  ),
  -2: DaySnapshot(
    youMood: MoodState.strategic,
    palMood: MoodState.calm,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Competitor analysis', done: true),
      Task(id: 'y1', label: 'WORK', text: '1:1 with Sasha', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Write weekly report', done: false),
      Task(id: 'y3', label: 'BODY', text: 'Morning run · 5 km', done: true),
      Task(id: 'y4', label: 'MIND', text: 'Journal · 10 min', done: true),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'Design sprint kick-off', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Prototype review', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Roadmap revision', done: false),
      Task(id: 'p3', label: 'BODY', text: 'Yoga · 45 min', done: true),
      Task(id: 'p4', label: 'MIND', text: 'Read · 20 pages', done: true),
    ],
  ),
  -3: DaySnapshot(
    youMood: MoodState.driven,
    palMood: MoodState.focused,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Board deck v2', done: true),
      Task(id: 'y1', label: 'WORK', text: 'Hiring interviews x2', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Async standup catchup', done: true),
      Task(id: 'y3', label: 'BODY', text: 'Walk · 40 min', done: true),
      Task(id: 'y4', label: 'MIND', text: 'Podcast · deep work', done: true),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'User research synthesis', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Stakeholder update', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Feature prioritisation', done: true),
      Task(id: 'p3', label: 'BODY', text: 'Swim · 30 min', done: false),
      Task(id: 'p4', label: 'MIND', text: 'Meditation · 20 min', done: true),
    ],
  ),
  -4: DaySnapshot(
    youMood: MoodState.lowEnergy,
    palMood: MoodState.struggling,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Refine pitch narrative', done: false),
      Task(id: 'y1', label: 'WORK', text: 'Email triage', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Team check-in', done: true),
      Task(id: 'y3', label: 'BODY', text: 'Stretch · 15 min', done: true),
      Task(id: 'y4', label: 'MIND', text: 'Rest — no screens', done: false),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'Fix prod regression', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Incident debrief', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Process retrospective', done: false),
      Task(id: 'p3', label: 'BODY', text: 'Walk · 20 min', done: false),
      Task(id: 'p4', label: 'MIND', text: 'Read fiction', done: true),
    ],
  ),
  -5: DaySnapshot(
    youMood: MoodState.calm,
    palMood: MoodState.driven,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Weekly planning session', done: true),
      Task(id: 'y1', label: 'WORK', text: 'Backlog grooming', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Partner sync', done: true),
      Task(id: 'y3', label: 'BODY', text: 'Gym · legs', done: true),
      Task(id: 'y4', label: 'MIND', text: 'Journaling · 15 min', done: true),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'Kick off new sprint', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Pair programming session', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Set personal OKRs', done: true),
      Task(id: 'p3', label: 'BODY', text: 'Run · 8 km', done: true),
      Task(id: 'p4', label: 'MIND', text: 'Meditate · 20 min', done: true),
    ],
  ),
  -6: DaySnapshot(
    youMood: MoodState.focused,
    palMood: MoodState.calm,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Deep work block · 3h', done: true),
      Task(id: 'y1', label: 'WORK', text: 'Design feedback round', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Async reviews', done: true),
      Task(id: 'y3', label: 'BODY', text: 'Bike ride · 45 min', done: false),
      Task(id: 'y4', label: 'MIND', text: 'Read · 40 pages', done: true),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'Content calendar setup', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Analytics review', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Growth experiment plan', done: false),
      Task(id: 'p3', label: 'BODY', text: 'Hot yoga · 60 min', done: true),
      Task(id: 'p4', label: 'MIND', text: 'Gratitude journal', done: true),
    ],
  ),
  -7: DaySnapshot(
    youMood: MoodState.strategic,
    palMood: MoodState.strategic,
    youTasks: const [
      Task(id: 'y0', label: 'MAIN TASK', text: 'Monthly review', done: true),
      Task(id: 'y1', label: 'WORK', text: 'Roadmap Q3 draft', done: true),
      Task(id: 'y2', label: 'WORK', text: 'Team offsite prep', done: false),
      Task(id: 'y3', label: 'BODY', text: 'Long walk · 1h', done: true),
      Task(id: 'y4', label: 'MIND', text: 'Planning reflection', done: true),
    ],
    palTasks: const [
      Task(id: 'p0', label: 'MAIN TASK', text: 'Q2 retrospective', done: true),
      Task(id: 'p1', label: 'WORK', text: 'Budget review', done: true),
      Task(id: 'p2', label: 'STRATEGY', text: 'Team goals alignment', done: true),
      Task(id: 'p3', label: 'BODY', text: 'Rest day', done: true),
      Task(id: 'p4', label: 'MIND', text: 'Strategic reading', done: true),
    ],
  ),
};

// ─── Daily insights ───────────────────────────────────────────────────────────
const List<String> dailyInsights = [
  "Relationships are one of the strongest predictors of long-term happiness.",
  "A 25-minute walk can change the trajectory of your day.",
  "Consistency beats intensity when repeated long enough.",
  "Sleep is a performance multiplier, not a luxury.",
  "What you do daily compounds. What you do occasionally doesn't.",
  "The body keeps the score. Move it, fuel it, rest it.",
  "Discomfort is the price of admission to a meaningful life.",
  "You don't rise to the level of your goals; you fall to the level of your systems.",
  "Showing up on bad days is what separates the disciplined from the rest.",
  "The most underrated productivity tool is going to bed at the same time.",
  "Identity precedes outcome. Decide who you are, then act accordingly.",
  "Boredom is the doorway. Most people walk away from it.",
  "Your mornings set the tone. Protect the first 90 minutes.",
  "Hard things become easier. Easy things become habits.",
  "Compare yourself to who you were yesterday — not to who someone else is today.",
  "Energy is a renewable resource if you treat it like one.",
  "Discipline is choosing between what you want now and what you want most.",
  "The work you avoid is usually the work you most need to do.",
  "Small wins, repeated, become identity.",
  "Strong relationships need standards, not just affection.",
];

String getDailyInsight([DateTime? date]) {
  final d = date ?? DateTime.now();
  final epoch = d.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
  return dailyInsights[epoch % dailyInsights.length];
}

// ─── Default task labels ──────────────────────────────────────────────────────
const List<String> defaultLabels = ['MAIN TASK', 'WORK', 'WORK', 'BODY', 'MIND'];

List<Task> makeFreshDay() => List.generate(
      defaultLabels.length,
      (i) => Task(id: 't$i', label: defaultLabels[i]),
    );
