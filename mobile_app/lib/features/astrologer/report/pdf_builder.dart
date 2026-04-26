import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../core/numerology/numerology_engine.dart';
import 'astro_report_screen.dart';

// ── CLEAN LIGHT THEME ─────────────────────────────────────────────────────────
const _white   = PdfColors.white;
const _bg      = PdfColor(0.97, 0.96, 0.94);   // warm off-white
const _card    = PdfColors.white;
const _card2   = PdfColor(0.96, 0.95, 0.93);
const _gold    = PdfColor(0.62, 0.45, 0.08);   // rich gold
const _goldBg  = PdfColor(0.98, 0.95, 0.88);   // gold tint bg
const _goldBd  = PdfColor(0.72, 0.55, 0.15);   // gold border
const _dark    = PdfColor(0.12, 0.12, 0.12);   // near black
const _body    = PdfColor(0.25, 0.25, 0.25);   // body text
const _muted   = PdfColor(0.50, 0.50, 0.50);   // labels
const _subtle  = PdfColor(0.75, 0.75, 0.75);   // borders
const _danger  = PdfColor(0.72, 0.10, 0.10);   // danger red
const _dangerBg= PdfColor(0.98, 0.92, 0.92);
const _warn    = PdfColor(0.65, 0.35, 0.02);   // warm orange
const _warnBg  = PdfColor(0.99, 0.95, 0.88);
const _good    = PdfColor(0.10, 0.45, 0.18);   // green
const _goodBg  = PdfColor(0.92, 0.97, 0.93);
const _info    = PdfColor(0.15, 0.30, 0.58);   // deep blue
const _infoBg  = PdfColor(0.92, 0.95, 0.99);

