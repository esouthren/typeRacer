import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:typeracer/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  // Create or update user
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = Timestamp.now();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  // Listen to user changes
  Stream<UserModel?> watchUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!, doc.id);
    });
  }
}
