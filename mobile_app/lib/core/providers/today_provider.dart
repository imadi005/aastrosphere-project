import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/auth/providers/user_provider.dart';

// Helper function to format DOB
String _dobToIso(DateTime dob) => dob.toIso8601String();

// ─── SMART PREDICTION PROVIDERS (NEW ENGINE) ───────────────────────────

/// Today's Smart Prediction: includes quote, rating, insight, do/avoid, yogas
final todayDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  
  // Hit updated /api/today endpoint
  return ApiService.getToday(_dobToIso(user.dob));
});

/// Permanent Life Predictions: core nature, money/love patterns, work style
final lifeInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  
  return ApiService.getLifeInsights(_dobToIso(user.dob));
});

/// Weekly Outlook: Finance signal, relationship depth, watch-outs
final weeklyInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  
  return ApiService.getWeeklyInsights(_dobToIso(user.dob));
});

/// Monthly Outlook: Career drive + Energy levels
final monthlyInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  
  return ApiService.getMonthlyInsights(_dobToIso(user.dob));
});

/// Yearly Outlook: The big picture context
final yearlyInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  
  return ApiService.getYearlyInsights(_dobToIso(user.dob));
});

// ─── CORE CHART & DASHA PROVIDERS (RETAINED) ──────────────────────────

final chartDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getChart(_dobToIso(user.dob));
});

final mahaTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final result = await ApiService.getDashas(_dobToIso(user.dob), type: 'mahadasha');
  return result['timeline'] as List<dynamic>;
});

final antarTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final result = await ApiService.getDashas(_dobToIso(user.dob), type: 'antardasha');
  return result['timeline'] as List<dynamic>;
});

/// Deep profile: core nature, patterns, chapter, warnings, natal combinations
final deepInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getDeepInsights(_dobToIso(user.dob));
});

// ─── LEGACY SUPPORT (OPTIONAL) ─────────────────────────────────────────

// If your UI still uses specific feature providers, we keep them pointing to the new engine's logic
final yogasProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  // New engine provides yogas within the today/life endpoints, 
  // but if you have a separate screen:
  return ApiService.getYogas(_dobToIso(user.dob));
});