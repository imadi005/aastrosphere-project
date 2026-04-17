// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE PREDICTION ENGINE
// Takes full chart → generates human-readable predictions at every time scale
// ═══════════════════════════════════════════════════════════════════════════════

import {
  NUMBER_ENERGY, COMBINATION_MEANINGS, DASHA_COMBO_PREDICTIONS,
  DAILY_QUOTES, DAILY_GUIDANCE, HOUR_QUALITIES, COMBO_DAILY_INSIGHTS,
  PERIOD_PREDICTIONS, LIFE_PREDICTIONS, CHART_MODIFIERS, PREDICTION_LOGIC,
} from './prediction_library.js';

import {
  DEEP_NUMBER_PROFILES, DEEP_COMBINATIONS, DEEP_COMBINATIONS_EXTENDED,
  DEEP_DASHA_EXPERIENCE, DEEP_PERIOD_TEXTS, HONEST_WARNINGS, PERSONAL_PATTERNS,
} from './deep_library.js';

import {
  basicNumber, destinyNumber, currentMahadasha, currentAntardasha,
  currentMonthlyDasha, dailyDasha, hourlyDasha, allHourlyDashas,
  buildFrequencyMap, PLANET_NAMES, WEEKDAY_VALUES, reduceToSingle,
} from './numerology.js';

// ─── Deep library lookup ─────────────────────────────────────────────────────
export function getDeepCombination(a, b) {
  const key = [a, b].sort((x,y) => x-y).join('_');
  return DEEP_COMBINATIONS[key] || DEEP_COMBINATIONS_EXTENDED[key] || null;
}

export function getPersonalPattern(basic, destiny) {
  const key = `${basic}_${destiny}`;
  const rev = `${destiny}_${basic}`;
  return PERSONAL_PATTERNS[key] || PERSONAL_PATTERNS[rev] || null;
}

export function getDashaExperience(mahaNum) {
  return DEEP_DASHA_EXPERIENCE[`maha_${mahaNum}`] || null;
}

export function getDeepNumberProfile(num) {
  return DEEP_NUMBER_PROFILES[num] || null;
}

export function getHonestWarnings(yogas, freqMap, maha, antar) {
  const warnings = [];
  const yogaIds = yogas.map(y => y.id);

  if (yogaIds.includes('financial_bandhan')) warnings.push(HONEST_WARNINGS.financial_bandhan_active);
  if (yogaIds.includes('bandhan')) warnings.push(HONEST_WARNINGS.bandhan_yoga_active);
  if (yogaIds.includes('defamation_risk')) warnings.push(HONEST_WARNINGS.defamation_risk_active);

  const freq7 = freqMap[7] || 0;
  const freq9 = freqMap[9] || 0;
  const freq4 = freqMap[4] || 0;
  if (freq7 >= 2) warnings.push(HONEST_WARNINGS.multiple_7_active);
  if (freq9 >= 2) warnings.push(HONEST_WARNINGS.multiple_9_active);
  if (freq4 >= 2) warnings.push(HONEST_WARNINGS.double_4_active);

  // Early Maha 8 (years 1-4)
  if (maha === 8) warnings.push(HONEST_WARNINGS.maha_8_early);

  return warnings;
}

export function getDeepPeriodText(maha, antar, period) {
  const key = `${maha}_${antar}`;
  const revKey = `${antar}_${maha}`;
  const periodData = DEEP_PERIOD_TEXTS[period];
  if (!periodData) return null;
  return periodData[key] || periodData[revKey] || null;
}

// ─── Text cleaning utility ───────────────────────────────────────────────────
function cleanText(text) {
  if (!text) return '';
  return text
    // Remove "X meets Y —" planet combo headers
    .replace(/\b\w+ meets \w+ —\s*/gi, '')
    // Remove "without number X" phrases
    .replace(/without number \d+\.?/gi, '')
    // Remove all planet names
    .replace(/\b(Sun|Moon|Jupiter|Rahu|Mercury|Venus|Ketu|Saturn|Mars)\b/g, '')
    // Remove "Double/Triple X lifts/worsens" style sentences
    .replace(/\b(Double|Triple|Single|Odd|Even)\s+\d+[^.!]*[.!]/gi, '')
    // Remove "number X" references
    .replace(/\bnumber\s+\d+\b/gi, '')
    // Remove "combination" word and "misfortune" when standalone
    .replace(/\bcombination\b/gi, '')
    .replace(/^misfortune\s+/i, '')
    // Clean up "despite ." leftover → just remove it cleanly
    .replace(/despite\s+\./gi, '.')
    // Clean up orphaned punctuation and spaces
    .replace(/\s+\./g, '.')
    .replace(/\.\s*\./g, '.')
    .replace(/\s*—\s*$/, '')
    .replace(/^[—\s]+/, '')
    .replace(/\s{2,}/g, ' ')
    .trim();
}

// ─── Build complete chart context ────────────────────────────────────────────
export function buildChartContext(dob, targetDate = new Date().toISOString()) {
  const d = new Date(dob);
  const basic   = basicNumber(d.getDate());
  const destiny = destinyNumber(dob);
  const maha    = currentMahadasha(dob);
  const antar   = currentAntardasha(dob);
  const monthly = currentMonthlyDasha(dob);
  const daily   = dailyDasha(dob, targetDate);
  const hours   = allHourlyDashas(dob, targetDate);

  // TWO separate frequency maps:
  // natalFreq  = only DOB digits (no dasha numbers) — for absence-condition yogas
  // annualFreq = DOB + Maha + Antar + Monthly — for presence-condition yogas
  const natalFreq  = buildFrequencyMap(dob, undefined, undefined, undefined, true);
  const annualFreq = buildFrequencyMap(dob, maha.number, antar.number, monthly.number);

  const natalNums  = Object.keys(natalFreq).map(Number);
  const annualNums = Object.keys(annualFreq).map(Number);

  const yogas     = detectYogas(natalNums, annualNums, natalFreq, annualFreq, basic, destiny, maha.number, antar.number, monthly.number, dailyDasha(dob, targetDate));
  const modifiers = getChartModifiers(annualNums, annualFreq, basic, destiny);

  return {
    basic, destiny,
    maha: maha.number, antar: antar.number, monthly: monthly.number,
    daily, hours,
    freqMap: annualFreq, natalFreq,
    allNums: annualNums, natalNums,
    yogas, modifiers,
    mahaDetails: maha, antarDetails: antar, monthlyDetails: monthly,
    _dob: dob, // for period processing
  };
}

