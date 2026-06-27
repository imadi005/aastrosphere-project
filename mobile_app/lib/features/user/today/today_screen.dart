import 'package:flutter/material.dart';
import '../../../core/providers/today_provider.dart';
import '../../../core/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/user_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _notificationsScheduled = false;
  String _lastScheduledDate = '';
  String _lastLoadedDate = '';

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(smartProfileProvider);
    final todayAsync = ref.watch(todayDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Refresh data when date changes (midnight / app reopen next day)
    final todayDate = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastLoadedDate.isNotEmpty && _lastLoadedDate != todayDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(todayDataProvider);
      });
    }

    // Schedule notifications when data loads (once per day, resets at midnight)
    todayAsync.whenData((data) {
      _lastLoadedDate = todayDate;
      if (_lastScheduledDate != todayDate) {
        _lastScheduledDate = todayDate;
        _notificationsScheduled = true;
        _scheduleNotifications(data);
      }
    });

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => const _NoProfileView(),
      data: (user) {
        if (user == null) return const _NoProfileView();
        return todayAsync.when(
          loading: () => Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 1.5, color: gold),
              const SizedBox(height: 16),
              Text('Reading today\'s energy...',
                  style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
            ],
          )),
          error: (e, _) => _ErrorView(onRetry: () => ref.refresh(todayDataProvider)),
          data: (data) { AnalyticsService.todayViewed(); return _TodayView(
            data: data, name: user.name, isDark: isDark,
            onRefresh: () async => ref.refresh(todayDataProvider),
          ); },
        );
      },
    );
  }
}

class _TodayView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String name;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const _TodayView({required this.data, required this.name,
      required this.isDark, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final now = DateTime.now();

    final rating = data['rating'] as String? ?? 'caution';
    final ratingLabel = data['rating_label'] as String? ?? '';
    final quote = data['quote'] as String? ?? '';
    final insight = data['insight'] as String? ?? '';
    final toDo = (data['what_to_do'] as List? ?? []).cast<String>();
    final avoid = (data['what_to_avoid'] as List? ?? []).cast<String>();
    final dayScoreData = data['day_score'] as Map<String, dynamic>?;
    final characteristics = (data['characteristics'] as List? ?? []);
    final primaryAction = data['primary_action'] as String?;
    final primaryAvoid = data['primary_avoid'] as String?;
    final structuralYogas = (data['structural_yogas'] as List? ?? []);
    final comboYogas = (data['combo_yogas'] as List? ?? []);
    final bestHours = (data['best_hours'] as List? ?? []);
    final cautionHours = (data['caution_hours'] as List? ?? []);
    final allHours = (data['all_hours'] as List? ?? []);
    final currentHour = data['current_hour'] as int? ?? now.hour;
    final dailyNum = data['daily_number'] as int? ?? 0;
    final accidentRiskHours = (data['accident_risk_hours'] as List? ?? []).cast<Map<String, dynamic>>();
    final dailyAccidentRisk = data['daily_accident_risk'] as Map<String, dynamic>?;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 1. Greeting ──────────────────────────────────────
            _GreetingRow(name: name, date: now, isDark: isDark, gold: gold),
            const SizedBox(height: 16),

            // ── 2. Yoga pills ────────────────────────────────────
            if (structuralYogas.isNotEmpty) ...[
              _YogaPills(yogas: structuralYogas, gold: gold),
              const SizedBox(height: 16),
            ],

            // ── 3. Day card — quote + insight (expandable) ───────
            _DayCard(
              quote: quote, insight: insight,
              rating: rating, ratingLabel: ratingLabel, dailyNum: dailyNum,
              isDark: isDark, gold: gold,
              layers: data['layers'] as Map<String, dynamic>?,
            ),
            const SizedBox(height: 16),

            // ── 4b. Accident risk warning ────────────────────────
            if (dailyAccidentRisk != null || accidentRiskHours.isNotEmpty)
              _AccidentWarningCard(
                dailyRisk: dailyAccidentRisk,
                riskHours: accidentRiskHours,
                isDark: isDark,
              ),
            if (dailyAccidentRisk != null || accidentRiskHours.isNotEmpty)
              const SizedBox(height: 16),

            // ── 5. Today's one action ────────────────────────────
            if (primaryAction != null || primaryAvoid != null)
              _OneActionCard(
                action: primaryAction,
                avoid: primaryAvoid,
                isDark: isDark, gold: gold,
              ),
            const SizedBox(height: 16),

            // ── 6. Full guidance — expandable ───────────────────
            _GuidanceCard(toDo: toDo, avoid: avoid, isDark: isDark, gold: gold),
            const SizedBox(height: 16),


            const SizedBox(height: 16),

            // ── 8. Today's Character (replaces the score) ─────────
            if (characteristics.isNotEmpty)
              _DayCharacterCard(items: characteristics, isDark: isDark, gold: gold),
            const SizedBox(height: 16),

            // ── 9. Your Hours — now + day parts (no graph) ────────
            if (allHours.isNotEmpty)
              _HoursCard(allHours: allHours, currentHour: DateTime.now().hour, isDark: isDark, gold: gold),
            const SizedBox(height: 10),


          ],
        ),
      ),
    );
  }
}

// ─── 1. Greeting row ──────────────────────────────────────────────────────────
class _GreetingRow extends StatelessWidget {
  final String name;
  final DateTime date;
  final bool isDark;
  final Color gold;
  const _GreetingRow({required this.name, required this.date,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final first = name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_greeting(first),
            style: GoogleFonts.cormorantGaramond(
                fontSize: 26, fontWeight: FontWeight.w400, color: gold)),
        Text(DateFormat('EEEE, d MMMM').format(date),
            style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
      ],
    );
  }

  String _greeting(String first) {
    final h = DateTime.now().hour;
    // 5 AM – 11:59 AM
    if (h >= 5 && h < 12) return 'Good morning, $first';
    // 12 PM – 4:59 PM
    if (h >= 12 && h < 17) return 'Good afternoon, $first';
    // 5 PM – 9:59 PM
    if (h >= 17 && h < 22) return 'Good evening, $first';
    // 10 PM – 4:59 AM (late night / very early)
    return 'Hello, $first';
  }
}

  Future<void> _scheduleNotifications(Map<String, dynamic> data) async {
    try {
      final quote = data['quote'] as String? ?? '';
      final rating = data['rating'] as String? ?? 'caution';
      final layers = data['layers'] as Map<String, dynamic>?;
      final dailyQuality = layers?['daily'] as String? ?? 'Today';
      final accidentRiskHours = (data['accident_risk_hours'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      await NotificationService.scheduleDailySnapshot(
        quote: quote, rating: rating, dailyQuality: dailyQuality,
      );
      if (accidentRiskHours.isNotEmpty) {
        await NotificationService.scheduleAccidentWarnings(
          accidentRiskHours: accidentRiskHours,
        );
      }
    } catch (_) {}
  }


// ─── 2. Yoga pills ────────────────────────────────────────────────────────────
class _YogaPills extends StatelessWidget {
  final List<dynamic> yogas;
  final Color gold;
  const _YogaPills({required this.yogas, required this.gold});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: yogas.length,
        itemBuilder: (_, i) {
          final y = yogas[i] as Map<String, dynamic>;
          final isPos = y['positive'] == true;
          final color = isPos ? gold : Colors.redAccent;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.35), width: 0.5),
            ),
            child: Text(y['name'] as String? ?? '',
                style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w500, color: color)),
          );
        },
      ),
    );
  }
}

