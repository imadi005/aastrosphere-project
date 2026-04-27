import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../providers/astro_client_provider.dart';
import '../../auth/providers/user_provider.dart';

class AstroDailyScreen extends ConsumerStatefulWidget {
  const AstroDailyScreen({super.key});
  @override
  ConsumerState<AstroDailyScreen> createState() => _AstroDailyScreenState();
}

class _AstroDailyScreenState extends ConsumerState<AstroDailyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<String, dynamic>? _deep;
  Map<String, dynamic>? _health;
  Map<String, dynamic>? _finance;
  Map<String, dynamic>? _love;
  Map<String, dynamic>? _risks;
  bool _loading = false;
  String? _error;
  DateTime? _loadedFor;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load(DateTime dob) async {
    if (_loadedFor == dob) return;
    setState(() { _loading = true; _error = null; });
    try {
      final dobStr = '${dob.year}-${dob.month.toString().padLeft(2,'0')}-${dob.day.toString().padLeft(2,'0')}';
      final results = await Future.wait([
        ApiService.getDeepInsights(dobStr),
        ApiService.getHealthPrediction(dobStr),
        ApiService.getFinancePrediction(dobStr),
        ApiService.getRelationshipPrediction(dobStr),
        ApiService.getFutureRisks(dobStr),
      ]);
      if (mounted) setState(() {
        _deep = results[0]; _health = results[1]; _finance = results[2];
        _love = results[3]; _risks = results[4];
        _loading = false; _loadedFor = dob;
      });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load. Check your connection.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final useClient = ref.watch(astroUseClientDobProvider);
    final clientDob = ref.watch(astroClientDobProvider);
    final userAsync = ref.watch(userProfileProvider);
    final activeDob = useClient ? clientDob : userAsync.valueOrNull?.dob;

    if (activeDob == null) return _NoDob(isDark: isDark, gold: gold);
    if (activeDob != _loadedFor && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(activeDob));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,4),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('Readings', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400)))),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: gold, unselectedLabelColor: secondary,
          indicatorColor: gold, indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          tabs: const [
            Tab(text: 'Life'),
            Tab(text: 'Now'),
            Tab(text: 'Health'),
            Tab(text: 'Career'),
            Tab(text: 'Love'),
            Tab(text: 'At Risk'),
          ],
        ),
        Expanded(child: _loading
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(strokeWidth: 1.5, color: gold),
              const SizedBox(height: 12),
              Text('Reading the chart...', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
            ]))
          : _error != null
            ? _ErrView(error: _error!, onRetry: () { _loadedFor = null; _load(activeDob); }, gold: gold)
            : _deep == null ? const SizedBox.shrink()
            : TabBarView(controller: _tabs, children: [
                _LifeTab(dob: activeDob, data: _deep!, isDark: isDark, gold: gold),
                _NowTab(data: _deep!, isDark: isDark, gold: gold),
                _HealthTab(data: _health!, deepData: _deep!, isDark: isDark, gold: gold),
                _CareerTab(data: _finance!, deepData: _deep!, isDark: isDark, gold: gold),
                _LoveTab(data: _love!, deepData: _deep!, isDark: isDark, gold: gold),
                _RiskTab(data: _risks!, isDark: isDark, gold: gold),
              ])),
      ])),
    );
  }
}

