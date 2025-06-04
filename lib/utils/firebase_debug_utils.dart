import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseDebugUtils {
  // Print current auth status to console
  static void printAuthInfo() {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    print('======= FIREBASE AUTH DEBUG =======');
    print('Is user logged in: ${user != null}');

    if (user != null) {
      print('User ID: ${user.uid}');
      print('Email: ${user.email ?? 'No email'}');
      print('Anonymous: ${user.isAnonymous}');
      print('Email verified: ${user.emailVerified}');
    }

    print('=================================');
  }

  // Try to force refresh the auth state
  static Future<bool> refreshAuthState() async {
    try {
      // Try to get the current token (causes a refresh)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        print('Auth refreshed. Token length: ${token?.length}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing auth: $e');
      return false;
    }
  }

  // Show a debug dialog with auth information
  static void showAuthDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Firebase Auth Debug'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User logged in: ${FirebaseAuth.instance.currentUser != null}',
                ),
                SizedBox(height: 8),
                if (FirebaseAuth.instance.currentUser != null) ...[
                  Text('User ID: ${FirebaseAuth.instance.currentUser!.uid}'),
                  Text(
                    'Email: ${FirebaseAuth.instance.currentUser!.email ?? 'None'}',
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await refreshAuthState();
                  Navigator.of(context).pop();
                  // Show again with refreshed data
                  Future.delayed(Duration(milliseconds: 500), () {
                    showAuthDebugDialog(context);
                  });
                },
                child: Text('Refresh Auth'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
    );
  }
}
