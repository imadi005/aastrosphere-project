import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
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

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _load(DateTime dob) async {
    setState(() { _loading = true; _error = null; });
    try {
      final dobStr = _dobStr(dob);
      final results = await Future.wait([ApiService.getChart(dobStr), ApiService.getYogas(dobStr)]);
      if (mounted) setState(() { _chartData = results[0]; _yogaData = results[1]; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load chart'; _loading = false; });
    }
  }

  Future<void> _pickDob(bool isDark, Color gold) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(astroClientDobProvider) ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: isDark
            ? ColorScheme.dark(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardDark, onSurface: AppColors.textPrimaryDark)
            : ColorScheme.light(primary: gold, onPrimary: Colors.black, surface: AppColors.bgCardLight, onSurface: AppColors.textPrimaryLight)),
        child: child!),
    );
    if (picked != null && mounted) {
      ref.read(astroClientDobProvider.notifier).state = picked;
      ref.read(astroUseClientDobProvider.notifier).state = true;
      await _load(picked);
    }
  }

  void _clearClient() {
    ref.read(astroClientDobProvider.notifier).state = null;
    ref.read(astroClientNameProvider.notifier).state = '';
    _nameCtrl.clear();
    setState(() { _chartData = null; _yogaData = null; _error = null; });
  }

  String _dobStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _fmtDate(DateTime d) { const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final useClient = ref.watch(astroUseClientDobProvider);
    final clientDob = ref.watch(astroClientDobProvider);
    final userAsync = ref.watch(userProfileProvider);
    DateTime? activeDob = useClient ? clientDob : userAsync.valueOrNull?.dob;
    if (!useClient && activeDob != null && _chartData == null && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(activeDob!));
    }
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8), child: Row(children: [
          Text('Chart', style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w400)),
          const Spacer(),
          userAsync.maybeWhen(
            data: (u) => u?.isAstrologer == true ? _ToggleChip(useClient: useClient, isDark: isDark, gold: gold, onToggle: (val) {
              ref.read(astroUseClientDobProvider.notifier).state = val;
              setState(() { _chartData = null; });
              if (!val && u?.dob != null) _load(u!.dob);
            }) : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink()),
        ])),
        if (useClient) Padding(padding: const EdgeInsets.fromLTRB(16,0,16,8), child: Row(children: [
          Expanded(child: TextField(
            controller: _nameCtrl,
            onChanged: (v) => ref.read(astroClientNameProvider.notifier).state = v,
            style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            decoration: InputDecoration(
              hintText: 'Client name (optional)',
              hintStyle: GoogleFonts.dmSans(fontSize: 12, color: secondary.withOpacity(0.5)),
              filled: true, fillColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border, width: 0.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: gold, width: 1))),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _pickDob(isDark, gold),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.3), width: 0.5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: gold),
                const SizedBox(width: 6),
                Text(clientDob != null ? _fmtDate(clientDob) : 'Enter DOB',
                    style: GoogleFonts.dmSans(fontSize: 12, color: clientDob != null ? gold : secondary)),
              ]),
            ),
          ),
          if (clientDob != null) ...[const SizedBox(width: 6),
            GestureDetector(onTap: _clearClient,
              child: Container(padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: isDark ? AppColors.bgCardDark : AppColors.bgSubtleLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
                child: Icon(Icons.close, size: 14, color: secondary))),
          ],
        ])),
        Expanded(child: activeDob == null
          ? _EmptyState(isDark: isDark, gold: gold, onPickDob: () => _pickDob(isDark, gold))
          : _loading ? Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold))
          : _error != null ? _ErrView(error: _error!, onRetry: () => _load(activeDob!), gold: gold)
          : _chartData == null ? const SizedBox.shrink()
          : _ChartBody(dob: activeDob, chartData: _chartData!, yogaData: _yogaData, isDark: isDark, gold: gold)),
      ])),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final bool useClient; final bool isDark; final Color gold; final ValueChanged<bool> onToggle;
  const _ToggleChip({required this.useClient, required this.isDark, required this.gold, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    return Container(decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border, width: 0.5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _Chip(label: 'Client', active: useClient, gold: gold, isDark: isDark, onTap: () => onToggle(true)),
        _Chip(label: 'My Chart', active: !useClient, gold: gold, isDark: isDark, onTap: () => onToggle(false)),
      ]));
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool active; final Color gold; final bool isDark; final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.gold, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: active ? gold.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? gold : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)))));
}

