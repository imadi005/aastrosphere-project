import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../providers/astro_client_provider.dart';
import '../../auth/providers/user_provider.dart';

// ─── Grid position map (same as grid widget) ────────────────────────────────
const _planetLabels = [
  ['Jupiter', 'Sun', 'Mars'],
  ['Venus', 'Ketu', 'Mercury'],
  ['Moon', 'Saturn', 'Rahu'],
];

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
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timeline_outlined, size: 40, color: gold.withOpacity(0.4)), const SizedBox(height: 16),
        Text('No DOB selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
        const SizedBox(height: 8),
        Text('Enter a client DOB in the Chart tab', textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      ])));
  }
}

class _TimelineBody extends StatefulWidget {
  final DateTime dob; final bool isDark; final Color gold;
  const _TimelineBody({required this.dob, required this.isDark, required this.gold});
  @override State<_TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<_TimelineBody> with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _mahaPast = 10, _mahaFuture = 30;
  int _antarPast = 3, _antarFuture = 10;
  int _monthlyPast = 3, _monthlyFuture = 12;

  @override void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final currentMaha = NumerologyEngine.currentMahadasha(widget.dob);
    final currentAntar = NumerologyEngine.currentAntardasha(widget.dob);
    final currentMonthly = NumerologyEngine.currentMonthlyDasha(widget.dob);
    final green = isDark ? AppColors.successDark : AppColors.success;
    final indigo = const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8),
          child: Text('Timeline', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400))),

        // Current summary strip
        Padding(padding: const EdgeInsets.fromLTRB(16,0,16,10),
          child: Row(children: [
            _PeriodPill(number: currentMaha.number, label: 'Maha', end: currentMaha.end, color: gold),
            const SizedBox(width: 8),
            _PeriodPill(number: currentAntar.number, label: 'Antar', end: currentAntar.end, color: green),
            const SizedBox(width: 8),
            _PeriodPill(number: currentMonthly.number, label: 'Monthly', end: currentMonthly.end, color: indigo),
          ])),

        TabBar(
          controller: _tab,
          labelColor: gold, unselectedLabelColor: secondary,
          indicatorColor: gold, indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          tabs: const [Tab(text: 'Mahadasha'), Tab(text: 'Antardasha'), Tab(text: 'Monthly')],
        ),

        Expanded(child: TabBarView(controller: _tab, children: [
          // ── MAHA ──────────────────────────────────────────────────────────
          Column(children: [
            _RangeBar(pastVal: _mahaPast, futureVal: _mahaFuture, isDark: isDark, gold: gold,
              pastOpts: const [3,5,10,15,20,30,50], futureOpts: const [5,10,20,30,50,80,100],
              onChanged: (p,f) => setState(() { _mahaPast = p; _mahaFuture = f; })),
            Expanded(child: _DashaList(
              dob: widget.dob, isDark: isDark, gold: gold, color: gold,
              items: NumerologyEngine.mahadashaTimeline(widget.dob, pastYears: _mahaPast, futureYears: _mahaFuture),
              tabType: 'maha',
            )),
          ]),
          // ── ANTAR ─────────────────────────────────────────────────────────
          Column(children: [
            _RangeBar(pastVal: _antarPast, futureVal: _antarFuture, isDark: isDark, gold: gold,
              pastOpts: const [1,3,5,10,15,20], futureOpts: const [3,5,10,20,30,50],
              onChanged: (p,f) => setState(() { _antarPast = p; _antarFuture = f; })),
            Expanded(child: _DashaList(
              dob: widget.dob, isDark: isDark, gold: gold, color: green,
              items: NumerologyEngine.antardashaTimeline(widget.dob, pastYears: _antarPast, futureYears: _antarFuture),
              tabType: 'antar',
            )),
          ]),
          // ── MONTHLY ───────────────────────────────────────────────────────
          Column(children: [
            _RangeBar(pastVal: _monthlyPast, futureVal: _monthlyFuture, isDark: isDark, gold: gold,
              pastOpts: const [1,2,3,6], futureOpts: const [6,12,18,24],
              pastLabel: 'mo', futureLabel: 'mo',
              onChanged: (p,f) => setState(() { _monthlyPast = p; _monthlyFuture = f; })),
            Expanded(child: _DashaList(
              dob: widget.dob, isDark: isDark, gold: gold, color: indigo,
              items: NumerologyEngine.monthlyTimeline(widget.dob, pastMonths: _monthlyPast, futureMonths: _monthlyFuture),
              tabType: 'monthly',
            )),
          ]),
        ])),
      ])),
    );
  }
}