// ─── Life Tab ─────────────────────────────────────────────────────────────────
class _LifeTab extends StatelessWidget {
  final DateTime dob;
  final Map<String, dynamic> data;
  final bool isDark; final Color gold;
  const _LifeTab({required this.dob, required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final basic = data['basic'] as int? ?? NumerologyEngine.basicNumber(dob.day);
    final destiny = data['destiny'] as int? ?? NumerologyEngine.destinyNumber(dob);
    final core = data['core_nature'] as Map<String,dynamic>? ?? {};
    final lifeDir = data['life_direction'] as Map<String,dynamic>? ?? {};
    final combo = data['core_combination'] as Map<String,dynamic>? ?? {};
    final patterns = data['personal_patterns'] as Map<String,dynamic>? ?? {};

    return ListView(padding: const EdgeInsets.fromLTRB(16,12,16,40), children: [
      // Header chips
      Row(children: [
        _NumChip(number: basic, label: 'Basic · ${NumerologyEngine.planetNames[basic]??''}', color: gold, isDark: isDark),
        const SizedBox(width: 8),
        _NumChip(number: destiny, label: 'Destiny · ${NumerologyEngine.planetNames[destiny]??''}', color: gold.withOpacity(0.7), isDark: isDark),
      ]),
      const SizedBox(height: 16),

      // Core pattern
      if (core['pattern'] != null) _BigCard(
        icon: Icons.person_outline, color: gold,
        title: 'Who they are', body: core['pattern'].toString(), isDark: isDark),

      // Combination
      if (combo['name'] != null) _BigCard(
        icon: Icons.link, color: const Color(0xFF6366F1),
        title: combo['name'].toString(), body: combo['what_it_creates']?.toString() ?? '', isDark: isDark),

      // Work pattern
      if (lifeDir['work_pattern'] != null) _BigCard(
        icon: Icons.work_outline, color: isDark ? AppColors.successDark : AppColors.success,
        title: 'At work', body: lifeDir['work_pattern'].toString(), isDark: isDark),

      // Money pattern
      if (patterns['money'] != null) _BigCard(
        icon: Icons.currency_rupee, color: gold,
        title: 'Money pattern', body: patterns['money'].toString(), isDark: isDark),

      // Love pattern
      if (lifeDir['love_pattern'] != null) _BigCard(
        icon: Icons.favorite_border, color: Colors.pinkAccent,
        title: 'Love pattern', body: lifeDir['love_pattern'].toString(), isDark: isDark),

      // Shadow
      if (core['shadow'] != null) _BigCard(
        icon: Icons.warning_amber_outlined, color: isDark ? AppColors.warningDark : AppColors.warning,
        title: 'Blind spot', body: core['shadow'].toString(), isDark: isDark, accent: true),

      // Recurring lesson
      if (patterns['recurring_lesson'] != null) _BigCard(
        icon: Icons.loop, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        title: 'Life lesson', body: patterns['recurring_lesson'].toString(), isDark: isDark),
    ]);
  }
}

// ─── Now Tab ─────────────────────────────────────────────────────────────────
class _NowTab extends StatelessWidget {
  final Map<String, dynamic> data; final bool isDark; final Color gold;
  const _NowTab({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final chapter = data['current_chapter'] as Map<String,dynamic>? ?? {};
    final mahaNum = data['maha'] as int? ?? 0;
    final antarNum = data['antar'] as int? ?? 0;
    final green = isDark ? AppColors.successDark : AppColors.success;

    return ListView(padding: const EdgeInsets.fromLTRB(16,12,16,40), children: [
      // Current period chips
      Row(children: [
        _PeriodChip(number: mahaNum, label: 'Maha · ${NumerologyEngine.planetNames[mahaNum]??''}', color: gold, isDark: isDark),
        const SizedBox(width: 8),
        _PeriodChip(number: antarNum, label: 'Antar · ${NumerologyEngine.planetNames[antarNum]??''}', color: green, isDark: isDark),
      ]),
      const SizedBox(height: 16),

      // Chapter title
      if (chapter['title'] != null) Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(chapter['title'].toString(), style: GoogleFonts.cormorantGaramond(fontSize: 16, color: gold))),

      // What it feels like
      if (chapter['what_it_feels_like'] != null) _BigCard(
        icon: Icons.sentiment_neutral_outlined, color: gold,
        title: 'What this time feels like', body: chapter['what_it_feels_like'].toString(), isDark: isDark),

      // What is actually happening
      if (chapter['what_is_actually_happening'] != null) _BigCard(
        icon: Icons.visibility_outlined, color: const Color(0xFF6366F1),
        title: 'What is actually happening', body: chapter['what_is_actually_happening'].toString(), isDark: isDark),

      // The gift
      if (chapter['the_gift'] != null) _BigCard(
        icon: Icons.star_outline, color: green,
        title: 'The gift of this period', body: chapter['the_gift'].toString(), isDark: isDark),

      // The trap
      if (chapter['the_trap'] != null) _BigCard(
        icon: Icons.warning_amber_outlined, color: isDark ? AppColors.warningDark : AppColors.warning,
        title: 'Watch out for', body: chapter['the_trap'].toString(), isDark: isDark, accent: true),

      // Advice
      if (chapter['advice'] != null) _BigCard(
        icon: Icons.lightbulb_outline, color: gold,
        title: 'What to do', body: chapter['advice'].toString(), isDark: isDark),
    ]);
  }
}

// ─── Health Tab ───────────────────────────────────────────────────────────────
class _HealthTab extends StatelessWidget {
  final Map<String, dynamic> data, deepData; final bool isDark; final Color gold;
  const _HealthTab({required this.data, required this.deepData, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final healthWatch = (data['healthWatch'] as List? ?? []).cast<Map<String,dynamic>>();
    final warnings = (data['warnings'] as List? ?? []).cast<String>();
    final lifeDir = deepData['life_direction'] as Map<String,dynamic>? ?? {};
    final healthReal = lifeDir['health_real'] as String? ?? '';
    final red = isDark ? AppColors.dangerDark : AppColors.danger;
    final orange = isDark ? AppColors.warningDark : AppColors.warning;

    return ListView(padding: const EdgeInsets.fromLTRB(16,12,16,40), children: [
      // Warnings first
      if (warnings.isNotEmpty) ...[
        _SectionTitle(title: 'Right Now — Watch Out', isDark: isDark),
        const SizedBox(height: 8),
        ...warnings.map((w) => _AlertCard(text: w, color: orange, isDark: isDark)),
        const SizedBox(height: 16),
      ],

      // Health pattern from life direction
      if (healthReal.isNotEmpty) ...[
        _SectionTitle(title: 'Your Body Pattern', isDark: isDark),
        const SizedBox(height: 8),
        _BigCard(icon: Icons.favorite_border, color: red,
            title: 'How this body works', body: healthReal, isDark: isDark),
        const SizedBox(height: 16),
      ],

      // Body system watch per number
      if (healthWatch.isNotEmpty) ...[
        _SectionTitle(title: 'Areas To Watch', isDark: isDark),
        const SizedBox(height: 8),
        ...healthWatch.map((h) {
          final planet = h['planet'] as String? ?? '';
          final common = (h['common'] as List? ?? []).cast<String>();
          final others = (h['others'] as List? ?? []).cast<String>();
          return _HealthCard(
            planet: planet,
            number: h['number'] as int? ?? 0,
            common: common, others: others,
            isDark: isDark, gold: gold,
          );
        }),
      ],
    ]);
  }
}

// ─── Career Tab ───────────────────────────────────────────────────────────────
class _CareerTab extends StatelessWidget {
  final Map<String, dynamic> data, deepData; final bool isDark; final Color gold;
  const _CareerTab({required this.data, required this.deepData, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final pos = (data['positive_indicators'] as List? ?? []).cast<String>();
    final neg = (data['negative_indicators'] as List? ?? []).cast<String>();
    final overall = data['overall'] as String? ?? 'mixed';
    final basic = deepData['basic'] as int? ?? 0;
    final lifeDir = deepData['life_direction'] as Map<String,dynamic>? ?? {};
    final workPattern = lifeDir['work_pattern'] as String? ?? '';
    final green = isDark ? AppColors.successDark : AppColors.success;
    final orange = isDark ? AppColors.warningDark : AppColors.warning;

    // Overall color
    final overallColor = overall == 'favorable' ? green : overall == 'challenging' ? (isDark ? AppColors.dangerDark : AppColors.danger) : orange;
    final overallText = overall == 'favorable' ? 'Good time for career' : overall == 'challenging' ? 'Hard period ahead' : 'Mixed signals — go carefully';
    final overallIcon = overall == 'favorable' ? Icons.trending_up : overall == 'challenging' ? Icons.trending_down : Icons.trending_flat;

    return ListView(padding: const EdgeInsets.fromLTRB(16,12,16,40), children: [
      // Overall status
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: overallColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: overallColor.withOpacity(0.3), width: 0.5)),
        child: Row(children: [
          Icon(overallIcon, color: overallColor, size: 20),
          const SizedBox(width: 10),
          Text(overallText, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: overallColor)),
        ])),

