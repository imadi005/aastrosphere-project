import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const _focusDateKey = 'today_focus_date';
const _focusLockedKey = 'today_focus_locked';
const _focusCompletedKey = 'today_focus_completed';

void _handleFocusNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId != 'focus_done' && actionId != 'focus_not_yet') return;

  () async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_focusDateKey, today);
    await prefs.setBool(_focusLockedKey, true);
    await prefs.setBool(_focusCompletedKey, actionId == 'focus_done');
    if (actionId == 'focus_done') {
      await NotificationService.cancelFocusReminders();
    }
  }();
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  _handleFocusNotificationResponse(response);
}

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
      onDidReceiveNotificationResponse: _handleFocusNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
    if (!_initialized) await init();
    await _plugin.cancel(1);

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
    if (!_initialized) await init();
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(100 + i);
    }
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

  static Future<void> scheduleFocusReminders({required String task}) async {
    if (!_initialized) await init();
    await cancelFocusReminders();

    final now = DateTime.now();
    final messages = [
      'Tiny check-in: "$task" is still waiting for you. Ho gaya?',
      'Your locked focus is "$task". One small step now is enough. Done?',
      'Soft reminder: "$task". You do not need perfect, just progress. Completed?',
      'Last gentle nudge for today: "$task". Can we close this loop?',
    ];

    var scheduled = now.add(const Duration(hours: 2));
    for (int i = 0; i < messages.length; i++) {
      if (scheduled.day == now.day && scheduled.hour <= 22) {
        await _scheduleAt(
          id: 300 + i,
          title: 'Focus check-in',
          body: messages[i],
          scheduledTime: scheduled,
          daily: false,
          focusActions: true,
        );
      }
      scheduled = scheduled.add(Duration(hours: i.isEven ? 3 : 2));
    }
  }

  static Future<void> cancelFocusReminders() async {
    if (!_initialized) await init();
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(300 + i);
    }
  }

  static Future<void> _scheduleAt({
    required int id, required String title, required String body,
    required DateTime scheduledTime, required bool daily, bool focusActions = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'aastrosphere_daily', 'Daily Predictions',
      channelDescription: 'Daily numerology predictions and alerts',
      importance: Importance.high,
      priority: Priority.high,
      actions: focusActions
          ? const <AndroidNotificationAction>[
              AndroidNotificationAction('focus_done', 'Yes', showsUserInterface: true),
              AndroidNotificationAction('focus_not_yet', 'No', showsUserInterface: true),
            ]
          : null,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

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