// ─── Detect all active yogas ─────────────────────────────────────────────────
// natalNums  = DOB digits only   → used for absence conditions
// annualNums = DOB + Maha + Antar → used for presence conditions
function detectYogas(natalNums, annualNums, natalFreq, annualFreq, basic, destiny, maha = 0, antar = 0, monthly = 0, daily = 0) {
  const yogas = [];

  // ── RAJ YOGA (1+2) ────────────────────────────────────────────────────────
  // Condition: 1 and 2 both in annual chart
  //            AND left-path of 1 must be clear in NATAL chart:
  //            3 (left of 1 in grid) must be absent
  //            AND 6 (below 3, above 2) must be absent
  if (annualNums.includes(1) && annualNums.includes(2)) {
    const leftPathClear = !natalNums.includes(3) && !natalNums.includes(6);
    if (leftPathClear) {
      const isStrong = destiny === 1 || destiny === 2 || basic === 2;
      yogas.push({
        id: 'raj_yoga',
        name: isStrong ? 'Strong Raj Yoga' : 'Raj Yoga',
        positive: true,
      });
    }
    // If path is blocked — no Raj Yoga, don't push anything
  }

  // ── SUN-KETU RAJ YOGA (1+7 without 8) ────────────────────────────────────
  // Absence of 8 checked against NATAL only (Maha 8 should not cancel this)
  if (natalNums.includes(1) && natalNums.includes(7) && !natalNums.includes(8)) {
    yogas.push({ id: 'sun_ketu_raj', name: 'Continuous Luck', positive: true });
  }

  // ── EASY MONEY (5+7) ──────────────────────────────────────────────────────
  // Can be triggered by annual chart (Dasha bringing 5 or 7 is valid)
  if (annualNums.includes(5) && annualNums.includes(7)) {
    yogas.push({ id: 'easy_money', name: 'Easy Money', positive: true });
  }

  // ── BANDHAN YOGA (9+4 without 5) ──────────────────────────────────────────
  // 5 is the grid blocker between 9 and 4 — check natal for absence of 5
  if (natalNums.includes(9) && natalNums.includes(4) && !natalNums.includes(5)) {
    yogas.push({ id: 'bandhan', name: 'Constraint Energy', positive: false });
  }

  // ── FINANCIAL BANDHAN (5+4 without 9) ─────────────────────────────────────
  // Check natal — Dasha bringing 9 should not cancel a natal financial bandhan
  if (natalNums.includes(5) && natalNums.includes(4) && !natalNums.includes(9)) {
    yogas.push({ id: 'financial_bandhan', name: 'Financial Caution', positive: false });
  }

  // ── VIPREET RAJ (2+8+4) ───────────────────────────────────────────────────
  // Annual chart — Dasha can trigger this
  if (annualNums.includes(2) && annualNums.includes(8) && annualNums.includes(4)) {
    yogas.push({ id: 'vipreet_raj', name: 'Adversity to Triumph', positive: true });
  }

  // ── 3-1-9 UPLIFTING ───────────────────────────────────────────────────────
  // Annual chart — Dasha can add the missing number
  if (annualNums.includes(3) && annualNums.includes(1) && annualNums.includes(9)) {
    yogas.push({ id: 'uplifting_319', name: 'Full Power Triad', positive: true });
  }

  // ── SPIRITUAL (3+7+9) ─────────────────────────────────────────────────────
  if (annualNums.includes(3) && annualNums.includes(7) && annualNums.includes(9)) {
    yogas.push({ id: 'spiritual', name: 'Spiritual Alignment', positive: true });
  }

  // ── STABLE LUXURY (6+7+5) ─────────────────────────────────────────────────
  if (annualNums.includes(6) && annualNums.includes(7) && annualNums.includes(5)) {
    yogas.push({ id: 'stable_luxury', name: 'Stable Luxury', positive: true });
  }

  // ── HIGH INTUITION (1+7+8) ────────────────────────────────────────────────
  // All three must be in annual chart
  if (annualNums.includes(1) && annualNums.includes(7) && annualNums.includes(8)) {
    yogas.push({ id: 'high_intuition', name: 'High Intuition', positive: true });
  }

  // ── DEFAMATION RISK (1+8 without 7) ──────────────────────────────────────
  // Absence of 7 checked against NATAL only
  if (natalNums.includes(1) && natalNums.includes(8) && !natalNums.includes(7)) {
    yogas.push({ id: 'defamation_risk', name: 'Reputation Caution', positive: false });
  }

  // ── MISFORTUNE (7+8 without 1) ────────────────────────────────────────────
  // Absence of 1 checked against NATAL only
  if (natalNums.includes(7) && natalNums.includes(8) && !natalNums.includes(1)) {
    yogas.push({ id: 'misfortune_78', name: 'Heavy Energy Period', positive: false });
  }

  // ── MAHA + ANTAR PAIR COMBINATIONS ───────────────────────────────────────
  // These fire based on what the two running dashas create together
  // Uses sorted key so 9_5 and 5_9 both match '5_9'
  const mahAntarKey = [maha, antar].sort((a,b)=>a-b).join('_');
  if (COMBINATION_MEANINGS[mahAntarKey]) {
    yogas.push({
      id: 'maha_antar_combo',
      combo_key: mahAntarKey,
      name: 'Running Energy',
      positive: true, // neutral — just informational
      description: cleanText(COMBINATION_MEANINGS[mahAntarKey]),
    });
  }

  // ── ANTAR + MONTHLY PAIR ───────────────────────────────────────────────────
  const antarMonthlyKey = [antar, monthly].sort((a,b)=>a-b).join('_');
  if (antarMonthlyKey !== mahAntarKey && COMBINATION_MEANINGS[antarMonthlyKey]) {
    yogas.push({
      id: 'antar_monthly_combo',
      combo_key: antarMonthlyKey,
      name: 'Monthly Energy',
      positive: true,
      description: cleanText(COMBINATION_MEANINGS[antarMonthlyKey]),
    });
  }

  // ── MAHA + DAILY PAIR ──────────────────────────────────────────────────────
  const mahaDailyKey = [maha, daily].sort((a,b)=>a-b).join('_');
  if (COMBINATION_MEANINGS[mahaDailyKey]) {
    yogas.push({
      id: 'maha_daily_combo',
      combo_key: mahaDailyKey,
      name: "Today's Drive",
      positive: true,
      description: cleanText(COMBINATION_MEANINGS[mahaDailyKey]),
    });
  }

  return yogas;
}

