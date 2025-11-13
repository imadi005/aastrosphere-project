import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/main.dart'; // For theme colors
import 'package:mobile_app/features/auth/screens/login_screen.dart'; // <-- YEH NAYA IMPORT HAI

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- YEH NAYA NAVIGATION FUNCTION HAI ---
    void navigateToLogin(String role) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(role: role),
        ),
      );
    }
    // ------------------------------------

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      
                      // --- Logo & Title ---
                      FadeInDown(
                        duration: const Duration(milliseconds: 900),
                        child: Text(
                          'AASTROSPHERE',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInDown(
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          'SELECT YOUR ROLE',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: kSecondaryTextColor,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // --- User Card ---
                      FadeInUp(
                        duration: const Duration(milliseconds: 1100),
                        child: _RoleCard(
                          icon: Icons.person_outline,
                          title: 'USER',
                          subtitle: 'Get personalized daily insights & predictions',
                          onTap: () => navigateToLogin('User'), // <-- YEH UPDATE HUA HAI
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Astrologer Card ---
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: _RoleCard(
                          icon: Icons.auto_awesome_outlined,
                          title: 'ASTROLOGER',
                          subtitle: 'Join our panel & guide users',
                          onTap: () => navigateToLogin('Astrologer'), // <-- YEH UPDATE HUA HAI
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----- Reusable Card Widget -----
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // <-- Pehle 'onTap' null tha

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // <-- onTap yahaan connect hua
      borderRadius: BorderRadius.circular(16),
      splashColor: kAccentColor.withOpacity(0.1),
      highlightColor: kAccentColor.withOpacity(0.1),
      child: Ink(
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kAccentColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: kAccentColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, color: kAccentColor, size: 40),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}