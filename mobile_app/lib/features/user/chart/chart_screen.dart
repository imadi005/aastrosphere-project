import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/user_provider.dart';

class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  DateTime? _selectedDate;
  int? _selectedHour;
  Map<String, dynamic>? _customChartData;
  bool _loadingCustom = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final userAsync = ref.watch(userProfileProvider);
    final chartAsync = ref.watch(chartDataProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => const Center(child: Text('Error')),
      data: (user) {
        if (user == null) return const Center(child: Text('No profile'));
        return chartAsync.when(
          loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
          error: (e, _) => _ErrorView(onRetry: () => ref.refresh(chartDataProvider)),
          data: (todayData) {
            final displayData = _customChartData ?? todayData;
            return _ChartView(
              data: displayData,
              isDark: isDark,
              gold: gold,
              name: user.name,
              dob: user.dob,
              isCustomDate: _customChartData != null,
              selectedDate: _selectedDate,
              selectedHour: _selectedHour,
              loadingCustom: _loadingCustom,
              onSelectDate: () => _showDatePicker(context, user, isDark, gold),
              onClearDate: () => setState(() {
                _customChartData = null;
                _selectedDate = null;
                _selectedHour = null;
              }),
            );
          },
        );
      },
    );
  }

  Future<void> _showDatePicker(BuildContext ctx, dynamic user, bool isDark, Color gold) async {
    DateTime? pickedDate;
    int? pickedHour;

    // Step 1: Date picker
    pickedDate = await showDatePicker(
      context: ctx,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: gold,
                  onPrimary: Colors.black,
                  surface: AppColors.bgCardDark,
                  onSurface: AppColors.textPrimaryDark,
                )
              : ColorScheme.light(
                  primary: gold,
                  onPrimary: Colors.black,
                  surface: AppColors.bgCardLight,
                  onSurface: AppColors.textPrimaryLight,
                ),
          textTheme: Theme.of(context).textTheme,
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    // Step 2: Optional time picker
    if (!mounted) return;
    final wantsTime = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final dIsDark = Theme.of(dCtx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: dIsDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          title: Text('Add time?',
              style: GoogleFonts.dmSans(fontSize: 14,
                  color: dIsDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          content: Text('Add a specific hour to see the hourly chart as well.',
              style: GoogleFonts.dmSans(fontSize: 12,
                  color: dIsDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false),
                child: Text('Skip', style: GoogleFonts.dmSans(
                    color: dIsDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
            TextButton(onPressed: () => Navigator.pop(dCtx, true),
                child: Text('Add Hour', style: GoogleFonts.dmSans(color: gold))),
          ],
        );
      },
    );

    if (wantsTime == true && mounted) {
      final picked = await showTimePicker(
        context: ctx,
        initialTime: TimeOfDay(hour: _selectedHour ?? DateTime.now().hour, minute: 0),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: gold,
                    onPrimary: Colors.black,
                    surface: AppColors.bgCardDark,
                    onSurface: AppColors.textPrimaryDark,
                  )
                : ColorScheme.light(
                    primary: gold,
                    onPrimary: Colors.black,
                    surface: AppColors.bgCardLight,
                    onSurface: AppColors.textPrimaryLight,
                  ),
          ),
          child: child!,
        ),
      );
      if (picked != null) pickedHour = picked.hour;
    }

    // Fetch the chart
    setState(() => _loadingCustom = true);
    try {
      final dob = _dobToIso(user.dob as DateTime);
      final dateStr = pickedDate!.toIso8601String();
      // Use local hour for today, specific picked hour otherwise
      final isToday = pickedDate!.year == DateTime.now().year &&
          pickedDate!.month == DateTime.now().month &&
          pickedDate!.day == DateTime.now().day;
      final effectiveHour = pickedHour ?? (isToday ? DateTime.now().hour : null);
      final data = await ApiService.getChartForDate(dob, dateStr, effectiveHour);
      setState(() {
        _customChartData = data;
        _selectedDate = pickedDate;
        _selectedHour = pickedHour;
        _loadingCustom = false;
      });
    } catch (e) {
      setState(() => _loadingCustom = false);
    }
  }

  String _dobToIso(DateTime dob) =>
      '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
}

