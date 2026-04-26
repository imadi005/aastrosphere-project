import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_theme.dart';
import 'pdf_builder.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../providers/astro_client_provider.dart';
import '../../auth/providers/user_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class YearSection {
  final int year;
  final String label; // e.g. "2026 – 2027"
  final int mahaNum;
  final String mahaPlanet;
  final bool mahaChanged;   // first year of a new maha
  final int antarNum;
  final String antarPlanet;
  final int monthlyNum;
  final String monthlyPlanet;
  final List<String> insights;
  final List<String> warnings;
  final List<String> yogas;
  final List<String> cautionDays; // notable caution periods
  final bool isCurrent;
  String remedies;          // editable by astrologer

  YearSection({
    required this.year, required this.label,
    required this.mahaNum, required this.mahaPlanet,
    required this.mahaChanged,
    required this.antarNum, required this.antarPlanet,
    required this.monthlyNum, required this.monthlyPlanet,
    required this.insights, required this.warnings,
    required this.yogas, required this.cautionDays,
    required this.isCurrent, this.remedies = '',
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT ENGINE — generates year-by-year breakdown
// ═══════════════════════════════════════════════════════════════════════════════

class ReportEngine {
  static const _planetNames = {
    1:'Sun', 2:'Moon', 3:'Jupiter', 4:'Rahu',
    5:'Mercury', 6:'Venus', 7:'Ketu', 8:'Saturn', 9:'Mars',
  };

  static const _combos = {
    '1_2': 'Career and emotions both demand attention. High visibility. Guard mental health.',
    '1_4': 'Ambitious but unstable. Big opportunities, big disruptions. Watch impulsive decisions.',
    '1_6': 'Career and finances both strong. Good for promotions and money.',
    '1_7': 'Lucky period. Career breakthroughs possible. Some detachment from material things.',
    '1_8': 'Hard work required. Authority challenged. Keep ego in check.',
    '1_9': 'Powerful energy. Leadership peaks. Anger and accident risk.',
    '2_4': 'Emotional instability. Deception risk. Guard finances and trust.',
    '2_7': 'Deeply spiritual. Intuition sharp. Emotional sensitivity very high.',
    '2_8': 'Depression risk. Emotional heaviness. Discipline helps navigate.',
    '2_9': 'Emotional aggression. Arguments in relationships. Channel into creative work.',
    '3_4': 'Wisdom tested by confusion. Good for research. Avoid shortcuts.',
    '3_9': 'Strong action with wisdom. Good for leadership and expansion.',
    '4_9': 'HIGH ACCIDENT RISK — most dangerous combination. Drive carefully, avoid rushing.',
    '4_8': 'Delays, frustration, obstacles. Results come very slowly. Stay patient.',
    '4_2': 'Emotionally unstable, prone to being deceived. Keep finances guarded.',
    '5_4': 'Financial impulsiveness. Easy money thinking leads to losses. Budget strictly.',
    '5_6': 'Excellent for business and relationships. Cash flow and romance both active.',
    '5_7': 'Easy money and luck combination. Financial gains with less effort.',
    '6_4': 'Relationship complications. Attraction without stability. Guard against deception.',
    '7_4': 'Highly unstable spiritually and materially. Avoid major decisions.',
    '7_8': 'Bad luck, delayed results. Financial and personal setbacks. Stay patient.',
    '8_9': 'Relentless hard work, heavy load. Protect health — heart and BP risk.',
    '9_4': 'HIGH ACCIDENT RISK. Impulsive actions cause physical harm. Slow down.',
    '9_8': 'Immense determination, heavy load. Physical health must be protected.',
  };

  static const _remedyMap = {
    1: 'Donate wheat/jaggery on Sundays. Wear gold. Chant Aditya Hridayam.',
    2: 'Donate milk/rice on Mondays. Wear silver. Chant Chandra mantra.',
    3: 'Donate yellow sweets on Thursdays. Wear yellow. Chant Guru mantra.',
    4: 'Donate blue clothes on Saturdays. Avoid shortcuts. Chant Rahu beej mantra.',
    5: 'Donate green vegetables on Wednesdays. Wear emerald. Chant Budh mantra.',
    6: 'Donate white sweets on Fridays. Wear diamond or opal. Chant Shukra mantra.',
    7: 'Donate sesame on Saturdays. Wear cat\'s eye. Chant Ketu beej mantra.',
    8: 'Donate black sesame on Saturdays. Wear blue sapphire. Chant Shani mantra.',
    9: 'Donate red lentils on Tuesdays. Wear red coral. Chant Mangal mantra.',
  };

  static List<YearSection> generate(DateTime dob, int years) {
    final sections = <YearSection>[];
    final today = DateTime.now();
    final basic = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    final natalNums = NumerologyEngine.chartDigits(dob).toSet();

    // Build full maha timeline
    final mahaList = NumerologyEngine.mahadashaTimeline(dob, pastYears: 30, futureYears: years + 2);

    int? prevMaha;

    for (int i = 0; i < years; i++) {
      final targetDate = DateTime(today.year + i, today.month, today.day);

      // Find maha for this date
      final maha = mahaList.firstWhere(
        (m) => !targetDate.isBefore(m.start) && targetDate.isBefore(m.end),
        orElse: () => mahaList.last,
      );

      // Antar
      final antarYear = targetDate.month <= dob.month && targetDate.day < dob.day
          ? targetDate.year - 1 : targetDate.year;
      final wd = DateTime(antarYear, dob.month, dob.day).weekday % 7;
      final wdVal = NumerologyEngine.weekdayValues[wd]!;
      final raw = basic + dob.month + (antarYear % 100) + wdVal;
      final antarNum = NumerologyEngine.reduceToSingle(raw);
      final antarPlanet = _planetNames[antarNum] ?? '';

      // Monthly (midpoint of this calendar year)
      final monthly = NumerologyEngine.currentMonthlyDasha(dob,
          targetDate: DateTime(targetDate.year, targetDate.month, targetDate.day));

      final allNums = {...natalNums, maha.number, antarNum, monthly.number};

      // Insights
      final insights = <String>[];
      final warnings = <String>[];
      final yogas = <String>[];

      // Combo text
      final c1 = '${maha.number}_$antarNum';
      final c2 = '${antarNum}_${maha.number}';
      final combo = _combos[c1] ?? _combos[c2] ?? '';
      if (combo.isNotEmpty) {
        if (combo.contains('HIGH ACCIDENT') || combo.contains('RISK')) {
          warnings.add(combo);
        } else {
          insights.add(combo);
        }
      }

      // Yogas
      if (allNums.contains(1) && allNums.contains(2) && !natalNums.contains(3) && !natalNums.contains(6)) {
        yogas.add('Raj Yoga — authority, career advancement strongly supported.');
      }
      if (natalNums.contains(1) && natalNums.contains(7) && !natalNums.contains(8)) {
        yogas.add('Continuous Luck (1-7) — things tend to work out, often unexpectedly.');
      }
      if (allNums.contains(5) && allNums.contains(7)) {
        yogas.add('Easy Money (5-7) — financial gains with less effort.');
      }
      if (allNums.contains(3) && allNums.contains(1) && allNums.contains(9)) {
        yogas.add('3-1-9 Uplift — very positive for growth and confidence.');
      }

      // Warnings
      if ((maha.number == 4 && antarNum == 9) || (maha.number == 9 && antarNum == 4)) {
        warnings.add('HIGH ACCIDENT RISK year. Drive carefully. Avoid rushing and risky activities.');
      }
      if (allNums.contains(9) && allNums.contains(4) && !allNums.contains(5)) {
        warnings.add('Bandhan Yoga — feeling stuck. Avoid new loans or big commitments.');
      }
      if (allNums.contains(5) && allNums.contains(4) && !allNums.contains(9)) {
        warnings.add('Financial Bandhan — debt risk. Impulsive spending causes damage.');
      }
      if (maha.number == 2 || antarNum == 2) {
        warnings.add('Mental health watch — risk of low mood and insomnia.');
      }
      if (maha.number == 4 || antarNum == 4) {
        if (!warnings.any((w) => w.contains('Bandhan') || w.contains('ACCIDENT'))) {
          warnings.add('Rahu active — watch impulsive financial decisions and sudden changes.');
        }
      }
      if ((maha.number == 8 || antarNum == 8) && (basic == 8 || destiny == 8)) {
        warnings.add('Bone, joint, dental health needs attention this year.');
      }

      // Caution days — months where daily/monthly combo is risky
      final cautionDays = <String>[];
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      for (int m = 1; m <= 12; m++) {
        final dateM = DateTime(targetDate.year, m, 15);
        final mon = NumerologyEngine.currentMonthlyDasha(dob, targetDate: dateM);
        final risk = (mon.number == 4 && antarNum == 9) ||
                     (mon.number == 9 && antarNum == 4) ||
                     (mon.number == 4 && maha.number == 9) ||
                     (mon.number == 9 && maha.number == 4);
        if (risk) cautionDays.add('${months[m-1]} ${targetDate.year} — monthly ${mon.number} (${_planetNames[mon.number]}) active. Extra caution advised.');
      }

      // Auto remedies based on active dashas
      final remedyNums = {maha.number, antarNum};
      final autoRemedies = remedyNums.map((n) => '• ${_planetNames[n]}: ${_remedyMap[n] ?? ""}').join('\n');

      sections.add(YearSection(
        year: targetDate.year,
        label: '${targetDate.year} – ${targetDate.year + 1}',
        mahaNum: maha.number,
        mahaPlanet: maha.planet,
        mahaChanged: prevMaha != null && prevMaha != maha.number,
        antarNum: antarNum,
        antarPlanet: antarPlanet,
        monthlyNum: monthly.number,
        monthlyPlanet: _planetNames[monthly.number] ?? '',
        insights: insights,
        warnings: warnings,
        yogas: yogas,
        cautionDays: cautionDays,
        isCurrent: i == 0,
        remedies: autoRemedies,
      ));
      prevMaha = maha.number;
    }
    return sections;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class AstroReportScreen extends ConsumerStatefulWidget {
  const AstroReportScreen({super.key});
  @override
  ConsumerState<AstroReportScreen> createState() => _AstroReportScreenState();
}

class _AstroReportScreenState extends ConsumerState<AstroReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,4),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('Reports', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400)))),
        TabBar(
          controller: _tab,
          labelColor: gold, unselectedLabelColor: secondary,
          indicatorColor: gold, indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          tabs: const [Tab(text: 'Generate'), Tab(text: 'History')],
        ),
        Expanded(child: TabBarView(controller: _tab, children: [
          _GenerateTab(isDark: isDark, gold: gold),
          _HistoryTab(isDark: isDark, gold: gold),
        ])),
      ])),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GENERATE TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _GenerateTab extends ConsumerStatefulWidget {
  final bool isDark; final Color gold;
  const _GenerateTab({required this.isDark, required this.gold});
  @override ConsumerState<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends ConsumerState<_GenerateTab> {
  int _years = 10;
  bool _generating = false;
  bool _saving = false;
  String? _error;
  List<YearSection>? _sections;
  final _clientNameCtrl = TextEditingController();

  // Remedy controllers per year index
  final Map<int, TextEditingController> _remedyCtrls = {};

  static const _yearOptions = [5, 10, 20, 30, 40, 50, 60];

  @override void dispose() {
    _clientNameCtrl.dispose();
    for (final c in _remedyCtrls.values) c.dispose();
    super.dispose();
  }

  TextEditingController _remedyCtrl(int idx, String initial) {
    return _remedyCtrls.putIfAbsent(idx, () => TextEditingController(text: initial));
  }

  Future<void> _generate(DateTime dob) async {
    setState(() { _generating = true; _error = null; _sections = null; _remedyCtrls.clear(); });
    try {
      final sections = await Future.microtask(() => ReportEngine.generate(dob, _years));
      if (mounted) setState(() { _sections = sections; _generating = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Generation failed: $e'; _generating = false; });
    }
  }

  Future<void> _saveAndExport(DateTime dob, UserProfile? astrologer) async {
    if (_sections == null) return;
    setState(() { _saving = true; });
    try {
      final clientName = ref.read(astroClientNameProvider).isNotEmpty
          ? ref.read(astroClientNameProvider)
          : _clientNameCtrl.text.trim().isNotEmpty
            ? _clientNameCtrl.text.trim()
            : 'Client';

      // Save remedies from controllers back to sections
      for (final entry in _remedyCtrls.entries) {
        if (entry.key < _sections!.length) {
          _sections![entry.key].remedies = entry.value.text;
        }
      }

      // Save to Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final docRef = await FirebaseFirestore.instance.collection('astro_reports').add({
        'astrologer_uid': uid,
        'client_name': clientName,
        'client_dob': '${dob.year}-${dob.month.toString().padLeft(2,'0')}-${dob.day.toString().padLeft(2,'0')}',
        'years': _years,
        'created_at': FieldValue.serverTimestamp(),
        'sections': _sections!.map((s) => {
          'year': s.year, 'label': s.label,
          'maha': s.mahaNum, 'maha_planet': s.mahaPlanet,
          'antar': s.antarNum, 'antar_planet': s.antarPlanet,
          'insights': s.insights, 'warnings': s.warnings,
          'yogas': s.yogas, 'caution_days': s.cautionDays,
          'remedies': s.remedies,
        }).toList(),
      });

      // Fetch astrologer name fresh from both collections
      String astroName = astrologer?.name ?? '';
      String astroPhone = astrologer?.phone ?? '';
      if (astroName.isEmpty) {
        try {
          final astroDoc = await FirebaseFirestore.instance.collection('astrologers').doc(uid).get();
          if (astroDoc.exists) {
            astroName = astroDoc.data()?['name'] ?? '';
            astroPhone = astroDoc.data()?['phone'] ?? '';
          }
        } catch (_) {}
      }
      if (astroName.isEmpty) astroName = 'Astrologer';

      // Generate PDF
      debugPrint('PDF: starting build...');
      String pdfPath;
      try {
        pdfPath = await PdfReportBuilder.build(
        clientName: clientName,
        dob: dob,
        astrologerName: astroName,
        astrologerPhone: astroPhone,
        years: _years,
        sections: _sections!,
      );
        debugPrint('PDF: built at \$pdfPath');
      } catch (pdfErr, stack) {
        debugPrint('PDF ERROR: \$pdfErr');
        debugPrint('\$stack');
        if (mounted) setState(() { _saving = false; _error = 'PDF failed: \$pdfErr'; });
        return;
      }
      await OpenFilex.open(pdfPath);

      if (mounted) setState(() { _saving = false; });
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = 'Save failed: $e'; });
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final useClient = ref.watch(astroUseClientDobProvider);
    final clientDob = ref.watch(astroClientDobProvider);
    final clientName = ref.watch(astroClientNameProvider);
    final userAsync = ref.watch(userProfileProvider);
    final astroAsync = ref.watch(astrologerProfileProvider);
    final activeDob = useClient ? clientDob : userAsync.valueOrNull?.dob;
    final astrologer = astroAsync.valueOrNull ?? userAsync.valueOrNull;

    if (activeDob == null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.description_outlined, size: 40, color: gold.withOpacity(0.35)),
      const SizedBox(height: 14),
      Text('No DOB selected', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: gold)),
      const SizedBox(height: 6),
      Text('Enter a client DOB in the Chart tab', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
    ]));

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 40), children: [
      // Client info card
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
                style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(clientName.isNotEmpty ? clientName : 'Client',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            Text(_fmtDate(activeDob), style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Basic ${NumerologyEngine.basicNumber(activeDob.day)}',
                style: GoogleFonts.dmSans(fontSize: 10, color: gold)),
            Text('Destiny ${NumerologyEngine.destinyNumber(activeDob)}',
                style: GoogleFonts.dmSans(fontSize: 10, color: gold.withOpacity(0.7))),
          ]),
        ]),
      ),
      const SizedBox(height: 14),

      // Year selector
      Row(children: [
        Text('Generate for:', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
        const SizedBox(width: 10),
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: _GenerateTabState._yearOptions.map((y) {
            final active = _years == y;
            return GestureDetector(
              onTap: () => setState(() { _years = y; _sections = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? gold : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? gold : border, width: 0.5)),
                child: Text('$y yr', style: GoogleFonts.dmSans(fontSize: 11, color: active ? Colors.black : secondary, fontWeight: active ? FontWeight.w700 : FontWeight.w400))));
          }).toList()))),
      ]),
      const SizedBox(height: 14),

      // Generate button
      GestureDetector(
        onTap: _generating ? null : () => _generate(activeDob),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: _generating ? gold.withOpacity(0.4) : gold, borderRadius: BorderRadius.circular(12)),
          child: Center(child: _generating
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                const SizedBox(width: 10),
                Text('Building $_years-year reading...', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
              ])
            : Text('Generate $_years-Year Life Reading', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black))),
        ),
      ),

      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: GoogleFonts.dmSans(fontSize: 11, color: isDark ? AppColors.dangerDark : AppColors.danger)),
      ],

      // Report sections
      if (_sections != null) ...[
        const SizedBox(height: 20),
        ..._buildReportUI(activeDob, astrologer),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _saving ? null : () => _saveAndExport(activeDob, astrologer),
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _saving ? (isDark ? AppColors.successDark : AppColors.success).withOpacity(0.5) : (isDark ? AppColors.successDark : AppColors.success),
              borderRadius: BorderRadius.circular(12)),
            child: Center(child: _saving
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 10),
                  Text('Generating PDF...', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ])
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Save & Export PDF', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ])),
          ),
        ),
      ],
    ]);
  }


  List<Widget> _buildReportUI(DateTime dob, UserProfile? astrologer) {
    final isDark = widget.isDark; final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final orange = isDark ? AppColors.warningDark : AppColors.warning;
    final red = isDark ? AppColors.dangerDark : AppColors.danger;
    final widgets = <Widget>[];

    // Life pattern header
    final natalNums = NumerologyEngine.chartDigits(dob).toSet();
    final basic = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    widgets.add(_ReportSectionHeader(title: 'Life Pattern', icon: Icons.person_outline, isDark: isDark, gold: gold));
    widgets.add(const SizedBox(height: 8));
    final lifeLines = [
      'Basic $basic (${ReportEngine._planetNames[basic]}) — core personality and drive.',
      'Destiny $destiny (${ReportEngine._planetNames[destiny]}) — life direction and purpose.',
      if (natalNums.contains(4) && natalNums.contains(9)) '4-9 in natal — physically impulsive, accident-prone tendency throughout life.',
      if (natalNums.contains(5) && natalNums.contains(7)) 'Easy Money yoga in natal — financial gains come with less struggle.',
      if (natalNums.contains(1) && natalNums.contains(2) && !natalNums.contains(3) && !natalNums.contains(6))
        'Raj Yoga in natal — natural authority, career advancement throughout life.',
    ];
    widgets.add(Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: lifeLines.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 6), decoration: BoxDecoration(color: gold, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(l, style: GoogleFonts.dmSans(fontSize: 12, color: primary, height: 1.5))),
        ]),
      )).toList()),
    ));
    widgets.add(const SizedBox(height: 20));

    // Year sections
    widgets.add(_ReportSectionHeader(title: '$_years-Year Reading', icon: Icons.calendar_month_outlined, isDark: isDark, gold: gold));
    widgets.add(const SizedBox(height: 8));

    int? prevMaha;
    for (int i = 0; i < _sections!.length; i++) {
      final s = _sections![i];

      // Maha change label
      if (prevMaha != s.mahaNum) {
        if (prevMaha != null) widgets.add(const SizedBox(height: 6));
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.radio_button_unchecked, size: 12, color: Colors.black),
            const SizedBox(width: 6),
            Text('Mahadasha ${s.mahaNum} — ${s.mahaPlanet}',
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.3)),
          ]),
        ));
        prevMaha = s.mahaNum;
      }

      widgets.add(_YearCard(
        section: s,
        index: i,
        isDark: isDark,
        gold: gold,
        remedyCtrl: _remedyCtrl(i, s.remedies),
        onRemedyChanged: (v) => s.remedies = v,
      ));
    }
    return widgets;
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// YEAR CARD (expandable)
// ═══════════════════════════════════════════════════════════════════════════════

