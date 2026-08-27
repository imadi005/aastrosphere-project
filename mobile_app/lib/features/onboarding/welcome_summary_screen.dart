import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../shell/app_shell.dart';
import '../user/chart/chart_explainer.dart';
import '../user/chart/chart_screen.dart' show kNeutralEnergyLabel;

/// Shown once, right after signup — before the (text-dense) Today tab.
/// The point is a graphical first impression: a newcomer with zero
/// numerology background should be able to glance at this and get the
/// gist, instead of being dropped straight into paragraphs of jargon.
class WelcomeSummaryScreen extends StatefulWidget {
  final String name;
  final DateTime dob;

  const WelcomeSummaryScreen({super.key, required this.name, required this.dob});

  @override
  State<WelcomeSummaryScreen> createState() => _WelcomeSummaryScreenState();
}

class _WelcomeSummaryScreenState extends State<WelcomeSummaryScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _data;
  bool _loading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await ApiService.getChart(widget.dob.toIso8601String());
      if (mounted) {
        setState(() {
          _data = result;
          _loading = false;
        });
        _fadeController.forward();
      }
    } catch (_) {
      // Chart fetch failing here shouldn't block signup — just skip ahead.
      if (mounted) _continue();
    }
  }

  void _continue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold))
            : FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _continue,
                        child: Text('Skip', style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Hi ${widget.name.split(' ').first},',
                        style: GoogleFonts.cormorantGaramond(fontSize: 26, color: primary)),
                    Text('here\'s your chart at a glance',
                        style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
                    const SizedBox(height: 28),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(children: [
                          _DestinyBadge(data: _data!, isDark: isDark, gold: gold, primary: primary, secondary: secondary),
                          const SizedBox(height: 24),
                          _PlanetWheel(data: _data!, isDark: isDark, gold: gold, primary: primary, secondary: secondary),
                          const SizedBox(height: 24),
                          _CurrentPhaseChip(data: _data!, isDark: isDark, gold: gold, primary: primary, secondary: secondary),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text('Explore My Chart',
                            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ),
      ),
    );
  }
}

// ─── Destiny Number — the big centerpiece ──────────────────────────────────
class _DestinyBadge extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold, primary, secondary;

  const _DestinyBadge({required this.data, required this.isDark, required this.gold, required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    final destiny = data['destiny'] as int;
    final planet = kNeutralEnergyLabel[destiny] ?? '';
    final icon = kPlanetIcon[destiny] ?? Icons.circle;

    return Column(children: [
      Container(
        width: 120, height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [gold.withOpacity(0.18), gold.withOpacity(0.02)]),
          border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: gold, size: 26),
          const SizedBox(height: 2),
          Text('$destiny', style: GoogleFonts.cormorantGaramond(fontSize: 40, color: gold, height: 1)),
        ]),
      ),
      const SizedBox(height: 10),
      Text('Your Destiny Number · $planet',
          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
      const SizedBox(height: 4),
      Text('The overall direction your life tends to move toward.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4)),
    ]);
  }
}

// ─── 3x3 wheel of planets, with the user's active ones lit up ─────────────
class _PlanetWheel extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold, primary, secondary;

  const _PlanetWheel({required this.data, required this.isDark, required this.gold, required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    final maha = (data['maha'] as Map<String, dynamic>)['number'] as int;
    final antar = (data['antar'] as Map<String, dynamic>)['number'] as int;
    final basic = data['basic'] as int;
    final active = {maha, antar, basic};

    const order = [3, 1, 9, 6, 7, 5, 2, 8, 4];
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: order.map((n) {
        final isActive = active.contains(n);
        final icon = kPlanetIcon[n] ?? Icons.circle;
        return Container(
          width: 56, height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? gold.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: isActive ? gold : border, width: isActive ? 1.5 : 0.5),
          ),
          child: Icon(icon, size: 18, color: isActive ? gold : secondary.withOpacity(0.5)),
        );
      }).toList(),
    );
  }
}

// ─── "Right now" chip — the phase currently active ─────────────────────────
class _CurrentPhaseChip extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold, primary, secondary;

  const _CurrentPhaseChip({required this.data, required this.isDark, required this.gold, required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    final maha = (data['maha'] as Map<String, dynamic>)['number'] as int;
    final planet = kNeutralEnergyLabel[maha] ?? '';
    final meaning = kPlanetMeaning[maha] ?? '';
    final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(children: [
        Icon(kPlanetIcon[maha] ?? Icons.circle, color: gold, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Right now: your $planet phase',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
          if (meaning.isNotEmpty)
            Text(meaning, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4)),
        ])),
      ]),
    );
  }
}
