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
    final fullAsync = ref.watch(fullPredictionProvider);
    final healthAsync = ref.watch(healthPredictionProvider);
    final relationshipAsync = ref.watch(relationshipPredictionProvider);

    return userAsync.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => const Center(child: Text('Error')),
      data: (user) {
        if (user == null) return const Center(child: Text('No profile'));
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              _ProfileHeader(user: user, isDark: isDark, gold: gold),
              const SizedBox(height: 24),

              // Full prediction
              fullAsync.when(
                loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
                error: (_, __) => const SizedBox.shrink(),
                data: (full) => _FullPredictionSection(data: full, isDark: isDark, gold: gold),
              ),

              const SizedBox(height: 20),

              // Health
              SectionLabel('Health Watch'),
              const SizedBox(height: 8),
              healthAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (health) => _HealthSection(data: health, isDark: isDark, gold: gold),
              ),

              const SizedBox(height: 20),

              // Relationship
              SectionLabel('Relationship Outlook'),
              const SizedBox(height: 8),
              relationshipAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (rel) => _RelationshipSection(data: rel, isDark: isDark, gold: gold),
              ),

              const SizedBox(height: 20),

              // Sign out
              _SignOutButton(isDark: isDark),
            ],
          ),
        );
      },
    );
  }
}

// ─── Profile header ───────────────────────────────────────────
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
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
        child: Center(child: Text(
          user.name[0].toUpperCase(),
          style: GoogleFonts.cormorantGaramond(fontSize: 28, color: gold),
        )),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.name, style: GoogleFonts.dmSans(
              fontSize: 17, fontWeight: FontWeight.w500, color: primary)),
          const SizedBox(height: 3),
          Text(_dobStr(user.dob as DateTime),
              style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
          if (user.isAstrologer)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
              child: Text('Astrologer', style: GoogleFonts.dmSans(fontSize: 10, color: gold)),
            ),
        ],
      )),
    ]);
  }

  String _dobStr(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month-1]} ${d.year}';
  }
}

// ─── Full prediction section ──────────────────────────────────
class _FullPredictionSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  const _FullPredictionSection({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final profile = data['profile'] as Map<String, dynamic>;
    final grid = data['grid'] as Map<String, dynamic>;
    final yogas = (grid['active_yogas'] as List<dynamic>?) ?? [];
    final traits = profile['traits'] as Map<String, dynamic>? ?? {};
    final lucky = profile['lucky'] as Map<String, dynamic>? ?? {};
    final professions = (profile['professions'] as List<dynamic>?)?.cast<String>() ?? [];
    final positives = (traits['positive'] as List<dynamic>?)?.cast<String>() ?? [];
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Core numbers
        SectionLabel('Your Numbers'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _NumberPill(label: 'Basic', number: profile['basic'] as int,
                    planet: profile['basicPlanet'] as String,
                    color: gold, isDark: isDark),
                const SizedBox(width: 12),
                _NumberPill(label: 'Destiny', number: profile['destiny'] as int,
                    planet: profile['destinyPlanet'] as String,
                    color: const Color(0xFF6366F1), isDark: isDark),
              ]),
              if (traits['core'] != null) ...[
                const SizedBox(height: 14),
                Text(traits['core'] as String,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: secondary, height: 1.6,
                        fontStyle: FontStyle.italic)),
              ],
              if (positives.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6,
                    children: positives.take(6).map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: gold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
                      child: Text(t, style: GoogleFonts.dmSans(fontSize: 11, color: gold)),
                    )).toList()),
              ],
            ],
          ),
        ),

        if (yogas.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionLabel('Active Yogas'),
          const SizedBox(height: 8),
          ...yogas.map((y) {
            final yoga = y as Map<String, dynamic>;
            final isNeg = yoga['isNegative'] as bool? ?? false;
            final color = isNeg ? dangerColor : successColor;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(yoga['yoga'] as String,
                        style: GoogleFonts.dmSans(fontSize: 13,
                            fontWeight: FontWeight.w500, color: color)),
                    const SizedBox(height: 3),
                    Text(yoga['description'] as String? ?? '',
                        style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.5)),
                  ])),
                ]),
              ),
            );
          }),
        ],

        if (professions.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionLabel('Suited Careers'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(14),
            child: Wrap(spacing: 8, runSpacing: 8,
                children: professions.map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5)),
                  child: Text(p, style: GoogleFonts.dmSans(fontSize: 12, color: primary)),
                )).toList()),
          ),
        ],

        if (lucky.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionLabel('Lucky For You'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _LuckyRow('Colors', (lucky['colors'] as List<dynamic>).join(', '), isDark),
              Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 16, thickness: 0.5),
              _LuckyRow('Direction', lucky['direction'] as String? ?? '', isDark),
              Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 16, thickness: 0.5),
              _LuckyRow('Numbers', (lucky['luckyNumbers'] as List<dynamic>).join(' & '), isDark),
            ]),
          ),
        ],
      ],
    );
  }
}