class _ChartView extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark, isCustomDate, loadingCustom;
  final Color gold;
  final String name;
  final dynamic dob;
  final DateTime? selectedDate;
  final int? selectedHour;
  final VoidCallback onSelectDate, onClearDate;

  const _ChartView({
    required this.data, required this.isDark, required this.gold,
    required this.name, required this.dob, required this.isCustomDate,
    required this.selectedDate, required this.selectedHour,
    required this.loadingCustom, required this.onSelectDate, required this.onClearDate,
  });

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
    final daily = data['daily'] as int?;
    final hourly = data['hourly'] as int?;
    final grid = data['grid'] as List<dynamic>;
    final karmic = data['karmic'] as Map<String, dynamic>;
    final lucky = data['lucky'] as Map<String, dynamic>? ?? {};
    final targetDate = data['target_date'] as String?;
    final targetHour = data['target_hour'] as int?;

    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Header title
    String chartTitle;
    if (isCustomDate && selectedDate != null) {
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      chartTitle = '${selectedDate!.day} ${months[selectedDate!.month - 1]} ${selectedDate!.year}';
      if (selectedHour != null) {
        final h12 = selectedHour! == 0 ? 12 : selectedHour! > 12 ? selectedHour! - 12 : selectedHour!;
        final ampm = selectedHour! < 12 ? 'AM' : 'PM';
        chartTitle += ' at $h12 $ampm';
      }
    } else {
      chartTitle = 'Your Chart Today';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(chartTitle,
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold)),
              Text('${name.split(' ').first}\'s numerological blueprint',
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
            ])),
            // Calendar selector button
            GestureDetector(
              onTap: loadingCustom ? null : onSelectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gold.withOpacity(0.3), width: 0.5),
                ),
                child: loadingCustom
                    ? SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: gold))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.calendar_month_outlined, size: 14, color: gold),
                        const SizedBox(width: 5),
                        Text('Any Date', style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w500, color: gold)),
                      ]),
              ),
            ),
            if (isCustomDate) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClearDate,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.dangerDark : AppColors.danger).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.close, size: 14,
                      color: isDark ? AppColors.dangerDark : AppColors.danger),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 16),

          // ── Grid ──────────────────────────────────────────────────
          SectionLabel('Numerological Grid'),
          const SizedBox(height: 8),
          _GridWidget(grid: grid, isDark: isDark, gold: gold),
          const SizedBox(height: 10),

          // ── Legend ────────────────────────────────────────────────
          _GridLegend(
            maha: maha['number'] as int,
            antar: antar['number'] as int,
            monthly: monthly['number'] as int,
            daily: daily,
            hourly: hourly,
            isDark: isDark,
            gold: gold,
          ),
          const SizedBox(height: 8),

          const SizedBox(height: 16),

          // ── Running Periods ───────────────────────────────────────
          SectionLabel('Running Periods'),
          const SizedBox(height: 8),
          AstroCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: [
              _PeriodRow(label: 'Maha Dasha', number: maha['number'] as int,
                  planet: maha['planet'] as String,
                  period: '${_yr(maha['start'])} – ${_yr(maha['end'])}',
                  color: gold, isDark: isDark),
              Divider(color: border, height: 16, thickness: 0.5),
              _PeriodRow(label: 'Antar Dasha', number: antar['number'] as int,
                  planet: antar['planet'] as String,
                  period: '${_mo(antar['start'])} – ${_mo(antar['end'])}',
                  color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
              Divider(color: border, height: 16, thickness: 0.5),
              _PeriodRow(label: 'Monthly', number: monthly['number'] as int,
                  planet: monthly['planet'] as String,
                  period: '${_dt(monthly['start'])} – ${_dt(monthly['end'])}',
                  color: const Color(0xFF6366F1), isDark: isDark),
              if (daily != null) ...[
                Divider(color: border, height: 16, thickness: 0.5),
                _PeriodRow(label: 'Daily', number: daily,
                    planet: '',
                    period: targetDate ?? '',
                    color: const Color(0xFF06B6D4), isDark: isDark),
              ],
              if (hourly != null) ...[
                Divider(color: border, height: 16, thickness: 0.5),
                _PeriodRow(label: 'Hourly', number: hourly,
                    planet: '',
                    period: targetHour != null
                        ? '${targetHour > 12 ? targetHour - 12 : targetHour == 0 ? 12 : targetHour}:00 ${targetHour < 12 ? 'AM' : 'PM'}'
                        : '',
                    color: const Color(0xFFF59E0B), isDark: isDark),
              ],
            ]),
          ),
          const SizedBox(height: 16),

          // ── Core Numbers ──────────────────────────────────────────
          SectionLabel('Core Numbers'),
          const SizedBox(height: 8),
          Row(children: [
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
          ]),
          const SizedBox(height: 16),

          // ── Lucky & Karmic ────────────────────────────────────────
          if (lucky.isNotEmpty || karmic.isNotEmpty) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (lucky['color'] != null)
                Expanded(child: _InfoCard(
                  title: 'Lucky Color',
                  value: lucky['color'] as String? ?? '',
                  isDark: isDark, gold: gold,
                )),
              if (lucky['color'] != null) const SizedBox(width: 10),
              Expanded(child: _InfoCard(
                title: 'Karmic Debt',
                value: karmic['hasKarmicDebt'] == true
                    ? (karmic['title'] as String? ?? 'Karmic Debt')
                    : 'None',
                isDark: isDark, gold: gold,
              )),
            ]),
          ],
        ],
      ),
    );
  }

  String _yr(dynamic s) {
    if (s == null) return '';
    return DateTime.parse(s.toString()).year.toString();
  }

  String _mo(dynamic s) {
    if (s == null) return '';
    final d = DateTime.parse(s.toString());
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month-1]} ${d.year}';
  }

  String _dt(dynamic s) {
    if (s == null) return '';
    final d = DateTime.parse(s.toString());
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month-1]}';
  }
}


