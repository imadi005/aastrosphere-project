import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/shell/app_shell.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'firebase_options.dart';
import 'core/services/midnight_refresh.dart';
import 'core/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final container = ProviderContainer();
  MidnightRefreshService.init(container);
  await NotificationService.init();
  runApp(ProviderScope(parent: container, child: const AastrosphereApp()));
}

class AastrosphereApp extends ConsumerWidget {
  const AastrosphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Aastrosphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    return authState.when(
      loading: () => const SplashScreen(),
      error: (_, __) => const RoleSelectionScreen(),
      data: (user) {
        if (user != null) {
          // Identify + track app open — wires all events to this Firebase user
          AnalyticsService.appOpened();
          // isAstrologer resolved by role provider — use uid for now, role set on login
          AnalyticsService.identify(user.uid, isAstrologer: false);
        }
        return user == null ? const RoleSelectionScreen() : const AppShell();
      },
    );
  }
}
