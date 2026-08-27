import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../ask/ask_screen.dart';
import 'chart_screen.dart' show kNeutralEnergyLabel;

/// One icon per planet — used for lightweight visual summaries (onboarding,
/// grid highlights) where a wall of text isn't the right first impression.
const Map<int, IconData> kPlanetIcon = {
  1: Icons.wb_sunny_rounded,
  2: Icons.nightlight_round,
  3: Icons.auto_awesome_rounded,
  4: Icons.bolt_rounded,
  5: Icons.chat_bubble_rounded,
  6: Icons.favorite_rounded,
  7: Icons.spa_rounded,
  8: Icons.hourglass_bottom_rounded,
  9: Icons.local_fire_department_rounded,
};

enum ChartPeriodType { maha, antar, monthly, daily, hourly, basic, destiny, grid }

/// Short, static "what does this planet mean" glossary — shown instantly on
/// tap, no network round trip. Kept intentionally brief; anything deeper
/// routes into the Ask chat, which is where the real personalization lives.
String _planetMeaning(AppLocalizations t, int number) {
  switch (number) {
    case 1: return t.planetMeaning1;
    case 2: return t.planetMeaning2;
    case 3: return t.planetMeaning3;
    case 4: return t.planetMeaning4;
    case 5: return t.planetMeaning5;
    case 6: return t.planetMeaning6;
    case 7: return t.planetMeaning7;
    case 8: return t.planetMeaning8;
    case 9: return t.planetMeaning9;
    default: return '';
  }
}

class _PeriodContext {
  final String timeframeLabel;
  final String explanation;
  const _PeriodContext(this.timeframeLabel, this.explanation);
}

_PeriodContext _periodContext(AppLocalizations t, ChartPeriodType type) {
  switch (type) {
    case ChartPeriodType.maha:
      return _PeriodContext(t.longTermPhase, t.periodExplainMaha);
    case ChartPeriodType.antar:
      return _PeriodContext(t.currentPhase, t.periodExplainAntar);
    case ChartPeriodType.monthly:
      return _PeriodContext(t.monthlyLabel, t.periodExplainMonthly);
    case ChartPeriodType.daily:
      return _PeriodContext(t.dailyLabel, t.periodExplainDaily);
    case ChartPeriodType.hourly:
      return _PeriodContext(t.hourlyLabel, t.periodExplainHourly);
    case ChartPeriodType.basic:
      return _PeriodContext(t.explainerBasicNumberLabel, t.periodExplainBasic);
    case ChartPeriodType.destiny:
      return _PeriodContext(t.explainerDestinyNumberLabel, t.periodExplainDestiny);
    case ChartPeriodType.grid:
      return _PeriodContext(t.explainerGridLabel, t.periodExplainGrid);
  }
}

String _buildQuestion(AppLocalizations t, ChartPeriodType type, int number, String planet, {String? extra}) {
  switch (type) {
    case ChartPeriodType.maha:
      return t.askQuestionMaha(planet);
    case ChartPeriodType.antar:
      return t.askQuestionAntar(planet);
    case ChartPeriodType.monthly:
      return t.askQuestionMonthly(planet);
    case ChartPeriodType.daily:
      return t.askQuestionDaily(number);
    case ChartPeriodType.hourly:
      return t.askQuestionHourly(number);
    case ChartPeriodType.basic:
      return t.askQuestionBasic(number, planet);
    case ChartPeriodType.destiny:
      return t.askQuestionDestiny(number, planet);
    case ChartPeriodType.grid:
      return t.askQuestionGrid(planet, extra ?? '1');
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
  final t = AppLocalizations.of(context)!;
  final planet = kNeutralEnergyLabel[number] ?? '';
  final meaning = _planetMeaning(t, number);
  final ctx = _periodContext(t, type);
  final question = _buildQuestion(t, type, number, planet, extra: gridCount);

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
              Text(t.explainerWhatThisMeans, style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
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
              label: Text(t.explainerAskButton),
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
