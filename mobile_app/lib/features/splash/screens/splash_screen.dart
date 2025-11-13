import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/screens/role_selection_screen.dart';
import 'package:mobile_app/main.dart';

// --- YEH HAIN ZAROORI (NECESSARY) CHANGES ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/features/home/screens/home_screen.dart';
// ------------------------------------------

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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    Timer(
      const Duration(milliseconds: 800),
      () => _animationController.forward(),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // --- YEH HAI UPDATED LOGIC (SESSION RETAIN) ---
        // Animation poora hua. Ab check karo user logged in hai ya nahi
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // User logged in hai -> Seedha Home
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (context, anim, a2, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
          );
        } else {
          // User logged out hai -> Role Selection
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const RoleSelectionScreen(),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (context, anim, a2, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
          );
        }
        // ------------------------------------------
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
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Container(color: kPrimaryColor),
          
          // ANIMATED DOOR PANELS - YEH AAPKA DIYA HUA CODE HAI
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // LEFT DOOR
                  Positioned(
                    left: -_animation.value * doorWidth,
                    child: Container(
                      width: doorWidth,
                      height: screenSize.height,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/wooden_door_texture.png',
                        width: doorWidth,
                        height: screenSize.height,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),

                  // RIGHT DOOR
                  Positioned(
                    right: -_animation.value * doorWidth,
                    child: Container(
                      width: doorWidth,
                      height: screenSize.height,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/wooden_door_texture.png',
                        width: doorWidth,
                        height: screenSize.height,
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