import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this import

enum SubscriptionStatus { active, dueSoon, expired }

class Subscription {
  String? id;
  String name;
  double price;
  DateTime startDate;
  String category;
  String paymentDuration; // Added payment duration property
  String? notes;
  DateTime? lastPaymentDate;
  DateTime? nextPaymentDate;
  bool isPaid; // Added isPaid property
  String currency; // Added currency property

  // Add formatted date getters
  String get startDateFormatted => DateFormat('MMM dd, yyyy').format(startDate);

  String get lastPaymentDateFormatted =>
      lastPaymentDate != null
          ? DateFormat('MMM dd, yyyy').format(lastPaymentDate!)
          : 'Not paid yet';

  String get nextPaymentDateFormatted =>
      nextPaymentDate != null
          ? DateFormat('MMM dd, yyyy').format(nextPaymentDate!)
          : 'Not scheduled';

  // Calculate status based on next payment date
  SubscriptionStatus get status {
    final now = DateTime.now();
    final dueDate = nextPaymentDate ?? startDate;

    final daysUntil = dueDate.difference(now).inDays;

    if (daysUntil < 0) {
      return SubscriptionStatus.expired;
    } else if (daysUntil <= 7) {
      return SubscriptionStatus.dueSoon;
    } else {
      return SubscriptionStatus.active;
    }
  }

  Subscription({
    this.id,
    required this.name,
    required this.price,
    required this.startDate,
    required this.category,
    this.paymentDuration = 'Monthly', // Default value
    this.currency = 'USD', // Default value
    this.notes,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.isPaid = false, // Default value
  });

  // Create from Firestore document
  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Subscription(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Subscription',
      price: (data['price'] ?? 0.0).toDouble(),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'Other',
      paymentDuration: data['paymentDuration'] ?? 'Monthly',
      currency: data['currency'] ?? 'USD',
      notes: data['notes'],
      lastPaymentDate: (data['lastPaymentDate'] as Timestamp?)?.toDate(),
      nextPaymentDate: (data['nextPaymentDate'] as Timestamp?)?.toDate(),
      isPaid: data['isPaid'] ?? false,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'paymentDuration': paymentDuration,
      'currency': currency,
      'notes': notes,
      'lastPaymentDate':
          lastPaymentDate != null ? Timestamp.fromDate(lastPaymentDate!) : null,
      'nextPaymentDate':
          nextPaymentDate != null ? Timestamp.fromDate(nextPaymentDate!) : null,
      'isPaid': isPaid,
    };
  }

  // Add copyWith method
  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    DateTime? startDate,
    String? category,
    String? paymentDuration,
    String? currency,
    String? notes,
    DateTime? lastPaymentDate,
    DateTime? nextPaymentDate,
    bool? isPaid,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      category: category ?? this.category,
      paymentDuration: paymentDuration ?? this.paymentDuration,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