class _EmptyState extends StatelessWidget {
  final bool isDark; final Color gold; final VoidCallback onPickDob;
  const _EmptyState({required this.isDark, required this.gold, required this.onPickDob});
  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.grid_view_outlined, size: 40, color: gold.withOpacity(0.4)),
      const SizedBox(height: 16),
      Text('Enter Client DOB', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)),
      const SizedBox(height: 8),
      Text('Pick a date of birth to view the complete numerology chart', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.5)),
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
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(error, style: GoogleFonts.dmSans(fontSize: 13)),
    const SizedBox(height: 12),
    GestureDetector(onTap: onRetry, child: Text('Retry', style: GoogleFonts.dmSans(color: gold, fontWeight: FontWeight.w600))),
  ]));
}

class _ChartBody extends StatelessWidget {
  final DateTime dob; final Map<String, dynamic> chartData; final Map<String, dynamic>? yogaData; final bool isDark; final Color gold;
  const _ChartBody({required this.dob, required this.chartData, required this.yogaData, required this.isDark, required this.gold});
  String _fmtDate(DateTime d) { const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; }
  String _fmtIso(String? iso) { if (iso==null) return ''; try { final d=DateTime.parse(iso); const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${m[d.month-1]} ${d.year}'; } catch(_){return iso;} }

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
    final mahaNum = maha['number'] as int? ?? 0;
    final antarNum = antar['number'] as int? ?? 0;
    final monthlyNum = monthly['number'] as int? ?? 0;
    final grid = NumerologyEngine.buildGrid(dob, mahaOverride: mahaNum>0?mahaNum:null, antarOverride: antarNum>0?antarNum:null, monthlyOverride: monthlyNum>0?monthlyNum:null);
    final digits = NumerologyEngine.chartDigits(dob);
    final missing = [1,2,3,4,5,6,7,8,9].where((n)=>!digits.contains(n)).toList();
    final yogas = (yogaData?['yogas'] as List? ?? []).cast<Map<String,dynamic>>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16,0,16,40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal:12,vertical:8), decoration: BoxDecoration(color:gold.withOpacity(0.06),borderRadius:BorderRadius.circular(8),border:Border.all(color:gold.withOpacity(0.15),width:0.5)),
          child: Row(children:[Icon(Icons.cake_outlined,size:13,color:gold),const SizedBox(width:8),Text(_fmtDate(dob),style:GoogleFonts.dmSans(fontSize:12,color:gold,fontWeight:FontWeight.w500))])),
        const SizedBox(height:16),
        Row(children:[
          _NPill(label:'BASIC',number:basic,color:gold,isDark:isDark),
          const SizedBox(width:8),
          _NPill(label:'DESTINY',number:destiny,color:gold.withOpacity(0.75),isDark:isDark),
          const SizedBox(width:8),
          _NPill(label:'MAHA',number:mahaNum,color:gold,isDark:isDark,hi:true),
          const SizedBox(width:8),
          _NPill(label:'ANTAR',number:antarNum,color:isDark?AppColors.successDark:AppColors.success,isDark:isDark),
        ]),
        const SizedBox(height:20),
        Center(child:NumerologyGrid(grid:grid,cellSize:72)),
        const SizedBox(height:20),
        _SecLabel(label:'CURRENT DASHAS',isDark:isDark),
        const SizedBox(height:8),
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:card,borderRadius:BorderRadius.circular(12),border:Border.all(color:border,width:0.5)),
          child:Column(children:[
            _DRow(label:'Mahadasha',num:mahaNum,start:_fmtIso(maha['start'] as String?),end:_fmtIso(maha['end'] as String?),planet:maha['planet'] as String?? NumerologyEngine.planetNames[mahaNum]??'',color:gold,isDark:isDark),
            const SizedBox(height:8),Divider(height:1,color:border),const SizedBox(height:8),
            _DRow(label:'Antardasha',num:antarNum,start:_fmtIso(antar['start'] as String?),end:_fmtIso(antar['end'] as String?),planet:antar['planet'] as String?? NumerologyEngine.planetNames[antarNum]??'',color:isDark?AppColors.successDark:AppColors.success,isDark:isDark),
            const SizedBox(height:8),Divider(height:1,color:border),const SizedBox(height:8),
            _DRow(label:'Monthly',num:monthlyNum,start:_fmtIso(monthly['start'] as String?),end:_fmtIso(monthly['end'] as String?),planet:monthly['planet'] as String?? NumerologyEngine.planetNames[monthlyNum]??'',color:const Color(0xFF6366F1),isDark:isDark),
          ])),
        if(missing.isNotEmpty)...[const SizedBox(height:20),
          _SecLabel(label:'MISSING NUMBERS',isDark:isDark),const SizedBox(height:8),
          Wrap(spacing:8,runSpacing:8,children:missing.map((n)=>_MChip(number:n,isDark:isDark)).toList()),
        ],
        if(yogas.isNotEmpty)...[const SizedBox(height:20),
          _SecLabel(label:'YOGAS',isDark:isDark),const SizedBox(height:8),
          ...yogas.map((y)=>_YCard(yoga:y,isDark:isDark,gold:gold)),
        ],
      ]),
    );
  }
}

