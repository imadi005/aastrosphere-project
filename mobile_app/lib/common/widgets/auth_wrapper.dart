import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/repository/auth_repository.dart';
import 'package:mobile_app/features/home/screens/home_screen.dart';
import 'package:mobile_app/features/splash/screens/splash_screen.dart';
import 'package:mobile_app/main.dart'; // For loading color

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
        backgroundColor: kPrimaryColor,
        body: Center(
          child: CircularProgressIndicator(color: kAccentColor),
        ),
      ),
    );
  }
}