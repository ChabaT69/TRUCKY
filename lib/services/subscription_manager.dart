import 'package:firebase_auth/firebase_auth.dart';
import '../services/subscription_service.dart';
import '../models/subscription.dart';

class SubscriptionManager {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID safely
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      print('Warning: No user is currently logged in');
      return '';
    }
    return user.uid;
  }

  // Add a new subscription ensuring user ID is set
  Future<Subscription?> addSubscription(Subscription subscription) async {
    try {
      if (currentUserId.isEmpty) {
        print('Cannot add subscription - no user logged in');
        return null;
      }

      return await _subscriptionService.addSubscription(subscription);
    } catch (e) {
      print('Error in subscription manager - addSubscription: $e');
      return null;
    }
  }

  // Get all subscriptions for the current user
  Future<List<Subscription>> getCurrentUserSubscriptions() async {
    if (currentUserId.isEmpty) return [];

    return await _subscriptionService.getUserSubscriptions();
  }

  // Update subscription
  Future<bool> updateSubscription(Subscription subscription) async {
    try {
      await _subscriptionService.updateSubscription(subscription);
      return true;
    } catch (e) {
      print('Error in subscription manager - updateSubscription: $e');
      return false;
    }
  }

  // Delete subscription
  Future<bool> deleteSubscription(String id) async {
    try {
      await _subscriptionService.deleteSubscription(id);
      return true;
    } catch (e) {
      print('Error in subscription manager - deleteSubscription: $e');
      return false;
    }
  }

  // Check if subscriptions exist for the current user
  Future<bool> hasSubscriptions() async {
    if (currentUserId.isEmpty) return false;

    final subscriptions = await _subscriptionService.getUserSubscriptions();
    return subscriptions.isNotEmpty;
  }
}
