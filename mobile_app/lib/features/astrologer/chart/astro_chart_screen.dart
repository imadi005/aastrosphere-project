import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/numerology/numerology_engine.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/astro_client_provider.dart';

class AstroChartScreen extends ConsumerStatefulWidget {
  const AstroChartScreen({super.key});
  @override
  ConsumerState<AstroChartScreen> createState() => _AstroChartScreenState();
}

class _AstroChartScreenState extends ConsumerState<AstroChartScreen> {
  Map<String, dynamic>? _chartData;
  Map<String, dynamic>? _yogaData;
  bool _loading = false;
  String? _error;
  final _nameCtrl = TextEditingController();

  // Date/hour selection for "any date" chart
  DateTime? _selectedDate;   // null = today
  int? _selectedHour;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  String _dobStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  Future<void> _loadChart(DateTime dob) async {
    setState(() { _loading = true; _error = null; });
    try {
      final dobStr = _dobStr(dob);
      late Map<String, dynamic> chart;
      if (_selectedDate == null) {
        chart = await ApiService.getChart(dobStr, _selectedHour);
      } else {
        final dateStr = _selectedDate!.toIso8601String();
        chart = await ApiService.getChartForDate(dobStr, dateStr, _selectedHour);
      }
      final yogas = await ApiService.getYogas(dobStr);
      if (mounted) setState(() { _chartData = chart; _yogaData = yogas; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load chart'; _loading = false; });
    }
  }

  Future<void> _pickClientDob(bool isDark, Color gold) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(astroClientDobProvider) ?? DateTime(1990),
      firstDate: DateTime(1920), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: isDark
            ? ColorScheme.dark(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardDark, onSurface: AppColors.textPrimaryDark)
            : ColorScheme.light(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardLight, onSurface: AppColors.textPrimaryLight)),
        child: child!),
    );
    if (picked != null && mounted) {
      ref.read(astroClientDobProvider.notifier).state = picked;
      ref.read(astroUseClientDobProvider.notifier).state = true;
      _selectedDate = null; _selectedHour = null;
      await _loadChart(picked);
    }
  }

  Future<void> _pickChartDate(DateTime dob, bool isDark, Color gold) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900), lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: isDark
            ? ColorScheme.dark(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardDark, onSurface: AppColors.textPrimaryDark)
            : ColorScheme.light(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardLight, onSurface: AppColors.textPrimaryLight)),
        child: child!),
    );
    if (picked == null || !mounted) return;

    // Optional hour
    final wantHour = await showDialog<bool>(context: context, builder: (dCtx) {
      final dIsDark = Theme.of(dCtx).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: dIsDark ? AppColors.bgCardDark : AppColors.bgCardLight,
        title: Text('Add hour?', style: GoogleFonts.dmSans(fontSize: 14,
            color: dIsDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        content: Text('Add a specific hour for hourly dasha.',
            style: GoogleFonts.dmSans(fontSize: 12,
                color: dIsDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false),
              child: Text('Skip', style: GoogleFonts.dmSans(
                  color: dIsDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
          TextButton(onPressed: () => Navigator.pop(dCtx, true),
              child: Text('Add Hour', style: GoogleFonts.dmSans(color: gold))),
        ],
      );
    });

    int? hour;
    if (wantHour == true && mounted) {
      final t = await showTimePicker(context: context,
          initialTime: TimeOfDay(hour: _selectedHour ?? DateTime.now().hour, minute: 0));
      if (t != null) hour = t.hour;
    }

    setState(() { _selectedDate = picked; _selectedHour = hour; });
    await _loadChart(dob);
  }

  void _clearClient() {
    ref.read(astroClientDobProvider.notifier).state = null;
    ref.read(astroClientNameProvider.notifier).state = '';
    _nameCtrl.clear();
    setState(() { _chartData = null; _yogaData = null; _error = null; _selectedDate = null; _selectedHour = null; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final useClient = ref.watch(astroUseClientDobProvider);
    final clientDob = ref.watch(astroClientDobProvider);
    final userAsync = ref.watch(userProfileProvider);
    final activeDob = useClient ? clientDob : userAsync.valueOrNull?.dob;

    if (!useClient && activeDob != null && _chartData == null && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadChart(activeDob!));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ────────────────────────────────────────────────────────
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8), child: Row(children: [
          Text('Chart', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400)),
          const Spacer(),
          userAsync.maybeWhen(
            data: (u) => u?.isAstrologer == true ? _ToggleChip(useClient: useClient, isDark: isDark, gold: gold,
              onToggle: (val) {
                ref.read(astroUseClientDobProvider.notifier).state = val;
                setState(() { _chartData = null; _selectedDate = null; _selectedHour = null; });
                if (!val && u?.dob != null) _loadChart(u!.dob);
              }) : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink()),
        ])),

        // ── Client DOB row ─────────────────────────────────────────────────
        if (useClient) Padding(padding: const EdgeInsets.fromLTRB(16,0,16,8), child: Row(children: [
          Expanded(child: TextField(
            controller: _nameCtrl,
            onChanged: (v) => ref.read(astroClientNameProvider.notifier).state = v,
            style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            decoration: InputDecoration(
              hintText: 'Client name', hintStyle: GoogleFonts.dmSans(fontSize: 12, color: secondary.withOpacity(0.5)),
              filled: true, fillColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border, width: 0.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: gold, width: 1))),
          )),
          const SizedBox(width: 8),
          GestureDetector(onTap: () => _pickClientDob(isDark, gold),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.cake_outlined, size: 13, color: gold), const SizedBox(width: 6),
                Text(clientDob != null ? _fmtDate(clientDob) : 'Enter DOB',
                    style: GoogleFonts.dmSans(fontSize: 12, color: clientDob != null ? gold : secondary)),
              ]))),
          if (clientDob != null) ...[const SizedBox(width: 6),
            GestureDetector(onTap: _clearClient, child: Container(padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgSubtleLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
              child: Icon(Icons.close, size: 14, color: secondary)))],
        ])),

        // ── Body ──────────────────────────────────────────────────────────
        Expanded(child: activeDob == null
          ? _EmptyState(isDark: isDark, gold: gold, onPickDob: () => _pickClientDob(isDark, gold))
          : _loading ? Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold))
          : _error != null ? _ErrView(error: _error!, onRetry: () => _loadChart(activeDob!), gold: gold)
          : _chartData == null ? const SizedBox.shrink()
          : _ChartBody(
              dob: activeDob,
              chartData: _chartData!,
              yogaData: _yogaData,
              isDark: isDark, gold: gold,
              selectedDate: _selectedDate, selectedHour: _selectedHour,
              onPickDate: () => _pickChartDate(activeDob, isDark, gold),
              onClearDate: () { setState(() { _selectedDate = null; _selectedHour = null; }); _loadChart(activeDob); },
            )),
      ])),
    );
  }
}

