import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../ask/ask_screen.dart';
import 'chart_screen.dart' show kNeutralEnergyLabel;

/// Short, static "what does this planet mean" glossary — shown instantly on
/// tap, no network round trip. Kept intentionally brief; anything deeper
/// routes into the Ask chat, which is where the real personalization lives.
const Map<int, String> kPlanetMeaning = {
  1: 'Leadership, confidence, and the drive to be seen as the authority in the room.',
  2: 'Emotions, relationships, and intuition — how you connect and how you feel things.',
  3: 'Wisdom, ethics, and growth — the part of you that thinks about right and wrong.',
  4: 'Unconventional thinking and sudden change — ideas and shifts that don\'t follow a straight line.',
  5: 'Intellect, communication, and business — quick thinking and sharp decisions.',
  6: 'Love, beauty, and comfort — relationships, aesthetics, and the good life.',
  7: 'Detachment and inner depth — intuition, spirituality, and letting go.',
  8: 'Discipline and long-term results — the slow, hard-earned kind of success.',
  9: 'Action, courage, and drive — the energy that pushes you to compete and move.',
};

enum ChartPeriodType { maha, antar, monthly, daily, hourly, basic, destiny, grid }

class _PeriodContext {
  final String timeframeLabel;
  final String explanation;
  const _PeriodContext(this.timeframeLabel, this.explanation);
}

const Map<ChartPeriodType, _PeriodContext> _kPeriodContext = {
  ChartPeriodType.maha: _PeriodContext(
    'Long-term Phase',
    'This is the dominant theme running through your life for this multi-year stretch — it colors your big decisions, opportunities, and challenges until it ends.',
  ),
  ChartPeriodType.antar: _PeriodContext(
    'Current Phase',
    'Inside your long-term phase, this is the specific sub-theme active right now for a few months — it shapes what actually shows up day to day.',
  ),
  ChartPeriodType.monthly: _PeriodContext(
    'This Month',
    'A shorter-term flavor layered on top of your longer cycles — highlighted for the current month only.',
  ),
  ChartPeriodType.daily: _PeriodContext(
    'Today',
    'The most immediate, short-term influence — today\'s specific energy.',
  ),
  ChartPeriodType.hourly: _PeriodContext(
    'This Hour',
    'The most fine-grained layer — useful for timing a decision within the next hour or two.',
  ),
  ChartPeriodType.basic: _PeriodContext(
    'Basic Number',
    'Reflects your inner self — how you naturally think and react, before the world shapes you.',
  ),
  ChartPeriodType.destiny: _PeriodContext(
    'Destiny Number',
    'Reflects your life path — the overarching direction your life tends to move toward.',
  ),
  ChartPeriodType.grid: _PeriodContext(
    'Birth Grid',
    'Shows how many times this number appears in your birth date. More repetitions mean this energy is more central to who you are.',
  ),
};

String _buildQuestion(ChartPeriodType type, int number, String planet, {String? extra}) {
  switch (type) {
    case ChartPeriodType.maha:
      return 'My Long-term Phase (Mahadasha) right now is $planet. What does that mean for me and what should I expect during this phase?';
    case ChartPeriodType.antar:
      return 'My Current Phase (Antardasha) right now is $planet. What does this specific combination mean for me right now?';
    case ChartPeriodType.monthly:
      return 'This month\'s number is $planet. What does that mean for me this month?';
    case ChartPeriodType.daily:
      return 'Today\'s number is $number. What does that mean for me today?';
    case ChartPeriodType.hourly:
      return 'This hour\'s number is $number. What does that mean for me right now?';
    case ChartPeriodType.basic:
      return 'My Basic Number is $number ($planet). What does that mean about my inner self?';
    case ChartPeriodType.destiny:
      return 'My Destiny Number is $number ($planet). What does that mean about my life path?';
    case ChartPeriodType.grid:
      return 'In my birth chart grid, $planet appears $extra time(s). What does that mean for me?';
  }
}

void showChartExplainer(
  BuildContext context, {
  required ChartPeriodType type,
  required int number,
  required bool isDark,
  required Color gold,
  String? gridCount,
}) {
  final planet = kNeutralEnergyLabel[number] ?? '';
  final meaning = kPlanetMeaning[number] ?? '';
  final ctx = _kPeriodContext[type]!;
  final question = _buildQuestion(type, number, planet, extra: gridCount);

  final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
  final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(children: [
            Container(
              width: 44, height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text('$number',
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, color: gold, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${ctx.timeframeLabel} · $planet',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: primary)),
              Text('What this means', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          if (meaning.isNotEmpty) ...[
            Text(meaning, style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.5)),
            const SizedBox(height: 10),
          ],
          Text(ctx.explanation, style: GoogleFonts.dmSans(fontSize: 13, color: secondary, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AskScreen(initialQuestion: question)),
                );
              },
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Ask for my personalized insight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
