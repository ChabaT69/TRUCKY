import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trucky/models/subscription.dart';

class SubscriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add subscription with userId
  Future<void> addSubscription(String userId, Subscription subscription) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .add({
            'userId': userId,
            'nomService': subscription.nomService,
            'prix': subscription.prix,
            'dateDebut': subscription.dateDebut,
            'duree': subscription.duree,
          });
    } catch (e) {
      print("Error adding subscription: $e");
    }
  }

  // Get subscriptions for a specific userId
  Future<List<Subscription>> getSubscriptions(String userId) async {
    try {
      final snapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection('subscriptions')
              .get();
      return snapshot.docs
          .map(
            (doc) => Subscription(
              id: doc.id,
              nomService: doc['nomService'],
              prix: doc['prix'],
              dateDebut: (doc['dateDebut'] as Timestamp).toDate(),
              duree: doc['duree'],
            ),
          )
          .toList();
    } catch (e) {
      print("Error getting subscriptions: $e");
      return [];
    }
  }
}
