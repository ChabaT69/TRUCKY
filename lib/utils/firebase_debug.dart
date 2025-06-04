import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_helper.dart';

class FirebaseDebug {
  static Future<Map<String, dynamic>> diagnoseFirebaseConnection() async {
    final results = <String, dynamic>{};

    try {
      // Check auth
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      // ignore: unnecessary_null_comparison
      results['auth_initialized'] = auth != null;
      results['user_logged_in'] = currentUser != null;
      results['user_id'] = currentUser?.uid;
      results['user_email'] = currentUser?.email;

      // Check Firestore
      final firestore = FirebaseFirestore.instance;
      // ignore: unnecessary_null_comparison
      results['firestore_initialized'] = firestore != null;

      // Test write
      final testConnection = await FirestoreHelper.testFirestoreConnection();
      results['can_write_to_firestore'] = testConnection;

      if (currentUser != null) {
        // Try to read user's subscriptions
        try {
          final subscriptions =
              await FirestoreHelper.getCurrentUserSubscriptions();
          results['subscriptions_count'] = subscriptions.length;
          results['can_read_subscriptions'] = true;
        } catch (e) {
          results['can_read_subscriptions'] = false;
          results['subscription_read_error'] = e.toString();
        }
      }

      return results;
    } catch (e) {
      results['error'] = e.toString();
      return results;
    }
  }

  static void printDiagnostics() async {
    print('======= FIREBASE DIAGNOSTICS =======');
    final results = await diagnoseFirebaseConnection();
    results.forEach((key, value) {
      print('$key: $value');
    });
    print('===================================');
  }
}