// ─── Range bar ────────────────────────────────────────────────────────────────
class _RangeBar extends StatelessWidget {
  final int pastVal, futureVal;
  final List<int> pastOpts, futureOpts;
  final bool isDark; final Color gold;
  final void Function(int,int) onChanged;
  final String pastLabel, futureLabel;
  const _RangeBar({required this.pastVal, required this.futureVal, required this.pastOpts,
      required this.futureOpts, required this.isDark, required this.gold,
      required this.onChanged, this.pastLabel = 'yr', this.futureLabel = 'yr'});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
      child: Row(children: [
        Text('Past:', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)), const SizedBox(width: 6),
        _YearPicker(value: pastVal, options: pastOpts, unit: pastLabel, gold: gold, isDark: isDark,
            onChanged: (v) => onChanged(v, futureVal)),
        const SizedBox(width: 16),
        Text('Ahead:', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)), const SizedBox(width: 6),
        _YearPicker(value: futureVal, options: futureOpts, unit: futureLabel, gold: gold, isDark: isDark,
            onChanged: (v) => onChanged(pastVal, v)),
      ]),
    );
  }
}

class _YearPicker extends StatelessWidget {
  final int value; final List<int> options; final String unit;
  final Color gold; final bool isDark; final ValueChanged<int> onChanged;
  const _YearPicker({required this.value, required this.options, required this.unit,
      required this.gold, required this.isDark, required this.onChanged});
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
          const SizedBox(height: 4),
          ...options.map((o) => ListTile(dense: true,
            title: Text('$o $unit', style: GoogleFonts.dmSans(fontSize: 14, color: o == value ? gold : primary, fontWeight: o == value ? FontWeight.w600 : FontWeight.w400)),
            trailing: o == value ? Icon(Icons.check, size: 16, color: gold) : null,
            onTap: () { Navigator.pop(context); onChanged(o); })),
          const SizedBox(height: 8),
        ])),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: gold.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$value', style: GoogleFonts.dmSans(fontSize: 12, color: gold, fontWeight: FontWeight.w600)),
          const SizedBox(width: 3),
          Icon(Icons.arrow_drop_down, size: 14, color: gold),
        ])));
  }
}

// ─── Dasha list (shared across all 3 tabs) ────────────────────────────────────
class _DashaList extends StatelessWidget {
  final DateTime dob;
  final List<DashaResult> items;
  final bool isDark; final Color gold, color;
  final String tabType; // 'maha' | 'antar' | 'monthly'
  const _DashaList({required this.dob, required this.items, required this.isDark,
      required this.gold, required this.color, required this.tabType});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text('No data', style: GoogleFonts.dmSans(fontSize: 13)));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _DashaCard(
        dob: dob, item: items[i], isDark: isDark, gold: gold, color: color, tabType: tabType,
        isFirst: i == 0, isLast: i == items.length - 1,
      ),
    );
  }
}

// ─── Single dasha card (expandable) ──────────────────────────────────────────
class _DashaCard extends StatefulWidget {
  final DateTime dob;
  final DashaResult item;
  final bool isDark, isFirst, isLast;
  final Color gold, color;
  final String tabType;
  const _DashaCard({required this.dob, required this.item, required this.isDark,
      required this.gold, required this.color, required this.tabType,
      required this.isFirst, required this.isLast});
  @override State<_DashaCard> createState() => _DashaCardState();
}

class _DashaCardState extends State<_DashaCard> {
  bool _open = false;

  @override void initState() {
    super.initState();
    if (widget.item.isCurrent) _open = true;
  }

