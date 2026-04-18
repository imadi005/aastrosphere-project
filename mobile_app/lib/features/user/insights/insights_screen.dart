import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bgPrimary = isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight;

    return Column(
      children: [
        Container(
          color: bgPrimary,
          child: TabBar(
            controller: _tab,
            labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
            labelColor: gold,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: gold,
            indicatorWeight: 1.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: border,
            tabs: const [Tab(text: 'WEEKLY'), Tab(text: 'MONTHLY'), Tab(text: 'YEARLY')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _WeeklyTab(isDark: isDark, gold: gold),
              _MonthlyTab(isDark: isDark, gold: gold),
              _YearlyTab(isDark: isDark, gold: gold),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── WEEKLY ───────────────────────────────────────────────────────────────────
class _WeeklyTab extends ConsumerWidget {
  final bool isDark;
  final Color gold;
  const _WeeklyTab({required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(weeklyInsightsProvider).when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => _RetryView(onRetry: () => ref.refresh(weeklyInsightsProvider), gold: gold, isDark: isDark),
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.refresh(weeklyInsightsProvider),
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview
              _OverviewCard(text: data['overview'] as String? ?? '', gold: gold, isDark: isDark, label: 'THIS WEEK'),
              const SizedBox(height: 14),

              // Opps + Watch
              _OppWatchRow(
                opps: (data['opportunities'] as List? ?? []).cast<String>(),
                watchOuts: (data['watch_out'] as List? ?? []).cast<String>(),
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Domain signals — full text, no truncation
              SectionLabel('This Week'),
              const SizedBox(height: 8),
              _SignalList(items: [
                if ((data['money_this_week'] as String? ?? '').isNotEmpty)
                  _SignalItem(icon: Icons.account_balance_wallet_outlined, label: 'Money', text: data['money_this_week'] as String, color: const Color(0xFFF59E0B)),
                if ((data['love_this_week'] as String? ?? '').isNotEmpty)
                  _SignalItem(icon: Icons.favorite_border, label: 'Love', text: data['love_this_week'] as String, color: Colors.pinkAccent),
                if ((data['health_this_week'] as String? ?? '').isNotEmpty)
                  _SignalItem(icon: Icons.monitor_heart_outlined, label: 'Health', text: data['health_this_week'] as String, color: Colors.teal),
              ], isDark: isDark),


              // Days breakdown
              if ((data['days_breakdown'] as List? ?? []).isNotEmpty) ...[
                const SizedBox(height: 14),
                _DaysBreakdown(
                  days: (data['days_breakdown'] as List).cast<Map<String, dynamic>>(),
                  isDark: isDark, gold: gold,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MONTHLY ──────────────────────────────────────────────────────────────────
class _MonthlyTab extends ConsumerWidget {
  final bool isDark;
  final Color gold;
  const _MonthlyTab({required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(monthlyInsightsProvider).when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => _RetryView(onRetry: () => ref.refresh(monthlyInsightsProvider), gold: gold, isDark: isDark),
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.refresh(monthlyInsightsProvider),
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OverviewCard(
                text: data['overview'] as String? ?? '',
                gold: gold, isDark: isDark,
                label: (data['month_name'] as String? ?? 'THIS MONTH').toUpperCase(),
              ),
              const SizedBox(height: 14),

              // Phase timeline
              SectionLabel('Month Arc'),
              const SizedBox(height: 8),
              _PhaseTimeline(phases: data['phases'] as List? ?? [], isDark: isDark, gold: gold),
              const SizedBox(height: 14),

              // Opps + Watch
              _OppWatchRow(
                opps: (data['opportunities'] as List? ?? []).cast<String>(),
                watchOuts: (data['watch_out'] as List? ?? []).cast<String>(),
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Domain cards — expandable
              SectionLabel('Life Domains'),
              const SizedBox(height: 8),
              _ExpandableDomain(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Money',
                signal: (data['finance'] as Map?)?['signal'] as String? ?? '',
                extra: (data['finance'] as Map?)?['action'] as String?,
                extraLabel: 'Do this',
                color: const Color(0xFFF59E0B), isDark: isDark,
              ),
              _ExpandableDomain(
                icon: Icons.favorite_border,
                title: 'Relationships',
                signal: (data['relationships'] as Map?)?['signal'] as String? ?? '',
                extra: (data['relationships'] as Map?)?['what_to_watch'] as String?,
                extraLabel: 'Watch for',
                color: Colors.pinkAccent, isDark: isDark,
              ),
              _ExpandableDomain(
                icon: Icons.monitor_heart_outlined,
                title: 'Health',
                signal: (data['health'] as Map?)?['watch'] as String? ?? '',
                extra: (data['health'] as Map?)?['advice'] as String?,
                extraLabel: 'Practice',
                color: Colors.teal, isDark: isDark,
              ),
              _ExpandableDomain(
                icon: Icons.trending_up_outlined,
                title: 'Career',
                signal: (data['career'] as Map?)?['signal'] as String? ?? '',
                extra: (data['career'] as Map?)?['best_week'] as String?,
                extraLabel: 'Timing',
                color: Colors.blueAccent, isDark: isDark,
              ),

              // Weeks breakdown
              if ((data['weeks_breakdown'] as List? ?? []).isNotEmpty) ...[
                const SizedBox(height: 14),
                _WeeksBreakdown(
                  weeks: (data['weeks_breakdown'] as List).cast<Map<String, dynamic>>(),
                  isDark: isDark, gold: gold,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── YEARLY ───────────────────────────────────────────────────────────────────
class _YearlyTab extends ConsumerWidget {
  final bool isDark;
  final Color gold;
  const _YearlyTab({required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(yearlyInsightsProvider).when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => _RetryView(onRetry: () => ref.refresh(yearlyInsightsProvider), gold: gold, isDark: isDark),
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.refresh(yearlyInsightsProvider),
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year title + one liner
              _YearTitleCard(
                title: data['title'] as String? ?? '',
                oneLiner: data['year_in_one_line'] as String?,
                gold: gold, isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Month windows
              if (data['best_months'] != null || data['risky_months'] != null)
                _MonthWindowsCard(
                  bestMonths: data['best_months'] as String? ?? '',
                  riskyMonths: data['risky_months'] as String? ?? '',
                  isDark: isDark, gold: gold,
                ),
              const SizedBox(height: 14),

              // Current chapter
              if (data['current_chapter'] != null)
                _CurrentChapterCard(
                  chapter: data['current_chapter'] as Map<String, dynamic>,
                  isDark: isDark, gold: gold,
                ),
              const SizedBox(height: 14),

              // Domain cards with pattern
              SectionLabel('Your Year'),
              const SizedBox(height: 8),
              _YearlyDomainCard(
                icon: Icons.account_balance_wallet_outlined, title: 'Money',
                yearSignal: (data['finance'] as Map?)?['year_signal'] as String? ?? '',
                yourPattern: (data['finance'] as Map?)?['your_pattern'] as String?,
                color: const Color(0xFFF59E0B), isDark: isDark,
              ),
              _YearlyDomainCard(
                icon: Icons.favorite_border, title: 'Relationships',
                yearSignal: (data['relationships'] as Map?)?['year_signal'] as String? ?? '',
                yourPattern: (data['relationships'] as Map?)?['your_pattern'] as String?,
                color: Colors.pinkAccent, isDark: isDark,
              ),
              _YearlyDomainCard(
                icon: Icons.monitor_heart_outlined, title: 'Health',
                yearSignal: (data['health'] as Map?)?['watch'] as String? ?? '',
                yourPattern: (data['health'] as Map?)?['your_pattern'] as String?,
                color: Colors.teal, isDark: isDark,
              ),
              _YearlyDomainCard(
                icon: Icons.trending_up_outlined, title: 'Career',
                yearSignal: (data['career'] as Map?)?['year_signal'] as String? ?? '',
                yourPattern: (data['career'] as Map?)?['your_pattern'] as String?,
                color: Colors.blueAccent, isDark: isDark,
              ),

              // Months breakdown
              if ((data['months_breakdown'] as List? ?? []).isNotEmpty) ...[
                const SizedBox(height: 14),
                _MonthsBreakdown(
                  months: (data['months_breakdown'] as List).cast<Map<String, dynamic>>(),
                  isDark: isDark, gold: gold,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _OverviewCard extends StatelessWidget {
  final String text, label;
  final Color gold;
  final bool isDark;
  const _OverviewCard({required this.text, required this.label, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return AstroCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, size: 12, color: gold),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
          ]),
          const SizedBox(height: 10),
          Text(text, style: GoogleFonts.dmSans(fontSize: 14, color: primary, height: 1.65)),
        ],
      ),
    );
  }
}

// Day pills row — visual, quick to scan
class _DayPillsRow extends StatelessWidget {
  final List<dynamic> bestDays, heavyDays;
  final bool isDark;
  final Color gold;
  const _DayPillsRow({required this.bestDays, required this.heavyDays, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final warningColor = const Color(0xFFF59E0B);
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      children: [
        // Best days
        ...bestDays.take(2).map((d) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: successColor.withOpacity(0.3), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_outline, size: 12, color: successColor),
              const SizedBox(width: 5),
              Text(d['day'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: successColor)),
            ]),
          ),
        )),
        // Heavy days
        ...heavyDays.take(2).map((d) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: warningColor.withOpacity(0.3), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.warning_amber_outlined, size: 12, color: warningColor),
              const SizedBox(width: 5),
              Text(d['day'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: warningColor)),
            ]),
          ),
        )),
      ],
    );
  }
}

// Signal list — icon + label on one line, text below, no truncation
class _SignalItem {
  final IconData icon;
  final String label, text;
  final Color color;
  const _SignalItem({required this.icon, required this.label, required this.text, required this.color});
}

class _SignalList extends StatelessWidget {
  final List<_SignalItem> items;
  final bool isDark;
  const _SignalList({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (i > 0) Divider(color: border, height: 16, thickness: 0.5),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(item.icon, size: 14, color: item.color),
                      const SizedBox(width: 6),
                      Text(item.label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: item.color)),
                    ]),
                    const SizedBox(height: 5),
                    Text(item.text, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Expandable domain card — tap to expand
class _ExpandableDomain extends StatefulWidget {
  final IconData icon;
  final String title, signal;
  final String? extra, extraLabel;
  final Color color;
  final bool isDark;
  const _ExpandableDomain({required this.icon, required this.title,
      required this.signal, this.extra, this.extraLabel,
      required this.color, required this.isDark});

  @override
  State<_ExpandableDomain> createState() => _ExpandableDomainState();
}

class _ExpandableDomainState extends State<_ExpandableDomain> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    final hasExtra = widget.extra != null && widget.extra!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: hasExtra ? () => setState(() => _expanded = !_expanded) : null,
        child: AstroCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 30, height: 30,
                      decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(widget.icon, size: 14, color: widget.color)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: primary))),
                  if (hasExtra)
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: secondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.signal, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
              if (_expanded && hasExtra) ...[
                const SizedBox(height: 8),
                Divider(color: border, height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${widget.extraLabel}: ', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: widget.color)),
                  Expanded(child: Text(widget.extra!, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4))),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Opps + Watch row
class _OppWatchRow extends StatelessWidget {
  final List<String> opps, watchOuts;
  final bool isDark;
  const _OppWatchRow({required this.opps, required this.watchOuts, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (opps.isNotEmpty) Expanded(child: _BulletBox(title: 'OPPORTUNITIES', items: opps, color: successColor, isDark: isDark)),
      if (opps.isNotEmpty && watchOuts.isNotEmpty) const SizedBox(width: 10),
      if (watchOuts.isNotEmpty) Expanded(child: _BulletBox(title: 'WATCH-OUTS', items: watchOuts, color: dangerColor, isDark: isDark)),
    ]);
  }
}

class _BulletBox extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final bool isDark;
  const _BulletBox({required this.title, required this.items, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: color)),
          const SizedBox(height: 8),
          ...items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: color))),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4))),
            ]),
          )),
        ],
      ),
    );
  }
}

