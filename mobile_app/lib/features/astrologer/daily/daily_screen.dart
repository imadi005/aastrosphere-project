import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../providers/astro_client_provider.dart';
import '../../auth/providers/user_provider.dart';

// API response structure from /api/insights/deep:
// basic, destiny, maha(int), antar(int)
// core_nature: { pattern, internal_conflict, shadow, what_trips_you }
// life_direction: { pattern, money_pattern, love_pattern, work_pattern, health_real }
// core_combination: { name, what_it_creates, the_conflict, real_life, warning, advice }
// personal_patterns: { money, love, work, recurring_lesson }
// current_chapter: { title, what_it_feels_like, what_is_actually_happening, the_trap, the_gift, advice }
// active_yogas: list of { yoga, description }
// warnings: list
// natal_combinations: list

class AstroDailyScreen extends ConsumerStatefulWidget {
  const AstroDailyScreen({super.key});
  @override
  ConsumerState<AstroDailyScreen> createState() => _AstroDailyScreenState();
}

class _AstroDailyScreenState extends ConsumerState<AstroDailyScreen> {
  Map<String, dynamic>? _data;
  bool _loading = false;
  String? _error;
  DateTime? _loadedFor;

  Future<void> _load(DateTime dob) async {
    if (_loadedFor == dob) return;
    setState(() { _loading = true; _error = null; });
    try {
      final dobStr = '${dob.year}-${dob.month.toString().padLeft(2,'0')}-${dob.day.toString().padLeft(2,'0')}';
      final result = await ApiService.getDeepInsights(dobStr);
      if (mounted) setState(() { _data = result; _loading = false; _loadedFor = dob; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
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
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8),
          child: Text('Life Pattern', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400))),
        Expanded(child: _loading
          ? Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold))
          : _error != null
            ? _ErrView(error: _error!, onRetry: () { _loadedFor = null; _load(activeDob); }, gold: gold)
            : _data == null ? const SizedBox.shrink()
            : _PatternBody(dob: activeDob, data: _data!, isDark: isDark, gold: gold)),
      ])),
    );
  }
}

class _NoDob extends StatelessWidget {
  final bool isDark; final Color gold;
  const _NoDob({required this.isDark, required this.gold});
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Scaffold(backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_outline, size: 40, color: gold.withOpacity(0.4)), const SizedBox(height: 16),
        Text('No DOB Selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)), const SizedBox(height: 8),
        Text('Enter a client DOB in the Chart tab to view the life pattern', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      ]))));
  }
}
class _ErrView extends StatelessWidget {
  final String error; final VoidCallback onRetry; final Color gold;
  const _ErrView({required this.error, required this.onRetry, required this.gold});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(error), const SizedBox(height: 12),
    GestureDetector(onTap: onRetry, child: Text('Retry', style: GoogleFonts.dmSans(color: gold, fontWeight: FontWeight.w600))),
  ]));
}

