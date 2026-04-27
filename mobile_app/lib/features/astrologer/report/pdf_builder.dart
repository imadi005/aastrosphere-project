import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../core/numerology/numerology_engine.dart';
import 'astro_report_screen.dart';

// ── THEME ─────────────────────────────────────────────────────────────────────
const _gold    = PdfColor(0.62, 0.45, 0.08);
const _goldBg  = PdfColor(0.99, 0.96, 0.88);
const _goldBd  = PdfColor(0.72, 0.55, 0.15);
const _dark    = PdfColor(0.10, 0.10, 0.10);
const _body    = PdfColor(0.22, 0.22, 0.22);
const _muted   = PdfColor(0.50, 0.50, 0.50);
const _subtle  = PdfColor(0.88, 0.88, 0.88);
const _danger  = PdfColor(0.72, 0.10, 0.10);
const _dangerBg= PdfColor(0.99, 0.93, 0.93);
const _warn    = PdfColor(0.65, 0.35, 0.02);
const _warnBg  = PdfColor(0.99, 0.96, 0.88);
const _good    = PdfColor(0.10, 0.48, 0.20);
const _goodBg  = PdfColor(0.92, 0.98, 0.93);
const _goodBd  = PdfColor(0.15, 0.55, 0.25);
const _info    = PdfColor(0.12, 0.28, 0.60);
const _infoBg  = PdfColor(0.92, 0.95, 0.99);
const _card    = PdfColor(0.97, 0.97, 0.97);
const _white   = PdfColors.white;