      // Work pattern
      if (workPattern.isNotEmpty) ...[
        _BigCard(icon: Icons.work_outline, color: gold,
            title: 'How they work best', body: workPattern, isDark: isDark),
        const SizedBox(height: 8),
      ],

      // Positives
      if (pos.isNotEmpty) ...[
        _SectionTitle(title: 'What is working for them', isDark: isDark),
        const SizedBox(height: 8),
        ...pos.map((p) => _BulletCard(text: _simplify(p), color: green, isDark: isDark)),
        const SizedBox(height: 16),
      ],

      // Negatives
      if (neg.isNotEmpty) ...[
        _SectionTitle(title: 'What to watch out for', isDark: isDark),
        const SizedBox(height: 8),
        ...neg.map((n) => _BulletCard(text: _simplify(n), color: orange, isDark: isDark, isWarning: true)),
        const SizedBox(height: 16),
      ],
    ]);
  }

  String _simplify(String text) {
    // Remove technical jargon like "Number X present —"
    return text.replaceAll(RegExp(r'Number \d+ present — '), '').replaceAll(RegExp(r'^\d+-\d+ combination — '), '').trim();
  }
}

// ─── Love Tab ─────────────────────────────────────────────────────────────────
class _LoveTab extends StatelessWidget {
  final Map<String, dynamic> data, deepData; final bool isDark; final Color gold;
  const _LoveTab({required this.data, required this.deepData, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final marriage = (data['marriage_indicators'] as List? ?? []).cast<Map<String,dynamic>>();
    final romance = (data['romance_indicators'] as List? ?? []).cast<String>();
    final caution = (data['caution_indicators'] as List? ?? []).cast<String>();
    final lifeDir = deepData['life_direction'] as Map<String,dynamic>? ?? {};
    final lovePattern = lifeDir['love_pattern'] as String? ?? '';
    final green = isDark ? AppColors.successDark : AppColors.success;
    final orange = isDark ? AppColors.warningDark : AppColors.warning;
    final pink = Colors.pinkAccent;

    return ListView(padding: const EdgeInsets.fromLTRB(16,12,16,40), children: [
      // Love pattern
      if (lovePattern.isNotEmpty) ...[
        _BigCard(icon: Icons.favorite_border, color: pink,
            title: 'How they love', body: lovePattern, isDark: isDark),
        const SizedBox(height: 8),
      ],

      // Marriage indicators
      if (marriage.isNotEmpty) ...[
        _SectionTitle(title: 'Marriage & Commitment', isDark: isDark),
        const SizedBox(height: 8),
        ...marriage.map((m) => _BulletCard(
            text: m['text']?.toString().replaceAll(RegExp(r'Yearly Dasha \d+ — '), '') ?? '',
            color: green, isDark: isDark)),
        const SizedBox(height: 16),
      ],

      // Romance indicators
      if (romance.isNotEmpty) ...[
        _SectionTitle(title: 'Romance Energy Right Now', isDark: isDark),
        const SizedBox(height: 8),
        ...romance.map((r) => _BulletCard(
            text: r.replaceAll(RegExp(r'\d+-\d+ combination — '), '').replaceAll(RegExp(r' \(Raj Yoga\)'), ''),
            color: pink, isDark: isDark)),
        const SizedBox(height: 16),
      ],

      // Cautions
      if (caution.isNotEmpty) ...[
        _SectionTitle(title: 'Be Careful About', isDark: isDark),
        const SizedBox(height: 8),
        ...caution.map((c) => _BulletCard(
            text: c.replaceAll(RegExp(r'Yearly Dasha \d+ — |Maha Dasha \d+ — '), '').replaceAll(RegExp(r'Multiple \d+ — '), ''),
            color: orange, isDark: isDark, isWarning: true)),
      ],
    ]);
  }
}

// ─── At Risk Tab ──────────────────────────────────────────────────────────────
class _RiskTab extends StatefulWidget {
  final Map<String, dynamic> data; final bool isDark; final Color gold;
  const _RiskTab({required this.data, required this.isDark, required this.gold});
  @override State<_RiskTab> createState() => _RiskTabState();
}

class _RiskTabState extends State<_RiskTab> {
  String _filter = 'all';

