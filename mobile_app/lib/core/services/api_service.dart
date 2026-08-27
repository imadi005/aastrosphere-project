import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Thrown when the backend returns 402 (out of question credits).
class OutOfCreditsException implements Exception {
  final String message;
  OutOfCreditsException(this.message);
}

/// Thrown when the backend returns 401 (missing/expired sign-in session).
class NotAuthenticatedException implements Exception {
  final String message;
  NotAuthenticatedException(this.message);
}

/// Thrown for real backend/server failures (500s, bad responses, timeouts) —
/// kept distinct from genuine connectivity issues so the UI never blames
/// "no internet" for a problem that's actually on the server.
class ServerErrorException implements Exception {
  final String message;
  ServerErrorException(this.message);
}

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

  /// Like _post, but attaches the signed-in user's Firebase ID token and
  /// translates 401/402 into typed exceptions the UI can handle specifically
  /// (e.g. "you're out of questions" vs a generic connection error).
  static Future<Map<String, dynamic>> _authedPost(
      String endpoint, Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw NotAuthenticatedException('Please sign in to continue.');
    }
    final token = await user.getIdToken();
    try {
      final response = await http
          .post(
            Uri.parse('$_base$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) return decoded;
      if (response.statusCode == 401) {
        throw NotAuthenticatedException(
            decoded['error'] as String? ?? 'Please sign in again.');
      }
      if (response.statusCode == 402) {
        throw OutOfCreditsException(decoded['message'] as String? ??
            "You're out of questions. Buy a pack or subscribe to keep asking.");
      }
      throw ServerErrorException('The server returned an error (${response.statusCode}). Please try again in a moment.');
    } on OutOfCreditsException {
      rethrow;
    } on NotAuthenticatedException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('ApiService: genuine network failure — $e');
      throw Exception('No internet connection. Check your network and try again.');
    } on TimeoutException catch (e) {
      debugPrint('ApiService: request timed out — $e');
      throw ServerErrorException('The server took too long to respond. Please try again.');
    } catch (e) {
      // Anything else (JSON parse failure, unexpected shape, etc.) is a
      // server/response problem, NOT a connectivity problem — never label
      // this as "no internet", since that sends debugging in the wrong
      // direction. Logged here so `flutter logs` / a connected debugger
      // shows the real cause even though the user only sees a friendly message.
      debugPrint('ApiService: unexpected error in _authedPost — $e');
      throw ServerErrorException('Something went wrong on our end. Please try again.');
    }
  }

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
      throw ServerErrorException('The server returned an error (${response.statusCode}). Please try again in a moment.');
    } on SocketException catch (e) {
      debugPrint('ApiService: genuine network failure — $e');
      throw Exception('No internet connection. Check your network and try again.');
    } on TimeoutException catch (e) {
      debugPrint('ApiService: request timed out — $e');
      throw ServerErrorException('The server took too long to respond. Please try again.');
    } catch (e) {
      debugPrint('ApiService: unexpected error in _post — $e');
      throw ServerErrorException('Something went wrong on our end. Please try again.');
    }
  }

  // ─── TODAY — always sends client's local date+hour ───────────────────
  static Future<Map<String, dynamic>> getToday(String dob, {String? lang}) =>
      _post('/api/today', {
        'dob': dob,
        'client_date': clientDate,
        'client_hour': _clientHour,
        if (lang != null) 'lang': lang,
      });

  // ─── INSIGHTS — always send client date ──────────────────────────────
  static Future<Map<String, dynamic>> getWeeklyInsights(String dob, [String? lang]) =>
      _post('/api/insights/weekly', {
        'dob': dob,
        'client_date': clientDate,
        if (lang != null) 'lang': lang,
      });

  static Future<Map<String, dynamic>> getMonthlyInsights(String dob, [String? lang]) =>
      _post('/api/insights/monthly', {
        'dob': dob,
        'client_date': clientDate,
        if (lang != null) 'lang': lang,
      });

  static Future<Map<String, dynamic>> getYearlyInsights(String dob, [String? lang]) =>
      _post('/api/insights/yearly', {
        'dob': dob,
        'client_date': clientDate,
        if (lang != null) 'lang': lang,
      });

  // ─── TIMELINE (astrologer) — server is the single source of truth for
  //     maha/antar/monthly + the frequency grid, so the client never computes
  //     this itself and can't drift from the backend's math ─────────────────
  static Future<Map<String, dynamic>> getTimelineSummary(String dob) =>
      _post('/api/timeline-summary', {'dob': dob});

  static Future<List<dynamic>> getMahadashaTimeline(String dob,
      {int pastYears = 20, int futureYears = 50}) async {
    final r = await _post('/api/dashas', {
      'dob': dob, 'type': 'mahadasha',
      'pastYears': pastYears, 'futureYears': futureYears,
    });
    return r['timeline'] as List<dynamic>? ?? [];
  }

  static Future<List<dynamic>> getAntardashaTimeline(String dob,
      {int pastYears = 5, int futureYears = 10}) async {
    final r = await _post('/api/dashas', {
      'dob': dob, 'type': 'antardasha',
      'pastYears': pastYears, 'futureYears': futureYears,
    });
    return r['timeline'] as List<dynamic>? ?? [];
  }

  static Future<List<dynamic>> getMonthlyDashaTimeline(String dob,
      {int pastMonths = 3, int futureMonths = 12}) async {
    final r = await _post('/api/dashas', {
      'dob': dob, 'type': 'monthly',
      'pastMonths': pastMonths, 'futureMonths': futureMonths,
    });
    return r['timeline'] as List<dynamic>? ?? [];
  }

  /// The 3x3 frequency grid at a specific moment — maha/antar/monthly are
  /// derived server-side from [atDate], never computed on the client.
  static Future<Map<String, dynamic>> getTimelineGrid(String dob, DateTime atDate) =>
      _post('/api/timeline-grid', {
        'dob': dob,
        'at_date': atDate.toIso8601String(),
      });

  // ─── CHART ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getChart(String dob,
          [int? clientHour, String? lang]) =>
      _post('/api/chart', {
        'dob': dob,
        'client_date': clientDate,
        'client_hour': clientHour ?? _clientHour,
        if (lang != null) 'lang': lang,
      });

  static Future<Map<String, dynamic>> getChartForDate(
          String dob, String date, int? hour, [String? lang]) =>
      _post('/api/chart/date', {
        'dob': dob,
        'date': date,
        if (hour != null) 'hour': hour,
        if (lang != null) 'lang': lang,
      });

  // ─── STATIC — don't need date ────────────────────────────────────────
  static Future<Map<String, dynamic>> getLifeInsights(String dob) =>
      _post('/api/insights/life', {'dob': dob});

  static Future<Map<String, dynamic>> getDeepInsights(String dob, [String? lang]) =>
      _post('/api/insights/deep', {
        'dob': dob,
        if (lang != null) 'lang': lang,
      });

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

  static Future<Map<String, dynamic>> ask({
    required String dob,
    required List<Map<String, dynamic>> messages,
    String? clientDate,
  }) =>
      _authedPost('/api/ask', {
        'dob': dob,
        'messages': messages,
        'client_date': clientDate ?? ApiService.clientDate,
      });

  /// Current question-credit balance / subscription status, without
  /// spending a credit. Safe to call whenever, e.g. to show a badge.
  static Future<Map<String, dynamic>> getCredits() =>
      _authedPost('/api/user/credits', {});

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

  static Future<Map<String, dynamic>> getFutureRisks(String dob) =>
      _post('/api/predict/future-risks', {'dob': dob});

  static Future<Map<String, dynamic>> getYearInsight(String dob, int maha, int antar, int monthly) =>
      _post('/api/report/year-insight', {'dob': dob, 'maha_num': maha, 'antar_num': antar, 'monthly_num': monthly});

  static Future<Map<String, dynamic>> getYearlyInsight(String dob, String targetDate) =>
      _post('/api/insights/yearly', {'dob': dob, 'client_date': targetDate});

  static Future<Map<String, dynamic>> prashna(int number) =>
      _post('/api/predict/prashna', {'number': number});

  static Future<Map<String, dynamic>> getNumberMeaning(int number) =>
      _post('/api/predict/number', {'number': number});
}