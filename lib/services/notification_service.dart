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
    // Prevent double initialization
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize plugin with settings
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      debugPrint('Notification plugin initialized successfully');

      // Only try to create notification channel on Android
      if (Theme.of(NavigationService.navigatorKey.currentContext!).platform ==
          TargetPlatform.android) {
        // Check if Android implementation is available
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'subscription_reminders',
            'Subscription Reminders',
            description: 'Notifications for upcoming subscription payments',
            importance: Importance.high,
          );

          await androidImplementation.createNotificationChannel(channel);
          debugPrint('Android notification channel created');
        } else {
          debugPrint('Android implementation not available');
        }
      }

      // Request permissions for iOS
      if (Theme.of(NavigationService.navigatorKey.currentContext!).platform ==
          TargetPlatform.iOS) {
        final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();

        if (iOSImplementation != null) {
          await iOSImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          debugPrint('iOS permissions requested');
        }
      }

      _initialized = true;

      // Show test notification
      await showTestNotification();
    } catch (e) {
      debugPrint('Error in notification service initialization: $e');
    }
  }

  // Show an immediate test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription:
              'Notifications for upcoming subscription payments',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
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
      notificationDetails,
    );
  }

  // Schedule all reminder notifications for a subscription
  Future<void> scheduleSubscriptionReminders({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime paymentDate,
  }) async {
    // Cancel any existing notifications for this subscription
    await cancelSubscriptionNotifications(subscriptionId);

    debugPrint('Scheduling reminders for $subscriptionName due $paymentDate');

    // Schedule 7-day reminder
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 7),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 7 days',
      scheduledDate: paymentDate.subtract(const Duration(days: 7)),
    );

    // Schedule 3-day reminder
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 3),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 3 days',
      scheduledDate: paymentDate.subtract(const Duration(days: 3)),
    );

    // Schedule 24-hour reminder
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 1),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 24 hours',
      scheduledDate: paymentDate.subtract(const Duration(days: 1)),
    );

    // Schedule on-day reminder
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 0),
      title: 'Payment Due Today',
      body: 'Your payment for $subscriptionName is due today',
      scheduledDate: paymentDate,
    );

    debugPrint('Reminders scheduled successfully');
  }

  // Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Only schedule if the date is in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint(
        'Skipping notification: scheduled date is in the past ($scheduledDate)',
      );
      return;
    }

    debugPrint('Scheduling notification ID $id for $scheduledDate');

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
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Generate unique notification ID based on subscription ID and days before
  int _generateNotificationId(int subscriptionId, int daysBefore) {
    // Combine subscription ID with days before to create unique ID
    // This ensures each reminder has a unique ID while keeping them grouped by subscription
    return subscriptionId * 100 + daysBefore;
  }

  // Cancel all notifications for a specific subscription
  Future<void> cancelSubscriptionNotifications(int subscriptionId) async {
    // Cancel 7-day notification
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 7),
    );
    // Cancel 3-day notification
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 3),
    );
    // Cancel 24-hour notification
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, 1),
    );
  }

  // For recurring subscriptions - reschedule notifications after payment
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
        // Advance to the same day next month
        nextPaymentDate = DateTime(
          lastPaymentDate.year,
          lastPaymentDate.month + 1,
          lastPaymentDate.day,
        );
        break;
      case 'yearly':
        // Advance to the same day next year
        nextPaymentDate = DateTime(
          lastPaymentDate.year + 1,
          lastPaymentDate.month,
          lastPaymentDate.day,
        );
        break;
      default:
        return; // Unknown recurring type
    }

    // Schedule new notifications for the next payment date
    await scheduleSubscriptionReminders(
      subscriptionId: subscriptionId,
      subscriptionName: subscriptionName,
      paymentDate: nextPaymentDate,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Add a NavigationService to provide global access to the navigator context
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
