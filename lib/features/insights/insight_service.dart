import 'models/daily_insight.dart';
import 'repositories/insight_repository.dart';

class InsightService {
  final InsightRepository repository;

  const InsightService({required this.repository});

  DailyInsight getInsightForDate(DateTime date) {
    final insights = repository.getActiveInsights();
    if (insights.isEmpty) {
      return const DailyInsight(
        id: 'fallback',
        text: 'Small steps done consistently can change everything.',
        category: 'mindset',
      );
    }

    final localDayNumber =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/
            (1000 * 60 * 60 * 24);
    final index = localDayNumber % insights.length;
    return insights[index];
  }
}
