// Core numerology calculation engine
// All logic ported from web app (Saurabh Avasthi framework)

class NumerologyEngine {
  // Planet names mapped to numbers
  static const Map<int, String> planetNames = {
    1: 'Sun', 2: 'Moon', 3: 'Jupiter', 4: 'Rahu',
    5: 'Mercury', 6: 'Venus', 7: 'Ketu', 8: 'Saturn', 9: 'Mars',
  };

  // Mahadasha durations in years (number = years)
  static const Map<int, int> dashaDurations = {
    1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9,
  };

  // Monthly dasha durations in days
  static const Map<int, int> monthlyDurations = {
    1: 8, 2: 16, 3: 24, 4: 32, 5: 41,
    6: 49, 7: 57, 8: 65, 9: 73,
  };

  // Weekday values (0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat)
  static const Map<int, int> weekdayValues = {
    0: 1, 1: 2, 2: 9, 3: 5, 4: 3, 5: 6, 6: 8,
  };

  // Grid position map: number -> [row, col]
  static const Map<int, List<int>> numberPositionMap = {
    1: [0, 1], 2: [2, 0], 3: [0, 0], 4: [2, 2],
    5: [1, 2], 6: [1, 0], 7: [1, 1], 8: [2, 1], 9: [0, 2],
  };

