import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/user_provider.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Something went wrong')),
      data: (user) {
        if (user == null) return const _NoProfileView();
        return _TodayView(dob: user.dob);
      },
    );
  }
}

class _TodayView extends StatelessWidget {
  final DateTime dob;
  const _TodayView({required this.dob});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maha = NumerologyEngine.currentMahadasha(dob);
    final antar = NumerologyEngine.currentAntardasha(dob);
    final monthly = NumerologyEngine.currentMonthlyDasha(dob);
    final daily = NumerologyEngine.dailyDasha(dob, today);
    final rating = NumerologyEngine.getDayRating(dob, today);
    final basic = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    final hasAlert = _shouldShowAlert(dob, today);

    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
            DateFormat('EEEE, d MMMM').format(today),
            style: GoogleFonts.dmSans(
              fontSize: 12, color: textSecondary, letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Main day card
          _DayCard(
            daily: daily,
            rating: rating,
            isDark: isDark,
            gold: gold,
          ),
          const SizedBox(height: 20),

          // Hourly strip
          _HourlyStrip(dob: dob, isDark: isDark, gold: gold),
          const SizedBox(height: 20),

          // Running periods
          _RunningPeriods(
            maha: maha, antar: antar, monthly: monthly,
            isDark: isDark, gold: gold,
          ),

          // Alert if triggered
          if (hasAlert) ...[
            const SizedBox(height: 16),
            _AlertCard(isDark: isDark),
          ],

          const SizedBox(height: 20),

          // Quick numbers
          _QuickNumbers(
            basic: basic, destiny: destiny,
            isDark: isDark, gold: gold,
          ),
        ],
      ),
    );
  }

  bool _shouldShowAlert(DateTime dob, DateTime today) {
    final freqMap = NumerologyEngine.buildFrequencyMap(dob);
    final maha = NumerologyEngine.currentMahadasha(dob).number;
    final antar = NumerologyEngine.currentAntardasha(dob).number;
    // Alert if Rahu (4) in maha/antar AND 8 or 4 in grid
    return (maha == 4 || antar == 4) && (freqMap.containsKey(8) || freqMap.containsKey(4));
  }
}

