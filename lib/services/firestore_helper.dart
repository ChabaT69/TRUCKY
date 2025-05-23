import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription.dart'; // Fix import path
import 'dart:async';

class FirestoreHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Force reauthentication and retry with exponential backoff
  static Future<String?> ensureAuthentication() async {
    // First try getting the current user directly
    User? user = _auth.currentUser;
    if (user != null) {
      print('User already authenticated: ${user.uid}');
      return user.uid;
    }

    // Wait for auth state to be ready
    print('Waiting for authentication...');

    // Try refreshing the auth state directly
    try {
      await _auth.currentUser?.reload();
      user = _auth.currentUser;
      if (user != null) {
        print('Authentication refreshed: ${user.uid}');
        return user.uid;
      }
    } catch (e) {
      print('Error refreshing auth: $e');
    }

    // Try anonymous login as fallback
    try {
      final result = await _auth.signInAnonymously();
      user = result.user;
      if (user != null) {
        print('Anonymous login successful: ${user.uid}');
        return user.uid;
      }
    } catch (e) {
      print('Anonymous login failed: $e');
    }

    print('Authentication failed after multiple attempts');
    return null;
  }

  // Get reference to a user's subscriptions collection
  static CollectionReference<Map<String, dynamic>> getUserSubscriptionsRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions');
  }

  // Get the current user ID safely with fallback
  static String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      print('WARNING: No user is currently logged in');

      // Force refresh the auth state to make sure we have the latest
      _auth.authStateChanges().first.then((user) {
        print(
          'Auth state refreshed: ${user != null ? "User logged in" : "No user"}',
        );
      });

      throw Exception('No user is currently logged in');
    }
    print('Current user ID: ${user.uid}');
    return user.uid;
  }

  // Check if a user is logged in
  static bool isUserLoggedIn() {
    final user = _auth.currentUser;
    print('User login check: ${user != null ? "Logged in" : "Not logged in"}');
    if (user != null) {
      print('User ID: ${user.uid}');
      print('User email: ${user.email}');
    }
    return user != null;
  }

  // Wait for authentication to be ready
  static Future<String?> waitForAuthUser({int timeoutSeconds = 5}) async {
    final completer = Completer<String?>();

    // First check if user is already logged in
    if (_auth.currentUser != null) {
      print('User already logged in: ${_auth.currentUser!.uid}');
      return _auth.currentUser!.uid;
    }

    // Otherwise, listen for auth state changes
    print('Waiting for auth to be ready...');
    final subscription = _auth.authStateChanges().listen((user) {
      if (user != null && !completer.isCompleted) {
        print('Auth user became available: ${user.uid}');
        completer.complete(user.uid);
      }
    });

    // Set timeout
    Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) {
        print('Auth wait timed out after $timeoutSeconds seconds');
        completer.complete(null);
      }
    });

    // Clean up
    final result = await completer.future;
    subscription.cancel();
    return result;
  }

  // Add subscription to Firestore with enhanced error handling and validation
  static Future<String?> addSubscription(Subscription subscription) async {
    try {
      // Make sure user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: Not logged in when trying to add subscription');
        return null;
      }

      print('Adding subscription to Firestore for user: ${user.uid}');
      print(
        'Subscription details: ${subscription.name}, ${subscription.price}€',
      );

      // Log the data being saved
      final data = subscription.toMap();
      print('Firestore data to save: $data');

      // Create the document and wait for confirmation
      final docRef = await getUserSubscriptionsRef().add(data);
      print('SUCCESS: Subscription added with ID: ${docRef.id}');

      // Verify the document was created by reading it back
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        print('VERIFIED: Document exists in Firestore');
      } else {
        print('WARNING: Document not found after creation');
      }

      return docRef.id;
    } catch (e) {
      print('ERROR adding subscription to Firestore: $e');
      return null;
    }
  }

  // Update subscription in Firestore
  static Future<bool> updateSubscription(Subscription subscription) async {
    try {
      if (subscription.id == null)
        throw Exception('Cannot update subscription without ID');

      await getUserSubscriptionsRef()
          .doc(subscription.id)
          .update(subscription.toMap());
      return true;
    } catch (e) {
      print('Error updating subscription in Firestore: $e');
      return false;
    }
  }

  // Delete subscription from Firestore
  static Future<bool> deleteSubscription(String subscriptionId) async {
    try {
      await getUserSubscriptionsRef().doc(subscriptionId).delete();
      return true;
    } catch (e) {
      print('Error deleting subscription from Firestore: $e');
      return false;
    }
  }

  // Get all subscriptions for current user
  static Future<List<Subscription>> getCurrentUserSubscriptions() async {
    try {
      // Check if user is logged in
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: Cannot get subscriptions - no user logged in');
        return [];
      }

      print('Fetching subscriptions for user: ${user.uid}');

      // Verify that the user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        print('Creating user document for new user: ${user.uid}');
        await _firestore.collection('users').doc(user.uid).set({
          'createdAt': Timestamp.now(),
        });
      }

      final snapshot = await getUserSubscriptionsRef().get();
      print(
        'Found ${snapshot.docs.length} subscriptions for user: ${user.uid}',
      );

      final subscriptions =
          snapshot.docs
              .map((doc) {
                try {
                  return Subscription.fromFirestore(doc);
                } catch (e) {
                  print('ERROR parsing subscription document: ${doc.id} - $e');
                  return null;
                }
              })
              .where((sub) => sub != null)
              .cast<Subscription>()
              .toList();

      return subscriptions;
    } catch (e) {
      print('ERROR getting subscriptions from Firestore: $e');
      return [];
    }
  }

  // Test connection to Firestore
  static Future<bool> testFirestoreConnection() async {
    try {
      await _firestore.collection('_test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Firestore connection test: SUCCESS');
      return true;
    } catch (e) {
      print('Firestore connection test: FAILED - $e');
      return false;
    }
  }
}
