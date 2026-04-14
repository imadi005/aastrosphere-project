import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/auth/providers/user_provider.dart';

String _dobToIso(DateTime dob) => dob.toIso8601String();

// Full prediction provider — main data source
final fullPredictionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getFullPrediction(_dobToIso(user.dob));
});

// Today screen data
final todayDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getToday(_dobToIso(user.dob));
});

// Dasha insight
final dashaInsightProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getDashaInsight(_dobToIso(user.dob));
});

// Yogas
final yogasProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getYogas(_dobToIso(user.dob));
});

// Chart data
final chartDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getChart(_dobToIso(user.dob));
});

// Finance
final financePredictionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getFinancePrediction(_dobToIso(user.dob));
});

// Health
final healthPredictionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getHealthPrediction(_dobToIso(user.dob));
});

// Relationship
final relationshipPredictionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getRelationshipPrediction(_dobToIso(user.dob));
});

// Mahadasha timeline
final mahaTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final result = await ApiService.getDashas(_dobToIso(user.dob), type: 'mahadasha');
  return result['timeline'] as List<dynamic>;
});

// Antardasha timeline
final antarTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final result = await ApiService.getDashas(_dobToIso(user.dob), type: 'antardasha');
  return result['timeline'] as List<dynamic>;
});