  static const _filters = [
    ('all', 'All', Icons.list),
    ('accident', 'Accident', Icons.directions_car_outlined),
    ('health', 'Health', Icons.favorite_outline),
    ('finance', 'Money', Icons.currency_rupee),
    ('relationship', 'Love', Icons.people_outline),
    ('career', 'Career', Icons.work_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final allWindows = (widget.data['riskWindows'] as List? ?? []).cast<Map<String,dynamic>>();
    final summary = widget.data['summary'] as Map<String,dynamic>? ?? {};
    final today = DateTime.now().year;

    // Filter
    final filtered = _filter == 'all'
        ? allWindows
        : allWindows.where((w) => (w['risks'] as List? ?? []).any((r) => (r as Map)['type'] == _filter)).toList();

    return Column(children: [
      // Summary pills
      Padding(padding: const EdgeInsets.fromLTRB(16,10,16,4),
        child: SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: _filters.map((f) {
            final count = f.$1 == 'all' ? allWindows.length : (summary[f.$1] as int? ?? 0);
            final isActive = _filter == f.$1;
            return GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? gold.withOpacity(0.15) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? gold.withOpacity(0.5) : (isDark ? AppColors.borderDark : AppColors.borderLight), width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(f.$3, size: 12, color: isActive ? gold : secondary),
                  const SizedBox(width: 5),
                  Text(f.$2, style: GoogleFonts.dmSans(fontSize: 11, color: isActive ? gold : secondary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                  if (count > 0) ...[const SizedBox(width: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: isActive ? gold : secondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                      child: Text('$count', style: GoogleFonts.dmSans(fontSize: 9, color: isActive ? Colors.black : secondary, fontWeight: FontWeight.w700))),
                  ],
                ])),
            );
          }).toList()))),

