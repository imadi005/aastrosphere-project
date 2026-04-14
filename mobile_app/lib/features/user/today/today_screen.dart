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
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
      error: (e, _) => const Center(child: Text('Something went wrong')),
      data: (user) {
        if (user == null) return const _NoProfileView();
        return _TodayView(dob: user.dob, name: user.name);
      },
    );
  }
}

class _TodayView extends StatelessWidget {
  final DateTime dob;
  final String name;
  const _TodayView({required this.dob, required this.name});

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
    final hasAlert = _shouldShowAlert(dob);

    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            _greeting(name),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22, fontWeight: FontWeight.w400, color: gold,
            ),
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(today),
            style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 20),

          // Main day card
          _DayCard(daily: daily, rating: rating, isDark: isDark, gold: gold),
          const SizedBox(height: 20),

          // Hourly strip
          _HourlyStrip(dob: dob, isDark: isDark, gold: gold),
          const SizedBox(height: 20),

          // Running periods
          _RunningPeriods(maha: maha, antar: antar, monthly: monthly, isDark: isDark, gold: gold),

          // Alert
          if (hasAlert) ...[
            const SizedBox(height: 16),
            _AlertCard(isDark: isDark),
          ],

          const SizedBox(height: 20),

          // Basic + Destiny
          _QuickNumbers(basic: basic, destiny: destiny, isDark: isDark, gold: gold),
        ],
      ),
    );
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final first = name.split(' ').first;
    if (h < 12) return 'Good morning, $first';
    if (h < 17) return 'Good afternoon, $first';
    return 'Good evening, $first';
  }

  bool _shouldShowAlert(DateTime dob) {
    final maha = NumerologyEngine.currentMahadasha(dob).number;
    final antar = NumerologyEngine.currentAntardasha(dob).number;
    final freqMap = NumerologyEngine.buildFrequencyMap(dob);
    return (maha == 4 || antar == 4) &&
        (freqMap.containsKey(8) || freqMap.containsKey(4));
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
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

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
                        fontSize: 64, fontWeight: FontWeight.w300,
                        color: gold, height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(planet,
                        style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
                  ],
                ),
              ),
              DayBadge(rating),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: borderColor, thickness: 0.5),
          const SizedBox(height: 12),
          Text(
            _dayInsight(daily),
            style: GoogleFonts.dmSans(
              fontSize: 13, color: textPrimary, height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text('Full insight',
                    style: GoogleFonts.dmSans(fontSize: 12, color: gold)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayInsight(int n) {
    const insights = {
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
    return insights[n] ?? 'Today carries the energy of number $n.';
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
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Hour by hour'),
        const SizedBox(height: 4),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 24,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final isNow = i == now.hour;
              final hourNum = NumerologyEngine.hourlyDasha(dob, now, i);
              final planet = NumerologyEngine.planetNames[hourNum] ?? '';
              final hourLabel = i == 0
                  ? '12am'
                  : i < 12
                      ? '${i}am'
                      : i == 12
                          ? '12pm'
                          : '${i - 12}pm';

              return Container(
                width: 54,
                decoration: BoxDecoration(
                  color: isNow
                      ? (isDark ? const Color(0xFF1F1A06) : const Color(0xFFFEF8E7))
                      : subtleBg,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: isNow ? gold : textPrimary,
                      ),
                    ),
                    Text(
                      planet.length > 3 ? planet.substring(0, 3) : planet,
                      style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary),
                    ),
                    Text(
                      hourLabel,
                      style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary),
                    ),
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
    required this.maha,
    required this.antar,
    required this.monthly,
    required this.isDark,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _PeriodRow(
            label: 'Mahadasha',
            number: maha.number,
            planet: maha.planet,
            period: '${_yr(maha.start)}–${_yr(maha.end)}',
            color: gold,
            isDark: isDark,
          ),
          Divider(color: border, thickness: 0.5, height: 20),
          _PeriodRow(
            label: 'Antardasha',
            number: antar.number,
            planet: antar.planet,
            period: '${_mo(antar.start)}–${_mo(antar.end)}',
            color: isDark ? AppColors.successDark : AppColors.success,
            isDark: isDark,
          ),
          Divider(color: border, thickness: 0.5, height: 20),
          _PeriodRow(
            label: 'Monthly',
            number: monthly.number,
            planet: monthly.planet,
            period: '${_dt(monthly.start)}–${_dt(monthly.end)}',
            color: const Color(0xFF6366F1),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _yr(DateTime d) => DateFormat('yyyy').format(d);
  String _mo(DateTime d) => DateFormat('MMM yy').format(d);
  String _dt(DateTime d) => DateFormat('d MMM').format(d);
}

class _PeriodRow extends StatelessWidget {
  final String label, planet, period;
  final int number;
  final Color color;
  final bool isDark;

  const _PeriodRow({
    required this.label,
    required this.number,
    required this.planet,
    required this.period,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Row(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18, fontWeight: FontWeight.w400, color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary)),
              Text(planet,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary)),
            ],
          ),
        ),
        Text(period,
            style: GoogleFonts.dmSans(fontSize: 11, color: textTertiary)),
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
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final dangerBg = isDark ? AppColors.dangerBgDark : AppColors.dangerBg;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dangerColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dangerColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stay careful today',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w500, color: dangerColor)),
                const SizedBox(height: 3),
                Text(
                  'Rahu period active. Physical carelessness is high — slow down.',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: textSecondary, height: 1.5),
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

  const _QuickNumbers({
    required this.basic,
    required this.destiny,
    required this.isDark,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _NumTile(
          label: 'Basic number',
          number: basic,
          planet: NumerologyEngine.planetNames[basic] ?? '',
          gold: gold, isDark: isDark,
        )),
        const SizedBox(width: 12),
        Expanded(child: _NumTile(
          label: 'Destiny number',
          number: destiny,
          planet: NumerologyEngine.planetNames[destiny] ?? '',
          gold: gold, isDark: isDark,
        )),
      ],
    );
  }
}

class _NumTile extends StatelessWidget {
  final String label, planet;
  final int number;
  final Color gold;
  final bool isDark;

  const _NumTile({
    required this.label, required this.number,
    required this.planet, required this.gold, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: subtleBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 10, color: textSecondary, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Text(
            number.toString(),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 36, fontWeight: FontWeight.w300, color: gold,
            ),
          ),
          Text(planet,
              style: GoogleFonts.dmSans(fontSize: 11, color: textSecondary)),
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
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Complete your profile',
              style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold)),
          const SizedBox(height: 8),
          Text('Add your date of birth to begin',
              style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
        ],
      ),
    );
  }
}
