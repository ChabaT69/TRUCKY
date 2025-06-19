import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  Future<bool> _checkExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    try {
      final androidPlugin =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin == null) return false;

      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      return canSchedule ?? false;
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
      return false;
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final androidPlugin =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
    }
  }

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
        onDidReceiveNotificationResponse: (response) async {
          debugPrint('Notification clicked: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final payloadData = jsonDecode(response.payload!);
              final subscriptionId = payloadData['subscriptionId'];

              // Only reschedule if it's the "due today" or daily notification
              if (response.id == _generateNotificationId(subscriptionId, 0) ||
                  response.id == _generateNotificationId(subscriptionId, -1)) {
                if (payloadData['type'] == 'recurring') {
                  await rescheduleForRecurring(
                    subscriptionId: payloadData['subscriptionId'],
                    subscriptionName: payloadData['subscriptionName'],
                    lastPaymentDate: DateTime.parse(payloadData['paymentDate']),
                    recurringType: payloadData['recurringType'],
                  );
                }
              }
            } catch (e) {
              debugPrint('Error handling notification payload: $e');
            }
          }
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
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription:
              'Notifications for upcoming subscription payments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // await flutterLocalNotificationsPlugin.show(
      //   0,
      //   'Notifications Enabled',
      //   'You will receive reminders for your subscription payments',
      //   details,
      // );
      debugPrint('Test notification shown successfully');
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  Future<void> scheduleSubscriptionReminders({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime paymentDate,
    required String recurringType,
  }) async {
    // Temporary notification for demonstration
    await flutterLocalNotificationsPlugin.show(
      -1, // Using a different ID to not conflict with scheduled notifications
      'Subscription Added!',
      'Reminders for $subscriptionName have been set.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription:
              'Notifications for upcoming subscription payments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    await cancelSubscriptionNotifications(subscriptionId);

    debugPrint('Scheduling reminders for $subscriptionName on $paymentDate');

    final payload = jsonEncode({
      'type': 'recurring',
      'subscriptionId': subscriptionId,
      'subscriptionName': subscriptionName,
      'paymentDate': paymentDate.toIso8601String(),
      'recurringType': recurringType,
    });

    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 7),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 7 days',
      scheduledDate: paymentDate.subtract(const Duration(days: 7)),
      payload: payload,
    );
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 3),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 3 days',
      scheduledDate: paymentDate.subtract(const Duration(days: 3)),
      payload: payload,
    );
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 1),
      title: 'Payment Reminder',
      body: 'Your payment for $subscriptionName is due in 24 hours',
      scheduledDate: paymentDate.subtract(const Duration(days: 1)),
      payload: payload,
    );
    await _scheduleNotification(
      id: _generateNotificationId(subscriptionId, 0),
      title: 'Payment Due Today',
      body: 'Your payment for $subscriptionName is due today',
      scheduledDate: paymentDate,
      payload: payload,
    );

    debugPrint('All reminders scheduled');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Ensure notification is scheduled for 9:00 AM
    final notificationTime = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9, // 9 AM
    );

    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('Skipped scheduling: $notificationTime is in the past');
      return;
    }

    try {
      debugPrint(
        'Attempting to schedule notification: $title at $notificationTime',
      );

      bool useExactAlarm = true;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final hasPermission = await _checkExactAlarmPermission();
        if (!hasPermission) {
          debugPrint('Cannot schedule exact alarm: permission not granted');
          await _requestExactAlarmPermission();

          // Recheck permission after requesting
          final newPermission = await _checkExactAlarmPermission();
          if (!newPermission) {
            debugPrint('Falling back to inexact alarm scheduling');
            useExactAlarm = false;
          } else {
            debugPrint('Permission granted after request');
          }
        }
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        notificationTime,
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
        payload: payload,
        androidAllowWhileIdle: useExactAlarm,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint(
        'Notification scheduled successfully: $title at $notificationTime',
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        debugPrint('Cannot schedule exact alarm: permission not granted');
        await _requestExactAlarmPermission();
      } else {
        debugPrint('Failed to schedule notification: $e');
      }
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  int _generateNotificationId(int subscriptionId, int daysBefore) {
    return subscriptionId * 100 + daysBefore;
  }

  Future<void> cancelSubscriptionNotifications(int subscriptionId) async {
    // Cancel daily notification
    await flutterLocalNotificationsPlugin.cancel(
      _generateNotificationId(subscriptionId, -1),
    );

    // Cancel standard reminders
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

  Future<void> scheduleDailyReminder({
    required int subscriptionId,
    required String subscriptionName,
    required DateTime startDate,
  }) async {
    try {
      final payload = jsonEncode({
        'type': 'recurring',
        'subscriptionId': subscriptionId,
        'subscriptionName': subscriptionName,
        'paymentDate': startDate.toIso8601String(),
        'recurringType': 'daily',
      });

      final tzDate = tz.TZDateTime.from(startDate, tz.local);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        _generateNotificationId(subscriptionId, -1), // Use -1 for daily ID
        'Daily Payment Reminder',
        'Your payment for $subscriptionName is due today',
        tzDate,
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
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        'Daily notification scheduled for $subscriptionName starting from $startDate',
      );
    } catch (e) {
      debugPrint('Failed to schedule daily notification: $e');
    }
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
        await scheduleDailyReminder(
          subscriptionId: subscriptionId,
          subscriptionName: subscriptionName,
          startDate: nextPaymentDate,
        );
        return; // Return early since we handled daily differently
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
      recurringType: recurringType,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