  void _toggle() => setState(() => _open = !_open);

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  String _duration() {
    final d = widget.item;
    if (widget.tabType == 'monthly') {
      final days = d.end.difference(d.start).inDays;
      return '$days days';
    }
    final yrs = d.end.year - d.start.year;
    return yrs == 1 ? '1 yr' : '$yrs yrs';
  }

  // Get maha number active at a given date
  int _mahaAt(DateTime date) {
    final basic = NumerologyEngine.basicNumber(widget.dob.day);
    final cycle = NumerologyEngine.buildDashaCycle(basic);
    DateTime cur = DateTime(widget.dob.year, widget.dob.month, widget.dob.day);
    int idx = 0;
    while (idx < 200) {
      final dasha = cycle[idx % 9];
      final dur = NumerologyEngine.dashaDurations[dasha]!;
      final end = DateTime(cur.year + dur, cur.month, cur.day);
      if (!date.isBefore(cur) && date.isBefore(end)) return dasha;
      cur = end; idx++;
    }
    return basic;
  }

  // Get antar number active at a given date
  int _antarAt(DateTime date) {
    final basic = NumerologyEngine.basicNumber(widget.dob.day);
    final month = widget.dob.month;
    final day = widget.dob.day;
    final bdayThisYear = DateTime(date.year, month, day);
    final antarYear = date.isBefore(bdayThisYear) ? date.year - 1 : date.year;
    final weekday = DateTime(antarYear, month, day).weekday % 7;
    final weekdayVal = NumerologyEngine.weekdayValues[weekday]!;
    final yearLast2 = antarYear % 100;
    final raw = basic + month + yearLast2 + weekdayVal;
    return NumerologyEngine.reduceToSingle(raw);
  }

  // Build grid for this period — uses mid-point of the period
  List<List<GridCell>> _buildPeriodGrid() {
    final d = widget.item;
    // Use midpoint of the period so we get accurate maha/antar for that time
    final mid = d.start.add(Duration(days: d.end.difference(d.start).inDays ~/ 2));
    switch (widget.tabType) {
      case 'maha':
        return NumerologyEngine.buildGrid(widget.dob,
            mahaOverride: d.number, antarOverride: _antarAt(mid), monthlyOverride: null);
      case 'antar':
        return NumerologyEngine.buildGrid(widget.dob,
            mahaOverride: _mahaAt(mid), antarOverride: d.number, monthlyOverride: null);
      case 'monthly':
      default:
        return NumerologyEngine.buildGrid(widget.dob,
            mahaOverride: _mahaAt(mid), antarOverride: _antarAt(mid), monthlyOverride: d.number);
    }
  }

  // Compute maha + antar active at midpoint of this period
  Map<String, int> _periodNumbers() {
    final d = widget.item;
    final mid = d.start.add(Duration(days: d.end.difference(d.start).inDays ~/ 2));
    final int maha, antar, monthly;
    switch (widget.tabType) {
      case 'maha':
        maha = d.number; antar = _antarAt(mid); monthly = 0;
        break;
      case 'antar':
        maha = _mahaAt(mid); antar = d.number; monthly = 0;
        break;
      case 'monthly':
      default:
        maha = _mahaAt(mid); antar = _antarAt(mid); monthly = d.number;
    }
    return {'maha': maha, 'antar': antar, 'monthly': monthly};
  }