// Phase timeline
class _PhaseTimeline extends StatelessWidget {
  final List<dynamic> phases;
  final bool isDark;
  final Color gold;
  const _PhaseTimeline({required this.phases, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return AstroCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: phases.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value as Map<String, dynamic>;
          final isCurrent = p['current'] as bool? ?? false;
          return Column(
            children: [
              if (i > 0) Divider(color: border, height: 16, thickness: 0.5),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isCurrent ? gold.withOpacity(0.15) : (isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent ? Border.all(color: gold.withOpacity(0.4), width: 1) : null,
                    ),
                    child: Center(child: Text('${i+1}', style: GoogleFonts.cormorantGaramond(fontSize: 14, color: isCurrent ? gold : secondary)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(p['label'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: isCurrent ? gold : primary)),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: gold)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(p['theme'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.45)),
                ])),
              ]),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Year title card
class _YearTitleCard extends StatelessWidget {
  final String title;
  final String? oneLiner;
  final Color gold;
  final bool isDark;
  const _YearTitleCard({required this.title, this.oneLiner, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return AstroCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold, fontWeight: FontWeight.w400)),
          if (oneLiner != null) ...[
            const SizedBox(height: 8),
            Text('"$oneLiner"', style: GoogleFonts.cormorantGaramond(fontSize: 15, color: gold.withOpacity(0.7), fontStyle: FontStyle.italic, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

// Month windows
class _MonthWindowsCard extends StatelessWidget {
  final String bestMonths, riskyMonths;
  final Color gold;
  final bool isDark;
  const _MonthWindowsCard({required this.bestMonths, required this.riskyMonths, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return AstroCard(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        if (bestMonths.isNotEmpty)
          _WindowRow(dot: successColor, text: bestMonths, secondary: secondary),
        if (bestMonths.isNotEmpty && riskyMonths.isNotEmpty)
          Divider(color: border, height: 14, thickness: 0.5),
        if (riskyMonths.isNotEmpty)
          _WindowRow(dot: dangerColor, text: riskyMonths, secondary: secondary),
      ]),
    );
  }
}

class _WindowRow extends StatelessWidget {
  final Color dot, secondary;
  final String text;
  const _WindowRow({required this.dot, required this.text, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 5),
          child: Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dot))),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
    ]);
  }
}