// ─── Get chart modifiers ─────────────────────────────────────────────────────
function getChartModifiers(nums, freq, basic, destiny) {
  const mods = [];
  if (nums.includes(3) && nums.includes(1) && nums.includes(9)) mods.push('has_319');
  if (nums.includes(6) && nums.includes(7) && nums.includes(5)) mods.push('has_675');
  if (nums.includes(2) && nums.includes(8) && nums.includes(4)) mods.push('has_284');
  if (nums.includes(1) && nums.includes(7) && nums.includes(8)) mods.push('has_178');
  if (nums.includes(1) && nums.includes(2)) mods.push('has_raj_yoga');
  if (nums.includes(5) && nums.includes(7)) mods.push('has_easy_money');
  if (nums.includes(9) && nums.includes(4) && !nums.includes(5)) mods.push('has_bandhan');
  if (nums.includes(5) && nums.includes(4) && !nums.includes(9)) mods.push('has_financial_bandhan');
  if (nums.includes(3) && nums.includes(7) && nums.includes(9)) mods.push('has_spiritual_379');
  if ((freq[2] || 0) >= 2) mods.push('multiple_2');
  if ((freq[4] || 0) >= 2 && (freq[4] % 2 !== 0)) mods.push('multiple_4_odd');
  if ((freq[4] || 0) >= 2 && (freq[4] % 2 === 0)) mods.push('multiple_4_even');
  if ((freq[7] || 0) >= 2) mods.push('multiple_7');
  if ((freq[8] || 0) >= 2 && (freq[8] % 2 === 0)) mods.push('multiple_8_even');
  if ((freq[8] || 0) >= 2 && (freq[8] % 2 !== 0)) mods.push('multiple_8_odd');
  if ((freq[9] || 0) >= 2) mods.push('multiple_9');
  if ((freq[1] || 0) > 1 && destiny !== 1) mods.push('multiple_1_no_destiny');
  return mods;
}

// ─── Generate daily prediction ────────────────────────────────────────────────
export function generateDailyPrediction(ctx) {
  const { basic, destiny, maha, antar, monthly, daily, yogas, freqMap, allNums } = ctx;

  // Pick quote based on daily number + chart energy
  const quotes = DAILY_QUOTES[daily];
  const quoteIndex = (basic + destiny + maha + antar) % quotes.length;
  const quote = quotes[quoteIndex];

  // Get dasha combo prediction
  const comboKey = `${maha}_${antar}`;
  const comboText = DASHA_COMBO_PREDICTIONS[comboKey] || '';

  // Build what-to-do list based on daily number
  const guidance = DAILY_GUIDANCE[daily];
  const doList = guidance.do;
  const avoidList = guidance.avoid;

  // Yoga-specific insight
  const yogaInsights = [];
  for (const yoga of yogas) {
    const yogaData = COMBO_DAILY_INSIGHTS[yoga.id];
    if (yogaData) {
      const text = yoga.positive
        ? (yogaData.favorable || yogaData.active)
        : (yogaData.active || yogaData.advice);
      if (text) yogaInsights.push(text);
    }
  }

  // Build main insight paragraph combining everything
  const dailyEnergy = NUMBER_ENERGY[daily];
  const mahaEnergy = NUMBER_ENERGY[maha];
  const antarEnergy = NUMBER_ENERGY[antar];

  // Combination context
  const mainCombo = `${maha}_${antar}`;
  const comboMeaning = COMBINATION_MEANINGS[mainCombo] || '';

  // Assess overall day rating
  const rating = assessDayRating(daily, maha, antar, yogas, freqMap);

  // Build full insight
  const insight = buildDailyInsight({
    daily, maha, antar, monthly, basic, destiny,
    dailyEnergy, comboText, yogaInsights, comboMeaning, rating,
  });

  return {
    quote,
    rating,
    insight,
    what_to_do: doList,
    what_to_avoid: avoidList,
    yoga_messages: yogaInsights,
    active_yogas: yogas,
  };
}

function buildDailyInsight({ daily, maha, antar, monthly, basic, destiny,
    dailyEnergy, comboText, yogaInsights, comboMeaning, rating }) {
  const parts = [];

  // Combo text — extract only clean human-readable sentences, no jargon
  if (comboText) {
    const isTechnical = (s) => /\b(Sun|Moon|Jupiter|Rahu|Mercury|Venus|Ketu|Saturn|Mars|Dasha|Yoga|combination|natal|chart|double|triple|single|multiple|\beven\b|\bodd\b|\d+)\b/i.test(s);
    const sentences = comboText.split(/(?<=[.!])/)
      .map(s => s.trim())
      .filter(s => s.length > 30 && !isTechnical(s));
    if (sentences.length > 0) parts.push(sentences[0]);
  }

  // Daily energy — use money/work signal based on daily number quality
  const dailySignal = {
    1: "Take initiative today — the conditions favor bold decisions.",
    2: "Connection and creativity are the day's strongest currents.",
    3: "Wisdom and sound judgment are accessible today — trust your read.",
    4: "Stay flexible today — what disrupts you is also redirecting you.",
    5: "Sharp thinking and financial instinct are running high today.",
    6: "Beauty, connection, and ease — today rewards presence over effort.",
    7: "Luck is quiet but active today. Trust your instincts over analysis.",
    8: "Discipline and output — what you put in today compounds later.",
    9: "Energy and courage are your tools today. Act before you overthink.",
  };
  parts.push(dailySignal[daily] || `Today's energy favors ${dailyEnergy.essence}.`);

  // Best yoga insight — pick the most impactful positive one
  const positiveInsights = yogaInsights.filter(t => t && t.length > 20);
  if (positiveInsights.length > 0) {
    parts.push(positiveInsights[0]);
  }

  return parts.join(' ');
}

