import 'package:cloud_firestore/cloud_firestore.dart';

class Pair {
  final String id;
  final List<String> memberIds;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const Pair({
    required this.id,
    required this.memberIds,
    this.createdAt,
    this.updatedAt,
  });

  factory Pair.fromMap(String id, Map<String, dynamic> map) {
    return Pair(
      id: id,
      memberIds: ((map['memberIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberIds': memberIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
