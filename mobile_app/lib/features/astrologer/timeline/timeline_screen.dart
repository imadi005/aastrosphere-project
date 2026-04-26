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

    if (activeDob == null) {
      return _NoDobState(isDark: isDark, gold: gold);
    }
    return _TimelineBody(dob: activeDob, isDark: isDark, gold: gold);
  }
}

class _NoDobState extends StatelessWidget {
  final bool isDark; final Color gold;
  const _NoDobState({required this.isDark, required this.gold});
  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.timeline_outlined, size: 40, color: gold.withOpacity(0.4)),
      const SizedBox(height: 16),
      Text('No DOB Selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
      const SizedBox(height: 8),
      Text('Enter a client DOB in the Chart tab to view the Mahadasha timeline', textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
    ])));
  }
}

class _TimelineBody extends StatelessWidget {
  final DateTime dob; final bool isDark; final Color gold;
  const _TimelineBody({required this.dob, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mahaList = NumerologyEngine.mahadashaTimeline(dob, pastYears: 15, futureYears: 50);
    final antarList = NumerologyEngine.antardashaTimeline(dob, pastYears: 3, futureYears: 10);
    final currentMaha = NumerologyEngine.currentMahadasha(dob);
    final currentAntar = NumerologyEngine.currentAntardasha(dob);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child:
          Text('Timeline', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400))),
        // Current summary
        _CurrentSummary(maha: currentMaha, antar: currentAntar, isDark: isDark, gold: gold),
        const SizedBox(height: 4),
        Expanded(child: DefaultTabController(length: 2, child: Column(children: [
          TabBar(
            labelColor: gold,
            unselectedLabelColor: secondary,
            indicatorColor: gold,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
            tabs: const [Tab(text: 'Mahadasha'), Tab(text: 'Antardasha')],
          ),
          Expanded(child: TabBarView(children: [
            _MahaList(list: mahaList, isDark: isDark, gold: gold),
            _AntarList(list: antarList, isDark: isDark, gold: gold),
          ])),
        ]))),
      ])),
    );
  }
}

class _CurrentSummary extends StatelessWidget {
  final DashaResult maha, antar; final bool isDark; final Color gold;
  const _CurrentSummary({required this.maha, required this.antar, required this.isDark, required this.gold});
  String _fmtDate(DateTime d) { const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child:
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MAHA', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
            const SizedBox(height: 2),
            Text('${maha.number} · ${maha.planet}', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: gold)),
            Text('until ${_fmtDate(maha.end)}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
          ])),
          Container(width: 0.5, height: 40, color: border),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ANTAR', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1, color: green)),
            const SizedBox(height: 2),
            Text('${antar.number} · ${antar.planet}', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: green)),
            Text('until ${_fmtDate(antar.end)}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
          ])),
        ]),
      ));
  }
}

class _MahaList extends StatelessWidget {
  final List<DashaResult> list; final bool isDark; final Color gold;
  const _MahaList({required this.list, required this.isDark, required this.gold});
  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final currentIdx = list.indexWhere((d) => d.isCurrent);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final d = list[i];
        final isCurrent = d.isCurrent;
        final isPast = d.isPast;
        final color = isCurrent ? gold : (isPast ? secondary.withOpacity(0.5) : primary);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Timeline line
          Column(children: [
            Container(width: 1.5, height: i == 0 ? 20 : 0, color: Colors.transparent),
            Container(width: 10, height: 10, decoration: BoxDecoration(
              color: isCurrent ? gold : (isPast ? secondary.withOpacity(0.3) : secondary.withOpacity(0.4)),
              shape: BoxShape.circle,
              border: isCurrent ? Border.all(color: gold.withOpacity(0.4), width: 2.5) : null,
            )),
            Container(width: 1.5, height: 60, color: i < list.length - 1 ? border : Colors.transparent),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent ? gold.withOpacity(0.07) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isCurrent ? gold.withOpacity(0.3) : border, width: isCurrent ? 0.8 : 0.5),
            ),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(d.number.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 18, color: color)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(d.planet, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
                  if (isCurrent) ...[const SizedBox(width: 6),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: gold.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: gold, letterSpacing: 0.5))),
                  ],
                ]),
                Text('${_fmtDate(d.start)} — ${_fmtDate(d.end)}',
                    style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
                Text('${d.end.year - d.start.year} yr period', style: GoogleFonts.dmSans(fontSize: 10, color: secondary.withOpacity(0.6))),
              ])),
            ]),
          ))),
        ]);
      },
    );
  }
}

class _AntarList extends StatelessWidget {
  final List<DashaResult> list; final bool isDark; final Color gold;
  const _AntarList({required this.list, required this.isDark, required this.gold});
  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final d = list[i];
        final isCurrent = d.isCurrent;
        final isPast = d.isPast;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent ? green.withOpacity(0.07) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isCurrent ? green.withOpacity(0.3) : border, width: isCurrent ? 0.8 : 0.5),
          ),
          child: Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: (isCurrent ? green : (isPast ? secondary.withOpacity(0.3) : primary.withOpacity(0.08))).withOpacity(0.15), borderRadius: BorderRadius.circular(7)),
              child: Center(child: Text(d.number.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 17, color: isCurrent ? green : (isPast ? secondary.withOpacity(0.4) : primary))))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(d.planet, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: isCurrent ? green : (isPast ? secondary.withOpacity(0.5) : primary))),
                if (isCurrent) ...[const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: green, letterSpacing: 0.5))),
                ],
              ]),
              Text('${d.start.year} — ${d.end.year}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
            ])),
          ]),
        );
      },
    );
  }
}
