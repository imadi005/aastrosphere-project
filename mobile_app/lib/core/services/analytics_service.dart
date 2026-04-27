import 'package:firebase_analytics/firebase_analytics.dart';

// ─── Aastrosphere Analytics Service ─────────────────────────────────────────
// All tracking goes through here. One place to manage everything.
// Firebase Console: Analytics > Events / Dashboard / User Explorer
class AnalyticsService {
  static final _a = FirebaseAnalytics.instance;

  // ── User Identity ──────────────────────────────────────────────────────────
  // Call on login/signup
  static Future<void> identify(String uid, {required bool isAstrologer}) async {
    await _a.setUserId(id: uid);
    await _a.setUserProperty(
        name: 'user_type', value: isAstrologer ? 'astrologer' : 'user');
  }

  // Call on logout
  static Future<void> reset() async {
    await _a.setUserId(id: null);
  }

  // ── Session / App Open ─────────────────────────────────────────────────────
  static Future<void> appOpened() =>
      _a.logAppOpen();

  // ── Screen Tracking ────────────────────────────────────────────────────────
  static Future<void> screen(String name) =>
      _a.logScreenView(screenName: name);

  // ── Auth Events ────────────────────────────────────────────────────────────
  static Future<void> signUp(String method) =>
      _a.logSignUp(signUpMethod: method);

  static Future<void> login(String method) =>
      _a.logLogin(loginMethod: method);

  // ── Core Feature: Today Screen ─────────────────────────────────────────────
  static Future<void> todayViewed() =>
      _track('today_viewed');

  // ── Core Feature: Chart ────────────────────────────────────────────────────
  static Future<void> chartViewed({bool isCustomDate = false}) =>
      _track('chart_viewed', {'custom_date': isCustomDate});

  static Future<void> chartDateChanged() =>
      _track('chart_date_changed');

  // ── Core Feature: Insights ─────────────────────────────────────────────────
  static Future<void> insightsViewed(String tab) =>
      _track('insights_viewed', {'tab': tab});

  // ── Core Feature: Ask ─────────────────────────────────────────────────────
  static Future<void> questionAsked(String questionType) =>
      _track('ask_question', {'question_type': questionType});

  // ── Astrologer: Client Management ─────────────────────────────────────────
  static Future<void> clientDobEntered() =>
      _track('client_dob_entered');

  static Future<void> meModeToggled(bool isMeMode) =>
      _track('me_mode_toggled', {'mode': isMeMode ? 'me' : 'client'});

  // ── Astrologer: Pattern Screen ─────────────────────────────────────────────
  static Future<void> patternTabViewed(String tab) =>
      _track('pattern_tab_viewed', {'tab': tab});

  static Future<void> riskTabViewed() =>
      _track('risk_tab_viewed');

  static Future<void> riskYearExpanded(int year) =>
      _track('risk_year_expanded', {'year': year});

  // ── Astrologer: Timeline ──────────────────────────────────────────────────
  static Future<void> timelineViewed(String tab) =>
      _track('timeline_viewed', {'tab': tab});

  // ── Astrologer: Reports ────────────────────────────────────────────────────
  static Future<void> reportGenerated(int years) =>
      _track('report_generated', {'years': years});

  static Future<void> pdfExported(int years) =>
      _track('pdf_exported', {'years': years});

  static Future<void> reportHistoryViewed() =>
      _track('report_history_viewed');

  static Future<void> remedyEdited(int year) =>
      _track('remedy_edited', {'year': year});

  // ── Private helper ─────────────────────────────────────────────────────────
  static Future<void> _track(String name,
      [Map<String, Object>? params]) async {
    try {
      await _a.logEvent(name: name, parameters: params);
    } catch (_) {
      // Never crash the app over analytics
    }
  }
}
