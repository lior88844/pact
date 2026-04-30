import '../models/daily_insight.dart';

abstract class InsightRepository {
  List<DailyInsight> getActiveInsights();
}
