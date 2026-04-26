import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../providers/astro_client_provider.dart';
import '../../auth/providers/user_provider.dart';

class AstroReportScreen extends ConsumerStatefulWidget {
  const AstroReportScreen({super.key});
  @override
  ConsumerState<AstroReportScreen> createState() => _AstroReportScreenState();
}

class _AstroReportScreenState extends ConsumerState<AstroReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8),
          child: Text('Reports', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400))),
        TabBar(
          controller: _tabController,
          labelColor: gold, unselectedLabelColor: secondary,
          indicatorColor: gold, indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          tabs: const [Tab(text: 'Generate'), Tab(text: 'History')],
        ),
        Expanded(child: TabBarView(controller: _tabController, children: [
          _GenerateTab(isDark: isDark, gold: gold),
          _HistoryTab(isDark: isDark, gold: gold),
        ])),
      ])),
    );
  }
}

// ─── Generate Tab ─────────────────────────────────────────────────────────────
class _GenerateTab extends ConsumerStatefulWidget {
  final bool isDark; final Color gold;
  const _GenerateTab({required this.isDark, required this.gold});
  @override ConsumerState<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends ConsumerState<_GenerateTab> {
  bool _generating = false;
  bool _generated = false;
  bool _saving = false;
  bool _saved = false;
  String? _error;

  // Editable section controllers
  final _profileCtrl = TextEditingController();
  final _currentPeriodCtrl = TextEditingController();
  final _lifeMapsCtrl = TextEditingController();
  final _insightsCtrl = TextEditingController();
  final _remediesCtrl = TextEditingController();

  @override
  void dispose() {
    _profileCtrl.dispose(); _currentPeriodCtrl.dispose();
    _lifeMapsCtrl.dispose(); _insightsCtrl.dispose(); _remediesCtrl.dispose();
    super.dispose();
  }

  String _dobStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }

