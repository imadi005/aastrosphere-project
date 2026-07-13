import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
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

const _kNotifDobKey = 'notif_dob';
const _kDailyTask = 'aastro_daily_snapshot';
const _kApiBase = 'https://aastrosphere-project.vercel.app';

/// Background task — runs every morning, fetches FRESH /api/today and fires
/// the daily notification with that day's real content (never stale).
@pragma('vm:entry-point')
void dailySnapshotDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _kDailyTask) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final dob = prefs.getString(_kNotifDobKey);
      if (dob == null || dob.isEmpty) return true;

      final now = DateTime.now();
      final clientDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final resp = await http
          .post(
            Uri.parse('$_kApiBase/api/today'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'dob': dob,
              'client_date': clientDate,
              'client_hour': now.hour,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) return false; // retry via backoff

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final quote = data['quote'] as String? ?? '';
      final rating = data['rating'] as String? ?? 'caution';
      final label = data['rating_label'] as String? ?? 'Your day at a glance';
      if (quote.isEmpty) return true;

      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ));
      final emoji =
          rating == 'favorable' ? '✨' : rating == 'caution' ? '⚠️' : '🔮';
      await plugin.show(
        1,
        '$emoji $label',
        '"$quote"',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aastrosphere_daily', 'Daily Predictions',
            channelDescription: 'Daily numerology predictions and alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      return true;
    } catch (_) {
      return false; // retry via backoff
    }
  });
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
      await _registerDailyWorker();
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

    // Same-day fallback ONLY: if today's 8 AM hasn't passed yet, schedule it
    // with TODAY's (accurate) content as a one-shot. Never schedule tomorrow
    // with today's content — the background worker fetches fresh data each
    // morning and fires the notification itself.
    final now = DateTime.now();
    final todayEight = DateTime(now.year, now.month, now.day, 8, 0);
    if (now.isAfter(todayEight)) return;

    final emoji = rating == 'favorable' ? '✨' : rating == 'caution' ? '⚠️' : '🔮';
    await _scheduleAt(
      id: 1,
      title: '$emoji $dailyQuality',
      body: '"$quote"',
      scheduledTime: todayEight,
      daily: false,
    );
  }

  static Future<void> _registerDailyWorker() async {
    try {
      await Workmanager().initialize(dailySnapshotDispatcher);
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, now.day, 7, 55);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      await Workmanager().registerPeriodicTask(
        _kDailyTask,
        _kDailyTask,
        frequency: const Duration(hours: 24),
        initialDelay: next.difference(now),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 15),
      );
    } catch (_) {}
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