// Current chapter card
class _CurrentChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final Color gold;
  final bool isDark;
  const _CurrentChapterCard({required this.chapter, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.hourglass_bottom_outlined, size: 13, color: gold),
          const SizedBox(width: 6),
          Text('YOUR CURRENT CHAPTER', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
        ]),
        const SizedBox(height: 10),
        Text(chapter['what_is_actually_happening'] as String? ?? '',
            style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.6)),
        if (chapter['the_gift'] != null) ...[
          const SizedBox(height: 10),
          Divider(color: border, height: 1, thickness: 0.5),
          const SizedBox(height: 8),
          _ChapterRow(dot: successColor, label: 'The gift', text: chapter['the_gift'] as String, secondary: secondary),
        ],
        if (chapter['the_trap'] != null) ...[
          const SizedBox(height: 6),
          _ChapterRow(dot: dangerColor, label: 'The trap', text: chapter['the_trap'] as String, secondary: secondary),
        ],
      ]),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final Color dot, secondary;
  final String label, text;
  const _ChapterRow({required this.dot, required this.label, required this.text, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 4),
          child: Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: dot))),
      const SizedBox(width: 8),
      Expanded(child: RichText(text: TextSpan(
        style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5),
        children: [
          TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: dot)),
          TextSpan(text: text),
        ],
      ))),
    ]);
  }
}