// ─── 3. Day card ──────────────────────────────────────────────────────────────
class _DayCard extends StatefulWidget {
  final String quote, insight, rating;
  final String ratingLabel;
  final int dailyNum;
  final bool isDark;
  final Color gold;
  final Map<String, dynamic>? layers;
  const _DayCard({required this.quote, required this.insight, required this.rating,
      this.ratingLabel = '', required this.dailyNum, required this.isDark, required this.gold, this.layers});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    Color ratingColor;
    String ratingLabel;
    switch (widget.rating) {
      case 'favorable': ratingColor = widget.isDark ? AppColors.successDark : AppColors.success; ratingLabel = 'FAVORABLE';
      case 'good': ratingColor = widget.isDark ? AppColors.successDark : AppColors.success; ratingLabel = 'GOOD';
      case 'avoid': ratingColor = widget.isDark ? AppColors.dangerDark : AppColors.danger; ratingLabel = 'CHALLENGING';
      case 'caution': ratingColor = const Color(0xFFF59E0B); ratingLabel = 'CAUTION';
      default: ratingColor = widget.gold; ratingLabel = 'STEADY';
    }
    // Varied label from API (color stays from rating above)
    if (widget.ratingLabel.isNotEmpty) ratingLabel = widget.ratingLabel.toUpperCase();

    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote + tag inline
          if (widget.quote.isNotEmpty) ...[
            Text('"${widget.quote}"',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 26, fontStyle: FontStyle.italic,
                    color: widget.gold, height: 1.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ratingColor.withOpacity(0.25), width: 0.5),
                ),
                child: Text(ratingLabel,
                    style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700,
                        letterSpacing: 0.8, color: ratingColor)),
              ),
            ]),
          ],
          const SizedBox(height: 12),
          Divider(color: border, thickness: 0.5),
          const SizedBox(height: 10),

          // Insight — styled with left border
          Container(
            padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: widget.gold.withOpacity(0.35), width: 2)),
            ),
            child: Text(widget.insight,
                style: GoogleFonts.dmSans(fontSize: 13, color: primary.withOpacity(0.8), height: 1.7)),
          ),


        ],
      ),
    );
  }
}

// ─── 4. Best & Caution hours summary ─────────────────────────────────────────
// ─── Hour Section: Heatmap strip + Current hour + Next 3 ─────────────────────
class _HourSection extends StatelessWidget {
  final List<dynamic> allHours;
  final int currentHour;
  final bool isDark;
  final Color gold;

  const _HourSection({
    required this.allHours, required this.currentHour,
    required this.isDark, required this.gold,
  });

