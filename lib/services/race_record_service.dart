import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:typeracer/models/race_record_model.dart';

class RaceRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new race record
  Future<String> createRaceRecord(RaceRecordModel record) async {
    try {
      final docRef = await _firestore.collection('race_records').add(record.toJson());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating race record: $e');
      rethrow;
    }
  }

  // Get race records for a user
  Future<List<RaceRecordModel>> getUserRaceRecords(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('race_records')
          .where('owner_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RaceRecordModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error getting user race records: $e');
      rethrow;
    }
  }

  // Get best WPM for a user
  Future<int> getBestWpm(String userId) async {
    try {
      final records = await getUserRaceRecords(userId);
      if (records.isEmpty) return 0;
      return records.map((r) => r.wpm).reduce((a, b) => a > b ? a : b);
    } catch (e) {
      debugPrint('Error getting best WPM: $e');
      return 0;
    }
  }

  // Get average WPM for a user
  Future<double> getAverageWpm(String userId) async {
    try {
      final records = await getUserRaceRecords(userId);
      if (records.isEmpty) return 0.0;
      final total = records.map((r) => r.wpm).reduce((a, b) => a + b);
      return total / records.length;
    } catch (e) {
      debugPrint('Error getting average WPM: $e');
      return 0.0;
    }
  }

  // Delete a race record
  Future<void> deleteRaceRecord(String recordId) async {
    try {
      await _firestore.collection('race_records').doc(recordId).delete();
    } catch (e) {
      debugPrint('Error deleting race record: $e');
      rethrow;
    }
  }

  // Listen to user's race records
  Stream<List<RaceRecordModel>> watchUserRaceRecords(String userId, {int limit = 20}) {
    return _firestore
        .collection('race_records')
        .where('owner_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RaceRecordModel.fromJson(doc.data(), doc.id)).toList());
  }

  // Get top leaderboard entries
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('wpm', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      rethrow;
    }
  }

  // Update leaderboard entry
  Future<void> updateLeaderboard(String userId, String userName, int wpm) async {
    try {
      await _firestore.collection('leaderboard').doc(userId).set({
        'user_id': userId,
        'user_name': userName,
        'wpm': wpm,
        'created_at': Timestamp.now(),
        'owner_id': userId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating leaderboard: $e');
      rethrow;
    }
  }
}
