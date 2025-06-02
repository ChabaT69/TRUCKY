import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Add this for DateUtils
import '../models/subscription.dart';

class SubscriptionManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Reference to user's subscriptions collection
  CollectionReference<Map<String, dynamic>> get _subscriptionsRef {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subscriptions');
  }

  // Get all subscriptions for the current user
  Future<List<Subscription>> getCurrentUserSubscriptions() async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final querySnapshot = await _subscriptionsRef.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Subscription(
          id: doc.id,
          name: data['name'] ?? '',
          price:
              (data['price'] is int)
                  ? (data['price'] as int).toDouble()
                  : (data['price'] ?? 0.0),
          startDate:
              data['startDate'] != null
                  ? (data['startDate'] as Timestamp).toDate()
                  : DateTime.now(),
          category: data['category'] ?? 'Other',
          paymentDuration: data['paymentDuration'] ?? 'Monthly',
          lastPaymentDate:
              data['lastPaymentDate'] != null
                  ? (data['lastPaymentDate'] as Timestamp).toDate()
                  : null,
          nextPaymentDate:
              data['nextPaymentDate'] != null
                  ? (data['nextPaymentDate'] as Timestamp).toDate()
                  : null,
          isPaid: data['isPaid'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error getting subscriptions: $e');
      return [];
    }
  }

  // Add a new subscription
  Future<String?> addSubscription(Subscription subscription) async {
    try {
      // Calculate initial next payment date if not provided
      Map<String, dynamic> subscriptionData = subscription.toFirestore();

      // Always calculate a next payment date if not set
      if (subscription.nextPaymentDate == null) {
        DateTime baseDate = subscription.startDate;
        DateTime nextPaymentDate;

        switch (subscription.paymentDuration.toLowerCase()) {
          case 'daily':
            nextPaymentDate = baseDate.add(const Duration(days: 1));
            break;
          case 'weekly':
            nextPaymentDate = baseDate.add(const Duration(days: 7));
            break;
          case 'yearly':
            nextPaymentDate = DateTime(
              baseDate.year + 1,
              baseDate.month,
              baseDate.day,
            );
            break;
          case 'monthly':
          default:
            int newMonth = baseDate.month + 1;
            int newYear = baseDate.year;

            if (newMonth > 12) {
              newMonth = 1;
              newYear += 1;
            }

            // Handle month lengths
            int maxDays = DateUtils.getDaysInMonth(newYear, newMonth);
            int newDay = baseDate.day > maxDays ? maxDays : baseDate.day;

            nextPaymentDate = DateTime(newYear, newMonth, newDay);
            break;
        }

        subscriptionData['nextPaymentDate'] = Timestamp.fromDate(
          nextPaymentDate,
        );

        // If next payment date is within 3 days or past, mark as not paid
        bool isPaid = nextPaymentDate.difference(DateTime.now()).inDays > 3;
        subscriptionData['isPaid'] = isPaid;
      }

      final docRef = await _subscriptionsRef.add(subscriptionData);
      return docRef.id;
    } catch (e) {
      print('Error adding subscription: $e');
      return null;
    }
  }

  // Update an existing subscription
  Future<bool> updateSubscription(Subscription subscription) async {
    if (subscription.id == null) {
      print('Cannot update subscription without ID');
      return false;
    }

    try {
      await _subscriptionsRef
          .doc(subscription.id)
          .update(subscription.toFirestore());
      return true;
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }

  // Delete a subscription
  Future<bool> deleteSubscription(String subscriptionId) async {
    try {
      await _subscriptionsRef.doc(subscriptionId).delete();
      return true;
    } catch (e) {
      print('Error deleting subscription: $e');
      return false;
    }
  }
}