  // Build real insights from actual combinations
  List<_InsightLine> _insights() {
    final nums = _periodNumbers();
    final int maha = nums['maha']!, antar = nums['antar']!, monthly = nums['monthly']!;
    final basic = NumerologyEngine.basicNumber(widget.dob.day);
    final destiny = NumerologyEngine.destinyNumber(widget.dob);
    final natalNums = NumerologyEngine.chartDigits(widget.dob).toSet();
    final allNums = {...natalNums, maha, antar, if (monthly > 0) monthly};
    final lines = <_InsightLine>[];

    // ── Period title ─────────────────────────────────────────────────────────
    const planetDesc = {
      1: 'Career, authority, government connections, and ego come forward.',
      2: 'Emotions, relationships, creativity, and mood sensitivity are heightened.',
      3: 'Wisdom, family, teaching, counselling, and spiritual growth.',
      4: 'Disruption, sudden changes, travel, foreign connections, and confusion.',
      5: 'Business, communication, cash flow, trade, and quick decisions.',
      6: 'Love, comfort, luxury, relationships, and financial ease.',
      7: 'Detachment, spirituality, travel, intuition, and inner work.',
      8: 'Discipline, delays, hard work, justice, and slow but real results.',
      9: 'High energy, action, courage, aggression, and physical intensity.',
    };
    final periodNum = widget.item.number;
    if (planetDesc[periodNum] != null) {
      lines.add(_InsightLine(text: '${NumerologyEngine.planetNames[periodNum]} period — ${planetDesc[periodNum]}', type: 'period'));
    }

    // ── Combination insights (maha × antar) ──────────────────────────────────
    const combos = {
      '1_2': 'Sun meets Moon — career and personal life both demand attention. High visibility period. Emotional health needs care.',
      '1_4': 'Sun meets Rahu — ambitious but unstable. Big opportunities, big disruptions. Watch impulsive decisions.',
      '1_6': 'Sun meets Venus — career and finances both strong. Good for promotions, relationships, and money.',
      '1_7': 'Sun meets Ketu — luck is active. Career breakthroughs possible. Some detachment from material things.',
      '1_8': 'Sun meets Saturn — hard work required. Authority challenged. Defamation risk if ego is unchecked.',
      '1_9': 'Sun meets Mars — powerful energy. Leadership peaks. Anger and accidents need caution.',
      '2_4': 'Moon meets Rahu — emotional instability. Deception risk. Guard finances and trust carefully.',
      '2_7': 'Moon meets Ketu — deeply spiritual period. Intuition sharp. Emotional sensitivity very high.',
      '2_8': 'Moon meets Saturn — depression risk. Emotional heaviness. Discipline helps navigate this period.',
      '2_9': 'Moon meets Mars — emotional aggression. Arguments in relationships. Channel energy into creative work.',
      '3_4': 'Jupiter meets Rahu — wisdom tested by confusion. Good for research and spiritual work. Avoid shortcuts.',
      '3_9': 'Jupiter meets Mars — strong action with wisdom. Good for leadership, teaching, and expansion.',
      '4_9': 'Rahu meets Mars — HIGH ACCIDENT RISK. This is the most physically dangerous combination. Drive carefully, avoid rushing, stay grounded.',
      '4_8': 'Rahu meets Saturn — delays, frustration, and obstacles. Results come very slowly. Do not lose patience.',
      '4_2': 'Rahu meets Moon — emotionally unstable, prone to being deceived. Keep finances guarded.',
      '5_4': 'Mercury meets Rahu — financial impulsiveness. Easy money thinking leads to losses. Budget strictly.',
      '5_6': 'Mercury meets Venus — excellent for business, trade, and relationships. Cash flow and romance both active.',
      '5_7': 'Mercury meets Ketu — easy money and luck combination. Financial gains with less effort.',
      '6_4': 'Venus meets Rahu — relationship complications. Attraction without stability. Guard against deception in love.',
      '7_4': 'Ketu meets Rahu — highly unstable spiritually and materially. Inner confusion. Avoid major decisions.',
      '7_8': 'Ketu meets Saturn — bad luck delayed results. Financial and personal setbacks likely. Stay patient.',
      '8_9': 'Saturn meets Mars — relentless hard work, heavy load. Protect health — heart and blood pressure risk.',
      '9_4': 'Mars meets Rahu — HIGH ACCIDENT RISK. Impulsive actions cause physical harm. Slow down in all areas.',
      '9_8': 'Mars meets Saturn — immense determination, heavy load. Physical health must be protected.',
    };

    final key1 = '${maha}_$antar';
    final key2 = '${antar}_$maha';
    final combo = combos[key1] ?? combos[key2];
    if (combo != null) {
      final isHigh = combo.contains('HIGH ACCIDENT');
      lines.add(_InsightLine(text: combo, type: isHigh ? 'danger' : 'combo'));
    }

    // ── Yoga detection ───────────────────────────────────────────────────────
    // Raj Yoga
    if (allNums.contains(1) && allNums.contains(2) && !natalNums.contains(3) && !natalNums.contains(6)) {
      lines.add(_InsightLine(text: 'Raj Yoga active — authority and career advancement strongly supported. High rise possible.', type: 'positive'));
    }
    // Sun-Ketu Raj Yoga
    if (natalNums.contains(1) && natalNums.contains(7) && !natalNums.contains(8)) {
      lines.add(_InsightLine(text: 'Continuous Luck active — things tend to work out, often unexpectedly.', type: 'positive'));
    }
    // Easy Money
    if (allNums.contains(5) && allNums.contains(7)) {
      lines.add(_InsightLine(text: 'Easy Money combination — financial gains arrive with less effort than usual.', type: 'positive'));
    }
    // 319
    if (allNums.contains(3) && allNums.contains(1) && allNums.contains(9)) {
      lines.add(_InsightLine(text: '3-1-9 uplift combination — very positive period for growth, career, and confidence.', type: 'positive'));
    }
    // Bandhan
    if (allNums.contains(9) && allNums.contains(4) && !allNums.contains(5)) {
      lines.add(_InsightLine(text: 'Bandhan Yoga — feeling stuck or restricted. Avoid new loans or big commitments.', type: 'warning'));
    }
    // Financial Bandhan
    if (allNums.contains(5) && allNums.contains(4) && !allNums.contains(9)) {
      lines.add(_InsightLine(text: 'Financial Bandhan — debt risk is real. Impulsive spending can cause lasting damage.', type: 'warning'));
    }
    // Vipreet Raj
    if (allNums.contains(2) && allNums.contains(8) && allNums.contains(4)) {
      lines.add(_InsightLine(text: 'Vipreet Raj Yoga — setbacks that eventually lead to growth. Avoid addictions.', type: 'warning'));
    }
    // Spiritual
    if (allNums.contains(3) && allNums.contains(7) && allNums.contains(9)) {
      lines.add(_InsightLine(text: 'Spiritual Yoga (3-7-9) — deep inner wisdom accessible. Good for healing and spiritual work.', type: 'positive'));
    }

    // ── Accident risk ────────────────────────────────────────────────────────
    if ((maha == 4 && antar == 9) || (maha == 9 && antar == 4)) {
      if (!lines.any((l) => l.text.contains('ACCIDENT'))) {
        lines.add(_InsightLine(text: 'HIGH ACCIDENT RISK — most dangerous dasha combination. Drive slowly, avoid rushing, double-check everything.', type: 'danger'));
      }
    } else if ((maha == 4 && natalNums.contains(9)) || (maha == 9 && natalNums.contains(4))) {
      lines.add(_InsightLine(text: 'Accident caution — physical awareness needed. Avoid risky activities.', type: 'warning'));
    }

    // ── Health flags ─────────────────────────────────────────────────────────
    if (maha == 2 || antar == 2) {
      lines.add(_InsightLine(text: 'Mental health watch — risk of low mood, sadness, insomnia. Stay connected with trusted people.', type: 'warning'));
    }
    if ((maha == 8 || antar == 8) && (basic == 8 || destiny == 8)) {
      lines.add(_InsightLine(text: 'Bone, joint, and dental health needs attention during this period.', type: 'warning'));
    }
    if ((maha == 9 || antar == 9) && (basic == 9 || destiny == 9)) {
      lines.add(_InsightLine(text: 'Blood pressure and high fever risk. Physical health checkup recommended.', type: 'warning'));
    }

    // ── Finance ──────────────────────────────────────────────────────────────
    if (allNums.contains(6) && allNums.contains(1)) {
      lines.add(_InsightLine(text: 'Strong financial period — career money and prosperity both supported.', type: 'positive'));
    }
    if ((maha == 4 || antar == 4)) {
      if (!lines.any((l) => l.text.contains('spending') || l.text.contains('Bandhan'))) {
        lines.add(_InsightLine(text: 'Watch spending — Rahu active brings impulsive financial decisions.', type: 'warning'));
      }
    }

    // ── Relationship ─────────────────────────────────────────────────────────
    if ([3, 2, 7, 6, 9].contains(antar) && !lines.any((l) => l.text.contains('marriage'))) {
      lines.add(_InsightLine(text: 'Favorable period for deepening relationships or marriage.', type: 'positive'));
    }
    if (maha == 4) {
      lines.add(_InsightLine(text: 'Long Rahu period — distance can grow in close relationships. Communicate more.', type: 'warning'));
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = widget.gold;
    final color = widget.color;
    final d = widget.item;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final isCurrent = d.isCurrent;
    final isPast = d.isPast;
    final numColor = isCurrent ? color : (isPast ? secondary.withOpacity(0.4) : primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isCurrent ? color.withOpacity(0.07) : cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isCurrent ? color.withOpacity(0.3) : border, width: isCurrent ? 0.8 : 0.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header row
            Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(color: numColor.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text('${d.number}', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: numColor)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(d.planet, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: numColor)),
                  if (isCurrent) ...[const SizedBox(width: 6), _NowBadge(color: color)],
                ]),
                Text('${_fmtDate(d.start)}  →  ${_fmtDate(d.end)}', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_duration(), style: GoogleFonts.dmSans(fontSize: 11, color: secondary.withOpacity(0.7))),
                const SizedBox(height: 4),
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: secondary),
              ]),
            ])),

            // Expanded content
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _open ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Divider(height: 1, color: border),
                Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: _InsightCards(insights: _insights(), isDark: isDark, gold: gold)),
                Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: _PeriodGrid(grid: _buildPeriodGrid(), isDark: isDark, gold: gold, color: color, tabType: widget.tabType, dashaNum: d.number)),
              ]) : const SizedBox.shrink()),
          ]),
        ),
      ),
    );
  }
}