// ─── Toggle chip ─────────────────────────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final bool useClient; final bool isDark; final Color gold; final ValueChanged<bool> onToggle;
  const _ToggleChip({required this.useClient, required this.isDark, required this.gold, required this.onToggle});
  @override Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: border, width: 0.5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _Chip(label: 'Client', active: useClient, gold: gold, isDark: isDark, onTap: () => onToggle(true)),
        _Chip(label: 'My Chart', active: !useClient, gold: gold, isDark: isDark, onTap: () => onToggle(false)),
      ]));
  }
}
class _Chip extends StatelessWidget {
  final String label; final bool active; final Color gold; final bool isDark; final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.gold, required this.isDark, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: active ? gold.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? gold : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)))));
}

class _EmptyState extends StatelessWidget {
  final bool isDark; final Color gold; final VoidCallback onPickDob;
  const _EmptyState({required this.isDark, required this.gold, required this.onPickDob});
  @override Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.grid_view_outlined, size: 40, color: gold.withOpacity(0.4)), const SizedBox(height: 16),
      Text('Enter Client DOB', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)), const SizedBox(height: 8),
      Text('Pick a date of birth to view the chart', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
      const SizedBox(height: 24),
      GestureDetector(onTap: onPickDob, child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(10)),
        child: Text('Select DOB', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)))),
    ])));
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

