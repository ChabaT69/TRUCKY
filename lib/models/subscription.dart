import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For DateUtils

enum SubscriptionStatus { active, dueSoon, expired }

class Subscription {
  final String? id;
  final String name;
  final double price;
  final DateTime startDate;
  final String category;
  final String paymentDuration;
  final DateTime? lastPaymentDate;
  final DateTime? nextPaymentDate;
  final bool isPaid;

  Subscription({
    this.id,
    required this.name,
    required this.price,
    required this.startDate,
    required this.category,
    required this.paymentDuration,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.isPaid = false,
  });

  // Copy with method to create a new instance with some modified properties
  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    DateTime? startDate,
    String? category,
    String? paymentDuration,
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
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  // Convert to a Map for Firestore (previously toFirestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'paymentDuration': paymentDuration,
      'lastPaymentDate':
          lastPaymentDate != null ? Timestamp.fromDate(lastPaymentDate!) : null,
      'nextPaymentDate':
          nextPaymentDate != null ? Timestamp.fromDate(nextPaymentDate!) : null,
      'isPaid': isPaid,
    };
  }

  // For backward compatibility with existing code
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Create Subscription from a Firestore document
  static Subscription fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Subscription(
      id: doc.id,
      name: data['name'] ?? '',
      price:
          (data['price'] is int)
              ? (data['price'] as int).toDouble()
              : (data['price'] ?? 0.0),
      startDate:
          data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : DateTime.now(),
      category: data['category'] ?? 'Other',
      paymentDuration: data['paymentDuration'] ?? 'Monthly',
      lastPaymentDate:
          data['lastPaymentDate'] != null
              ? (data['lastPaymentDate'] as Timestamp).toDate()
              : null,
      nextPaymentDate:
          data['nextPaymentDate'] != null
              ? (data['nextPaymentDate'] as Timestamp).toDate()
              : null,
      isPaid: data['isPaid'] ?? false,
    );
  }

  // Calculate subscription status based on payment dates
  SubscriptionStatus get status {
    final now = DateTime.now();

    // If nextPaymentDate is explicitly set, use it for status calculation
    if (nextPaymentDate != null) {
      final difference = nextPaymentDate!.difference(now);

      // If next payment date has passed
      if (difference.isNegative) {
        return SubscriptionStatus.expired;
      }

      // If next payment is within 3 days
      if (difference.inDays < 3) {
        return SubscriptionStatus.dueSoon;
      }

      return SubscriptionStatus.active;
    }

    // If no nextPaymentDate is set, calculate based on start date
    final startDateDifference = startDate.difference(now);

    // If start date is in the past, it's expired
    if (startDateDifference.isNegative) {
      return SubscriptionStatus.expired;
    }

    // If start date is within next 3 days, it's due soon
    if (startDateDifference.inDays < 3) {
      return SubscriptionStatus.dueSoon;
    }

    // Otherwise active
    return SubscriptionStatus.active;
  }

  // This displays the effective date to show on the home screen
  DateTime get effectiveDisplayDate {
    // Show next payment date if available, otherwise startDate
    return nextPaymentDate ?? startDate;
  }

  // Formatted date for display in home screen
  String get startDateFormatted {
    DateTime dateToShow = effectiveDisplayDate;
    return '${dateToShow.day}/${dateToShow.month}/${dateToShow.year}';
  }
}
