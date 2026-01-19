import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:typeracer/services/user_service.dart';
import 'package:typeracer/models/user_model.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService._internal() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _createOrUpdateUserDocument(user);
      }
      notifyListeners();
    });
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On Web, use the Firebase Auth popup directly for better compatibility
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile implementation requires google_sign_in package which is currently having version issues.
        // Returning null or throwing error.
        debugPrint('Google Sign In is only supported on Web in this version.');
        throw Exception('Google Sign In is only supported on Web in this version.');
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final now = DateTime.now();
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous',
        photoUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
        ownerId: user.uid,
      );
      await _userService.createOrUpdateUser(userModel);
    } catch (e) {
      debugPrint('Error creating/updating user document: $e');
    }
  }
}
