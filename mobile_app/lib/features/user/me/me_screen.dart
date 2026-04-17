import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../auth/providers/user_provider.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final userAsync = ref.watch(userProfileProvider);
    final deepAsync = ref.watch(deepInsightsProvider);

    return userAsync.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => const Center(child: Text('Error')),
      data: (user) {
        if (user == null) return const Center(child: Text('No profile'));
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: deepAsync.when(
            loading: () => Column(children: [
              _ProfileHeader(user: user, isDark: isDark, gold: gold),
              const SizedBox(height: 40),
              CircularProgressIndicator(strokeWidth: 1.5, color: gold),
            ]),
            error: (_, __) => Column(children: [
              _ProfileHeader(user: user, isDark: isDark, gold: gold),
              const SizedBox(height: 24),
              Text('Could not load profile', style: GoogleFonts.dmSans(
                  fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ]),
            data: (deep) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(user: user, isDark: isDark, gold: gold),
                const SizedBox(height: 24),
                _MeContent(data: deep, isDark: isDark, gold: gold),
                const SizedBox(height: 32),
                _SignOutButton(isDark: isDark),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MeContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  const _MeContent({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;

    final coreNature = data['core_nature'] as Map<String, dynamic>?;
    final lifeDir = data['life_direction'] as Map<String, dynamic>?;
    final coreCombination = data['core_combination'] as Map<String, dynamic>?;
    final patterns = data['personal_patterns'] as Map<String, dynamic>?;
    final chapter = data['current_chapter'] as Map<String, dynamic>?;
    final yogas = (data['active_yogas'] as List? ?? []);
    final warnings = (data['warnings'] as List? ?? []);
    final natalCombos = (data['natal_combinations'] as List? ?? []);

    // Separate structural yogas
    final structuralYogas = yogas.where((y) => y['combo_key'] == null && y['positive'] == true).toList();
    final cautionYogas = yogas.where((y) => y['combo_key'] == null && y['positive'] == false).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Who You Are ─────────────────────────────────────────
        if (coreNature != null) ...[
          SectionLabel('Who You Are'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coreNature['pattern'] as String? ?? '',
                    style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.6)),
                if (coreNature['internal_conflict'] != null) ...[
                  const SizedBox(height: 12),
                  Divider(color: border, height: 1, thickness: 0.5),
                  const SizedBox(height: 10),
                  _LabeledText('The tension inside you',
                      coreNature['internal_conflict'] as String, secondary, gold),
                ],
                if (coreNature['shadow'] != null) ...[
                  const SizedBox(height: 8),
                  _LabeledText('Your shadow',
                      coreNature['shadow'] as String, secondary, dangerColor),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Your Life Patterns ───────────────────────────────────
        if (patterns != null) ...[
          SectionLabel('Your Patterns'),
          const SizedBox(height: 8),
          _PatternCard(icon: Icons.account_balance_wallet_outlined,
              label: 'Money', text: patterns['money'] as String? ?? '',
              color: const Color(0xFFF59E0B), isDark: isDark),
          _PatternCard(icon: Icons.favorite_border,
              label: 'Love', text: patterns['love'] as String? ?? '',
              color: Colors.pinkAccent, isDark: isDark),
          _PatternCard(icon: Icons.work_outline,
              label: 'Work', text: patterns['work'] as String? ?? '',
              color: Colors.blueAccent, isDark: isDark),
          if (patterns['recurring_lesson'] != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withOpacity(0.2), width: 0.5),
              ),
              child: Row(children: [
                Icon(Icons.lightbulb_outline, size: 14, color: gold),
                const SizedBox(width: 10),
                Expanded(child: Text(patterns['recurring_lesson'] as String,
                    style: GoogleFonts.dmSans(fontSize: 12, color: secondary,
                        height: 1.5, fontStyle: FontStyle.italic))),
              ]),
            ),
          ],
          const SizedBox(height: 16),
        ],

        // ── Current Chapter ──────────────────────────────────────
        if (chapter != null) ...[
          SectionLabel('Current Chapter'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chapter['title'] as String? ?? '',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, fontWeight: FontWeight.w600, color: gold)),
                const SizedBox(height: 8),
                Text(chapter['what_it_feels_like'] as String? ?? '',
                    style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.6)),
                if (chapter['the_gift'] != null) ...[
                  const SizedBox(height: 10),
                  Divider(color: border, height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  _LabeledText('The gift', chapter['the_gift'] as String, secondary, successColor),
                ],
                if (chapter['the_trap'] != null) ...[
                  const SizedBox(height: 6),
                  _LabeledText('The trap', chapter['the_trap'] as String, secondary, dangerColor),
                ],
                if (chapter['advice'] != null) ...[
                  const SizedBox(height: 6),
                  _LabeledText('Advice', chapter['advice'] as String, secondary, gold),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Health ───────────────────────────────────────────────
        if (lifeDir?['health_real'] != null) ...[
          SectionLabel('Health'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.monitor_heart_outlined, size: 16, color: Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: Text(lifeDir!['health_real'] as String,
                    style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.55))),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Active Yogas ─────────────────────────────────────────
        if (structuralYogas.isNotEmpty || cautionYogas.isNotEmpty) ...[
          SectionLabel('Active in Your Chart'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...structuralYogas.take(4).map((y) => _YogaRow(
                    name: y['name'] as String, isPositive: true,
                    isDark: isDark, gold: gold)),
                ...cautionYogas.take(2).map((y) => _YogaRow(
                    name: y['name'] as String, isPositive: false,
                    isDark: isDark, gold: gold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── What Your Chart Says (natal combos) ──────────────────
        if (natalCombos.isNotEmpty) ...[
          SectionLabel('What Your Chart Says'),
          const SizedBox(height: 8),
          ...natalCombos.take(4).map((c) {
            final combo = c as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AstroCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(combo['name'] as String? ?? '',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w600, color: gold)),
                    const SizedBox(height: 6),
                    Text(combo['what_it_creates'] as String? ?? '',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: secondary, height: 1.5)),
                    if (combo['advice'] != null) ...[
                      const SizedBox(height: 6),
                      Text(combo['advice'] as String,
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: secondary.withOpacity(0.7),
                              height: 1.4, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // ── Honest Warnings ──────────────────────────────────────
        if (warnings.isNotEmpty) ...[
          SectionLabel('Be Honest With Yourself'),
          const SizedBox(height: 8),
          ...warnings.take(3).map((w) {
            final warning = w as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dangerColor.withOpacity(0.2), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(warning['short'] as String? ?? '',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: primary, height: 1.5)),
                    if (warning['probability'] != null) ...[
                      const SizedBox(height: 6),
                      Text(warning['probability'] as String,
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: secondary,
                              height: 1.4, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],

      ],
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────
class _LabeledText extends StatelessWidget {
  final String label, text;
  final Color textColor, labelColor;
  const _LabeledText(this.label, this.text, this.textColor, this.labelColor);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ', style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w600, color: labelColor)),
      Expanded(child: Text(text, style: GoogleFonts.dmSans(
          fontSize: 12, color: textColor, height: 1.5))),
    ]);
  }
}

class _PatternCard extends StatelessWidget {
  final IconData icon;
  final String label, text;
  final Color color;
  final bool isDark;
  const _PatternCard({required this.icon, required this.label,
      required this.text, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AstroCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 30, height: 30,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(text, style: GoogleFonts.dmSans(
                fontSize: 12, color: secondary, height: 1.45)),
          ])),
        ]),
      ),
    );
  }
}

class _YogaRow extends StatelessWidget {
  final String name;
  final bool isPositive, isDark;
  final Color gold;
  const _YogaRow({required this.name, required this.isPositive,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final color = isPositive ? successColor : dangerColor;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 10),
        Text(name, style: GoogleFonts.dmSans(
            fontSize: 12, color: isPositive ? color : color,
            fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(isPositive ? 'Active' : 'Caution',
            style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
      ]),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  final Color gold;
  const _ProfileHeader({required this.user, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(children: [
      Container(width: 52, height: 52,
          decoration: BoxDecoration(
              color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(26),
              border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
          child: Center(child: Text(
              (user.name as String).isNotEmpty ? user.name[0].toUpperCase() : 'A',
              style: GoogleFonts.cormorantGaramond(fontSize: 26, color: gold)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(user.name as String, style: GoogleFonts.dmSans(
            fontSize: 17, fontWeight: FontWeight.w500, color: primary)),
        const SizedBox(height: 2),
        Text(_dobStr(user.dob as DateTime),
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
      ])),
    ]);
  }

  String _dobStr(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month-1]} ${d.year}';
  }
}

class _SignOutButton extends StatelessWidget {
  final bool isDark;
  const _SignOutButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: GestureDetector(
      onTap: () => FirebaseAuth.instance.signOut(),
      child: Padding(padding: const EdgeInsets.all(16),
          child: Text('Sign out', style: GoogleFonts.dmSans(fontSize: 13, color: secondary))),
    ));
  }
}