// ─── Chart Body ───────────────────────────────────────────────────────────────
class _ChartBody extends StatelessWidget {
  final DateTime dob;
  final Map<String, dynamic> chartData;
  final Map<String, dynamic>? yogaData;
  final bool isDark; final Color gold;
  final DateTime? selectedDate; final int? selectedHour;
  final VoidCallback onPickDate; final VoidCallback onClearDate;

  const _ChartBody({required this.dob, required this.chartData, required this.yogaData,
      required this.isDark, required this.gold, required this.selectedDate,
      required this.selectedHour, required this.onPickDate, required this.onClearDate});

  String _fmtDate(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
  String _fmtIso(dynamic v) {
    if (v == null) return '';
    try { final d = DateTime.parse(v.toString()); const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; } catch(_) { return v.toString(); }
  }

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final card = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;

    final basic = chartData['basic'] as int? ?? NumerologyEngine.basicNumber(dob.day);
    final destiny = chartData['destiny'] as int? ?? NumerologyEngine.destinyNumber(dob);
    final maha = chartData['maha'] as Map<String, dynamic>? ?? {};
    final antar = chartData['antar'] as Map<String, dynamic>? ?? {};
    final monthly = chartData['monthly'] as Map<String, dynamic>? ?? {};
    final mahaNum = (maha['number'] as int?) ?? 0;
    final antarNum = (antar['number'] as int?) ?? 0;
    final monthlyNum = (monthly['number'] as int?) ?? 0;
    final dailyNum = chartData['daily'] as int? ?? 0;
    final hourlyNum = chartData['hourly'] as int? ?? 0;

    // Use API grid directly — daily/hourly already injected by backend
    final grid = chartData['grid'] as List<dynamic>? ?? [];

    // Yogas — field is 'yoga' not 'name'
    final yogas = (yogaData?['yogas'] as List? ?? []).cast<Map<String, dynamic>>();

    final displayDate = selectedDate ?? DateTime.now();
    final clientName = ''; // accessed from provider via ConsumerWidget but here we use a param approach

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── DOB + Date selector row ────────────────────────────────────────
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: gold.withOpacity(0.06), borderRadius: BorderRadius.circular(8), border: Border.all(color: gold.withOpacity(0.15), width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cake_outlined, size: 12, color: gold), const SizedBox(width: 6),
              Text(_fmtDate(dob), style: GoogleFonts.dmSans(fontSize: 11, color: gold, fontWeight: FontWeight.w500)),
            ])),
          const SizedBox(width: 8),
          GestureDetector(onTap: onPickDate,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: selectedDate != null ? gold.withOpacity(0.08) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selectedDate != null ? gold.withOpacity(0.4) : border, width: 0.5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_month_outlined, size: 12, color: selectedDate != null ? gold : secondary), const SizedBox(width: 5),
                Text(
                  selectedDate != null
                    ? '${_fmtDate(selectedDate!)}${selectedHour != null ? "  ${selectedHour}:00" : ""}'
                    : 'Today',
                  style: GoogleFonts.dmSans(fontSize: 11, color: selectedDate != null ? gold : secondary)),
              ]))),
          if (selectedDate != null) ...[const SizedBox(width: 6),
            GestureDetector(onTap: onClearDate, child: Icon(Icons.close, size: 14, color: secondary))],
        ]),
        const SizedBox(height: 14),

        // ── Number pills ──────────────────────────────────────────────────
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _NPill(label: 'BASIC', number: basic, color: gold, isDark: isDark),
          const SizedBox(width: 6),
          _NPill(label: 'DESTINY', number: destiny, color: gold.withOpacity(0.75), isDark: isDark),
          const SizedBox(width: 6),
          _NPill(label: 'MAHA', number: mahaNum, color: gold, isDark: isDark, hi: true),
          const SizedBox(width: 6),
          _NPill(label: 'ANTAR', number: antarNum, color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
          const SizedBox(width: 6),
          _NPill(label: 'MONTHLY', number: monthlyNum, color: const Color(0xFF6366F1), isDark: isDark),
          const SizedBox(width: 6),
          _NPill(label: 'DAILY', number: dailyNum, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, isDark: isDark),
          if (hourlyNum > 0) ...[const SizedBox(width: 6),
            _NPill(label: 'HOURLY', number: hourlyNum, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight, isDark: isDark)],
        ])),
        const SizedBox(height: 18),

        // ── Grid — uses API response with daily/hourly injected ─────────────
        if (grid.isNotEmpty) ...[
          _GridWidget(grid: grid, isDark: isDark, gold: gold),
          const SizedBox(height: 10),
          _GridLegend(
            maha: mahaNum, antar: antarNum, monthly: monthlyNum,
            daily: dailyNum > 0 ? dailyNum : null,
            hourly: hourlyNum > 0 ? hourlyNum : null,
            isDark: isDark, gold: gold,
          ),
        ],
        const SizedBox(height: 20),

        // ── Dasha cards ───────────────────────────────────────────────────
        _SecLabel(label: 'CURRENT DASHAS', isDark: isDark),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: Column(children: [
            _DRow(label: 'Mahadasha', num: mahaNum, planet: (maha['planet'] as String?) ?? NumerologyEngine.planetNames[mahaNum] ?? '', start: _fmtIso(maha['start']), end: _fmtIso(maha['end']), color: gold, isDark: isDark),
            Divider(height: 16, color: border),
            _DRow(label: 'Antardasha', num: antarNum, planet: (antar['planet'] as String?) ?? NumerologyEngine.planetNames[antarNum] ?? '', start: _fmtIso(antar['start']), end: _fmtIso(antar['end']), color: isDark ? AppColors.successDark : AppColors.success, isDark: isDark),
            Divider(height: 16, color: border),
            _DRow(label: 'Monthly', num: monthlyNum, planet: (monthly['planet'] as String?) ?? NumerologyEngine.planetNames[monthlyNum] ?? '', start: _fmtIso(monthly['start']), end: _fmtIso(monthly['end']), color: const Color(0xFF6366F1), isDark: isDark),
            Divider(height: 16, color: border),
            Row(children: [
              _NumBadge(number: dailyNum, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              const SizedBox(width: 10),
              Text('Daily Dasha — ${NumerologyEngine.planetNames[dailyNum] ?? ""}',
                  style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: primary)),
              const Spacer(),
              if (hourlyNum > 0) ...[
                _NumBadge(number: hourlyNum, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                const SizedBox(width: 6),
                Text('Hourly', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
              ],
            ]),
          ])),

        // ── Yogas ─────────────────────────────────────────────────────────
        if (yogas.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SecLabel(label: 'YOGAS', isDark: isDark),
          const SizedBox(height: 8),
          ...yogas.map((y) => _YCard(yoga: y, isDark: isDark, gold: gold)),
        ],
      ]),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────
