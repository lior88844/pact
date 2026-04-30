import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _inviteCodes =>
      _db.collection('inviteCodes');

  Future<UserProfile?> getByUid(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserProfile.fromMap(snapshot.data()!);
  }

  Future<UserProfile?> getByInviteCode(String inviteCode) async {
    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) return null;
    final inviteSnap = await _inviteCodes.doc(code).get();
    final uid = inviteSnap.data()?['uid'] as String?;
    if (uid == null || uid.isEmpty) return null;
    return getByUid(uid);
  }

  Future<UserProfile> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    return _db.runTransaction((txn) async {
      final userRef = _users.doc(uid);
      final existingUser = await txn.get(userRef);
      if (existingUser.exists && existingUser.data() != null) {
        final profile = UserProfile.fromMap(existingUser.data()!);
        final existingCode = profile.inviteCode.trim().toUpperCase();
        if (existingCode.isNotEmpty) {
          txn.set(_inviteCodes.doc(existingCode), {
            'uid': uid,
            'createdAt': profile.createdAt ?? Timestamp.now(),
          }, SetOptions(merge: true));
        }
        return profile;
      }

      final inviteCode = await generateUniqueInviteCode(txn: txn);
      final now = Timestamp.now();
      final profile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        inviteCode: inviteCode,
        pairId: null,
        createdAt: now,
        updatedAt: now,
      );
      txn.set(userRef, profile.toMap(), SetOptions(merge: true));
      txn.set(_inviteCodes.doc(inviteCode), {
        'uid': uid,
        'createdAt': now,
      });
      return profile;
    });
  }

  Future<void> setPairId(String uid, String pairId) {
    return _users.doc(uid).set({
      'pairId': pairId,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  }) {
    return _users.doc(uid).set({
      'displayName': displayName.trim(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<String> generateUniqueInviteCode({
    Transaction? txn,
  }) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();

    for (var i = 0; i < 20; i++) {
      final code = List.generate(
        6,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
      final inviteRef = _inviteCodes.doc(code);
      final inviteSnap = txn == null ? await inviteRef.get() : await txn.get(inviteRef);
      if (!inviteSnap.exists) return code;
    }
    throw StateError('Failed to generate unique invite code');
  }
}
