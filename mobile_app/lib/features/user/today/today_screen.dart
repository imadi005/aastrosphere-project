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
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 1.5, color: gold),
                const SizedBox(height: 16),
                Text('Reading the cosmos...',
                    style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
              ],
            ),
          ),
          error: (e, _) => _ErrorView(onRetry: () => ref.refresh(todayDataProvider)),
          data: (data) => _TodayView(data: data, name: user.name, isDark: isDark),
        );
      },
    );
  }
}

class _TodayView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String name;
  final bool isDark;

  const _TodayView({required this.data, required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final daily = data['daily'] as int;
    final dailyPlanet = data['dailyPlanet'] as String;
    final rating = data['rating'] as String;
    final insight = data['insight'] as String;
    final hours = data['hours'] as List<dynamic>;
    final maha = data['maha'] as Map<String, dynamic>;
    final antar = data['antar'] as Map<String, dynamic>;
    final monthly = data['monthly'] as Map<String, dynamic>;
    final basic = data['basic'] as int;
    final destiny = data['destiny'] as int;
    final basicPlanet = data['basicPlanet'] as String;
    final destinyPlanet = data['destinyPlanet'] as String;
    final hasAlert = data['hasAlert'] as bool? ?? false;
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: () async {},
      color: gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(_greeting(name),
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 22, fontWeight: FontWeight.w400, color: gold)),
            Text(DateFormat('EEEE, d MMMM').format(now),
                style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary)),
            const SizedBox(height: 20),

            // Day card
            _DayCard(
              daily: daily,
              planet: dailyPlanet,
              rating: rating,
              insight: insight,
              isDark: isDark,
              gold: gold,
            ),
            const SizedBox(height: 20),

            // Hourly strip
            _HourlyStrip(hours: hours, currentHour: now.hour, isDark: isDark, gold: gold),
            const SizedBox(height: 20),

            // Running periods
            _RunningPeriods(maha: maha, antar: antar, monthly: monthly, isDark: isDark, gold: gold),

            // Alert
            if (hasAlert) ...[
              const SizedBox(height: 16),
              _AlertCard(message: data['alertMessage'] ?? '', isDark: isDark),
            ],

            const SizedBox(height: 20),

            // Basic + Destiny
            Row(children: [
              Expanded(child: _NumTile(
                label: 'Basic number', number: basic, planet: basicPlanet,
                gold: gold, isDark: isDark,
              )),
              const SizedBox(width: 12),
              Expanded(child: _NumTile(
                label: 'Destiny number', number: destiny, planet: destinyPlanet,
                gold: gold, isDark: isDark,
              )),
            ]),
          ],
        ),
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
}

// ─── Day Card ─────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final int daily;
  final String planet, rating, insight;
  final bool isDark;
  final Color gold;

  const _DayCard({
    required this.daily, required this.planet, required this.rating,
    required this.insight, required this.isDark, required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    DayRating ratingEnum;
    switch (rating) {
      case 'favorable': ratingEnum = DayRating.favorable;
      case 'avoid': ratingEnum = DayRating.avoid;
      default: ratingEnum = DayRating.caution;
    }

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
                    Text(daily.toString(),
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 64, fontWeight: FontWeight.w300,
                            color: gold, height: 1)),
                    const SizedBox(height: 2),
                    Text(planet,
                        style: GoogleFonts.dmSans(fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              DayBadge(ratingEnum),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: border, thickness: 0.5),
          const SizedBox(height: 12),
          Text(insight,
              style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary, height: 1.6)),
          const SizedBox(height: 14),
          Row(children: [
            Text('Full insight',
                style: GoogleFonts.dmSans(fontSize: 12, color: gold)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 12, color: gold),
          ]),
        ],
      ),
    );
  }
}

// ─── Hourly Strip ─────────────────────────────────────────────
class _HourlyStrip extends StatelessWidget {
  final List<dynamic> hours;
  final int currentHour;
  final bool isDark;
  final Color gold;

  const _HourlyStrip({
    required this.hours, required this.currentHour,
    required this.isDark, required this.gold,
  });

  @override
  Widget build(BuildContext context) {
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
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final h = hours[i] as Map<String, dynamic>;
              final isNow = h['hour'] == currentHour;
              final num = h['number'] as int;
              final planet = h['planet'] as String;
              final hourInt = h['hour'] as int;
              final label = hourInt == 0 ? '12am'
                  : hourInt < 12 ? '${hourInt}am'
                  : hourInt == 12 ? '12pm'
                  : '${hourInt - 12}pm';

              return Container(
                width: 54,
                decoration: BoxDecoration(
                  color: isNow
                      ? (isDark ? const Color(0xFF1F1A06) : const Color(0xFFFEF8E7))
                      : subtleBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isNow ? gold : border, width: isNow ? 0.8 : 0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(num.toString(),
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            color: isNow ? gold : textPrimary)),
                    Text(planet.length > 3 ? planet.substring(0, 3) : planet,
                        style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary)),
                    Text(label,
                        style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary)),
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

// ─── Running Periods ──────────────────────────────────────────
class _RunningPeriods extends StatelessWidget {
  final Map<String, dynamic> maha, antar, monthly;
  final bool isDark;
  final Color gold;

  const _RunningPeriods({
    required this.maha, required this.antar, required this.monthly,
    required this.isDark, required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _PRow(label: 'Mahadasha', data: maha,
              period: '${_yr(maha['start'])}–${_yr(maha['end'])}',
              color: gold, isDark: isDark),
          Divider(color: border, thickness: 0.5, height: 20),
          _PRow(label: 'Antardasha', data: antar,
              period: '${_mo(antar['start'])}–${_mo(antar['end'])}',
              color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
          Divider(color: border, thickness: 0.5, height: 20),
          _PRow(label: 'Monthly', data: monthly,
              period: '${_dt(monthly['start'])}–${_dt(monthly['end'])}',
              color: const Color(0xFF6366F1), isDark: isDark),
        ],
      ),
    );
  }

  String _yr(String iso) => DateFormat('yyyy').format(DateTime.parse(iso));
  String _mo(String iso) => DateFormat('MMM yy').format(DateTime.parse(iso));
  String _dt(String iso) => DateFormat('d MMM').format(DateTime.parse(iso));
}

class _PRow extends StatelessWidget {
  final String label, period;
  final Map<String, dynamic> data;
  final Color color;
  final bool isDark;

  const _PRow({required this.label, required this.data,
      required this.period, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final num = data['number'] as int;
    final planet = data['planet'] as String;

    return Row(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text(num.toString(),
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 18, color: color)),
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

// ─── Alert Card ───────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final String message;
  final bool isDark;

  const _AlertCard({required this.message, required this.isDark});

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
            decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor),
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
                Text(message,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Num Tile ─────────────────────────────────────────────────
class _NumTile extends StatelessWidget {
  final String label, planet;
  final int number;
  final Color gold;
  final bool isDark;

  const _NumTile({required this.label, required this.number,
      required this.planet, required this.gold, required this.isDark});

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
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary)),
          const SizedBox(height: 8),
          Text(number.toString(),
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 36, fontWeight: FontWeight.w300, color: gold)),
          Text(planet, style: GoogleFonts.dmSans(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Could not load today\'s data',
              style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Text('Try again',
                style: GoogleFonts.dmSans(fontSize: 13, color: gold)),
          ),
        ],
      ),
    );
  }
}

// ─── No Profile ───────────────────────────────────────────────
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