function assessDayRating(daily, maha, antar, yogas, freqMap) {
  let score = 0;

  // Positive yogas add to score
  const positiveYogas = yogas.filter(y => y.positive).length;
  const negativeYogas = yogas.filter(y => !y.positive).length;
  score += positiveYogas * 2;
  score -= negativeYogas * 2;

  // Daily number quality
  const goodDays = [1, 3, 5, 7, 9];
  const heavyDays = [4, 8];
  if (goodDays.includes(daily)) score += 1;
  if (heavyDays.includes(daily)) score -= 1;

  // Maha-antar combo
  const positiveMainCombos = ['1_7', '1_5', '3_1', '5_7', '5_9', '6_7', '7_1'];
  const heavyMainCombos = ['1_8', '7_8', '4_4', '8_8', '9_9'];
  if (positiveMainCombos.includes(`${maha}_${antar}`)) score += 2;
  if (heavyMainCombos.includes(`${maha}_${antar}`)) score -= 2;

  // Even/odd 8 check
  const count8 = freqMap[8] || 0;
  if (count8 >= 2 && count8 % 2 === 0) score += 1;
  if (count8 >= 2 && count8 % 2 !== 0) score -= 1;

  if (score >= 3) return 'favorable';
  if (score <= -2) return 'avoid';
  return 'caution';
}

// ─── Generate hourly predictions ─────────────────────────────────────────────
export function generateHourlyPredictions(ctx) {
  const { daily, maha, antar, hours, yogas, natalNums } = ctx;

  // Only classify waking hours (6AM to 11PM)
  const wakingHours = hours.filter(h => h.hour >= 6 && h.hour <= 23);

  const classified = wakingHours.map(h => {
    const hourNum = h.number;
    const quality = classifyHour(hourNum, daily, maha, antar, yogas, natalNums || []);
    const hourQuality = HOUR_QUALITIES[hourNum];

    return {
      hour: h.hour,
      number: hourNum,
      classification: quality.type,
      label: hourQuality.label,
      good_for: quality.good_for || hourQuality.good_for,
      avoid: quality.avoid || hourQuality.avoid,
      reason: quality.reason,
    };
  });

  // Best = 'best' type only
  // Caution = 'caution' or 'avoid' type only
  const best = classified.filter(h => h.classification === 'best');
  const caution = classified.filter(h => h.classification === 'caution' || h.classification === 'avoid');

  // If no best hours found, promote top 'good' hours
  const bestOrGood = best.length > 0 ? best : classified.filter(h => h.classification === 'good').slice(0, 3);

  return { best: bestOrGood, caution, all: classified };
}

function classifyHour(hourNum, daily, maha, antar, yogas, natalNums) {
  // hourNum = the calculated dasha number for this hour
  // natalNums = natal chart numbers only (no dasha additions)
  const hourQuality = HOUR_QUALITIES[hourNum];
  const yogaIds = yogas.map(y => y.id);

  // ── BEST hours ─────────────────────────────────────────────────
  // Hour number creates Easy Money with daily
  if ((hourNum === 5 && daily === 7) || (hourNum === 7 && daily === 5)) {
    return { type: 'best', reason: 'Sharp financial instincts this hour', good_for: ['money decisions', 'business', 'negotiations', 'investments'], avoid: [] };
  }
  // Hour number = 1, daily = 9 or vice versa (full power)
  if ((hourNum === 1 && daily === 9) || (hourNum === 9 && daily === 1)) {
    return { type: 'best', reason: 'Peak energy and authority this hour', good_for: ['bold decisions', 'leadership', 'starting something important'], avoid: [] };
  }
  // Hour number = 7, Easy Money yoga active in chart
  if (hourNum === 7 && yogaIds.includes('easy_money')) {
    return { type: 'best', reason: 'Luck peaks this hour', good_for: ['important asks', 'meetings', 'travel', 'key decisions'], avoid: [] };
  }
  // Hour number = 1, Raj Yoga active
  if (hourNum === 1 && yogaIds.includes('raj_yoga')) {
    return { type: 'best', reason: 'Authority and recognition peak this hour', good_for: ['career moves', 'negotiations', 'public visibility'], avoid: [] };
  }
  // Hour number = 5 or 1, High Intuition yoga active
  if ((hourNum === 5 || hourNum === 1) && yogaIds.includes('high_intuition')) {
    return { type: 'best', reason: 'Mental clarity at its sharpest this hour', good_for: ['analysis', 'decisions', 'creative work', 'communication'], avoid: [] };
  }
  // Hour aligns with daily number (same = amplified)
  if (hourNum === daily) {
    return { type: 'best', reason: "The day's core energy amplifies this hour", good_for: hourQuality.good_for, avoid: hourQuality.avoid };
  }

  // ── CAUTION hours ───────────────────────────────────────────────
  // Hour = 4 + daily has 9 but no 5 → Bandhan energy
  if (hourNum === 4 && daily === 9) {
    return { type: 'caution', reason: 'Frustration and constraint peak — avoid confrontations', good_for: ['rest', 'routine tasks'], avoid: ['confrontations', 'contracts', 'big decisions'] };
  }
  // Hour = 4 + Financial Bandhan yoga active
  if (hourNum === 4 && yogaIds.includes('financial_bandhan')) {
    return { type: 'caution', reason: 'Spending impulse is strongest this hour', good_for: ['planning', 'analysis'], avoid: ['purchases', 'financial commitments', 'online shopping'] };
  }
  // Hour = 8 + daily = 7 (misfortune combination)
  if (hourNum === 8 && daily === 7) {
    return { type: 'caution', reason: 'Heavy energy this hour — work quietly, avoid big moves', good_for: ['focused work', 'reflection'], avoid: ['launches', 'pitches', 'social events'] };
  }
  // Hour = 9 + multiple 9 in chart
  if (hourNum === 9 && natalNums.filter(n => n === 9).length >= 2) {
    return { type: 'caution', reason: 'Aggression and frustration can spike this hour', good_for: ['physical activity', 'solo work'], avoid: ['arguments', 'negotiations', 'emotional conversations'] };
  }

  // ── Default based on alignment ──────────────────────────────────
  const aligned = isAligned(hourNum, daily, maha, antar);
  if (aligned.positive) return { type: 'good', reason: aligned.reason, good_for: hourQuality.good_for, avoid: hourQuality.avoid };
  if (aligned.negative) return { type: 'caution', reason: aligned.reason, good_for: hourQuality.good_for, avoid: hourQuality.avoid };

  return { type: 'neutral', reason: 'Steady energy this hour', good_for: hourQuality.good_for, avoid: hourQuality.avoid };
}

