import 'dart:async';
import 'package:flutter/material.dart';
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
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
    Timer(const Duration(milliseconds: 800), () => _animationController.forward());
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final user = FirebaseAuth.instance.currentUser;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) =>
                user != null ? const AppShell() : const RoleSelectionScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final doorWidth = screenSize.width / 2;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          Container(color: AppColors.bgLight),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: -_animation.value * doorWidth,
                    child: SizedBox(
                      width: doorWidth,
                      height: screenSize.height,
                      child: Image.asset(
                        'assets/images/wooden_door_texture.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -_animation.value * doorWidth,
                    child: SizedBox(
                      width: doorWidth,
                      height: screenSize.height,
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
