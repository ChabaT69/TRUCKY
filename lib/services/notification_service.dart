import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:trucky/models/subscription.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleSubscriptionReminders(Subscription subscription) async {
    if (subscription.id == null) return;

    final now = DateTime.now();
    DateTime targetDate =
        subscription.nextPaymentDate ?? subscription.startDate;

    if (targetDate.isBefore(now)) {
      return;
    }

    await cancelSubscriptionNotifications(subscription.id!);

    // Schedule future notifications
    await _scheduleNotificationFor(
      subscription,
      targetDate,
      const Duration(days: 7),
    );
    await _scheduleNotificationFor(
      subscription,
      targetDate,
      const Duration(days: 3),
    );
    await _scheduleNotificationFor(
      subscription,
      targetDate,
      const Duration(days: 1),
    );

    // If the due date is within 7 days, show an immediate notification
    // to confirm to the user that reminders are active.
    final timeUntilDue = targetDate.difference(now);
    if (timeUntilDue < const Duration(days: 7)) {
      final daysUntil = timeUntilDue.inDays;
      final String timeStr =
          daysUntil < 1
              ? 'in less than a day'
              : 'in $daysUntil day${daysUntil > 1 ? 's' : ''}';

      await flutterLocalNotificationsPlugin.show(
        (subscription.id.hashCode + 999).hashCode, // Unique ID
        'Reminder Set',
        'Your payment for ${subscription.name} is due $timeStr.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_channel',
            'Subscription Notifications',
            channelDescription: 'Notifications for subscription payments',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> _scheduleNotificationFor(
    Subscription subscription,
    DateTime targetDate,
    Duration timeBefore,
  ) async {
    final scheduledDate = targetDate.subtract(timeBefore);

    final now = tz.TZDateTime.now(tz.local);
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzScheduledDate.isBefore(now)) {
      return;
    }

    final days = timeBefore.inDays;
    final String timeStr =
        days > 0 ? '$days day${days > 1 ? 's' : ''}' : '24 hours';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      (subscription.id.hashCode + timeBefore.inMilliseconds).hashCode,
      'Payment Reminder',
      'Your payment for ${subscription.name} is due in $timeStr',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_channel',
          'Subscription Notifications',
          channelDescription: 'Notifications for subscription payments',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelSubscriptionNotifications(String subscriptionId) async {
    await flutterLocalNotificationsPlugin.cancel(
      (subscriptionId.hashCode + const Duration(days: 7).inMilliseconds)
          .hashCode,
    );
    await flutterLocalNotificationsPlugin.cancel(
      (subscriptionId.hashCode + const Duration(days: 3).inMilliseconds)
          .hashCode,
    );
    await flutterLocalNotificationsPlugin.cancel(
      (subscriptionId.hashCode + const Duration(days: 1).inMilliseconds)
          .hashCode,
    );
  }
}
