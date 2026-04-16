import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../auth/providers/user_provider.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final todayAsync = ref.watch(todayDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => const Center(child: Text('Error loading profile')),
      data: (user) {
        if (user == null) return const _NoProfileView();
        return todayAsync.when(
          loading: () => Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 1.5, color: gold),
              const SizedBox(height: 16),
              Text('Reading today\'s energy...',
                  style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
            ],
          )),
          error: (e, _) => _ErrorView(onRetry: () => ref.refresh(todayDataProvider)),
          data: (data) => _TodayView(data: data, name: user.name, isDark: isDark,
              onRefresh: () async => ref.refresh(todayDataProvider)),
        );
      },
    );
  }
}

class _TodayView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String name;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _TodayView({required this.data, required this.name,
      required this.isDark, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final now = DateTime.now();

    // Parse data
    final rating = data['rating'] as String? ?? 'caution';
    final quote = data['quote'] as String? ?? '';
    final insight = data['insight'] as String? ?? '';
    final toDo = (data['what_to_do'] as List? ?? []).cast<String>();
    final avoid = (data['what_to_avoid'] as List? ?? []).cast<String>();
    final activeYogas = (data['active_yogas'] as List? ?? []);
    final bestHours = (data['best_hours'] as List? ?? []);
    final cautionHours = (data['caution_hours'] as List? ?? []);

    // Separate structural yogas from combo yogas
    final structuralYogas = activeYogas.where((y) => y['combo_key'] == null).toList();
    final comboYogas = activeYogas.where((y) => y['combo_key'] != null).toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Greeting ────────────────────────────────────────
            Text(_greeting(name),
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 24, fontWeight: FontWeight.w400, color: gold)),
            Text(DateFormat('EEEE, d MMMM').format(now),
                style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary)),
            const SizedBox(height: 20),

            // ── Yoga pills ───────────────────────────────────────
            if (structuralYogas.isNotEmpty) ...[
              SizedBox(
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: structuralYogas.length,
                  itemBuilder: (_, i) {
                    final y = structuralYogas[i];
                    final isPos = y['positive'] == true;
                    final color = isPos ? gold : Colors.redAccent;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
                      ),
                      child: Text(y['name'] ?? '',
                          style: GoogleFonts.dmSans(
                              fontSize: 10, fontWeight: FontWeight.w500, color: color)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Day Card ─────────────────────────────────────────
            _DayCard(rating: rating, quote: quote, insight: insight,
                isDark: isDark, gold: gold),
            const SizedBox(height: 20),

            // ── What's running (combo yogas) ─────────────────────
            if (comboYogas.isNotEmpty) ...[
              _ComboSection(combos: comboYogas, isDark: isDark, gold: gold),
              const SizedBox(height: 20),
            ],

            // ── Guidance ─────────────────────────────────────────
            if (toDo.isNotEmpty || avoid.isNotEmpty) ...[
              _GuidanceSection(toDo: toDo, avoid: avoid, isDark: isDark, gold: gold),
              const SizedBox(height: 20),
            ],

            // ── Best hours ───────────────────────────────────────
            if (bestHours.isNotEmpty || cautionHours.isNotEmpty) ...[
              _HoursSection(
                  bestHours: bestHours, cautionHours: cautionHours,
                  isDark: isDark, gold: gold),
            ],

          ],
        ),
      ),
    );
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final first = name.split(' ').first;
    if (h < 12) return 'Shubh Prabhat, $first';
    if (h < 17) return 'Namaste, $first';
    return 'Shubh Sandhya, $first';
  }
}

// ─── Day Card ─────────────────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final String rating, quote, insight;
  final bool isDark;
  final Color gold;

  const _DayCard({required this.rating, required this.quote,
      required this.insight, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    Color ratingColor;
    String ratingLabel;
    switch (rating) {
      case 'favorable':
        ratingColor = isDark ? AppColors.successDark : AppColors.success;
        ratingLabel = 'FAVORABLE';
      case 'avoid':
        ratingColor = isDark ? AppColors.dangerDark : AppColors.danger;
        ratingLabel = 'CHALLENGING';
      default:
        ratingColor = gold;
        ratingLabel = 'MIXED';
    }

    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating badge
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ratingColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text(ratingLabel,
                    style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w600,
                        letterSpacing: 0.5, color: ratingColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quote
          if (quote.isNotEmpty) ...[
            Text('"$quote"',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 16, fontStyle: FontStyle.italic,
                    color: gold, height: 1.5)),
            const SizedBox(height: 14),
            Divider(color: border, thickness: 0.5),
            const SizedBox(height: 12),
          ],

          // Insight
          if (insight.isNotEmpty)
            Text(insight,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: primary, height: 1.65)),
        ],
      ),
    );
  }
}

