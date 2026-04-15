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
                Text('Analyzing your cosmic alignment...',
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

// Changed from StatelessWidget to ConsumerWidget to use 'ref'
class _TodayView extends ConsumerWidget {
  final Map<String, dynamic> data;
  final String name;
  final bool isDark;

  const _TodayView({required this.data, required this.name, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final now = DateTime.now();

    final yogas = (data['active_yogas'] as List? ?? []);
    final toDo = (data['what_to_do'] as List? ?? []);
    final avoid = (data['what_to_avoid'] as List? ?? []);
    
    final maha = (data['mahaDetails'] ?? data['maha']) as Map<String, dynamic>?;
    final antar = (data['antarDetails'] ?? data['antar']) as Map<String, dynamic>?;
    final monthly = (data['monthlyDetails'] ?? data['monthly']) as Map<String, dynamic>?;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(todayDataProvider),
      color: gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(name),
                style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w400, color: gold)),
            Text(DateFormat('EEEE, d MMMM').format(now),
                style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary)),
            const SizedBox(height: 16),

            if (yogas.isNotEmpty) ...[
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: yogas.length,
                  itemBuilder: (context, i) {
                    final yoga = yogas[i];
                    final isPositive = yoga['positive'] ?? true;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isPositive ? gold.withOpacity(0.1) : Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isPositive ? gold.withOpacity(0.3) : Colors.red.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(yoga['name'] ?? 'Unknown Yoga', 
                          style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: isPositive ? gold : Colors.redAccent)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            _DayCard(
              daily: data['daily'] ?? 0,
              rating: data['rating'] ?? 'caution',
              insight: data['insight'] ?? 'No insight available.',
              quote: data['quote'] ?? '',
              isDark: isDark,
              gold: gold,
            ),
            const SizedBox(height: 20),

            if (toDo.isNotEmpty || avoid.isNotEmpty) ...[
               _ActionableGuidance(toDo: toDo, avoid: avoid, isDark: isDark, gold: gold),
               const SizedBox(height: 20),
            ],

            _HourlyStrip(hours: data['hours'] ?? [], currentHour: now.hour, isDark: isDark, gold: gold),
            const SizedBox(height: 20),

            if (maha != null && antar != null && monthly != null)
              _RunningPeriods(maha: maha, antar: antar, monthly: monthly, isDark: isDark, gold: gold)
            else
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Dasha details sync in progress...", style: TextStyle(fontSize: 12, color: Colors.grey)),
              )),
          ],
        ),
      ),
    );
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final first = name.isNotEmpty ? name.split(' ').first : "User";
    if (h < 12) return 'Shubh Prabhat, $first';
    if (h < 17) return 'Namaste, $first';
    return 'Shubh Sandhya, $first';
  }
}

class _DayCard extends StatelessWidget {
  final int daily;
  final String rating, insight, quote;
  final bool isDark;
  final Color gold;

  const _DayCard({required this.daily, required this.rating, required this.insight, required this.quote, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final ratingColor = rating == 'favorable' ? Colors.green : (rating == 'avoid' ? Colors.redAccent : gold);
    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(daily.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 64, color: gold, height: 1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: ratingColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(rating.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: ratingColor)),
              ),
            ],
          ),
          if (quote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('"$quote"', style: GoogleFonts.dmSans(fontSize: 14, fontStyle: FontStyle.italic, color: gold.withOpacity(0.8))),
          ],
          const Divider(height: 24),
          Text(insight, style: GoogleFonts.dmSans(fontSize: 13, height: 1.6, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Could not load today\'s data', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          GestureDetector(onTap: onRetry, child: Text('Try again', style: TextStyle(color: gold))),
        ],
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Complete your profile first"));
  }
}

class _ActionableGuidance extends StatelessWidget {
  final List<dynamic> toDo, avoid;
  final bool isDark;
  final Color gold;

  const _ActionableGuidance({required this.toDo, required this.avoid, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personalized Guidance', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: gold)),
          const SizedBox(height: 12),
          ...toDo.take(3).map((item) => _GuidelineRow(text: item.toString(), isPositive: true)),
          const SizedBox(height: 8),
          ...avoid.take(2).map((item) => _GuidelineRow(text: item.toString(), isPositive: false)),
        ],
      ),
    );
  }
}

class _GuidelineRow extends StatelessWidget {
  final String text;
  final bool isPositive;
  const _GuidelineRow({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(isPositive ? Icons.check_circle_outline : Icons.remove_circle_outline, 
               size: 14, color: isPositive ? Colors.green : Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 12))),
        ],
      ),
    );
  }
}

class _HourlyStrip extends StatelessWidget {
  final List<dynamic> hours;
  final int currentHour;
  final bool isDark;
  final Color gold;

  const _HourlyStrip({required this.hours, required this.currentHour, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Cosmic Timeline'),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final h = hours[i];
              final isNow = h['hour'] == currentHour;
              final type = h['classification'] ?? 'neutral';
              
              Color statusColor = type == 'best' ? Colors.green : (type == 'avoid' ? Colors.red : (type == 'caution' ? Colors.orange : gold));

              return Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isNow ? statusColor.withOpacity(0.1) : (isDark ? Colors.white10 : Colors.black12.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isNow ? statusColor : Colors.transparent, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${h['hour']}:00', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: isNow ? FontWeight.bold : FontWeight.normal)),
                    const SizedBox(height: 4),
                    Text(h['number']?.toString() ?? '?', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
                    const SizedBox(height: 2),
                    Icon(Icons.circle, size: 6, color: statusColor),
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
              period: '${_yr(maha['start'] ?? '')}–${_yr(maha['end'] ?? '')}',
              color: gold, isDark: isDark),
          Divider(color: border, thickness: 0.5, height: 20),
          _PRow(label: 'Antardasha', data: antar,
              period: '${_mo(antar['start'] ?? '')}–${_mo(antar['end'] ?? '')}',
              color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
          Divider(color: border, thickness: 0.5, height: 20),
          _PRow(label: 'Monthly', data: monthly,
              period: '${_dt(monthly['start'] ?? '')}–${_dt(monthly['end'] ?? '')}',
              color: const Color(0xFF6366F1), isDark: isDark),
        ],
      ),
    );
  }

  String _yr(String iso) => iso.isNotEmpty ? DateFormat('yyyy').format(DateTime.parse(iso)) : "N/A";
  String _mo(String iso) => iso.isNotEmpty ? DateFormat('MMM yy').format(DateTime.parse(iso)) : "N/A";
  String _dt(String iso) => iso.isNotEmpty ? DateFormat('d MMM').format(DateTime.parse(iso)) : "N/A";
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
    final num = data['number'] ?? 0;
    final planet = data['planet'] ?? 'Unknown';

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