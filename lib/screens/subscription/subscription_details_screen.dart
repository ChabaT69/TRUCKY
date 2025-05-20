import 'package:flutter/material.dart';
import '../../models/subscription.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final List<Subscription> subscriptions;

  const SubscriptionDetailsScreen({Key? key, required this.subscriptions})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subscription Details")),
      body: ListView.builder(
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          return ListTile(
            title: Text(subscription.name),
            subtitle: Text(
              "Price: \$${subscription.price}\nStart Date: ${subscription.startDate.toLocal()}",
            ),
          );
        },
      ),
    );
  }
}