      // List
      Expanded(child: filtered.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_outline, size: 36, color: (isDark ? AppColors.successDark : AppColors.success).withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('No risks found for this filter', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final w = filtered[i];
              final year = w['year'] as int? ?? 0;
              final maha = w['maha'] as Map<String,dynamic>? ?? {};
              final antar = w['antar'] as Map<String,dynamic>? ?? {};
              final risks = (w['risks'] as List? ?? []).cast<Map<String,dynamic>>();
              final filteredRisks = _filter == 'all' ? risks : risks.where((r) => r['type'] == _filter).toList();
              final isFuture = year > today;
              final isNow = year == today;

              return _RiskYearCard(
                year: year, maha: maha, antar: antar,
                data: w, risks: filteredRisks, isDark: isDark, gold: gold,
                isNow: isNow,
              );
            })),
    ]);
  }
}

class _RiskYearCard extends StatefulWidget {
  final int year;
  final Map<String,dynamic> maha, antar, data;
  final List<Map<String,dynamic>> risks;
  final bool isDark, isNow;
  final Color gold;
  const _RiskYearCard({required this.year, required this.maha, required this.antar,
      required this.data, required this.risks, required this.isDark, required this.gold, required this.isNow});
  @override State<_RiskYearCard> createState() => _RiskYearCardState();
}

class _RiskYearCardState extends State<_RiskYearCard> {
  bool _expanded = false;

  Color _riskColor(String type, bool isDark) {
    switch(type) {
      case 'accident': return isDark ? AppColors.dangerDark : AppColors.danger;
      case 'health': return Colors.pinkAccent;
      case 'finance': return isDark ? AppColors.warningDark : AppColors.warning;
      case 'relationship': return Colors.pinkAccent.withOpacity(0.8);
      case 'career': return const Color(0xFF6366F1);
      default: return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    }
  }