// ─── Period grid ─────────────────────────────────────────────────────────────
class _PeriodGrid extends StatelessWidget {
  final List<List<GridCell>> grid;
  final bool isDark; final Color gold, color;
  final String tabType; final int dashaNum;
  const _PeriodGrid({required this.grid, required this.isDark, required this.gold,
      required this.color, required this.tabType, required this.dashaNum});

  @override
  Widget build(BuildContext context) {
    if (grid.isEmpty) return const SizedBox.shrink();
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgSubtleLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final indigo = const Color(0xFF6366F1);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Legend
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Wrap(spacing: 10, children: [
        _LegendDot(color: gold, label: 'Natal'),
        if (tabType == 'maha') _LegendDot(color: color, label: 'Maha ${dashaNum}'),
        if (tabType == 'antar') ...[_LegendDot(color: gold, label: 'Maha'), _LegendDot(color: color, label: 'Antar ${dashaNum}')],
        if (tabType == 'monthly') ...[_LegendDot(color: gold, label: 'Maha'), _LegendDot(color: green, label: 'Antar'), _LegendDot(color: color, label: 'Monthly ${dashaNum}')],
      ])),
      // Grid
      Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
        child: Column(children: List.generate(3, (row) => Row(
          children: List.generate(3, (col) {
            final cell = grid[row][col];
            final planet = _planetLabels[row][col];
            return Expanded(child: Container(
              height: 72,
              decoration: BoxDecoration(border: Border(
                right: col == 2 ? BorderSide.none : BorderSide(color: border, width: 0.5),
                bottom: row == 2 ? BorderSide.none : BorderSide(color: border, width: 0.5),
              )),
              child: _GridCell(cell: cell, planet: planet, isDark: isDark, gold: gold, color: color, tabType: tabType),
            ));
          }),
        ))),
      ),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 4),
    Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: color)),
  ]);
}

