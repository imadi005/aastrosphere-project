import 'package:flutter/foundation.dart';

// Notifications not supported on web — stub implementation
class NotificationService {
  static Future<void> init() async {}
  static Future<void> initialize() async {}
  static Future<void> scheduleDailySnapshot(Map<String, dynamic> data) async {}
  static Future<void> scheduleAccidentWarnings(List<dynamic> hours) async {}
  static Future<void> scheduleNotification({
    required int id, required String title,
    required String body, required DateTime scheduledTime,
  }) async {}
  static Future<void> cancelAll() async {}
}
