import 'dart:async';

import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:aastrosphere/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _entranceGateController;
  late final AnimationController _introController;
  late final AnimationController _welcomeController;
  Timer? _introTimer;
  int _page = 0;
  bool _showEntranceGate = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _entranceGateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    );
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    Timer(const Duration(milliseconds: 240), () {
      if (mounted) _entranceGateController.forward();
    });
    Timer(const Duration(milliseconds: 1020), () {
      if (mounted) _introController.forward();
    });
    _entranceGateController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showEntranceGate = false);
      }
    });

    _introTimer = Timer(const Duration(milliseconds: 4400), () {
      if (!mounted) return;
      _goToPage(1);
    });
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _pageController.dispose();
    _entranceGateController.dispose();
    _introController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    if (page == 1) _welcomeController.forward(from: 0);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _navigateToLogin(String role) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginScreen(role: role),
        transitionDuration: const Duration(milliseconds: 520),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _SoftBackdrop(isDark: isDark),
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _IntroPage(animation: _introController),
                _WelcomePage(
                  animation: _welcomeController,
                  onDiveIn: () => _goToPage(2),
                ),
                _ChoicePage(onRoleSelected: _navigateToLogin),
              ],
            ),
          ),
          if (_showEntranceGate)
            _WoodenGateOverlay(
              animation: _entranceGateController,
              showGlow: true,
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22 + MediaQuery.of(context).padding.bottom,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 420),
              opacity: _showEntranceGate ? 0 : 1,
              child: _ProgressDots(active: _page),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final Animation<double> animation;

  const _IntroPage({required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final title = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
    );
    final subtitle = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.42, 1, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: title.value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - title.value)),
                  child: Transform.scale(
                    scale: 0.92 + (0.08 * title.value),
                    child: Text(
                      'Aastrosphere',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 54,
                        height: 1,
                        fontWeight: FontWeight.w400,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: subtitle.value,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - subtitle.value)),
                  child: Column(
                    children: [
                      Container(
                        width: 52 + (18 * subtitle.value),
                        height: 1,
                        color: gold.withOpacity(0.45),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Guidance through the Power of Numbers',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          height: 1.45,
                          color: secondary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onDiveIn;

  const _WelcomePage({
    required this.animation,
    required this.onDiveIn,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final title = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );
    final body = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.25, 0.8, curve: Curves.easeOutCubic),
    );
    final action = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.55, 1, curve: Curves.easeOutCubic),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: _WelcomeNumberMist(animation: animation, isDark: isDark),
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: title.value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - title.value)),
                      child: Text(
                        'Welcome to the world of numbers',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 35,
                          height: 1.08,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: body.value,
                    child: Transform.scale(
                      scale: 0.98 + (0.02 * body.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: card.withOpacity(isDark ? 0.76 : 0.88),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: border, width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withOpacity(isDark ? 0.08 : 0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Text(
                          'Discover how your date of birth reveals the patterns of your past and the possibilities ahead.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            height: 1.7,
                            color: secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Opacity(
                    opacity: action.value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - action.value)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onDiveIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor:
                                isDark ? AppColors.bgDark : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Let's Dive In",
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.bgDark : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WelcomeNumberMist extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _WelcomeNumberMist({
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final reveal = Curves.easeOutCubic.transform(animation.value);
        return Stack(
          children: [
            Positioned(
              left: -16,
              right: -16,
              bottom: 86,
              child: Opacity(
                opacity: 0.28 * reveal,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - reveal)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(9, (index) {
                      final number = index + 1;
                      final active = number == 1 || number == 5 || number == 9;
                      return Text(
                        '$number',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: active ? 24 : 18,
                          color: active
                              ? gold.withOpacity(0.16)
                              : secondary.withOpacity(0.08),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChoicePage extends StatelessWidget {
  final ValueChanged<String> onRoleSelected;

  const _ChoicePage({required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Are you a',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 38,
              height: 1,
              color: primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choose your path',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: secondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 42),
          _RoleCard(
            icon: Icons.person_outline,
            title: 'User',
            subtitle: 'Daily guidance, personal chart and reminders',
            gold: gold,
            isDark: isDark,
            onTap: () => onRoleSelected('User'),
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.auto_awesome_outlined,
            title: 'Astrologer',
            subtitle: 'Read charts, timelines and client reports',
            gold: gold,
            isDark: isDark,
            onTap: () => onRoleSelected('Astrologer'),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color gold;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gold,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg.withOpacity(isDark ? 0.72 : 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold.withOpacity(0.24), width: 0.5),
                ),
                child: Icon(icon, color: gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        height: 1.35,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: secondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _WoodenGateOverlay extends StatelessWidget {
  final Animation<double> animation;
  final bool showGlow;

  const _WoodenGateOverlay({
    required this.animation,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final doorWidth = size.width / 2;
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final opening = curved.value;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                    color: Colors.black.withOpacity(0.12 * (1 - opening))),
              ),
              Positioned(
                left: -doorWidth * opening,
                top: 0,
                bottom: 0,
                width: doorWidth,
                child: Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-0.28 * opening),
                  child: Image.asset(
                    'assets/images/wooden_door_texture.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              Positioned(
                right: -doorWidth * opening,
                top: 0,
                bottom: 0,
                width: doorWidth,
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(0.28 * opening),
                  child: Image.asset(
                    'assets/images/wooden_door_texture.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
              Positioned(
                left: size.width / 2 - 0.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: showGlow ? 2 + (12 * opening) : 1,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity((1 - opening) * 0.48),
                    boxShadow: showGlow
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.34 * opening),
                              blurRadius: 34,
                              spreadRadius: 7,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoftBackdrop extends StatelessWidget {
  final bool isDark;

  const _SoftBackdrop({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gold.withOpacity(isDark ? 0.08 : 0.05),
            bg,
            bg,
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int active;

  const _ProgressDots({required this.active});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final muted = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? gold : muted,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