  Color _hourColor(String cls, bool isDark) {
    switch (cls) {
      case 'best':    return isDark ? AppColors.successDark : AppColors.success;
      case 'caution': return const Color(0xFFF59E0B);
      case 'avoid':   return isDark ? AppColors.dangerDark : AppColors.danger;
      default:        return isDark ? Colors.white24 : Colors.black12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary   = isDark ? AppColors.textPrimaryDark  : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg    = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final border    = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtleBg  = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;

    final waking = allHours
        .where((h) { final hr = h['hour'] as int; return hr >= 6 && hr <= 23; })
        .toList();

    final currentData = allHours.firstWhere(
      (h) => h['hour'] == currentHour,
      orElse: () => allHours.isNotEmpty ? allHours.first : <String, dynamic>{},
    ) as Map<String, dynamic>;

    final nextHours = allHours
        .where((h) {
          final hr = h['hour'] as int;
          return hr > currentHour && hr <= currentHour + 3 && hr >= 6 && hr <= 23;
        })
        .take(3)
        .toList();

    final currentCls = currentData['classification'] as String? ?? 'neutral';
    final currentColor = _hourColor(currentCls, isDark);
    final currentLabel = _clsLabel(currentCls);
    final currentReason = currentData['reason'] as String? ?? '';
    final currentAction = currentData['best_action'] as String? ?? '';
    final currentGoodFor = (currentData['good_for'] as List? ?? []).cast<String>();
    final currentAvoid = (currentData['avoid'] as List? ?? []).cast<String>();

    final ch12 = currentHour == 0 ? 12 : currentHour > 12 ? currentHour - 12 : currentHour;
    final campm = currentHour < 12 ? 'AM' : 'PM';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label
        SectionLabel('Hour by Hour'),
        const SizedBox(height: 10),

        // ── Energy Wave ────────────────────────────────────────────────────
        AstroCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('ENERGY TODAY', style: GoogleFonts.dmSans(
                  fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
              const Spacer(),
              _Dot(color: isDark ? AppColors.successDark : AppColors.success), const SizedBox(width: 4),
              Text('Best', style: GoogleFonts.dmSans(fontSize: 8, color: secondary)),
              const SizedBox(width: 10),
              _Dot(color: const Color(0xFFF59E0B)), const SizedBox(width: 4),
              Text('Caution', style: GoogleFonts.dmSans(fontSize: 8, color: secondary)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: CustomPaint(
                size: const Size(double.infinity, 56),
                painter: _EnergyWavePainter(
                  hours: waking,
                  currentHour: currentHour,
                  gold: gold,
                  successColor: isDark ? AppColors.successDark : AppColors.success,
                  cautionColor: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['6a', '9a', '12p', '3p', '6p', '9p'].map((t) =>
                Text(t, style: GoogleFonts.dmSans(fontSize: 8, color: secondary.withOpacity(0.4)))
              ).toList()),
          ]),
        ),
        const SizedBox(height: 10),

        // ── B: Current hour — big card ───────────────────────────────────────
        GestureDetector(
          onTap: () => _HourStrip.showHourBottomSheet(context, currentData, isDark, gold),
          child: AstroCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('NOW  $ch12 $campm',
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1, color: gold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: currentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: currentColor.withOpacity(0.3), width: 0.5),
                  ),
                  child: Text(currentLabel,
                      style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700,
                          letterSpacing: 0.5, color: currentColor)),
                ),
              ]),
              const SizedBox(height: 10),
              if (currentReason.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: gold.withOpacity(0.4), width: 2))),
                  child: Text(currentReason,
                      style: GoogleFonts.dmSans(fontSize: 13, color: primary.withOpacity(0.85), height: 1.5)),
                ),
              if (currentAction.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.arrow_forward_ios, size: 11, color: gold),
                  const SizedBox(width: 6),
                  Expanded(child: Text(currentAction,
                      style: GoogleFonts.dmSans(fontSize: 12, color: primary.withOpacity(0.8),
                          fontWeight: FontWeight.w600, height: 1.4))),
                ]),
              ],
              if (currentGoodFor.isNotEmpty || currentAvoid.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (currentGoodFor.isNotEmpty) Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('GOOD FOR', style: GoogleFonts.dmSans(fontSize: 8,
                          color: (isDark ? AppColors.successDark : AppColors.success),
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      ...currentGoodFor.take(3).map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(padding: const EdgeInsets.only(top: 3),
                            child: Icon(Icons.check_circle_outline, size: 11,
                                color: isDark ? AppColors.successDark : AppColors.success)),
                          const SizedBox(width: 5),
                          Expanded(child: Text(g, style: GoogleFonts.dmSans(fontSize: 11,
                              color: primary.withOpacity(0.75), height: 1.4))),
                        ]),
                      )),
                    ]),
                  ),
                  if (currentAvoid.isNotEmpty) Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('AVOID', style: GoogleFonts.dmSans(fontSize: 8,
                          color: isDark ? AppColors.dangerDark : AppColors.danger,
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      ...currentAvoid.take(3).map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(padding: const EdgeInsets.only(top: 3),
                            child: Icon(Icons.cancel_outlined, size: 11,
                                color: isDark ? AppColors.dangerDark : AppColors.danger)),
                          const SizedBox(width: 5),
                          Expanded(child: Text(a, style: GoogleFonts.dmSans(fontSize: 11,
                              color: primary.withOpacity(0.75), height: 1.4))),
                        ]),
                      )),
                    ]),
                  ),
                ]),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 8),

        // ── Next 3 hours ────────────────────────────────────────────────────
        if (nextHours.length >= 2) Row(
          children: nextHours.map((h) {
            final hr  = h['hour'] as int;
            final cls = h['classification'] as String? ?? 'neutral';
            final reason = h['reason'] as String? ?? '';
            final action = h['best_action'] as String? ?? '';
            final clsColor = _hourColor(cls, isDark);
            final h12 = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
            final ampm = hr < 12 ? 'AM' : 'PM';
            return Expanded(
              child: GestureDetector(
                onTap: () => _HourStrip.showHourBottomSheet(context, h as Map<String, dynamic>, isDark, gold),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 0.5),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('$h12 $ampm', style: GoogleFonts.dmSans(
                          fontSize: 10, fontWeight: FontWeight.w700, color: gold)),
                      const Spacer(),
                      Container(width: 7, height: 7,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: clsColor.withOpacity(0.8))),
                    ]),
                    const SizedBox(height: 6),
                    Text(action.isNotEmpty ? action : reason,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(fontSize: 10,
                            color: primary.withOpacity(0.75), height: 1.4)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 2),

        // ── Day Blocks ────────────────────────────────────────────────────
        _DayBlocks(allHours: allHours, currentHour: currentHour, isDark: isDark, gold: gold),
      ],
    );
  }

  String _clsLabel(String cls) {
    switch (cls) {
      case 'best':    return 'BEST HOUR';
      case 'caution': return 'CAUTION';
      case 'avoid':   return 'AVOID';
      default:        return 'NEUTRAL';
    }
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 7, height: 7,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}


// ─── Today's Character Card ───────────────────────────────────────────────────
class _DayCharacterCard extends StatelessWidget {
  final List<dynamic> items;
  final bool isDark;
  final Color gold;
  const _DayCharacterCard({required this.items, required this.isDark, required this.gold});

  Color _tone(String t) {
    switch (t) {
      case 'good':   return isDark ? AppColors.successDark : AppColors.success;
      case 'gentle': return const Color(0xFFF59E0B);
      default:       return gold;
    }
  }
  IconData _icon(String c) {
    switch (c) {
      case 'phase':        return Icons.air;
      case 'personal':     return Icons.person_outline;
      case 'money':        return Icons.payments_outlined;
      case 'energy':       return Icons.bolt_outlined;
      case 'care':         return Icons.spa_outlined;
      case 'luck':         return Icons.auto_awesome_outlined;
      case 'relationship': return Icons.favorite_outline;
      default:             return Icons.wb_twilight_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final primary = items.first as Map<String, dynamic>;
    final rest = items.skip(1).toList();
    final textPrimary   = isDark ? AppColors.textPrimaryDark   : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final pTone = _tone(primary['tone'] as String? ?? 'neutral');

    return AstroCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("TODAY'S CHARACTER", style: GoogleFonts.dmSans(
            fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: gold)),
        const SizedBox(height: 14),

        // Primary characteristic — prominent
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pTone.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: pTone.withOpacity(0.18), width: 0.6),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: pTone.withOpacity(0.14), borderRadius: BorderRadius.circular(11)),
              child: Icon(_icon(primary['category'] as String? ?? 'core'), size: 20, color: pTone),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(primary['label'] as String? ?? '', style: GoogleFonts.dmSans(
                  fontSize: 15.5, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 3),
              Text(primary['text'] as String? ?? '', style: GoogleFonts.dmSans(
                  fontSize: 12.5, height: 1.45, color: textSecondary)),
            ])),
          ]),
        ),

        if (rest.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...rest.map((raw) {
            final c = raw as Map<String, dynamic>;
            final t = _tone(c['tone'] as String? ?? 'neutral');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: t.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_icon(c['category'] as String? ?? 'core'), size: 14, color: t),
                ),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['label'] as String? ?? '', style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 2),
                  Text(c['text'] as String? ?? '', style: GoogleFonts.dmSans(
                      fontSize: 11.5, height: 1.4, color: textSecondary)),
                ])),
              ]),
            );
          }),
        ],
      ]),
    );
  }
}

