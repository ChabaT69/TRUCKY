import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus { active, dueSoon, expired }

class Subscription {
  final String? id;
  final String userId;
  final String name;
  final double price;
  final DateTime startDate;
  final String category;
  final String paymentDuration;

  Subscription({
    this.id,
    required this.userId,
    required this.name,
    required this.price,
    required this.startDate,
    required this.category,
    required this.paymentDuration,
  });

  String get startDateFormatted =>
      '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';

  SubscriptionStatus get status {
    final today = DateTime.now();
    final durationDays = _durationToDays(paymentDuration);

    final endDate = startDate.add(Duration(days: durationDays));
    final daysUntilEnd = endDate.difference(today).inDays;

    if (daysUntilEnd < 0) {
      return SubscriptionStatus.expired;
    } else if (daysUntilEnd <= 5) {
      return SubscriptionStatus.dueSoon;
    } else {
      return SubscriptionStatus.active;
    }
  }

  int _durationToDays(String duration) {
    switch (duration.toLowerCase()) {
      case 'daily':
        return 1;
      case 'weekly':
        return 7;
      case 'monthly':
        return 30;
      case 'yearly':
        return 365;
      default:
        return 30;
    }
  }

  // Convert Subscription to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'price': price,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'paymentDuration': paymentDuration,
    };
  }

  // Create a Subscription from a Firestore document
  static Subscription fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      category: data['category'] ?? 'Other',
      paymentDuration: data['paymentDuration'] ?? 'Monthly',
    );
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    double? price,
    DateTime? startDate,
    String? category,
    String? paymentDuration,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      category: category ?? this.category,
      paymentDuration: paymentDuration ?? this.paymentDuration,
    );
  }
}
