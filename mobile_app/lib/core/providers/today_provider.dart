import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/auth/providers/user_provider.dart';

// Formats DateTime to ISO string for API
String _dobToIso(DateTime dob) => dob.toIso8601String();

// Today data provider — fetches from backend
final todayDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getToday(_dobToIso(user.dob));
});

// Chart data provider
final chartDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  return ApiService.getChart(_dobToIso(user.dob));
});

// Mahadasha timeline provider
final mahaTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final result = await ApiService.getDashas(_dobToIso(user.dob), type: 'mahadasha');
  return result['timeline'] as List<dynamic>;
});

// Antardasha timeline provider
final antarTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user == null) throw Exception('No user profile');
  final result = await ApiService.getDashas(_dobToIso(user.dob), type: 'antardasha');
  return result['timeline'] as List<dynamic>;
});
