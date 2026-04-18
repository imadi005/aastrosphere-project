import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aastrosphere/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aastrosphere/features/shell/app_shell.dart';
import 'package:aastrosphere/features/auth/screens/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _slide;
  late Animation<double> _doorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Phase 1: content fades in (0→0.45)
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    // Subtle upward drift
    _slide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    // Phase 2: doors open (0.62→1.0)
    _doorAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.62, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    Timer(const Duration(milliseconds: 300), () => _ctrl.forward());

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final user = FirebaseAuth.instance.currentUser;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, a1, a2) =>
                user != null ? const AppShell() : const RoleSelectionScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final doorW = size.width / 2;
    final gold = AppColors.gold;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [

          // ── Background — subtle radial glow ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.0,
                colors: [
                  AppColors.gold.withOpacity(0.06),
                  AppColors.bgLight,
                ],
              ),
            ),
          ),

          // ── Centre content — fades + slides in ───────────────────────────
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _fade.value,
              child: Transform.translate(
                offset: Offset(0, _slide.value),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // A monogram
                      Text('A',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: gold,
                            height: 1,
                          )),

                      const SizedBox(height: 10),

                      // App name
                      Text('Aastrosphere',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimaryLight,
                            letterSpacing: 1.5,
                          )),

                      const SizedBox(height: 20),

                      // Divider line
                      Container(
                        width: 40,
                        height: 0.5,
                        color: gold.withOpacity(0.4),
                      ),

                      const SizedBox(height: 18),

                      // Attribution
                      Text('by',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight.withOpacity(0.6),
                            letterSpacing: 1,
                          )),

                      const SizedBox(height: 6),

                      Text('Ank Jyotish',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            color: AppColors.textSecondaryLight,
                            letterSpacing: 0.8,
                            fontStyle: FontStyle.italic,
                          )),

                      const SizedBox(height: 3),

                      Text('Pankajj Kumar Mishra',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: gold.withOpacity(0.85),
                            letterSpacing: 0.6,
                          )),

                      const SizedBox(height: 4),

                      Text('Palmist',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.textSecondaryLight.withOpacity(0.5),
                            letterSpacing: 1.2,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Door animation ────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _doorAnim,
            builder: (_, __) {
              if (_doorAnim.value == 0) return const SizedBox.shrink();
              return Stack(
                children: [
                  Positioned(
                    left: -_doorAnim.value * doorW,
                    child: SizedBox(
                      width: doorW, height: size.height,
                      child: Image.asset(
                        'assets/images/wooden_door_texture.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -_doorAnim.value * doorW,
                    child: SizedBox(
                      width: doorW, height: size.height,
                      child: Image.asset(
                        'assets/images/wooden_door_texture.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