// ─── Day Score Card ───────────────────────────────────────────────────────────
class _DayScoreCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  const _DayScoreCard({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final score    = data['score'] as int? ?? 65;
    final label    = data['label'] as String? ?? 'Good day';
    final colorKey = data['color'] as String? ?? 'neutral';
    final goodFor  = (data['good_for'] as List? ?? []).cast<String>();
    final badFor   = (data['bad_for'] as List? ?? []).cast<String>();

    final primary   = isDark ? AppColors.textPrimaryDark  : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border    = isDark ? AppColors.borderDark : AppColors.borderLight;

    final Color scoreColor;
    switch (colorKey) {
      case 'success': scoreColor = isDark ? AppColors.successDark : AppColors.success;
      case 'good':    scoreColor = isDark ? AppColors.successDark : AppColors.success;
      case 'caution': scoreColor = const Color(0xFFF59E0B);
      case 'avoid':   scoreColor = isDark ? AppColors.dangerDark : AppColors.danger;
      default:        scoreColor = gold;
    }

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Score row
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$score', style: GoogleFonts.cormorantGaramond(
              fontSize: 52, fontWeight: FontWeight.w600,
              color: scoreColor, height: 1)),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('/100', style: GoogleFonts.dmSans(
                fontSize: 13, color: secondary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
          ])),
        ]),
        const SizedBox(height: 6),
        // Score bar
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 4,
            backgroundColor: border,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor.withOpacity(0.7)),
          ),
        ),
      ]),
    );
  }
}


// ─── Energy Wave Painter ──────────────────────────────────────────────────────
class _EnergyWavePainter extends CustomPainter {
  final List<dynamic> hours;
  final int currentHour;
  final Color gold, successColor, cautionColor;
  final bool isDark;

  const _EnergyWavePainter({
    required this.hours, required this.currentHour,
    required this.gold, required this.successColor,
    required this.cautionColor, required this.isDark,
  });

