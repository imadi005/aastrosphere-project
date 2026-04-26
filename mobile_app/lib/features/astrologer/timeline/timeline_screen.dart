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

class _DashaCardState extends State<_DashaCard> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    if (widget.item.isCurrent) {
      _open = true;
      _anim.value = 1.0;
    }
  }
  @override void dispose() { _anim.dispose(); super.dispose(); }

  void _toggle() {
    setState(() { _open = !_open; });
    if (_open) _anim.forward(); else _anim.reverse();
  }

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

  // Build grid for this period
  List<List<GridCell>> _buildPeriodGrid() {
    final d = widget.item;
    switch (widget.tabType) {
      case 'maha':
        return NumerologyEngine.buildGrid(widget.dob, mahaOverride: d.number, antarOverride: 0, monthlyOverride: 0);
      case 'antar':
        final maha = NumerologyEngine.currentMahadasha(widget.dob).number;
        return NumerologyEngine.buildGrid(widget.dob, mahaOverride: maha, antarOverride: d.number, monthlyOverride: 0);
      case 'monthly':
      default:
        final maha = NumerologyEngine.currentMahadasha(widget.dob).number;
        final antar = NumerologyEngine.currentAntardasha(widget.dob).number;
        return NumerologyEngine.buildGrid(widget.dob, mahaOverride: maha, antarOverride: antar, monthlyOverride: d.number);
    }
  }

  // Simple period insight based on number combination
  String _insight() {
    final num = widget.item.number;
    const insights = {
      1: 'Sun period — authority, leadership, and career come forward. A time to step up and be seen.',
      2: 'Moon period — emotions run high. Great for creative work and relationships. Guard mental health.',
      3: 'Jupiter period — wisdom, growth, and good fortune. Teaching, learning, and family matters bloom.',
      4: 'Rahu period — unexpected changes and disruptions. Stay grounded, avoid shortcuts.',
      5: 'Mercury period — business, communication, and money flow. Sharp mind, fast decisions.',
      6: 'Venus period — love, comfort, and beauty. Strong period for relationships and finances.',
      7: 'Ketu period — spiritual growth, detachment, and intuition. Inner work more than outer action.',
      8: 'Saturn period — hard work, discipline, and slow but lasting results. No shortcuts here.',
      9: 'Mars period — high energy, action, and courage. Beware aggression and impulsive decisions.',
    };
    return insights[num] ?? '';
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

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Timeline spine
      Column(children: [
        if (!widget.isFirst) Container(width: 1.5, height: 14, color: border),
        Container(width: 10, height: 10, decoration: BoxDecoration(
          color: isCurrent ? color : (isPast ? secondary.withOpacity(0.2) : secondary.withOpacity(0.35)),
          shape: BoxShape.circle,
          border: isCurrent ? Border.all(color: color.withOpacity(0.4), width: 2.5) : null)),
        if (!widget.isLast) Container(width: 1.5, height: double.infinity, color: border),
      ]),
      const SizedBox(width: 12),
      // Card
      Expanded(child: GestureDetector(
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
            FadeTransition(opacity: _fade, child: _open ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: 1, color: border),
              // Insight text
              Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Text(_insight(), style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.6))),
              // Grid
              Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: _PeriodGrid(grid: _buildPeriodGrid(), isDark: isDark, gold: gold, color: color, tabType: widget.tabType, dashaNum: d.number)),
            ]) : const SizedBox.shrink()),
          ]),
        ),
      )),
    ]);
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