class _PatternBody extends StatelessWidget {
  final DateTime dob; final Map<String, dynamic> data; final bool isDark; final Color gold;
  const _PatternBody({required this.dob, required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final basic = data['basic'] as int? ?? NumerologyEngine.basicNumber(dob.day);
    final destiny = data['destiny'] as int? ?? NumerologyEngine.destinyNumber(dob);
    final mahaNum = data['maha'] as int? ?? 0;
    final antarNum = data['antar'] as int? ?? 0;

    // Nested objects — must access as Map, not String
    final coreNature = data['core_nature'] as Map<String, dynamic>? ?? {};
    final lifeDir = data['life_direction'] as Map<String, dynamic>? ?? {};
    final coreCombination = data['core_combination'] as Map<String, dynamic>? ?? {};
    final personalPatterns = data['personal_patterns'] as Map<String, dynamic>? ?? {};
    final currentChapter = data['current_chapter'] as Map<String, dynamic>? ?? {};
    final activeYogas = (data['active_yogas'] as List? ?? []).cast<Map<String, dynamic>>();
    final warnings = (data['warnings'] as List? ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Numbers
        Row(children: [
          _NumTag(number: basic, label: 'Basic', color: gold, isDark: isDark),
          const SizedBox(width: 8),
          _NumTag(number: destiny, label: 'Destiny', color: gold.withOpacity(0.75), isDark: isDark),
          const SizedBox(width: 8),
          _NumTag(number: mahaNum, label: 'Maha', color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
        ]),
        const SizedBox(height: 20),

        // Core Nature (Basic number profile)
        if (coreNature.isNotEmpty) ...[
          _SecLabel(label: 'CORE NATURE (${NumerologyEngine.planetNames[basic] ?? ""})', isDark: isDark),
          const SizedBox(height: 8),
          if (coreNature['pattern'] != null) _TextCard(text: coreNature['pattern'].toString(), isDark: isDark),
          if (coreNature['internal_conflict'] != null) ...[const SizedBox(height: 8), _TextCard(text: coreNature['internal_conflict'].toString(), isDark: isDark)],
          const SizedBox(height: 16),
        ],

        // Life Direction (Destiny number profile)
        if (lifeDir.isNotEmpty) ...[
          _SecLabel(label: 'LIFE DIRECTION (${NumerologyEngine.planetNames[destiny] ?? ""})', isDark: isDark),
          const SizedBox(height: 8),
          if (lifeDir['pattern'] != null) _TextCard(text: lifeDir['pattern'].toString(), isDark: isDark),
          const SizedBox(height: 4),
          if (lifeDir['work_pattern'] != null) ...[const SizedBox(height: 4), _MiniRow(icon: Icons.work_outline, text: lifeDir['work_pattern'].toString(), isDark: isDark)],
          if (lifeDir['money_pattern'] != null) _MiniRow(icon: Icons.currency_rupee, text: lifeDir['money_pattern'].toString(), isDark: isDark),
          if (lifeDir['love_pattern'] != null) _MiniRow(icon: Icons.favorite_outline, text: lifeDir['love_pattern'].toString(), isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Core Combination (Basic × Destiny)
        if (coreCombination.isNotEmpty) ...[
          _SecLabel(label: 'COMBINATION $basic × $destiny', isDark: isDark),
          const SizedBox(height: 8),
          if (coreCombination['name'] != null)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(coreCombination['name'].toString(), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: gold))),
          if (coreCombination['what_it_creates'] != null) _TextCard(text: coreCombination['what_it_creates'].toString(), isDark: isDark),
          if (coreCombination['real_life'] != null) ...[const SizedBox(height: 8), _TextCard(text: coreCombination['real_life'].toString(), isDark: isDark)],
          if (coreCombination['advice'] != null) ...[const SizedBox(height: 8), _AccentCard(text: coreCombination['advice'].toString(), color: gold, isDark: isDark)],
          const SizedBox(height: 16),
        ],

        // Current Chapter
        if (currentChapter.isNotEmpty) ...[
          _SecLabel(label: 'CURRENT CHAPTER', isDark: isDark),
          const SizedBox(height: 8),
          if (currentChapter['title'] != null)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: gold.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
              child: Text(currentChapter['title'].toString(), style: GoogleFonts.cormorantGaramond(fontSize: 14, color: gold))),
          if (currentChapter['what_it_feels_like'] != null) _AccentCard(text: currentChapter['what_it_feels_like'].toString(), color: gold, isDark: isDark),
          if (currentChapter['what_is_actually_happening'] != null) ...[const SizedBox(height: 8), _TextCard(text: currentChapter['what_is_actually_happening'].toString(), isDark: isDark)],
          if (currentChapter['the_gift'] != null) ...[const SizedBox(height: 8), _AccentCard(text: '${currentChapter['the_gift']}', color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark)],
          if (currentChapter['advice'] != null) ...[const SizedBox(height: 8), _TextCard(text: currentChapter['advice'].toString(), isDark: isDark)],
          const SizedBox(height: 16),
        ],

        // Shadow & what trips you
        if (coreNature['shadow'] != null || coreNature['what_trips_you'] != null) ...[
          _SecLabel(label: 'SHADOW & BLIND SPOTS', isDark: isDark),
          const SizedBox(height: 8),
          if (coreNature['shadow'] != null) _AccentCard(text: coreNature['shadow'].toString(), color: isDark ? AppColors.warningDark : AppColors.warning, isDark: isDark),
          if (coreNature['what_trips_you'] != null) ...[const SizedBox(height: 8), _TextCard(text: coreNature['what_trips_you'].toString(), isDark: isDark)],
          const SizedBox(height: 16),
        ],

        // Health
        if (lifeDir['health_real'] != null) ...[
          _SecLabel(label: 'HEALTH PATTERN', isDark: isDark),
          const SizedBox(height: 8),
          _TextCard(text: lifeDir['health_real'].toString(), isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Warnings
        if (warnings.isNotEmpty) ...[
          _SecLabel(label: 'WARNINGS', isDark: isDark),
          const SizedBox(height: 8),
          ...warnings.map((w) {
            final text = w is Map ? (w['warning'] ?? w['text'] ?? w.toString()) : w.toString();
            return Padding(padding: const EdgeInsets.only(bottom: 8),
              child: _AccentCard(text: text.toString(), color: isDark ? AppColors.warningDark : AppColors.warning, isDark: isDark));
          }),
          const SizedBox(height: 8),
        ],

        // Active Yogas
        if (activeYogas.isNotEmpty) ...[
          _SecLabel(label: 'ACTIVE YOGAS', isDark: isDark),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: activeYogas.take(8).map((y) {
            final name = y['yoga'] as String? ?? y['name'] as String? ?? '';
            return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: gold.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: gold.withOpacity(0.25), width: 0.5)),
              child: Text(name, style: GoogleFonts.dmSans(fontSize: 11, color: gold)));
          }).toList()),
        ],
      ]),
    );
  }
}

class _SecLabel extends StatelessWidget {
  final String label; final bool isDark;
  const _SecLabel({required this.label, required this.isDark});
  @override Widget build(BuildContext context) => Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight));
}
class _NumTag extends StatelessWidget {
  final int number; final String label; final Color color; final bool isDark;
  const _NumTag({required this.number, required this.label, required this.color, required this.isDark});
  @override Widget build(BuildContext context) {
    final planet = NumerologyEngine.planetNames[number] ?? '';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(number.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 18, color: color)),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 8, color: color.withOpacity(0.7), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          Text(planet, style: GoogleFonts.dmSans(fontSize: 10, color: color)),
        ]),
      ]));
  }
}
class _TextCard extends StatelessWidget {
  final String text; final bool isDark;
  const _TextCard({required this.text, required this.isDark});
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5)),
    child: Text(text, style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.65)));
}
class _AccentCard extends StatelessWidget {
  final String text; final Color color; final bool isDark;
  const _AccentCard({required this.text, required this.color, required this.isDark});
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
    child: Text(text, style: GoogleFonts.dmSans(fontSize: 13, color: color, height: 1.65)));
}
class _MiniRow extends StatelessWidget {
  final IconData icon; final String text; final bool isDark;
  const _MiniRow({required this.icon, required this.text, required this.isDark});
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Padding(padding: const EdgeInsets.only(top: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 13, color: secondary.withOpacity(0.6)), const SizedBox(width: 8),
      Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5))),
    ]));
  }
}
