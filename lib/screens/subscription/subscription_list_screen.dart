import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../services/subscription_manager.dart';
import '../../models/subscription.dart'; // Fix import
import 'add_edit_subscription_screen.dart';

class SubscriptionListScreen extends StatefulWidget {
  @override
  _SubscriptionListScreenState createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();

    // Add auth state listener to reload subscriptions when user logs in
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        print('User logged in: ${user.uid}. Refreshing subscriptions.');
        _loadSubscriptions();
      } else {
        print('User logged out. Clearing subscriptions.');
        setState(() {
          _subscriptions = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // Make sure to call this after each authentication change
  Future<void> _loadSubscriptions() async {
    // Check if a user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _subscriptions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final subscriptions =
          await _subscriptionManager.getCurrentUserSubscriptions();
      setState(() {
        _subscriptions = subscriptions;
      });
    } catch (e) {
      print('Error loading subscriptions: $e');
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load subscriptions')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addSubscription() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need to be logged in to add a subscription'),
        ),
      );
      return;
    }

    final result = await showDialog<Subscription>(
      context: Navigator.of(context, rootNavigator: true).context!,
      builder:
          (context) => AddSubscriptionDialog(
            onAdd: (subscription) async {
              // The actual save happens in the dialog
              final addedSubscription = await _subscriptionManager
                  .addSubscription(subscription);
              if (addedSubscription != null) {
                // Refresh the list after adding
                _loadSubscriptions();
              }
            },
          ),
    );

    if (result != null) {
      // Subscription was added, list will be refreshed by the onAdd callback
    }
  }

  // Rest of your UI implementation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Subscriptions')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _subscriptions.isEmpty
              ? Center(child: Text('No subscriptions found'))
              : ListView.builder(
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = _subscriptions[index];
                  return ListTile(
                    title: Text(subscription.name),
                    subtitle: Text(
                      '${subscription.price} - ${subscription.category}',
                    ),
                    trailing: Text(subscription.startDateFormatted),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubscription,
        child: Icon(Icons.add),
      ),
    );
  }
}
