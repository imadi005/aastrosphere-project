import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the DOB currently being analyzed in the astrologer shell
final astroClientDobProvider = StateProvider<DateTime?>((ref) => null);

/// true = show client DOB, false = show astrologer's own DOB
final astroUseClientDobProvider = StateProvider<bool>((ref) => true);

/// Client name for saving reports
final astroClientNameProvider = StateProvider<String>((ref) => '');
