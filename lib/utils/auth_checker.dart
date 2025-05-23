import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthChecker {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
    }
  }

  static Future<bool> isUserLoggedIn() async {
    await ensureInitialized();
    return FirebaseAuth.instance.currentUser != null;
  }

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<void> signInAnonymously() async {
    await ensureInitialized();
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }
}