// ─── Grid Legend ──────────────────────────────────────────────────────────────
class _GridLegend extends StatelessWidget {
  final int maha, antar, monthly;
  final int? daily, hourly;
  final bool isDark;
  final Color gold;

  const _GridLegend({
    required this.maha, required this.antar, required this.monthly,
    this.daily, this.hourly, required this.isDark, required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    final items = <Map<String, dynamic>>[
      {'label': 'Maha', 'number': maha, 'color': gold},
      {'label': 'Antar', 'number': antar, 'color': successColor},
      {'label': 'Monthly', 'number': monthly, 'color': const Color(0xFF6366F1)},
      if (daily != null) {'label': 'Daily', 'number': daily, 'color': const Color(0xFF06B6D4)},
      if (hourly != null) {'label': 'Hourly', 'number': hourly, 'color': const Color(0xFFF59E0B)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) {
        final color = item['color'] as Color;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 5),
          Text('${item['label']} (${item['number']})',
              style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
        ]);
      }).toList(),
    );
  }
}

// ─── Grid Widget ──────────────────────────────────────────────────────────────
class _GridWidget extends StatelessWidget {
  final List<dynamic> grid;
  final bool isDark;
  final Color gold;

  const _GridWidget({required this.grid, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;

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
          return Column(children: [
            Row(children: List.generate(3, (col) {
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
                  child: _GridCell(cell: cell, planet: planet, isDark: isDark, gold: gold),
                ),
              );
            })),
          ]);
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
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    if (cell.isEmpty) {
      return Center(child: Text('—',
          style: GoogleFonts.dmSans(fontSize: 18, color: textTertiary)));
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
              final highlight = m['highlight'] as String? ?? '';
              Color numColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
              if (highlight == 'maha')    numColor = gold;
              if (highlight == 'antar')   numColor = successColor;
              if (highlight == 'monthly') numColor = const Color(0xFF6366F1);
              if (highlight == 'daily')   numColor = const Color(0xFF06B6D4);  // cyan
              if (highlight == 'hourly')  numColor = const Color(0xFFF59E0B);  // amber

              return Text('${m['value']}',
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

// ─── Period Row ───────────────────────────────────────────────────────────────
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
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Row(children: [
      Container(width: 6, height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
        if (period.isNotEmpty)
          Text(period, style: GoogleFonts.dmSans(fontSize: 10, color: secondary.withOpacity(0.6))),
      ])),
      Row(children: [
        Text('$number', style: GoogleFonts.cormorantGaramond(
            fontSize: 24, color: color, height: 1)),
        if (planet.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(planet, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
        ],
      ]),
    ]);
  }
}

// ─── Core Number Card ─────────────────────────────────────────────────────────
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
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Text('$number', style: GoogleFonts.cormorantGaramond(
            fontSize: 36, color: gold, height: 1)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          Text(sublabel, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
          Text(planet, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
        ])),
      ]),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title, value;
  final bool isDark;
  final Color gold;

  const _InfoCard({required this.title, required this.value,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return AstroCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w500, color: primary)),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Could not load chart'),
      const SizedBox(height: 12),
      GestureDetector(onTap: onRetry, child: const Text('Retry')),
    ]));
  }
}
