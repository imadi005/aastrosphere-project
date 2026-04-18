import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final todayAsync = ref.watch(todayDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Schedule notifications when data loads (once per day)
    todayAsync.whenData((data) {
      if (!_notificationsScheduled) {
        _notificationsScheduled = true;
        _scheduleNotifications(data);
      }
    });

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => const Center(child: Text('Error loading profile')),
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
          data: (data) => _TodayView(
            data: data, name: user.name, isDark: isDark,
            onRefresh: () async => ref.refresh(todayDataProvider),
          ),
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
    final quote = data['quote'] as String? ?? '';
    final insight = data['insight'] as String? ?? '';
    final toDo = (data['what_to_do'] as List? ?? []).cast<String>();
    final avoid = (data['what_to_avoid'] as List? ?? []).cast<String>();
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
              rating: rating, dailyNum: dailyNum,
              isDark: isDark, gold: gold,
            ),
            const SizedBox(height: 16),

            // ── 4. Best & Caution hours summary ─────────────────
            _HourSummaryCard(
              bestHours: bestHours,
              cautionHours: cautionHours,
              isDark: isDark, gold: gold,
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

            // ── 7. What's active in chart ────────────────────────
            if (comboYogas.isNotEmpty)
              _ActiveEnergyCard(combos: comboYogas, isDark: isDark, gold: gold),
            const SizedBox(height: 16),

            // ── 8. Hour strip ────────────────────────────────────
            _HourStrip(
              allHours: allHours,
              bestHours: bestHours,
              cautionHours: cautionHours,
              currentHour: currentHour,
              isDark: isDark, gold: gold,
            ),

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
  final int dailyNum;
  final bool isDark;
  final Color gold;
  const _DayCard({required this.quote, required this.insight, required this.rating,
      required this.dailyNum, required this.isDark, required this.gold});

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
      case 'avoid': ratingColor = widget.isDark ? AppColors.dangerDark : AppColors.danger; ratingLabel = 'CHALLENGING';
      default: ratingColor = widget.gold; ratingLabel = 'MIXED';
    }

    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating + number
          Row(
            children: [
              Text('${widget.dailyNum}',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 52, fontWeight: FontWeight.w300,
                      color: widget.gold, height: 1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ratingColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text(ratingLabel,
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 0.5, color: ratingColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quote
          if (widget.quote.isNotEmpty)
            Text('"${widget.quote}"',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 16, fontStyle: FontStyle.italic,
                    color: widget.gold, height: 1.5)),
          const SizedBox(height: 12),
          Divider(color: border, thickness: 0.5),
          const SizedBox(height: 10),

          // Insight
          Text(widget.insight,
              style: GoogleFonts.dmSans(fontSize: 13, color: primary, height: 1.65)),

          // Expand toggle
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(children: [
              Text(_expanded ? 'Show less' : 'What\'s happening in your chart',
                  style: GoogleFonts.dmSans(fontSize: 12, color: widget.gold)),
              const SizedBox(width: 4),
              Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 14, color: widget.gold),
            ]),
          ),

          // Expanded detail
          if (_expanded) ...[
            const SizedBox(height: 12),
            Divider(color: border, thickness: 0.5),
            const SizedBox(height: 10),
            Text(
              'Your chart today is a layered combination — the multi-year energy running, the year\'s chapter, this month\'s current, and today\'s frequency all interact. The rating above reflects the sum of those layers, not just one.',
              style: GoogleFonts.dmSans(fontSize: 12, color: secondary, height: 1.6, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── 4. Best & Caution hours summary ─────────────────────────────────────────
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

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best hours
          if (bestHours.isNotEmpty) ...[
            Row(children: [
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: successColor)),
              const SizedBox(width: 8),
              Text('BEST HOURS TODAY',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1, color: successColor)),
            ]),
            const SizedBox(height: 8),
            ...bestHours.take(3).map((h) {
              final hr = h['hour'] as int;
              final reason = h['reason'] as String? ?? '';
              final goodFor = (h['good_for'] as List? ?? []).cast<String>();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Text(_fmtHour(hr),
                      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
                          color: successColor)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    reason.isNotEmpty ? reason : goodFor.take(2).join(', '),
                    style: GoogleFonts.dmSans(fontSize: 12, color: secondary),
                  )),
                ]),
              );
            }),
          ],

          if (bestHours.isNotEmpty && cautionHours.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(color: border, height: 1, thickness: 0.5),
            const SizedBox(height: 8),
          ],

          // Caution hours
          if (cautionHours.isNotEmpty) ...[
            Row(children: [
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: warningColor)),
              const SizedBox(width: 8),
              Text('CAUTION HOURS',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1, color: warningColor)),
            ]),
            const SizedBox(height: 8),
            ...cautionHours.take(3).map((h) {
              final hr = h['hour'] as int;
              final reason = h['reason'] as String? ?? '';
              final avoidFor = (h['avoid'] as List? ?? []).cast<String>();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Text(_fmtHour(hr),
                      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
                          color: warningColor)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    reason.isNotEmpty ? reason : avoidFor.take(2).join(', '),
                    style: GoogleFonts.dmSans(fontSize: 12, color: secondary),
                  )),
                ]),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _fmtHour(int hr) {
    final h12 = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
    final ampm = hr < 12 ? 'AM' : 'PM';
    return '$h12 $ampm';
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
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final successColor = widget.isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = widget.isDark ? AppColors.dangerDark : AppColors.danger;
    final secondary = widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    // Show 2 by default, all when expanded
    final showDo = _expanded ? widget.toDo : widget.toDo.take(2).toList();
    final showAvoid = _expanded ? widget.avoid : widget.avoid.take(2).toList();

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('TODAY\'S GUIDANCE', style: GoogleFonts.dmSans(
                fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: widget.gold)),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Less' : 'More',
                  style: GoogleFonts.dmSans(fontSize: 11, color: widget.gold)),
            ),
          ]),
          const SizedBox(height: 14),

          // Two columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Do column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DO', style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1, color: successColor)),
                    const SizedBox(height: 8),
                    ...showDo.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: const EdgeInsets.only(top: 5),
                            child: Container(width: 4, height: 4,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: successColor))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item,
                            style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4))),
                      ]),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Avoid column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVOID', style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 1, color: dangerColor)),
                    const SizedBox(height: 8),
                    ...showAvoid.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: const EdgeInsets.only(top: 5),
                            child: Container(width: 4, height: 4,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item,
                            style: GoogleFonts.dmSans(fontSize: 11, color: secondary, height: 1.4))),
                      ]),
                    )),
                  ],
                ),
              ),
            ],
          ),
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
                onTap: () => _showHourDetail(ctx, h, isDark, gold),
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

  void _showHourDetail(BuildContext context, Map<String, dynamic> h, bool isDark, Color gold) {
    final hr = h['hour'] as int;
    final num = h['number'] as int;
    final classification = h['classification'] as String? ?? 'neutral';
    final reason = h['reason'] as String? ?? '';
    final goodFor = (h['good_for'] as List? ?? []).cast<String>();
    final avoidList = (h['avoid'] as List? ?? []).cast<String>();

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
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
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
            Text('Hourly number: $num',
                style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
            const SizedBox(height: 16),

            // Main reason
            if (reason.isNotEmpty) ...[
              Text(reason,
                  style: GoogleFonts.dmSans(fontSize: 14, color: primary, height: 1.5)),
              const SizedBox(height: 16),
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
          ],
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
