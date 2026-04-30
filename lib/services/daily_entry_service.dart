import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_entry.dart';
import '../models/task_item.dart';

class DailyEntryService {
  DailyEntryService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _entries =>
      _db.collection('dailyEntries');

  static const List<String> _defaultLabels = [
    'MAIN TASK',
    'WORK',
    'WORK',
    'BODY',
    'MIND',
  ];

  String dateToLocalYmd(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String buildEntryId(String userId, String ymdDate) => '${userId}_$ymdDate';

  List<TaskItem> makeDefaultTasks() {
    return List.generate(_defaultLabels.length, (index) {
      return TaskItem(
        id: 'task_${index + 1}',
        label: _defaultLabels[index],
        title: '',
        done: false,
        position: index,
      );
    });
  }

  Future<DailyEntry> getOrCreateTodayEntry(String userId, String pairId) async {
    final today = dateToLocalYmd(DateTime.now());
    return getOrCreateEntry(userId: userId, pairId: pairId, date: today);
  }

  Future<DailyEntry> getOrCreateEntry({
    required String userId,
    required String pairId,
    required String date,
  }) async {
    final id = buildEntryId(userId, date);
    final ref = _entries.doc(id);
    final existing = await ref.get();
    if (existing.exists && existing.data() != null) {
      return DailyEntry.fromMap(existing.data()!);
    }

    final now = Timestamp.now();
    final newEntry = DailyEntry(
      id: id,
      userId: userId,
      pairId: pairId,
      date: date,
      state: null,
      tasks: makeDefaultTasks(),
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(newEntry.toMap());
    return newEntry;
  }

  Future<DailyEntry?> getEntryByUserAndDate({
    required String userId,
    required String date,
  }) async {
    final id = buildEntryId(userId, date);
    final doc = await _entries.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return DailyEntry.fromMap(doc.data()!);
  }

  Future<List<DailyEntry>> getRecentEntries({
    required String userId,
    int limit = 7,
  }) async {
    final snapshot = await _entries
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => DailyEntry.fromMap(d.data())).toList();
  }

  Future<void> updateEntryState({
    required String entryId,
    required String? state,
  }) async {
    await _entries.doc(entryId).update({
      'state': state,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateTask({
    required String entryId,
    required String taskId,
    String? title,
    String? label,
    bool? done,
  }) async {
    final ref = _entries.doc(entryId);
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data() == null) return;

    final entry = DailyEntry.fromMap(snapshot.data()!);
    final updatedTasks = entry.tasks.map((task) {
      if (task.id != taskId) return task;
      return task.copyWith(
        title: title ?? task.title,
        label: label ?? task.label,
        done: done ?? task.done,
      );
    }).toList();

    await ref.update({
      'tasks': updatedTasks.map((t) => t.toMap()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }
}
