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

    return Column(
      children: [
        Container(
          color: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight,
          child: TabBar(
            controller: _tab,
            labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
            labelColor: gold,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: gold,
            indicatorWeight: 2,
            dividerColor: border,
            tabs: const [
              Tab(text: 'WEEKLY'),
              Tab(text: 'MONTHLY'),
              Tab(text: 'YEARLY'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _SmartInsightTab(provider: weeklyInsightsProvider, type: 'weekly'),
              _SmartInsightTab(provider: monthlyInsightsProvider, type: 'monthly'),
              _SmartInsightTab(provider: yearlyInsightsProvider, type: 'yearly'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmartInsightTab extends ConsumerWidget {
  final FutureProvider<Map<String, dynamic>> provider;
  final String type;

  const _SmartInsightTab({required this.provider, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(provider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;

    return asyncData.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (e, __) => _ErrorView(onRetry: () => ref.refresh(provider), gold: gold),
      data: (data) {
        final opportunities = List<String>.from(data['opportunities'] ?? []);
        final watchOuts = List<String>.from(data['watch_out'] ?? []);
        final yogaContext = data['yoga_context'] as Map<String, dynamic>?;

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(provider),
          color: gold,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MAIN OVERVIEW
                _MainEnergyCard(
                  overview: data['overview'] ?? '',
                  extra: data['this_year_specifically'],
                  gold: gold,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // OPPORTUNITIES & WATCH-OUTS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _InsightBox(title: 'Opportunities', items: opportunities, color: Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _InsightBox(title: 'Watch-outs', items: watchOuts, color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 24),

                // LIFE DOMAINS (DENSE DATA)
                SectionLabel('Life Domains'),
                const SizedBox(height: 8),
                _DomainTile(title: 'Wealth & Finance', desc: data['finance'], icon: Icons.account_balance_wallet_outlined, color: Colors.amber),
                _DomainTile(title: 'Relationships', desc: data['relationships'], icon: Icons.favorite_border, color: Colors.pinkAccent),
                _DomainTile(title: 'Health Watch', desc: data['health'], icon: Icons.shutter_speed_outlined, color: Colors.teal),
                if (data['career'] != null)
                  _DomainTile(title: 'Career Drive', desc: data['career'], icon: Icons.trending_up, color: Colors.blueAccent),

                // YOGA SUMMARY
                if (yogaContext != null) ...[
                  const SizedBox(height: 24),
                  _YogaBadge(summary: yogaContext['summary'] ?? '', gold: gold, isDark: isDark),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── REUSABLE UI COMPONENTS ──────────────────────────────────

class _MainEnergyCard extends StatelessWidget {
  final String overview;
  final String? extra;
  final Color gold;
  final bool isDark;
  const _MainEnergyCard({required this.overview, this.extra, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: gold, size: 16),
              const SizedBox(width: 8),
              Text('CORE ENERGY', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: gold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(overview, style: GoogleFonts.dmSans(fontSize: 14, height: 1.6, color: isDark ? Colors.white : Colors.black87)),
          if (extra != null) ...[
            const Divider(height: 32),
            Text(extra!, style: GoogleFonts.dmSans(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.white60 : Colors.black54)),
          ]
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _InsightBox({required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          ...items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Expanded(child: Text(item, style: GoogleFonts.dmSans(fontSize: 11, height: 1.3))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _DomainTile extends StatelessWidget {
  final String title;
  final dynamic desc;
  final IconData icon;
  final Color color;
  const _DomainTile({required this.title, this.desc, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    if (desc == null || desc.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AstroCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc.toString(), style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YogaBadge extends StatelessWidget {
  final String summary;
  final Color gold;
  final bool isDark;
  const _YogaBadge({required this.summary, required this.gold, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withOpacity(0.2), style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology_outlined, color: gold, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(summary, style: GoogleFonts.dmSans(fontSize: 12, fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final Color gold;
  const _ErrorView({required this.onRetry, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Syncing with Smart Engine...', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
          TextButton(onPressed: onRetry, child: Text('Retry Connection', style: TextStyle(color: gold))),
        ],
      ),
    );
  }
}