  /// Reduce any number to single digit (1-9)
  static int reduceToSingle(int n) {
    while (n > 9) {
      n = n.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return n;
  }

  /// Sum digits of a string of digits
  static int sumDigits(String s) =>
      s.split('').map(int.parse).reduce((a, b) => a + b);

  /// Calculate Basic Number from day of birth
  static int basicNumber(int day) {
    final raw = sumDigits(day.toString());
    return raw > 9 ? reduceToSingle(raw) : raw;
  }

  /// Calculate Destiny Number from full DOB
  static int destinyNumber(DateTime dob) {
    final s = '${dob.day}${dob.month}${dob.year}';
    return reduceToSingle(sumDigits(s));
  }

  /// Supportive numbers (individual digits of day if day > 9 and not 10/20/30)
  static List<int> supportiveNumbers(int day) {
    if (day <= 9 || day == 10 || day == 20 || day == 30) return [];
    return day.toString().split('').map(int.parse).toList();
  }

  /// Calculate chart digits for the grid
  static List<int> chartDigits(DateTime dob) {
    final day = dob.day;
    final month = dob.month;
    final year = dob.year;
    final destiny = destinyNumber(dob);
    final basic = basicNumber(day);
    final supportive = supportiveNumbers(day);
    final yearLast2 = year % 100;

    final digits = [
      ...day.toString().split('').map(int.parse),
      ...month.toString().split('').map(int.parse),
      ...yearLast2.toString().padLeft(2, '0').split('').map(int.parse),
    ].where((d) => d != 0).toList();

    final result = [...digits, destiny];
    if (!(day <= 9 || day == 10 || day == 20 || day == 30)) {
      result.add(basic);
    }
    for (final s in supportive) {
      if (!result.contains(s)) result.add(s);
    }
    return result;
  }

  /// Get current Mahadasha
  static DashaResult currentMahadasha(DateTime dob) {
    final basic = basicNumber(dob.day);
    final cycle = _buildDashaCycle(basic);
    final today = DateTime.now();

    DateTime current = DateTime(dob.year, dob.month, dob.day);
    int index = 0;

    while (index < 200) {
      final dasha = cycle[index % 9];
      final duration = dashaDurations[dasha]!;
      final end = DateTime(current.year + duration, current.month, current.day);

      if (today.isAfter(current) && today.isBefore(end)) {
        return DashaResult(
          number: dasha,
          planet: planetNames[dasha]!,
          start: current,
          end: end,
        );
      }
      current = end;
      index++;
    }
    return DashaResult(number: basic, planet: planetNames[basic]!, start: today, end: today);
  }

  /// Get Mahadasha timeline (past + future)
  static List<DashaResult> mahadashaTimeline(DateTime dob, {int pastYears = 20, int futureYears = 50}) {
    final basic = basicNumber(dob.day);
    final cycle = _buildDashaCycle(basic);
    final today = DateTime.now();
    final results = <DashaResult>[];

    DateTime current = DateTime(dob.year, dob.month, dob.day);
    int index = 0;

    while (index < 200) {
      final dasha = cycle[index % 9];
      final duration = dashaDurations[dasha]!;
      final end = DateTime(current.year + duration, current.month, current.day);

      final startYear = current.year;
      if (startYear >= today.year - pastYears && startYear <= today.year + futureYears) {
        final isCurrent = today.isAfter(current) && today.isBefore(end);
        final isPast = end.isBefore(today);
        results.add(DashaResult(
          number: dasha,
          planet: planetNames[dasha]!,
          start: current,
          end: end,
          isCurrent: isCurrent,
          isPast: isPast,
        ));
      }

      if (startYear > today.year + futureYears) break;
      current = end;
      index++;
    }
    return results;
  }

  /// Get current Antardasha
  static DashaResult currentAntardasha(DateTime dob) {
    final basic = basicNumber(dob.day);
    final today = DateTime.now();
    final month = dob.month;
    final day = dob.day;

    final bdayThisYear = DateTime(today.year, month, day);
    final antarYear = today.isBefore(bdayThisYear) ? today.year - 1 : today.year;

    final weekday = DateTime(antarYear, month, day).weekday % 7;
    final weekdayVal = weekdayValues[weekday]!;
    final yearLast2 = antarYear % 100;

    final raw = basic + month + yearLast2 + weekdayVal;
    final antar = reduceToSingle(raw);

    return DashaResult(
      number: antar,
      planet: planetNames[antar]!,
      start: DateTime(antarYear, month, day),
      end: DateTime(antarYear + 1, month, day).subtract(const Duration(days: 1)),
      isCurrent: true,
    );
  }

  /// Get Antardasha timeline
  static List<DashaResult> antardashaTimeline(DateTime dob, {int pastYears = 5, int futureYears = 10}) {
    final basic = basicNumber(dob.day);
    final today = DateTime.now();
    final month = dob.month;
    final day = dob.day;
    final results = <DashaResult>[];

    for (int y = today.year - pastYears; y <= today.year + futureYears; y++) {
      final weekday = DateTime(y, month, day).weekday % 7;
      final weekdayVal = weekdayValues[weekday]!;
      final yearLast2 = y % 100;
      final raw = basic + month + yearLast2 + weekdayVal;
      final antar = reduceToSingle(raw);

      final start = DateTime(y, month, day);
      final end = DateTime(y + 1, month, day).subtract(const Duration(days: 1));
      final bdayThisYear = DateTime(today.year, month, day);
      final antarYear = today.isBefore(bdayThisYear) ? today.year - 1 : today.year;
      final isCurrent = y == antarYear;
      final isPast = end.isBefore(today) && !isCurrent;

      results.add(DashaResult(
        number: antar,
        planet: planetNames[antar]!,
        start: start,
        end: end,
        isCurrent: isCurrent,
        isPast: isPast,
      ));
    }
    return results;
  }

  /// Get current Monthly Dasha
  static DashaResult currentMonthlyDasha(DateTime dob) {
    final basic = basicNumber(dob.day);
    final today = DateTime.now();
    final month = dob.month;
    final day = dob.day;

    // Find this year's birthday
    final bdayThisYear = DateTime(today.year, month, day);
    final startPoint = today.isBefore(bdayThisYear)
        ? DateTime(today.year - 1, month, day)
        : bdayThisYear;

    final cycle = _buildDashaCycle(basic);
    DateTime current = startPoint;
    int index = 0;

    while (index < 100) {
      final dasha = cycle[index % 9];
      final durationDays = monthlyDurations[dasha]!;
      final end = current.add(Duration(days: durationDays));

      if (!today.isBefore(current) && today.isBefore(end)) {
        return DashaResult(
          number: dasha,
          planet: planetNames[dasha]!,
          start: current,
          end: end,
          isCurrent: true,
        );
      }
      current = end;
      index++;
    }
    return DashaResult(number: basic, planet: planetNames[basic]!, start: today, end: today);
  }

  /// Daily dasha number for a specific date
  static int dailyDasha(DateTime dob, DateTime date) {
    final basic = basicNumber(dob.day);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return reduceToSingle(basic + date.day + date.month);
  }

  /// Hourly dasha for a specific hour (0-23)
  static int hourlyDasha(DateTime dob, DateTime date, int hour) {
    final daily = dailyDasha(dob, date);
    return reduceToSingle(daily + hour + 1);
  }

  /// Build grid frequency map from chart digits + maha + antar
  static Map<int, int> buildFrequencyMap(
    DateTime dob, {
    int? mahaOverride,
    int? antarOverride,
  }) {
    final digits = chartDigits(dob);
    final maha = mahaOverride ?? currentMahadasha(dob).number;
    final antar = antarOverride ?? currentAntardasha(dob).number;
    final monthly = currentMonthlyDasha(dob).number;

    final map = <int, int>{};
    for (final d in digits) {
      if (d != 0) map[d] = (map[d] ?? 0) + 1;
    }

    // Add maha, antar, monthly
    map[maha] = (map[maha] ?? 0) + 1;
    if (antar != maha) map[antar] = (map[antar] ?? 0) + 1;
    map[monthly] = (map[monthly] ?? 0) + 1;

    return map;
  }

  /// Build 3x3 grid cells
  static List<List<GridCell>> buildGrid(
    DateTime dob, {
    int? mahaOverride,
    int? antarOverride,
    int? monthlyOverride,
  }) {
    final maha = mahaOverride ?? currentMahadasha(dob).number;
    final antar = antarOverride ?? currentAntardasha(dob).number;
    final monthly = monthlyOverride ?? currentMonthlyDasha(dob).number;
    final freqMap = buildFrequencyMap(dob, mahaOverride: maha, antarOverride: antar);

    final grid = List.generate(3, (_) => List.generate(3, (_) => const GridCell(number: 0, highlights: [])));

    freqMap.forEach((num, count) {
      final pos = numberPositionMap[num];
      if (pos == null) return;
      final row = pos[0];
      final col = pos[1];
      final highlights = <GridHighlight>[];
      if (num == maha) highlights.add(GridHighlight.maha);
      if (num == antar) highlights.add(GridHighlight.antar);
      if (num == monthly) highlights.add(GridHighlight.monthly);
      grid[row][col] = GridCell(
        number: num,
        count: count,
        highlights: highlights,
        planet: planetNames[num]!,
      );
    });

    return grid;
  }

  /// Day rating based on daily dasha and chart
  static DayRating getDayRating(DateTime dob, DateTime date) {
    final daily = dailyDasha(dob, date);
    final basic = basicNumber(dob.day);
    final destiny = destinyNumber(dob);
    final freqMap = buildFrequencyMap(dob);

    // Favorable: daily dasha aligns with basic or destiny
    if (daily == basic || daily == destiny) return DayRating.favorable;
    // Avoid: Rahu (4) or Saturn (8) daily without support
    if ((daily == 4 || daily == 8) && !freqMap.containsKey(daily)) {
      return DayRating.avoid;
    }
    // Caution: otherwise
    return DayRating.caution;
  }

  // Build ordered dasha cycle starting from basic number
  static List<int> _buildDashaCycle(int basic) {
    const all = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    final startIndex = all.indexOf(basic);
    return [...all.sublist(startIndex), ...all.sublist(0, startIndex)];
  }

  /// Compatibility score between two people (1-100)
  static CompatibilityResult compatibility(DateTime dob1, DateTime dob2) {
    final basic1 = basicNumber(dob1.day);
    final basic2 = basicNumber(dob2.day);
    final destiny1 = destinyNumber(dob1);
    final destiny2 = destinyNumber(dob2);
    final maha1 = currentMahadasha(dob1).number;
    final maha2 = currentMahadasha(dob2).number;
    final freq1 = buildFrequencyMap(dob1);
    final freq2 = buildFrequencyMap(dob2);

    // Basic number compatibility (0-30 points)
    int basicScore = _basicCompatScore(basic1, basic2);

    // Destiny compatibility (0-25 points)
    int destinyScore = _basicCompatScore(destiny1, destiny2);
    destinyScore = (destinyScore * 25 / 30).round();

    // Current dasha compatibility (0-25 points)
    int dashaScore = _dashaCompatScore(maha1, maha2);

    // Grid overlap (0-20 points)
    int overlapScore = _gridOverlapScore(freq1, freq2);

    final total = (basicScore + destinyScore + dashaScore + overlapScore).clamp(0, 100);

    return CompatibilityResult(
      score: total,
      basicScore: basicScore,
      destinyScore: destinyScore,
      dashaScore: dashaScore,
      overlapScore: overlapScore,
      label: _compatLabel(total),
      description: _compatDescription(total),
    );
  }

  static int _basicCompatScore(int a, int b) {
    const compatible = {
      1: [1, 3, 5, 9], 2: [2, 4, 6, 8], 3: [3, 6, 9],
      4: [2, 4, 8], 5: [1, 5, 7], 6: [3, 6, 9],
      7: [5, 7], 8: [2, 4, 8], 9: [3, 6, 9],
    };
    const neutral = {
      1: [2, 4, 6], 2: [1, 3, 7], 3: [1, 5, 8],
      4: [6, 7], 5: [3, 8, 9], 6: [2, 4, 8],
      7: [2, 4, 8], 8: [5, 6], 9: [1, 5],
    };
    if (compatible[a]?.contains(b) ?? false) return 30;
    if (neutral[a]?.contains(b) ?? false) return 18;
    return 8;
  }

  static int _dashaCompatScore(int maha1, int maha2) {
    if (maha1 == maha2) return 22;
    return _basicCompatScore(maha1, maha2) ~/ 30 * 25 + 5;
  }

  static int _gridOverlapScore(Map<int, int> f1, Map<int, int> f2) {
    int overlap = 0;
    for (final k in f1.keys) {
      if (f2.containsKey(k)) overlap++;
    }
    return (overlap * 4).clamp(0, 20);
  }

  static String _compatLabel(int score) {
    if (score >= 85) return 'Soul connection';
    if (score >= 72) return 'Harmonious';
    if (score >= 58) return 'Growth oriented';
    if (score >= 44) return 'Karmic teachers';
    return 'Challenging';
  }

  static String _compatDescription(int score) {
    if (score >= 85) return 'Deep alignment across numbers and periods. Rare bond.';
    if (score >= 72) return 'Strong foundation. Friction exists but growth is mutual.';
    if (score >= 58) return 'Different energies. Learning happens through each other.';
    if (score >= 44) return 'Intense connection. Requires conscious effort from both.';
    return 'Fundamentally different paths. Growth possible but not easy.';
  }
}

// Data classes

class DashaResult {
  final int number;
  final String planet;
  final DateTime start;
  final DateTime end;
  final bool isCurrent;
  final bool isPast;

  const DashaResult({
    required this.number,
    required this.planet,
    required this.start,
    required this.end,
    this.isCurrent = false,
    this.isPast = false,
  });
}

class GridCell {
  final int number;
  final int count;
  final List<GridHighlight> highlights;
  final String planet;

  const GridCell({
    required this.number,
    this.count = 1,
    required this.highlights,
    this.planet = '',
  });

  bool get isEmpty => number == 0;
  bool get isMaha => highlights.contains(GridHighlight.maha);
  bool get isAntar => highlights.contains(GridHighlight.antar);
  bool get isMonthly => highlights.contains(GridHighlight.monthly);
}

enum GridHighlight { maha, antar, monthly }

enum DayRating { favorable, caution, avoid }

class CompatibilityResult {
  final int score;
  final int basicScore;
  final int destinyScore;
  final int dashaScore;
  final int overlapScore;
  final String label;
  final String description;

  const CompatibilityResult({
    required this.score,
    required this.basicScore,
    required this.destinyScore,
    required this.dashaScore,
    required this.overlapScore,
    required this.label,
    required this.description,
  });
}