class _GridCell extends StatelessWidget {
  final GridCell cell; final String planet;
  final bool isDark; final Color gold, color; final String tabType;
  const _GridCell({required this.cell, required this.planet, required this.isDark,
      required this.gold, required this.color, required this.tabType});

  Color _highlightColor(GridHighlight h, bool isDark, Color gold, Color color) {
    final green = isDark ? AppColors.successDark : AppColors.success;
    final indigo = const Color(0xFF6366F1);
    switch (h) {
      case GridHighlight.maha:    return tabType == 'maha' ? color : gold;
      case GridHighlight.antar:   return tabType == 'antar' ? color : green;
      case GridHighlight.monthly: return tabType == 'monthly' ? color : indigo;
      default: return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    if (cell.number == 0) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('—', style: GoogleFonts.dmSans(fontSize: 14, color: textTertiary)),
        const SizedBox(height: 2),
        Text(planet, style: GoogleFonts.dmSans(fontSize: 7, color: textTertiary)),
      ]));
    }
    return Padding(padding: const EdgeInsets.all(4), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Wrap(alignment: WrapAlignment.center, spacing: 1, children: List.generate(cell.count, (i) {
        Color c = primary;
        if (cell.highlights.isNotEmpty && i < cell.highlights.length) {
          c = _highlightColor(cell.highlights[i], isDark, gold, color);
        } else if (cell.highlights.isNotEmpty) {
          c = _highlightColor(cell.highlights.last, isDark, gold, color);
        }
        return Text('${cell.number}', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: c, height: 1.1));
      })),
      const SizedBox(height: 2),
      Text(planet, style: GoogleFonts.dmSans(fontSize: 7, color: textTertiary), textAlign: TextAlign.center),
    ]));
  }
}

