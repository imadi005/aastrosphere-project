import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../auth/providers/user_provider.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final chartAsync = ref.watch(chartDataProvider);
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => const Center(child: Text('Error')),
      data: (user) {
        if (user == null) return const Center(child: Text('No profile'));
        return chartAsync.when(
          loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
          error: (e, _) => _ErrorView(onRetry: () => ref.refresh(chartDataProvider)),
          data: (data) => _ChartView(data: data, isDark: isDark, gold: gold, name: user.name),
        );
      },
    );
  }
}

class _ChartView extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  final String name;

  const _ChartView({required this.data, required this.isDark, required this.gold, required this.name});

  @override
  Widget build(BuildContext context) {
    final basic = data['basic'] as int;
    final destiny = data['destiny'] as int;
    final basicPlanet = data['basicPlanet'] as String;
    final destinyPlanet = data['destinyPlanet'] as String;
    final supportive = (data['supportive'] as List<dynamic>).cast<int>();
    final maha = data['maha'] as Map<String, dynamic>;
    final antar = data['antar'] as Map<String, dynamic>;
    final monthly = data['monthly'] as Map<String, dynamic>;
    final grid = data['grid'] as List<dynamic>;
    final karmic = data['karmic'] as Map<String, dynamic>;
    final lucky = data['lucky'] as Map<String, dynamic>? ?? {};
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Ank Kundli',
              style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold)),
          Text('${name.split(' ').first}\'s numerological blueprint',
              style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary)),
          const SizedBox(height: 20),

          // Core Numbers
          SectionLabel('Core Numbers'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _CoreNumberCard(
                label: 'Basic', sublabel: 'Inner Self',
                number: basic, planet: basicPlanet,
                gold: gold, isDark: isDark,
              )),
              const SizedBox(width: 10),
              Expanded(child: _CoreNumberCard(
                label: 'Destiny', sublabel: 'Life Path',
                number: destiny, planet: destinyPlanet,
                gold: gold, isDark: isDark,
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

          // The Grid
          SectionLabel('Numerological Grid'),
          const SizedBox(height: 8),
          _GridWidget(grid: grid, isDark: isDark, gold: gold),
          const SizedBox(height: 20),

          // Running Periods
          SectionLabel('Running Periods'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PeriodRow(label: 'Maha Dasha', number: maha['number'] as int,
                    planet: maha['planet'] as String,
                    period: '${_yr(maha['start'])} – ${_yr(maha['end'])}',
                    color: gold, isDark: isDark),
                Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 20, thickness: 0.5),
                _PeriodRow(label: 'Antar Dasha', number: antar['number'] as int,
                    planet: antar['planet'] as String,
                    period: '${_mo(antar['start'])} – ${_mo(antar['end'])}',
                    color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
                Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 20, thickness: 0.5),
                _PeriodRow(label: 'Monthly', number: monthly['number'] as int,
                    planet: monthly['planet'] as String,
                    period: '${_dt(monthly['start'])} – ${_dt(monthly['end'])}',
                    color: const Color(0xFF6366F1), isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lucky Info
          if (lucky.isNotEmpty) ...[
            SectionLabel('Lucky for You'),
            const SizedBox(height: 8),
            AstroCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _LuckyRow('Colors', (lucky['colors'] as List<dynamic>).join(', '), isDark),
                  Divider(color: border, height: 16, thickness: 0.5),
                  _LuckyRow('Direction', lucky['direction'] as String? ?? '', isDark),
                  Divider(color: border, height: 16, thickness: 0.5),
                  _LuckyRow('Lucky Numbers', (lucky['luckyNumbers'] as List<dynamic>).join(' & '), isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Karmic debt
          if (karmic['hasKarmicDebt'] == true) ...[
            SectionLabel('Karmic Insight'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A0A0A) : const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(karmic['title'] as String? ?? '',
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
                          color: Colors.redAccent)),
                  const SizedBox(height: 6),
                  Text(karmic['remedy'] as String? ?? '',
                      style: GoogleFonts.dmSans(fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _yr(String iso) {
    try { return DateTime.parse(iso).year.toString(); } catch (_) { return ''; }
  }
  String _mo(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month-1]} ${d.year.toString().substring(2)}';
    } catch (_) { return ''; }
  }
  String _dt(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month-1]}';
    } catch (_) { return ''; }
  }
}

