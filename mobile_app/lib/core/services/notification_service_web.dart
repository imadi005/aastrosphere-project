// Web stub — notifications not supported on web
class NotificationService {
  static Future<void> init() async {}
  static Future<void> initialize() async {}
  static Future<void> scheduleDailySnapshot({
    required String quote,
    required String rating,
    required String dailyQuality,
  }) async {}
  static Future<void> scheduleAccidentWarnings({
    required List<Map<String, dynamic>> accidentRiskHours,
  }) async {}
  static Future<void> scheduleNotification({
    required int id, required String title,
    required String body, required DateTime scheduledTime,
  }) async {}
  static Future<void> cancelAll() async {}
}
