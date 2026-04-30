import '../models/daily_insight.dart';
import 'insight_repository.dart';

class LocalInsightRepository implements InsightRepository {
  const LocalInsightRepository();

  @override
  List<DailyInsight> getActiveInsights() {
    return _seedInsights.where((insight) => insight.active).toList(growable: false);
  }
}

const List<DailyInsight> _seedInsights = [
  DailyInsight(
    id: 'insight_001',
    text: 'Relationships are one of the strongest predictors of long-term happiness.',
    category: 'relationship',
    tags: ['happiness', 'connection'],
  ),
  DailyInsight(
    id: 'insight_002',
    text: 'A 25-minute walk can change the trajectory of your day.',
    category: 'body',
    tags: ['movement', 'energy'],
  ),
  DailyInsight(
    id: 'insight_003',
    text: 'Consistency beats intensity when repeated long enough.',
    category: 'discipline',
    tags: ['consistency', 'habits'],
  ),
  DailyInsight(
    id: 'insight_004',
    text: 'Sleep is a performance multiplier, not a luxury.',
    category: 'body',
    tags: ['sleep', 'recovery'],
  ),
  DailyInsight(
    id: 'insight_005',
    text: 'What you do daily compounds. What you do occasionally does not.',
    category: 'discipline',
    tags: ['compounding', 'habits'],
  ),
  DailyInsight(
    id: 'insight_006',
    text: 'The body keeps the score. Move it, fuel it, rest it.',
    category: 'body',
    tags: ['movement', 'nutrition', 'rest'],
  ),
  DailyInsight(
    id: 'insight_007',
    text: 'Discomfort is the price of admission to a meaningful life.',
    category: 'mindset',
    tags: ['growth', 'resilience'],
  ),
  DailyInsight(
    id: 'insight_008',
    text: 'You do not rise to the level of your goals; you fall to the level of your systems.',
    category: 'discipline',
    tags: ['systems', 'execution'],
  ),
  DailyInsight(
    id: 'insight_009',
    text: 'Showing up on bad days is what separates the disciplined from the rest.',
    category: 'discipline',
    tags: ['discipline', 'identity'],
  ),
  DailyInsight(
    id: 'insight_010',
    text: 'The most underrated productivity tool is going to bed at the same time.',
    category: 'body',
    tags: ['sleep', 'productivity'],
  ),
  DailyInsight(
    id: 'insight_011',
    text: 'Identity precedes outcome. Decide who you are, then act accordingly.',
    category: 'mindset',
    tags: ['identity', 'outcomes'],
  ),
  DailyInsight(
    id: 'insight_012',
    text: 'Boredom is the doorway. Most people walk away from it.',
    category: 'mindset',
    tags: ['focus', 'deep work'],
  ),
  DailyInsight(
    id: 'insight_013',
    text: 'Your mornings set the tone. Protect the first 90 minutes.',
    category: 'discipline',
    tags: ['routine', 'focus'],
  ),
  DailyInsight(
    id: 'insight_014',
    text: 'Hard things become easier. Easy things become habits.',
    category: 'discipline',
    tags: ['practice', 'habits'],
  ),
  DailyInsight(
    id: 'insight_015',
    text: 'Compare yourself to who you were yesterday, not to who someone else is today.',
    category: 'mindset',
    tags: ['self-improvement', 'perspective'],
  ),
  DailyInsight(
    id: 'insight_016',
    text: 'Energy is a renewable resource if you treat it like one.',
    category: 'body',
    tags: ['energy', 'recovery'],
  ),
  DailyInsight(
    id: 'insight_017',
    text: 'Discipline is choosing between what you want now and what you want most.',
    category: 'discipline',
    tags: ['self-control', 'long-term'],
  ),
  DailyInsight(
    id: 'insight_018',
    text: 'The work you avoid is usually the work you most need to do.',
    category: 'mindset',
    tags: ['avoidance', 'priority'],
  ),
  DailyInsight(
    id: 'insight_019',
    text: 'Small wins, repeated, become identity.',
    category: 'discipline',
    tags: ['identity', 'momentum'],
  ),
  DailyInsight(
    id: 'insight_020',
    text: 'Strong relationships need standards, not just affection.',
    category: 'relationship',
    tags: ['boundaries', 'connection'],
  ),
];
