import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/repository/auth_repository.dart';
import 'package:mobile_app/main.dart';

// --- NAYI FILES BANANI HAIN ---
// Inko hum abhi bas empty UI banayenge
import 'package:mobile_app/features/home/screens/user_dashboard.dart';
import 'package:mobile_app/features/home/screens/astrologer_dashboard.dart';
// -----------------------------

// Ek state provider jo track karega ki kaunsa role selected hai
final selectedRoleProvider = StateProvider<String>((ref) => 'User');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current selected role ko watch karo
    final String currentRole = ref.watch(selectedRoleProvider);
    // Dono roles ka data fetch karo
    final rolesData = ref.watch(userRolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AASTROSPHERE',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: rolesData.when(
        // Data aa gaya
        data: (roles) {
          final bool isUser = roles['User'] != null;
          final bool isAstrologer = roles['Astrologer'] != null;
          final bool hasDualRole = isUser && isAstrologer;

          // Agar user ke paas User role hi nahi hai, toh default 'Astrologer' select karo
          if (!isUser && isAstrologer) {
            // Post-build update taaki error na aaye
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedRoleProvider.notifier).state = 'Astrologer';
            });
          }

          return Column(
            children: [
              // --- YEH HAI AAPKA ROLE TOGGLE ---
              if (hasDualRole)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'User', label: Text('User'), icon: Icon(Icons.person)),
                      ButtonSegment(value: 'Astrologer', label: Text('Astrologer'), icon: Icon(Icons.auto_awesome)),
                    ],
                    selected: {currentRole},
                    onSelectionChanged: (newSelection) {
                      ref.read(selectedRoleProvider.notifier).state = newSelection.first;
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: kSurfaceColor,
                      foregroundColor: kSecondaryTextColor,
                      selectedBackgroundColor: kAccentColor,
                      selectedForegroundColor: kPrimaryColor,
                    ),
                  ),
                ),
              // --------------------------------

              // Body content ko switch karo
              Expanded(
                child: currentRole == 'User'
                    ? const UserDashboard() // User dashboard dikhao
                    : const AstrologerDashboard(), // Astrologer dashboard dikhao
              ),
            ],
          );
        },
        // Error aa gaya
        error: (err, stack) => Center(child: Text('Error: $err')),
        // Load ho raha hai
        loading: () => const Center(
          child: CircularProgressIndicator(color: kAccentColor),
        ),
      ),
    );
  }
}