  // Color per hour classification
  Color _segColor(String cls) {
    switch (cls) {
      case 'best':    return successColor;
      case 'caution': return cautionColor;
      case 'avoid':   return const Color(0xFFDC2626);
      default:        return isDark ? const Color(0x33FFFFFF) : const Color(0x22000000);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (hours.isEmpty) return;
    final n = hours.length;
    final w = size.width;
    final h = size.height;

    double score(String cls) {
      switch (cls) {
        case 'best':    return 1.0;
        case 'caution': return 0.28;
        case 'avoid':   return 0.08;
        default:        return 0.55;
      }
    }

    // Build points
    final pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      final x = (i / (n - 1)) * w;
      final cls = (hours[i] as Map)['classification'] as String? ?? 'neutral';
      final y = h - score(cls) * (h * 0.82) - (h * 0.08);
      pts.add(Offset(x, y));
    }

    // Draw segment by segment — each with its own color
    for (int i = 0; i < n - 1; i++) {
      final cls  = (hours[i] as Map)['classification'] as String? ?? 'neutral';
      final c    = _segColor(cls);
      final cp1x = pts[i].dx + (pts[i + 1].dx - pts[i].dx) / 2;

      // Fill under segment
      final fill = Path()
        ..moveTo(pts[i].dx, h)
        ..lineTo(pts[i].dx, pts[i].dy)
        ..cubicTo(cp1x, pts[i].dy, cp1x, pts[i+1].dy, pts[i+1].dx, pts[i+1].dy)
        ..lineTo(pts[i+1].dx, h)
        ..close();
      canvas.drawPath(fill, Paint()..color = c.withOpacity(0.12));

      // Stroke
      final seg = Path()..moveTo(pts[i].dx, pts[i].dy);
      seg.cubicTo(cp1x, pts[i].dy, cp1x, pts[i+1].dy, pts[i+1].dx, pts[i+1].dy);
      canvas.drawPath(seg, Paint()
        ..color = c.withOpacity(0.8)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
    }

    // Dots at caution/avoid hours
    for (int i = 0; i < n; i++) {
      final cls = (hours[i] as Map)['classification'] as String? ?? 'neutral';
      if (cls == 'caution' || cls == 'avoid') {
        final c = _segColor(cls);
        canvas.drawCircle(pts[i], 4, Paint()..color = c);
        canvas.drawCircle(pts[i], 2.5, Paint()..color = Colors.white.withOpacity(0.85));
      }
    }

    // Current hour — dashed line + gold dot
    final curIdx = hours.indexWhere((h) => (h as Map)['hour'] == currentHour);
    if (curIdx >= 0) {
      final cx = curIdx == 0 ? 0.0 : (curIdx / (n - 1)) * w;
      final cy = pts[curIdx].dy;
      final dashPaint = Paint()..color = gold.withOpacity(0.55)..strokeWidth = 1;
      double y0 = 0;
      while (y0 < h) {
        canvas.drawLine(Offset(cx, y0), Offset(cx, (y0 + 4).clamp(0.0, h)), dashPaint);
        y0 += 8;
      }
      canvas.drawCircle(Offset(cx, cy), 5.5, Paint()..color = gold);
      canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_EnergyWavePainter old) => old.currentHour != currentHour;
}

// ─── Day Blocks ───────────────────────────────────────────────────────────────
class _DayBlocks extends StatefulWidget {
  final List<dynamic> allHours;
  final int currentHour;
  final bool isDark;
  final Color gold;
  const _DayBlocks({required this.allHours, required this.currentHour,
      required this.isDark, required this.gold});
  @override State<_DayBlocks> createState() => _DayBlocksState();
}

class _DayBlocksState extends State<_DayBlocks> {
  int? _openBlock;

  static const _blocks = [
    {'label': 'Morning',   'icon': 'M', 'start': 6,  'end': 11},
    {'label': 'Afternoon', 'icon': 'A', 'start': 12, 'end': 16},
    {'label': 'Evening',   'icon': 'E', 'start': 17, 'end': 20},
    {'label': 'Night',     'icon': 'N', 'start': 21, 'end': 23},
  ];

  Color _hourColor(String cls) {
    final isDark = widget.isDark;
    switch (cls) {
      case 'best':    return isDark ? AppColors.successDark : AppColors.success;
      case 'caution': return const Color(0xFFF59E0B);
      case 'avoid':   return isDark ? AppColors.dangerDark : AppColors.danger;
      default:        return isDark ? Colors.white30 : Colors.black26;
    }
  }

  String _blockSummary(List<dynamic> hours) {
    final best = hours.where((h) => h['classification'] == 'best').length;
    final total = hours.length;
    if (best == total) return 'All clear';
    if (best > total / 2) return 'Mostly good';
    if (best == 0) return 'Stay careful';
    return '$best of $total good';
  }

  Color _blockColor(List<dynamic> hours) {
    final best = hours.where((h) => h['classification'] == 'best').length;
    final total = hours.length;
    if (best > total / 2) return widget.isDark ? AppColors.successDark : AppColors.success;
    if (best == 0) return const Color(0xFFF59E0B);
    return widget.gold;
  }

  @override
  Widget build(BuildContext context) {
    final primary   = widget.isDark ? AppColors.textPrimaryDark  : AppColors.textPrimaryLight;
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border    = widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      children: List.generate(_blocks.length, (bi) {
        final block = _blocks[bi];
        final start = block['start'] as int;
        final end   = block['end']   as int;
        final blockHours = widget.allHours
            .where((h) { final hr = h['hour'] as int; return hr >= start && hr <= end; })
            .toList();
        if (blockHours.isEmpty) return const SizedBox.shrink();

        final isOpen    = _openBlock == bi;
        final hasNow    = widget.currentHour >= start && widget.currentHour <= end;
        final summary   = _blockSummary(blockHours);
        final blockColor = hasNow ? widget.gold : _blockColor(blockHours);

        return Column(children: [
          GestureDetector(
            onTap: () => setState(() => _openBlock = isOpen ? null : bi),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: hasNow ? widget.gold.withOpacity(0.4) : border,
                    width: hasNow ? 1.2 : 0.5),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasNow ? widget.gold.withOpacity(0.12) : border.withOpacity(0.4),
                    border: Border.all(
                      color: hasNow ? widget.gold.withOpacity(0.4) : border,
                      width: 0.8),
                  ),
                  child: Center(child: Text(block['icon'] as String,
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: hasNow ? widget.gold : secondary))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(block['label'] as String,
                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600,
                            color: primary)),
                    if (hasNow) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: widget.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('NOW', style: GoogleFonts.dmSans(
                            fontSize: 8, fontWeight: FontWeight.w700,
                            color: widget.gold, letterSpacing: 0.5)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(summary, style: GoogleFonts.dmSans(
                      fontSize: 11, color: blockColor)),
                ])),
                // Mini dots for each hour
                Row(children: blockHours.map((h) {
                  final cls = h['classification'] as String? ?? 'neutral';
                  final isNowHour = (h['hour'] as int) == widget.currentHour;
                  return Container(
                    width: 7, height: 7,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isNowHour ? widget.gold : _hourColor(cls).withOpacity(0.7),
                    ),
                  );
                }).toList()),
                const SizedBox(width: 8),
                Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16, color: secondary),
              ]),
            ),
          ),
          // Expanded hours
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: isOpen ? Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(children: blockHours.map((h) {
                final hr     = h['hour'] as int;
                final cls    = h['classification'] as String? ?? 'neutral';
                final action = h['best_action'] as String? ?? h['reason'] as String? ?? '';
                final isNow  = hr == widget.currentHour;
                final clr    = _hourColor(cls);
                final h12    = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
                final ampm   = hr < 12 ? 'AM' : 'PM';
                return GestureDetector(
                  onTap: () => _HourStrip.showHourBottomSheet(
                      context, h as Map<String, dynamic>, widget.isDark, widget.gold),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isNow
                          ? widget.gold.withOpacity(0.07)
                          : (widget.isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight),
                      borderRadius: BorderRadius.circular(10),
                      border: isNow ? Border.all(color: widget.gold.withOpacity(0.3), width: 0.8) : null,
                    ),
                    child: Row(children: [
                      SizedBox(width: 46, child: Text('$h12 $ampm',
                          style: GoogleFonts.dmSans(fontSize: 11,
                              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                              color: isNow ? widget.gold : secondary))),
                      Container(width: 6, height: 6,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: clr.withOpacity(0.8))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(action,
                          style: GoogleFonts.dmSans(fontSize: 11,
                              color: primary.withOpacity(isNow ? 0.9 : 0.75), height: 1.3))),
                      Icon(Icons.chevron_right, size: 13, color: secondary.withOpacity(0.3)),
                    ]),
                  ),
                );
              }).toList()),
            ) : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
        ]);
      }),
    );
  }
}


class _HourSummaryCard extends StatelessWidget {
  final List<dynamic> bestHours, cautionHours;
  final bool isDark;
  final Color gold;
  const _HourSummaryCard({required this.bestHours, required this.cautionHours,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final warningColor = const Color(0xFFF59E0B);
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Build all hour chips
    final bestChips = bestHours.take(4).map((h) =>
      _HourChip(hour: h['hour'] as int, color: successColor, isDark: isDark)).toList();
    final cautionChips = cautionHours.take(3).map((h) =>
      _HourChip(hour: h['hour'] as int, color: warningColor, isDark: isDark)).toList();

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Best hours row
        if (bestChips.isNotEmpty) Row(children: [
          Container(width: 5, height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: successColor)),
          const SizedBox(width: 6),
          Expanded(child: Wrap(spacing: 6, children:
            bestChips.map((c) => c).toList())),
        ]),
        if (bestChips.isNotEmpty && cautionChips.isNotEmpty) const SizedBox(height: 8),
        // Caution hours row
        if (cautionChips.isNotEmpty) Row(children: [
          Container(width: 5, height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: warningColor)),
          const SizedBox(width: 6),
          Expanded(child: Wrap(spacing: 6, children:
            cautionChips.map((c) => c).toList())),
        ]),
        const SizedBox(height: 4),
        Text('tap any hour below for detail',
            style: GoogleFonts.dmSans(fontSize: 9, color: secondary.withOpacity(0.45))),
      ]),
    );
  }
}