// ─── Combo Section (Running Energy, Monthly Energy, Today's Drive) ────────────
class _ComboSection extends StatelessWidget {
  final List<dynamic> combos;
  final bool isDark;
  final Color gold;

  const _ComboSection({required this.combos, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Label → icon map
    final icons = {
      'Running Energy': Icons.bolt_outlined,
      'Monthly Energy': Icons.calendar_month_outlined,
      "Today's Drive": Icons.trending_up_outlined,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('What\'s Running'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: combos.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value as Map<String, dynamic>;
              final name = c['name'] as String? ?? '';
              final desc = c['description'] as String? ?? '';
              final icon = icons[name] ?? Icons.circle_outlined;

              return Column(
                children: [
                  if (i > 0) Divider(color: border, height: 20, thickness: 0.5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 16, color: gold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: GoogleFonts.dmSans(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: gold, letterSpacing: 0.3)),
                            const SizedBox(height: 3),
                            Text(desc,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, color: secondary, height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Guidance Section ─────────────────────────────────────────────────────────
class _GuidanceSection extends StatelessWidget {
  final List<String> toDo, avoid;
  final bool isDark;
  final Color gold;

  const _GuidanceSection({required this.toDo, required this.avoid,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Today\'s Guidance'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Do
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: successColor.withOpacity(0.2), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DO', style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1, color: successColor)),
                    const SizedBox(height: 8),
                    ...toDo.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(width: 4, height: 4,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: successColor)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11, color: secondary, height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Avoid
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dangerColor.withOpacity(0.2), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVOID', style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1, color: dangerColor)),
                    const SizedBox(height: 8),
                    ...avoid.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(width: 4, height: 4,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: dangerColor)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11, color: secondary, height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Hours Section ────────────────────────────────────────────────────────────
class _HoursSection extends StatelessWidget {
  final List<dynamic> bestHours, cautionHours;
  final bool isDark;
  final Color gold;

  const _HoursSection({required this.bestHours, required this.cautionHours,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final warningColor = const Color(0xFFF59E0B);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Best & Caution Hours'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Best hours
              if (bestHours.isNotEmpty) ...[
                Row(children: [
                  Container(width: 6, height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: successColor)),
                  const SizedBox(width: 8),
                  Text('Best hours',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: successColor)),
                ]),
                const SizedBox(height: 10),
                ...bestHours.take(4).map((h) => _HourRow(
                  hour: h['hour'] as int,
                  reason: h['reason'] as String? ?? '',
                  goodFor: (h['good_for'] as List? ?? []).cast<String>(),
                  color: successColor,
                  secondary: secondary,
                )),
              ],

              // Divider
              if (bestHours.isNotEmpty && cautionHours.isNotEmpty) ...[
                Divider(color: border, height: 20, thickness: 0.5),
              ],

              // Caution hours
              if (cautionHours.isNotEmpty) ...[
                Row(children: [
                  Container(width: 6, height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: warningColor)),
                  const SizedBox(width: 8),
                  Text('Watch out',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: warningColor)),
                ]),
                const SizedBox(height: 10),
                ...cautionHours.take(3).map((h) => _HourRow(
                  hour: h['hour'] as int,
                  reason: h['reason'] as String? ?? '',
                  goodFor: [],
                  avoidFor: (h['avoid'] as List? ?? []).cast<String>(),
                  color: warningColor,
                  secondary: secondary,
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HourRow extends StatelessWidget {
  final int hour;
  final String reason;
  final List<String> goodFor;
  final List<String> avoidFor;
  final Color color, secondary;

  const _HourRow({
    required this.hour, required this.reason,
    required this.goodFor, this.avoidFor = const [],
    required this.color, required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final h12 = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final ampm = hour < 12 ? 'AM' : 'PM';
    final details = goodFor.isNotEmpty
        ? goodFor.take(2).join(', ')
        : avoidFor.take(2).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$h12',
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 18, color: color, height: 1)),
                Text(ampm,
                    style: GoogleFonts.dmSans(fontSize: 8, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: secondary)),
                if (details.isNotEmpty)
                  Text(details,
                      style: GoogleFonts.dmSans(fontSize: 11, color: secondary.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error / No Profile ───────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Could not load today\'s reading',
            style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
        const SizedBox(height: 16),
        GestureDetector(onTap: onRetry,
            child: Text('Try again',
                style: GoogleFonts.dmSans(fontSize: 13, color: gold))),
      ],
    ));
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    return Center(child: Text('Complete your profile to begin',
        style: GoogleFonts.dmSans(fontSize: 13, color: gold)));
  }
}
