import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription.dart'; // Fix this import
import 'package:flutter/material.dart';

class SubscriptionDebug {
  // Debug method to create a test subscription
  static Subscription createTestSubscription() {
    return Subscription(
      name: 'Test Subscription',
      price: 9.99,
      startDate: DateTime.now(),
      category: 'Test',
      paymentDuration: 'Monthly',
    );
  }

  // Show the current user ID
  static void showUserIdDialog(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('User ID Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Is user logged in: ${userId != null}'),
                SizedBox(height: 8),
                if (userId != null)
                  Text('User ID: $userId')
                else
                  Text(
                    'No user is logged in',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
