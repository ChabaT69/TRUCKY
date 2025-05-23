import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      _initialized = true;
      print('Firebase initialized successfully');
    }
  }

  static Future<bool> isUserLoggedIn() async {
    await initialize();
    return FirebaseAuth.instance.currentUser != null;
  }

  static Future<User?> getCurrentUser() async {
    await initialize();
    return FirebaseAuth.instance.currentUser;
  }

  static Future<String?> getCurrentUserId() async {
    await initialize();
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<void> signOut() async {
    await initialize();
    await FirebaseAuth.instance.signOut();
  }
}