  IconData _riskIcon(String type) {
    switch(type) {
      case 'accident': return Icons.directions_car_outlined;
      case 'health': return Icons.favorite_outline;
      case 'finance': return Icons.currency_rupee;
      case 'relationship': return Icons.people_outline;
      case 'career': return Icons.work_outline;
      default: return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final hasHigh = widget.risks.any((r) => r['level'] == 'high');
    final cardBorder = hasHigh ? (isDark ? AppColors.dangerDark : AppColors.danger) : (isDark ? AppColors.warningDark : AppColors.warning);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.isNow ? gold.withOpacity(0.5) : cardBorder.withOpacity(0.3), width: widget.isNow ? 1 : 0.5)),
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            // Year
            Container(width: 48, height: 48, decoration: BoxDecoration(
                color: (hasHigh ? (isDark ? AppColors.dangerDark : AppColors.danger) : (isDark ? AppColors.warningDark : AppColors.warning)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${widget.year}', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700,
                    color: hasHigh ? (isDark ? AppColors.dangerDark : AppColors.danger) : (isDark ? AppColors.warningDark : AppColors.warning))),
                if (widget.isNow) Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, color: gold, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ])),
            const SizedBox(width: 12),
            // Dasha info + risk icons
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Maha ${widget.maha['number']} · Antar ${widget.antar['number']}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, children: widget.risks.map((r) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _riskColor(r['type'] as String, isDark).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_riskIcon(r['type'] as String), size: 10, color: _riskColor(r['type'] as String, isDark)),
                  const SizedBox(width: 3),
                  Text(r['title'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 10, color: _riskColor(r['type'] as String, isDark))),
                ]))).toList()),
            ])),
            Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: secondary),
          ])),

          AnimatedSize(
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
            child: _expanded ? Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Divider(height: 12, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                // Combination analysis
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.data['combination_label'] as String? ?? 'Maha ${widget.maha['number']} + Antar ${widget.antar['number']}',
                        style: GoogleFonts.dmSans(fontSize: 11, color: gold, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('This specific combination of Mahadasha and Antardasha creates the energy environment for this year. '
                        'The risks listed below emerge from how these two frequencies interact.',
                        style: GoogleFonts.dmSans(fontSize: 12, color: primary, height: 1.6)),
                  ])),
                const SizedBox(height: 10),
                // Risk details
                ...widget.risks.map((r) {
                  final rc = _riskColor(r['type'] as String, isDark);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: rc.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: rc.withOpacity(0.2), width: 0.5)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(_riskIcon(r['type'] as String), size: 16, color: rc),
                      const SizedBox(width: 10),
                      Expanded(child: Text(r['msg'] as String? ?? '',
                          style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.6))),
                    ]));
                }),
                // Risky months
                if ((widget.data['risky_months'] as List? ?? []).isNotEmpty) ...[
                  Text('RISKY MONTHS', style: GoogleFonts.dmSans(fontSize: 9, color: isDark ? AppColors.dangerDark : AppColors.danger, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: (widget.data['risky_months'] as List).map((m) {
                    final mm = m as Map;
                    final red = isDark ? AppColors.dangerDark : AppColors.danger;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: red.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: red.withOpacity(0.3), width: 0.5)),
                      child: Column(children: [
                        Text(mm['month'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 11, color: red, fontWeight: FontWeight.w700)),
                        Text('Mo ${mm['monthly']}', style: GoogleFonts.dmSans(fontSize: 9, color: red.withOpacity(0.7))),
                      ]));
                  }).toList()),
                  const SizedBox(height: 10),
                ],
                // Safe months
                if ((widget.data['safe_months'] as List? ?? []).isNotEmpty) ...[
                  Text('SAFER MONTHS', style: GoogleFonts.dmSans(fontSize: 9, color: isDark ? AppColors.successDark : AppColors.success, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: (widget.data['safe_months'] as List).map((m) {
                    final mm = m as Map;
                    final grn = isDark ? AppColors.successDark : AppColors.success;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: grn.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: grn.withOpacity(0.3), width: 0.5)),
                      child: Column(children: [
                        Text(mm['month'] as String? ?? '', style: GoogleFonts.dmSans(fontSize: 11, color: grn, fontWeight: FontWeight.w700)),
                        Text('Mo ${mm['monthly']}', style: GoogleFonts.dmSans(fontSize: 9, color: grn.withOpacity(0.7))),
                      ]));
                  }).toList()),
                ],
              ])) : const SizedBox.shrink()),
        ]),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────
