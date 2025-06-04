import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Init settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      debugPrint('Notification plugin initialized successfully');

      // Create Android notification channel if needed
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          const channel = AndroidNotificationChannel(
            'subscription_reminders',
            'Subscription Reminders',
            description: 'Notifications for upcoming subscription payments',
            importance: Importance.high,
          );
          await androidImplementation.createNotificationChannel(channel);
          debugPrint('Android notification channel created');
        }
      }

      _initialized = true;

      // Show a test notification to verify
      await showTestNotification();
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  Future<void> showTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'subscription_reminders',
        'Subscription Reminders',
        channelDescription: 'Notifications for upcoming subscription payments',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notifications Enabled',
      'You will receive reminders for your subscription payments',
      details,
    );
  }

  Future<void> scheduleSubscriptionReminders({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime paymentDate,
  }) async {
    await cancelSubscriptionNotifications(subscriptionId);

    debugPrint('Scheduling reminders for $subscriptionName on $paymentDate');

    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 7),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 7 days',
      scheduledDate: paymentDate.subtract(const Duration(days: 7)),
    );
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 3),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 3 days',
      scheduledDate: paymentDate.subtract(const Duration(days: 3)),
    );
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 1),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 24 hours',
      scheduledDate: paymentDate.subtract(const Duration(days: 1)),
    );
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 0),
      title: 'Payment Due Today',
      body: 'Your payment for $subscriptionName is due today',
      scheduledDate: paymentDate,
    );

    debugPrint('All reminders scheduled');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('Skipped scheduling: $scheduledDate is in the past');
      return;
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_reminders',
            'Subscription Reminders',
            channelDescription:
                'Notifications for upcoming subscription payments',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('Notification scheduled: $title at $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  int _generateNotificationId(int subscriptionId, int daysBefore) {
    return subscriptionId * 100 + daysBefore;
  }

  Future<void> cancelSubscriptionNotifications(int subscriptionId) async {
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 7),
    );
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 3),
    );
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 1),
    );
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 0),
    );
  }

  Future<void> rescheduleForRecurring({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime lastPaymentDate,
    required String recurringType,
  }) async {
    DateTime nextPaymentDate;
    switch (recurringType.toLowerCase()) {
      case 'daily':
        nextPaymentDate = lastPaymentDate.add(const Duration(days: 1));
        break;
      case 'monthly':
        nextPaymentDate = DateTime(
          lastPaymentDate.year,
          lastPaymentDate.month + 1,
          lastPaymentDate.day,
        );
        break;
      case 'yearly':
        nextPaymentDate = DateTime(
          lastPaymentDate.year + 1,
          lastPaymentDate.month,
          lastPaymentDate.day,
        );
        break;
      default:
        debugPrint('Unknown recurring type: $recurringType');
        return;
    }

    await scheduleSubscriptionReminders(
      subscriptionId: subscriptionId,
      subscriptionName: subscriptionName,
      paymentDate: nextPaymentDate,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
