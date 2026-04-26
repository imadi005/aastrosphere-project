import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../core/numerology/numerology_engine.dart';
import 'astro_report_screen.dart';

// ─── Color palette ─────────────────────────────────────────────────────────────
const _gold      = PdfColor(0.722, 0.588, 0.18);
const _goldLight = PdfColor(0.831, 0.706, 0.376);
const _darkBg    = PdfColor(0.09, 0.09, 0.09);
const _cardBg    = PdfColor(0.13, 0.13, 0.13);
const _textW     = PdfColors.white;
const _textGray  = PdfColor(0.6, 0.6, 0.6);
const _textDark  = PdfColor(0.15, 0.15, 0.15);
const _green     = PdfColor(0.09, 0.64, 0.20);
const _red       = PdfColor(0.86, 0.15, 0.15);
const _orange    = PdfColor(0.85, 0.47, 0.04);
const _indigo    = PdfColor(0.39, 0.40, 0.94);
const _subtle    = PdfColor(0.17, 0.17, 0.17);
const _border    = PdfColor(0.25, 0.25, 0.25);

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
    pw.ImageProvider? logoImage;
    try {
      final bytes = await rootBundle.load('assets/images/zodiac_circle_gold.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final doc = pw.Document();
    final dobStr = '${dob.day}/${dob.month}/${dob.year}';
    final basic = NumerologyEngine.basicNumber(dob.day);
    final destiny = NumerologyEngine.destinyNumber(dob);
    final natalNums = NumerologyEngine.chartDigits(dob).toSet();
    final today = DateTime.now();
    final dateStr = '${today.day}/${today.month}/${today.year}';

    // ── COVER PAGE ──────────────────────────────────────────────────────────
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Stack(children: [
        // Dark background
        pw.Container(color: _darkBg),

        // Watermark logo
        if (logoImage != null) pw.Positioned(
          top: 180, left: 80,
          child: pw.Opacity(opacity: 0.06,
            child: pw.Image(logoImage, width: 440, height: 440))),

        // Gold top bar
        pw.Positioned(top: 0, left: 0, right: 0,
          child: pw.Container(height: 4, color: _gold)),

        // Content
        pw.Padding(padding: const pw.EdgeInsets.all(56), child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 60),
            // Small label
            pw.Text('NUMEROLOGY LIFE REPORT',
                style: pw.TextStyle(fontSize: 10, color: _gold, letterSpacing: 3,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 24),
            // Client name
            pw.Text(clientName,
                style: pw.TextStyle(fontSize: 42, color: _textW,
                    fontWeight: pw.FontWeight.bold, lineSpacing: 1.1)),
            pw.SizedBox(height: 16),
            // Divider
            pw.Container(height: 1, width: 120, color: _gold),
            pw.SizedBox(height: 24),
            // DOB + numbers
            _infoRow('Date of Birth', dobStr),
            pw.SizedBox(height: 8),
            _infoRow('Basic Number', '$basic — ${_planetName(basic)}'),
            pw.SizedBox(height: 8),
            _infoRow('Destiny Number', '$destiny — ${_planetName(destiny)}'),
            pw.SizedBox(height: 8),
            _infoRow('Report Period', '$years Years ($dateStr onwards)'),
            pw.Spacer(),
            // Bottom section
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: _cardBg,
                border: pw.Border.all(color: _border, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Row(children: [
                if (logoImage != null) pw.Image(logoImage, width: 36, height: 36),
                pw.SizedBox(width: 14),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('AASTROSPHERE',
                      style: pw.TextStyle(fontSize: 13, color: _gold,
                          fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.Text('Prepared by $astrologerName  |  $astrologerPhone',
                      style: pw.TextStyle(fontSize: 9, color: _textGray)),
                  pw.Text('Report generated on $dateStr',
                      style: pw.TextStyle(fontSize: 9, color: _textGray)),
                ]),
              ]),
            ),
          ],
        )),
        // Gold bottom bar
        pw.Positioned(bottom: 0, left: 0, right: 0,
          child: pw.Container(height: 4, color: _gold)),
      ]),
    ));

    // ── CONTENT PAGES ───────────────────────────────────────────────────────
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(48, 52, 48, 52),
      header: (ctx) => _pageHeader(clientName, dateStr, logoImage),
      footer: (ctx) => _pageFooter(astrologerName, astrologerPhone, ctx),
      build: (ctx) {
        final widgets = <pw.Widget>[];

        // ── LIFE PATTERN SECTION ───────────────────────────────────────────
        widgets.add(_sectionTitle('LIFE PATTERN'));
        widgets.add(pw.SizedBox(height: 12));

        // Life pattern cards
        final lifeCards = [
          _buildLifeCard('Basic Number — ${_planetName(basic)}',
              'The core personality and daily energy. How they show up in the world.', _gold),
          _buildLifeCard('Destiny Number — ${_planetName(destiny)}',
              'The life direction and soul purpose. Where life keeps pushing them.', _goldLight),
        ];
        if (natalNums.contains(4) && natalNums.contains(9)) {
          lifeCards.add(_buildLifeCard('4-9 Natal Combination',
              'Physically impulsive and accident-prone. Requires conscious management throughout life. Physical caution is a lifetime practice.', _red));
        }
        if (natalNums.contains(5) && natalNums.contains(7)) {
          lifeCards.add(_buildLifeCard('Easy Money Yoga (5-7)',
              'Financial gains come with less struggle than average. Money tends to flow when focus is right.', _green));
        }
        if (natalNums.contains(1) && natalNums.contains(2) && !natalNums.contains(3) && !natalNums.contains(6)) {
          lifeCards.add(_buildLifeCard('Raj Yoga',
              'Authority positions are natural territory. Career advancement is strongly supported. High rise in life.', _gold));
        }
        if (natalNums.contains(8) && natalNums.contains(9)) {
          lifeCards.add(_buildLifeCard('8-9 Tension',
              'Relentless determination but heavy load. Enormous output is possible but health — especially heart and blood pressure — must be protected.', _orange));
        }

        widgets.add(pw.Wrap(spacing: 10, runSpacing: 10,
            children: lifeCards));
        widgets.add(pw.SizedBox(height: 28));

        // ── YEAR SECTIONS ─────────────────────────────────────────────────
        widgets.add(_sectionTitle('$years-YEAR READING'));
        widgets.add(pw.SizedBox(height: 12));

        int? prevMaha;
        for (final s in sections) {
          // Maha change banner
          if (prevMaha != s.mahaNum) {
            if (prevMaha != null) widgets.add(pw.SizedBox(height: 8));
            widgets.add(_mahaBanner(s.mahaNum, s.mahaPlanet));
            widgets.add(pw.SizedBox(height: 8));
            prevMaha = s.mahaNum;
          }

          widgets.add(_yearCard(s));
          widgets.add(pw.SizedBox(height: 10));
        }

        return widgets;
      },
    ));

    // Save and return path
    final dir = await getTemporaryDirectory();
    final safeName = clientName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final path = '${dir.path}/Aastrosphere_${safeName}_Report.pdf';
    final file = File(path);
    await file.writeAsBytes(await doc.save());
    return path;
  }

  // ─── Page header ─────────────────────────────────────────────────────────────
  static pw.Widget _pageHeader(String clientName, String date, pw.ImageProvider? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Row(children: [
          if (logo != null) pw.Opacity(opacity: 0.8, child: pw.Image(logo, width: 18, height: 18)),
          if (logo != null) pw.SizedBox(width: 8),
          pw.Text('AASTROSPHERE',
              style: pw.TextStyle(fontSize: 8, color: _gold, letterSpacing: 1.5,
                  fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Text('$clientName  |  $date',
            style: pw.TextStyle(fontSize: 8, color: _textGray)),
      ]),
    );
  }

  // ─── Page footer ─────────────────────────────────────────────────────────────
  static pw.Widget _pageFooter(String name, String phone, pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('$name  |  $phone',
            style: pw.TextStyle(fontSize: 8, color: _textGray)),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _textGray)),
        pw.Text('© Aastrosphere  |  Confidential',
            style: pw.TextStyle(fontSize: 8, color: _textGray)),
      ]),
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────────
  static pw.Widget _sectionTitle(String title) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title,
          style: pw.TextStyle(fontSize: 10, color: _gold, letterSpacing: 2,
              fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Container(height: 1, color: _gold),
    ]);
  }

  // ─── Life card ────────────────────────────────────────────────────────────────
  static pw.Widget _buildLifeCard(String title, String body, PdfColor color) {
    return pw.Container(
      width: 232,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.06),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.3), width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 10, color: color, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(body,
            style: pw.TextStyle(fontSize: 9, color: _textDark, lineSpacing: 1.5)),
      ]),
    );
  }

  // ─── Maha banner ─────────────────────────────────────────────────────────────
  static pw.Widget _mahaBanner(int num, String planet) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _gold,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(children: [
        pw.Text('MAHADASHA $num',
            style: pw.TextStyle(fontSize: 11, color: PdfColors.black,
                fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
        pw.Text('  —  ${planet.toUpperCase()}',
            style: pw.TextStyle(fontSize: 11, color: PdfColors.black, letterSpacing: 0.5)),
      ]),
    );
  }

  // ─── Year card ────────────────────────────────────────────────────────────────
  static pw.Widget _yearCard(YearSection s) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: s.isCurrent ? PdfColor(0.722, 0.588, 0.18, 0.04) : PdfColors.white,
        border: pw.Border.all(
            color: s.isCurrent ? _gold
                : (s.warnings.any((w) => w.contains('HIGH ACCIDENT') || w.contains('RISK')) ? _red : _border),
            width: s.isCurrent ? 1 : 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Year header row
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: pw.BoxDecoration(color: _gold, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: pw.Text(s.label,
                style: pw.TextStyle(fontSize: 10, color: PdfColors.black, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(width: 10),
          if (s.isCurrent) pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(color: _green, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Text('CURRENT', style: pw.TextStyle(fontSize: 7, color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
          ),
          if (s.warnings.any((w) => w.contains('HIGH ACCIDENT'))) ...[
            pw.SizedBox(width: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(color: _red, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Text('HIGH RISK', style: pw.TextStyle(fontSize: 7, color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
            ),
          ],
          pw.Spacer(),
          // Dasha numbers
          pw.Text('M${s.mahaNum}  A${s.antarNum}  Mo${s.monthlyNum}',
              style: pw.TextStyle(fontSize: 9, color: _textGray)),
        ]),
        pw.SizedBox(height: 10),

        // Mini grid (3x3) inline
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Grid
          _miniGrid3x3(s.mahaNum, s.antarNum, s.monthlyNum),
          pw.SizedBox(width: 16),
          // Right side content
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            // Dasha pills row
            pw.Wrap(spacing: 6, runSpacing: 4, children: [
              _dashaChip('Maha ${s.mahaNum}', s.mahaPlanet, _gold),
              _dashaChip('Antar ${s.antarNum}', s.antarPlanet, _green),
              _dashaChip('Monthly ${s.monthlyNum}', s.monthlyPlanet, _indigo),
            ]),
            pw.SizedBox(height: 10),

            // Insights
            if (s.insights.isNotEmpty) ...[
              for (final ins in s.insights) _infoChunk(ins, _indigo),
              pw.SizedBox(height: 6),
            ],

            // Yogas
            if (s.yogas.isNotEmpty) pw.Wrap(spacing: 6, runSpacing: 4,
                children: s.yogas.map((y) => _tag(y, _green)).toList()),
            if (s.yogas.isNotEmpty) pw.SizedBox(height: 6),

            // Warnings
            if (s.warnings.isNotEmpty) ...[
              for (final w in s.warnings)
                _infoChunk(w, w.contains('HIGH ACCIDENT') || w.contains('RISK') ? _red : _orange, isWarning: true),
            ],
          ])),
        ]),

        // Caution months
        if (s.cautionDays.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor(0.85, 0.47, 0.04, 0.05),
              border: pw.Border.all(color: PdfColor(0.85, 0.47, 0.04, 0.3), width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('CAUTION MONTHS', style: pw.TextStyle(fontSize: 7, color: _orange, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Wrap(spacing: 8, runSpacing: 4, children: s.cautionDays.map((c) =>
                  pw.Text(c, style: pw.TextStyle(fontSize: 8, color: _orange))).toList()),
            ]),
          ),
        ],

        // Remedies
        if (s.remedies.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor(0.722, 0.588, 0.18, 0.04),
              border: pw.Border.all(color: PdfColor(0.722, 0.588, 0.18, 0.3), width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('REMEDIES', style: pw.TextStyle(fontSize: 7, color: _gold, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
              pw.SizedBox(height: 5),
              pw.Text(s.remedies, style: pw.TextStyle(fontSize: 9, color: _textDark, lineSpacing: 1.6)),
            ]),
          ),
        ],
      ]),
    );
  }

  // ─── Mini 3x3 grid ────────────────────────────────────────────────────────────
  static pw.Widget _miniGrid3x3(int maha, int antar, int monthly) {
    const positions = {
      3:[0,0], 1:[0,1], 9:[0,2],
      6:[1,0], 7:[1,1], 5:[1,2],
      2:[2,0], 8:[2,1], 4:[2,2],
    };
    const planetAbbr = [['Ju','Su','Ma'],['Ve','Ke','Me'],['Mo','Sa','Ra']];

    return pw.Container(
      width: 100,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(children: List.generate(3, (row) =>
        pw.Row(children: List.generate(3, (col) {
          final num = positions.entries
              .firstWhere((e) => e.value[0] == row && e.value[1] == col,
                  orElse: () => const MapEntry(0, [0,0])).key;
          PdfColor c = _textGray;
          if (num == maha) c = _gold;
          else if (num == antar) c = _green;
          else if (num == monthly) c = _indigo;
          final isHighlighted = num == maha || num == antar || num == monthly;
          return pw.Expanded(child: pw.Container(
            height: 30,
            decoration: pw.BoxDecoration(
              color: isHighlighted ? PdfColor(c.red, c.green, c.blue, 0.1) : null,
              border: pw.Border(
                right: col < 2 ? pw.BorderSide(color: _border, width: 0.3) : pw.BorderSide.none,
                bottom: row < 2 ? pw.BorderSide(color: _border, width: 0.3) : pw.BorderSide.none,
              ),
            ),
            child: pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Text('$num', style: pw.TextStyle(fontSize: 13, color: c,
                  fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal)),
              pw.Text(planetAbbr[row][col], style: pw.TextStyle(fontSize: 5, color: _textGray)),
            ])),
          ));
        }))
      )),
    );
  }

  // ─── Small helpers ────────────────────────────────────────────────────────────
  static pw.Widget _dashaChip(String num, String planet, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.1),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.3), width: 0.4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Text('$num  $planet', style: pw.TextStyle(fontSize: 8, color: color)),
    );
  }

  static pw.Widget _infoChunk(String text, PdfColor color, {bool isWarning = false}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.06),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.2), width: 0.4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(isWarning ? '[!] ' : '[-] ', style: pw.TextStyle(fontSize: 9, color: color, fontWeight: pw.FontWeight.bold)),
        pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: _textDark, lineSpacing: 1.4))),
      ]),
    );
  }

  static pw.Widget _tag(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.1),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.25), width: 0.4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, color: color)),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(children: [
      pw.Text('$label  ', style: pw.TextStyle(fontSize: 11, color: _textGray)),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, color: _textW, fontWeight: pw.FontWeight.bold)),
    ]);
  }

  static String _planetName(int n) {
    const names = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};
    return names[n] ?? '';
  }
}
