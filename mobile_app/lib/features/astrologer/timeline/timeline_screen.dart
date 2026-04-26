import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../providers/astro_client_provider.dart';
import '../../auth/providers/user_provider.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final useClient = ref.watch(astroUseClientDobProvider);
    final clientDob = ref.watch(astroClientDobProvider);
    final userAsync = ref.watch(userProfileProvider);
    final activeDob = useClient ? clientDob : userAsync.valueOrNull?.dob;
    if (activeDob == null) return _NoDob(isDark: isDark, gold: gold);
    return _TimelineBody(dob: activeDob, isDark: isDark, gold: gold);
  }
}

class _NoDob extends StatelessWidget {
  final bool isDark; final Color gold;
  const _NoDob({required this.isDark, required this.gold});
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Scaffold(backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timeline_outlined, size: 40, color: gold.withOpacity(0.4)), const SizedBox(height: 16),
        Text('No DOB Selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)), const SizedBox(height: 8),
        Text('Enter a client DOB in the Chart tab to view the timeline', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      ]))));
  }
}

class _TimelineBody extends StatefulWidget {
  final DateTime dob; final bool isDark; final Color gold;
  const _TimelineBody({required this.dob, required this.isDark, required this.gold});
  @override State<_TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<_TimelineBody> with SingleTickerProviderStateMixin {
  late TabController _tab;
  // Mahadasha range
  int _mahaPast = 10;
  int _mahaFuture = 30;
  // Antardasha range
  int _antarPast = 3;
  int _antarFuture = 10;

  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final currentMaha = NumerologyEngine.currentMahadasha(widget.dob);
    final currentAntar = NumerologyEngine.currentAntardasha(widget.dob);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8),
          child: Text('Timeline', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400))),

        // Current summary
        Padding(padding: const EdgeInsets.fromLTRB(16,0,16,8), child:
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MAHA', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
                const SizedBox(height: 2),
                Text('${currentMaha.number} · ${currentMaha.planet}', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: gold)),
                Text('until ${_fmtDate(currentMaha.end)}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
              ])),
              Container(width: 0.5, height: 36, color: border),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ANTAR', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: isDark ? AppColors.successDark : AppColors.success)),
                const SizedBox(height: 2),
                Text('${currentAntar.number} · ${currentAntar.planet}', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: isDark ? AppColors.successDark : AppColors.success)),
                Text('until ${_fmtDate(currentAntar.end)}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
              ])),
            ]))),

        TabBar(
          controller: _tab,
          labelColor: gold, unselectedLabelColor: secondary,
          indicatorColor: gold, indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          tabs: const [Tab(text: 'Mahadasha'), Tab(text: 'Antardasha')],
        ),

        Expanded(child: TabBarView(controller: _tab, children: [
          // ── MAHADASHA TAB ──────────────────────────────────────────────
          Column(children: [
            _RangeControls(
              pastYears: _mahaPast, futureYears: _mahaFuture,
              isDark: isDark, gold: gold,
              onChanged: (past, future) => setState(() { _mahaPast = past; _mahaFuture = future; }),
            ),
            Expanded(child: _MahaList(
              dob: widget.dob, isDark: isDark, gold: gold,
              pastYears: _mahaPast, futureYears: _mahaFuture,
            )),
          ]),
          // ── ANTARDASHA TAB ─────────────────────────────────────────────
          Column(children: [
            _RangeControls(
              pastYears: _antarPast, futureYears: _antarFuture,
              isDark: isDark, gold: gold,
              onChanged: (past, future) => setState(() { _antarPast = past; _antarFuture = future; }),
            ),
            Expanded(child: _AntarList(
              dob: widget.dob, isDark: isDark, gold: gold,
              pastYears: _antarPast, futureYears: _antarFuture,
            )),
          ]),
        ])),
      ])),
    );
  }
}

// ─── Year range controls ──────────────────────────────────────────────────────
class _RangeControls extends StatelessWidget {
  final int pastYears, futureYears;
  final bool isDark; final Color gold;
  final void Function(int past, int future) onChanged;
  const _RangeControls({required this.pastYears, required this.futureYears, required this.isDark, required this.gold, required this.onChanged});

