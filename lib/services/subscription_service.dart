import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trucky/models/subscription.dart';

class SubscriptionService {
  final CollectionReference subscriptionsRef = FirebaseFirestore.instance
      .collection('subscriptions');

  Future<void> addSubscription(Subscription subscription) async {
    await subscriptionsRef.doc(subscription.id).set(subscription.toMap());
  }

  Stream<List<Subscription>> getSubscriptions() {
    return subscriptionsRef.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) =>
                    Subscription.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}
