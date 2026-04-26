import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../core/numerology/numerology_engine.dart';
import 'astro_report_screen.dart';

// ── SINGLE THEME: Dark background + Gold accents only ─────────────────────────
const _bg      = PdfColor(0.08, 0.08, 0.08);   // near-black
const _card    = PdfColor(0.12, 0.12, 0.12);   // dark card
const _card2   = PdfColor(0.16, 0.16, 0.16);   // slightly lighter card
const _border  = PdfColor(0.22, 0.22, 0.22);   // subtle border
const _gold    = PdfColor(0.72, 0.59, 0.18);   // brand gold
const _goldDim = PdfColor(0.55, 0.44, 0.12);   // dimmer gold for subtitles
const _white   = PdfColors.white;
const _gray    = PdfColor(0.55, 0.55, 0.55);   // body text
const _gray2   = PdfColor(0.40, 0.40, 0.40);   // dimmer
const _warn    = PdfColor(0.80, 0.35, 0.10);   // muted orange (warnings)
const _danger  = PdfColor(0.75, 0.18, 0.18);   // muted red (high risk)
const _good    = PdfColor(0.18, 0.55, 0.28);   // muted green (yogas/positive)

// ── Planet names ──────────────────────────────────────────────────────────────
String _p(int n) => {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',
    6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'}[n] ?? '';

// ── Safe text — strip chars that pdf package renders as boxes ─────────────────
String _s(String t) => t
    .replaceAll('\u2014','--')  // em-dash
    .replaceAll('\u2013','-')   // en-dash
    .replaceAll('\u2019',"'")   // curly apostrophe
    .replaceAll('\u2018',"'")
    .replaceAll('\u2022','*')   // bullet
    .replaceAll('\u00b7','.')   // middle dot
    .replaceAll('\u2026','...')  // ellipsis
    .replaceAll('\u00e9','e');  // e accent

class PdfReportBuilder {

  static Future<String> build({
    required String clientName,
    required DateTime dob,
    required String astrologerName,
    required String astrologerPhone,
    required int years,
    required List<YearSection> sections,
  }) async {
    // Load logo
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
    final astroPhone = astrologerPhone.isNotEmpty ? astrologerPhone : '';

    // ── COVER PAGE ────────────────────────────────────────────────────────────
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(children: [
        pw.Container(color: _bg),
        // Watermark
        if (logo != null) pw.Positioned(top: 160, left: 60,
          child: pw.Opacity(opacity: 0.05, child: pw.Image(logo, width: 460, height: 460))),
        // Gold top bar
        pw.Positioned(top: 0, left: 0, right: 0,
          child: pw.Container(height: 3, color: _gold)),
        // Content
        pw.Padding(padding: const pw.EdgeInsets.fromLTRB(56, 64, 56, 48),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('NUMEROLOGY LIFE REPORT', style: pw.TextStyle(
                fontSize: 9, color: _gold, letterSpacing: 2.5,
                fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text(_s(clientName), style: pw.TextStyle(
                fontSize: 40, color: _white, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 14),
            pw.Container(width: 80, height: 1, color: _gold),
            pw.SizedBox(height: 24),
            _coverRow('Date of Birth', dobStr),
            pw.SizedBox(height: 6),
            _coverRow('Basic Number', '$basic -- ${_p(basic)}'),
            pw.SizedBox(height: 6),
            _coverRow('Destiny Number', '$destiny -- ${_p(destiny)}'),
            pw.SizedBox(height: 6),
            _coverRow('Report Period', '$years Years ($dateStr onwards)'),
            pw.Spacer(),
            // Bottom card
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: _card,
                border: pw.Border.all(color: _border, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
              child: pw.Row(children: [
                if (logo != null) pw.Opacity(opacity: 0.85,
                    child: pw.Image(logo, width: 32, height: 32)),
                if (logo != null) pw.SizedBox(width: 12),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('AASTROSPHERE', style: pw.TextStyle(
                      fontSize: 12, color: _gold, fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.5)),
                  pw.SizedBox(height: 3),
                  pw.Text('Prepared by $astroLabel${astroPhone.isNotEmpty ? " | $astroPhone" : ""}',
                      style: pw.TextStyle(fontSize: 8, color: _gray)),
                  pw.Text('Report generated on $dateStr',
                      style: pw.TextStyle(fontSize: 8, color: _gray)),
                ]),
              ]),
            ),
          ])),
        // Gold bottom bar
        pw.Positioned(bottom: 0, left: 0, right: 0,
          child: pw.Container(height: 3, color: _gold)),
      ]),
    ));

    // ── CONTENT PAGES ─────────────────────────────────────────────────────────
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 50, 44, 50),
      header: (ctx) => _header(clientName, dateStr, logo),
      footer: (ctx) => _footer(astroLabel, astroPhone, ctx),
      build: (ctx) {
        final widgets = <pw.Widget>[];

        // LIFE PATTERN
        widgets.add(_sectionTitle('LIFE PATTERN'));
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(_lifePatternSection(basic, destiny, natal));
        widgets.add(pw.SizedBox(height: 24));

        // YEAR READINGS
        widgets.add(_sectionTitle('${years.toString().toUpperCase()}-YEAR READING'));
        widgets.add(pw.SizedBox(height: 10));

        int? prevMaha;
        for (final s in sections) {
          if (prevMaha != s.mahaNum) {
            if (prevMaha != null) widgets.add(pw.SizedBox(height: 8));
            widgets.add(_mahaBanner(s.mahaNum));
            widgets.add(pw.SizedBox(height: 8));
            prevMaha = s.mahaNum;
          }
          widgets.add(_yearCard(s));
          widgets.add(pw.SizedBox(height: 8));
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
  static pw.Widget _header(String client, String date, pw.ImageProvider? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Row(children: [
          if (logo != null) pw.Opacity(opacity: 0.7, child: pw.Image(logo, width: 14, height: 14)),
          if (logo != null) pw.SizedBox(width: 6),
          pw.Text('AASTROSPHERE', style: pw.TextStyle(fontSize: 7, color: _gold,
              letterSpacing: 1.5, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Text('${_s(client)}  |  $date', style: pw.TextStyle(fontSize: 7, color: _gray)),
      ]));
  }

  static pw.Widget _footer(String name, String phone, pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('$name${phone.isNotEmpty ? "  |  $phone" : ""}',
            style: pw.TextStyle(fontSize: 7, color: _gray)),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _gray)),
        pw.Text('(c) Aastrosphere  |  Confidential',
            style: pw.TextStyle(fontSize: 7, color: _gray)),
      ]));
  }

  // ── Section title ────────────────────────────────────────────────────────────
  static pw.Widget _sectionTitle(String t) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(t, style: pw.TextStyle(fontSize: 9, color: _gold,
          letterSpacing: 2, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: _gold),
    ]);

  // ── Cover info row ────────────────────────────────────────────────────────────
  static pw.Widget _coverRow(String label, String val) =>
    pw.Row(children: [
      pw.Text('$label  ', style: pw.TextStyle(fontSize: 11, color: _gray)),
      pw.Text(_s(val), style: pw.TextStyle(fontSize: 11, color: _white,
          fontWeight: pw.FontWeight.bold)),
    ]);

  // ── Life pattern section ──────────────────────────────────────────────────────
  static pw.Widget _lifePatternSection(int basic, int destiny, Set<int> natal) {
    final items = <Map<String, dynamic>>[];
    items.add({'title': 'Basic Number $basic -- ${_p(basic)}',
        'body': 'Core personality and daily energy. How they show up in the world.',
        'type': 'neutral'});
    items.add({'title': 'Destiny Number $destiny -- ${_p(destiny)}',
        'body': 'Life direction and soul purpose. Where life keeps pushing them.',
        'type': 'neutral'});
    if (natal.contains(4) && natal.contains(9))
      items.add({'title': '4-9 Natal: Physical Caution',
          'body': 'Accident-prone tendency throughout life. Requires conscious management. Never rush.',
          'type': 'warn'});
    if (natal.contains(5) && natal.contains(7))
      items.add({'title': '5-7 Natal: Easy Money Yoga',
          'body': 'Financial gains come with less effort. Money tends to flow when focus is right.',
          'type': 'good'});
    if (natal.contains(1) && natal.contains(2) && !natal.contains(3) && !natal.contains(6))
      items.add({'title': 'Raj Yoga in Natal Chart',
          'body': 'Authority positions are natural territory. Career advancement strongly supported.',
          'type': 'good'});
    if (natal.contains(8) && natal.contains(9))
      items.add({'title': '8-9 Natal: Heavy Load',
          'body': 'Relentless determination but enormous output. Heart and blood pressure must be protected.',
          'type': 'warn'});

    // Render as 2-column grid
    final rows = <pw.Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i+1 < items.length ? items[i+1] : null;
      rows.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: _lifeCard(left['title'], left['body'], left['type'])),
        pw.SizedBox(width: 8),
        pw.Expanded(child: right != null
            ? _lifeCard(right['title'], right['body'], right['type'])
            : pw.SizedBox()),
      ]));
      rows.add(pw.SizedBox(height: 8));
    }
    return pw.Column(children: rows);
  }

  static pw.Widget _lifeCard(String title, String body, String type) {
    final tc = type == 'good' ? _good : type == 'warn' ? _warn : _gold;
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _card,
        border: pw.Border.all(color: tc, width: 0.4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(_s(title), style: pw.TextStyle(fontSize: 9, color: tc,
            fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(_s(body), style: pw.TextStyle(fontSize: 8, color: _gray, lineSpacing: 1.5)),
      ]));
  }

  // ── Mahadasha banner ──────────────────────────────────────────────────────────
  static pw.Widget _mahaBanner(int num) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: pw.BoxDecoration(
      color: _gold,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
    child: pw.Text('MAHADASHA $num  --  ${_p(num).toUpperCase()}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.black,
            fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)));

  // ── Year card ──────────────────────────────────────────────────────────────────
  static pw.Widget _yearCard(YearSection s) {
    final hasHigh = s.warnings.any((w) => w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK'));
    final bColor = s.isCurrent ? _gold : hasHigh ? _danger : _border;
    final bWidth = (s.isCurrent || hasHigh) ? 0.8 : 0.4;

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _card,
        border: pw.Border.all(color: bColor, width: bWidth),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Header row
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(color: _gold,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Text(_s(s.label), style: pw.TextStyle(fontSize: 9,
                color: PdfColors.black, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(width: 8),
          if (s.isCurrent) _badge('CURRENT', _good),
          if (hasHigh) ...[pw.SizedBox(width: 4), _badge('HIGH RISK', _danger)],
          pw.Spacer(),
          pw.Text('M${s.mahaNum} A${s.antarNum} Mo${s.monthlyNum}',
              style: pw.TextStyle(fontSize: 7, color: _gray2)),
        ]),
        pw.SizedBox(height: 10),

        // 3-col layout: grid | content
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Mini grid
          _miniGrid(s.mahaNum, s.antarNum, s.monthlyNum),
          pw.SizedBox(width: 14),
          // Right content
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            // Dasha labels row
            pw.Row(children: [
              _dashaTag('M${s.mahaNum} ${_p(s.mahaNum)}', _gold),
              pw.SizedBox(width: 5),
              _dashaTag('A${s.antarNum} ${_p(s.antarNum)}', _goldDim),
              pw.SizedBox(width: 5),
              _dashaTag('Mo${s.monthlyNum} ${_p(s.monthlyNum)}', _gray2),
            ]),
            pw.SizedBox(height: 8),

            // Insights
            if (s.insights.isNotEmpty) ...[
              ...s.insights.map((t) => _infoLine(_s(t), _gray)),
              pw.SizedBox(height: 4),
            ],

            // Yogas
            if (s.yogas.isNotEmpty) ...[
              pw.Wrap(spacing: 5, runSpacing: 3,
                  children: s.yogas.map((y) => _smallTag(_s(y), _good)).toList()),
              pw.SizedBox(height: 4),
            ],

            // Warnings
            if (s.warnings.isNotEmpty) ...[
              ...s.warnings.map((w) {
                final isH = w.contains('HIGH ACCIDENT') || w.contains('HIGH RISK');
                return _infoLine(_s(w), isH ? _danger : _warn);
              }),
            ],
          ])),
        ]),

        // Caution months
        if (s.cautionDays.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _card2,
              border: pw.Border.all(color: _warn, width: 0.3),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('CAUTION MONTHS', style: pw.TextStyle(fontSize: 7,
                  color: _warn, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
              pw.SizedBox(height: 4),
              pw.Wrap(spacing: 10, runSpacing: 3,
                children: s.cautionDays.map((c) =>
                    pw.Text(_s(c), style: pw.TextStyle(fontSize: 7, color: _warn))).toList()),
            ])),
        ],

        // Remedies
        if (s.remedies.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _card2,
              border: pw.Border.all(color: _goldDim, width: 0.3),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('REMEDIES', style: pw.TextStyle(fontSize: 7, color: _gold,
                  fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
              pw.SizedBox(height: 4),
              pw.Text(_s(s.remedies), style: pw.TextStyle(fontSize: 8,
                  color: _gray, lineSpacing: 1.5)),
            ])),
        ],
      ]));
  }

  // ── Mini 3x3 grid ──────────────────────────────────────────────────────────────
  static pw.Widget _miniGrid(int maha, int antar, int monthly) {
    const pos = {3:[0,0],1:[0,1],9:[0,2],6:[1,0],7:[1,1],5:[1,2],2:[2,0],8:[2,1],4:[2,2]};
    const abbr = [['Ju','Su','Ma'],['Ve','Ke','Me'],['Mo','Sa','Ra']];
    return pw.Container(
      width: 92,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(children: List.generate(3, (row) =>
        pw.Row(children: List.generate(3, (col) {
          final num = pos.entries.firstWhere(
              (e) => e.value[0]==row && e.value[1]==col,
              orElse: () => const MapEntry(0,[0,0])).key;
          final isMaha    = num == maha;
          final isAntar   = num == antar;
          final isMonthly = num == monthly;
          final isAny = isMaha || isAntar || isMonthly;
          // Use gold for maha, slightly dimmer for antar, dimmer still for monthly
          final tc = isMaha ? _gold : isAntar ? _goldDim : isAny ? _gray : _gray2;
          final bg = isMaha ? PdfColor(0.72,0.59,0.18,0.14)
                   : isAntar ? PdfColor(0.72,0.59,0.18,0.07)
                   : isMonthly ? PdfColor(0.72,0.59,0.18,0.04)
                   : PdfColor(0,0,0,0);
          return pw.Expanded(child: pw.Container(
            height: 28,
            color: bg,
            child: pw.Stack(children: [
              // Cell border
              if (col < 2) pw.Positioned(right: 0, top: 0, bottom: 0,
                  child: pw.Container(width: 0.3, color: _border)),
              if (row < 2) pw.Positioned(left: 0, right: 0, bottom: 0,
                  child: pw.Container(height: 0.3, color: _border)),
              pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text('$num', style: pw.TextStyle(fontSize: 12, color: tc,
                    fontWeight: isAny ? pw.FontWeight.bold : pw.FontWeight.normal)),
                pw.Text(abbr[row][col], style: pw.TextStyle(fontSize: 5, color: _gray2)),
              ])),
            ])));
        }))
      )));
  }

  // ── Small helpers ─────────────────────────────────────────────────────────────
  static pw.Widget _badge(String t, PdfColor c) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: pw.BoxDecoration(color: c,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 6, color: PdfColors.white,
        fontWeight: pw.FontWeight.bold, letterSpacing: 0.3)));

  static pw.Widget _dashaTag(String t, PdfColor c) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: c, width: 0.4),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7, color: c)));

  static pw.Widget _smallTag(String t, PdfColor c) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: pw.BoxDecoration(
      color: PdfColor(c.red,c.green,c.blue,0.12),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7, color: c)));

  static pw.Widget _infoLine(String t, PdfColor c) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 4),
    padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: pw.BoxDecoration(
      color: PdfColor(c.red,c.green,c.blue,0.08),
      border: pw.Border(left: pw.BorderSide(color: c, width: 2))),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 8, color: _gray, lineSpacing: 1.4)));
}
