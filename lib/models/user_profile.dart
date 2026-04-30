import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String inviteCode;
  final String? pairId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.inviteCode,
    required this.pairId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: (map['uid'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? '',
      inviteCode: (map['inviteCode'] as String?) ?? '',
      pairId: map['pairId'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'inviteCode': inviteCode,
      'pairId': pairId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
