import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../../core/numerology/numerology_engine.dart';
import 'astro_report_screen.dart';

// ── THEME ─────────────────────────────────────────────────────────────────────
const _gold    = PdfColor(0.62, 0.45, 0.08);
const _goldBg  = PdfColor(0.99, 0.96, 0.88);
const _goldBd  = PdfColor(0.72, 0.55, 0.15);
const _dark    = PdfColor(0.10, 0.10, 0.10);
const _body    = PdfColor(0.22, 0.22, 0.22);
const _muted   = PdfColor(0.50, 0.50, 0.50);
const _subtle  = PdfColor(0.82, 0.82, 0.82);
const _danger  = PdfColor(0.72, 0.10, 0.10);
const _dangerBg= PdfColor(0.99, 0.93, 0.93);
const _warn    = PdfColor(0.65, 0.35, 0.02);
const _warnBg  = PdfColor(0.99, 0.96, 0.88);
const _good    = PdfColor(0.10, 0.48, 0.20);
const _goodBg  = PdfColor(0.92, 0.98, 0.93);
const _info    = PdfColor(0.12, 0.28, 0.60);
const _infoBg  = PdfColor(0.92, 0.95, 0.99);
const _card2   = PdfColor(0.97, 0.97, 0.97);

// ── Helpers ───────────────────────────────────────────────────────────────────
String _p(int n) => {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',
    6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'}[n] ?? '';

String _s(String? t) {
  if (t == null) return '';
  return t
    .replaceAll('\u2014','--').replaceAll('\u2013','-')
    .replaceAll('\u2019',"'").replaceAll('\u2018',"'")
    .replaceAll('\u2022','-').replaceAll('\u2026','...')
    .replaceAll('\u00e9','e').replaceAll('&', 'and');
}

const _gridPos = {3:[0,0],1:[0,1],9:[0,2],6:[1,0],7:[1,1],5:[1,2],2:[2,0],8:[2,1],4:[2,2]};
const _gridAbbr = [['Ju','Su','Ma'],['Ve','Ke','Me'],['Mo','Sa','Ra']];

const _dashaBehavior = {
  1: 'Anger increases, authority and leadership qualities emerge, ego amplifies. Strong need for respect. Confidence surge -- commanding presence.',
  2: 'Emotional sensitivity increases sharply, creativity surges, self-expression rises. Strong need for emotional security and connection.',
  3: 'Heightened morality, addiction control improves, family attachment deepens. Spirituality grows. Natural counseling skills come forward.',
  4: 'Illusion and imaginative thinking dominate. Restlessness, moodiness. Tries new things impulsively without completing old ones.',
  5: 'Sharp mind, money-minded, excellent communication. Playful and childlike energy. Calculative, workaholic tendencies, fast decision-making.',
  6: 'Luxury-seeking, relationship-focused, appearance-conscious. Food interest increases. Romantic nature, desire for comfort and beauty.',
  7: 'Analytical thinking increases dramatically. LUCK and desire realization peak. Reduced struggles, spirituality upsurge, travel ease.',
  8: 'Hard work required without immediate reward. Disappointments and delays. Financial pressure. Charitable and compassionate inclination.',
  9: 'Confidence boost, boldness, courage and assertive energy. Competitive attitude, commitment strengthens. Energy surge. Action-oriented.',
};

const _dashaPositive = {
  1: 'Financial growth, status elevation, name and fame, awards and honors, competition victories, career advancement, leadership roles.',
  2: 'Social circle expansion, contact with influential people, networking success, visible and influential presence. Collaborative opportunities.',
  3: 'Learning and education, family bonding, seeking a guru, spiritual discourse, seeking life purpose. Higher education pursuits bloom.',
  4: 'When 4 creates 44 -- clarity of thought, logical behavior, meaningful travels, enhanced decision-making, increased earnings.',
  5: 'Increased cash flow, new investment opportunities, career advancement, business ventures, financial security. Strong earnings period.',
  6: 'Luxurious lifestyle, relationship strengthening, romantic and marital developments, career in arts, hospitality, beauty.',
  7: 'Luck and success, ease overcoming challenges, stability, spiritual growth, travel opportunities. Things work out effortlessly.',
  8: 'When 8 creates 88 -- Professional advancement, financial growth, improved health, life purpose fulfillment, karmic rewards.',
  9: 'Personal growth, career advancements, increased activity, leadership opportunities. Positive, expansive period full of achievements.',
};

const _dashaNegative = {
  1: 'Confidence can decrease when alone without 3 or 9. Ego vulnerability. Guard against self-doubt and arrogance in equal measure.',
  2: 'Multiple 2s -- sadness, anxiety, emotional instability. Insomnia risk. Depression tendency. Mental health vigilance needed.',
  3: 'When 3 creates 33 -- moral flexibility, spiritual showmanship. Family bonds can loosen. Addiction temptations may increase.',
  4: 'Financial expenses and losses, job loss risk, debt accumulation, scam vulnerability, accidents, mental confusion. HIGH CAUTION.',
  5: 'When 5 creates 555 -- overconfidence, complete money focus, fraud risk. Deceptive behavior possible. Guard financial decisions carefully.',
  6: 'When 6 creates 66 -- conflicts increase, harsh speech, luxuries at others expense, ego-driven, materialism dominates.',
  7: 'When 7 creates 77 -- instability in career and life, relationship challenges. Anxiety and insomnia increase. Substance use risk.',
  8: 'Hard work with delayed results. Financial hardship, career challenges, health management needed. Patience is the only remedy.',
  9: 'When 9 creates 99 -- legal issues, financial challenges, relationship strain, health concerns, conflict-prone period.',
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
    // Load fonts
    pw.Font regularFont;
    pw.Font boldFont;
    try {
      regularFont = await PdfGoogleFonts.openSansRegular();
      boldFont = await PdfGoogleFonts.openSansBold();
    } catch (_) {
      regularFont = pw.Font.courier();
      boldFont = pw.Font.courierBold();
    }

    // Load logo
    pw.ImageProvider? logo;
    try {
      final bytes = await rootBundle.load('assets/images/app_icon.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    final dobStr = '${dob.day}/${dob.month}/${dob.year}';
    final basic   = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    final natal   = NumerologyEngine.chartDigits(dob).toSet();
    final today   = DateTime.now();
    final dateStr = '${today.day}/${today.month}/${today.year}';
    final astroLabel = astrologerName.isNotEmpty ? astrologerName : 'Astrologer';
    final astroPhone = astrologerPhone.isNotEmpty ? astrologerPhone : '';

    // ── COVER PAGE ────────────────────────────────────────────────────────────
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(children: [
        pw.Container(color: PdfColors.white),
        // Watermark
        if (logo != null) pw.Positioned(top: 160, left: 60,
          child: pw.Opacity(opacity: 0.04, child: pw.Image(logo, width: 460, height: 460))),
        pw.Positioned(top: 0, left: 0, right: 0, child: pw.Container(height: 4, color: _gold)),
        pw.Positioned(bottom: 0, left: 0, right: 0, child: pw.Container(height: 4, color: _gold)),
        pw.Padding(padding: const pw.EdgeInsets.fromLTRB(56, 60, 56, 48),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('NUMEROLOGY LIFE REPORT', style: pw.TextStyle(
                fontSize: 9, color: _gold, letterSpacing: 3, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text(_s(clientName), style: pw.TextStyle(
                fontSize: 40, color: _dark, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 14),
            pw.Container(width: 80, height: 1.5, color: _gold),
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
              decoration: pw.BoxDecoration(color: _goldBg,
                border: pw.Border.all(color: _goldBd, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
              child: pw.Row(children: [
                if (logo != null) pw.Opacity(opacity: 0.85, child: pw.Image(logo, width: 30, height: 30)),
                if (logo != null) pw.SizedBox(width: 12),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('AASTROSPHERE', style: pw.TextStyle(
                      fontSize: 12, color: _gold, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 3),
                  pw.Text('Prepared by $astroLabel${astroPhone.isNotEmpty ? "  |  $astroPhone" : ""}',
                      style: pw.TextStyle(fontSize: 8, color: _muted)),
                  pw.Text('Generated on $dateStr',
                      style: pw.TextStyle(fontSize: 8, color: _muted)),
                ]),
              ])),
          ])),
      ]),
    ));

    // ── NATAL OVERVIEW (MultiPage so it fills properly) ───────────────────────
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
      header: (ctx) => _hdr(clientName, dateStr, logo),
      footer: (ctx) => _ftr(astroLabel, astroPhone, ctx),
      build: (ctx) => [
        _secTitle('NATAL OVERVIEW'),
        pw.SizedBox(height: 12),
        _natalOverview(basic, destiny, natal, dob),
        pw.SizedBox(height: 20),
        _secTitle('NATAL CHART'),
        pw.SizedBox(height: 12),
        _natalChart(basic, destiny, natal),
      ],
    ));

    // ── YEAR SECTIONS — one MultiPage per year ────────────────────────────────
    int? prevMaha;
    for (final s in sections) {
      // Maha banner on new maha
      if (prevMaha != s.mahaNum) {
        doc.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
          header: (ctx) => _hdr(clientName, dateStr, logo),
          footer: (ctx) => _ftr(astroLabel, astroPhone, ctx),
          build: (ctx) => _mahaBannerPage(s.mahaNum, s.mahaPlanet, natal),
        ));
        prevMaha = s.mahaNum;
      }

      // Year detail page
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
        header: (ctx) => _hdr(clientName, dateStr, logo),
        footer: (ctx) => _ftr(astroLabel, astroPhone, ctx),
        build: (ctx) => _yearPage(s, natal, dob),
      ));
    }

    final dir = await getTemporaryDirectory();
    final safe = clientName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final path = '${dir.path}/Aastrosphere_${safe}_Report.pdf';
    await File(path).writeAsBytes(await doc.save());
    return path;
  }

  // ── Header / Footer ──────────────────────────────────────────────────────────
  static pw.Widget _hdr(String client, String date, pw.ImageProvider? logo) =>
    pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _subtle, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Row(children: [
          if (logo != null) pw.Opacity(opacity: 0.6, child: pw.Image(logo, width: 13, height: 13)),
          if (logo != null) pw.SizedBox(width: 6),
          pw.Text('AASTROSPHERE', style: pw.TextStyle(fontSize: 7, color: _gold, letterSpacing: 1.5, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Text('${_s(client)}  |  $date', style: pw.TextStyle(fontSize: 7, color: _muted)),
      ]));

  static pw.Widget _ftr(String name, String phone, pw.Context ctx) =>
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _subtle, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('$name${phone.isNotEmpty ? "  |  $phone" : ""}', style: pw.TextStyle(fontSize: 7, color: _muted)),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: pw.TextStyle(fontSize: 7, color: _muted)),
        pw.Text('(c) Aastrosphere  |  Confidential', style: pw.TextStyle(fontSize: 7, color: _muted)),
      ]));

  static pw.Widget _secTitle(String t) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(t, style: pw.TextStyle(fontSize: 9, color: _gold, letterSpacing: 2, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: _gold),
    ]);

  static pw.Widget _coverRow(String l, String v) => pw.Row(children: [
    pw.Text('$l  ', style: pw.TextStyle(fontSize: 11, color: _muted)),
    pw.Text(_s(v), style: pw.TextStyle(fontSize: 11, color: _dark, fontWeight: pw.FontWeight.bold)),
  ]);

  // ── Natal overview ────────────────────────────────────────────────────────────
  static pw.Widget _natalOverview(int basic, int destiny, Set<int> natal, DateTime dob) {
    final items = <pw.Widget>[];
    items.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: _box('Basic Number $basic -- ${_p(basic)}',
          'Core personality, daily behavior, and driving energy. How this person naturally shows up in every situation. The number that describes their instinctive reactions and automatic behavior patterns.', _gold, _goldBg, _goldBd)),
      pw.SizedBox(width: 10),
      pw.Expanded(child: _box('Destiny Number $destiny -- ${_p(destiny)}',
          'Life direction, soul purpose, and karmic path. Where life consistently pushes this person, whether they resist or not. The themes that repeat until integrated.', _gold, _goldBg, _goldBd)),
    ]));
    items.add(pw.SizedBox(height: 12));

    // Natal yogas with detailed descriptions
    if (natal.contains(4) && natal.contains(9)) {
      items.add(_box('4-9 Natal Combination -- Physical Caution Required',
          'Rahu (4) and Mars (9) both present at birth. This creates a lifelong tendency toward impulsive physical actions and elevated accident risk. This does NOT mean accidents are inevitable -- it means the tendency is present and requires CONSCIOUS, daily management. Never rush physical actions. Double-check before moving. Especially important during Rahu or Mars dashas when the energy amplifies.',
          _danger, _dangerBg, _danger));
      items.add(pw.SizedBox(height: 8));
    }
    if (natal.contains(5) && natal.contains(7)) {
      items.add(_box('5-7 Natal Combination -- Easy Money Yoga',
          'Mercury (5) and Ketu (7) both present at birth. Financial gains tend to arrive with less effort than average throughout life. Business and financial acumen are natural gifts. Money flows more easily when focus and intent are aligned. This yoga strengthens during periods when 5 or 7 is active in the Maha or Antardasha.',
          _good, _goodBg, _good));
      items.add(pw.SizedBox(height: 8));
    }
    if (natal.contains(1) && natal.contains(2) && !natal.contains(3) && !natal.contains(6)) {
      items.add(_box('Raj Yoga in Natal Chart',
          'Sun (1) present with Moon (2), left path of 1 is clear (no 3 above, no 6 below). Authority positions are natural territory. Career advancement and public recognition are strongly supported throughout life. When Mahadasha or Antardasha activates 1 or 2, career peaks are highly probable.',
          _gold, _goldBg, _goldBd));
      items.add(pw.SizedBox(height: 8));
    }
    if (natal.contains(8) && natal.contains(9)) {
      items.add(_box('8-9 Natal Combination -- Heavy Load, Strong Capacity',
          'Saturn and Mars both present. Relentless determination and enormous output capacity. The work never stops but the person handles it. Heart and blood pressure need monitoring throughout life. Physical health vigilance is essential, especially during Saturn or Mars mahadashas.',
          _warn, _warnBg, _warn));
      items.add(pw.SizedBox(height: 8));
    }
    if (natal.contains(3) && natal.contains(1) && natal.contains(9)) {
      items.add(_box('3-1-9 Uplift Combination in Natal',
          'Jupiter, Sun, and Mars all present at birth. Naturally uplifting and positive energy throughout life. Confidence, leadership, and courage are all strong simultaneously. Achievements come more easily during periods when any of these numbers are activated in the annual chart.',
          _good, _goodBg, _good));
    }
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: items);
  }

  // ── Natal chart ───────────────────────────────────────────────────────────────
  static pw.Widget _natalChart(int basic, int destiny, Set<int> natal) =>
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _grid(null, null, null, natal: natal, size: 46.0),
      pw.SizedBox(width: 18),
      pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('PRESENT NUMBERS', style: pw.TextStyle(fontSize: 8, color: _muted, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 6, runSpacing: 5, children: natal.map((n) => _chip('$n ${_p(n)}', _gold, _goldBg, _goldBd)).toList()),
        pw.SizedBox(height: 10),
        pw.Text('MISSING NUMBERS', style: pw.TextStyle(fontSize: 8, color: _muted, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 6, runSpacing: 5, children: [1,2,3,4,5,6,7,8,9]
            .where((n) => !natal.contains(n))
            .map((n) => _chip('$n ${_p(n)}', _warn, _warnBg, _warn)).toList()),
        pw.SizedBox(height: 12),
        pw.Text('BASIC $basic (${_p(basic)}): ${_s(_dashaBehavior[basic])}',
            style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
        pw.SizedBox(height: 6),
        pw.Text('DESTINY $destiny (${_p(destiny)}): ${_s(_dashaPositive[destiny])}',
            style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
      ])),
    ]);

  // ── Mahadasha banner page content ────────────────────────────────────────────
  static List<pw.Widget> _mahaBannerPage(int num, String planet, Set<int> natal) => [
    pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _goldBg,
        border: pw.Border.all(color: _goldBd, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: pw.BoxDecoration(color: _gold, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Text('MAHADASHA $num  --  ${planet.toUpperCase()}',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8))),
        pw.SizedBox(height: 14),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _subBox('ENERGY IN THIS PERIOD', _s(_dashaBehavior[num]), _info)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _subBox('WHAT THIS PERIOD BRINGS', _s(_dashaPositive[num]), _good)),
        ]),
        pw.SizedBox(height: 10),
        _warnBox('WATCH OUT: ${_s(_dashaNegative[num])}'),
      ])),
    pw.SizedBox(height: 16),
    // Mahadasha dates context
    pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: _card2, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Text(
        'The Mahadasha of ${_p(num)} ($num) is a multi-year master arc that sets the background energy for every sub-period within it. '
        'The Antardasha (sub-period) changes annually within this arc, adding specific themes on top of the Mahadasha energy. '
        'Think of Mahadasha as the season and Antardasha as the specific weather within that season.',
        style: pw.TextStyle(fontSize: 9, color: _body, lineSpacing: 1.7))),
  ];

  // ── Year page content ─────────────────────────────────────────────────────────
  static List<pw.Widget> _yearPage(YearSection s, Set<int> natal, DateTime dob) {
    final rich = s.richData;
    final widgets = <pw.Widget>[];
    final hasHigh = s.warnings.any((w) => w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK'));

    // Year header
    widgets.add(pw.Row(children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: pw.BoxDecoration(color: _gold, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
        child: pw.Text(_s(s.label), style: pw.TextStyle(fontSize: 12, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
      pw.SizedBox(width: 8),
      if (s.isCurrent) _badge('CURRENT', _good),
      if (hasHigh) ...[pw.SizedBox(width: 6), _badge('HIGH RISK', _danger)],
      pw.Spacer(),
      pw.Text('Maha ${s.mahaNum} ${_p(s.mahaNum)}  |  Antar ${s.antarNum} ${_p(s.antarNum)}',
          style: pw.TextStyle(fontSize: 8, color: _muted)),
    ]));
    widgets.add(pw.SizedBox(height: 12));

    // Chart + Antardasha side by side
    widgets.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Column(children: [
        _grid(s.mahaNum, s.antarNum, s.monthlyNum, natal: natal, size: 40.0),
        pw.SizedBox(height: 5),
        pw.Wrap(spacing: 5, runSpacing: 3, children: [
          _dot(_gold, 'M${s.mahaNum}'),
          _dot(_info, 'A${s.antarNum}'),
          _dot(_good, 'Mo${s.monthlyNum}'),
        ]),
      ]),
      pw.SizedBox(width: 14),
      pw.Expanded(child: pw.Container(
        padding: const pw.EdgeInsets.all(11),
        decoration: pw.BoxDecoration(color: _infoBg,
            border: pw.Border.all(color: _info, width: 0.3),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('ANTARDASHA ${s.antarNum} -- ${_p(s.antarNum).toUpperCase()}',
              style: pw.TextStyle(fontSize: 8, color: _info, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(_s(_dashaBehavior[s.antarNum]), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
          pw.SizedBox(height: 5),
          pw.Text('BRINGS: ${_s(_dashaPositive[s.antarNum])}',
              style: pw.TextStyle(fontSize: 8, color: _good, lineSpacing: 1.4)),
        ]))),
    ]));
    widgets.add(pw.SizedBox(height: 12));

    // ── RICH BACKEND DATA ──────────────────────────────────────────────────────
    if (rich != null) {
      // Year in one line
      final oneLineTxt = rich['year_in_one_line'] as String?;
      if (oneLineTxt != null && oneLineTxt.isNotEmpty) {
        widgets.add(pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: _goldBg,
            border: pw.Border(left: pw.BorderSide(color: _gold, width: 3))),
          child: pw.Text(_s(oneLineTxt),
              style: pw.TextStyle(fontSize: 9, color: _dark, fontWeight: pw.FontWeight.bold, lineSpacing: 1.4))));
        widgets.add(pw.SizedBox(height: 10));
      }

      // Overview
      final overview = rich['overview'] as String?;
      if (overview != null && overview.isNotEmpty) {
        widgets.add(_secTitle('YEAR OVERVIEW'));
        widgets.add(pw.SizedBox(height: 6));
        widgets.add(pw.Text(_s(overview), style: pw.TextStyle(fontSize: 9, color: _body, lineSpacing: 1.7)));
        widgets.add(pw.SizedBox(height: 12));
      }

      // 4 sections: Finance, Career, Relationships, Health
      final sections4 = <Map<String, String>>[];
      final fin = rich['finance'] as Map?;
      if (fin != null) {
        final sig = fin['year_signal'] as String? ?? '';
        final pat = fin['your_pattern'] as String? ?? '';
        if (sig.isNotEmpty || pat.isNotEmpty)
          sections4.add({'title': 'FINANCE', 'body': '${_s(sig)}${pat.isNotEmpty ? " Their pattern: ${_s(pat)}" : ""}'});
      }
      final car = rich['career'] as Map?;
      if (car != null) {
        final sig = car['year_signal'] as String? ?? '';
        final pat = car['your_pattern'] as String? ?? '';
        if (sig.isNotEmpty || pat.isNotEmpty)
          sections4.add({'title': 'CAREER', 'body': '${_s(sig)}${pat.isNotEmpty ? " Their pattern: ${_s(pat)}" : ""}'});
      }
      final rel = rich['relationships'] as Map?;
      if (rel != null) {
        final sig = rel['year_signal'] as String? ?? '';
        final pat = rel['your_pattern'] as String? ?? '';
        if (sig.isNotEmpty || pat.isNotEmpty)
          sections4.add({'title': 'RELATIONSHIPS', 'body': '${_s(sig)}${pat.isNotEmpty ? " Their pattern: ${_s(pat)}" : ""}'});
      }
      final hlt = rich['health'] as Map?;
      if (hlt != null) {
        final wch = hlt['watch'] as String? ?? '';
        final pat = hlt['your_pattern'] as String? ?? '';
        if (wch.isNotEmpty || pat.isNotEmpty)
          sections4.add({'title': 'HEALTH', 'body': '${_s(wch)}${pat.isNotEmpty ? " Pattern: ${_s(pat)}" : ""}'});
      }

      if (sections4.isNotEmpty) {
        widgets.add(_secTitle('LIFE AREAS THIS YEAR'));
        widgets.add(pw.SizedBox(height: 8));
        // 2 column grid
        for (int i = 0; i < sections4.length; i += 2) {
          final left = sections4[i];
          final right = i+1 < sections4.length ? sections4[i+1] : null;
          widgets.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(child: _subBox(left['title']!, left['body']!, _gold)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: right != null ? _subBox(right['title']!, right['body']!, _gold) : pw.SizedBox()),
          ]));
          widgets.add(pw.SizedBox(height: 8));
        }
        widgets.add(pw.SizedBox(height: 6));
      }

      // Opportunities
      final opps = (rich['opportunities'] as List?)?.cast<String>() ?? [];
      if (opps.isNotEmpty) {
        widgets.add(_secTitle('OPPORTUNITIES THIS YEAR'));
        widgets.add(pw.SizedBox(height: 6));
        for (final o in opps) {
          widgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _goodBg,
              border: pw.Border(left: pw.BorderSide(color: _good, width: 2))),
            child: pw.Text(_s(o), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.4))));
        }
        widgets.add(pw.SizedBox(height: 10));
      }

      // Watch out
      final watchOut = (rich['watch_out'] as List?)?.cast<String>() ?? [];
      final allWarnings = [...s.warnings, ...watchOut];
      if (allWarnings.isNotEmpty) {
        widgets.add(_secTitle('WATCH OUT FOR'));
        widgets.add(pw.SizedBox(height: 6));
        for (final w in allWarnings) {
          final isH = w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK');
          widgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: isH ? _dangerBg : _warnBg,
              border: pw.Border(left: pw.BorderSide(color: isH ? _danger : _warn, width: 2))),
            child: pw.Text(_s(w), style: pw.TextStyle(fontSize: 8, color: isH ? _danger : _body, lineSpacing: 1.4))));
        }
        widgets.add(pw.SizedBox(height: 10));
      }

      // Best / risky months
      final bestM = rich['best_months'] as String?;
      final riskyM = rich['risky_months'] as String?;
      if (bestM != null || riskyM != null) {
        widgets.add(_secTitle('MONTH GUIDANCE'));
        widgets.add(pw.SizedBox(height: 6));
        if (bestM != null && bestM.isNotEmpty)
          widgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(color: _goodBg, border: pw.Border.all(color: _good, width: 0.4), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Row(children: [
              pw.Text('BEST: ', style: pw.TextStyle(fontSize: 7, color: _good, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(_s(bestM), style: pw.TextStyle(fontSize: 8, color: _body))),
            ])));
        if (riskyM != null && riskyM.isNotEmpty)
          widgets.add(pw.Container(
            padding: const pw.EdgeInsets.all(9),
            decoration: pw.BoxDecoration(color: _warnBg, border: pw.Border.all(color: _warn, width: 0.4), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Row(children: [
              pw.Text('CAUTION: ', style: pw.TextStyle(fontSize: 7, color: _warn, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(_s(riskyM), style: pw.TextStyle(fontSize: 8, color: _body))),
            ])));
        widgets.add(pw.SizedBox(height: 10));
      }

      // Yogas
      if (s.yogas.isNotEmpty) {
        widgets.add(_secTitle('ACTIVE YOGAS'));
        widgets.add(pw.SizedBox(height: 6));
        widgets.add(pw.Wrap(spacing: 6, runSpacing: 5,
            children: s.yogas.map((y) => _chip(_s(y), _good, _goodBg, _good)).toList()));
        widgets.add(pw.SizedBox(height: 10));
      }
    } else {
      // No backend data — use local insights
      if (s.insights.isNotEmpty) {
        widgets.add(_secTitle('PERIOD ANALYSIS'));
        widgets.add(pw.SizedBox(height: 6));
        for (final ins in s.insights)
          widgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(color: _infoBg, border: pw.Border(left: pw.BorderSide(color: _info, width: 2))),
            child: pw.Text(_s(ins), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.4))));
        widgets.add(pw.SizedBox(height: 10));
      }
      if (s.warnings.isNotEmpty) {
        for (final w in s.warnings) {
          final isH = w.contains('HIGH ACCIDENT');
          widgets.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: isH ? _dangerBg : _warnBg,
              border: pw.Border(left: pw.BorderSide(color: isH ? _danger : _warn, width: 2))),
            child: pw.Text(_s(w), style: pw.TextStyle(fontSize: 8, color: isH ? _danger : _body, lineSpacing: 1.4))));
        }
        widgets.add(pw.SizedBox(height: 10));
      }
    }

    // Month table
    widgets.add(_secTitle('MONTH BY MONTH'));
    widgets.add(pw.SizedBox(height: 6));
    widgets.add(_monthTable(s, natal, dob));

    // Remedies (only if warnings)
    if (s.warnings.isNotEmpty && s.remedies.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 12));
      widgets.add(pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(color: _goldBg, border: pw.Border.all(color: _goldBd, width: 0.4), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('REMEDIES', style: pw.TextStyle(fontSize: 8, color: _gold, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
          pw.SizedBox(height: 5),
          pw.Text(_s(s.remedies), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
        ])));
    }

    return widgets;
  }

  // ── Month table ───────────────────────────────────────────────────────────────
  static pw.Widget _monthTable(YearSection s, Set<int> natal, DateTime dob) {
    final basic = NumerologyEngine.basicNumber(dob.day);
    final rows = <pw.TableRow>[];
    rows.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: _card2),
      children: ['MONTH','MONTHLY DASHA','DAILY NUM','CHART ACTIVE','NOTES'].map((h) =>
        pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(h, style: pw.TextStyle(fontSize: 6.5, color: _muted, fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)))).toList()));

    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    for (int m = 1; m <= 12; m++) {
      final targetDate = DateTime(s.year, m, 15);
      final monthly = NumerologyEngine.currentMonthlyDasha(dob, targetDate: targetDate);
      final wd = targetDate.weekday % 7;
      final wdVal = NumerologyEngine.weekdayValues[wd]!;
      final rawDaily = basic + targetDate.month + (targetDate.year % 100) + wdVal + targetDate.day;
      final dailyNum = NumerologyEngine.reduceToSingle(rawDaily);
      final allNums = {...natal, s.mahaNum, s.antarNum, monthly.number};
      final isRisk = (monthly.number == 4 && s.antarNum == 9) ||
                     (monthly.number == 9 && s.antarNum == 4) ||
                     (monthly.number == 4 && s.mahaNum == 9) ||
                     (monthly.number == 9 && s.mahaNum == 4);

      // Build notes
      final notes = <String>[];
      const cautions = {
        '4_9':'HIGH RISK -- Rahu meets Mars. Drive carefully, avoid rushing.',
        '9_4':'HIGH RISK -- Mars meets Rahu. Slow down, avoid impulsive actions.',
        '4_4':'Double Rahu -- extreme impulsiveness. Avoid major decisions.',
        '9_9':'Double Mars -- anger and legal risk. Guard temper.',
        '2_4':'Emotional confusion risk. Guard trust and finances.',
        '4_2':'Rahu + Moon -- unstable. Not good for commitments.',
        '8_4':'Saturn + Rahu -- delays and confusion. Stay patient.',
        '4_8':'Same as 8_4. Nothing moves. Force patience.',
        '2_8':'Moon + Saturn -- depression risk. Reach out to people.',
        '8_7':'Ketu + Saturn -- bad luck + delays. Avoid new ventures.',
        '7_8':'Same as 8_7. Spiritual practice helps.',
      };
      final key1 = '${monthly.number}_${s.antarNum}';
      final key2 = '${s.antarNum}_${monthly.number}';
      final caut = cautions[key1] ?? cautions[key2];
      if (caut != null) notes.add(caut);
      if (allNums.contains(1) && allNums.contains(2) && !natal.contains(3) && !natal.contains(6)) notes.add('Raj Yoga active');
      if (allNums.contains(5) && allNums.contains(7)) notes.add('Easy Money active');
      if (allNums.contains(3) && allNums.contains(1) && allNums.contains(9)) notes.add('3-1-9 Uplift');
      if (allNums.contains(2) && (monthly.number == 2 || s.antarNum == 2)) notes.add('Mental health watch');
      if (notes.isEmpty) notes.add('--');

      final rowBg = isRisk ? _dangerBg : (m % 2 == 0 ? _card2 : PdfColors.white);
      final tc = isRisk ? _danger : _body;

      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: rowBg),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(months[m-1], style: pw.TextStyle(fontSize: 7.5, color: tc, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text('${monthly.number} ${_p(monthly.number)}',
                style: pw.TextStyle(fontSize: 7.5, color: isRisk ? _danger : _gold, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text('$dailyNum ${_p(dailyNum)}', style: pw.TextStyle(fontSize: 7, color: _muted))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(allNums.toList().join(', '), style: pw.TextStyle(fontSize: 7, color: _muted))),
          pw.Padding(padding: const pw.EdgeInsets.all(5),
            child: pw.Text(notes.join('. '), style: pw.TextStyle(fontSize: 7.5, color: isRisk ? _danger : _body, lineSpacing: 1.4))),
        ]));
    }

    return pw.Table(
      columnWidths: {
        0: const pw.FractionColumnWidth(0.14),
        1: const pw.FractionColumnWidth(0.13),
        2: const pw.FractionColumnWidth(0.11),
        3: const pw.FractionColumnWidth(0.13),
        4: const pw.FractionColumnWidth(0.49),
      },
      border: pw.TableBorder.all(color: _subtle, width: 0.3),
      children: rows);
  }

  // ── Grid builder ──────────────────────────────────────────────────────────────
  static pw.Widget _grid(int? maha, int? antar, int? monthly, {required Set<int> natal, required double size}) =>
    pw.Container(
      width: size * 3 + 2,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: _subtle, width: 0.5), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Column(children: List.generate(3, (row) =>
        pw.Row(children: List.generate(3, (col) {
          final num = _gridPos.entries.firstWhere(
              (e) => e.value[0]==row && e.value[1]==col, orElse: () => const MapEntry(0,[0,0])).key;
          final isMaha    = maha != null && num == maha;
          final isAntar   = antar != null && num == antar;
          final isMonthly = monthly != null && num == monthly;
          final inNatal   = natal.contains(num);
          PdfColor tc = _muted;
          PdfColor bg = PdfColors.white;
          if (isMaha) { tc = _gold; bg = _goldBg; }
          else if (isAntar) { tc = _info; bg = _infoBg; }
          else if (isMonthly) { tc = _good; bg = _goodBg; }
          else if (inNatal) tc = _body;
          return pw.Container(
            width: size, height: size, color: bg,
            child: pw.Stack(children: [
              if (col < 2) pw.Positioned(right: 0, top: 0, bottom: 0, child: pw.Container(width: 0.3, color: _subtle)),
              if (row < 2) pw.Positioned(left: 0, right: 0, bottom: 0, child: pw.Container(height: 0.3, color: _subtle)),
              pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text('$num', style: pw.TextStyle(fontSize: size * 0.28, color: tc,
                    fontWeight: (isMaha || isAntar || isMonthly || inNatal) ? pw.FontWeight.bold : pw.FontWeight.normal)),
                pw.Text(_gridAbbr[row][col], style: pw.TextStyle(fontSize: size * 0.13, color: _muted)),
              ])),
            ]));
        })))));

  // ── Small helpers ──────────────────────────────────────────────────────────────
  static pw.Widget _box(String title, String body, PdfColor tc, PdfColor bg, PdfColor bd) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(color: bg, border: pw.Border.all(color: bd, width: 0.4), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(_s(title), style: pw.TextStyle(fontSize: 9, color: tc, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(_s(body), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.6)),
      ]));

  static pw.Widget _subBox(String title, String body, PdfColor tc) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: _card2, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 7, color: tc, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
        pw.SizedBox(height: 4),
        pw.Text(_s(body), style: pw.TextStyle(fontSize: 8, color: _body, lineSpacing: 1.5)),
      ]));

  static pw.Widget _warnBox(String text) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(color: _warnBg, border: pw.Border.all(color: _warn, width: 0.4), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, color: _warn, lineSpacing: 1.4)));

  static pw.Widget _badge(String t, PdfColor c) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(color: c, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 6.5, color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)));

  static pw.Widget _chip(String t, PdfColor tc, PdfColor bg, PdfColor bd) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(color: bg, border: pw.Border.all(color: bd, width: 0.3), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, color: tc, fontWeight: pw.FontWeight.bold)));

  static pw.Widget _dot(PdfColor c, String label) =>
    pw.Row(children: [
      pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: c, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)))),
      pw.SizedBox(width: 3),
      pw.Text(label, style: pw.TextStyle(fontSize: 6.5, color: c)),
    ]);
}
