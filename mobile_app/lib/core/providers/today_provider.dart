import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/auth/providers/user_provider.dart';

String _dobToIso(DateTime dob) => dob.toIso8601String();

// ─── All providers use .autoDispose so they re-fetch on next access ──────────
// This means when invalidated, they don't keep stale cache

final todayDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getToday(_dobToIso(user.dob));
});

final lifeInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getLifeInsights(_dobToIso(user.dob));
});

final weeklyInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getWeeklyInsights(_dobToIso(user.dob));
});

final monthlyInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getMonthlyInsights(_dobToIso(user.dob));
});

final yearlyInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getYearlyInsights(_dobToIso(user.dob));
});

final deepInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getDeepInsights(_dobToIso(user.dob));
});

final chartDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getChart(_dobToIso(user.dob), DateTime.now().hour);
});

final mahaTimelineProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final data = await ApiService.getDashas(_dobToIso(user.dob));
  return data['maha'] as List<dynamic>? ?? [];
});

final antarTimelineProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final data = await ApiService.getDashas(_dobToIso(user.dob));
  return data['antar'] as List<dynamic>? ?? [];
});
