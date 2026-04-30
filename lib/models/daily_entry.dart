import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_item.dart';

class DailyEntry {
  final String id;
  final String userId;
  final String pairId;
  final String date;
  final String? state;
  final List<TaskItem> tasks;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const DailyEntry({
    required this.id,
    required this.userId,
    required this.pairId,
    required this.date,
    required this.state,
    required this.tasks,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: (map['id'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      pairId: (map['pairId'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      state: map['state'] as String?,
      tasks: ((map['tasks'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => TaskItem.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pairId': pairId,
      'date': date,
      'state': state,
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