class _SecLabel extends StatelessWidget {
  final String label; final bool isDark;
  const _SecLabel({required this.label, required this.isDark});
  @override Widget build(BuildContext context) => Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight));
}

class _NPill extends StatelessWidget {
  final String label; final int number; final Color color; final bool isDark; final bool hi;
  const _NPill({required this.label, required this.number, required this.color, required this.isDark, this.hi = false});
  @override Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: hi ? color.withOpacity(0.1) : (isDark ? AppColors.bgCardDark : AppColors.bgCardLight), borderRadius: BorderRadius.circular(8), border: Border.all(color: hi ? color.withOpacity(0.4) : border, width: 0.5)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(number > 0 ? number.toString() : '—', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: color, height: 1)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(fontSize: 7, color: color.withOpacity(0.8), fontWeight: FontWeight.w600, letterSpacing: 0.4)),
      ]));
  }
}

class _NumBadge extends StatelessWidget {
  final int number; final Color color;
  const _NumBadge({required this.number, required this.color});
  @override Widget build(BuildContext context) => Container(width: 26, height: 26,
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Center(child: Text(number > 0 ? number.toString() : '—', style: GoogleFonts.cormorantGaramond(fontSize: 15, color: color))));
}

class _DRow extends StatelessWidget {
  final String label, planet, start, end; final int num; final Color color; final bool isDark;
  const _DRow({required this.label, required this.num, required this.planet, required this.start, required this.end, required this.color, required this.isDark});
  @override Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
        child: Center(child: Text(num > 0 ? num.toString() : '—', style: GoogleFonts.cormorantGaramond(fontSize: 16, color: color)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label — $planet', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: primary)),
        if (start.isNotEmpty && end.isNotEmpty) Text('$start → $end', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
      ])),
    ]);
  }
}