class _SecLabel extends StatelessWidget {
  final String label; final bool isDark;
  const _SecLabel({required this.label, required this.isDark});
  @override Widget build(BuildContext context) => Text(label, style: GoogleFonts.dmSans(fontSize:9,fontWeight:FontWeight.w700,letterSpacing:1.2,color:isDark?AppColors.textSecondaryDark:AppColors.textSecondaryLight));
}

class _NPill extends StatelessWidget {
  final String label; final int number; final Color color; final bool isDark; final bool hi;
  const _NPill({required this.label,required this.number,required this.color,required this.isDark,this.hi=false});
  @override Widget build(BuildContext context) {
    final border=isDark?AppColors.borderDark:AppColors.borderLight;
    return Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),decoration:BoxDecoration(color:hi?color.withOpacity(0.1):(isDark?AppColors.bgCardDark:AppColors.bgCardLight),borderRadius:BorderRadius.circular(8),border:Border.all(color:hi?color.withOpacity(0.4):border,width:0.5)),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(number>0?number.toString():'—',style:GoogleFonts.cormorantGaramond(fontSize:20,color:color,height:1)),
        const SizedBox(height:2),
        Text(label,style:GoogleFonts.dmSans(fontSize:8,color:color.withOpacity(0.8),fontWeight:FontWeight.w600,letterSpacing:0.5)),
      ]));
  }
}

class _DRow extends StatelessWidget {
  final String label,start,end,planet; final int num; final Color color; final bool isDark;
  const _DRow({required this.label,required this.num,required this.start,required this.end,required this.planet,required this.color,required this.isDark});
  @override Widget build(BuildContext context) {
    final primary=isDark?AppColors.textPrimaryDark:AppColors.textPrimaryLight;
    final secondary=isDark?AppColors.textSecondaryDark:AppColors.textSecondaryLight;
    return Row(children:[
      Container(width:28,height:28,decoration:BoxDecoration(color:color.withOpacity(0.1),borderRadius:BorderRadius.circular(7)),
        child:Center(child:Text(num>0?num.toString():'—',style:GoogleFonts.cormorantGaramond(fontSize:16,color:color)))),
      const SizedBox(width:10),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('$label — $planet',style:GoogleFonts.dmSans(fontSize:12,fontWeight:FontWeight.w500,color:primary)),
        if(start.isNotEmpty&&end.isNotEmpty) Text('$start → $end',style:GoogleFonts.dmSans(fontSize:10,color:secondary)),
      ])),
    ]);
  }
}

class _MChip extends StatelessWidget {
  final int number; final bool isDark;
  const _MChip({required this.number,required this.isDark});
  @override Widget build(BuildContext context) {
    final planet=NumerologyEngine.planetNames[number]??'';
    final warn=isDark?AppColors.warningDark:AppColors.warning;
    final warnBg=isDark?AppColors.warningBgDark:AppColors.warningBg;
    return Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:warnBg,borderRadius:BorderRadius.circular(8),border:Border.all(color:warn.withOpacity(0.3),width:0.5)),
      child:Row(mainAxisSize:MainAxisSize.min,children:[Text(number.toString(),style:GoogleFonts.cormorantGaramond(fontSize:16,color:warn)),const SizedBox(width:6),Text(planet,style:GoogleFonts.dmSans(fontSize:10,color:warn))]));
  }
}

class _YCard extends StatelessWidget {
  final Map<String,dynamic> yoga; final bool isDark; final Color gold;
  const _YCard({required this.yoga,required this.isDark,required this.gold});
  @override Widget build(BuildContext context) {
    final primary=isDark?AppColors.textPrimaryDark:AppColors.textPrimaryLight;
    final secondary=isDark?AppColors.textSecondaryDark:AppColors.textSecondaryLight;
    final border=isDark?AppColors.borderDark:AppColors.borderLight;
    final name=yoga['name'] as String?? '';
    final desc=yoga['description'] as String?? yoga['desc'] as String?? '';
    final isPos=(yoga['type'] as String?)!='challenging';
    return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:isDark?AppColors.bgCardDark:AppColors.bgCardLight,borderRadius:BorderRadius.circular(10),border:Border.all(color:border,width:0.5)),
      child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Container(width:6,height:6,margin:const EdgeInsets.only(top:5),decoration:BoxDecoration(color:isPos?gold:(isDark?AppColors.warningDark:AppColors.warning),shape:BoxShape.circle)),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(name,style:GoogleFonts.dmSans(fontSize:12,fontWeight:FontWeight.w600,color:primary)),
          if(desc.isNotEmpty)...[const SizedBox(height:3),Text(desc,style:GoogleFonts.dmSans(fontSize:11,color:secondary,height:1.5))],
        ])),
      ]));
  }
}
