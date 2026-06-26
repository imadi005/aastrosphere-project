import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request permissions
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    _initialized = true;
  }

  static Future<void> initialize() => init();

  static Future<void> scheduleDailySnapshot({
    required String quote,
    required String rating,
    required String dailyQuality,
  }) async {
    await cancelAll();
    if (!_initialized) await init();

    final now = DateTime.now();
    // Schedule for 8 AM today (or tomorrow if already past 8)
    var scheduled = DateTime(now.year, now.month, now.day, 8, 0);
    if (now.isAfter(scheduled)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final emoji = rating == 'favorable' ? '✨' : rating == 'caution' ? '⚠️' : '🔮';
    final title = '$emoji $dailyQuality';
    final body = '"$quote"';

    await _scheduleAt(
      id: 1,
      title: title,
      body: body,
      scheduledTime: scheduled,
      daily: true,
    );
  }

  static Future<void> scheduleAccidentWarnings({
    required List<Map<String, dynamic>> accidentRiskHours,
  }) async {
    for (int i = 0; i < accidentRiskHours.length && i < 3; i++) {
      final h = accidentRiskHours[i];
      final hour = h['hour'] as int? ?? 0;
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, 0);
      if (scheduled.isAfter(now)) {
        await _scheduleAt(
          id: 100 + i,
          title: '⚠️ Careful this hour',
          body: 'Move slowly and stay aware — risk window active.',
          scheduledTime: scheduled,
          daily: false,
        );
      }
    }
  }

  static Future<void> scheduleNotification({
    required int id, required String title,
    required String body, required DateTime scheduledTime,
  }) => _scheduleAt(id: id, title: title, body: body, scheduledTime: scheduledTime, daily: false);

  static Future<void> _scheduleAt({
    required int id, required String title, required String body,
    required DateTime scheduledTime, required bool daily,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'aastrosphere_daily', 'Daily Predictions',
      channelDescription: 'Daily numerology predictions and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    if (daily) {
      await _plugin.zonedSchedule(
        id, title, body, tzTime, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      await _plugin.zonedSchedule(
        id, title, body, tzTime, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
