import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // For animations
import 'package:mobile_app/main.dart'; // To access our theme colors

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Logo/Title
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'AASTROSPHERE',
                  style: textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Select Your Role',
                  style: textTheme.titleLarge?.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 2. User Role Card
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: _RoleCard(
                  icon: Icons.person_outline,
                  title: 'User',
                  description: 'Get personalized daily insights & predictions',
                  onTap: () {
                    // Yahaan hum "User" ko select karke Phone Login page pe jaayenge
                    print('User role selected');
                    // Navigator.push(...); // Next step
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 3. Astrologer Role Card
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                child: _RoleCard(
                  icon: Icons.auto_awesome_outlined, // Star icon
                  title: 'Astrologer',
                  description: 'Join our panel & guide users',
                  onTap: () {
                    // Yahaan hum "Astrologer" ko select karke Phone Login page pe jaayenge
                    print('Astrologer role selected');
                    // Navigator.push(...); // Next step
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----- Internal Widget for the Role Card -----
// Humne isko alag se banaya hai taaki code clean rahe
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSurfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: kAccentColor.withOpacity(0.1), // Gold ripple
        highlightColor: kAccentColor.withOpacity(0.1), // Gold highlight
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAccentColor.withOpacity(0.3)), // Gold border
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: kAccentColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kSecondaryTextColor, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}