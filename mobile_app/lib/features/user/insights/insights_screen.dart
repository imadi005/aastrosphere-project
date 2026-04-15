import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/today_provider.dart';
import '../../../core/numerology/numerology_engine.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg = isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;

    return Column(
      children: [
        Container(
          color: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight,
          child: TabBar(
            controller: _tab,
            labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
            labelColor: gold,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: gold,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 1.5,
            dividerColor: border,
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _DailyInsight(isDark: isDark, gold: gold),
              _PeriodInsight(period: 'weekly', isDark: isDark, gold: gold),
              _PeriodInsight(period: 'monthly', isDark: isDark, gold: gold),
              _PeriodInsight(period: 'yearly', isDark: isDark, gold: gold),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyInsight extends ConsumerWidget {
  final bool isDark;
  final Color gold;
  const _DailyInsight({required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayDataProvider);
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return todayAsync.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (_, __) => _retry(() => ref.refresh(todayDataProvider), isDark, gold),
      data: (data) {
        final daily = data['daily'] as int;
        final dailyPlanet = data['dailyPlanet'] as String;
        final rating = data['rating'] as String;
        final insight = data['insight'] as String;
        final hours = data['hours'] as List<dynamic>;
        final maha = data['maha'] as Map<String, dynamic>;
        final antar = data['antar'] as Map<String, dynamic>;

        DayRating r;
        switch (rating) {
          case 'favorable': r = DayRating.favorable;
          case 'avoid': r = DayRating.avoid;
          default: r = DayRating.caution;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Today\'s Energy'),
              const SizedBox(height: 8),
              AstroCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$daily',
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 64, fontWeight: FontWeight.w300,
                                color: gold, height: 1)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(dailyPlanet,
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                            const SizedBox(height: 4),
                            DayBadge(r),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(insight,
                        style: GoogleFonts.dmSans(fontSize: 13,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SectionLabel('Hourly Dasha'),
              const SizedBox(height: 8),
              _HourlyGrid(hours: hours, isDark: isDark, gold: gold),
              const SizedBox(height: 20),

              SectionLabel('Current Dasha'),
              const SizedBox(height: 8),
              _DashaCard(maha: maha, antar: antar, isDark: isDark, gold: gold),
            ],
          ),
        );
      },
    );
  }
}

class _HourlyGrid extends StatelessWidget {
  final List<dynamic> hours;
  final bool isDark;
  final Color gold;
  const _HourlyGrid({required this.hours, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    return AstroCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 6,
        runSpacing: 8,
        children: (hours).map((h) {
          final map = h as Map<String, dynamic>;
          final hour = map['hour'] as int;
          final num = map['number'] as int;
          final planet = map['planet'] as String;
          final isCurrent = hour == currentHour;
          final bg = isCurrent
              ? gold.withOpacity(0.15)
              : isDark ? AppColors.bgSubtleDark : AppColors.bgSubtleLight;
          final border = isCurrent ? gold.withOpacity(0.4)
              : isDark ? AppColors.borderDark : AppColors.borderLight;

          return Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Column(children: [
              Text(_fmt(hour),
                  style: GoogleFonts.dmSans(fontSize: 9,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
              const SizedBox(height: 3),
              Text('$num',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 20, color: isCurrent ? gold : isDark
                          ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text(planet.substring(0, planet.length > 3 ? 3 : planet.length),
                  style: GoogleFonts.dmSans(fontSize: 8,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  String _fmt(int h) {
    final ampm = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : h > 12 ? h - 12 : h;
    return '${h12}$ampm';
  }
}

class _DashaCard extends StatelessWidget {
  final Map<String, dynamic> maha, antar;
  final bool isDark;
  final Color gold;
  const _DashaCard({required this.maha, required this.antar,
      required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('${maha['number']}',
                  style: GoogleFonts.cormorantGaramond(fontSize: 20, color: gold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Maha Dasha', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
            Text(maha['planet'] as String, style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w500, color: primary)),
          ])),
          Text('${_yr(maha['start'] as String)}–${_yr(maha['end'] as String)}',
              style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
        ]),
        Divider(color: border, height: 20, thickness: 0.5),
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(
                  color: successColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('${antar['number']}',
                  style: GoogleFonts.cormorantGaramond(fontSize: 20, color: successColor)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Antar Dasha', style: GoogleFonts.dmSans(fontSize: 10, color: secondary)),
            Text(antar['planet'] as String, style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w500, color: primary)),
          ])),
          Text('${_mo(antar['start'] as String)}–${_mo(antar['end'] as String)}',
              style: GoogleFonts.dmSans(fontSize: 11, color: secondary)),
        ]),
      ]),
    );
  }

  String _yr(String iso) => DateTime.parse(iso).year.toString();
  String _mo(String iso) {
    final d = DateTime.parse(iso);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month-1]} ${d.year.toString().substring(2)}';
  }
}

// ─── Period Insight Tab (weekly/monthly/yearly) ───────────────
class _PeriodInsight extends ConsumerWidget {
  final String period;
  final bool isDark;
  final Color gold;
  const _PeriodInsight({required this.period, required this.isDark, required this.gold});

  // SAFE extractor for any type to string
  String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    if (value is Map) {
      // Try to find any string value in the map
      for (var v in value.values) {
        if (v is String && v.isNotEmpty) return v;
        if (v is int) return v.toString();
      }
      return '';
    }
    if (value is List) {
      if (value.isNotEmpty) return _safeToString(value.first);
      return '';
    }
    return value.toString();
  }

  // SAFE extractor for prediction field
  String _extractPrediction(dynamic pred) {
    if (pred == null) return '';
    if (pred is String) return pred;
    if (pred is Map) {
      // Check for common keys
      final possibleKeys = ['single', 'text', 'description', 'prediction', 'message', 'content'];
      for (var key in possibleKeys) {
        if (pred.containsKey(key)) {
          final value = pred[key];
          if (value is String && value.isNotEmpty) return value;
          if (value != null) return value.toString();
        }
      }
      // If no common keys, take the first non-null value
      for (var value in pred.values) {
        if (value != null) {
          if (value is String && value.isNotEmpty) return value;
          return value.toString();
        }
      }
      return '';
    }
    if (pred is List) {
      if (pred.isNotEmpty) return _extractPrediction(pred.first);
      return '';
    }
    return pred.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashaAsync = ref.watch(dashaInsightProvider);
    final financeAsync = ref.watch(financePredictionProvider);

    return dashaAsync.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: gold)),
      error: (error, stack) {
        print('ERROR in dashaInsightProvider: $error');
        print('Stack: $stack');
        return _retry(() => ref.refresh(dashaInsightProvider), isDark, gold);
      },
      data: (insight) {
        // Debug: Print the actual data structure
        print('INSIGHT DATA TYPE: ${insight.runtimeType}');
        print('INSIGHT KEYS: ${insight.keys}');
        
        // SAFE extraction - handle everything with try-catch
        Map<String, dynamic> maha = {};
        Map<String, dynamic> antar = {};
        
        try {
          final mahaRaw = insight['maha'];
          if (mahaRaw is Map<String, dynamic>) {
            maha = mahaRaw;
          } else if (mahaRaw is Map) {
            maha = Map<String, dynamic>.from(mahaRaw);
          }
          print('MAHA extracted successfully: ${maha.keys}');
        } catch (e) {
          print('Error extracting maha: $e');
        }
        
        try {
          final antarRaw = insight['antar'];
          if (antarRaw is Map<String, dynamic>) {
            antar = antarRaw;
          } else if (antarRaw is Map) {
            antar = Map<String, dynamic>.from(antarRaw);
          }
          print('ANTAR extracted successfully: ${antar.keys}');
        } catch (e) {
          print('Error extracting antar: $e');
        }
        
        // Extract values with safe defaults
        final mahaNumber = _safeToInt(maha['number']);
        final antarNumber = _safeToInt(antar['number']);
        
        final mahaPlanet = _safeToString(maha['planet']);
        final antarPlanet = _safeToString(antar['planet']);
        
        // Extract traits
        Map<String, dynamic> mahaTraits = {};
        Map<String, dynamic> antarTraits = {};
        
        final mahaTraitsRaw = maha['traits'];
        if (mahaTraitsRaw is Map) {
          mahaTraits = Map<String, dynamic>.from(mahaTraitsRaw);
        }
        
        final antarTraitsRaw = antar['traits'];
        if (antarTraitsRaw is Map) {
          antarTraits = Map<String, dynamic>.from(antarTraitsRaw);
        }
        
        // Extract keywords safely
        List<String> mahaKeywords = [];
        List<String> antarKeywords = [];
        
        final mahaKeywordsRaw = mahaTraits['keywords'];
        if (mahaKeywordsRaw is List) {
          mahaKeywords = mahaKeywordsRaw.whereType<String>().toList();
        }
        
        final antarKeywordsRaw = antarTraits['keywords'];
        if (antarKeywordsRaw is List) {
          antarKeywords = antarKeywordsRaw.whereType<String>().toList();
        }
        
        // Extract predictions safely
        final mahaPredictionRaw = maha['prediction'];
        final antarPredictionRaw = antar['prediction'];
        
        final mahaPrediction = _extractPrediction(mahaPredictionRaw);
        final antarPrediction = _extractPrediction(antarPredictionRaw);
        
        print('Maha prediction type: ${mahaPredictionRaw.runtimeType}');
        print('Antar prediction type: ${antarPredictionRaw.runtimeType}');

        String periodTitle;
        String periodDesc;
        switch (period) {
          case 'weekly':
            periodTitle = 'This Week';
            periodDesc = 'Antar Dasha $antarNumber ($antarPlanet) governs this week.';
            break;
          case 'monthly':
            periodTitle = 'This Month';
            periodDesc = 'Monthly Dasha aligns with Antar Dasha $antarNumber — $antarPlanet energy.';
            break;
          default:
            periodTitle = 'This Year';
            periodDesc = 'Maha Dasha $mahaNumber ($mahaPlanet) + Antar Dasha $antarNumber ($antarPlanet).';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(periodTitle),
              const SizedBox(height: 8),
              AstroCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  periodDesc,
                  style: GoogleFonts.dmSans(fontSize: 13, 
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, 
                    height: 1.6
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SectionLabel('Maha Dasha Energy'),
              const SizedBox(height: 8),
              _InsightBlock(
                number: mahaNumber,
                planet: mahaPlanet,
                prediction: mahaPrediction,
                keywords: mahaKeywords,
                color: gold,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              SectionLabel('Antar Dasha Energy'),
              const SizedBox(height: 8),
              _InsightBlock(
                number: antarNumber,
                planet: antarPlanet,
                prediction: antarPrediction,
                keywords: antarKeywords,
                color: isDark ? AppColors.successDark : AppColors.success,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              if (period == 'yearly')
                financeAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (finance) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      SectionLabel('Finance Outlook'),
                      const SizedBox(height: 8),
                      _FinanceBlock(data: finance, isDark: isDark, gold: gold),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class _InsightBlock extends StatelessWidget {
  final int number;
  final String planet;
  final String prediction;
  final List<String> keywords;
  final Color color;
  final bool isDark;
  
  const _InsightBlock({
    required this.number,
    required this.planet,
    required this.prediction,
    required this.keywords,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 38, 
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, color: color)
                )
              )
            ),
            const SizedBox(width: 12),
            Text(
              planet, 
              style: GoogleFonts.dmSans(
                fontSize: 15, 
                fontWeight: FontWeight.w500, 
                color: primary
              )
            ),
          ]),
          if (keywords.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, 
              runSpacing: 6,
              children: keywords.map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2), width: 0.5)
                ),
                child: Text(
                  k, 
                  style: GoogleFonts.dmSans(fontSize: 11, color: color)
                ),
              )).toList(),
            ),
          ],
          if (prediction.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              prediction,
              style: GoogleFonts.dmSans(
                fontSize: 12, 
                color: secondary, 
                height: 1.6
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinanceBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final Color gold;
  const _FinanceBlock({required this.data, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final positives = (data['positive_indicators'] as List<dynamic>?)?.cast<String>() ?? [];
    final negatives = (data['negative_indicators'] as List<dynamic>?)?.cast<String>() ?? [];
    final overall = data['overall'] as String? ?? 'mixed';
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.danger;

    Color overallColor;
    String overallText;
    switch (overall) {
      case 'favorable':
        overallColor = successColor; overallText = 'Favorable Period';
        break;
      case 'challenging':
        overallColor = dangerColor; overallText = 'Challenging Period';
        break;
      default:
        overallColor = gold; overallText = 'Mixed Period';
    }

    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: overallColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: overallColor.withOpacity(0.3), width: 0.5)
            ),
            child: Text(
              overallText,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500, 
                color: overallColor
              ),
            ),
          ),
          if (positives.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...positives.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 5, 
                    height: 5,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: successColor)
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p, 
                    style: GoogleFonts.dmSans(
                      fontSize: 12, 
                      color: secondary, 
                      height: 1.5
                    )
                  )
                ),
              ]),
            )),
          ],
          if (negatives.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...negatives.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 5, 
                    height: 5,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: dangerColor)
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    n, 
                    style: GoogleFonts.dmSans(
                      fontSize: 12, 
                      color: secondary, 
                      height: 1.5
                    )
                  )
                ),
              ]),
            )),
          ],
        ],
      ),
    );
  }
}

Widget _retry(VoidCallback onTap, bool isDark, Color gold) {
  final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Text(
          'Could not load', 
          style: GoogleFonts.dmSans(fontSize: 13, color: secondary)
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Try again', 
            style: GoogleFonts.dmSans(fontSize: 13, color: gold)
          )
        ),
      ]
    ),
  );
}