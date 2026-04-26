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

class _AstroDailyScreenState extends ConsumerState<AstroDailyScreen> {
  Map<String, dynamic>? _data;
  bool _loading = false;
  String? _error;
  DateTime? _loadedFor;

  Future<void> _load(DateTime dob) async {
    if (_loadedFor == dob) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.getDeepInsights(
          '${dob.year}-${dob.month.toString().padLeft(2,'0')}-${dob.day.toString().padLeft(2,'0')}');
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

    if (activeDob == null) return _NoDobState(isDark: isDark, gold: gold);
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
            ? _ErrView(error: _error!, onRetry: () => _load(activeDob), gold: gold)
            : _data == null ? const SizedBox.shrink()
            : _PatternBody(dob: activeDob, data: _data!, isDark: isDark, gold: gold)),
      ])),
    );
  }
}

class _NoDobState extends StatelessWidget {
  final bool isDark; final Color gold;
  const _NoDobState({required this.isDark, required this.gold});
  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Scaffold(backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_outline, size: 40, color: gold.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text('No DOB Selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
        const SizedBox(height: 8),
        Text('Enter a client DOB in the Chart tab to view the life pattern', textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      ]))));
  }
}

class _ErrView extends StatelessWidget {
  final String error; final VoidCallback onRetry; final Color gold;
  const _ErrView({required this.error, required this.onRetry, required this.gold});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(error, style: GoogleFonts.dmSans(fontSize: 13)), const SizedBox(height: 12),
    GestureDetector(onTap: onRetry, child: Text('Retry', style: GoogleFonts.dmSans(color: gold, fontWeight: FontWeight.w600))),
  ]));
}

class _PatternBody extends StatelessWidget {
  final DateTime dob; final Map<String, dynamic> data; final bool isDark; final Color gold;
  const _PatternBody({required this.dob, required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final basic = data['basic'] as int? ?? NumerologyEngine.basicNumber(dob.day);
    final destiny = data['destiny'] as int? ?? NumerologyEngine.destinyNumber(dob);
    final basicProfile = data['basic_profile'] as Map<String,dynamic>? ?? {};
    final combo = data['combination'] as String? ?? data['combo'] as String? ?? '';
    final pattern = data['pattern'] as String? ?? data['personal_pattern'] as String? ?? '';
    final dashaExp = data['dasha_experience'] as String? ?? '';
    final shadow = basicProfile['shadow'] as String? ?? '';
    final health = basicProfile['health_real'] as String? ?? '';
    final whatTrips = basicProfile['what_trips_you'] as String? ?? '';
    final currentChapter = basicProfile['current_chapter'] as String? ?? data['current_chapter'] as String? ?? '';
    final realLife = basicProfile['real_life'] as String? ?? '';
    final yogas = (data['yogas'] as List? ?? []).cast<Map<String,dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Number tags
        Row(children: [
          _NumTag(number: basic, label: 'Basic', color: gold, isDark: isDark),
          const SizedBox(width: 8),
          _NumTag(number: destiny, label: 'Destiny', color: gold.withOpacity(0.75), isDark: isDark),
        ]),
        const SizedBox(height: 20),

        // Combination (basic × destiny life pattern)
        if (combo.isNotEmpty) ...[
          _SecLabel(label: 'LIFE COMBINATION', isDark: isDark),
          const SizedBox(height: 8),
          _TextCard(text: combo, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Pattern
        if (pattern.isNotEmpty) ...[
          _SecLabel(label: 'LIFE PATTERN', isDark: isDark),
          const SizedBox(height: 8),
          _TextCard(text: pattern, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Real life
        if (realLife.isNotEmpty) ...[
          _SecLabel(label: 'WHAT THEIR LIFE ACTUALLY LOOKS LIKE', isDark: isDark),
          const SizedBox(height: 8),
          _TextCard(text: realLife, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Current chapter
        if (currentChapter.isNotEmpty) ...[
          _SecLabel(label: 'CURRENT CHAPTER', isDark: isDark),
          const SizedBox(height: 8),
          _AccentCard(text: currentChapter, color: gold, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Dasha experience
        if (dashaExp.isNotEmpty) ...[
          _SecLabel(label: 'CURRENT DASHA EXPERIENCE', isDark: isDark),
          const SizedBox(height: 8),
          _TextCard(text: dashaExp, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Shadow + what trips
        if (shadow.isNotEmpty || whatTrips.isNotEmpty) ...[
          _SecLabel(label: 'SHADOW & BLIND SPOTS', isDark: isDark),
          const SizedBox(height: 8),
          if (shadow.isNotEmpty) _AccentCard(text: shadow, color: isDark ? AppColors.warningDark : AppColors.warning, isDark: isDark),
          if (shadow.isNotEmpty && whatTrips.isNotEmpty) const SizedBox(height: 8),
          if (whatTrips.isNotEmpty) _TextCard(text: whatTrips, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Health
        if (health.isNotEmpty) ...[
          _SecLabel(label: 'HEALTH PATTERN', isDark: isDark),
          const SizedBox(height: 8),
          _TextCard(text: health, isDark: isDark),
          const SizedBox(height: 16),
        ],

        // Yogas summary
        if (yogas.isNotEmpty) ...[
          _SecLabel(label: 'ACTIVE YOGAS', isDark: isDark),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: yogas.take(6).map((y) {
            final name = y['name'] as String? ?? '';
            final isPos = (y['type'] as String?) != 'challenging';
            return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isPos ? gold : (isDark ? AppColors.warningDark : AppColors.warning)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (isPos ? gold : (isDark ? AppColors.warningDark : AppColors.warning)).withOpacity(0.3), width: 0.5),
              ),
              child: Text(name, style: GoogleFonts.dmSans(fontSize: 11, color: isPos ? gold : (isDark ? AppColors.warningDark : AppColors.warning))));
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
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
      child: Text(text, style: GoogleFonts.dmSans(fontSize: 13, color: secondary, height: 1.65)));
  }
}

class _AccentCard extends StatelessWidget {
  final String text; final Color color; final bool isDark;
  const _AccentCard({required this.text, required this.color, required this.isDark});
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
    child: Text(text, style: GoogleFonts.dmSans(fontSize: 13, color: color, height: 1.65)));
}