// ─── Day Card ─────────────────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final int daily;
  final DayRating rating;
  final bool isDark;
  final Color gold;

  const _DayCard({required this.daily, required this.rating, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final planet = NumerologyEngine.planetNames[daily] ?? '';
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      daily.toString(),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        color: gold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      planet,
                      style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              DayBadge(rating),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            thickness: 0.5,
          ),
          const SizedBox(height: 12),
          Text(
            _dayInsight(daily, rating),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {}, // navigate to insights
            child: Row(
              children: [
                Text(
                  'Full insight',
                  style: GoogleFonts.dmSans(fontSize: 12, color: gold),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayInsight(int daily, DayRating rating) {
    final insights = {
      1: 'Sun energy is direct today. Take initiative. Ego can get in the way — check it.',
      2: 'Moon makes emotions loud. Creativity is high. Avoid conflict, lean into feeling.',
      3: 'Jupiter expands everything today. Good for learning, teaching, and honest talk.',
      4: 'Rahu brings confusion and speed. Double-check everything. Not a day for big decisions.',
      5: 'Mercury is sharp. Communication, numbers, deals — all flow well today.',
      6: 'Venus asks for harmony. Relationships take centre stage. Money decisions — wait.',
      7: 'Ketu pulls inward. Good for reflection and research. Social energy is low.',
      8: 'Saturn demands patience today. Things move slow on purpose. Trust the delay.',
      9: 'Mars adds fire. Bold action works. Anger is also close — choose your battles.',
    };
    return insights[daily] ?? 'Today carries the energy of number $daily.';
  }
}

// ─── Hourly Strip ─────────────────────────────────────────────────────────────
class _HourlyStrip extends StatelessWidget {
  final DateTime dob;
  final bool isDark;
  final Color gold;

  const _HourlyStrip({required this.dob, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final cardBg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOUR BY HOUR',
          style: GoogleFonts.dmSans(
            fontSize: 10, fontWeight: FontWeight.w500,
            letterSpacing: 1.2, color: textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 24,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final isNow = i == now.hour;
              final hourNum = NumerologyEngine.hourlyDasha(dob, now, i);
              final planet = NumerologyEngine.planetNames[hourNum] ?? '';
              final hourLabel = i == 0 ? '12am' : i < 12 ? '${i}am' : i == 12 ? '12pm' : '${i - 12}pm';

              return Container(
                width: 52,
                decoration: BoxDecoration(
                  color: isNow ? (isDark ? const Color(0xFF1F1A06) : const Color(0xFFFEF8E7)) : subtleBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isNow ? gold : border,
                    width: isNow ? 0.8 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hourNum.toString(),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: isNow ? gold : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    Text(
                      planet.substring(0, planet.length.clamp(0, 3)),
                      style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary),
                    ),
                    Text(hourLabel, style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Running Periods ──────────────────────────────────────────────────────────
class _RunningPeriods extends StatelessWidget {
  final DashaResult maha, antar, monthly;
  final bool isDark;
  final Color gold;

  const _RunningPeriods({
    required this.maha, required this.antar, required this.monthly,
    required this.isDark, required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _PeriodRow(
            label: 'Mahadasha',
            number: maha.number,
            planet: maha.planet,
            period: '${_fmtYear(maha.start)}–${_fmtYear(maha.end)}',
            color: gold,
            isDark: isDark,
          ),
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, thickness: 0.5, height: 16),
          _PeriodRow(
            label: 'Antardasha',
            number: antar.number,
            planet: antar.planet,
            period: '${_fmtMonth(antar.start)}–${_fmtMonth(antar.end)}',
            color: isDark ? AppColors.successDark : AppColors.success,
            isDark: isDark,
          ),
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, thickness: 0.5, height: 16),
          _PeriodRow(
            label: 'Monthly',
            number: monthly.number,
            planet: monthly.planet,
            period: '${_fmtDate(monthly.start)}–${_fmtDate(monthly.end)}',
            color: const Color(0xFF6366F1),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _fmtYear(DateTime d) => DateFormat('yyyy').format(d);
  String _fmtMonth(DateTime d) => DateFormat('MMM yyyy').format(d);
  String _fmtDate(DateTime d) => DateFormat('d MMM').format(d);
}

class _PeriodRow extends StatelessWidget {
  final String label, planet, period;
  final int number;
  final Color color;
  final bool isDark;

  const _PeriodRow({
    required this.label, required this.number, required this.planet,
    required this.period, required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16, fontWeight: FontWeight.w400, color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: textSecondary)),
              Text(
                planet,
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ],
          ),
        ),
        Text(period, style: GoogleFonts.dmSans(fontSize: 11, color: textTertiary)),
      ],
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final bool isDark;
  const _AlertCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dangerBgDark : AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.dangerDark : AppColors.danger).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.dangerDark : AppColors.danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay careful today',
                  style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.dangerDark : AppColors.danger,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Rahu period active. Physical carelessness is high — slow down, double-check.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Numbers ────────────────────────────────────────────────────────────
class _QuickNumbers extends StatelessWidget {
  final int basic, destiny;
  final bool isDark;
  final Color gold;

  const _QuickNumbers({required this.basic, required this.destiny, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Row(
      children: [
        Expanded(child: _NumberTile(
          label: 'Basic', number: basic,
          planet: NumerologyEngine.planetNames[basic] ?? '',
          color: gold, subtleBg: subtleBg, border: border,
          textSecondary: textSecondary, isDark: isDark,
        )),
        const SizedBox(width: 10),
        Expanded(child: _NumberTile(
          label: 'Destiny', number: destiny,
          planet: NumerologyEngine.planetNames[destiny] ?? '',
          color: gold, subtleBg: subtleBg, border: border,
          textSecondary: textSecondary, isDark: isDark,
        )),
      ],
    );
  }
}

class _NumberTile extends StatelessWidget {
  final String label, planet;
  final int number;
  final Color color, subtleBg, border, textSecondary;
  final bool isDark;

  const _NumberTile({
    required this.label, required this.number, required this.planet,
    required this.color, required this.subtleBg, required this.border,
    required this.textSecondary, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(
            number.toString(),
            style: GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.w300, color: color),
          ),
          Text(planet, style: GoogleFonts.dmSans(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }
}

// ─── No Profile ───────────────────────────────────────────────────────────────
class _NoProfileView extends StatelessWidget {
  const _NoProfileView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Complete your profile',
            style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your date of birth to begin',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