class _YearCard extends StatefulWidget {
  final YearSection section;
  final int index;
  final bool isDark; final Color gold;
  final TextEditingController remedyCtrl;
  final ValueChanged<String> onRemedyChanged;
  const _YearCard({required this.section, required this.index, required this.isDark,
      required this.gold, required this.remedyCtrl, required this.onRemedyChanged});
  @override State<_YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<_YearCard> {
  bool _open = false;
  bool _editingRemedies = false;

  @override void initState() { super.initState(); if (widget.section.isCurrent) _open = true; }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final s = widget.section;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final card = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final orange = isDark ? AppColors.warningDark : AppColors.warning;
    final red = isDark ? AppColors.dangerDark : AppColors.danger;
    final hasWarning = s.warnings.any((w) => w.contains('HIGH ACCIDENT') || w.contains('RISK'));
    final borderColor = s.isCurrent ? gold : (hasWarning ? red.withOpacity(0.4) : border);

    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: s.isCurrent ? gold.withOpacity(0.05) : card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: s.isCurrent ? 0.8 : 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(7)),
              child: Text(s.label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black))),
            if (s.isCurrent) ...[const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(6)),
                child: Text('NOW', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)))],
            if (hasWarning) ...[const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(color: red.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: red.withOpacity(0.4), width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_rounded, size: 10, color: red),
                  const SizedBox(width: 3),
                  Text('Risk', style: GoogleFonts.dmSans(fontSize: 9, color: red)),
                ]))],
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('M${s.mahaNum}·A${s.antarNum}·Mo${s.monthlyNum}',
                  style: GoogleFonts.dmSans(fontSize: 9, color: secondary.withOpacity(0.7))),
              const SizedBox(height: 2),
              Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: secondary),
            ]),
          ])),

          // ── Expanded content ──────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
            child: _open ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: 1, color: border),
              Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Dasha row
                _DashaRow(mahaNum: s.mahaNum, mahaPlanet: s.mahaPlanet,
                    antarNum: s.antarNum, antarPlanet: s.antarPlanet,
                    monthlyNum: s.monthlyNum, monthlyPlanet: s.monthlyPlanet,
                    isDark: isDark, gold: gold),
                const SizedBox(height: 12),

                // Grid
                _MiniGrid(dob: null, mahaNum: s.mahaNum, antarNum: s.antarNum, monthlyNum: s.monthlyNum, isDark: isDark, gold: gold),
                const SizedBox(height: 12),

                // Insights
                if (s.insights.isNotEmpty) ...[
                  _Label('WHAT HAPPENS', secondary),
                  const SizedBox(height: 6),
                  ...s.insights.map((ins) => _InfoLine(text: ins, color: const Color(0xFF6366F1), isDark: isDark)),
                  const SizedBox(height: 10),
                ],

                // Yogas
                if (s.yogas.isNotEmpty) ...[
                  _Label('YOGAS ACTIVE', secondary),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: s.yogas.map((y) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: green.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: green.withOpacity(0.3), width: 0.5)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.star_outline, size: 11, color: green), const SizedBox(width: 5),
                      Flexible(child: Text(y, style: GoogleFonts.dmSans(fontSize: 11, color: green))),
                    ]))).toList()),
                  const SizedBox(height: 10),
                ],

                // Warnings
                if (s.warnings.isNotEmpty) ...[
                  _Label('WATCH OUT', secondary),
                  const SizedBox(height: 6),
                  ...s.warnings.map((w) {
                    final isHigh = w.contains('HIGH ACCIDENT') || w.contains('RISK');
                    return _InfoLine(text: w, color: isHigh ? red : orange, isDark: isDark, isWarning: true);
                  }),
                  const SizedBox(height: 10),
                ],

                // Caution months
                if (s.cautionDays.isNotEmpty) ...[
                  _Label('CAUTION MONTHS', secondary),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: s.cautionDays.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(color: orange.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: orange.withOpacity(0.25), width: 0.5)),
                    child: Text(c, style: GoogleFonts.dmSans(fontSize: 10, color: orange)))).toList()),
                  const SizedBox(height: 12),
                ],

                // Remedies (editable)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.2), width: 0.5)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.auto_fix_high_outlined, size: 13, color: gold),
                      const SizedBox(width: 6),
                      Text('REMEDIES', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _editingRemedies = !_editingRemedies),
                        child: Text(_editingRemedies ? 'Done' : 'Edit',
                            style: GoogleFonts.dmSans(fontSize: 11, color: gold, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 8),
                    _editingRemedies
                      ? TextField(
                          controller: widget.remedyCtrl,
                          onChanged: widget.onRemedyChanged,
                          maxLines: null, minLines: 3,
                          style: GoogleFonts.dmSans(fontSize: 12, color: primary, height: 1.6),
                          decoration: InputDecoration(
                            filled: true, fillColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                            contentPadding: const EdgeInsets.all(10),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: gold.withOpacity(0.3), width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: gold, width: 1))),
                        )
                      : Text(widget.remedyCtrl.text,
                          style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.6)),
                  ]),
                ),
              ])),
            ]) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HISTORY TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _HistoryTab extends ConsumerWidget {
  final bool isDark; final Color gold;
  const _HistoryTab({required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('astro_reports')
          .where('astrologer_uid', isEqualTo: uid)
          .orderBy('created_at', descending: true).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.history_outlined, size: 36, color: gold.withOpacity(0.3)), const SizedBox(height: 14),
            Text('No reports yet', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: gold)), const SizedBox(height: 6),
            Text('Generated reports will appear here', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
          ]));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final clientName = data['client_name'] as String? ?? 'Client';
            final clientDob = data['client_dob'] as String? ?? '';
            final years = data['years'] as int? ?? 0;
            final ts = data['created_at'] as Timestamp?;
            final date = ts != null ? _fmtDate(ts.toDate()) : '';
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                  child: Center(child: Text(clientName[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(fontSize: 18, color: gold)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(clientName, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
                  Text('$clientDob  ·  $years yrs  ·  $date', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
                ])),
                Icon(Icons.chevron_right, size: 16, color: secondary),
              ]));
          });
      });
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMALL SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _ReportSectionHeader extends StatelessWidget {
  final String title; final IconData icon; final bool isDark; final Color gold;
  const _ReportSectionHeader({required this.title, required this.icon, required this.isDark, required this.gold});
  @override Widget build(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
      child: Icon(icon, size: 14, color: gold)),
    const SizedBox(width: 8),
    Text(title.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: gold, letterSpacing: 0.8)),
  ]);
}