  Future<void> _generate(DateTime dob) async {
    setState(() { _generating = true; _error = null; _generated = false; });
    try {
      final dobStr = _dobStr(dob);
      final results = await Future.wait([
        ApiService.getFullPrediction(dobStr),
        ApiService.getDeepInsights(dobStr),
        ApiService.getDashas(dobStr),
        ApiService.getDashas(dobStr, type: 'antardasha'),
      ]);
      final full = results[0]; final deep = results[1];
      final mahaTimeline = (results[2]['timeline'] as List? ?? []).cast<Map<String,dynamic>>();
      final basic = full['basic'] as int? ?? NumerologyEngine.basicNumber(dob.day);
      final destiny = full['destiny'] as int? ?? NumerologyEngine.destinyNumber(dob);
      final maha = full['maha'] as Map<String,dynamic>? ?? {};
      final antar = full['antar'] as Map<String,dynamic>? ?? {};
      final combo = deep['combination'] as String? ?? deep['combo'] as String? ?? '';
      final pattern = deep['pattern'] as String? ?? deep['personal_pattern'] as String? ?? '';
      final basicProfile = deep['basic_profile'] as Map<String,dynamic>? ?? {};
      final dashaExp = deep['dasha_experience'] as String? ?? '';

      // Build profile text
      _profileCtrl.text = [
        'Basic Number: $basic (${NumerologyEngine.planetNames[basic] ?? ""})',
        'Destiny Number: $destiny (${NumerologyEngine.planetNames[destiny] ?? ""})',
        if (combo.isNotEmpty) '\n$combo',
        if (pattern.isNotEmpty) '\n$pattern',
      ].join('\n');

      // Current period
      final mahaNum = maha['number'] as int? ?? 0;
      final mahaEnd = maha['end'] as String? ?? '';
      final antarNum = antar['number'] as int? ?? 0;
      final antarEnd = antar['end'] as String? ?? '';
      _currentPeriodCtrl.text = [
        'Mahadasha: $mahaNum · ${NumerologyEngine.planetNames[mahaNum] ?? ""}${mahaEnd.isNotEmpty ? " (until $mahaEnd)" : ""}',
        'Antardasha: $antarNum · ${NumerologyEngine.planetNames[antarNum] ?? ""}${antarEnd.isNotEmpty ? " (until $antarEnd)" : ""}',
        if (dashaExp.isNotEmpty) '\n$dashaExp',
      ].join('\n');

      // Life map from maha timeline
      final currentIdx = mahaTimeline.indexWhere((d) => d['isCurrent'] == true);
      final slice = currentIdx >= 0 ? mahaTimeline.skip((currentIdx - 1).clamp(0, 999)).take(5).toList() : mahaTimeline.take(5).toList();
      _lifeMapsCtrl.text = slice.map((d) {
        final n = d['number'] as int? ?? 0;
        final planet = d['planet'] as String? ?? NumerologyEngine.planetNames[n] ?? '';
        final start = d['start'] as String? ?? ''; final end = d['end'] as String? ?? '';
        final curr = d['isCurrent'] == true ? ' ← NOW' : '';
        return '$n $planet  $start – $end$curr';
      }).join('\n');

      // Insights
      final shadow = basicProfile['shadow'] as String? ?? '';
      final whatTrips = basicProfile['what_trips_you'] as String? ?? '';
      final health = basicProfile['health_real'] as String? ?? '';
      _insightsCtrl.text = [
        if (shadow.isNotEmpty) 'Shadow: $shadow',
        if (whatTrips.isNotEmpty) '\nWhat trips them: $whatTrips',
        if (health.isNotEmpty) '\nHealth pattern: $health',
      ].join('\n');

      // Remedies from prediction
      final remedies = (full['remedies'] as List? ?? full['remedy_list'] as List? ?? []).cast<String>();
      _remediesCtrl.text = remedies.isNotEmpty
          ? remedies.map((r) => '• $r').join('\n')
          : 'Add remedies here...';

      if (mounted) setState(() { _generated = true; _generating = false; _saved = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to generate: $e'; _generating = false; });
    }
  }

  Future<void> _save(DateTime dob, String clientName) async {
    setState(() { _saving = true; });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('astro_reports').add({
        'astrologer_uid': uid,
        'client_name': clientName.isEmpty ? 'Unknown' : clientName,
        'client_dob': _dobStr(dob),
        'created_at': FieldValue.serverTimestamp(),
        'profile': _profileCtrl.text,
        'current_period': _currentPeriodCtrl.text,
        'life_map': _lifeMapsCtrl.text,
        'insights': _insightsCtrl.text,
        'remedies': _remediesCtrl.text,
      });
      if (mounted) setState(() { _saving = false; _saved = true; });
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = 'Save failed: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; final gold = widget.gold;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final useClient = ref.watch(astroUseClientDobProvider);
    final clientDob = ref.watch(astroClientDobProvider);
    final clientName = ref.watch(astroClientNameProvider);
    final userAsync = ref.watch(userProfileProvider);
    final activeDob = useClient ? clientDob : userAsync.valueOrNull?.dob;

    if (activeDob == null) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.description_outlined, size: 40, color: gold.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text('No DOB Selected', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
        const SizedBox(height: 8),
        Text('Enter a client DOB in the Chart tab to generate a report', textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      ])));
    }

    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Client info banner
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.15), width: 0.5)),
        child: Row(children: [
          Icon(Icons.person_outline, size: 16, color: gold),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(clientName.isEmpty ? 'Client' : clientName, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
            Text(_fmtDate(activeDob), style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),

      // Generate button
      if (!_generated) GestureDetector(
        onTap: _generating ? null : () => _generate(activeDob),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: _generating ? gold.withOpacity(0.3) : gold, borderRadius: BorderRadius.circular(12)),
          child: Center(child: _generating
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                const SizedBox(width: 10),
                Text('Generating report...', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
              ])
            : Text('Generate Report', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)))),
      ),

      if (_error != null) ...[const SizedBox(height: 8),
        Text(_error!, style: GoogleFonts.dmSans(fontSize: 11, color: isDark ? AppColors.dangerDark : AppColors.danger)),
      ],

      // Editable sections (shown after generate)
      if (_generated) ...[
        _EditSection(label: 'PROFILE', controller: _profileCtrl, isDark: isDark, gold: gold),
        _EditSection(label: 'CURRENT PERIOD', controller: _currentPeriodCtrl, isDark: isDark, gold: gold),
        _EditSection(label: 'LIFE MAP (DASHA TIMELINE)', controller: _lifeMapsCtrl, isDark: isDark, gold: gold),
        _EditSection(label: 'INSIGHTS', controller: _insightsCtrl, isDark: isDark, gold: gold),
        _EditSection(label: 'REMEDIES', controller: _remediesCtrl, isDark: isDark, gold: gold),
        const SizedBox(height: 8),

        // Regenerate + Save
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => _generate(activeDob),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
              child: Center(child: Text('Regenerate', style: GoogleFonts.dmSans(fontSize: 13, color: primary)))),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: GestureDetector(
            onTap: _saving || _saved ? null : () => _save(activeDob, clientName),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: _saved ? (isDark ? AppColors.successDark : AppColors.success) : gold, borderRadius: BorderRadius.circular(10)),
              child: Center(child: _saving
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text(_saved ? 'Saved to History' : 'Save Report',
                    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)))),
          )),
        ]),
      ],
    ]));
  }
}