class _HourChip extends StatelessWidget {
  final int hour;
  final Color color;
  final bool isDark;
  const _HourChip({required this.hour, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h12 = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text('$h12 $ampm',
          style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}


// ─── 5. One action card ───────────────────────────────────────────────────────
class _OneActionCard extends StatelessWidget {
  final String? action, avoid;
  final bool isDark;
  final Color gold;
  const _OneActionCard({this.action, this.avoid, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TODAY\'S PRIORITY', style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: gold)),
          const SizedBox(height: 12),
          if (action != null) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.check, size: 10, color: successColor),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(action!,
                  style: GoogleFonts.dmSans(fontSize: 13, color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      height: 1.5))),
            ]),
          ],
          if (action != null && avoid != null) ...[
            const SizedBox(height: 10),
            Divider(color: border, thickness: 0.5),
            const SizedBox(height: 10),
          ],
          if (avoid != null) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: dangerColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.close, size: 10, color: dangerColor),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(avoid!,
                  style: GoogleFonts.dmSans(fontSize: 13, color: secondary, height: 1.5))),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─── 6. Full guidance card (expandable) ──────────────────────────────────────
class _GuidanceCard extends StatefulWidget {
  final List<String> toDo, avoid;
  final bool isDark;
  final Color gold;
  const _GuidanceCard({required this.toDo, required this.avoid,
      required this.isDark, required this.gold});

  @override
  State<_GuidanceCard> createState() => _GuidanceCardState();
}

class _GuidanceCardState extends State<_GuidanceCard> {

  @override
  Widget build(BuildContext context) {
    final successColor = widget.isDark ? AppColors.successDark : AppColors.success;
    final dangerColor  = widget.isDark ? AppColors.dangerDark  : AppColors.danger;
    final primary   = widget.isDark ? AppColors.textPrimaryDark  : AppColors.textPrimaryLight;
    final border    = widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    // Max 4 each, already trimmed by backend
    final dos    = widget.toDo.take(4).toList();
    final avoids = widget.avoid.take(4).toList();

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TODAY\'S GUIDANCE', style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: widget.gold)),
          const SizedBox(height: 12),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // DO column
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DO', style: GoogleFonts.dmSans(
                  fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: successColor)),
              const SizedBox(height: 8),
              ...dos.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.check, size: 11, color: successColor)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: primary.withOpacity(0.8), height: 1.5))),
                ]),
              )),
            ])),

            Container(width: 0.5, color: border, margin: const EdgeInsets.symmetric(horizontal: 10)),

            // AVOID column
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AVOID', style: GoogleFonts.dmSans(
                  fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: dangerColor)),
              const SizedBox(height: 8),
              ...avoids.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.close, size: 11, color: dangerColor)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: primary.withOpacity(0.8), height: 1.5))),
                ]),
              )),
            ])),
          ]),
        ],
      ),
    );
  }
}

// ─── 7. Active energy card ────────────────────────────────────────────────────
class _ActiveEnergyCard extends StatefulWidget {
  final List<dynamic> combos;
  final bool isDark;
  final Color gold;
  const _ActiveEnergyCard({required this.combos, required this.isDark, required this.gold});

  @override
  State<_ActiveEnergyCard> createState() => _ActiveEnergyCardState();
}

class _ActiveEnergyCardState extends State<_ActiveEnergyCard> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    final icons = {
      'Running Energy': Icons.bolt_outlined,
      'Monthly Energy': Icons.calendar_month_outlined,
      "Today's Drive": Icons.trending_up_outlined,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Active in Your Chart'),
        const SizedBox(height: 8),
        AstroCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: widget.combos.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value as Map<String, dynamic>;
              final name = c['name'] as String? ?? '';
              final desc = c['description'] as String? ?? '';
              final icon = icons[name] ?? Icons.circle_outlined;
              final isOpen = _expanded == i;

