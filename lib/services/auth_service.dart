import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a new user with the given email and password.
  static Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a user document
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      print('Error in registration: $e');
      rethrow;
    }
  }

  /// Logs in an existing user with the given email and password.
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Logs out the current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the current user.
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Returns the current user's ID.
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Checks if a user is logged in.
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}
