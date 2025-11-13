import 'package:flutter/material.dart';

class SpinningWheel extends StatefulWidget {
  const SpinningWheel({super.key});

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // Dheere spin ke liye
      vsync: this,
    )..repeat(); // Hamesha repeat hoga
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/images/zodiac_circle_gold.png',
        color: Colors.white.withOpacity(0.3), // Thoda transparent
        colorBlendMode: BlendMode.modulate,
      ),
    );
  }
}