class _NumberPill extends StatelessWidget {
  final String label, planet;
  final int number;
  final Color color;
  final bool isDark;
  const _NumberPill({required this.label, required this.number,
      required this.planet, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
      const SizedBox(height: 2),
      Text('$number', style: GoogleFonts.cormorantGaramond(
          fontSize: 40, fontWeight: FontWeight.w300, color: color, height: 1)),
      Text(planet, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
    ]);
  }
}

class _LuckyRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _LuckyRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
    ]);
  }
}

// ─── Health section ───────────────────────────────────────────
class _HealthSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  const _HealthSection({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final healthWatch = (data['healthWatch'] as List<dynamic>?) ?? [];
    final warnings = (data['warnings'] as List<dynamic>?)?.cast<String>() ?? [];
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...healthWatch.take(2).map((hw) {
            final h = hw as Map<String, dynamic>;
            final common = (h['common'] as List<dynamic>?)?.cast<String>() ?? [];
            final planet = h['planet'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(planet, style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(height: 4),
                Text(common.join(' · '),
                    style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
              ]),
            );
          }),
          if (warnings.isNotEmpty) ...[
            Divider(color: border, height: 16, thickness: 0.5),
            ...warnings.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: 5),
                    child: Container(width: 5, height: 5,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                const SizedBox(width: 8),
                Expanded(child: Text(w, style: GoogleFonts.dmSans(
                    fontSize: 12, color: secondary, height: 1.5))),
              ]),
            )),
          ],
        ],
      ),
    );
  }
}

// ─── Relationship section ─────────────────────────────────────
class _RelationshipSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  const _RelationshipSection({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final marriage = (data['marriage_indicators'] as List<dynamic>?) ?? [];
    final romance = (data['romance_indicators'] as List<dynamic>?)?.cast<String>() ?? [];
    final cautions = (data['caution_indicators'] as List<dynamic>?)?.cast<String>() ?? [];
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (marriage.isNotEmpty) ...[
            ...marriage.map((m) {
              final mi = m as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 5),
                      child: Container(width: 5, height: 5,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(mi['text'] as String? ?? '',
                      style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
                ]),
              );
            }),
          ],
          if (romance.isNotEmpty) ...[
            if (marriage.isNotEmpty) Divider(color: border, height: 16, thickness: 0.5),
            ...romance.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: 5),
                    child: Container(width: 5, height: 5,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: gold))),
                const SizedBox(width: 8),
                Expanded(child: Text(r, style: GoogleFonts.dmSans(
                    fontSize: 12, color: secondary, height: 1.5))),
              ]),
            )),
          ],
          if (cautions.isNotEmpty) ...[
            Divider(color: border, height: 16, thickness: 0.5),
            ...cautions.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: 5),
                    child: Container(width: 5, height: 5,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                const SizedBox(width: 8),
                Expanded(child: Text(c, style: GoogleFonts.dmSans(
                    fontSize: 12, color: secondary, height: 1.5))),
              ]),
            )),
          ],
          if (marriage.isEmpty && romance.isEmpty && cautions.isEmpty)
            Text('No specific indicators this period.',
                style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        ],
      ),
    );
  }
}

// ─── Sign out ─────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  final bool isDark;
  const _SignOutButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(
      child: GestureDetector(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Sign out',
              style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
        ),
      ),
    );
  }
}