// ─── Grid Widget ──────────────────────────────────────────────
class _GridWidget extends StatelessWidget {
  final List<dynamic> grid;
  final bool isDark;
  final Color gold;

  const _GridWidget({required this.grid, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;

    // Planet labels for grid positions
    const planetLabels = [
      ['Jupiter', 'Sun', 'Mars'],
      ['Venus', 'Ketu', 'Mercury'],
      ['Moon', 'Saturn', 'Rahu'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        children: List.generate(3, (row) {
          return Column(
            children: [
              Row(
                children: List.generate(3, (col) {
                  final cell = (grid[row] as List<dynamic>)[col] as List<dynamic>;
                  final isLast = col == 2;
                  final isLastRow = row == 2;
                  final planet = planetLabels[row][col];

                  return Expanded(
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border(
                          right: isLast ? BorderSide.none : BorderSide(color: border, width: 0.5),
                          bottom: isLastRow ? BorderSide.none : BorderSide(color: border, width: 0.5),
                        ),
                      ),
                      child: _GridCell(
                        cell: cell, planet: planet,
                        isDark: isDark, gold: gold,
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final List<dynamic> cell;
  final String planet;
  final bool isDark;
  final Color gold;

  const _GridCell({required this.cell, required this.planet, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    if (cell.isEmpty) {
      return Center(
        child: Text('—', style: GoogleFonts.dmSans(fontSize: 18, color: textTertiary)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            children: cell.map((item) {
              final m = item as Map<String, dynamic>;
              final highlight = m['highlight'] as String;
              Color numColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
              if (highlight == 'maha') numColor = gold;
              if (highlight == 'antar') numColor = isDark ? AppColors.successDark : AppColors.success;
              if (highlight == 'monthly') numColor = const Color(0xFF6366F1);

              return Text(
                '${m['value']}',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22, fontWeight: FontWeight.w400, color: numColor,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 2),
          Text(planet,
              style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Core number card ─────────────────────────────────────────
class _CoreNumberCard extends StatelessWidget {
  final String label, sublabel, planet;
  final int number;
  final Color gold;
  final bool isDark;

  const _CoreNumberCard({
    required this.label, required this.sublabel, required this.number,
    required this.planet, required this.gold, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
          Text(sublabel, style: GoogleFonts.dmSans(fontSize: 9, color: secondary)),
          const SizedBox(height: 6),
          Text('$number',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 34, fontWeight: FontWeight.w300, color: gold)),
          Text(planet, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
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
    final bg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supportive', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
          Text('Numbers', style: GoogleFonts.dmSans(fontSize: 9, color: secondary)),
          const SizedBox(height: 6),
          Row(
            children: numbers.map((n) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text('$n',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 28, fontWeight: FontWeight.w300, color: gold)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final String label, planet, period;
  final int number;
  final Color color;
  final bool isDark;

  const _PeriodRow({required this.label, required this.number, required this.planet,
      required this.period, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Row(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('$number',
              style: GoogleFonts.cormorantGaramond(fontSize: 18, color: color))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
            Text(planet, style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
          ],
        )),
        Text(period, style: GoogleFonts.dmSans(fontSize: 11, color: tertiary)),
      ],
    );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        Text(value, style: GoogleFonts.dmSans(fontSize: 13,
            fontWeight: FontWeight.w500, color: primary)),
      ],
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
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Could not load chart',
            style: GoogleFonts.dmSans(fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        const SizedBox(height: 16),
        GestureDetector(onTap: onRetry,
            child: Text('Try again', style: GoogleFonts.dmSans(fontSize: 13, color: gold))),
      ],
    ));
  }
}