class _Label extends StatelessWidget {
  final String text; final Color color;
  const _Label(this.text, this.color);
  @override Widget build(BuildContext context) => Text(text, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: color));
}

class _InfoLine extends StatelessWidget {
  final String text; final Color color; final bool isDark, isWarning;
  const _InfoLine({required this.text, required this.color, required this.isDark, this.isWarning = false});
  @override Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(isWarning ? Icons.warning_amber_rounded : Icons.circle, size: isWarning ? 13 : 5, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: isWarning ? color : primary, height: 1.5))),
      ]));
  }
}

class _DashaRow extends StatelessWidget {
  final int mahaNum, antarNum, monthlyNum;
  final String mahaPlanet, antarPlanet, monthlyPlanet;
  final bool isDark; final Color gold;
  const _DashaRow({required this.mahaNum, required this.mahaPlanet, required this.antarNum,
      required this.antarPlanet, required this.monthlyNum, required this.monthlyPlanet,
      required this.isDark, required this.gold});
  @override Widget build(BuildContext context) {
    final green = isDark ? AppColors.successDark : AppColors.success;
    final indigo = const Color(0xFF6366F1);
    return Row(children: [
      _DashaChip(number: mahaNum, label: 'Maha', planet: mahaPlanet, color: gold),
      const SizedBox(width: 8),
      _DashaChip(number: antarNum, label: 'Antar', planet: antarPlanet, color: green),
      const SizedBox(width: 8),
      _DashaChip(number: monthlyNum, label: 'Monthly', planet: monthlyPlanet, color: indigo),
    ]);
  }
}

