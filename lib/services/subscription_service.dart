import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new subscription
  Future<Subscription> addSubscription(Subscription subscription) async {
    try {
      // Get the current user
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Store in user's subscriptions subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .add(subscription.toMap());

      print('Subscription added with ID: ${docRef.id}');

      // Return an updated subscription with the new document ID
      return subscription.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding subscription: $e');
      rethrow;
    }
  }

  // Get all subscriptions for current user
  Future<List<Subscription>> getUserSubscriptions() async {
    try {
      // Get the current user
      final user = _auth.currentUser;
      if (user == null) {
        print('Warning: No user logged in');
        return [];
      }

      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('subscriptions')
              .get();

      print('Found ${snapshot.docs.length} subscriptions for user ${user.uid}');

      return snapshot.docs
          .map((doc) => Subscription.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return [];
    }
  }

  // Update a subscription
  Future<void> updateSubscription(Subscription subscription) async {
    if (subscription.id == null) {
      throw Exception('Cannot update subscription without an ID');
    }

    try {
      // Get the current user
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .doc(subscription.id)
          .update(subscription.toMap());
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  // Delete a subscription
  Future<void> deleteSubscription(String id) async {
    try {
      // Get the current user
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting subscription: $e');
      rethrow;
    }
  }
}