              return Column(
                children: [
                  if (i > 0) Divider(color: border, height: 16, thickness: 0.5),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = isOpen ? null : i),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                color: widget.gold.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, size: 14, color: widget.gold),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(name,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: widget.gold))),
                            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 14, color: secondary),
                          ]),
                          if (isOpen && desc.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(desc, style: GoogleFonts.dmSans(
                                fontSize: 12, color: secondary, height: 1.5)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── 8. Hour strip (clickable) ───────────────────────────────────────────────
class _HourStrip extends StatelessWidget {
  final List<dynamic> allHours, bestHours, cautionHours;
  final int currentHour;
  final bool isDark;
  final Color gold;

  const _HourStrip({required this.allHours, required this.bestHours,
      required this.cautionHours, required this.currentHour,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final warningColor = const Color(0xFFF59E0B);
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;

    final wakingHours = allHours.where((h) {
      final hr = h['hour'] as int;
      return hr >= 6 && hr <= 23;
    }).toList();

    final bestHourNums = bestHours.map((h) => h['hour'] as int).toSet();
    final cautionHourNums = cautionHours.map((h) => h['hour'] as int).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Hour by Hour'),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wakingHours.length,
            itemBuilder: (ctx, i) {
              final h = wakingHours[i] as Map<String, dynamic>;
              final hr = h['hour'] as int;
              final num = h['number'] as int;
              final isCurrent = hr == currentHour;
              final isBest = bestHourNums.contains(hr);
              final isCaution = cautionHourNums.contains(hr);

              Color dotColor = isDark ? Colors.white12 : Colors.black12;
              if (isBest) dotColor = successColor;
              else if (isCaution) dotColor = warningColor;

              final h12 = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
              final ampm = hr < 12 ? 'AM' : 'PM';

              return GestureDetector(
                onTap: () => _HourStrip.showHourBottomSheet(ctx, h, isDark, gold),
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (isBest ? successColor : gold).withOpacity(0.12)
                        : subtleBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? gold.withOpacity(0.5) : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$h12$ampm',
                          style: GoogleFonts.dmSans(fontSize: 8,
                              color: isCurrent ? gold : secondary)),
                      const SizedBox(height: 2),
                      Text('$num',
                          style: GoogleFonts.cormorantGaramond(
                              fontSize: 24,
                              color: isCurrent ? gold
                                  : (isDark ? Colors.white54 : Colors.black45),
                              height: 1)),
                      const SizedBox(height: 3),
                      Container(width: 6, height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: dotColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          _LegendDot(color: successColor, label: 'Best'),
          const SizedBox(width: 14),
          _LegendDot(color: warningColor, label: 'Watch'),
          const SizedBox(width: 14),
          Text('Tap any hour for detail',
              style: GoogleFonts.dmSans(fontSize: 10,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
        ]),
      ],
    );
  }

  static void showHourBottomSheet(BuildContext context, Map<String, dynamic> h, bool isDark, Color gold) {
    final hr = h['hour'] as int;
    final num = h['number'] as int;
    final classification = h['classification'] as String? ?? 'neutral';
    final reason = h['reason'] as String? ?? '';
    final goodFor = (h['good_for'] as List? ?? []).cast<String>();
    final avoidList = (h['avoid'] as List? ?? []).cast<String>();
    final bestAction = h['best_action'] as String?;
    final hourEssence = h['hour_essence'] as String?;
    final layers = (h['layers'] as List? ?? []).cast<Map<String, dynamic>>();

    final h12 = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
    final ampm = hr < 12 ? 'AM' : 'PM';

    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final warningColor = const Color(0xFFF59E0B);
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final bg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    Color statusColor;
    String statusLabel;
    switch (classification) {
      case 'best': statusColor = successColor; statusLabel = 'BEST HOUR';
      case 'caution': statusColor = warningColor; statusLabel = 'CAUTION';
      case 'avoid': statusColor = dangerColor; statusLabel = 'AVOID';
      default: statusColor = gold; statusLabel = 'NEUTRAL';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Handle
            Center(child: Container(width: 36, height: 3,
                decoration: BoxDecoration(
                    color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            // Hour + status
            Row(children: [
              Text('$h12 $ampm',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 32, color: gold, height: 1)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text(statusLabel,
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 0.5, color: statusColor)),
              ),
            ]),
            const SizedBox(height: 4),
            const SizedBox(height: 4),

            // Essence + reason
            if (hourEssence != null)
              Text(hourEssence.toUpperCase(),
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1, color: secondary)),
            if (hourEssence != null) const SizedBox(height: 6),
            if (reason.isNotEmpty) ...[
              Text(reason,
                  style: GoogleFonts.dmSans(fontSize: 14, color: primary, height: 1.5)),
              const SizedBox(height: 12),
            ],
            if (bestAction != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.bolt, size: 13, color: gold),
                  const SizedBox(width: 6),
                  Expanded(child: Text(bestAction,
                      style: GoogleFonts.dmSans(fontSize: 12, color: primary, height: 1.4))),
                ]),
              ),
              const SizedBox(height: 12),
            ],

            Divider(color: border, thickness: 0.5),
            const SizedBox(height: 12),

            // Good for
            if (goodFor.isNotEmpty) ...[
              Text('BEST FOR THIS HOUR',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1, color: successColor)),
              const SizedBox(height: 8),
              ...goodFor.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 5),
                      child: Container(width: 4, height: 4,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(g,
                      style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.4))),
                ]),
              )),
              const SizedBox(height: 12),
            ],

            // Avoid
            if (avoidList.isNotEmpty) ...[
              Text('AVOID THIS HOUR',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1, color: dangerColor)),
              const SizedBox(height: 8),
              ...avoidList.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 5),
                      child: Container(width: 4, height: 4,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a,
                      style: GoogleFonts.dmSans(fontSize: 13, color: secondary, height: 1.4))),
                ]),
              )),
            ],

            // 6-layer context
            if (layers.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: border, thickness: 0.5),
              const SizedBox(height: 10),
              Text('WHY THIS HOUR',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1, color: secondary)),
              const SizedBox(height: 8),
              ...layers.take(3).map((layer) {
                final src = layer['source'] as String? ?? '';
                final txt = layer['text'] as String? ?? '';
                final srcLabel = src == 'today' ? 'Today'
                    : src == 'period' ? 'Your period'
                    : src == 'chapter' ? 'Your chapter'
                    : src == 'natal' ? 'Your chart'
                    : src == 'yoga' ? 'Active yoga'
                    : 'Context';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(srcLabel,
                          style: GoogleFonts.dmSans(fontSize: 8, color: gold, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(txt,
                        style: GoogleFonts.dmSans(fontSize: 12, color: primary.withOpacity(0.8), height: 1.5))),
                  ]),
                );
              }),
            ],
          ],
          ),
          ),
        ),
      ),
    );
  }
}


class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
    ]);
  }
}

// ─── Layer row for DayCard expanded ──────────────────────────────────────────
class _LayerRow extends StatelessWidget {
  final String label, text;
  final Color secondary, gold;
  const _LayerRow(this.label, this.text, this.secondary, this.gold, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(label, style: GoogleFonts.dmSans(
              fontSize: 9, fontWeight: FontWeight.w600, color: gold)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.dmSans(
            fontSize: 11, color: secondary, height: 1.4))),
      ]),
    );
  }
}

// ─── Utility ──────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Could not load today\'s reading',
          style: GoogleFonts.dmSans(fontSize: 13, color: secondary)),
      const SizedBox(height: 16),
      GestureDetector(onTap: onRetry,
          child: Text('Try again', style: GoogleFonts.dmSans(fontSize: 13, color: gold))),
    ]));
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    return Center(child: Text('Complete your profile to begin',
        style: GoogleFonts.dmSans(fontSize: 13, color: gold)));
  }
}

// ─── Accident Warning Card ────────────────────────────────────────────────────
class _AccidentWarningCard extends StatelessWidget {
  final Map<String, dynamic>? dailyRisk;
  final List<Map<String, dynamic>> riskHours;
  final bool isDark;

  const _AccidentWarningCard({
    this.dailyRisk, required this.riskHours, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final warnColor = const Color(0xFFF59E0B);
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final isHighDaily = dailyRisk?['level'] == 'high';
    final accentColor = isHighDaily ? dangerColor : warnColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, size: 15, color: accentColor),
          const SizedBox(width: 8),
          Text('PHYSICAL CAUTION',
              style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1, color: accentColor)),
        ]),
        if (dailyRisk != null) ...[
          const SizedBox(height: 8),
          Text(dailyRisk!['reason'] as String? ?? '',
              style: GoogleFonts.dmSans(fontSize: 12, color: primary, height: 1.5)),
        ],
        if (riskHours.isNotEmpty) ...[
          const SizedBox(height: 10),
          Divider(color: border, height: 1, thickness: 0.5),
          const SizedBox(height: 8),
          Text('CAUTION WINDOWS TODAY',
              style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600,
                  letterSpacing: 0.8, color: secondary)),
          const SizedBox(height: 6),
          ...riskHours.map((h) {
            final isHigh = h['risk_level'] == 'high';
            final timeLabel = h['time_label'] as String? ?? '';
            final reason = h['reason'] as String? ?? '';
            final color = isHigh ? dangerColor : warnColor;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6, height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(child: RichText(text: TextSpan(children: [
                  TextSpan(text: '$timeLabel  ',
                      style: GoogleFonts.dmSans(fontSize: 12,
                          fontWeight: FontWeight.w600, color: color)),
                  TextSpan(text: reason,
                      style: GoogleFonts.dmSans(fontSize: 11,
                          color: secondary, height: 1.4)),
                ]))),
              ]),
            );
          }),
          const SizedBox(height: 6),
          Text('You will be notified 1 hour before each window.',
              style: GoogleFonts.dmSans(fontSize: 10,
                  color: secondary.withOpacity(0.6), fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }
}