class _YCard extends StatelessWidget {
  final Map<String, dynamic> yoga; final bool isDark; final Color gold;
  const _YCard({required this.yoga, required this.isDark, required this.gold});
  @override Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    // API returns 'yoga' field not 'name'
    final name = yoga['yoga'] as String? ?? yoga['name'] as String? ?? '';
    final desc = yoga['description'] as String? ?? yoga['desc'] as String? ?? '';
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: gold, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
          if (desc.isNotEmpty) ...[const SizedBox(height: 3), Text(desc, style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.5))],
        ])),
      ]));
  }
}

// ─── Grid Widget (same as user chart) ────────────────────────────────────────
class _GridWidget extends StatelessWidget {
  final List<dynamic> grid;
  final bool isDark;
  final Color gold;
  const _GridWidget({required this.grid, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    const planetLabels = [
      ['Jupiter', 'Sun', 'Mars'],
      ['Venus', 'Ketu', 'Mercury'],
      ['Moon', 'Saturn', 'Rahu'],
    ];
    return Container(
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5)),
      child: Column(children: List.generate(3, (row) => Row(
        children: List.generate(3, (col) {
          final cell = (grid[row] as List<dynamic>)[col] as List<dynamic>;
          final planet = planetLabels[row][col];
          return Expanded(child: Container(
            height: 90,
            decoration: BoxDecoration(border: Border(
              right: col == 2 ? BorderSide.none : BorderSide(color: border, width: 0.5),
              bottom: row == 2 ? BorderSide.none : BorderSide(color: border, width: 0.5),
            )),
            child: _GridCellWidget(cell: cell, planet: planet, isDark: isDark, gold: gold),
          ));
        }),
      ))),
    );
  }
}

class _GridCellWidget extends StatelessWidget {
  final List<dynamic> cell;
  final String planet;
  final bool isDark;
  final Color gold;
  const _GridCellWidget({required this.cell, required this.planet, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    if (cell.isEmpty) {
      return Center(child: Text('—', style: GoogleFonts.dmSans(fontSize: 18, color: textTertiary)));
    }
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          children: cell.map((item) {
            final m = item as Map<String, dynamic>;
            final highlight = m['highlight'] as String? ?? '';
            Color numColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            if (highlight == 'maha')    numColor = gold;
            if (highlight == 'antar')   numColor = successColor;
            if (highlight == 'monthly') numColor = const Color(0xFF6366F1);
            if (highlight == 'daily')   numColor = const Color(0xFF06B6D4);  // cyan
            if (highlight == 'hourly')  numColor = const Color(0xFFF59E0B);  // amber
            return Text('${m['value']}',
                style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w400, color: numColor));
          }).toList(),
        ),
        const SizedBox(height: 2),
        Text(planet, style: GoogleFonts.dmSans(fontSize: 8, color: textTertiary), textAlign: TextAlign.center),
      ]),
    );
  }
}

// ─── Grid Legend ──────────────────────────────────────────────────────────────
class _GridLegend extends StatelessWidget {
  final int maha, antar, monthly;
  final int? daily, hourly;
  final bool isDark;
  final Color gold;
  const _GridLegend({required this.maha, required this.antar, required this.monthly,
      this.daily, this.hourly, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final items = <Map<String, dynamic>>[
      {'label': 'Maha', 'number': maha, 'color': gold},
      {'label': 'Antar', 'number': antar, 'color': successColor},
      {'label': 'Monthly', 'number': monthly, 'color': const Color(0xFF6366F1)},
      if (daily != null) {'label': 'Daily', 'number': daily, 'color': const Color(0xFF06B6D4)},
      if (hourly != null) {'label': 'Hourly', 'number': hourly, 'color': const Color(0xFFF59E0B)},
    ];
    return Wrap(spacing: 12, runSpacing: 6,
      children: items.map((item) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: item['color'] as Color)),
        const SizedBox(width: 5),
        Text('${item['label']} (${item['number']})', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
      ])).toList());
  }
}