// ─── Small shared widgets ─────────────────────────────────────────────────────
class _PeriodPill extends StatelessWidget {
  final int number; final String label; final DateTime end; final Color color;
  const _PeriodPill({required this.number, required this.label, required this.end, required this.color});
  String _fmtShort(DateTime d) { const m=['Jan','Feb','Mar','Apr']; return '${d.month}/${d.year}'; }
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 8, color: color.withOpacity(0.7), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      Text('$number · ${NumerologyEngine.planetNames[number]??''}',
          style: GoogleFonts.dmSans(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]));
}

class _NowBadge extends StatelessWidget {
  final Color color;
  const _NowBadge({required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
    child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)));
}

// ─── Insight data model ───────────────────────────────────────────────────────
class _InsightLine {
  final String text;
  final String type; // 'period' | 'combo' | 'positive' | 'warning' | 'danger'
  const _InsightLine({required this.text, required this.type});
}

// ─── Insight cards widget ─────────────────────────────────────────────────────
class _InsightCards extends StatelessWidget {
  final List<_InsightLine> insights;
  final bool isDark;
  final Color gold;
  const _InsightCards({required this.insights, required this.isDark, required this.gold});

  Color _color(_InsightLine line) {
    final green = isDark ? AppColors.successDark : AppColors.success;
    final orange = isDark ? AppColors.warningDark : AppColors.warning;
    final red = isDark ? AppColors.dangerDark : AppColors.danger;
    switch (line.type) {
      case 'danger':   return red;
      case 'warning':  return orange;
      case 'positive': return green;
      case 'combo':    return const Color(0xFF6366F1);
      case 'period':   return gold;
      default:         return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    }
  }

  IconData _icon(_InsightLine line) {
    switch (line.type) {
      case 'danger':   return Icons.warning_rounded;
      case 'warning':  return Icons.warning_amber_outlined;
      case 'positive': return Icons.star_outline;
      case 'combo':    return Icons.link;
      case 'period':   return Icons.radio_button_unchecked;
      default:         return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: insights.map((line) {
        final c = _color(line);
        final isAccent = line.type == 'danger' || line.type == 'warning';
        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: c.withOpacity(isAccent ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: c.withOpacity(isAccent ? 0.3 : 0.15), width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(_icon(line), size: 13, color: c),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                line.text,
                style: GoogleFonts.dmSans(fontSize: 12, color: isAccent ? c : primary, height: 1.55),
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }
}