// ─── Your Hours — expandable day-parts, every hour, tap for detail ────────────
class _HoursCard extends StatefulWidget {
  final List<dynamic> allHours;
  final int currentHour;
  final bool isDark;
  final Color gold;
  const _HoursCard({required this.allHours, required this.currentHour, required this.isDark, required this.gold});
  @override
  State<_HoursCard> createState() => _HoursCardState();
}

class _HoursCardState extends State<_HoursCard> {
  int? _open;

  static const _parts = [
    ['Morning', 6, 11], ['Afternoon', 12, 16], ['Evening', 17, 20], ['Night', 21, 23],
  ];
  static const _icons = [Icons.wb_twilight, Icons.light_mode_outlined, Icons.wb_twilight_outlined, Icons.dark_mode_outlined];

  @override
  void initState() {
    super.initState();
    final h = widget.currentHour;
    _open = h >= 12 && h <= 16 ? 1 : h >= 17 && h <= 20 ? 2 : h >= 21 && h <= 23 ? 3 : 0;
  }

  Color _c(String cls) {
    switch (cls) {
      case 'best':    return widget.isDark ? AppColors.successDark : AppColors.success;
      case 'caution': return const Color(0xFFF59E0B);
      default:        return widget.gold;
    }
  }
  String _word(String cls) => cls == 'best' ? 'Strong' : cls == 'caution' ? 'Low-key' : 'Steady';
  String _fmt(int h) => '${h == 0 ? 12 : (h > 12 ? h - 12 : h)} ${h < 12 ? 'AM' : 'PM'}';

  Map<String, dynamic>? _hourAt(int h) {
    for (final x in widget.allHours) { if (x['hour'] == h) return x as Map<String, dynamic>; }
    return null;
  }
  List<Map<String, dynamic>> _hoursIn(int a, int b) => widget.allHours
      .where((x) { final h = x['hour'] as int; return h >= a && h <= b; })
      .cast<Map<String, dynamic>>().toList();

  // Dominant colour for a part of the day
  Color _partColor(int a, int b) {
    final hrs = _hoursIn(a, b);
    if (hrs.any((h) => h['classification'] == 'best')) return _c('best');
    if (hrs.isNotEmpty && hrs.every((h) => h['classification'] == 'caution')) return _c('caution');
    return widget.gold;
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    final cls = data['classification'] as String? ?? 'neutral';
    final color = _c(cls);
    final action = data['best_action'] as String? ?? '';
    final goodFor = (data['good_for'] as List? ?? []).cast<String>();
    final avoid = (data['avoid'] as List? ?? []).cast<String>();
    final primary = widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final bg = widget.isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final hr = data['hour'] as int? ?? 0;

    showModalBottomSheet(
      context: context, backgroundColor: bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(
              color: secondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 18),
          Row(children: [
            Text(_fmt(hr), style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: primary)),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(_word(cls), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
          ]),
          if (action.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(action, style: GoogleFonts.dmSans(fontSize: 14, height: 1.5, color: primary.withOpacity(0.85))),
          ],
          if (goodFor.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('GOOD FOR', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
                color: widget.isDark ? AppColors.successDark : AppColors.success)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: goodFor.map((g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: (widget.isDark ? AppColors.successDark : AppColors.success).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(g, style: GoogleFonts.dmSans(fontSize: 12.5,
                  color: widget.isDark ? AppColors.successDark : AppColors.success)))).toList()),
          ],
          if (avoid.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('GO EASY ON', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
                color: const Color(0xFFF59E0B))),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: avoid.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(a, style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFFF59E0B))))).toList()),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary   = widget.isDark ? AppColors.textPrimaryDark  : AppColors.textPrimaryLight;
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border    = widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionLabel('Hour by Hour'),
      const SizedBox(height: 10),
      AstroCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: List.generate(_parts.length, (i) {
          final name = _parts[i][0] as String;
          final a = _parts[i][1] as int, b = _parts[i][2] as int;
          final hrs = _hoursIn(a, b);
          if (hrs.isEmpty) return const SizedBox.shrink();
          final isOpen = _open == i;
          final pColor = _partColor(a, b);

          return Column(children: [
            if (i != 0) Divider(height: 1, color: border, indent: 14, endIndent: 14),
            // Header
            InkWell(
              onTap: () => setState(() => _open = isOpen ? null : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(children: [
                  Icon(_icons[i], size: 19, color: pColor),
                  const SizedBox(width: 13),
                  Text(name, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: pColor)),
                  const Spacer(),
                  Text('${hrs.length} hrs', style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
                  const SizedBox(width: 6),
                  AnimatedRotation(turns: isOpen ? 0.5 : 0, duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.expand_more, size: 20, color: secondary)),
                ]),
              ),
            ),
            // Hours
            if (isOpen)
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 8, bottom: 8),
                child: Column(children: hrs.map((h) {
                  final hr = h['hour'] as int;
                  final cls = h['classification'] as String? ?? 'neutral';
                  final color = _c(cls);
                  final good = (h['good_for'] as List? ?? []).cast<String>();
                  final isNow = hr == widget.currentHour;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _showDetail(context, h),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        color: isNow ? widget.gold.withOpacity(0.06) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                        const SizedBox(width: 11),
                        SizedBox(width: 52, child: Text(_fmt(hr),
                            style: GoogleFonts.dmSans(fontSize: 12.5,
                                fontWeight: isNow ? FontWeight.w700 : FontWeight.w500, color: primary))),
                        if (isNow) ...[
                          Text('now ', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: widget.gold)),
                        ],
                        Expanded(child: Text(good.isNotEmpty ? good.first : 'steady',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(fontSize: 12, color: secondary))),
                        Icon(Icons.chevron_right, size: 15, color: secondary.withOpacity(0.4)),
                      ]),
                    ),
                  );
                }).toList()),
              ),
          ]);
        })),
      ),
    ]);
  }
}