// Yearly domain card
class _YearlyDomainCard extends StatelessWidget {
  final IconData icon;
  final String title, yearSignal;
  final String? yourPattern;
  final Color color;
  final bool isDark;
  const _YearlyDomainCard({required this.icon, required this.title,
      required this.yearSignal, this.yourPattern,
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AstroCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 30, height: 30,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: color)),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
          ]),
          const SizedBox(height: 8),
          Text(yearSignal, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
          if (yourPattern != null && yourPattern!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(color: border, height: 1, thickness: 0.5),
            const SizedBox(height: 6),
            Text(yourPattern!, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4, fontStyle: FontStyle.italic)),
          ],
        ]),
      ),
    );
  }
}


class _RetryView extends StatelessWidget {
  final VoidCallback onRetry;
  final Color gold;
  final bool isDark;
  const _RetryView({required this.onRetry, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Could not load insights', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
      const SizedBox(height: 12),
      GestureDetector(onTap: onRetry, child: Text('Retry', style: GoogleFonts.dmSans(fontSize: 13, color: gold))),
    ]));
  }
}


// ─── Days breakdown (weekly) ──────────────────────────────────────────────────
class _DaysBreakdown extends StatefulWidget {
  final List<Map<String, dynamic>> days;
  final bool isDark;
  final Color gold;
  const _DaysBreakdown({required this.days, required this.isDark, required this.gold});

