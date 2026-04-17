import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../auth/providers/user_provider.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final todayAsync = ref.watch(todayDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
    final currentHourData = data['current_hour_data'] as Map<String, dynamic>?;
    final nextBestHour = data['next_best_hour'] as Map<String, dynamic>?;
    final dailyNum = data['daily_number'] as int? ?? 0;

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

            // ── 4. Right now — current hour ──────────────────────
            _RightNowCard(
              currentHour: currentHour,
              currentHourData: currentHourData,
              nextBestHour: nextBestHour,
              isDark: isDark, gold: gold,
            ),
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
    if (h < 12) return 'Good morning, $first';
    if (h < 17) return 'Good afternoon, $first';
    if (h < 21) return 'Good evening, $first';
    return 'Good night, $first';
  }
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

// ─── 4. Right now card ────────────────────────────────────────────────────────
class _RightNowCard extends StatelessWidget {
  final int currentHour;
  final Map<String, dynamic>? currentHourData;
  final Map<String, dynamic>? nextBestHour;
  final bool isDark;
  final Color gold;

  const _RightNowCard({required this.currentHour, required this.currentHourData,
      required this.nextBestHour, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final warningColor = const Color(0xFFF59E0B);

    final type = currentHourData?['classification'] as String? ?? 'neutral';
    Color hourColor;
    IconData hourIcon;
    switch (type) {
      case 'best': hourColor = successColor; hourIcon = Icons.bolt;
      case 'caution': hourColor = warningColor; hourIcon = Icons.warning_amber_outlined;
      case 'avoid': hourColor = isDark ? AppColors.dangerDark : AppColors.danger; hourIcon = Icons.do_not_disturb_outlined;
      default: hourColor = gold; hourIcon = Icons.access_time;
    }

    final h12 = currentHour == 0 ? 12 : currentHour > 12 ? currentHour - 12 : currentHour;
    final ampm = currentHour < 12 ? 'AM' : 'PM';
    final reason = currentHourData?['reason'] as String? ?? '';
    final goodFor = (currentHourData?['good_for'] as List? ?? []).cast<String>();

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.radio_button_checked, size: 8, color: hourColor),
            const SizedBox(width: 6),
            Text('RIGHT NOW', style: GoogleFonts.dmSans(
                fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: hourColor)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: hourColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: hourColor.withOpacity(0.3), width: 0.5),
                ),
                child: Column(children: [
                  Text('$h12', style: GoogleFonts.cormorantGaramond(
                      fontSize: 28, color: hourColor, height: 1)),
                  Text(ampm, style: GoogleFonts.dmSans(fontSize: 9, color: hourColor)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reason.isNotEmpty)
                    Text(reason, style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
                  if (goodFor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Good for: ${goodFor.take(2).join(', ')}',
                        style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
                  ],
                ],
              )),
            ],
          ),

          // Next best hour
          if (nextBestHour != null) ...[
            const SizedBox(height: 12),
            Divider(color: border, thickness: 0.5),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.arrow_forward, size: 12, color: successColor),
              const SizedBox(width: 6),
              Text(_formatNextHour(nextBestHour!),
                  style: GoogleFonts.dmSans(fontSize: 12, color: secondary)),
            ]),
          ],
        ],
      ),
    );
  }

  String _formatNextHour(Map<String, dynamic> h) {
    final hr = h['hour'] as int;
    final h12 = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
    final ampm = hr < 12 ? 'AM' : 'PM';
    final reason = h['reason'] as String? ?? '';
    return 'Next: $h12 $ampm — $reason';
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

// ─── 8. Hour strip ────────────────────────────────────────────────────────────
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
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final subtleBg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;

    // Only waking hours
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
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wakingHours.length,
            itemBuilder: (_, i) {
              final h = wakingHours[i] as Map<String, dynamic>;
              final hr = h['hour'] as int;
              final num = h['number'] as int;
              final isCurrent = hr == currentHour;
              final isBest = bestHourNums.contains(hr);
              final isCaution = cautionHourNums.contains(hr);

              Color dotColor;
              if (isBest) dotColor = successColor;
              else if (isCaution) dotColor = warningColor;
              else dotColor = isDark ? Colors.white12 : Colors.black12;

              final h12 = hr == 0 ? 12 : hr > 12 ? hr - 12 : hr;
              final ampm = hr < 12 ? 'AM' : 'PM';

              return Container(
                width: 52,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (isBest ? successColor : gold).withOpacity(0.12)
                      : subtleBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? gold.withOpacity(0.5) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$h12$ampm',
                        style: GoogleFonts.dmSans(
                            fontSize: 8,
                            color: isCurrent ? gold : secondary)),
                    const SizedBox(height: 3),
                    Text('$num',
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 22,
                            color: isCurrent ? gold : (isDark ? Colors.white54 : Colors.black45),
                            height: 1)),
                    const SizedBox(height: 3),
                    Container(width: 6, height: 6,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
                  ],
                ),
              );
            },
          ),
        ),

        // Legend
        const SizedBox(height: 8),
        Row(children: [
          _LegendDot(color: successColor, label: 'Best'),
          const SizedBox(width: 14),
          _LegendDot(color: warningColor, label: 'Watch'),
        ]),
      ],
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