function isAligned(hourNum, daily, maha, antar) {
  const positiveAlignments = [
    [1, 3], [1, 9], [3, 9], [5, 7], [5, 9], [6, 7], [7, 9], [1, 5], [3, 5],
  ];
  const negativeAlignments = [
    [4, 9], [4, 5], [7, 8], [1, 8], [2, 8], [8, 8],
  ];

  const pair1 = [hourNum, daily].sort().join('_');
  const pair2 = [hourNum, maha].sort().join('_');
  const pair3 = [hourNum, antar].sort().join('_');

  for (const [a, b] of positiveAlignments) {
    const key = [a, b].sort().join('_');
    if (pair1 === key || pair2 === key || pair3 === key) {
      return { positive: true, reason: `${HOUR_QUALITIES[hourNum]?.quality} energy aligns with the day's frequency` };
    }
  }

  for (const [a, b] of negativeAlignments) {
    const key = [a, b].sort().join('_');
    if (pair1 === key || pair2 === key || pair3 === key) {
      return { negative: true, reason: `Conflicting energies this hour — move carefully` };
    }
  }

  return { positive: false, negative: false };
}

// ─── Generate weekly prediction ───────────────────────────────────────────────
// ─── Daily number calculator for a specific date ─────────────────────────────
function getDailyForDate(dob, dateStr) {
  const d = new Date(dateStr);
  const monthly = currentMonthlyDasha(dob, dateStr);
  const monthlyNum = monthly ? monthly.number : basicNumber(new Date(dob).getDate());
  const weekday = d.getDay();
  const dayLord = WEEKDAY_VALUES[weekday];
  return reduceToSingle(monthlyNum + dayLord);
}

// ─── Process 7 days and return pattern analysis ───────────────────────────────
function processWeekDays(dob, startDate) {
  const days = [];
  const d = new Date(startDate);
  for (let i = 0; i < 7; i++) {
    const dateStr = new Date(d.getTime() + i * 86400000).toISOString();
    const dayNum = getDailyForDate(dob, dateStr);
    const dayName = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][new Date(dateStr).getDay()];
    days.push({ day: dayName, date: dateStr, number: dayNum });
  }
  // Find best and heaviest days
  const numberScores = { 1:7, 2:5, 3:7, 4:3, 5:8, 6:6, 7:8, 8:4, 9:6 };
  const sorted = [...days].sort((a,b) => numberScores[b.number] - numberScores[a.number]);
  const bestDays = sorted.slice(0,2).map(d => ({ day: d.day, number: d.number }));
  const heavyDays = sorted.slice(-2).map(d => ({ day: d.day, number: d.number }));
  const numbers = days.map(d => d.number);
  const dominant = numbers.reduce((acc, n) => { acc[n] = (acc[n]||0)+1; return acc; }, {});
  const dominantNum = parseInt(Object.entries(dominant).sort((a,b)=>b[1]-a[1])[0][0]);
  return { days, bestDays, heavyDays, dominantNum, numbers };
}

// ─── Process 4 weeks and return month pattern ─────────────────────────────────
function processMonthWeeks(dob, startDate) {
  const weeks = [];
  const d = new Date(startDate);
  // Start from beginning of current month
  const monthStart = new Date(d.getFullYear(), d.getMonth(), 1);
  for (let w = 0; w < 4; w++) {
    const weekStart = new Date(monthStart.getTime() + w * 7 * 86400000);
    const weekData = processWeekDays(dob, weekStart.toISOString());
    weeks.push({ week: w+1, ...weekData });
  }
  const allNumbers = weeks.flatMap(w => w.numbers);
  const dominant = allNumbers.reduce((acc,n) => { acc[n]=(acc[n]||0)+1; return acc; }, {});
  const dominantNum = parseInt(Object.entries(dominant).sort((a,b)=>b[1]-a[1])[0][0]);
  // Current week position
  const dayOfMonth = d.getDate();
  const currentWeek = Math.ceil(dayOfMonth / 7);
  return { weeks, dominantNum, currentWeek };
}

// ─── Process 12 months and return year pattern ───────────────────────────────
function processYearMonths(dob, year) {
  const months = [];
  const numberScores = { 1:8, 2:5, 3:7, 4:2, 5:9, 6:6, 7:8, 8:4, 9:7 };
  for (let m = 0; m < 12; m++) {
    const monthStart = new Date(year, m, 1).toISOString();
    const monthly = currentMonthlyDasha(dob, monthStart);
    const monthNum = monthly ? monthly.number : 0;
    const score = numberScores[monthNum] || 5;
    months.push({ month: m+1, number: monthNum, score });
  }
  const sorted = [...months].sort((a,b) => b.score - a.score);
  const bestMonths = sorted.slice(0,3).map(m => m.month);
  const riskyMonths = sorted.slice(-2).map(m => m.month);
  return { months, bestMonths, riskyMonths };
}

const MONTH_NAMES = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