String _p(int n) => {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',
    6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'}[n] ?? '';

String _s(String? t) {
  if (t == null || t.isEmpty) return '';
  return t
    .replaceAll('\u2014','--').replaceAll('\u2013','-')
    .replaceAll('\u2019',"'").replaceAll('\u2018',"'")
    .replaceAll('\u201C','"').replaceAll('\u201D','"')
    .replaceAll('\u2022','-').replaceAll('\u2026','...')
    .replaceAll('&','and').replaceAll('\u00e9','e');
}

// ── Dense text helper — truncates at word boundary ───────────────────────────
String _trim(String? t, int maxChars) {
  if (t == null || t.isEmpty) return '';
  final s = _s(t);
  if (s.length <= maxChars) return s;
  final cut = s.lastIndexOf(' ', maxChars);
  return cut > 0 ? '${s.substring(0, cut)}...' : '${s.substring(0, maxChars)}...';
}

const _gridPos = {3:[0,0],1:[0,1],9:[0,2],6:[1,0],7:[1,1],5:[1,2],2:[2,0],8:[2,1],4:[2,2]};
const _gridAbbr = [['Ju','Su','Ma'],['Ve','Ke','Me'],['Mo','Sa','Ra']];

class PdfReportBuilder {

  static Future<String> build({
    required String clientName,
    required DateTime dob,
    required String astrologerName,
    required String astrologerPhone,
    required int years,
    required List<YearSection> sections,
  }) async {
    final pw.Font reg  = pw.Font.helvetica();
    final pw.Font bold = pw.Font.helveticaBold();

    pw.ImageProvider? logo;
    try {
      final b = await rootBundle.load('assets/images/app_icon.png');
      logo = pw.MemoryImage(b.buffer.asUint8List());
    } catch (_) {}

    final doc = pw.Document(theme: pw.ThemeData.withFont(base: reg, bold: bold));

    final dobStr  = '${dob.day}/${dob.month}/${dob.year}';
    final basic   = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    final natal   = NumerologyEngine.chartDigits(dob).toSet();
    final now     = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final astroLabel = astrologerName.isNotEmpty ? astrologerName : 'Astrologer';
    final astroPhone = astrologerPhone.isNotEmpty ? '  |  $astrologerPhone' : '';

    pw.Widget hdr(pw.Context c) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 7),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _subtle, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Row(children: [
          if (logo != null) pw.Opacity(opacity: 0.55, child: pw.Image(logo, width: 12, height: 12)),
          if (logo != null) pw.SizedBox(width: 5),
          pw.Text('AASTROSPHERE', style: pw.TextStyle(fontSize: 6.5, color: _gold, letterSpacing: 1.5, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Text('${_s(clientName)}  |  $dateStr', style: pw.TextStyle(fontSize: 6.5, color: _muted)),
      ]));

    pw.Widget ftr(pw.Context c) => pw.Container(
      padding: const pw.EdgeInsets.only(top: 7),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _subtle, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('$astroLabel$astroPhone', style: pw.TextStyle(fontSize: 6.5, color: _muted)),
        pw.Text('Page ${c.pageNumber} of ${c.pagesCount}', style: pw.TextStyle(fontSize: 6.5, color: _muted)),
        pw.Text('(c) Aastrosphere  |  Confidential', style: pw.TextStyle(fontSize: 6.5, color: _muted)),
      ]));

    // ── COVER ─────────────────────────────────────────────────────────────────
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(children: [
        pw.Container(color: _white),
        if (logo != null) pw.Positioned(top: 140, left: 50,
          child: pw.Opacity(opacity: 0.04, child: pw.Image(logo, width: 500, height: 500))),
        pw.Positioned(top: 0, left: 0, right: 0, child: pw.Container(height: 4, color: _gold)),
        pw.Positioned(bottom: 0, left: 0, right: 0, child: pw.Container(height: 4, color: _gold)),
        pw.Padding(padding: const pw.EdgeInsets.fromLTRB(56, 64, 56, 48),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('NUMEROLOGY LIFE REPORT', style: pw.TextStyle(
                fontSize: 9, color: _gold, letterSpacing: 3, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 22),
            pw.Text(_s(clientName), style: pw.TextStyle(
                fontSize: 38, color: _dark, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Container(width: 70, height: 1.5, color: _gold),
            pw.SizedBox(height: 20),
            _cr('Date of Birth', dobStr),
            pw.SizedBox(height: 6),
            _cr('Basic Number', '$basic -- ${_p(basic)}'),
            pw.SizedBox(height: 6),
            _cr('Destiny Number', '$destiny -- ${_p(destiny)}'),
            pw.SizedBox(height: 6),
            _cr('Report Covers', '$years Years from $dateStr'),
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(color: _goldBg,
                border: pw.Border.all(color: _goldBd, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
              child: pw.Row(children: [
                if (logo != null) pw.Opacity(opacity: 0.8, child: pw.Image(logo, width: 28, height: 28)),
                if (logo != null) pw.SizedBox(width: 10),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('AASTROSPHERE', style: pw.TextStyle(
                      fontSize: 11, color: _gold, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 2),
                  pw.Text('Prepared by $astroLabel$astroPhone',
                      style: pw.TextStyle(fontSize: 8, color: _muted)),
                  pw.Text('Generated on $dateStr',
                      style: pw.TextStyle(fontSize: 8, color: _muted)),
                ]),
              ])),
          ])),
      ])));

    // ── NATAL ─────────────────────────────────────────────────────────────────
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
      header: hdr, footer: ftr,
      build: (ctx) => [
        _st('NATAL OVERVIEW'), pw.SizedBox(height: 10),
        _natalOverview(basic, destiny, natal),
        pw.SizedBox(height: 16),
        _st('NATAL CHART'), pw.SizedBox(height: 10),
        _natalChart(basic, destiny, natal),
      ]));

    // ── YEAR PAGES ────────────────────────────────────────────────────────────
    int? prevMaha;
    for (final s in sections) {
      if (prevMaha != s.mahaNum) {
        doc.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
          header: hdr, footer: ftr,
          build: (ctx) => _mahaBannerPage(s.mahaNum, s.mahaPlanet)));
        prevMaha = s.mahaNum;
      }
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
        header: hdr, footer: ftr,
        build: (ctx) => _yearPage(s, natal, dob)));
    }

    final dir  = await getTemporaryDirectory();
    final safe = clientName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final path = '${dir.path}/Aastrosphere_${safe}_Report.pdf';
    await File(path).writeAsBytes(await doc.save());
    return path;
  }

  // ── Section title ─────────────────────────────────────────────────────────
  static pw.Widget _st(String t) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(t, style: pw.TextStyle(fontSize: 8.5, color: _gold,
          letterSpacing: 2, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: _gold),
    ]);

  static pw.Widget _cr(String l, String v) => pw.Row(children: [
    pw.Text('$l  ', style: pw.TextStyle(fontSize: 11, color: _muted)),
    pw.Text(_s(v), style: pw.TextStyle(fontSize: 11, color: _dark, fontWeight: pw.FontWeight.bold)),
  ]);

  // ── Natal overview ─────────────────────────────────────────────────────────
  static pw.Widget _natalOverview(int basic, int destiny, Set<int> natal) {
    final items = <pw.Widget>[];
    items.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: _box(
        'Basic Number $basic -- ${_p(basic)}',
        'Core personality, daily behavior, and driving energy. This number describes how this person naturally shows up, their automatic reactions, and instinctive patterns in all situations.',
        _gold, _goldBg, _goldBd)),
      pw.SizedBox(width: 10),
      pw.Expanded(child: _box(
        'Destiny Number $destiny -- ${_p(destiny)}',
        'Life direction, soul purpose, and karmic path. The themes that keep repeating until integrated. Career direction, life lessons, and the deepest calling -- all encoded in this number.',
        _gold, _goldBg, _goldBd)),
    ]));
    items.add(pw.SizedBox(height: 10));

    // Natal combination analysis
    final combos = <String, String>{};
    if (natal.contains(4) && natal.contains(9)) combos['4-9 Natal'] =
        'Rahu (4) and Mars (9) present at birth. Physically impulsive tendency -- highest accident risk combination. This is NOT destiny, it is a tendency that requires DAILY conscious management. Never rush physical actions. Double-check before moving. This pattern intensifies during any Rahu or Mars dasha.';
    if (natal.contains(5) && natal.contains(7)) combos['5-7 Easy Money Yoga'] =
        'Mercury (5) and Ketu (7) both present. Financial gains arrive with significantly less effort than average throughout life. Money flows when focus and intent are aligned. This yoga activates and strengthens whenever 5 or 7 appears in the annual Maha or Antardasha.';
    if (natal.contains(1) && natal.contains(2) && !natal.contains(3) && !natal.contains(6)) combos['Raj Yoga'] =
        'Sun (1) and Moon (2) present with clear path -- no 3 above, no 6 below. Authority positions are natural territory throughout life. Career advancement and public recognition are strongly supported. This yoga peaks when Mahadasha or Antardasha activates 1 or 2.';
    if (natal.contains(8) && natal.contains(9)) combos['8-9 Tension'] =
        'Saturn (8) and Mars (9) both present. Relentless determination, enormous output capacity, but the load never stops. Heart and blood pressure require vigilance throughout life. Physical health is a lifelong practice, not an option. Intensifies during Saturn or Mars mahadashas.';
    if (natal.contains(3) && natal.contains(1) && natal.contains(9)) combos['3-1-9 Uplift'] =
        'Jupiter (3), Sun (1), and Mars (9) all present. Naturally uplifting energy. Confidence, leadership, and courage are all strong simultaneously. Achievements come more easily. Any year where these three combine actively in the annual chart becomes a breakthrough year.';
    if (natal.contains(2) && natal.contains(8)) combos['2-8 Emotional Load'] =
        'Moon (2) and Saturn (8) both present. Deep sensitivity combined with heavy responsibility. Depression and loneliness tendency throughout life, especially during Moon or Saturn dashas. Consistent routine, strong social support, and physical exercise are essential lifelong practices.';

    for (final e in combos.entries) {
      final isRisk = e.key.contains('4-9') || e.key.contains('Tension') || e.key.contains('Load');
      items.add(_box(e.key, e.value, 
        isRisk ? _danger : _good,
        isRisk ? _dangerBg : _goodBg,
        isRisk ? _danger : _goodBd));
      items.add(pw.SizedBox(height: 8));
    }
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: items);
  }

  // ── Natal chart ─────────────────────────────────────────────────────────────
  static pw.Widget _natalChart(int basic, int destiny, Set<int> natal) {
    final missing = [1,2,3,4,5,6,7,8,9].where((n) => !natal.contains(n)).toList();
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _grid(null, null, null, natal: natal, size: 46.0),
      pw.SizedBox(width: 16),
      pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('PRESENT NUMBERS', style: pw.TextStyle(fontSize: 7.5, color: _muted,
            fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 5, runSpacing: 4, children: natal.map((n) =>
            _chip('$n ${_p(n)}', _gold, _goldBg, _goldBd)).toList()),
        pw.SizedBox(height: 10),
        if (missing.isNotEmpty) ...[
          pw.Text('MISSING NUMBERS', style: pw.TextStyle(fontSize: 7.5, color: _muted,
              fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
          pw.SizedBox(height: 5),
          pw.Wrap(spacing: 5, runSpacing: 4, children: missing.map((n) =>
              _chip('$n ${_p(n)}', _warn, _warnBg, _warn)).toList()),
          pw.SizedBox(height: 10),
        ],
        pw.Text('Missing numbers represent areas of life that require more conscious effort and attention. '
            'They are not weaknesses -- they are growth edges that become strengths when developed intentionally.',
            style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
      ])),
    ]);
  }

  // ── Mahadasha banner ────────────────────────────────────────────────────────
  static const _mDesc = {
    1: 'Authority, leadership, ambition. Need for recognition grows. Confidence swings between peak and valley. Career is center stage.',
    2: 'Emotional sensitivity peaks. Creativity surges. Social connections multiply. Mental health requires vigilance. Deep spiritual longing.',
    3: 'Morality, ethics, spiritual seeking. Family bonds deepen. Teaching and counseling gifts emerge. Higher wisdom is sought.',
    4: 'Illusion, restlessness, confusion. Expect the unexpected. Major disruptions. New directions appear suddenly. Guard against deception.',
    5: 'Sharp intellect, business acumen. Communication skills peak. Multiple opportunities. Financial focus intensifies. Fast-moving decisions.',
    6: 'Luxury, relationships, beauty. Romance heightens. Comfort-seeking. Food and aesthetics matter more. Financial flow through partnerships.',
    7: 'Luck peaks. Analytical power at maximum. Spiritual depth grows. Intuition is strongest here. Travel and freedom are themes.',
    8: 'Hard work, discipline, delays. Patience is tested. Financial lessons arrive. Health management required. Karmic account settlement.',
    9: 'Courage, action, ambition. Leadership and competition. Energy surge. Projects accelerate. Anger risk rises. Results come faster.',
  };
  static const _mBring = {
    1: 'Financial growth, status elevation, name and fame, awards, competition victories, career advancement. Growth in all life aspects.',
    2: 'Social circle expansion, contact with influential people, networking success, collaborative opportunities. Creative recognition.',
    3: 'Learning, family bonding, seeking a guru, spiritual discourse, life purpose clarity. Higher education opportunities bloom.',
    4: 'When aligned -- clarity, logical thinking, meaningful travels, enhanced decision-making, unexpected breakthroughs.',
    5: 'Increased cash flow, business opportunities, communication success, financial security. Strong earnings period.',
    6: 'Relationship strengthening, romantic and marital developments, career in arts or hospitality, comfort and beauty in life.',
    7: 'Luck and success, ease in overcoming challenges, stability, spiritual growth, travel opportunities. Things work out.',
    8: 'When channeled -- professional advancement, financial rewards, improved health, life purpose fulfillment, karmic payoffs.',
    9: 'Personal growth, career advancements, leadership opportunities. Positive, expansive period full of achievements.',
  };
  static const _mWarn = {
    1: 'When alone (no 3 or 9 active) -- confidence collapses, ego becomes vulnerability. Guard against self-doubt and arrogance equally.',
    2: 'Double 2 (22) -- sadness, anxiety, emotional instability. Insomnia risk. Depression tendency. Strong mental health discipline needed.',
    3: 'When 3 creates 33 -- moral flexibility, spiritual showmanship. Family bonds loosen. Addiction temptations increase.',
    4: 'Financial losses, job risk, debt accumulation, scam vulnerability, accidents, mental confusion. HIGH CAUTION. Never rush decisions.',
    5: '555 energy -- overconfidence, fraud risk, money obsession. Deceptive behavior possible. Guard every financial decision carefully.',
    6: '66 energy -- conflicts increase, harsh speech, ego-driven materialism. Relationships become transactional.',
    7: '77 energy -- career instability, relationship challenges, anxiety and insomnia increase. Substance use risk.',
    8: 'Hard work with delayed results. Financial hardship, career challenges, health management needed. Patience is the ONLY remedy.',
    9: '99 energy -- legal issues, financial challenges, relationship strain, health concerns, conflict-prone period.',
  };

  static List<pw.Widget> _mahaBannerPage(int num, String planet) => [
    pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(color: _goldBg,
        border: pw.Border.all(color: _goldBd, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: pw.BoxDecoration(color: _gold,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Text('MAHADASHA $num  --  ${planet.toUpperCase()}',
              style: pw.TextStyle(fontSize: 11, color: _white,
                  fontWeight: pw.FontWeight.bold, letterSpacing: 0.8))),
        pw.SizedBox(height: 14),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _subBox('ENERGY IN THIS PERIOD',
              _s(_mDesc[num]), _info)),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _subBox('WHAT THIS PERIOD BRINGS',
              _s(_mBring[num]), _good)),
        ]),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(color: _warnBg,
              border: pw.Border.all(color: _warn, width: 0.4),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('WATCH OUT:  ', style: pw.TextStyle(
                fontSize: 8, color: _warn, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(child: pw.Text(_s(_mWarn[num]),
                style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5))),
          ])),
      ])),
    pw.SizedBox(height: 16),
    pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: _card,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Text(
        'Mahadasha ${_p(num)} ($num) is the master arc -- the background frequency that colors every year within it. '
        'Think of it as the season. Each Antardasha is the specific weather within that season. '
        'When the Antardasha energy aligns with the Mahadasha energy, results amplify. '
        'When they conflict, tension increases and patience is required. '
        'The pages that follow break down exactly what each year within this period brings.',
        style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.7))),
  ];

  // ── Year page ────────────────────────────────────────────────────────────────
  static const _antDesc = {
    1: 'Authority and leadership qualities emerge strongly. Ego amplifies -- need for respect and recognition increases. Confidence surges, commanding presence in all interactions. Anger control requires daily effort.',
    2: 'Emotional sensitivity increases dramatically. Creativity surges. Self-expression rises. Strong need for emotional security. Shyness and sentimentality emerge. Social connections matter more.',
    3: 'Heightened morality and ethics. Addiction control improves. Family attachment deepens. Spirituality grows. Natural counseling and teaching skills come forward. Wisdom-seeking phase.',
    4: 'Illusion and imaginative thinking dominate. Lack of logic, restlessness, moodiness. Tries new things impulsively without completing old ones. Expect sudden and unexpected events.',
    5: 'Sharp mind, money focus, excellent communication. Playful and childlike energy. Speaks mind directly. Calculative, workaholic tendencies, fast decision-making. Multiple opportunities appear.',
    6: 'Luxury-seeking, relationship-focused, appearance-conscious. Food interest increases. Direct communication, romantic nature, desire for comfort and beauty. Partnerships become important.',
    7: 'Analytical thinking increases dramatically. LUCK and desire realization peak. Reduced struggles, spirituality upsurge, travel ease. Intuition is at its strongest. Things fall into place.',
    8: 'Hard work required without immediate reward. Disappointments and delays. Financial pressure. Negative attitude can develop. Charitable inclination. Patience is the only path.',
    9: 'Confidence boost, boldness, courage and assertive energy. Competitive attitude, commitment strengthens. Energy surge. Physical activity increases. Action-oriented. Results come faster.',
  };
  static const _antBring = {
    1: 'Leadership peak. Financial growth possible. Status elevation. Recognition arrives. Career advancement. Competition victories.',
    2: 'Social circle expansion. Creative recognition. Networking breakthroughs. Emotional depth in relationships.',
    3: 'Family harmony. Spiritual growth. Teaching opportunities. Higher education. Wisdom and clarity.',
    4: 'Unexpected breakthroughs. Sudden travel. New directions. When aligned -- clarity and logical breakthroughs.',
    5: 'Cash flow increases. Business success. Communication wins. Multiple income streams active.',
    6: 'Romantic developments. Relationship strengthening. Arts and beauty career. Financial flow through partnerships.',
    7: 'Peak luck period. Career breakthroughs possible. Spiritual insight. Travel and freedom.',
    8: 'When channeled correctly -- karmic payoffs, professional advancement, improved health.',
    9: 'Personal growth surge. Leadership opportunities. Achievements multiply. Energy is high.',
  };

  // Combination-specific predictions
  static const _comboText = {
    '8_9': 'Saturn demands patience while Mars pushes for speed. This creates relentless pressure. The person works incredibly hard but feels the results lag behind effort. Physical health -- especially heart and blood pressure -- must be actively managed. This combination builds extraordinary strength but at a cost. Those who survive it emerge with unshakeable resilience.',
    '8_8': 'Double Saturn intensifies everything. Delays on top of delays. Financial tightening. But this is also the period where character is truly forged. Those who maintain discipline through this period emerge with structural stability that very few people achieve. Avoid debt at all costs during this period.',
    '8_3': 'Saturn slows down and Jupiter brings wisdom. A year of spiritual depth, ethical reflection, and family connection. Financial growth is slow but steady. Teaching, mentoring, or studying brings unexpected rewards. The combination supports long-term planning over quick gains.',
    '8_7': 'Saturn delays meet Ketu bad luck. A genuinely difficult period. The person feels abandoned by fortune. Spiritual practice and charitable acts are the only reliable remedies. Avoid new ventures. Consolidate existing commitments. The period passes and clarity returns.',
    '8_5': 'Saturn discipline applied to Mercury intelligence. Sharp analytical period. Financial decisions made here tend to be sound because emotions are less active. Business planning, research, and skill development all benefit. Not a period for big launches, but excellent for preparation.',
    '8_2': 'Saturn heaviness meets Moon sensitivity. Depression risk is real. Emotional heaviness, loneliness, and low energy are likely themes. Consistent routine is medicine. Social connection is medicine. Physical movement is medicine. Do not isolate during this period.',
    '8_4': 'Saturn delays plus Rahu confusion equals total stagnation. Nothing moves. Nothing clicks. This is the period where the person must simply hold the line without breaking. Do not make major decisions. Do not take on new debt. Simply maintain and survive. It passes.',
    '8_6': 'Saturn work ethic meets Venus comfort-seeking. A productive but internally conflicted year. Career progress requires sacrifice of pleasures. Relationships either stabilize through commitment or face reality check. Not a year for luxury spending, but a year where genuine values clarify.',
    '8_1': 'Saturn patience meets Sun authority. Hard work finally gets recognized -- but slowly. Career authority builds. Leadership roles open up but come with extra responsibility. The combination rewards consistency over brilliance.',
    '9_9': 'Double Mars creates maximum energy, aggression risk, and physical strain. Incredible capacity for work and action. But anger flares, legal risks rise, and accidents become more likely. Channel this energy into physical training and structured projects. Do NOT let it become conflict.',
    '9_1': 'Mars courage meets Sun leadership. Peak leadership period. Confidence is contagious. Others follow naturally. Career authority peaks. Guard against ego inflation and anger outbursts. Accident risk is real when moving fast.',
    '9_4': 'Mars impulsiveness meets Rahu instability. HIGHEST ACCIDENT RISK COMBINATION. Never rush physical movements. Drive slowly. Avoid confrontations. Physical harm through impulsive action is the primary risk. The energy is intense but must be channeled into structured, careful action.',
    '9_2': 'Mars aggression meets Moon sensitivity. Emotional aggression is the primary challenge. Arguments in relationships are very likely. Channel this energy into creative output -- writing, music, art absorb the intensity productively.',
    '9_7': 'Mars action meets Ketu luck. Excellent period for effortless progress. Work feels aligned. Financial gains arrive with less effort than usual. Travel and spiritual insights come naturally. One of the more comfortable combinations within Mars maha.',
    '9_3': 'Mars strength meets Jupiter wisdom. Powerful combination for growth with wisdom. Leadership with ethics. Business expansion with integrity. Family bonds strengthen while ambition rises. Excellent for long-term ventures launched this year.',
    '9_8': 'Mars determination meets Saturn patience. Immense capacity but heavy load. This combination builds empires through sheer persistence. Guard health -- heart, BP, and physical exhaustion are real risks. Rest is not optional, it is strategic.',
    '9_5': 'Mars energy meets Mercury intelligence. Fast thinking, fast moving, fast results. Communication and business both thrive. Multiple projects run simultaneously. Guard against overcommitment and mental fatigue.',
    '9_6': 'Mars ambition meets Venus relationships. Career and romance both active simultaneously. Romantic intensity rises. Business partnerships can be romantic and vice versa. Financial flow through Venus-ruled activities -- arts, beauty, hospitality.',
    '1_9': 'Sun authority meets Mars action. Leadership peaks. Decisiveness is at maximum. Career advancement is very likely. Guard ego -- the combination can produce arrogance that pushes away support.',
    '1_7': 'Sun authority meets Ketu luck. Career breakthroughs arrive unexpectedly. Lucky period for authority figures. Some detachment from material pursuits brings clarity. Intuition is sharp.',
    '1_2': 'Sun recognition meets Moon emotions. Public visibility increases. Career and emotional life both demand attention simultaneously. Guard mental health. This can be a beautiful combination when balanced.',
    '2_9': 'Moon sensitivity meets Mars aggression. Emotional aggression is the primary challenge. Channel creativity intensely. Arguments are very likely in relationships. Physical movement helps manage the intensity.',
    '2_3': 'Moon sensitivity meets Jupiter wisdom. Spiritual, creative, and emotionally rich period. Family connections deepen. Creative work flourishes. One of the gentler combinations in Moon maha.',
    '2_4': 'Moon emotions meet Rahu illusion. Emotional instability and deception risk. Not a good period for trust-based decisions. Keep finances guarded. Reality testing is difficult -- what feels real may not be.',
    '2_7': 'Moon intuition meets Ketu spiritual power. Deeply spiritual, highly intuitive period. Creative and emotional sensitivity at maximum. Some material detachment. Lucky in unexpected ways.',
    '3_1': 'Jupiter wisdom meets Sun authority. Spiritual authority emerges. Teaching and leadership combine powerfully. Excellent for any work that involves guiding others. Financial wisdom improves.',
    '3_9': 'Jupiter ethics meet Mars action. Ethical action, moral courage, principled leadership. Excellent for launching ventures that require both wisdom and energy. Family and career both benefit.',
    '4_9': 'Rahu confusion meets Mars impulsiveness. MAXIMUM PHYSICAL RISK. This is the most dangerous combination for accidents. EVERY physical movement requires deliberate caution. Drive slowly, walk carefully, avoid risky physical activities entirely.',
    '4_2': 'Rahu confusion meets Moon sensitivity. Emotional instability and proneness to deception. Guard finances and relationships equally. What appears real may be illusion. Reality-testing is essential.',
    '4_8': 'Rahu confusion meets Saturn delays. Total stagnation. Frustration and confusion peak. Nothing moves forward. This is a survival period -- simply maintain without breaking. It ends.',
    '5_7': 'Mercury intelligence meets Ketu luck. Easy Money yoga activated. Financial gains arrive with less effort. Business and financial acumen are at maximum. One of the best combinations for wealth building.',
    '6_4': 'Venus relationships meet Rahu illusion. Romantic deception risk. Relationships may not be what they appear. Guard financial commitments made under romantic pressure. Attraction without stability.',
    '7_8': 'Ketu bad luck meets Saturn delays. Double negative. Financial and personal setbacks accumulate. Spiritual practice and charity are the only reliable remedies. This combination strips away what is not real.',
  };

  static List<pw.Widget> _yearPage(YearSection s, Set<int> natal, DateTime dob) {
    final rich = s.richData;
    final ws = <pw.Widget>[];
    final hasHigh = s.warnings.any((w) => w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK'));
    final comboKey1 = '${s.mahaNum}_${s.antarNum}';
    final comboKey2 = '${s.antarNum}_${s.mahaNum}';
    final combo = _comboText[comboKey1] ?? _comboText[comboKey2] ?? '';

    // ── Year header ─────────────────────────────────────────────────────────
    ws.add(pw.Row(children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: pw.BoxDecoration(color: _gold,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
        child: pw.Text(_s(s.label), style: pw.TextStyle(
            fontSize: 12, color: _white, fontWeight: pw.FontWeight.bold))),
      pw.SizedBox(width: 8),
      if (s.isCurrent) _badge('CURRENT', _good),
      if (hasHigh) ...[pw.SizedBox(width: 6), _badge('HIGH RISK', _danger)],
      pw.Spacer(),
      pw.Text('Maha ${s.mahaNum} ${_p(s.mahaNum)}  |  Antar ${s.antarNum} ${_p(s.antarNum)}',
          style: pw.TextStyle(fontSize: 8, color: _muted)),
    ]));
    ws.add(pw.SizedBox(height: 12));

    // ── Chart + Antardasha ──────────────────────────────────────────────────
    ws.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Column(children: [
        _grid(s.mahaNum, s.antarNum, s.monthlyNum, natal: natal, size: 40.0),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 5, runSpacing: 3, children: [
          _dot(_gold, 'M${s.mahaNum}'),
          _dot(_info, 'A${s.antarNum}'),
          _dot(_good, 'Mo${s.monthlyNum}'),
        ]),
      ]),
      pw.SizedBox(width: 12),
      pw.Expanded(child: pw.Container(
        padding: const pw.EdgeInsets.all(11),
        decoration: pw.BoxDecoration(color: _infoBg,
            border: pw.Border.all(color: _info, width: 0.3),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('ANTARDASHA ${s.antarNum} -- ${_p(s.antarNum).toUpperCase()}',
              style: pw.TextStyle(fontSize: 8, color: _info, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(_s(_antDesc[s.antarNum]),
              style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
          pw.SizedBox(height: 5),
          pw.Text('BRINGS: ${_s(_antBring[s.antarNum])}',
              style: pw.TextStyle(fontSize: 8, color: _good, lineSpacing: 1.4)),
        ]))),
    ]));
    ws.add(pw.SizedBox(height: 12));

    // ── Maha+Antar Combination Prediction (rich, specific) ─────────────────
    if (combo.isNotEmpty) {
      ws.add(pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: pw.BoxDecoration(
          color: _goldBg,
          border: pw.Border(left: pw.BorderSide(color: _gold, width: 3.5))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('MAHA ${s.mahaNum} + ANTAR ${s.antarNum} -- WHAT THIS SPECIFICALLY MEANS',
              style: pw.TextStyle(fontSize: 8, color: _gold, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(_s(combo),
              style: pw.TextStyle(fontSize: 8.5, color: _dark, lineSpacing: 1.7)),
        ])));
      ws.add(pw.SizedBox(height: 12));
    }

    // ── Backend rich data ────────────────────────────────────────────────────
    if (rich != null) {
      // Year in one line
      final oneLine = rich['year_in_one_line'] as String?;
      if (oneLine != null && oneLine.isNotEmpty) {
        ws.add(pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: pw.BoxDecoration(
            color: _dark,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Text(_s(oneLine),
              style: pw.TextStyle(fontSize: 9.5, color: _white,
                  fontWeight: pw.FontWeight.bold, lineSpacing: 1.4))));
        ws.add(pw.SizedBox(height: 12));
      }

      // Full year overview
      final overview = rich['overview'] as String?;
      if (overview != null && overview.isNotEmpty) {
        ws.add(_st('YEAR OVERVIEW'));
        ws.add(pw.SizedBox(height: 7));
        ws.add(pw.Text(_s(overview),
            style: pw.TextStyle(fontSize: 9, color: _body, lineSpacing: 1.75)));
        ws.add(pw.SizedBox(height: 12));
      }

      // What this year specifically
      final specific = rich['this_year_specifically'] as String?;
      if (specific != null && specific.isNotEmpty && specific.length > 20) {
        ws.add(pw.Container(
          padding: const pw.EdgeInsets.all(11),
          decoration: pw.BoxDecoration(color: _infoBg,
              border: pw.Border.all(color: _info, width: 0.4),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('THIS YEAR SPECIFICALLY', style: pw.TextStyle(
                fontSize: 8, color: _info, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text(_s(specific),
                style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.6)),
          ])));
        ws.add(pw.SizedBox(height: 12));
      }

      // Current chapter
      final cc = rich['current_chapter'] as Map?;
      if (cc != null) {
        final ccTitle = cc['title'] as String? ?? '';
        final happening = cc['what_is_actually_happening'] as String? ?? '';
        final gift = cc['the_gift'] as String? ?? '';
        final trap = cc['the_trap'] as String? ?? '';
        if (ccTitle.isNotEmpty || happening.isNotEmpty) {
          ws.add(_st('CURRENT CHAPTER: ${_s(ccTitle).toUpperCase()}'));
          ws.add(pw.SizedBox(height: 7));
          if (happening.isNotEmpty) {
            ws.add(_lbl('What is actually happening:', _body, _card));
            ws.add(pw.SizedBox(height: 4));
            ws.add(pw.Text(_s(happening),
                style: pw.TextStyle(fontSize: 9, color: _body, lineSpacing: 1.7)));
            ws.add(pw.SizedBox(height: 8));
          }
          ws.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            if (gift.isNotEmpty) pw.Expanded(child: _subBox('THE GIFT', _s(gift), _good)),
            if (gift.isNotEmpty && trap.isNotEmpty) pw.SizedBox(width: 8),
            if (trap.isNotEmpty) pw.Expanded(child: _subBox('THE TRAP', _s(trap), _danger)),
          ]));
          ws.add(pw.SizedBox(height: 12));
        }
      }

      // 4 life areas — dense rich predictions
      final fin = rich['finance'] as Map?;
      final car = rich['career'] as Map?;
      final rel = rich['relationships'] as Map?;
      final hlt = rich['health'] as Map?;
      final areas = <Map<String,String>>[];
      if (fin != null) {
        final sig = _s(fin['year_signal'] as String?);
        final pat = _s(fin['your_pattern'] as String?);
        if (sig.isNotEmpty || pat.isNotEmpty)
          areas.add({'t':'FINANCE & WEALTH','b':'$sig${pat.isNotEmpty ? " Their pattern: $pat" : ""}'});
      }
      if (car != null) {
        final sig = _s(car['year_signal'] as String?);
        final pat = _s(car['your_pattern'] as String?);
        if (sig.isNotEmpty || pat.isNotEmpty)
          areas.add({'t':'CAREER & WORK','b':'$sig${pat.isNotEmpty ? " Their pattern: $pat" : ""}'});
      }
      if (rel != null) {
        final sig = _s(rel['year_signal'] as String?);
        final pat = _s(rel['your_pattern'] as String?);
        if (sig.isNotEmpty || pat.isNotEmpty)
          areas.add({'t':'RELATIONSHIPS','b':'$sig${pat.isNotEmpty ? " Their pattern: $pat" : ""}'});
      }
      if (hlt != null) {
        final wch = _s(hlt['watch'] as String?);
        final pat = _s(hlt['your_pattern'] as String?);
        if (wch.isNotEmpty || pat.isNotEmpty)
          areas.add({'t':'HEALTH','b':'$wch${pat.isNotEmpty ? " Pattern: $pat" : ""}'});
      }
      if (areas.isNotEmpty) {
        ws.add(_st('LIFE AREAS THIS YEAR'));
        ws.add(pw.SizedBox(height: 7));
        for (int i = 0; i < areas.length; i += 2) {
          final l = areas[i]; final r = i+1 < areas.length ? areas[i+1] : null;
          ws.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: _card,
                  border: pw.Border(left: pw.BorderSide(color: _gold, width: 2))),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(l['t']!, style: pw.TextStyle(fontSize: 7.5, color: _gold,
                    fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(l['b']!, style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.6)),
              ]))),
            if (r != null) pw.SizedBox(width: 8),
            if (r != null) pw.Expanded(child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: _card,
                  border: pw.Border(left: pw.BorderSide(color: _gold, width: 2))),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(r['t']!, style: pw.TextStyle(fontSize: 7.5, color: _gold,
                    fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(r['b']!, style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.6)),
              ]))),
          ]));
          ws.add(pw.SizedBox(height: 8));
        }
        ws.add(pw.SizedBox(height: 6));
      }

      // Opportunities
      final opps = (rich['opportunities'] as List?)?.cast<String>() ?? [];
      if (opps.isNotEmpty) {
        ws.add(_st('OPPORTUNITIES THIS YEAR'));
        ws.add(pw.SizedBox(height: 7));
        for (final o in opps) {
          ws.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
            decoration: pw.BoxDecoration(color: _goodBg,
                border: pw.Border(left: pw.BorderSide(color: _good, width: 2))),
            child: pw.Text(_s(o),
                style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.5))));
        }
        ws.add(pw.SizedBox(height: 8));
      }

      // Watch out (backend + local combined)
      final watchOut = (rich['watch_out'] as List?)?.cast<String>() ?? [];
      final allW = [...s.warnings, ...watchOut.where((w) =>
          !s.warnings.any((sw) => sw.contains(w.substring(0, [w.length, 20].reduce((a, b) => a < b ? a : b))))
      )];
      if (allW.isNotEmpty) {
        ws.add(_st('WATCH OUT FOR'));
        ws.add(pw.SizedBox(height: 7));
        for (final w in allW) {
          final isH = w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK') || w.contains('MAXIMUM');
          ws.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
            decoration: pw.BoxDecoration(
              color: isH ? _dangerBg : _warnBg,
              border: pw.Border(left: pw.BorderSide(color: isH ? _danger : _warn, width: 2))),
            child: pw.Text(_s(w),
                style: pw.TextStyle(fontSize: 8.5,
                    color: isH ? _danger : _body, lineSpacing: 1.5))));
        }
        ws.add(pw.SizedBox(height: 8));
      }

      // Month guidance
      final bestM = rich['best_months'] as String?;
      final riskyM = rich['risky_months'] as String?;
      if ((bestM != null && bestM.isNotEmpty) || (riskyM != null && riskyM.isNotEmpty)) {
        ws.add(_st('MONTH GUIDANCE'));
        ws.add(pw.SizedBox(height: 7));
        if (bestM != null && bestM.isNotEmpty)
          ws.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(color: _goodBg,
                border: pw.Border.all(color: _goodBd, width: 0.4),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Row(children: [
              pw.Text('BEST: ', style: pw.TextStyle(fontSize: 7.5, color: _good, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(_s(bestM), style: pw.TextStyle(fontSize: 8.5, color: _body))),
            ])));
        if (riskyM != null && riskyM.isNotEmpty)
          ws.add(pw.Container(
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(color: _warnBg,
                border: pw.Border.all(color: _warn, width: 0.4),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Row(children: [
              pw.Text('CAUTION: ', style: pw.TextStyle(fontSize: 7.5, color: _warn, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(_s(riskyM), style: pw.TextStyle(fontSize: 8.5, color: _body))),
            ])));
        ws.add(pw.SizedBox(height: 8));
      }

      // Month breakdown table (from richData months_breakdown)
      final months = (rich['months_breakdown'] as List?)?.cast<Map>() ?? [];
      if (months.isNotEmpty) {
        ws.add(_st('MONTH BY MONTH'));
        ws.add(pw.SizedBox(height: 7));
        ws.add(_monthTableFromRich(months, s));
        ws.add(pw.SizedBox(height: 10));
      } else {
        // fallback: local month table
        ws.add(_st('MONTH BY MONTH'));
        ws.add(pw.SizedBox(height: 7));
        ws.add(_monthTableLocal(s, natal, dob));
        ws.add(pw.SizedBox(height: 10));
      }

      // Life context modifiers
      final ctx = (rich['life_context'] as List?)?.cast<Map>() ?? [];
      if (ctx.isNotEmpty) {
        ws.add(_st('LIFE CONTEXT ACTIVE THIS YEAR'));
        ws.add(pw.SizedBox(height: 7));
        for (final c in ctx) {
          final title = _s(c['title'] as String?);
          final desc  = _s(c['description'] as String?);
          if (title.isNotEmpty && desc.isNotEmpty)
            ws.add(pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 7),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: _card,
                  border: pw.Border.all(color: _subtle, width: 0.4),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 8, color: _gold, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(desc, style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.6)),
              ])));
        }
        ws.add(pw.SizedBox(height: 8));
      }

      // Active yogas
      if (s.yogas.isNotEmpty) {
        ws.add(_st('ACTIVE YOGAS'));
        ws.add(pw.SizedBox(height: 7));
        ws.add(pw.Wrap(spacing: 6, runSpacing: 5,
            children: s.yogas.map((y) => _chip(_s(y), _good, _goodBg, _goodBd)).toList()));
        ws.add(pw.SizedBox(height: 10));
      }
    } else {
      // No backend data — fallback to local insights
      if (s.insights.isNotEmpty) {
        ws.add(_st('PERIOD ANALYSIS'));
        ws.add(pw.SizedBox(height: 7));
        for (final ins in s.insights) {
          ws.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
            decoration: pw.BoxDecoration(color: _infoBg,
                border: pw.Border(left: pw.BorderSide(color: _info, width: 2))),
            child: pw.Text(_s(ins),
                style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.5))));
        }
        ws.add(pw.SizedBox(height: 8));
      }
      ws.add(_st('MONTH BY MONTH'));
      ws.add(pw.SizedBox(height: 7));
      ws.add(_monthTableLocal(s, natal, dob));
      ws.add(pw.SizedBox(height: 10));
    }

    // Remedies — only where warnings exist
    if (s.warnings.isNotEmpty && s.remedies.isNotEmpty) {
      ws.add(pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(color: _goldBg,
            border: pw.Border.all(color: _goldBd, width: 0.4),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('REMEDIES', style: pw.TextStyle(
              fontSize: 8, color: _gold, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
          pw.SizedBox(height: 5),
          pw.Text(_s(s.remedies),
              style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.7)),
        ])));
    }

    return ws;
  }

  // ── Month table from backend richData ────────────────────────────────────────
  static pw.Widget _monthTableFromRich(List<Map> months, YearSection s) {
    final rows = <pw.TableRow>[];
    rows.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: _card),
      children: ['MONTH','MONTHLY','FINANCE','HEALTH','RISKY DAYS','NOTES'].map((h) =>
        pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(h, style: pw.TextStyle(fontSize: 6.5, color: _muted,
              fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)))).toList()));

    for (final m in months) {
      final name = m['month_name'] as String? ?? '';
      final mNum = m['monthly_number'] as int? ?? 0;
      final label = _s(m['label'] as String?);
      final fin   = _trim(m['finance'] as String?, 60);
      final hlt   = _trim(m['health'] as String?, 55);
      final cauts = (m['caution'] as List?)?.cast<String>() ?? [];
      final bestFor = (m['best_for'] as List?)?.cast<String>() ?? [];
      final isCurrent = m['is_current'] as bool? ?? false;
      final hasRisk = mNum == 4 && (s.antarNum == 9 || s.mahaNum == 9) ||
                      mNum == 9 && (s.antarNum == 4 || s.mahaNum == 4);
      final bg = isCurrent ? _goldBg : (hasRisk ? _dangerBg : (months.indexOf(m) % 2 == 0 ? _white : _card));
      final nc = isCurrent ? _gold : (hasRisk ? _danger : _body);
      final notes = cauts.isNotEmpty ? cauts.first : (bestFor.isNotEmpty ? 'Best for: ${bestFor.first}' : '--');

      final riskyDays = (m['risky_days'] as List?)?.cast<int>() ?? [];
      final luckyDays = (m['lucky_days'] as List?)?.cast<int>() ?? [];
      final riskyDayStr = riskyDays.isNotEmpty ? riskyDays.map((d) => '$d').join(', ') : '--';
      final luckyDayStr = luckyDays.isNotEmpty ? luckyDays.map((d) => '$d').join(', ') : '';
      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(name, style: pw.TextStyle(fontSize: 7.5, color: nc, fontWeight: pw.FontWeight.bold)),
              if (luckyDayStr.isNotEmpty) pw.Text('Lucky: $luckyDayStr', style: pw.TextStyle(fontSize: 6, color: _good)),
            ])),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text('$mNum ${_p(mNum)}', style: pw.TextStyle(fontSize: 7.5, color: isCurrent ? _gold : _info, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(_s(fin), style: pw.TextStyle(fontSize: 7.5, color: _body, lineSpacing: 1.3))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(_s(hlt), style: pw.TextStyle(fontSize: 7.5, color: _body, lineSpacing: 1.3))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(riskyDayStr, style: pw.TextStyle(fontSize: 7.5, color: riskyDays.isNotEmpty ? _danger : _muted, fontWeight: riskyDays.isNotEmpty ? pw.FontWeight.bold : pw.FontWeight.normal))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(_s(notes), style: pw.TextStyle(fontSize: 7.5, color: hasRisk ? _danger : _body, lineSpacing: 1.3))),
        ]));
    }

    return pw.Table(
      columnWidths: {
        0: const pw.FractionColumnWidth(0.13),
        1: const pw.FractionColumnWidth(0.10),
        2: const pw.FractionColumnWidth(0.19),
        3: const pw.FractionColumnWidth(0.19),
        4: const pw.FractionColumnWidth(0.12),
        5: const pw.FractionColumnWidth(0.27),
      },
      border: pw.TableBorder.all(color: _subtle, width: 0.3),
      children: rows);
  }

  // ── Month table fallback ────────────────────────────────────────────────────
  static pw.Widget _monthTableLocal(YearSection s, Set<int> natal, DateTime dob) {
    final basic = NumerologyEngine.basicNumber(dob.day);
    final rows = <pw.TableRow>[];
    rows.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: _card),
      children: ['MONTH','MONTHLY','CHART ACTIVE','NOTES'].map((h) =>
        pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(h, style: pw.TextStyle(fontSize: 6.5, color: _muted,
              fontWeight: pw.FontWeight.bold)))).toList()));

    const mNames = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    for (int m = 1; m <= 12; m++) {
      final td = DateTime(s.year, m, 15);
      final monthly = NumerologyEngine.currentMonthlyDasha(dob, targetDate: td);
      final allNums = {...natal, s.mahaNum, s.antarNum, monthly.number};
      final isRisk = (monthly.number == 4 && (s.antarNum == 9 || s.mahaNum == 9)) ||
                     (monthly.number == 9 && (s.antarNum == 4 || s.mahaNum == 4));
      final notes = <String>[];
      if (allNums.contains(5) && allNums.contains(7)) notes.add('Easy Money active');
      if (allNums.contains(3) && allNums.contains(1) && allNums.contains(9)) notes.add('3-1-9 Uplift');
      if (isRisk) notes.add('HIGH PHYSICAL RISK');
      if (monthly.number == 2 && (s.mahaNum == 2 || s.antarNum == 2)) notes.add('Mental health watch');
      if (notes.isEmpty) notes.add('--');

      final bg = isRisk ? _dangerBg : (m % 2 == 0 ? _card : _white);
      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(mNames[m-1], style: pw.TextStyle(fontSize: 7.5, color: isRisk ? _danger : _body, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text('${monthly.number} ${_p(monthly.number)}', style: pw.TextStyle(fontSize: 7.5, color: isRisk ? _danger : _info, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(allNums.toList().join(', '), style: pw.TextStyle(fontSize: 7, color: _muted))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(notes.join('. '), style: pw.TextStyle(fontSize: 7.5, color: isRisk ? _danger : _body, lineSpacing: 1.4))),
        ]));
    }
    return pw.Table(
      columnWidths: {0: const pw.FractionColumnWidth(0.14), 1: const pw.FractionColumnWidth(0.13), 2: const pw.FractionColumnWidth(0.18), 3: const pw.FractionColumnWidth(0.55)},
      border: pw.TableBorder.all(color: _subtle, width: 0.3),
      children: rows);
  }

  // ── Grid ──────────────────────────────────────────────────────────────────────
  static pw.Widget _grid(int? maha, int? antar, int? monthly,
      {required Set<int> natal, required double size}) =>
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _subtle, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Column(children: List.generate(3, (row) =>
        pw.Row(children: List.generate(3, (col) {
          final num = _gridPos.entries.firstWhere(
              (e) => e.value[0]==row && e.value[1]==col,
              orElse: () => const MapEntry(0,[0,0])).key;
          final isMaha    = maha != null && num == maha;
          final isAntar   = antar != null && num == antar;
          final isMonthly = monthly != null && num == monthly;
          final inNatal   = natal.contains(num);
          PdfColor tc = _muted; PdfColor bg = _white;
          if (isMaha)    { tc = _gold; bg = _goldBg; }
          else if (isAntar)   { tc = _info; bg = _infoBg; }
          else if (isMonthly) { tc = _good; bg = _goodBg; }
          else if (inNatal)   tc = _body;
          return pw.Container(width: size, height: size, color: bg,
            child: pw.Stack(children: [
              if (col < 2) pw.Positioned(right: 0, top: 0, bottom: 0,
                  child: pw.Container(width: 0.3, color: _subtle)),
              if (row < 2) pw.Positioned(left: 0, right: 0, bottom: 0,
                  child: pw.Container(height: 0.3, color: _subtle)),
              pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text('$num', style: pw.TextStyle(fontSize: size * 0.28, color: tc,
                    fontWeight: (isMaha||isAntar||isMonthly||inNatal)
                        ? pw.FontWeight.bold : pw.FontWeight.normal)),
                pw.Text(_gridAbbr[row][col], style: pw.TextStyle(fontSize: size*0.13, color: _muted)),
              ])),
            ]));
        })))));

  // ── Small helpers ─────────────────────────────────────────────────────────────
  static pw.Widget _box(String t, String b, PdfColor tc, PdfColor bg, PdfColor bd) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(color: bg,
          border: pw.Border.all(color: bd, width: 0.4),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(_s(t), style: pw.TextStyle(fontSize: 9, color: tc, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(_s(b), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
      ]));

  static pw.Widget _subBox(String t, String b, PdfColor tc) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: _card,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(t, style: pw.TextStyle(fontSize: 7.5, color: tc,
            fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
        pw.SizedBox(height: 4),
        pw.Text(_s(b), style: pw.TextStyle(fontSize: 8.5, color: _body, lineSpacing: 1.5)),
      ]));

  static pw.Widget _lbl(String t, PdfColor tc, PdfColor bg) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, color: tc, fontWeight: pw.FontWeight.bold)));

  static pw.Widget _badge(String t, PdfColor c) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(color: c,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 6.5, color: _white,
          fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)));

  static pw.Widget _chip(String t, PdfColor tc, PdfColor bg, PdfColor bd) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(color: bg,
          border: pw.Border.all(color: bd, width: 0.3),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, color: tc, fontWeight: pw.FontWeight.bold)));

  static pw.Widget _dot(PdfColor c, String l) => pw.Row(children: [
    pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: c,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)))),
    pw.SizedBox(width: 3),
    pw.Text(l, style: pw.TextStyle(fontSize: 6.5, color: c)),
  ]);
}
