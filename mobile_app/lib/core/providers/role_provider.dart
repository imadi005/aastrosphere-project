import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRole { user, astrologer }

final roleProvider = StateNotifierProvider<RoleNotifier, AppRole>((ref) {
  return RoleNotifier();
});

class RoleNotifier extends StateNotifier<AppRole> {
  RoleNotifier() : super(AppRole.user) {
    _load();
  }

  static const _key = 'app_role';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_key) ?? 'user';
    state = val == 'astrologer' ? AppRole.astrologer : AppRole.user;
  }

  Future<void> setRole(AppRole role) async {
    final prefs = await SharedPreferences.getInstance();
    state = role;
    await prefs.setString(_key, role == AppRole.astrologer ? 'astrologer' : 'user');
  }

  void toggle() {
    setRole(state == AppRole.user ? AppRole.astrologer : AppRole.user);
  }
}