// ─── Generate weekly prediction ───────────────────────────────────────────────
export function generateWeeklyPrediction(ctx, targetDate = new Date().toISOString()) {
  const { basic, destiny, maha, antar, monthly, yogas, freqMap, dob: ctxDob } = ctx;

  // Process actual 7 days
  const weekData = ctx._dob ? processWeekDays(ctx._dob, targetDate) : null;
  const bestDays = weekData?.bestDays || [];
  const heavyDays = weekData?.heavyDays || [];
  const dominantNum = weekData?.dominantNum || antar;

  // Deep period text if available
  const deepText = getDeepPeriodText(maha, antar, 'weekly');

  // Yoga context
  const yogaCtx = getYogaContext(yogas, 'weekly');

  // Build genuinely week-specific content
  const overview = deepText?.overview || PERIOD_PREDICTIONS.weekly[dominantNum] || PERIOD_PREDICTIONS.weekly[antar];
  const opportunities = deepText?.opportunities || buildOpportunities(maha, antar, yogas, 'weekly');
  const watchOut = deepText?.watch_out || buildWatchOut(maha, antar, yogas, freqMap, 'weekly');

  return {
    // Structure unique to WEEKLY
    overview,
    best_days: bestDays.map(d => ({
      day: d.day,
      energy: NUMBER_ENERGY[d.number]?.essence || '',
      advice: HOUR_QUALITIES[d.number]?.good_for?.slice(0,2).join(', ') || '',
    })),
    heavy_days: heavyDays.map(d => ({
      day: d.day,
      caution: NUMBER_ENERGY[d.number]?.shadow || '',
    })),
    opportunities,
    watch_out: watchOut,
    // Weekly-specific domains (short, punchy)
    money_this_week: deepText?.finance || getFinanceSignal(freqMap, maha, antar, 'weekly'),
    love_this_week: deepText?.relationships || getRelationshipSignal(maha, antar, yogas, 'weekly'),
    health_this_week: deepText?.health || getHealthWatch(basic, destiny, maha, antar),
    yoga_context: yogaCtx,
  };
}

// ─── Generate monthly prediction ─────────────────────────────────────────────
export function generateMonthlyPrediction(ctx, targetDate = new Date().toISOString()) {
  const { basic, destiny, maha, antar, monthly, yogas, freqMap } = ctx;

  // Process actual month weeks
  const monthData = ctx._dob ? processMonthWeeks(ctx._dob, targetDate) : null;
  const currentWeek = monthData?.currentWeek || 2;

  // Deep period text
  const deepText = getDeepPeriodText(maha, antar, 'monthly');

  const yogaCtx = getYogaContext(yogas, 'monthly');
  const d = new Date(targetDate);
  const monthName = MONTH_NAMES[d.getMonth()];

  return {
    // Structure unique to MONTHLY — arc view with phases
    month_name: monthName,
    overview: deepText?.overview || PERIOD_PREDICTIONS.monthly[monthly] || PERIOD_PREDICTIONS.monthly[antar],

    // Phase breakdown — unique to monthly
    phases: [
      {
        label: 'Week 1–2',
        theme: deepText?.first_half || buildPhaseText(maha, antar, 'early'),
        current: currentWeek <= 2,
      },
      {
        label: 'Week 3–4',
        theme: deepText?.second_half || buildPhaseText(maha, antar, 'late'),
        current: currentWeek > 2,
      },
    ],

    // Deeper domain breakdowns for monthly
    finance: {
      signal: deepText?.finance || getFinanceSignal(freqMap, maha, antar, 'monthly'),
      action: getFinanceAction(maha, antar, yogas),
    },
    relationships: {
      signal: deepText?.relationships || getRelationshipSignal(maha, antar, yogas, 'monthly'),
      what_to_watch: getRelationshipWatch(maha, antar),
    },
    health: {
      watch: deepText?.health || getHealthWatch(basic, destiny, maha, antar),
      advice: getHealthAdvice(basic, destiny, maha),
    },
    career: {
      signal: deepText?.career || getCareerSignal(maha, antar, yogas, basic, destiny, 'monthly'),
      best_week: `Week ${currentWeek <= 2 ? 3 : 1} is stronger for career moves this month`,
    },
    yoga_context: yogaCtx,
    opportunities: buildOpportunities(maha, antar, yogas, 'monthly'),
    watch_out: buildWatchOut(maha, antar, yogas, freqMap, 'monthly'),
  };
}

// ─── Generate yearly prediction ───────────────────────────────────────────────
export function generateYearlyPrediction(ctx, targetDate = new Date().toISOString()) {
  const { basic, destiny, maha, antar, yogas, modifiers, freqMap } = ctx;

  // Process actual 12 months
  const d = new Date(targetDate);
  const year = d.getFullYear();
  const yearData = ctx._dob ? processYearMonths(ctx._dob, year) : null;
  const bestMonths = yearData?.bestMonths?.map(m => MONTH_NAMES[m-1]) || [];
  const riskyMonths = yearData?.riskyMonths?.map(m => MONTH_NAMES[m-1]) || [];

  // Deep period text
  const deepText = getDeepPeriodText(maha, antar, 'yearly');
  const comboText = DASHA_COMBO_PREDICTIONS[`${maha}_${antar}`] || '';

  const yogaCtx = getYogaContext(yogas, 'yearly');
  const allModifiers = modifiers.map(m => CHART_MODIFIERS[m]).filter(Boolean);

  // Personal pattern for yearly
  const personalPattern = getPersonalPattern(basic, destiny);
  const dashaExp = getDashaExperience(maha);

  return {
    // Structure unique to YEARLY — big picture with month windows
    year,
    title: deepText?.title || `${year}: The ${NUMBER_ENERGY[maha]?.essence} Year`,
    overview: deepText?.overview || PERIOD_PREDICTIONS.yearly[maha],

    // Year in one line — unique to yearly
    year_in_one_line: deepText?.the_year_in_one_line || null,

    // Month windows — unique to yearly
    best_months: deepText?.best_months || (bestMonths.length > 0 ? `${bestMonths.join(', ')} carry the year's highest energy` : null),
    risky_months: deepText?.risky_months || (riskyMonths.length > 0 ? `${riskyMonths.join(', ')} require more caution` : null),

    // This year specifically — the dasha combo layer
    this_year_specifically: cleanText(comboText.split('.').slice(0,2).join('.')),

    // Deeper domain view for yearly
    finance: {
      year_signal: deepText?.finance || getFinanceSignal(freqMap, maha, antar, 'yearly'),
      your_pattern: personalPattern?.money || null,
    },
    relationships: {
      year_signal: deepText?.relationships || getRelationshipSignal(maha, antar, yogas, 'yearly'),
      your_pattern: personalPattern?.love || null,
    },
    health: {
      watch: deepText?.health || getHealthWatch(basic, destiny, maha, antar),
      your_pattern: NUMBER_ENERGY[basic]?.health_risk || null,
    },
    career: {
      year_signal: deepText?.career || getCareerSignal(maha, antar, yogas, basic, destiny, 'yearly'),
      your_pattern: personalPattern?.work || null,
    },

    // The current chapter context — unique to yearly
    current_chapter: dashaExp ? {
      title: dashaExp.title,
      what_is_actually_happening: dashaExp.what_is_actually_happening,
      the_gift: dashaExp.the_gift,
      the_trap: dashaExp.the_trap,
    } : null,

    // Chart-level modifiers
    life_context: allModifiers.slice(0,3),
    yoga_context: yogaCtx,
    opportunities: buildOpportunities(maha, antar, yogas, 'yearly'),
    watch_out: buildWatchOut(maha, antar, yogas, freqMap, 'yearly'),
  };
}

