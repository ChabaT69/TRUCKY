import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthDebug {
  /// Check if a user is logged in and return the ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Print current auth status to console
  static void printAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('===== LOGGED IN =====');
      print('User ID: ${user.uid}');
      print('Email: ${user.email}');
      print('====================');
    } else {
      print('===== NOT LOGGED IN =====');
    }
  }

  /// Show a dialog with current auth status
  static void showAuthStatusDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(user != null ? 'Logged In' : 'Not Logged In'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auth state: ${user != null ? "Authenticated" : "Not authenticated"}',
                ),
                if (user != null) ...[
                  SizedBox(height: 8),
                  Text('User ID: ${user.uid}'),
                  Text('Email: ${user.email ?? "No email"}'),
                  Text('Email verified: ${user.emailVerified}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
