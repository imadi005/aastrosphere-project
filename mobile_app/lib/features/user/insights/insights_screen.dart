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
              _InsightTab(provider: weeklyInsightsProvider, period: 'week', isDark: isDark, gold: gold),
              _InsightTab(provider: monthlyInsightsProvider, period: 'month', isDark: isDark, gold: gold),
              _InsightTab(provider: yearlyInsightsProvider, period: 'year', isDark: isDark, gold: gold),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightTab extends ConsumerWidget {
  final FutureProvider<Map<String, dynamic>> provider;
  final String period;
  final bool isDark;
  final Color gold;

  const _InsightTab({required this.provider, required this.period,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(provider).when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => _RetryView(onRetry: () => ref.refresh(provider), gold: gold, isDark: isDark),
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.refresh(provider),
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: _InsightContent(data: data, period: period, isDark: isDark, gold: gold),
        ),
      ),
    );
  }
}

class _InsightContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final String period;
  final bool isDark;
  final Color gold;

  const _InsightContent({required this.data, required this.period,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final overview = data['overview'] as String? ?? '';
    final thisYear = data['this_year_specifically'] as String?;
    final opps = (data['opportunities'] as List? ?? []).cast<String>();
    final watchOuts = (data['watch_out'] as List? ?? []).cast<String>();
    final finance = data['finance'] as String?;
    final relationships = data['relationships'] as String?;
    final health = data['health'] as String?;
    final career = data['career'] as String?;
    final yogaCtx = data['yoga_context'] as Map<String, dynamic>?;
    final lifeCtx = (data['life_context'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Overview ────────────────────────────────────────────
        AstroCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.auto_awesome, size: 14, color: gold),
                const SizedBox(width: 6),
                Text('THIS ${period.toUpperCase()}',
                    style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1, color: gold)),
              ]),
              const SizedBox(height: 12),
              Text(overview,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: primary, height: 1.7)),
              if (thisYear != null && thisYear.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(color: border, thickness: 0.5),
                const SizedBox(height: 10),
                Text(thisYear,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: secondary,
                        height: 1.6, fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Opportunities + Watch-outs ───────────────────────────
        if (opps.isNotEmpty || watchOuts.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (opps.isNotEmpty)
                Expanded(child: _BulletBox(
                  title: 'OPPORTUNITIES',
                  items: opps,
                  color: successColor,
                )),
              if (opps.isNotEmpty && watchOuts.isNotEmpty)
                const SizedBox(width: 10),
              if (watchOuts.isNotEmpty)
                Expanded(child: _BulletBox(
                  title: 'WATCH-OUTS',
                  items: watchOuts,
                  color: dangerColor,
                )),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // ── Life Domains ─────────────────────────────────────────
        SectionLabel('Life Domains'),
        const SizedBox(height: 8),
        if (finance != null && finance.isNotEmpty)
          _DomainRow(icon: Icons.account_balance_wallet_outlined,
              title: 'Wealth', desc: finance, color: const Color(0xFFF59E0B),
              isDark: isDark),
        if (relationships != null && relationships.isNotEmpty)
          _DomainRow(icon: Icons.favorite_border,
              title: 'Relationships', desc: relationships, color: Colors.pinkAccent,
              isDark: isDark),
        if (health != null && health.isNotEmpty)
          _DomainRow(icon: Icons.monitor_heart_outlined,
              title: 'Health', desc: health, color: Colors.teal,
              isDark: isDark),
        if (career != null && career.isNotEmpty)
          _DomainRow(icon: Icons.trending_up_outlined,
              title: 'Career', desc: career, color: Colors.blueAccent,
              isDark: isDark),

        // ── Yoga context ─────────────────────────────────────────
        if (yogaCtx != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold.withOpacity(0.15), width: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology_outlined, size: 16, color: gold),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  yogaCtx['summary'] as String? ?? '',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: secondary,
                      height: 1.5, fontStyle: FontStyle.italic),
                )),
              ],
            ),
          ),
        ],

        // ── Life context (yearly only) ───────────────────────────
        if (lifeCtx.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionLabel('Your Chart Says'),
          const SizedBox(height: 8),
          ...lifeCtx.map((ctx) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 0.5),
              ),
              child: Text(ctx,
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: secondary, height: 1.55)),
            ),
          )),
        ],

      ],
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _BulletBox extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;

  const _BulletBox({required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Text(title,
              style: GoogleFonts.dmSans(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 0.8, color: color)),
          const SizedBox(height: 8),
          ...items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 4, height: 4,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: secondary, height: 1.45))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _DomainRow extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  final bool isDark;

  const _DomainRow({required this.icon, required this.title,
      required this.desc, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AstroCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
                const SizedBox(height: 3),
                Text(desc,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: secondary, height: 1.5)),
              ],
            )),
          ],
        ),
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
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Could not load insights',
            style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
        const SizedBox(height: 12),
        GestureDetector(onTap: onRetry,
            child: Text('Retry', style: GoogleFonts.dmSans(fontSize: 13, color: gold))),
      ],
    ));
  }
}
