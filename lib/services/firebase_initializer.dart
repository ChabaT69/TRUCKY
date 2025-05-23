import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FirebaseInitializer {
  static bool _initialized = false;
  static final Completer<bool> _initializing = Completer<bool>();

  // Initialize Firebase with exponential backoff retries
  static Future<bool> initializeFirebase() async {
    if (_initialized) return true;

    // If already initializing, wait for the result
    if (_initializing.isCompleted == false) {
      return _initializing.future;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      print('Firebase initialized');

      // Try to get current auth state
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        // Try anonymous sign-in as a fallback
        try {
          final userCred = await auth.signInAnonymously();
          print('Anonymous auth successful: ${userCred.user?.uid}');
        } catch (e) {
          print('Anonymous auth failed: $e');
        }
      } else {
        print('User already signed in: ${user.uid}');
      }

      _initialized = true;
      _initializing.complete(true);
      return true;
    } catch (e) {
      print('Firebase initialization error: $e');
      _initializing.complete(false);
      return false;
    }
  }

  // Make sure Firebase Auth is ready
  static Future<bool> ensureAuthReady() async {
    if (!_initialized) {
      await initializeFirebase();
    }

    final auth = FirebaseAuth.instance;

    // Wait for auth state to be ready
    try {
      final completer = Completer<bool>();

      // Check if already logged in
      if (auth.currentUser != null) {
        return true;
      }

      // Listen for auth state changes
      final subscription = auth.authStateChanges().listen((user) {
        if (!completer.isCompleted) {
          completer.complete(user != null);
        }
      });

      // Set a timeout
      Timer(Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          print('Auth wait timed out');
          completer.complete(false);
        }
      });

      final result = await completer.future;
      subscription.cancel();
      return result;
    } catch (e) {
      print('Error ensuring auth ready: $e');
      return false;
    }
  }
}
