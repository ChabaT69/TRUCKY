import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

class SubscriptionManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID with better error handling
  String? _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      print('SubscriptionManager: ERROR - No user is logged in');
      return null;
    }
    return user.uid;
  }

  // Add a subscription
  Future<String?> addSubscription(Subscription subscription) async {
    try {
      print('SubscriptionManager: Adding subscription: ${subscription.name}');

      // Get current user ID
      final userId = _getCurrentUserId();
      if (userId == null) {
        print('SubscriptionManager: Cannot add subscription - no user ID');
        return null;
      }

      print('SubscriptionManager: User ID: $userId');

      // Prepare subscription data with validation
      final data = subscription.toMap();
      if (data['name'] == null || data['price'] == null) {
        print('SubscriptionManager: Invalid subscription data');
        return null;
      }

      // Add created timestamp
      data['createdAt'] = FieldValue.serverTimestamp();

      // Add to user's subscriptions collection
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .add(data);

      print('SubscriptionManager: Added subscription with ID: ${docRef.id}');

      // Return the new document ID
      return docRef.id;
    } catch (e) {
      print('SubscriptionManager: Error adding subscription: $e');
      return null;
    }
  }

  // Update a subscription
  Future<bool> updateSubscription(Subscription subscription) async {
    try {
      if (subscription.id == null) {
        print('SubscriptionManager: Cannot update subscription without ID');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) return false;

      print('SubscriptionManager: Updating subscription: ${subscription.id}');

      // Update the document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .doc(subscription.id)
          .update({
            ...subscription.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print('SubscriptionManager: Subscription updated successfully');
      return true;
    } catch (e) {
      print('SubscriptionManager: Error updating subscription: $e');
      return false;
    }
  }

  // Delete a subscription
  Future<bool> deleteSubscription(String subscriptionId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return false;

      print('SubscriptionManager: Deleting subscription: $subscriptionId');

      // Delete the document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .doc(subscriptionId)
          .delete();

      print('SubscriptionManager: Subscription deleted successfully');
      return true;
    } catch (e) {
      print('SubscriptionManager: Error deleting subscription: $e');
      return false;
    }
  }

  // Get all subscriptions for the current user
  Future<List<Subscription>> getCurrentUserSubscriptions() async {
    try {
      print('SubscriptionManager: Fetching subscriptions');

      // Get current user ID
      final userId = _getCurrentUserId();
      if (userId == null) {
        print('SubscriptionManager: No user ID available');
        return [];
      }

      // Ensure the user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('SubscriptionManager: Creating user document');
        await _firestore.collection('users').doc(userId).set({
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Get subscriptions
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('subscriptions')
              .get();

      print('SubscriptionManager: Found ${snapshot.docs.length} subscriptions');

      // Convert to Subscription objects
      final subscriptions =
          snapshot.docs
              .map((doc) {
                try {
                  return Subscription.fromFirestore(doc);
                } catch (e) {
                  print('SubscriptionManager: Error parsing subscription: $e');
                  return null;
                }
              })
              .where((sub) => sub != null)
              .cast<Subscription>()
              .toList();

      return subscriptions;
    } catch (e) {
      print('SubscriptionManager: Error fetching subscriptions: $e');
      return [];
    }
  }
}