// ─── Phase text helper ────────────────────────────────────────────────────────
function buildPhaseText(maha, antar, phase) {
  const mahaE = NUMBER_ENERGY[maha];
  const antarE = NUMBER_ENERGY[antar];
  if (phase === 'early') {
    return `The ${mahaE?.essence} energy is establishing the month's tone. Early decisions carry weight.`;
  }
  return `${antarE?.essence.charAt(0).toUpperCase() + antarE?.essence.slice(1)} becomes the dominant current. What was started early begins to show results.`;
}

// ─── Finance action helper ────────────────────────────────────────────────────
function getFinanceAction(maha, antar, yogas) {
  const yogaIds = yogas.map(y => y.id);
  if (yogaIds.includes('financial_bandhan')) return "Save before spending — automate it so the choice doesn't happen at the point of temptation.";
  if (yogaIds.includes('easy_money')) return "Act on the financial opportunity — but save a meaningful portion before spending any.";
  if (maha === 8) return "Protect what exists. Not the month for large financial moves.";
  if (maha === 5 || antar === 5) return "Business and income are the priorities. Move on what's in front of you.";
  return "Steady management. No dramatic moves needed this month.";
}

// ─── Relationship watch helper ────────────────────────────────────────────────
function getRelationshipWatch(maha, antar) {
  if (antar === 4) return 'Deception risk — verify before trusting new connections.';
  if (antar === 9 || maha === 9) return 'Intensity peaks — passion and conflict run at the same frequency.';
  if (antar === 2 || antar === 6) return 'Depth is available — invest in the relationship that matters.';
  if (antar === 7) return 'Detachment is present — not coldness, just a different kind of connection.';
  return "Steady relational energy — nurture what's already there.";
}

// ─── Health advice helper ─────────────────────────────────────────────────────
function getHealthAdvice(basic, destiny, maha) {
  const healthMap = {
    1: "Manage stress before it becomes physical — headaches and eye strain are the early signals.",
    2: "Sleep quality is the priority — the emotional load lands in the body when sleep is insufficient.",
    3: "Liver and skin — watch what you're eating and whether the ethics are aligned.",
    4: "Blood sugar and blood pressure — physical recklessness increases when the mind is scattered.",
    5: "Anxiety management is non-optional. Physical movement is the antidote.",
    6: "Hormonal balance and hydration — both need more attention than usual.",
    7: "Sleep and stillness — the nervous system is running hot.",
    8: "Dental and gut health — where this number holds its unprocessed tension.",
    9: "Physical outlet is mandatory. The energy needs somewhere constructive to go.",
  };
  return healthMap[maha] || healthMap[basic] || "Maintain baseline care consistently.";
}


export function generateLifePrediction(ctx) {
  const { basic, destiny, yogas, modifiers, freqMap } = ctx;

  const key = `${basic}_${destiny}`;
  const lifeText = LIFE_PREDICTIONS[key] || LIFE_PREDICTIONS[`${destiny}_${basic}`] || '';

  const basicEnergy = NUMBER_ENERGY[basic];
  const destinyEnergy = NUMBER_ENERGY[destiny];

  const allModifiers = modifiers.map(m => CHART_MODIFIERS[m]).filter(Boolean);

  return {
    life_path: lifeText,
    core_nature: basicEnergy.essence,
    life_direction: destinyEnergy.essence,
    greatest_strength: basicEnergy.at_best,
    core_challenge: basicEnergy.at_worst,
    money_pattern: basicEnergy.money,
    love_pattern: basicEnergy.love,
    health_pattern: basicEnergy.health_risk,
    work_style: basicEnergy.work_style,
    active_yogas: yogas,
    chart_modifiers: allModifiers,
  };
}

// ─── Helper builders ──────────────────────────────────────────────────────────
function buildOpportunities(maha, antar, yogas, period) {
  const opps = [];

  // From dasha combo
  const combo = DASHA_COMBO_PREDICTIONS[`${maha}_${antar}`] || '';
  if (combo) {
    // Extract positive-sounding sentences
    const sentences = combo.split('. ');
    const positive = sentences.filter(s =>
      !s.toLowerCase().includes('caution') &&
      !s.toLowerCase().includes('avoid') &&
      !s.toLowerCase().includes('risk') &&
      !s.toLowerCase().includes('watch') &&
      s.length > 20
    );
    if (positive.length > 0) opps.push(positive[0]);
  }

  // From yogas
  for (const yoga of yogas.filter(y => y.positive).slice(0, 2)) {
    const yogaData = COMBO_DAILY_INSIGHTS[yoga.id];
    if (yogaData?.favorable || yogaData?.active) {
      opps.push(yogaData.favorable || yogaData.active);
    }
  }

  // From maha energy
  const mahaE = NUMBER_ENERGY[maha];
  opps.push(`Your ${mahaE.essence} is the dominant force — use it.`);

  return opps.slice(0, 3);
}