// ── Helpers ───────────────────────────────────────────────────────────────────
String _p(int n) => {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',
    6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'}[n] ?? '';

String _s(String t) => t
    .replaceAll('\u2014','--').replaceAll('\u2013','-')
    .replaceAll('\u2019',"'").replaceAll('\u2018',"'")
    .replaceAll('\u2022','-').replaceAll('\u2026','...')
    .replaceAll('\u00e9','e').replaceAll('\u00e8','e');

const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const _fullMonths = ['January','February','March','April','May','June',
    'July','August','September','October','November','December'];

// Grid positions
const _gridPos = {3:[0,0],1:[0,1],9:[0,2],6:[1,0],7:[1,1],5:[1,2],2:[2,0],8:[2,1],4:[2,2]};
const _gridAbbr = [['Ju','Su','Ma'],['Ve','Ke','Me'],['Mo','Sa','Ra']];

// ── Per-number rich descriptions ──────────────────────────────────────────────
const _dashaBehavior = {
  1: 'Anger increases, authority and leadership qualities emerge, ego amplifies, strong need for respect and recognition. Confidence surge -- commanding presence in all interactions.',
  2: 'Emotional sensitivity increases sharply, creativity surges, self-expression rises. Shyness and sentimentality emerge. Strong need for emotional security and connection.',
  3: 'Heightened morality and ethics, addiction control improves, family attachment deepens. Spirituality grows. Natural counseling and teaching skills come forward.',
  4: 'Illusion and imaginative thinking dominate. Lack of logic, restlessness, moodiness. Tries new things impulsively without completing old ones. Expect the unexpected.',
  5: 'Sharp mind, money-minded, excellent communication. Playful and childlike energy. Speaks mind directly. Calculative, workaholic tendencies, fast decision-making.',
  6: 'Luxury-seeking, relationship-focused, appearance-conscious. Food interest increases. Direct communication, romantic nature, desire for comfort and beauty.',
  7: 'Analytical thinking increases dramatically. LUCK and desire realization peak. Reduced struggles, spirituality upsurge, travel ease. Intuition is strongest here.',
  8: 'Hard work required without immediate reward. Disappointments and delays. Financial pressure. Negative attitude can develop. Charitable and compassionate inclination.',
  9: 'Confidence boost, boldness, courage and assertive energy. Competitive attitude, commitment strengthens. Energy surge. Physical activity increases. Action-oriented.',
};

const _dashaPositive = {
  1: 'Financial growth, status elevation, name and fame, awards and honors, competition victories, career advancement, leadership roles. Growth in all life aspects.',
  2: 'Social circle expansion, contact with influential people, networking success, visible and influential presence. Collaborative opportunities increase.',
  3: 'Learning and education, family bonding, seeking a guru, spiritual discourse, seeking life purpose. Higher education and wisdom pursuits bloom.',
  4: 'When 4 creates 44 -- clarity of thought, logical behavior, illusions removed, meaningful travels, enhanced decision-making, increased earnings.',
  5: 'Increased cash flow, new investment opportunities, career advancement, business ventures, financial security. Strong earnings period.',
  6: 'Luxurious lifestyle, relationship strengthening, romantic and marital developments, career in arts, hospitality, beauty. Financial comfort.',
  7: 'Luck and success, ease overcoming challenges, stability, spiritual growth, travel opportunities. Things work out effortlessly.',
  8: 'When 8 creates 88 -- Professional advancement, financial growth, improved health, life purpose fulfillment, karmic rewards.',
  9: 'Personal growth, career advancements, increased activity, leadership opportunities. Positive, expansive period full of achievements.',
};

const _dashaNegative = {
  1: 'When alone without 3 or 9 -- softer phase, confidence decreases, leadership diminishes. Ego vulnerability. Guard against self-doubt.',
  2: 'Multiple 2s (22) -- sadness, anxiety, emotional instability. Insomnia risk. Depression tendency. Strong mental health vigilance needed.',
  3: 'When 3 creates 33 -- moral flexibility, spiritual showmanship. Family bonds can loosen. Addiction temptations increase.',
  4: 'Financial expenses and losses, job loss risk, debt accumulation, scam vulnerability, accidents, unwanted travel, mental confusion. HIGH CAUTION.',
  5: 'When 5 creates 555 -- overconfidence, complete money focus, fraud risk. Deceptive behavior possible. Guard financial decisions.',
  6: 'When 6 creates 66 -- conflicts increase, harsh speech, foul language, luxuries at others expense, ego-driven, materialism.',
  7: 'When 7 creates 77 -- instability in career and life, relationship challenges. Anxiety and insomnia. Substance use risk.',
  8: 'Hard work with delayed results. Financial hardship, career challenges, health management needed. Patience is the only remedy.',
  9: 'When 9 creates 99 -- legal issues, financial challenges, relationship strain, health concerns, conflict-prone period.',
};

// Month-wise caution description lookup
const _monthCaution = {
  '4_9': 'HIGH PHYSICAL RISK -- Rahu meets Mars monthly. Drive carefully. Avoid confrontations. No risky activities.',
  '9_4': 'HIGH PHYSICAL RISK -- Mars meets Rahu monthly. Impulsive actions cause harm. Slow down in all areas.',
  '4_4': 'Double Rahu -- extreme impulsiveness. Financial leakage likely. Avoid major decisions this month.',
  '9_9': 'Double Mars -- anger flares, legal risk, physical overexertion. Guard temper and health.',
  '2_4': 'Emotional + Rahu -- deception risk emotionally. Guard trust and finances both.',
  '4_2': 'Rahu + Moon -- confusion and emotional instability. Not a good time for commitments.',
  '8_4': 'Saturn + Rahu -- delays plus confusion. Nothing moves. Stay patient, do not force outcomes.',
  '4_8': 'Rahu + Saturn -- frustration and obstacles peak. Mental health watch.',
  '2_8': 'Moon + Saturn -- depression risk, emotional heaviness. Reach out to trusted people.',
  '8_2': 'Saturn + Moon -- sadness, loneliness tendency. Routine and structure help greatly.',
  '7_8': 'Ketu + Saturn -- bad luck combined with delays. Avoid new ventures this month.',
  '8_7': 'Saturn + Ketu -- past karma comes due. Spiritual practice helps. Avoid shortcuts.',
};

class PdfReportBuilder {

  static Future<String> build({
    required String clientName,
    required DateTime dob,
    required String astrologerName,
    required String astrologerPhone,
    required int years,
    required List<YearSection> sections,
  }) async {
    pw.ImageProvider? logo;
    try {
      final bytes = await rootBundle.load('assets/images/zodiac_circle_gold.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final doc = pw.Document();
    final dobStr = '${dob.day}/${dob.month}/${dob.year}';
    final basic   = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    final natal   = NumerologyEngine.chartDigits(dob).toSet();
    final today   = DateTime.now();
    final dateStr = '${today.day}/${today.month}/${today.year}';
    final astroLabel = astrologerName.isNotEmpty ? astrologerName : 'Astrologer';

    // ── COVER PAGE ────────────────────────────────────────────────────────────
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(children: [
        pw.Container(color: _dark),
        if (logo != null) pw.Positioned(top: 150, left: 50,
          child: pw.Opacity(opacity: 0.05, child: pw.Image(logo, width: 480, height: 480))),
        pw.Positioned(top: 0, left: 0, right: 0, child: pw.Container(height: 4, color: _goldBd)),
        pw.Padding(padding: const pw.EdgeInsets.fromLTRB(56, 60, 56, 48),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('NUMEROLOGY LIFE REPORT', style: pw.TextStyle(
                fontSize: 9, color: _goldBd, letterSpacing: 3, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 22),
            pw.Text(_s(clientName), style: pw.TextStyle(
                fontSize: 38, color: _white, fontWeight: pw.FontWeight.bold, lineSpacing: 1.1)),
            pw.SizedBox(height: 16),
            pw.Container(width: 80, height: 1, color: _goldBd),
            pw.SizedBox(height: 26),
            _coverRow('Date of Birth', dobStr),
            pw.SizedBox(height: 7),
            _coverRow('Basic Number', '$basic -- ${_p(basic)}'),
            pw.SizedBox(height: 7),
            _coverRow('Destiny Number', '$destiny -- ${_p(destiny)}'),
            pw.SizedBox(height: 7),
            _coverRow('Report Covers', '$years Years from $dateStr'),
            pw.Spacer(),
            pw.Container(padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: const PdfColor(0.18, 0.18, 0.18),
                border: pw.Border.all(color: const PdfColor(0.30, 0.30, 0.30), width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
              child: pw.Row(children: [
                if (logo != null) pw.Opacity(opacity: 0.85, child: pw.Image(logo, width: 30, height: 30)),
                if (logo != null) pw.SizedBox(width: 12),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('AASTROSPHERE', style: pw.TextStyle(
                      fontSize: 12, color: _goldBd, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 3),
                  pw.Text('Prepared by $astroLabel${astrologerPhone.isNotEmpty ? "  |  $astrologerPhone" : ""}',
                      style: pw.TextStyle(fontSize: 8, color: const PdfColor(0.60, 0.60, 0.60))),
                  pw.Text('Generated on $dateStr',
                      style: pw.TextStyle(fontSize: 8, color: const PdfColor(0.60, 0.60, 0.60))),
                ]),
              ])),
          ])),
        pw.Positioned(bottom: 0, left: 0, right: 0, child: pw.Container(height: 4, color: _goldBd)),
      ]),
    ));

    // ── CONTENT PAGES ─────────────────────────────────────────────────────────
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
      header: (ctx) => _header(clientName, dateStr, logo),
      footer: (ctx) => _footer(astroLabel, astrologerPhone, ctx),
      build: (ctx) {
        final widgets = <pw.Widget>[];

        // ── NATAL OVERVIEW ────────────────────────────────────────────────────
        widgets.add(_secTitle('NATAL OVERVIEW'));
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(_natalOverview(basic, destiny, natal, dob));
        widgets.add(pw.SizedBox(height: 20));

        // ── NATAL GRID ───────────────────────────────────────────────────────
        widgets.add(_secTitle('NATAL CHART'));
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(_natalGridSection(basic, destiny, natal));
        widgets.add(pw.SizedBox(height: 24));

        // ── YEAR-MONTH BREAKDOWN ─────────────────────────────────────────────
        widgets.add(_secTitle('${years.toString()}-YEAR DETAILED READING'));
        widgets.add(pw.SizedBox(height: 12));

        int? prevMaha;
        for (final s in sections) {
          // Mahadasha change banner
          if (prevMaha != s.mahaNum) {
            if (prevMaha != null) widgets.add(pw.SizedBox(height: 12));
            widgets.add(_mahaBanner(s.mahaNum, s.mahaPlanet, natal));
            widgets.add(pw.SizedBox(height: 8));
            prevMaha = s.mahaNum;
          }
          // Full year card with month breakdown
          widgets.add(_fullYearCard(s, natal, dob));
          widgets.add(pw.SizedBox(height: 12));
        }
        return widgets;
      },
    ));

    final dir = await getTemporaryDirectory();
    final safe = clientName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final path = '${dir.path}/Aastrosphere_${safe}_Report.pdf';
    await File(path).writeAsBytes(await doc.save());
    return path;
  }

  // ── Header / Footer ──────────────────────────────────────────────────────────
  static pw.Widget _header(String client, String date, pw.ImageProvider? logo) =>
    pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _subtle, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Row(children: [
          if (logo != null) pw.Opacity(opacity: 0.6, child: pw.Image(logo, width: 13, height: 13)),
          if (logo != null) pw.SizedBox(width: 6),
          pw.Text('AASTROSPHERE', style: pw.TextStyle(fontSize: 7, color: _gold,
              letterSpacing: 1.5, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Text('${_s(client)}  |  $date', style: pw.TextStyle(fontSize: 7, color: _muted)),
      ]));

  static pw.Widget _footer(String name, String phone, pw.Context ctx) =>
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _subtle, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('$name${phone.isNotEmpty ? "  |  $phone" : ""}',
            style: pw.TextStyle(fontSize: 7, color: _muted)),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _muted)),
        pw.Text('(c) Aastrosphere  |  Confidential',
            style: pw.TextStyle(fontSize: 7, color: _muted)),
      ]));

  // ── Section title ─────────────────────────────────────────────────────────────
  static pw.Widget _secTitle(String t) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(t, style: pw.TextStyle(fontSize: 9, color: _gold,
          letterSpacing: 2, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: _goldBd),
    ]);

  static pw.Widget _coverRow(String l, String v) => pw.Row(children: [
    pw.Text('$l  ', style: pw.TextStyle(fontSize: 11, color: const PdfColor(0.55,0.55,0.55))),
    pw.Text(_s(v), style: pw.TextStyle(fontSize: 11, color: _white, fontWeight: pw.FontWeight.bold)),
  ]);

  // ── Natal overview ────────────────────────────────────────────────────────────
  static pw.Widget _natalOverview(int basic, int destiny, Set<int> natal, DateTime dob) {
    final items = <pw.Widget>[];

    // Basic + Destiny side by side
    items.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: _infoBox('Basic Number $basic -- ${_p(basic)}',
          'Core personality, daily behavior, and driving energy. How this person naturally shows up in every situation.',
          _gold, _goldBg, _goldBd)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _infoBox('Destiny Number $destiny -- ${_p(destiny)}',
          'Life direction, soul purpose, and karmic path. Where life consistently pushes this person, whether they resist or not.',
          _gold, _goldBg, _goldBd)),
    ]));
    items.add(pw.SizedBox(height: 8));

    // Natal yogas
    if (natal.contains(1) && natal.contains(2) && !natal.contains(3) && !natal.contains(6)) {
      items.add(_infoBox('Raj Yoga Present in Natal Chart',
          'Left path of Sun (1) is clear -- 3 absent, 6 absent. Authority positions are natural territory. '
          'Career advancement and public recognition are strongly supported throughout life. '
          'When Mahadasha or Antardasha activates 1 or 2, career peaks are highly likely.',
          _gold, _goldBg, _goldBd));
      items.add(pw.SizedBox(height: 6));
    }
    if (natal.contains(5) && natal.contains(7)) {
      items.add(_infoBox('Easy Money Yoga (5-7) in Natal',
          'Mercury and Ketu both present at birth. Financial gains come with less effort than average throughout life. '
          'Money tends to flow naturally when focus and intent are right. Business and financial acumen are natural gifts.',
          _good, _goodBg, _good));
      items.add(pw.SizedBox(height: 6));
    }
    if (natal.contains(4) && natal.contains(9)) {
      items.add(_infoBox('4-9 Natal Combination -- Lifelong Physical Caution Required',
          'Rahu (4) and Mars (9) both present at birth. This creates a lifelong tendency toward impulsive physical actions '
          'and accident risk. Requires CONSCIOUS management every single day -- especially during Rahu or Mars dashas. '
          'Never rush. Always double-check before physical actions. This does NOT mean accidents will happen -- only that the '
          'tendency exists and must be managed actively.',
          _danger, _dangerBg, _danger));
      items.add(pw.SizedBox(height: 6));
    }
    if (natal.contains(8) && natal.contains(9)) {
      items.add(_infoBox('8-9 Natal Combination -- Heavy Load, Strong Capacity',
          'Saturn and Mars both present. Relentless determination and enormous output capacity. '
          'The heavy work never stops, but the person handles it. Heart and blood pressure need monitoring throughout life. '
          'Physical health vigilance is essential, especially during Saturn or Mars mahadashas.',
          _warn, _warnBg, _warn));
      items.add(pw.SizedBox(height: 6));
    }
    if (natal.contains(3) && natal.contains(1) && natal.contains(9)) {
      items.add(_infoBox('3-1-9 Uplift Combination in Natal',
          'Jupiter, Sun, and Mars all present at birth. Naturally uplifting and positive energy throughout life. '
          'Confidence, leadership, and courage are all strong simultaneously. Achievements come more easily during '
          'periods when these numbers are activated.',
          _good, _goodBg, _good));
    }

    return pw.Column(children: items);
  }

  // ── Natal grid section ───────────────────────────────────────────────────────
  static pw.Widget _natalGridSection(int basic, int destiny, Set<int> natal) {
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      // Grid
      pw.Container(
        width: 140,
        child: _buildGrid(null, null, null, natal: natal, size: 44.0)),
      pw.SizedBox(width: 16),
      // Grid analysis
      pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('PRESENT NUMBERS', style: pw.TextStyle(fontSize: 8, color: _muted,
            fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 6, runSpacing: 5, children: natal.map((n) =>
          _numChip(n, _gold, _goldBg, _goldBd)).toList()),
        pw.SizedBox(height: 10),
        pw.Text('MISSING NUMBERS', style: pw.TextStyle(fontSize: 8, color: _muted,
            fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 6, runSpacing: 5, children: [1,2,3,4,5,6,7,8,9]
            .where((n) => !natal.contains(n))
            .map((n) => _numChip(n, _warn, _warnBg, _warn)).toList()),
        pw.SizedBox(height: 10),
        pw.Text('BASIC $basic (${_p(basic)}): ${_s(_dashaBehavior[basic] ?? "")}',
            style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
      ])),
    ]);
  }

  // ── Mahadasha banner ──────────────────────────────────────────────────────────
  static pw.Widget _mahaBanner(int num, String planet, Set<int> natal) {
    final prediction = _s(_dashaPositive[num] ?? '');
    final behavior   = _s(_dashaBehavior[num] ?? '');
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _goldBg,
        border: pw.Border.all(color: _goldBd, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(color: _gold,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Text('MAHADASHA  $num  --  ${planet.toUpperCase()}',
                style: pw.TextStyle(fontSize: 10, color: _white,
                    fontWeight: pw.FontWeight.bold, letterSpacing: 0.8))),
        ]),
        pw.SizedBox(height: 8),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('ENERGY IN THIS PERIOD', style: pw.TextStyle(fontSize: 7, color: _gold,
                fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
            pw.SizedBox(height: 3),
            pw.Text(behavior, style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
          ])),
          pw.SizedBox(width: 12),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('WHAT THIS PERIOD BRINGS', style: pw.TextStyle(fontSize: 7, color: _good,
                fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
            pw.SizedBox(height: 3),
            pw.Text(prediction, style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
          ])),
        ]),
        if (_dashaNegative[num] != null) ...[
          pw.SizedBox(height: 6),
          pw.Container(padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(color: _warnBg,
                border: pw.Border.all(color: _warn, width: 0.4),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Row(children: [
              pw.Text('WATCH OUT: ', style: pw.TextStyle(fontSize: 7, color: _warn,
                  fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(_s(_dashaNegative[num]!),
                  style: pw.TextStyle(fontSize: 7, color: _warn))),
            ])),
        ],
      ]));
  }

  // ── Full year card ────────────────────────────────────────────────────────────
  static pw.Widget _fullYearCard(YearSection s, Set<int> natal, DateTime dob) {
    final hasHigh = s.warnings.any((w) => w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK'));
    final bColor = s.isCurrent ? _goldBd : hasHigh ? _danger : _subtle;
    final bWidth = s.isCurrent || hasHigh ? 1.0 : 0.4;

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _card,
        border: pw.Border.all(color: bColor, width: bWidth),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Year header
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: pw.BoxDecoration(
            color: s.isCurrent ? _goldBg : hasHigh ? _dangerBg : _card2,
            borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7), topRight: pw.Radius.circular(7)),
            border: pw.Border(bottom: pw.BorderSide(color: _subtle, width: 0.4))),
          child: pw.Row(children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(color: _gold,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Text(_s(s.label), style: pw.TextStyle(fontSize: 10,
                  color: _white, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(width: 8),
            if (s.isCurrent) _badge('CURRENT', _good),
            if (hasHigh) ...[pw.SizedBox(width: 5), _badge('HIGH RISK', _danger)],
            pw.Spacer(),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('Maha ${s.mahaNum} ${_p(s.mahaNum)}',
                  style: pw.TextStyle(fontSize: 8, color: _gold, fontWeight: pw.FontWeight.bold)),
              pw.Text('Antar ${s.antarNum} ${_p(s.antarNum)}  |  Monthly ${s.monthlyNum} ${_p(s.monthlyNum)}',
                  style: pw.TextStyle(fontSize: 7, color: _muted)),
            ]),
          ])),

        pw.Padding(padding: const pw.EdgeInsets.all(14), child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, children: [

          // Chart + Period analysis side by side
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            // Chart
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('ANNUAL CHART', style: pw.TextStyle(fontSize: 7, color: _muted,
                  fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
              pw.SizedBox(height: 4),
              _buildGrid(s.mahaNum, s.antarNum, s.monthlyNum, natal: natal, size: 38.0),
              pw.SizedBox(height: 5),
              // Legend
              pw.Wrap(spacing: 6, runSpacing: 3, children: [
                _legendDot(_gold, 'Maha ${s.mahaNum}'),
                _legendDot(_info, 'Antar ${s.antarNum}'),
                _legendDot(_good, 'Mo ${s.monthlyNum}'),
              ]),
            ]),
            pw.SizedBox(width: 14),
            // Period analysis
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('PERIOD ANALYSIS', style: pw.TextStyle(fontSize: 7, color: _muted,
                  fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
              pw.SizedBox(height: 5),
              if (s.insights.isNotEmpty) ...[
                ...s.insights.map((t) => _lineItem(_s(t), _info, _infoBg)),
                pw.SizedBox(height: 4),
              ],
              if (s.yogas.isNotEmpty) ...[
                pw.Wrap(spacing: 5, runSpacing: 4,
                    children: s.yogas.map((y) => _smallTag(_s(y), _good, _goodBg)).toList()),
                pw.SizedBox(height: 4),
              ],
              if (s.warnings.isNotEmpty) ...[
                ...s.warnings.map((w) {
                  final h = w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK');
                  return _lineItem(_s(w), h ? _danger : _warn, h ? _dangerBg : _warnBg);
                }),
              ],
              if (s.insights.isEmpty && s.warnings.isEmpty && s.yogas.isEmpty)
                pw.Text('Standard period. No exceptional combinations active.',
                    style: pw.TextStyle(fontSize: 8, color: _muted)),
            ])),
          ]),
          pw.SizedBox(height: 12),

          // Antardasha detailed text
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: _infoBg,
              border: pw.Border.all(color: _info, width: 0.3),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('ANTARDASHA ${s.antarNum} (${_p(s.antarNum).toUpperCase()}) -- DETAILED',
                  style: pw.TextStyle(fontSize: 7, color: _info,
                      fontWeight: pw.FontWeight.bold, letterSpacing: 0.6)),
              pw.SizedBox(height: 4),
              pw.Text(_s(_dashaBehavior[s.antarNum] ?? ''),
                  style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
              pw.SizedBox(height: 3),
              pw.Text('Positive: ${_s(_dashaPositive[s.antarNum] ?? "")}',
                  style: pw.TextStyle(fontSize: 8, color: _good, lineSpacing: 1.4)),
            ])),
          pw.SizedBox(height: 10),

          // Month-by-month breakdown
          pw.Text('MONTH-BY-MONTH BREAKDOWN', style: pw.TextStyle(fontSize: 7, color: _muted,
              fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
          pw.SizedBox(height: 6),
          _monthTable(s, natal, dob),
          pw.SizedBox(height: 10),

          // Remedies - only if there's a risk event
          if (hasHigh || s.warnings.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: _goldBg,
                border: pw.Border.all(color: _goldBd, width: 0.4),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('REMEDIES', style: pw.TextStyle(fontSize: 7, color: _gold,
                    fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
                pw.SizedBox(height: 5),
                pw.Text(_s(s.remedies), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
              ])),
          ],

          // Astrologer notes placeholder
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(
              color: const PdfColor(0.96, 0.96, 0.96),
              border: pw.Border.all(color: _subtle, width: 0.4),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Row(children: [
              pw.Text('Astrologer Notes: ', style: pw.TextStyle(fontSize: 7, color: _muted,
                  fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(s.remedies.isEmpty ? '(No notes added)' : '',
                  style: pw.TextStyle(fontSize: 7, color: _muted))),
            ])),
        ])),
      ]));
  }

  // ── Month table ───────────────────────────────────────────────────────────────
  static pw.Widget _monthTable(YearSection s, Set<int> natal, DateTime dob) {
    final basic = NumerologyEngine.basicNumber(dob.day);
    final rows = <pw.TableRow>[];

    // Header row
    rows.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: _card2),
      children: ['MONTH','MONTHLY\nDASHA','DAILY\nNUM','CHART\nACTIVE','NOTES'].map((h) =>
        pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(h, style: pw.TextStyle(fontSize: 6.5, color: _muted,
              fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)))).toList(),
    ));

    // One row per month
    for (int m = 1; m <= 12; m++) {
      final targetDate = DateTime(s.year, m, 15);
      final monthly = NumerologyEngine.currentMonthlyDasha(dob, targetDate: targetDate);
      
      // Daily number for mid-month
      final wd = targetDate.weekday % 7;
      final wdVal = NumerologyEngine.weekdayValues[wd]!;
      final rawDaily = basic + targetDate.month + (targetDate.year % 100) + wdVal + targetDate.day;
      final dailyNum = NumerologyEngine.reduceToSingle(rawDaily);

      final allNums = {...natal, s.mahaNum, s.antarNum, monthly.number};
      final isRisk = (monthly.number == 4 && s.antarNum == 9) ||
                     (monthly.number == 9 && s.antarNum == 4) ||
                     (monthly.number == 4 && s.mahaNum == 9) ||
                     (monthly.number == 9 && s.mahaNum == 4);
      final key1 = '${monthly.number}_${s.antarNum}';
      final key2 = '${s.antarNum}_${monthly.number}';
      final cautionNote = _monthCaution[key1] ?? _monthCaution[key2] ?? '';

      // Active yogas this month
      final notes = <String>[];
      if (cautionNote.isNotEmpty) notes.add(cautionNote);
      if (allNums.contains(1) && allNums.contains(2) && !natal.contains(3) && !natal.contains(6))
        notes.add('Raj Yoga active');
      if (allNums.contains(5) && allNums.contains(7)) notes.add('Easy Money active');
      if (allNums.contains(3) && allNums.contains(1) && allNums.contains(9))
        notes.add('3-1-9 Uplift');
      if (allNums.contains(2) && (monthly.number == 2 || s.antarNum == 2))
        notes.add('Mental health watch');
      if (notes.isEmpty) notes.add('--');

      final rowBg = isRisk ? _dangerBg : (m % 2 == 0 ? _card2 : _card);
      final textColor = isRisk ? _danger : _body;

      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: rowBg),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(_fullMonths[m-1], style: pw.TextStyle(fontSize: 7.5,
                color: textColor, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text('${monthly.number}\n${_p(monthly.number)}',
                style: pw.TextStyle(fontSize: 7.5, color: isRisk ? _danger : _gold,
                    fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text('$dailyNum\n${_p(dailyNum)}',
                style: pw.TextStyle(fontSize: 7, color: _muted))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(allNums.toList().join(', '),
                style: pw.TextStyle(fontSize: 7, color: _muted))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(notes.join('. '),
                style: pw.TextStyle(fontSize: 7, color: isRisk ? _danger : _body,
                    lineSpacing: 1.4))),
        ]));
    }

    return pw.Table(
      columnWidths: {
        0: const pw.FractionColumnWidth(0.12),
        1: const pw.FractionColumnWidth(0.10),
        2: const pw.FractionColumnWidth(0.09),
        3: const pw.FractionColumnWidth(0.13),
        4: const pw.FractionColumnWidth(0.56),
      },
      border: pw.TableBorder.all(color: _subtle, width: 0.3),
      children: rows,
    );
  }

  // ── Grid builder ─────────────────────────────────────────────────────────────
  static pw.Widget _buildGrid(int? maha, int? antar, int? monthly,
      {required Set<int> natal, required double size}) {
    return pw.Container(
      width: size * 3 + 2,
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

          PdfColor tc = _muted;
          PdfColor bg = _card;
          if (isMaha) { tc = _gold; bg = _goldBg; }
          else if (isAntar) { tc = _info; bg = _infoBg; }
          else if (isMonthly) { tc = _good; bg = _goodBg; }
          else if (inNatal) tc = _body;

          return pw.Container(
            width: size, height: size,
            color: bg,
            child: pw.Stack(children: [
              if (col < 2) pw.Positioned(right: 0, top: 0, bottom: 0,
                  child: pw.Container(width: 0.3, color: _subtle)),
              if (row < 2) pw.Positioned(left: 0, right: 0, bottom: 0,
                  child: pw.Container(height: 0.3, color: _subtle)),
              pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text('$num', style: pw.TextStyle(fontSize: size * 0.3, color: tc,
                    fontWeight: (isMaha || isAntar || isMonthly || inNatal)
                        ? pw.FontWeight.bold : pw.FontWeight.normal)),
                pw.Text(_gridAbbr[row][col], style: pw.TextStyle(fontSize: size * 0.14, color: _muted)),
              ])),
            ]));
        })))));
  }

  // ── Small helpers ─────────────────────────────────────────────────────────────
  static pw.Widget _badge(String t, PdfColor c) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: pw.BoxDecoration(color: c,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 6.5, color: _white,
        fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)));

  static pw.Widget _smallTag(String t, PdfColor c, PdfColor bg) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: pw.BoxDecoration(color: bg,
        border: pw.Border.all(color: c, width: 0.3),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7, color: c)));

  static pw.Widget _lineItem(String t, PdfColor c, PdfColor bg) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 4),
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: pw.BoxDecoration(color: bg,
        border: pw.Border(left: pw.BorderSide(color: c, width: 2))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.4)));

  static pw.Widget _infoBox(String title, String body, PdfColor tc, PdfColor bg, PdfColor bd) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: bg,
          border: pw.Border.all(color: bd, width: 0.4),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(_s(title), style: pw.TextStyle(fontSize: 8.5, color: tc, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(_s(body), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
      ]));

  static pw.Widget _numChip(int n, PdfColor tc, PdfColor bg, PdfColor bd) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: pw.BoxDecoration(color: bg,
        border: pw.Border.all(color: bd, width: 0.3),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
    child: pw.Text('$n ${_p(n)}', style: pw.TextStyle(fontSize: 7.5, color: tc,
        fontWeight: pw.FontWeight.bold)));

  static pw.Widget _legendDot(PdfColor c, String label) => pw.Row(children: [
    pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(
        color: c, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)))),
    pw.SizedBox(width: 3),
    pw.Text(label, style: pw.TextStyle(fontSize: 6.5, color: c)),
  ]);
}
