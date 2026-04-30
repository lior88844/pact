class DailyInsight {
  final String id;
  final String text;
  final String? author;
  final String category;
  final List<String> tags;
  final bool active;

  const DailyInsight({
    required this.id,
    required this.text,
    this.author,
    required this.category,
    this.tags = const [],
    this.active = true,
  });
}
