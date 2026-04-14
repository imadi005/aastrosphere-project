import 'package:flutter/material.dart';
import 'package:aastrosphere/features/shell/app_shell.dart';

// Legacy redirect - points to new AppShell
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}
