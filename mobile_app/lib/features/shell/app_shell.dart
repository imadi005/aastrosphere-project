import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/role_provider.dart';
import '../../core/services/midnight_refresh.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../auth/providers/user_provider.dart';

// User screens
import '../user/today/today_screen.dart';
import '../user/insights/insights_screen.dart';
import '../user/circle/circle_screen.dart';
import '../user/chart/chart_screen.dart';
import '../user/me/me_screen.dart';

// Astrologer screens
import '../astrologer/chart/astro_chart_screen.dart';
import '../astrologer/timeline/timeline_screen.dart';
import '../astrologer/daily/daily_screen.dart';
import '../astrologer/more/more_screen.dart';

final _userIndexProvider = StateProvider<int>((ref) => 0);
final _astroIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    final isAstrologer = role == AppRole.astrologer;

    return isAstrologer
        ? const _AstrologerShell()
        : const _UserShell();
  }
}

// ─── User Shell ───────────────────────────────────────────────────────────────
class _UserShell extends ConsumerStatefulWidget {
  const _UserShell();

  @override
  ConsumerState<_UserShell> createState() => _UserShellState();
}

class _UserShellState extends ConsumerState<_UserShell> with WidgetsBindingObserver {
  static const _screens = [
    TodayScreen(),
    InsightsScreen(),
    CircleScreen(),
    ChartScreen(),
    MeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MidnightRefreshService.checkDateOnResume();
    }
  }

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), activeIcon: Icon(Icons.wb_sunny), label: 'Today'),
    BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'Insights'),
    BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Circle'),
    BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Chart'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(_userIndexProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final role = ref.watch(roleProvider);

    return Scaffold(
      appBar: _AppBar(
        isAstrologer: false,
        isDark: isDark,
        onThemeToggle: () => ref.read(themeProvider.notifier).toggle(),
        onRoleToggle: () => ref.read(roleProvider.notifier).toggle(),
      ),
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttributionFooter(isDark: isDark),
          _BottomNav(
            currentIndex: index,
            items: _items,
            onTap: (i) => ref.read(_userIndexProvider.notifier).state = i,
          ),
        ],
      ),
    );
  }
}

// ─── Astrologer Shell ─────────────────────────────────────────────────────────
class _AstrologerShell extends ConsumerWidget {
  const _AstrologerShell();

  static const _screens = [
    AstroChartScreen(),
    TimelineScreen(),
    AstroDailyScreen(),
    MoreScreen(),
  ];

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Chart'),
    BottomNavigationBarItem(icon: Icon(Icons.timeline_outlined), activeIcon: Icon(Icons.timeline), label: 'Timeline'),
    BottomNavigationBarItem(icon: Icon(Icons.today_outlined), activeIcon: Icon(Icons.today), label: 'Daily'),
    BottomNavigationBarItem(icon: Icon(Icons.apps_outlined), activeIcon: Icon(Icons.apps), label: 'More'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_astroIndexProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: _AppBar(
        isAstrologer: true,
        isDark: isDark,
        onThemeToggle: () => ref.read(themeProvider.notifier).toggle(),
        onRoleToggle: () => ref.read(roleProvider.notifier).toggle(),
      ),
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttributionFooter(isDark: isDark),
          _BottomNav(
            currentIndex: index,
            items: _items,
            onTap: (i) => ref.read(_astroIndexProvider.notifier).state = i,
          ),
        ],
      ),
    );
  }
}

// ─── Shared App Bar ───────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAstrologer;
  final bool isDark;
  final VoidCallback onThemeToggle;
  final VoidCallback onRoleToggle;

  const _AppBar({
    required this.isAstrologer,
    required this.isDark,
    required this.onThemeToggle,
    required this.onRoleToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    return AppBar(
      toolbarHeight: 52,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Text(
            'A',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24, fontWeight: FontWeight.w400, color: gold,
            ),
          ),
        ),
      ),
      title: Text(
        'Aastrosphere',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 17, fontWeight: FontWeight.w400, color: gold,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        // Only show toggle if user has astrologer access
        Consumer(builder: (context, ref, _) {
          final userAsync = ref.watch(userProfileProvider);
          final showToggle = userAsync.maybeWhen(
            data: (u) => u?.isAstrologer ?? false,
            orElse: () => false,
          );
          if (!showToggle) return const SizedBox.shrink();
          return RoleToggle(isAstrologer: isAstrologer, onToggle: onRoleToggle);
        }),
        const SizedBox(width: 8),
        ThemeToggleButton(isDark: isDark, onToggle: onThemeToggle),
        const SizedBox(width: 16),
      ],
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        iconSize: 20,
      ),
    );
  }
}

// ─── Attribution Footer ───────────────────────────────────────────────────────
class _AttributionFooter extends StatelessWidget {
  final bool isDark;
  const _AttributionFooter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? Colors.white.withOpacity(0.75)
        : Colors.black.withOpacity(0.70);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        'Aastrosphere  ·  Ank Jyotish & Palmist Pankajj Kumar Mishra',
        textAlign: TextAlign.center,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 10,
          color: color,
          letterSpacing: 0.4,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