  static const _pastOptions = [3, 5, 10, 15, 20, 30, 50];
  static const _futureOptions = [5, 10, 20, 30, 50, 80, 100];

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
      child: Row(children: [
        Text('Past:', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
        const SizedBox(width: 6),
        _YearPicker(value: pastYears, options: _pastOptions, gold: gold, isDark: isDark,
            onChanged: (v) => onChanged(v, futureYears)),
        const SizedBox(width: 16),
        Text('Future:', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
        const SizedBox(width: 6),
        _YearPicker(value: futureYears, options: _futureOptions, gold: gold, isDark: isDark,
            onChanged: (v) => onChanged(pastYears, v)),
        const Spacer(),
        Text('yrs', style: GoogleFonts.dmSans(fontSize: 10, color: secondary.withOpacity(0.6))),
      ]),
    );
  }
}

class _YearPicker extends StatelessWidget {
  final int value; final List<int> options; final Color gold; final bool isDark; final ValueChanged<int> onChanged;
  const _YearPicker({required this.value, required this.options, required this.gold, required this.isDark, required this.onChanged});
  @override Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return GestureDetector(
      onTap: () => showModalBottomSheet(context: context,
        backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 3, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          ...options.map((o) => ListTile(
            dense: true,
            title: Text('$o years', style: GoogleFonts.dmSans(fontSize: 14, color: o == value ? gold : primary, fontWeight: o == value ? FontWeight.w600 : FontWeight.w400)),
            trailing: o == value ? Icon(Icons.check, size: 16, color: gold) : null,
            onTap: () { Navigator.pop(context); onChanged(o); },
          )),
          const SizedBox(height: 8),
        ])),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: gold.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$value', style: GoogleFonts.dmSans(fontSize: 12, color: gold, fontWeight: FontWeight.w600)),
          const SizedBox(width: 3),
          Icon(Icons.arrow_drop_down, size: 14, color: gold),
        ])),
    );
  }
}

// ─── Mahadasha list ───────────────────────────────────────────────────────────
class _MahaList extends StatelessWidget {
  final DateTime dob; final bool isDark; final Color gold; final int pastYears, futureYears;
  const _MahaList({required this.dob, required this.isDark, required this.gold, required this.pastYears, required this.futureYears});
  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final list = NumerologyEngine.mahadashaTimeline(dob, pastYears: pastYears, futureYears: futureYears);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16,10,16,40),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final d = list[i];
        final isCurrent = d.isCurrent; final isPast = d.isPast;
        final color = isCurrent ? gold : (isPast ? secondary.withOpacity(0.4) : primary);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            if (i == 0) const SizedBox(height: 18),
            Container(width: 10, height: 10, decoration: BoxDecoration(
              color: isCurrent ? gold : (isPast ? secondary.withOpacity(0.25) : secondary.withOpacity(0.35)),
              shape: BoxShape.circle,
              border: isCurrent ? Border.all(color: gold.withOpacity(0.4), width: 2.5) : null)),
            if (i < list.length - 1) Container(width: 1.5, height: 64, color: border),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent ? gold.withOpacity(0.07) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isCurrent ? gold.withOpacity(0.3) : border, width: isCurrent ? 0.8 : 0.5)),
            child: Row(children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
                child: Center(child: Text(d.number.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 17, color: color)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(d.planet, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
                  if (isCurrent) ...[const SizedBox(width: 6),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: gold.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: gold, letterSpacing: 0.5)))],
                ]),
                Text('${_fmtDate(d.start)} — ${_fmtDate(d.end)}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
                Text('${d.end.year - d.start.year} yr', style: GoogleFonts.dmSans(fontSize: 10, color: secondary.withOpacity(0.5))),
              ])),
            ]),
          ))),
        ]);
      });
  }
}

// ─── Antardasha list ──────────────────────────────────────────────────────────
class _AntarList extends StatelessWidget {
  final DateTime dob; final bool isDark; final Color gold; final int pastYears, futureYears;
  const _AntarList({required this.dob, required this.isDark, required this.gold, required this.pastYears, required this.futureYears});
  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final list = NumerologyEngine.antardashaTimeline(dob, pastYears: pastYears, futureYears: futureYears);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16,10,16,40),
      itemCount: list.length,
      separatorBuilder: (_,__) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final d = list[i];
        final isCurrent = d.isCurrent; final isPast = d.isPast;
        final color = isCurrent ? green : (isPast ? secondary.withOpacity(0.4) : primary);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent ? green.withOpacity(0.07) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isCurrent ? green.withOpacity(0.3) : border, width: isCurrent ? 0.8 : 0.5)),
          child: Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
              child: Center(child: Text(d.number.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 17, color: color)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(d.planet, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
                if (isCurrent) ...[const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: green, letterSpacing: 0.5)))],
              ]),
              Text('${d.start.year} — ${d.end.year}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
            ])),
          ]),
        );
      });
  }
}
