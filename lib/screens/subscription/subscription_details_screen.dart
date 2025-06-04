import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/subscription.dart';
import '../../services/subscription_manager.dart';
import '../../services/notification_service.dart';
import 'add_edit_subscription_screen.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailsScreen({Key? key, required this.subscription})
    : super(key: key);

  @override
  _SubscriptionDetailsScreenState createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  late Subscription subscription;
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    subscription = widget.subscription;
  }

  Future<void> _markAsPaid() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // More debug output to diagnose the issue
      print("PAYMENT DEBUG - Current subscription state:");
      print("Start date: ${subscription.startDate}");
      print("Last payment date: ${subscription.lastPaymentDate}");
      print("Next payment date: ${subscription.nextPaymentDate}");

      // Important: Use the payment date directly from the display
      // This is the date that is currently shown to the user as the next payment date
      final DateTime baseDate = subscription.startDate;

      // Calculate next payment date based on the original payment date
      DateTime nextPaymentDate;

      // Calculate the next payment directly relative to the original date
      switch (subscription.paymentDuration.toLowerCase()) {
        case 'daily':
          nextPaymentDate = baseDate.add(const Duration(days: 1));
          break;
        case 'weekly':
          nextPaymentDate = baseDate.add(const Duration(days: 7));
          break;
        case 'yearly':
          nextPaymentDate = DateTime(
            baseDate.year + 1,
            baseDate.month,
            baseDate.day,
          );
          break;
        case 'monthly':
        default:
          // Simple month calculation
          int year = baseDate.year;
          int month = baseDate.month + 1;
          int day = baseDate.day;

          if (month > 12) {
            month = 1;
            year += 1;
          }

          // Handle shorter months
          int maxDays = DateUtils.getDaysInMonth(year, month);
          if (day > maxDays) day = maxDays;

          nextPaymentDate = DateTime(year, month, day);
          break;
      }

      print("PAYMENT DEBUG - Calculated next payment: $nextPaymentDate");

      // Clear approach: create a completely new subscription object
      final updatedSubscription = Subscription(
        id: subscription.id,
        name: subscription.name,
        price: subscription.price,
        category: subscription.category,
        paymentDuration: subscription.paymentDuration,
        startDate: subscription.startDate, // Keep original start date
        lastPaymentDate: DateTime.now(), // Set to now
        nextPaymentDate: nextPaymentDate, // Set to calculated date
        isPaid: true, // Mark as paid
      );

      print(
        "PAYMENT DEBUG - New next payment date: ${updatedSubscription.nextPaymentDate}",
      );

      // Save to database
      await _subscriptionManager.updateSubscription(updatedSubscription);

      // Schedule notifications for the next payment
      if (subscription.id != null) {
        final notificationService = NotificationService();

        try {
          // Try to parse the ID as an integer if possible
          final subscriptionIdInt = int.tryParse(subscription.id!) ?? 0;
          await notificationService.scheduleSubscriptionReminders(
            subscriptionId: subscriptionIdInt,
            subscriptionName: subscription.name,
            paymentDate: nextPaymentDate,
          );
        } catch (e) {
          print("Failed to schedule notification: $e");
          // Continue with the rest of the function even if notification scheduling fails
        }
      }

      // Update local state
      setState(() {
        subscription = updatedSubscription;
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment recorded successfully!')));

      // Always return to the previous screen with updated data
      Navigator.pop(context, {
        'action': 'update',
        'subscription': updatedSubscription,
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error recording payment: $e')));
    }
  }

  Future<void> _editSubscription() async {
    final result = await showDialog<Subscription>(
      context: Navigator.of(context, rootNavigator: true).context!,
      builder:
          (context) => AddSubscriptionDialog(
            isEditing: true,
            existingSubscription: subscription,
            onAdd: (updatedSubscription) async {
              await _subscriptionManager.updateSubscription(
                updatedSubscription,
              );
            },
          ),
    );

    if (result != null) {
      setState(() {
        subscription = result;
      });
      // Notify previous screen about the update
      Navigator.pop(context, {'action': 'update', 'subscription': result});
    }
  }

  Future<void> _deleteSubscription() async {
    final bool confirm =
        await showDialog<bool>(
          context: Navigator.of(context, rootNavigator: true).context!,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Deletion"),
                content: Text(
                  'Are you sure you want to delete "${subscription.name}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm && subscription.id != null) {
      final success = await _subscriptionManager.deleteSubscription(
        subscription.id!,
      );
      if (success) {
        Navigator.pop(context, {'action': 'delete', 'id': subscription.id});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete subscription')),
        );
      }
    }
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  List<DateTime> _getUpcomingPayments() {
    List<DateTime> upcomingPayments = [];
    DateTime baseDate =
        subscription.nextPaymentDate ??
        (subscription.lastPaymentDate ?? subscription.startDate);

    // Generate next 6 payment dates
    for (int i = 0; i < 6; i++) {
      DateTime nextDate;

      switch (subscription.paymentDuration.toLowerCase()) {
        case 'daily':
          nextDate = baseDate.add(Duration(days: i));
          break;
        case 'weekly':
          nextDate = baseDate.add(Duration(days: 7 * i));
          break;
        case 'yearly':
          nextDate = DateTime(baseDate.year + i, baseDate.month, baseDate.day);
          break;
        case 'monthly':
        default:
          // Fix: If it's the first upcoming payment (i=0), use the base date
          if (i == 0) {
            nextDate = baseDate;
          } else {
            // For subsequent payments, correctly add i months
            int newMonth = baseDate.month + i;
            int yearOffset = (newMonth - 1) ~/ 12;
            newMonth = (newMonth - 1) % 12 + 1;

            // Ensure we handle month length differences
            int maxDays = DateUtils.getDaysInMonth(
              baseDate.year + yearOffset,
              newMonth,
            );
            int day = baseDate.day > maxDays ? maxDays : baseDate.day;

            nextDate = DateTime(baseDate.year + yearOffset, newMonth, day);
          }
          break;
      }

      upcomingPayments.add(nextDate);
    }

    return upcomingPayments;
  }

  @override
  Widget build(BuildContext context) {
    final nextPaymentDate = subscription.nextPaymentDate;
    final lastPaymentDate = subscription.lastPaymentDate;
    final upcomingPayments = _getUpcomingPayments();
    final bool isPastDue =
        nextPaymentDate != null && nextPaymentDate.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription Details"),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _editSubscription),
          IconButton(icon: Icon(Icons.delete), onPressed: _deleteSubscription),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card with subscription details
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      subscription.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          subscription.isPaid
                                              ? Colors.green.withOpacity(0.2)
                                              : (isPastDue
                                                  ? Colors.red.withOpacity(0.2)
                                                  : Colors.orange.withOpacity(
                                                    0.2,
                                                  )),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      subscription.isPaid
                                          ? 'PAID'
                                          : (isPastDue
                                              ? 'PAST DUE'
                                              : 'UPCOMING'),
                                      style: TextStyle(
                                        color:
                                            subscription.isPaid
                                                ? Colors.green.shade800
                                                : (isPastDue
                                                    ? Colors.red.shade800
                                                    : Colors.orange.shade800),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Price row
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${subscription.price.toStringAsFixed(2)} / ${subscription.paymentDuration.toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Category
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Category: ${subscription.category}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Change "Start date" to "Payment date"
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Payment date: ${_getFormattedDate(subscription.startDate)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              if (lastPaymentDate != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last payment: ${_getFormattedDate(lastPaymentDate)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              if (nextPaymentDate != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color:
                                          isPastDue
                                              ? Colors.red
                                              : Colors.orange.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Next payment: ${_getFormattedDate(nextPaymentDate)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            isPastDue
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            isPastDue
                                                ? Colors.red
                                                : Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Upcoming payments section
                      Text(
                        'Upcoming Payments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: upcomingPayments.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final date = upcomingPayments[index];
                            final isPast = date.isBefore(DateTime.now());
                            final isNext =
                                nextPaymentDate != null &&
                                DateFormat('yyyy-MM-dd').format(date) ==
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(nextPaymentDate);

                            return ListTile(
                              dense: true,
                              title: Text(
                                _getFormattedDate(date),
                                style: TextStyle(
                                  fontWeight:
                                      isNext
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: isPast ? Colors.grey : Colors.black,
                                ),
                              ),
                              trailing: Text(
                                '\$${subscription.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isPast ? Colors.grey : Colors.black,
                                ),
                              ),
                              leading: Icon(
                                isNext ? Icons.arrow_right : Icons.schedule,
                                color:
                                    isNext
                                        ? Colors.blue
                                        : (isPast
                                            ? Colors.grey
                                            : Colors.black54),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _markAsPaid,
          child: const Text(
            'Mark as Paid',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
