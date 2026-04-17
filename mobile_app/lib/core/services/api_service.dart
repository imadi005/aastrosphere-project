import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _base = 'https://aastrosphere-project.vercel.app';

  /// Client's local date as ISO string — YYYY-MM-DD
  /// This ensures server uses correct local date regardless of UTC offset
  static String get clientDate {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int get clientHour => DateTime.now().hour;
  static int get _clientHour => clientHour;

  static Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('API error ${response.statusCode}: ${response.body}');
    } catch (e) {
      throw Exception('Connection Failed: $e');
    }
  }

  // ─── TODAY — always sends client's local date+hour ───────────────────
  static Future<Map<String, dynamic>> getToday(String dob) =>
      _post('/api/today', {
        'dob': dob,
        'client_date': clientDate,
        'client_hour': _clientHour,
      });

  // ─── INSIGHTS — always send client date ──────────────────────────────
  static Future<Map<String, dynamic>> getWeeklyInsights(String dob) =>
      _post('/api/insights/weekly', {
        'dob': dob,
        'client_date': clientDate,
      });

  static Future<Map<String, dynamic>> getMonthlyInsights(String dob) =>
      _post('/api/insights/monthly', {
        'dob': dob,
        'client_date': clientDate,
      });

  static Future<Map<String, dynamic>> getYearlyInsights(String dob) =>
      _post('/api/insights/yearly', {
        'dob': dob,
        'client_date': clientDate,
      });

  // ─── CHART ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getChart(String dob, [int? clientHour]) =>
      _post('/api/chart', {
        'dob': dob,
        'client_date': clientDate,
        'client_hour': clientHour ?? _clientHour,
      });

  static Future<Map<String, dynamic>> getChartForDate(
          String dob, String date, int? hour) =>
      _post('/api/chart/date', {
        'dob': dob,
        'date': date,
        if (hour != null) 'hour': hour,
      });

  // ─── STATIC — don't need date ────────────────────────────────────────
  static Future<Map<String, dynamic>> getLifeInsights(String dob) =>
      _post('/api/insights/life', {'dob': dob});

  static Future<Map<String, dynamic>> getDeepInsights(String dob) =>
      _post('/api/insights/deep', {'dob': dob});

  static Future<Map<String, dynamic>> getDailyInsights(String dob) =>
      _post('/api/insights/daily', {'dob': dob});

  static Future<Map<String, dynamic>> getDashas(String dob,
          {String type = 'mahadasha'}) =>
      _post('/api/dashas', {'dob': dob, 'type': type});

  static Future<Map<String, dynamic>> getCompatibility(
      String dob1, String dob2, {String? clientDate, int? clientHour, String? relation}) =>
      _post('/api/compatibility', {
        'dob1': dob1, 'dob2': dob2,
        'client_date': clientDate ?? ApiService.clientDate,
        'client_hour': clientHour ?? _clientHour,
        if (relation != null) 'relation': relation,
      });

  static Future<Map<String, dynamic>> checkName(String name, String dob) =>
      _post('/api/name', {'name': name, 'dob': dob});

  static Future<Map<String, dynamic>> getKarmic(String dob) =>
      _post('/api/karmic', {'dob': dob});

  static Future<Map<String, dynamic>> getFullPrediction(String dob) =>
      _post('/api/predict/full', {'dob': dob});

  static Future<Map<String, dynamic>> getYogas(String dob) =>
      _post('/api/predict/yogas', {'dob': dob});

  static Future<Map<String, dynamic>> getDashaInsight(String dob) =>
      _post('/api/predict/dasha-insight', {'dob': dob});

  static Future<Map<String, dynamic>> getHealthPrediction(String dob) =>
      _post('/api/predict/health', {'dob': dob});

  static Future<Map<String, dynamic>> getFinancePrediction(String dob) =>
      _post('/api/predict/finance', {'dob': dob});

  static Future<Map<String, dynamic>> getRelationshipPrediction(String dob) =>
      _post('/api/predict/relationship', {'dob': dob});

  static Future<Map<String, dynamic>> prashna(int number) =>
      _post('/api/predict/prashna', {'number': number});

  static Future<Map<String, dynamic>> getNumberMeaning(int number) =>
      _post('/api/predict/number', {'number': number});
}
