import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/role_selection_screen.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => const Center(child: Text('Error loading profile')),
      data: (user) {
        if (user == null) return const _NoProfile();

        final basic = NumerologyEngine.basicNumber(user.dob.day);
        final destiny = NumerologyEngine.destinyNumber(user.dob);
        final supportive = NumerologyEngine.supportiveNumbers(user.dob.day);
        final maha = NumerologyEngine.currentMahadasha(user.dob);
        final antar = NumerologyEngine.currentAntardasha(user.dob);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + name
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: gold.withOpacity(0.3), width: 0.8),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24, color: gold, fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 20, color: textPrimary)),
                        Text(
                          DateFormat('d MMMM yyyy').format(user.dob),
                          style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Core numbers
              SectionLabel('Your numbers'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _NumberCard(
                    label: 'Basic', number: basic,
                    planet: NumerologyEngine.planetNames[basic] ?? '',
                    color: gold, isDark: isDark,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NumberCard(
                    label: 'Destiny', number: destiny,
                    planet: NumerologyEngine.planetNames[destiny] ?? '',
                    color: gold, isDark: isDark,
                  )),
                  if (supportive.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(child: _SupportiveCard(
                      numbers: supportive, gold: gold, isDark: isDark,
                    )),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Current periods
              SectionLabel('Current periods'),
              const SizedBox(height: 8),
              AstroCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Mahadasha', '${maha.number} · ${maha.planet}',
                        '${DateFormat('yyyy').format(maha.start)}–${DateFormat('yyyy').format(maha.end)}',
                        gold, textSecondary, textPrimary, border),
                    Divider(color: border, thickness: 0.5, height: 20),
                    _InfoRow('Antardasha', '${antar.number} · ${antar.planet}',
                        '${DateFormat('MMM yy').format(antar.start)}–${DateFormat('MMM yy').format(antar.end)}',
                        isDark ? AppColors.successDark : AppColors.success,
                        textSecondary, textPrimary, border),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile info
              SectionLabel('Account'),
              const SizedBox(height: 8),
              AstroCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Phone', user.phone, '',
                        textSecondary, textSecondary, textPrimary, border),
                    Divider(color: border, thickness: 0.5, height: 20),
                    _InfoRow('Role', user.isAstrologer ? 'Astrologer' : 'User', '',
                        textSecondary, textSecondary, textPrimary, border),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign out
              GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 0.5),
                    color: subtleBg,
                  ),
                  child: Center(
                    child: Text('Sign out',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: textSecondary)),
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

class _NumberCard extends StatelessWidget {
  final String label, planet;
  final int number;
  final Color color;
  final bool isDark;

  const _NumberCard({
    required this.label, required this.number,
    required this.planet, required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: subtleBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary)),
          const SizedBox(height: 6),
          Text(number.toString(),
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 32, fontWeight: FontWeight.w300, color: color)),
          Text(planet,
              style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }
}

class _SupportiveCard extends StatelessWidget {
  final List<int> numbers;
  final Color gold;
  final bool isDark;

  const _SupportiveCard({required this.numbers, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: subtleBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supportive',
              style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: numbers.map((n) => Text(
              n.toString(),
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 32, fontWeight: FontWeight.w300, color: gold),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value, trailing;
  final Color labelColor, valueColor, primaryColor, borderColor;

  const _InfoRow(this.label, this.value, this.trailing,
      this.labelColor, this.valueColor, this.primaryColor, this.borderColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(fontSize: 11, color: labelColor)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
            ],
          ),
        ),
        if (trailing.isNotEmpty)
          Text(trailing,
              style: GoogleFonts.dmSans(fontSize: 11, color: valueColor)),
      ],
    );
  }
}

class _NoProfile extends StatelessWidget {
  const _NoProfile();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    return Center(
      child: Text('No profile found',
          style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
    );
  }
}
