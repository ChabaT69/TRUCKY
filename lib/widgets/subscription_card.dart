import 'package:flutter/material.dart';
import 'package:trucky/models/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionCard({Key? key, required this.subscription})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display subscription details in a Card.
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(subscription.name),
        subtitle: Text(
          "Duration: ${subscription.paymentDuration} months - Price: \$${subscription.price}",
        ),
      ),
    );
  }
}