function buildWatchOut(maha, antar, yogas, freqMap, period) {
  const warnings = [];

  // From negative yogas
  for (const yoga of yogas.filter(y => !y.positive)) {
    const yogaData = COMBO_DAILY_INSIGHTS[yoga.id];
    if (yogaData?.active || yogaData?.advice) {
      warnings.push(yogaData.advice || yogaData.active);
    }
  }

  // Even/odd 8 warning
  const count8 = freqMap[8] || 0;
  if (count8 > 0 && count8 % 2 !== 0) {
    warnings.push("Saturn's karmic weight is active — shortcuts and ethical compromises will cost more than they save.");
  }

  // Multiple 9 warning
  if ((freqMap[9] || 0) >= 2) {
    warnings.push("Frustration can spike unexpectedly. Physical activity and clear communication prevent it from becoming explosive.");
  }

  // Multiple 2 warning
  if ((freqMap[2] || 0) >= 2) {
    warnings.push("Emotional sensitivity is heightened. Criticism lands harder than usual. Build in recovery time.");
  }

  // Financial Bandhan
  if (warnings.length === 0) {
    const mahaE = NUMBER_ENERGY[maha];
    if (mahaE.shadow) warnings.push(`Watch for ${mahaE.shadow} — the shadow of this period's dominant energy.`);
  }

  return warnings.slice(0, 3);
}

function getYogaContext(yogas, period) {
  const positive = yogas.filter(y => y.positive).map(y => y.name);
  const negative = yogas.filter(y => !y.positive).map(y => y.name);

  if (positive.length === 0 && negative.length === 0) return null;

  return {
    active_positive: positive,
    active_caution: negative,
    summary: positive.length > negative.length
      ? `${positive.join(', ')} are working in your favor this ${period}.`
      : negative.length > 0
        ? `${negative.join(', ')} require conscious navigation this ${period}.`
        : `Balanced energy this ${period}.`,
  };
}

function getFinanceSignal(freqMap, maha, antar, period) {
  const positiveNums = [1, 5, 6];
  const signals = [];

  // Even 8 check
  const c8 = freqMap[8] || 0;
  if (c8 >= 2 && c8 % 2 === 0) signals.push("Even 8 energy is supporting bulk financial gains and disciplined wealth building.");

  // 5-7 Easy Money
  const nums = Object.keys(freqMap).map(Number);
  if (nums.includes(5) && nums.includes(7)) signals.push("Easy Money combination active — financial opportunities arrive with less friction than usual.");

  // Maha/antar numbers
  if (maha === 5 || antar === 5) signals.push("Cash flow improves this period — new income streams are accessible.");
  if (maha === 1 || antar === 1) signals.push("Bulk money and significant financial events are characteristic of this period.");
  if (maha === 4 || antar === 4) signals.push("Financial caution is essential — impulsive spending and debt are the main risks.");
  if ((c8 > 0 && c8 % 2 !== 0)) signals.push("Financial hardship possible — discipline and minimal new commitments are the right approach.");

  // Financial Bandhan
  if (nums.includes(5) && nums.includes(4) && !nums.includes(9)) {
    signals.push("Financial Bandhan active — save actively and defer large purchases.");
  }

  return signals.length > 0 ? signals[0] : "Financial energy is neutral this period — steady effort produces steady results.";
}

function getHealthWatch(basic, destiny, maha, antar) {
  const { HEALTH_MAP } = { HEALTH_MAP: {
    1: "Headaches, eye strain, and stress-related tension.",
    2: "Digestive issues, emotional fatigue, and sleep disruption.",
    3: "Liver stress and skin flare-ups.",
    4: "Blood pressure, blood sugar, and accident-prone moments.",
    5: "Anxiety, constipation, and overthinking-induced fatigue.",
    6: "Hormonal shifts, kidney sensitivity.",
    7: "Anxiety, insomnia, and overanalysis spirals.",
    8: "Dental, intestinal, and stress-held tension.",
    9: "Fever risk, throat sensitivity, and injury from recklessness.",
  }};

  const watchNumbers = [...new Set([basic, maha, antar])];
  const risks = watchNumbers.map(n => HEALTH_MAP[n]).filter(Boolean);
  return risks[0] || "No specific health risks flagged this period — maintain baseline care.";
}

function getRelationshipSignal(maha, antar, yogas, period) {
  const marriageNums = [2, 3, 6, 9];
  const cautionNums = [4, 7];

  if (marriageNums.includes(antar)) {
    return `Relationship energy is positive this ${period} — emotional bonds deepen, romantic opportunities are real, and commitments made now carry weight.`;
  }
  if (antar === 4) {
    return `Relationship caution this ${period} — trust carefully, verify before committing, and watch for deception in close connections.`;
  }
  if (antar === 5) {
    return `Neutral relationship energy — connections are intellectual and social rather than deeply romantic this ${period}.`;
  }

  // Check for romantic yogas
  const nums = yogas.map(y => y.id);
  if (nums.includes('easy_money') || nums.includes('sun_ketu_raj')) {
    return `Attraction is heightened this ${period} — romantic energy is real and connections made now can be significant.`;
  }

  return `Relationship energy is steady this ${period} — existing bonds benefit from attention and nurturing.`;
}

function getCareerSignal(maha, antar, yogas, basic, destiny, period) {
  const careerNums = [1, 3, 5];
  const heavyNums = [4, 8];

  if (careerNums.includes(maha) || careerNums.includes(antar)) {
    return `Career is an active front this ${period} — advancement, recognition, and opportunities for leadership are accessible.`;
  }
  if (maha === 4 || antar === 4) {
    return `Career instability possible this ${period} — unexpected shifts and financial friction in professional matters. Research before committing.`;
  }
  if ((maha === 8 || antar === 8)) {
    const c8 = 1; // simplification
    return `Career demands full effort this ${period}. The rewards are real but they require consistent output over shortcuts.`;
  }

  const raj = yogas.find(y => y.id === 'raj_yoga');
  if (raj) return `Raj Yoga active — authority and career advancement are strongly supported this ${period}.`;

  return `Career energy is steady this ${period}. Build on existing momentum rather than chasing new directions.`;
}