class _NoDob extends StatelessWidget {
  final bool isDark; final Color gold;
  const _NoDob({required this.isDark, required this.gold});
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Scaffold(backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_outline, size: 40, color: gold.withOpacity(0.4)), const SizedBox(height: 16),
        Text('No DOB selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)), const SizedBox(height: 8),
        Text('Enter a client DOB in the Chart tab first', textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      ])));
  }
}

class _ErrView extends StatelessWidget {
  final String error; final VoidCallback onRetry; final Color gold;
  const _ErrView({required this.error, required this.onRetry, required this.gold});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(error, style: GoogleFonts.dmSans(fontSize: 13)), const SizedBox(height: 12),
    GestureDetector(onTap: onRetry, child: Text('Try again', style: GoogleFonts.dmSans(color: gold, fontWeight: FontWeight.w600))),
  ]));
}

class _SectionTitle extends StatelessWidget {
  final String title; final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});
  @override Widget build(BuildContext context) => Text(title.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight));
}

class _NumChip extends StatelessWidget {
  final int number; final String label; final Color color; final bool isDark;
  const _NumChip({required this.number, required this.label, required this.color, required this.isDark});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$number', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: color)),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: color)),
    ]));
}

class _PeriodChip extends StatelessWidget {
  final int number; final String label; final Color color; final bool isDark;
  const _PeriodChip({required this.number, required this.label, required this.color, required this.isDark});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3), width: 0.5)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$number', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: color)),
      const SizedBox(width: 7),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: color)),
    ]));
}

class _BigCard extends StatelessWidget {
  final IconData icon; final Color color; final String title, body; final bool isDark, accent;
  const _BigCard({required this.icon, required this.color, required this.title, required this.body, required this.isDark, this.accent = false});
  @override Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent ? color.withOpacity(0.07) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent ? color.withOpacity(0.25) : border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 14, color: color)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: primary))),
        ]),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(body, style: GoogleFonts.dmSans(fontSize: 13, color: secondary, height: 1.6)),
        ],
      ]));
  }
}

class _AlertCard extends StatelessWidget {
  final String text; final Color color; final bool isDark;
  const _AlertCard({required this.text, required this.color, required this.isDark});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.warning_amber_rounded, size: 14, color: color), const SizedBox(width: 8),
      Expanded(child: Text(text.replaceAll(RegExp(r'Yearly Dasha \d+ — '), '').replaceAll(RegExp(r'^\d+-\d+ combination active — '), ''),
          style: GoogleFonts.dmSans(fontSize: 12, color: color, height: 1.5))),
    ]));
}

class _BulletCard extends StatelessWidget {
  final String text; final Color color; final bool isDark, isWarning;
  const _BulletCard({required this.text, required this.color, required this.isDark, this.isWarning = false});
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? color.withOpacity(0.07) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isWarning ? color.withOpacity(0.2) : border, width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
      ]));
  }
}

class _HealthCard extends StatelessWidget {
  final String planet; final int number; final List<String> common, others; final bool isDark; final Color gold;
  const _HealthCard({required this.planet, required this.number, required this.common, required this.others, required this.isDark, required this.gold});
  @override Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final pink = Colors.pinkAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: pink.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
            child: Icon(Icons.favorite_outline, size: 14, color: pink)),
          const SizedBox(width: 8),
          Text('$number · $planet', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
        ]),
        const SizedBox(height: 8),
        if (common.isNotEmpty) ...[
          Text('COMMON ISSUES', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: secondary)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4, children: common.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: pink.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
            child: Text(c, style: GoogleFonts.dmSans(fontSize: 11, color: pink)))).toList()),
          const SizedBox(height: 8),
        ],
        if (others.isNotEmpty) ...[
          Text('ALSO WATCH', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: secondary)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4, children: others.map((o) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: (isDark ? AppColors.borderDark : AppColors.borderLight), borderRadius: BorderRadius.circular(6)),
            child: Text(o, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)))).toList()),
        ],
      ]));
  }
}
