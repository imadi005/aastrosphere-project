import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── Notification IDs ──────────────────────────────────────────────────────
  static const int _dailySnapshotId = 1001;
  static const int _accidentBaseId  = 2000; // 2000+ for accident warnings

  // ── Init ──────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request Android 13+ permission
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Both daily snapshot + accident warning open Today screen
    // Navigation handled via global navigator key in main.dart
    _navigatorKey?.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
  }

  static GlobalKey<NavigatorState>? _navigatorKey;
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // ── Daily Snapshot notification at 7 AM ──────────────────────────────────
  static Future<void> scheduleDailySnapshot({
    required String quote,
    required String rating,      // favorable / good / caution / avoid
    required String dailyQuality, // e.g. "Authority Day"
  }) async {
    await init();
    await _plugin.cancel(_dailySnapshotId);

    final title = 'Your Daily Snapshot';
    final body = quote;

    // Schedule for 7:00 AM local time today (or tomorrow if past 7)
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 10, 0, 0);
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailySnapshotId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_snapshot',
          'Daily Snapshot',
          channelDescription: 'Your daily numerology snapshot',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            body,
            summaryText: dailyQuality,
          ),
          color: const Color(0xFFB8973D),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Accident risk warning — 1 hour before the risk window ────────────────
  static Future<void> scheduleAccidentWarnings({
    required List<Map<String, dynamic>> accidentRiskHours,
  }) async {
    await init();

    // Cancel all previous accident warnings
    for (int i = _accidentBaseId; i < _accidentBaseId + 24; i++) {
      await _plugin.cancel(i);
    }

    final now = DateTime.now();

    for (int i = 0; i < accidentRiskHours.length; i++) {
      final risk = accidentRiskHours[i];
      final warnHour = risk['warn_at_hour'] as int? ?? 0;
      final riskLevel = risk['risk_level'] as String? ?? 'medium';
      final reason = risk['reason'] as String? ?? 'Physical caution recommended this hour';
      final timeLabel = risk['time_label'] as String? ?? '';

      if (warnHour < 0) continue;

      var warningTime = DateTime(now.year, now.month, now.day, warnHour, 0, 0);
      if (now.isAfter(warningTime)) continue; // already past

      final isHigh = riskLevel == 'high';
      final title = isHigh ? '⚠️ Accident Risk Ahead' : 'Physical Caution — $timeLabel';
      final body = '$reason\nBe extra careful at $timeLabel today.';

      await _plugin.zonedSchedule(
        _accidentBaseId + i,
        title,
        body,
        tz.TZDateTime.from(warningTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'accident_warning',
            'Accident Warnings',
            channelDescription: 'Numerology-based physical caution alerts',
            importance: isHigh ? Importance.max : Importance.high,
            priority: isHigh ? Priority.max : Priority.high,
            color: isHigh
                ? const Color(0xFFEF4444)
                : const Color(0xFFF59E0B),
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ── Show immediate notification (for testing) ────────────────────────────
  static Future<void> showImmediate({
    required String title,
    required String body,
    int id = 9999,
  }) async {
    await init();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate',
          'Immediate',
          channelDescription: 'Immediate notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  // ── Cancel all ────────────────────────────────────────────────────────────
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
