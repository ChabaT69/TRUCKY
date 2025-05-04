import 'package:trucky/models/subscription.dart';

class SubscriptionService {
  static Future<List<Subscription>> getSubscriptions() async {
    // Simulate fetching subscriptions from a database with a delay.
    await Future.delayed(Duration(seconds: 1));
    // Replace with actual database retrieval logic.
    return [];
  }
}
