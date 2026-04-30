import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pair.dart';

class PairService {
  PairService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _pairs => _db.collection('pairs');
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _inviteCodes =>
      _db.collection('inviteCodes');

  Future<Pair?> getPair(String pairId) async {
    final snapshot = await _pairs.doc(pairId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return Pair.fromMap(snapshot.id, snapshot.data()!);
  }

  Future<String?> getPartnerUid({
    required String pairId,
    required String myUid,
  }) async {
    final pair = await getPair(pairId);
    if (pair == null) return null;
    final candidates = pair.memberIds.where((id) => id != myUid).toList();
    return candidates.isEmpty ? null : candidates.first;
  }

  Future<Pair> pairUsers({
    required String currentUid,
    required String inviteCode,
  }) async {
    try {
      return await _db.runTransaction((txn) async {
        final meRef = _users.doc(currentUid);
        final meDoc = await txn.get(meRef);
        if (!meDoc.exists || meDoc.data() == null) {
          throw StateError('Current user profile is missing.');
        }

        final meData = meDoc.data()!;
        if (meData['pairId'] != null) {
          throw StateError('Current user is already paired.');
        }

        final inviteRef = _inviteCodes.doc(inviteCode.trim().toUpperCase());
        final inviteSnap = await txn.get(inviteRef);
        final partnerUid = inviteSnap.data()?['uid'] as String?;
        if (partnerUid == null || partnerUid.isEmpty) {
          throw StateError('Invite code not found.');
        }

        if (partnerUid == currentUid) {
          throw StateError('You cannot pair with yourself.');
        }

        final partnerRef = _users.doc(partnerUid);

        final pairRef = _pairs.doc();
        final now = Timestamp.now();
        txn.set(pairRef, {
          'memberIds': [currentUid, partnerUid],
          'createdAt': now,
          'updatedAt': now,
        });
        txn.update(meRef, {'pairId': pairRef.id, 'updatedAt': now});
        txn.update(partnerRef, {'pairId': pairRef.id, 'updatedAt': now});

        return Pair(
          id: pairRef.id,
          memberIds: [currentUid, partnerUid],
          createdAt: now,
          updatedAt: now,
        );
      });
    } on FirebaseException catch (e) {
      final code = e.code.toLowerCase();
      if (code == 'permission-denied') {
        throw StateError(
          'Pairing failed due to Firestore permission rules. '
          'This usually means the invite code is invalid, already paired, '
          'or rules were not deployed yet.',
        );
      }
      throw StateError('Firestore error (${e.code}): ${e.message ?? 'Unknown error'}');
    }
  }
}
