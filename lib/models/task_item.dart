class TaskItem {
  final String id;
  final String label;
  final String title;
  final bool done;
  final int position;

  const TaskItem({
    required this.id,
    required this.label,
    required this.title,
    required this.done,
    required this.position,
  });

  TaskItem copyWith({
    String? label,
    String? title,
    bool? done,
    int? position,
  }) {
    return TaskItem(
      id: id,
      label: label ?? this.label,
      title: title ?? this.title,
      done: done ?? this.done,
      position: position ?? this.position,
    );
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: (map['id'] as String?) ?? '',
      label: (map['label'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      done: (map['done'] as bool?) ?? false,
      position: (map['position'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'title': title,
      'done': done,
      'position': position,
    };
  }
}
