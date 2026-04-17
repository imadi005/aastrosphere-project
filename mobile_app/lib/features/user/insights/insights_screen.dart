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

// ─── WEEKLY TAB ───────────────────────────────────────────────────────────────
// Focus: This week's specific days, action-oriented, short and punchy
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
              // Overview — short
              _OverviewCard(text: data['overview'] as String? ?? '', gold: gold, isDark: isDark,
                  label: 'THIS WEEK'),
              const SizedBox(height: 16),

              // Best days + Heavy days — unique to weekly
              if ((data['best_days'] as List? ?? []).isNotEmpty ||
                  (data['heavy_days'] as List? ?? []).isNotEmpty) ...[
                Row(children: [
                  Expanded(child: _DayBox(
                    title: 'BEST DAYS',
                    days: (data['best_days'] as List? ?? []),
                    color: isDark ? AppColors.successDark : AppColors.success,
                    isDark: isDark,
                    isGood: true,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _DayBox(
                    title: 'WATCH DAYS',
                    days: (data['heavy_days'] as List? ?? []),
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                    isGood: false,
                  )),
                ]),
                const SizedBox(height: 16),
              ],

              // Opportunities + Watch-outs
              _OppWatchRow(
                opps: (data['opportunities'] as List? ?? []).cast<String>(),
                watchOuts: (data['watch_out'] as List? ?? []).cast<String>(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Three quick domain signals — horizontal chips
              SectionLabel('This Week'),
              const SizedBox(height: 8),
              _QuickDomainChip(icon: Icons.account_balance_wallet_outlined,
                  label: 'Money', text: data['money_this_week'] as String? ?? '',
                  color: const Color(0xFFF59E0B), isDark: isDark),
              _QuickDomainChip(icon: Icons.favorite_border,
                  label: 'Love', text: data['love_this_week'] as String? ?? '',
                  color: Colors.pinkAccent, isDark: isDark),
              _QuickDomainChip(icon: Icons.monitor_heart_outlined,
                  label: 'Health', text: data['health_this_week'] as String? ?? '',
                  color: Colors.teal, isDark: isDark),

              // Yoga context
              if (data['yoga_context'] != null) ...[
                const SizedBox(height: 12),
                _YogaBar(yogaCtx: data['yoga_context'] as Map<String, dynamic>,
                    gold: gold, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MONTHLY TAB ──────────────────────────────────────────────────────────────
// Focus: The month's arc — two phases, domain depth, what to act on
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
              // Month overview
              _OverviewCard(
                  text: data['overview'] as String? ?? '',
                  gold: gold, isDark: isDark,
                  label: (data['month_name'] as String? ?? 'THIS MONTH').toUpperCase()),
              const SizedBox(height: 16),

              // Phase breakdown — UNIQUE to monthly
              SectionLabel('Month Arc'),
              const SizedBox(height: 8),
              _PhaseTimeline(phases: data['phases'] as List? ?? [], isDark: isDark, gold: gold),
              const SizedBox(height: 16),

              // Domain cards with signal + action — deeper than weekly
              SectionLabel('Life Domains'),
              const SizedBox(height: 8),
              _MonthlyDomainCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Money',
                signal: (data['finance'] as Map?)?['signal'] as String? ?? '',
                action: (data['finance'] as Map?)?['action'] as String?,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
              _MonthlyDomainCard(
                icon: Icons.favorite_border,
                title: 'Relationships',
                signal: (data['relationships'] as Map?)?['signal'] as String? ?? '',
                action: (data['relationships'] as Map?)?['what_to_watch'] as String?,
                actionLabel: 'Watch for',
                color: Colors.pinkAccent,
                isDark: isDark,
              ),
              _MonthlyDomainCard(
                icon: Icons.monitor_heart_outlined,
                title: 'Health',
                signal: (data['health'] as Map?)?['watch'] as String? ?? '',
                action: (data['health'] as Map?)?['advice'] as String?,
                actionLabel: 'Practice',
                color: Colors.teal,
                isDark: isDark,
              ),
              _MonthlyDomainCard(
                icon: Icons.trending_up_outlined,
                title: 'Career',
                signal: (data['career'] as Map?)?['signal'] as String? ?? '',
                action: (data['career'] as Map?)?['best_week'] as String?,
                actionLabel: 'Timing',
                color: Colors.blueAccent,
                isDark: isDark,
              ),

              // Opportunities
              const SizedBox(height: 8),
              _OppWatchRow(
                opps: (data['opportunities'] as List? ?? []).cast<String>(),
                watchOuts: (data['watch_out'] as List? ?? []).cast<String>(),
                isDark: isDark,
              ),

              if (data['yoga_context'] != null) ...[
                const SizedBox(height: 12),
                _YogaBar(yogaCtx: data['yoga_context'] as Map<String, dynamic>,
                    gold: gold, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── YEARLY TAB ───────────────────────────────────────────────────────────────
// Focus: Big picture — year narrative, month windows, patterns, chapter
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
              // Year title card with one-liner
              _YearTitleCard(
                title: data['title'] as String? ?? '',
                oneLiner: data['year_in_one_line'] as String?,
                gold: gold, isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Month windows — UNIQUE to yearly
              if (data['best_months'] != null || data['risky_months'] != null) ...[
                _MonthWindowsCard(
                  bestMonths: data['best_months'] as String? ?? '',
                  riskyMonths: data['risky_months'] as String? ?? '',
                  isDark: isDark, gold: gold,
                ),
                const SizedBox(height: 16),
              ],

              // Current chapter — UNIQUE to yearly
              if (data['current_chapter'] != null) ...[
                _CurrentChapterCard(
                  chapter: data['current_chapter'] as Map<String, dynamic>,
                  isDark: isDark, gold: gold,
                ),
                const SizedBox(height: 16),
              ],

              // Domain cards with signal + YOUR pattern — deepest view
              SectionLabel('Your Year'),
              const SizedBox(height: 8),
              _YearlyDomainCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Money',
                yearSignal: (data['finance'] as Map?)?['year_signal'] as String? ?? '',
                yourPattern: (data['finance'] as Map?)?['your_pattern'] as String?,
                color: const Color(0xFFF59E0B), isDark: isDark,
              ),
              _YearlyDomainCard(
                icon: Icons.favorite_border,
                title: 'Relationships',
                yearSignal: (data['relationships'] as Map?)?['year_signal'] as String? ?? '',
                yourPattern: (data['relationships'] as Map?)?['your_pattern'] as String?,
                color: Colors.pinkAccent, isDark: isDark,
              ),
              _YearlyDomainCard(
                icon: Icons.monitor_heart_outlined,
                title: 'Health',
                yearSignal: (data['health'] as Map?)?['watch'] as String? ?? '',
                yourPattern: (data['health'] as Map?)?['your_pattern'] as String?,
                color: Colors.teal, isDark: isDark,
              ),
              _YearlyDomainCard(
                icon: Icons.trending_up_outlined,
                title: 'Career',
                yearSignal: (data['career'] as Map?)?['year_signal'] as String? ?? '',
                yourPattern: (data['career'] as Map?)?['your_pattern'] as String?,
                color: Colors.blueAccent, isDark: isDark,
              ),

              if (data['yoga_context'] != null) ...[
                const SizedBox(height: 8),
                _YogaBar(yogaCtx: data['yoga_context'] as Map<String, dynamic>,
                    gold: gold, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _OverviewCard extends StatelessWidget {
  final String text, label;
  final Color gold;
  final bool isDark;
  const _OverviewCard({required this.text, required this.label,
      required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, size: 12, color: gold),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 1, color: gold)),
          ]),
          const SizedBox(height: 12),
          Text(text, style: GoogleFonts.dmSans(
              fontSize: 14, color: primary, height: 1.7)),
        ],
      ),
    );
  }
}

// ─── Day Box (weekly only) ────────────────────────────────────────────────────
class _DayBox extends StatelessWidget {
  final String title;
  final List<dynamic> days;
  final Color color;
  final bool isDark, isGood;
  const _DayBox({required this.title, required this.days, required this.color,
      required this.isDark, required this.isGood});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: color)),
          const SizedBox(height: 8),
          ...days.take(2).map((d) {
            final day = d['day'] as String? ?? '';
            final detail = isGood
                ? d['advice'] as String? ?? d['energy'] as String? ?? ''
                : d['caution'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                  if (detail.isNotEmpty)
                    Text(detail, style: GoogleFonts.dmSans(
                        fontSize: 10, color: secondary, height: 1.4),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Quick domain chip (weekly only) ─────────────────────────────────────────
class _QuickDomainChip extends StatelessWidget {
  final IconData icon;
  final String label, text;
  final Color color;
  final bool isDark;
  const _QuickDomainChip({required this.icon, required this.label,
      required this.text, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AstroCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 11, fontWeight: FontWeight.w600, color: primary)),
            const SizedBox(width: 8),
            Expanded(child: Text(text,
                style: GoogleFonts.dmSans(fontSize: 11, color: secondary),
                maxLines: 2, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

// ─── Phase timeline (monthly only) ───────────────────────────────────────────
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: phases.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value as Map<String, dynamic>;
          final isCurrent = p['current'] as bool? ?? false;
          return Column(
            children: [
              if (i > 0) Divider(color: border, height: 20, thickness: 0.5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isCurrent ? gold.withOpacity(0.15) : (isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent ? Border.all(color: gold.withOpacity(0.4), width: 1) : null,
                    ),
                    child: Center(child: Text('${i+1}',
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 16, color: isCurrent ? gold : secondary))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(p['label'] as String? ?? '', style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isCurrent ? gold : primary)),
                        if (isCurrent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('NOW', style: GoogleFonts.dmSans(
                                fontSize: 8, fontWeight: FontWeight.w700, color: gold)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 3),
                      Text(p['theme'] as String? ?? '', style: GoogleFonts.dmSans(
                          fontSize: 12, color: secondary, height: 1.5)),
                    ],
                  )),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Monthly domain card (signal + action) ────────────────────────────────────
class _MonthlyDomainCard extends StatelessWidget {
  final IconData icon;
  final String title, signal;
  final String? action, actionLabel;
  final Color color;
  final bool isDark;
  const _MonthlyDomainCard({required this.icon, required this.title,
      required this.signal, this.action, this.actionLabel = 'Do this',
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AstroCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 32, height: 32,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: color)),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
            ]),
            const SizedBox(height: 10),
            Text(signal, style: GoogleFonts.dmSans(
                fontSize: 12, color: secondary, height: 1.5)),
            if (action != null && action!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(color: border, height: 1, thickness: 0.5),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$actionLabel: ', style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                Expanded(child: Text(action!, style: GoogleFonts.dmSans(
                    fontSize: 11, color: secondary, height: 1.4))),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Year title card (yearly only) ───────────────────────────────────────────
class _YearTitleCard extends StatelessWidget {
  final String title;
  final String? oneLiner;
  final Color gold;
  final bool isDark;
  const _YearTitleCard({required this.title, this.oneLiner,
      required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cormorantGaramond(
              fontSize: 20, color: gold, fontWeight: FontWeight.w400)),
          if (oneLiner != null) ...[
            const SizedBox(height: 8),
            Text('"$oneLiner"', style: GoogleFonts.cormorantGaramond(
                fontSize: 15, color: gold.withOpacity(0.7),
                fontStyle: FontStyle.italic, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

// ─── Month windows card (yearly only) ────────────────────────────────────────
class _MonthWindowsCard extends StatelessWidget {
  final String bestMonths, riskyMonths;
  final Color gold;
  final bool isDark;
  const _MonthWindowsCard({required this.bestMonths, required this.riskyMonths,
      required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (bestMonths.isNotEmpty) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: successColor)),
              const SizedBox(width: 10),
              Expanded(child: Text(bestMonths,
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
            ]),
          ],
          if (bestMonths.isNotEmpty && riskyMonths.isNotEmpty) ...[
            Divider(color: border, height: 16, thickness: 0.5),
          ],
          if (riskyMonths.isNotEmpty) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor)),
              const SizedBox(width: 10),
              Expanded(child: Text(riskyMonths,
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─── Current chapter card (yearly only) ──────────────────────────────────────
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.hourglass_bottom_outlined, size: 14, color: gold),
            const SizedBox(width: 6),
            Text('YOUR CURRENT CHAPTER', style: GoogleFonts.dmSans(
                fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
          ]),
          const SizedBox(height: 10),
          Text(chapter['what_is_actually_happening'] as String? ?? '',
              style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.6)),
          if (chapter['the_gift'] != null) ...[
            const SizedBox(height: 12),
            Divider(color: border, height: 1, thickness: 0.5),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: successColor)),
              const SizedBox(width: 8),
              Expanded(child: Text(chapter['the_gift'] as String,
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
            ]),
          ],
          if (chapter['the_trap'] != null) ...[
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor)),
              const SizedBox(width: 8),
              Expanded(child: Text(chapter['the_trap'] as String,
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─── Yearly domain card (signal + your pattern) ───────────────────────────────
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
      padding: const EdgeInsets.only(bottom: 10),
      child: AstroCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                const SizedBox(height: 4),
                Text(yearSignal, style: GoogleFonts.dmSans(
                    fontSize: 12, color: secondary, height: 1.5)),
                if (yourPattern != null && yourPattern!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Divider(color: border, height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  Text('Your pattern: ', style: GoogleFonts.dmSans(
                      fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                  Text(yourPattern!, style: GoogleFonts.dmSans(
                      fontSize: 11, color: secondary, height: 1.4,
                      fontStyle: FontStyle.italic)),
                ],
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Opps + Watch row (shared) ────────────────────────────────────────────────
class _OppWatchRow extends StatelessWidget {
  final List<String> opps, watchOuts;
  final bool isDark;
  const _OppWatchRow({required this.opps, required this.watchOuts, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (opps.isNotEmpty) Expanded(child: _BulletBox(
            title: 'OPPORTUNITIES', items: opps, color: successColor, isDark: isDark)),
        if (opps.isNotEmpty && watchOuts.isNotEmpty) const SizedBox(width: 10),
        if (watchOuts.isNotEmpty) Expanded(child: _BulletBox(
            title: 'WATCH-OUTS', items: watchOuts, color: dangerColor, isDark: isDark)),
      ],
    );
  }
}

class _BulletBox extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final bool isDark;
  const _BulletBox({required this.title, required this.items,
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: color)),
          const SizedBox(height: 8),
          ...items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 4, height: 4,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color))),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: GoogleFonts.dmSans(
                  fontSize: 11, color: secondary, height: 1.4))),
            ]),
          )),
        ],
      ),
    );
  }
}

// ─── Yoga bar (shared) ────────────────────────────────────────────────────────
class _YogaBar extends StatelessWidget {
  final Map<String, dynamic> yogaCtx;
  final Color gold;
  final bool isDark;
  const _YogaBar({required this.yogaCtx, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withOpacity(0.15), width: 0.5),
      ),
      child: Row(children: [
        Icon(Icons.psychology_outlined, size: 14, color: gold),
        const SizedBox(width: 10),
        Expanded(child: Text(yogaCtx['summary'] as String? ?? '',
            style: GoogleFonts.dmSans(
                fontSize: 11, color: secondary, height: 1.5,
                fontStyle: FontStyle.italic))),
      ]),
    );
  }
}

// ─── Retry view ───────────────────────────────────────────────────────────────
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
      GestureDetector(onTap: onRetry,
          child: Text('Retry', style: GoogleFonts.dmSans(fontSize: 13, color: gold))),
    ]));
  }
}