class _EditSection extends StatelessWidget {
  final String label; final TextEditingController controller; final bool isDark; final Color gold;
  const _EditSection({required this.label, required this.controller, required this.isDark, required this.gold});
  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: secondary)),
      const SizedBox(height: 6),
      TextField(controller: controller, maxLines: null, minLines: 3,
        style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.6),
        decoration: InputDecoration(
          filled: true, fillColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          contentPadding: const EdgeInsets.all(14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border, width: 0.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: gold, width: 1)))),
    ]));
  }
}

// ─── History Tab ─────────────────────────────────────────────────────────────
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
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.history_outlined, size: 40, color: gold.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No reports yet', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: gold)),
            const SizedBox(height: 8),
            Text('Saved reports will appear here', style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
          ])));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String,dynamic>;
            final clientName = data['client_name'] as String? ?? 'Client';
            final clientDob = data['client_dob'] as String? ?? '';
            final ts = data['created_at'] as Timestamp?;
            final date = ts != null ? _fmtDate(ts.toDate()) : '';
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _ReportViewScreen(data: data, isDark: isDark, gold: gold))),
              child: Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                    child: Center(child: Text(clientName[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(fontSize: 18, color: gold)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(clientName, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
                    Text('$clientDob  ·  $date', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
                  ])),
                  Icon(Icons.chevron_right, size: 16, color: secondary),
                ])),
            );
          },
        );
      },
    );
  }

  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
}

// ─── Report View Screen ───────────────────────────────────────────────────────
class _ReportViewScreen extends StatelessWidget {
  final Map<String,dynamic> data; final bool isDark; final Color gold;
  const _ReportViewScreen({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final clientName = data['client_name'] as String? ?? 'Client';
    final clientDob = data['client_dob'] as String? ?? '';
    final sections = [
      ('PROFILE', data['profile'] as String? ?? ''),
      ('CURRENT PERIOD', data['current_period'] as String? ?? ''),
      ('LIFE MAP', data['life_map'] as String? ?? ''),
      ('INSIGHTS', data['insights'] as String? ?? ''),
      ('REMEDIES', data['remedies'] as String? ?? ''),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 16, color: primary), onPressed: () => Navigator.pop(context)),
        title: Text(clientName, style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16),
          child: Center(child: Text(clientDob, style: GoogleFonts.dmSans(fontSize: 10, color: secondary))))],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...sections.where((s) => s.$2.isNotEmpty).map((s) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.$1, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: secondary)),
          const SizedBox(height: 8),
          Container(width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5)),
            child: Text(s.$2, style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.65))),
        ]))),
      ])),
    );
  }
}