class _DashaChip extends StatelessWidget {
  final int number; final String label, planet; final Color color;
  const _DashaChip({required this.number, required this.label, required this.planet, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('$number', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: color, height: 1)),
      Text('$label · $planet', style: GoogleFonts.dmSans(fontSize: 8, color: color.withOpacity(0.8))),
    ]));
}

// Mini 3×3 grid for the year card
class _MiniGrid extends StatelessWidget {
  final DateTime? dob;
  final int mahaNum, antarNum, monthlyNum;
  final bool isDark; final Color gold;
  const _MiniGrid({required this.dob, required this.mahaNum, required this.antarNum,
      required this.monthlyNum, required this.isDark, required this.gold});

  static const _positions = {
    3:[0,0], 1:[0,1], 9:[0,2],
    6:[1,0], 7:[1,1], 5:[1,2],
    2:[2,0], 8:[2,1], 4:[2,2],
  };
  static const _planets = [[' Jup','Sun','Mar'],['Ven','Ket','Mer'],['Mon','Sat','Rah']];

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgSubtleLight;
    final tertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final indigo = const Color(0xFF6366F1);

    // Build map: position → list of (number, color)
    final cells = <String, List<MapEntry<int, Color>>>{};
    // We need natal digits from engine — but we don't have dob here
    // So just highlight maha/antar/monthly positions
    void addCell(int num, Color color) {
      final pos = _positions[num];
      if (pos == null) return;
      final key = '${pos[0]}_${pos[1]}';
      cells[key] = [...(cells[key] ?? []), MapEntry(num, color)];
    }
    addCell(mahaNum, gold);
    addCell(antarNum, green);
    if (monthlyNum > 0) addCell(monthlyNum, indigo);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Legend
      Row(children: [
        _Dot(color: gold, label: 'Maha $mahaNum'),
        const SizedBox(width: 10),
        _Dot(color: green, label: 'Antar $antarNum'),
        const SizedBox(width: 10),
        _Dot(color: indigo, label: 'Monthly $monthlyNum'),
      ]),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border, width: 0.5)),
        child: Column(children: List.generate(3, (row) => Row(
          children: List.generate(3, (col) {
            final key = '${row}_$col';
            final num = _positions.entries.firstWhere((e) => e.value[0] == row && e.value[1] == col, orElse: () => const MapEntry(0, [0,0])).key;
            final hits = cells[key] ?? [];
            final planet = _planets[row][col].trim();
            return Expanded(child: Container(
              height: 54,
              decoration: BoxDecoration(border: Border(
                right: col == 2 ? BorderSide.none : BorderSide(color: border, width: 0.5),
                bottom: row == 2 ? BorderSide.none : BorderSide(color: border, width: 0.5),
              )),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                hits.isNotEmpty
                  ? Wrap(alignment: WrapAlignment.center, spacing: 1, children: hits.map((h) =>
                      Text('$num', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: h.value, height: 1))).toList())
                  : Text('$num', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: tertiary.withOpacity(0.3), height: 1)),
                const SizedBox(height: 1),
                Text(planet, style: GoogleFonts.dmSans(fontSize: 6, color: tertiary), textAlign: TextAlign.center),
              ]),
            ));
          }),
        ))),
      ),
    ]);
  }
}

class _Dot extends StatelessWidget {
  final Color color; final String label;
  const _Dot({required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 4),
    Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: color)),
  ]);
}