  @override
  State<_DaysBreakdown> createState() => _DaysBreakdownState();
}

class _DaysBreakdownState extends State<_DaysBreakdown> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = widget.isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = widget.isDark ? AppColors.dangerDark : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('This Week'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: widget.days.asMap().entries.map((entry) {
              final i = entry.key;
              final day = entry.value;
              final isToday = day['is_today'] as bool? ?? false;
              final isOpen = _expanded == i;
              final label = day['label'] as String? ?? '';
              final quality = day['day_quality'] as String? ?? 'neutral';
              final dayName = day['day_name'] as String? ?? '';
              final dateLabel = day['date_label'] as String? ?? '';
              final headline = day['headline'] as String? ?? '';
              final goodFor = (day['good_for'] as List? ?? []).cast<String>();
              final watchOut = (day['watch_out'] as List? ?? []).cast<String>();
              final money = day['money'] as String? ?? '';
              final relationships = day['relationships'] as String? ?? '';
              // Quality color and label
              final successColor2 = widget.isDark ? AppColors.successDark : AppColors.success;
              final dangerColor2 = widget.isDark ? AppColors.dangerDark : AppColors.danger;
              final qualityColor = quality == 'good' ? successColor2
                  : quality == 'caution' ? const Color(0xFFF59E0B)
                  : quality == 'danger' ? dangerColor2
                  : (widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);
              final qualityText = quality == 'good' ? 'Good'
                  : quality == 'caution' ? 'Caution'
                  : quality == 'danger' ? 'Difficult'
                  : 'Neutral';

              return Column(children: [
                if (i > 0) Divider(color: border, height: 14, thickness: 0.5),
                GestureDetector(
                  onTap: () => setState(() => _expanded = isOpen ? null : i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(right: 7),
                              width: 6, height: 6,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.gold),
                            ),
                          Expanded(child: Text(dateLabel, style: GoogleFonts.dmSans(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isToday ? widget.gold : primary))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: qualityColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(qualityText, style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w600,
                                color: qualityColor)),
                          ),
                          const SizedBox(width: 8),
                          Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 14, color: secondary),
                        ]),
                        const SizedBox(height: 2),
                        Text(headline, style: GoogleFonts.dmSans(
                            fontSize: 11, color: secondary, fontStyle: FontStyle.italic)),
                        if (isOpen) ...[
                          const SizedBox(height: 10),
                          if (goodFor.isNotEmpty) ...[
                            Text('GOOD FOR', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 0.8, color: successColor)),
                            const SizedBox(height: 5),
                            ...goodFor.map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 4, height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(g, style: GoogleFonts.dmSans(
                                    fontSize: 12, color: primary, height: 1.4))),
                              ]),
                            )),
                          ],
                          if (watchOut.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('WATCH OUT', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 0.8, color: dangerColor)),
                            const SizedBox(height: 5),
                            ...watchOut.map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 4, height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(w, style: GoogleFonts.dmSans(
                                    fontSize: 12, color: secondary, height: 1.4))),
                              ]),
                            )),
                          ],
                          if (money.isNotEmpty || relationships.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Divider(color: border, height: 1, thickness: 0.5),
                            const SizedBox(height: 6),
                            if (money.isNotEmpty)
                              _MiniRow(icon: Icons.account_balance_wallet_outlined,
                                  text: money, color: const Color(0xFFF59E0B), secondary: secondary),
                            if (relationships.isNotEmpty)
                              _MiniRow(icon: Icons.favorite_border,
                                  text: relationships, color: Colors.pinkAccent, secondary: secondary),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Weeks breakdown (monthly) ────────────────────────────────────────────────
class _WeeksBreakdown extends StatefulWidget {
  final List<Map<String, dynamic>> weeks;
  final bool isDark;
  final Color gold;
  const _WeeksBreakdown({required this.weeks, required this.isDark, required this.gold});

  @override
  State<_WeeksBreakdown> createState() => _WeeksBreakdownState();
}

class _WeeksBreakdownState extends State<_WeeksBreakdown> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = widget.isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = widget.isDark ? AppColors.dangerDark : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Week by Week'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: widget.weeks.asMap().entries.map((entry) {
              final i = entry.key;
              final week = entry.value;
              final isCurrent = week['is_current'] as bool? ?? false;
              final isOpen = _expanded == i;
              final label = week['label'] as String? ?? '';
              final dateLabel = week['date_label'] as String? ?? '';
              final character = week['character'] as String? ?? '';
              final goodFor = (week['good_for'] as List? ?? []).cast<String>();
              final watchOut = (week['watch_out'] as List? ?? []).cast<String>();
              final finance = week['finance'] as String? ?? '';
              final relationships = week['relationships'] as String? ?? '';

              return Column(children: [
                if (i > 0) Divider(color: border, height: 14, thickness: 0.5),
                GestureDetector(
                  onTap: () => setState(() => _expanded = isOpen ? null : i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(dateLabel, style: GoogleFonts.dmSans(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isCurrent ? widget.gold : primary))),
                          if (isCurrent)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('NOW', style: GoogleFonts.dmSans(
                                  fontSize: 8, fontWeight: FontWeight.w700, color: widget.gold)),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.gold.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(label, style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w600, color: widget.gold)),
                          ),
                          const SizedBox(width: 8),
                          Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 14, color: secondary),
                        ]),
                        if (isOpen) ...[
                          const SizedBox(height: 8),
                          Text(character, style: GoogleFonts.dmSans(
                              fontSize: 12, color: secondary, height: 1.5)),
                          const SizedBox(height: 10),
                          if (goodFor.isNotEmpty) ...[
                            Text('GOOD FOR', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 0.8, color: successColor)),
                            const SizedBox(height: 5),
                            ...goodFor.map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 4, height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(g, style: GoogleFonts.dmSans(
                                    fontSize: 12, color: primary, height: 1.4))),
                              ]),
                            )),
                          ],
                          if (watchOut.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('WATCH OUT', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 0.8, color: dangerColor)),
                            const SizedBox(height: 5),
                            ...watchOut.map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 4, height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(w, style: GoogleFonts.dmSans(
                                    fontSize: 12, color: secondary, height: 1.4))),
                              ]),
                            )),
                          ],
                          if (finance.isNotEmpty || relationships.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Divider(color: border, height: 1, thickness: 0.5),
                            const SizedBox(height: 6),
                            if (finance.isNotEmpty)
                              _MiniRow(icon: Icons.account_balance_wallet_outlined,
                                  text: finance, color: const Color(0xFFF59E0B), secondary: secondary),
                            if (relationships.isNotEmpty)
                              _MiniRow(icon: Icons.favorite_border,
                                  text: relationships, color: Colors.pinkAccent, secondary: secondary),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Months breakdown (yearly) ────────────────────────────────────────────────
class _MonthsBreakdown extends StatefulWidget {
  final List<Map<String, dynamic>> months;
  final bool isDark;
  final Color gold;
  const _MonthsBreakdown({required this.months, required this.isDark, required this.gold});

  @override
  State<_MonthsBreakdown> createState() => _MonthsBreakdownState();
}

class _MonthsBreakdownState extends State<_MonthsBreakdown> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = widget.isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = widget.isDark ? AppColors.dangerDark : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Month by Month'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: widget.months.asMap().entries.map((entry) {
              final i = entry.key;
              final month = entry.value;
              final isCurrent = month['is_current'] as bool? ?? false;
              final isOpen = _expanded == i;
              final label = month['label'] as String? ?? '';
              final monthName = month['month_name'] as String? ?? '';
              final character = month['character'] as String? ?? '';
              final bestFor = (month['best_for'] as List? ?? []).cast<String>();
              final caution = (month['caution'] as List? ?? []).cast<String>();
              final finance = month['finance'] as String? ?? '';
              final relationships = month['relationships'] as String? ?? '';
              final health = month['health'] as String? ?? '';

              return Column(children: [
                if (i > 0) Divider(color: border, height: 14, thickness: 0.5),
                GestureDetector(
                  onTap: () => setState(() => _expanded = isOpen ? null : i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(monthName, style: GoogleFonts.cormorantGaramond(
                              fontSize: 18,
                              color: isCurrent ? widget.gold : (widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              fontWeight: FontWeight.w400)),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('NOW', style: GoogleFonts.dmSans(
                                  fontSize: 8, fontWeight: FontWeight.w700, color: widget.gold)),
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.gold.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(label, style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w600, color: widget.gold)),
                          ),
                          const SizedBox(width: 8),
                          Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 14, color: secondary),
                        ]),
                        if (isOpen) ...[
                          const SizedBox(height: 8),
                          Text(character, style: GoogleFonts.dmSans(
                              fontSize: 12, color: secondary, height: 1.5)),
                          const SizedBox(height: 10),
                          if (bestFor.isNotEmpty) ...[
                            Text('BEST FOR', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 0.8, color: successColor)),
                            const SizedBox(height: 5),
                            ...bestFor.map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 4, height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(g, style: GoogleFonts.dmSans(
                                    fontSize: 12, color: primary, height: 1.4))),
                              ]),
                            )),
                          ],
                          if (caution.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('CAUTION', style: GoogleFonts.dmSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 0.8, color: dangerColor)),
                            const SizedBox(height: 5),
                            ...caution.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 4, height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                                const SizedBox(width: 8),
                                Expanded(child: Text(c, style: GoogleFonts.dmSans(
                                    fontSize: 12, color: secondary, height: 1.4))),
                              ]),
                            )),
                          ],
                          if (finance.isNotEmpty || relationships.isNotEmpty || health.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Divider(color: border, height: 1, thickness: 0.5),
                            const SizedBox(height: 6),
                            if (finance.isNotEmpty)
                              _MiniRow(icon: Icons.account_balance_wallet_outlined,
                                  text: finance, color: const Color(0xFFF59E0B), secondary: secondary),
                            if (relationships.isNotEmpty)
                              _MiniRow(icon: Icons.favorite_border,
                                  text: relationships, color: Colors.pinkAccent, secondary: secondary),
                            if (health.isNotEmpty)
                              _MiniRow(icon: Icons.monitor_heart_outlined,
                                  text: health, color: Colors.teal, secondary: secondary),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Mini row (icon + text) ───────────────────────────────────────────────────
class _MiniRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color, secondary;
  const _MiniRow({required this.icon, required this.text, required this.color, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4))),
      ]),
    );
  }
}
