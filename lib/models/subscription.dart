import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;
  final String userId;
  final String name;
  final double price;
  final DateTime startDate;
  final String category;
  final String paymentDuration;

  Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.price,
    required this.startDate,
    required this.category,
    required this.paymentDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'price': price,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'paymentDuration': paymentDuration,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      category: map['category'] ?? '',
      paymentDuration: map['paymentDuration'] ?? 'monthly',
    );
  }

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      paymentDuration: data['paymentDuration'] ?? 'monthly',
    );
  }
}
