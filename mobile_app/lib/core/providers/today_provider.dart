import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../providers/role_provider.dart';
import '../providers/locale_provider.dart';
import '../../features/auth/providers/user_provider.dart';

String _dobToIso(DateTime dob) => dob.toIso8601String();

// ─── Smart profile provider ───────────────────────────────────────────────────
// For USER role: reads from users collection only
// For ASTROLOGER role: reads users collection first, falls back to astrologers
// This means user screens are NEVER touched by astrologer logic
final smartProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final role = ref.watch(roleProvider);
  if (role == AppRole.astrologer) {
    // Astrologer Me mode — try users first, then astrologers collection
    final astroProfile = await ref.watch(astrologerProfileProvider.future);
    return astroProfile;
  }
  // Regular user — always use userProfileProvider
  return ref.watch(userProfileProvider.future);
});

// ─── All data providers use smartProfileProvider ──────────────────────────────

final todayDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final iso = _dobToIso(user.dob);
  // Persist dob so the background notification worker can fetch fresh data
  SharedPreferences.getInstance().then((p) => p.setString('notif_dob', iso));
  final lang = ref.watch(localeProvider).languageCode;
  return ApiService.getToday(iso, lang: lang);
});

final lifeInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getLifeInsights(_dobToIso(user.dob));
});

final weeklyInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getWeeklyInsights(_dobToIso(user.dob));
});

final monthlyInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getMonthlyInsights(_dobToIso(user.dob));
});

final yearlyInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getYearlyInsights(_dobToIso(user.dob));
});

final deepInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getDeepInsights(_dobToIso(user.dob));
});

final chartDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final lang = ref.watch(localeProvider).languageCode;
  return ApiService.getChart(_dobToIso(user.dob), DateTime.now().hour, lang);
});

final mahaTimelineProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final data = await ApiService.getDashas(_dobToIso(user.dob));
  return data['maha'] as List<dynamic>? ?? [];
});

final antarTimelineProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = await ref.watch(smartProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final data = await ApiService.getDashas(_dobToIso(user.dob));
  return data['antar'] as List<dynamic>? ?? [];
});
