import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aastrosphere/features/auth/repository/auth_repository.dart';
import 'package:aastrosphere/features/home/screens/home_screen.dart';
import 'package:aastrosphere/features/splash/screens/splash_screen.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state ko live watch karein
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      // Data (user state) aa gaya
      data: (user) {
        if (user != null) {
          // User logged in hai -> Seedha Home
          return const HomeScreen();
        } else {
          // User logged out hai -> Splash/Login flow
          return const SplashScreen();
        }
      },
      // Error aa gaya
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      // Check kar rahe hain...
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      ),
    );
  }
}