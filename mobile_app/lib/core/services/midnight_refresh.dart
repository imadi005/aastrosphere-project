import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/today_provider.dart';

/// Handles automatic refresh of all daily-sensitive providers at midnight
/// and when app resumes after being backgrounded.
class MidnightRefreshService {
  static Timer? _midnightTimer;
  static ProviderContainer? _container;
  static String? _lastRefreshDate;

  static void init(ProviderContainer container) {
    _container = container;
    _lastRefreshDate = _todayStr();
    _scheduleMidnightTimer();
  }

  static void dispose() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
  }

  /// Call this when app resumes from background.
  /// If date has changed, immediately invalidates all providers.
  static void checkDateOnResume() {
    final today = _todayStr();
    if (_lastRefreshDate != today) {
      _lastRefreshDate = today;
      _invalidateAll();
      _scheduleMidnightTimer(); // reset timer for next midnight
    }
  }

  static void _scheduleMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    // Fire 5 seconds after midnight to ensure date has flipped
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 5);
    final duration = nextMidnight.difference(now);

    _midnightTimer = Timer(duration, () {
      _lastRefreshDate = _todayStr();
      _invalidateAll();
      _scheduleMidnightTimer(); // schedule next midnight
    });
  }

  static void _invalidateAll() {
    final c = _container;
    if (c == null) return;
    try {
      c.invalidate(todayDataProvider);
      c.invalidate(weeklyInsightsProvider);
      c.invalidate(monthlyInsightsProvider);
      c.invalidate(yearlyInsightsProvider);
      c.invalidate(chartDataProvider);
    } catch (_) {
      // Providers may not be active — ignore
    }
  }

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
