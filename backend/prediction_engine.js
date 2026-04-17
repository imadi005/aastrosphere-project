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

import { classifyHourDeep } from './hour_library.js';

import { DEEP_PERIOD_TEXTS_GENERATED } from './deep_library_generated.js';

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
  // Priority: manual deep texts (high quality) > generated texts (all 81 combos)
  const manualData = DEEP_PERIOD_TEXTS[period];
  if (manualData?.[key]) return manualData[key];

  const generatedData = DEEP_PERIOD_TEXTS_GENERATED[period];
  if (generatedData?.[key]) return generatedData[key];

  return null;
}

// ─── Text cleaning utility ───────────────────────────────────────────────────
function cleanText(text) {
  if (!text) return '';
  // Split into sentences, filter out any that have technical terms, rejoin clean ones
  const techPattern = /\b(Sun|Moon|Jupiter|Rahu|Mercury|Venus|Ketu|Saturn|Mars|Dasha|yoga|combination|natal|chart|misfortune|defamation|bandhan|vipreet|raj|without number|meets \w+ —)\b/gi;
  
  const sentences = text.split(/(?<=[.!])\s*/).map(s => s.trim()).filter(Boolean);
  const clean = sentences
    .filter(s => !techPattern.test(s))
    .join(' ')
    .replace(/\b\w+ meets \w+ —\s*/gi, '')
    .replace(/without number \d+\.?/gi, '')
    .replace(/\b(Double|Triple|Single|Odd|Even)\s+\d+[^.!]*/gi, '')
    .replace(/\bnumber\s+\d+\b/gi, '')
    .replace(/\s+\./g, '.')
    .replace(/\.\s*\./g, '.')
    .replace(/^[.—\s]+/, '')
    .replace(/\s*—\s*$/, '')
    .replace(/\s{2,}/g, ' ')
    .trim();
  
  return clean;
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

  // ── COMBO DESCRIPTION HELPER ──────────────────────────────────────────────
  // Gets the best available clean description for a combo key
  function getComboDesc(key) {
    // Try deep library real_life first (always second-person, clean)
    const deep = DEEP_COMBINATIONS[key] || DEEP_COMBINATIONS_EXTENDED[key];
    if (deep?.real_life) return deep.real_life;
    // Fall back to what_it_creates from deep
    if (deep?.what_it_creates) return cleanText(deep.what_it_creates);
    // Last resort: COMBINATION_MEANINGS cleaned
    const raw = COMBINATION_MEANINGS[key];
    return raw ? cleanText(raw) : '';
  }

  // ── MAHA + ANTAR PAIR ─────────────────────────────────────────────────────
  const mahAntarKey = [maha, antar].sort((a,b)=>a-b).join('_');
  const mahAntarDesc = getComboDesc(mahAntarKey);
  if (mahAntarDesc) {
    yogas.push({
      id: 'maha_antar_combo',
      combo_key: mahAntarKey,
      name: 'Running Energy',
      positive: true,
      description: mahAntarDesc,
    });
  }

  // ── ANTAR + MONTHLY PAIR ─────────────────────────────────────────────────
  const antarMonthlyKey = [antar, monthly].sort((a,b)=>a-b).join('_');
  const antarMonthlyDesc = getComboDesc(antarMonthlyKey);
  if (antarMonthlyKey !== mahAntarKey && antarMonthlyDesc) {
    yogas.push({
      id: 'antar_monthly_combo',
      combo_key: antarMonthlyKey,
      name: 'Monthly Energy',
      positive: true,
      description: antarMonthlyDesc,
    });
  }

  // ── MAHA + DAILY PAIR ────────────────────────────────────────────────────
  const mahaDailyKey = [maha, daily].sort((a,b)=>a-b).join('_');
  const mahaDailyDesc = getComboDesc(mahaDailyKey);
  if (mahaDailyDesc) {
    yogas.push({
      id: 'maha_daily_combo',
      combo_key: mahaDailyKey,
      name: "Today's Drive",
      positive: true,
      description: mahaDailyDesc,
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

// ─── Primary action — chart-specific, not from generic guidance list ─────────
// Based on active yogas + maha+antar+daily combination
export function getPrimaryAction(ctx) {
  const { basic, destiny, maha, antar, monthly, daily, yogas, natalNums } = ctx;
  const yogaIds = yogas.map(y => y.id);

  if (yogaIds.includes('raj_yoga') || yogaIds.includes('sun_ketu_raj')) {
    return {
      do: "Make the authority move you've been postponing — the conditions are right today.",
      avoid: "Letting ego override the opportunity. Confidence is warranted, arrogance isn't.",
    };
  }
  if (yogaIds.includes('easy_money')) {
    return {
      do: "Act on the financial opportunity in front of you — the luck is structural, not random.",
      avoid: "Letting easy income leave as easily as it arrived. Save something from what comes.",
    };
  }
  if (yogaIds.includes('financial_bandhan')) {
    return {
      do: "Set aside money before spending anything today — even a small amount breaks the pattern.",
      avoid: "Any purchase that feels justified by the moment. It isn't.",
    };
  }
  if (yogaIds.includes('bandhan')) {
    return {
      do: "Navigate the constraint rather than fight it. Find the door instead of breaking the wall.",
      avoid: "Explosive reactions to being blocked — they make the cage smaller.",
    };
  }
  if (yogaIds.includes('uplifting_319')) {
    return {
      do: "Lead on something today — authority, wisdom, and energy are all available simultaneously.",
      avoid: "Wasting the full-power day on things that don't matter.",
    };
  }
  if (yogaIds.includes('vipreet_raj')) {
    return {
      do: "Show up fully today — the adversity you're navigating is building something real.",
      avoid: "Shortcuts and substances. The difficult path today is the right one.",
    };
  }
  if (yogaIds.includes('high_intuition')) {
    return {
      do: "Trust the first read on the situation or person today — your instincts are accurate.",
      avoid: "Overanalyzing what only feeling can resolve.",
    };
  }

  const dailyActions = {
    1: { do: "Take initiative on the one thing requiring a decision — your confidence is warranted today.", avoid: "Letting pride turn a small disagreement into a larger conflict." },
    2: { do: "Have the meaningful conversation you've been avoiding — emotional honesty lands well today.", avoid: "Making financial decisions from emotional reasoning." },
    3: { do: "Seek or give advice on something that matters — your judgment is particularly sound today.", avoid: "Ethical shortcuts. The consequences multiply today." },
    4: { do: "Research before committing to anything — your analytical ability is sharp today.", avoid: "Impulsive purchases or commitments. Verify first." },
    5: { do: "Negotiate, pitch, or close the business conversation you've been putting off.", avoid: "Letting the sharp mind run into overthinking and anxiety tonight." },
    6: { do: "Express genuine appreciation to someone who deserves it — it lands unusually well today.", avoid: "Harsh words when frustrated. Your tongue carries extra weight today." },
    7: { do: "Trust your gut over the spreadsheet today — intuition is outperforming analysis.", avoid: "Forcing outcomes. What needs to arrive will, when you stop pushing." },
    8: { do: "Do the one hard thing you've been postponing. Today's effort compounds.", avoid: "Shortcuts. Saturn is watching every one of them today." },
    9: { do: "Make the bold move that requires courage. The energy is behind you today.", avoid: "Starting fights that aren't worth the energy they'll cost." },
  };

  return dailyActions[daily] || {
    do: "Focus on what matters most today and give it full attention.",
    avoid: "Distractions that feel important but aren't.",
  };
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
  const { daily, maha, antar, monthly, hours, yogas, natalNums } = ctx;

  // Classify every waking hour with all 6 layers
  const wakingHours = hours.filter(h => h.hour >= 6 && h.hour <= 23);

  const classified = wakingHours.map(h => {
    const result = classifyHourDeep(
      h.hour, h.number, daily, maha, antar, monthly, natalNums, yogas
    );
    return {
      hour: h.hour,
      number: h.number,
      classification: result.type,
      label: result.type === 'best' ? 'Best hour' : result.type === 'caution' ? 'Caution' : 'Steady',
      reason: result.reason,
      good_for: result.good_for,
      avoid: result.avoid,
      layers: result.layers,
      best_action: result.best_action,
      hour_essence: result.hour_essence,
      time_of_day: result.time_of_day,
    };
  });

  const best = classified.filter(h => h.classification === 'best');
  const caution = classified.filter(h => h.classification === 'caution');
  const neutral = classified.filter(h => h.classification === 'neutral');

  return { best, caution, neutral, all: classified };
}


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
// Checks if a sentence contains any technical jargon that shouldn't reach users
function isTechnicalSentence(s) {
  return /\b(Sun|Moon|Jupiter|Rahu|Mercury|Venus|Ketu|Saturn|Mars|Dasha|yoga|combination|natal|chart|double|triple|single|multiple|misfortune|even|odd)\b/i.test(s);
}

function buildOpportunities(maha, antar, yogas, period) {
  const opps = [];

  // From dasha combo — extract clean, positive sentences only
  const combo = DASHA_COMBO_PREDICTIONS[`${maha}_${antar}`] || '';
  if (combo) {
    const sentences = combo.split(/(?<=[.!])/).map(s => s.trim());
    const positive = sentences.filter(s =>
      s.length > 30 &&
      !isTechnicalSentence(s) &&
      !s.toLowerCase().includes('caution') &&
      !s.toLowerCase().includes('avoid') &&
      !s.toLowerCase().includes('risk') &&
      !s.toLowerCase().includes('watch') &&
      !s.toLowerCase().includes('trap') &&
      !s.toLowerCase().includes('warning') &&
      // Filter out bare keyword lists (e.g. "Sharp, fast, competitive.")
      (s.match(/,/g) || []).length < 3 &&
      // Must be a proper sentence (has a verb indicator)
      /\b(is|are|was|were|will|can|the|your|you|this|what|when|how|comes|brings|creates|peaks|arrives|works|makes|gives|builds|runs|flows|lands)\b/i.test(s)
    );
    if (positive.length > 0) opps.push(positive[0]);
  }

  // From positive yogas — use human-readable descriptions only
  for (const yoga of yogas.filter(y => y.positive && !y.combo_key).slice(0, 2)) {
    const yogaData = COMBO_DAILY_INSIGHTS[yoga.id];
    const text = yogaData?.favorable || yogaData?.active;
    if (text && !isTechnicalSentence(text)) {
      // Remove "today" language for non-daily contexts
      const cleaned = text.replace(/\btoday\b/gi, 'right now').replace(/\bthis week\b/gi, 'currently');
      opps.push(cleaned);
    }
  }

  // From maha energy — human language only
  const mahaE = NUMBER_ENERGY[maha];
  // Use drive (purpose) for clean phrasing
  const driveDescriptions = {
    1: 'The energy to lead, initiate, and take decisive action is available right now.',
    2: 'The energy to connect deeply and create meaningfully is available right now.',
    3: 'The energy for wisdom, guidance, and ethical clarity is available right now.',
    4: 'The energy for research, unconventional thinking, and adaptability is available right now.',
    5: 'Sharp financial instinct and business clarity are running at peak right now.',
    6: 'Creative energy, social magnetism, and relational warmth are available right now.',
    7: 'Luck, intuition, and spiritual clarity are available right now — trust them.',
    8: 'The determination to push through obstacles and build something lasting is available right now.',
    9: 'High physical and competitive energy is available right now — channel it.',
  };
  if (driveDescriptions[maha]) opps.push(driveDescriptions[maha]);

  return opps.filter(Boolean).slice(0, 3);
}

function buildWatchOut(maha, antar, yogas, freqMap, period) {
  const warnings = [];

  // From negative yogas — human language only
  for (const yoga of yogas.filter(y => !y.positive && !y.combo_key)) {
    const yogaData = COMBO_DAILY_INSIGHTS[yoga.id];
    const text = yogaData?.advice || yogaData?.active;
    if (text && !isTechnicalSentence(text)) {
      warnings.push(text);
    }
  }

  // Karmic weight (odd 8)
  const count8 = freqMap[8] || 0;
  if (count8 > 0 && count8 % 2 !== 0) {
    warnings.push("The karmic weight is active — shortcuts cost more than they save right now.");
  }

  // Multiple 9
  if ((freqMap[9] || 0) >= 2) {
    warnings.push("Frustration can spike unexpectedly. Physical activity and honest communication are the antidote.");
  }

  // Multiple 2
  if ((freqMap[2] || 0) >= 2) {
    warnings.push("Emotional sensitivity is heightened. Criticism lands harder than usual — build in recovery time.");
  }

  // Fallback from maha shadow
  if (warnings.length === 0) {
    const mahaE = NUMBER_ENERGY[maha];
    if (mahaE?.shadow) warnings.push(`Watch for ${mahaE.shadow} — the shadow side of this period's energy.`);
  }

  return warnings.filter(Boolean).slice(0, 3);
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
