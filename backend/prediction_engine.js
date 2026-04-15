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
  basicNumber, destinyNumber, currentMahadasha, currentAntardasha,
  currentMonthlyDasha, dailyDasha, hourlyDasha, allHourlyDashas,
  buildFrequencyMap, PLANET_NAMES,
} from './numerology.js';

// ─── Build complete chart context ────────────────────────────────────────────
export function buildChartContext(dob, targetDate = new Date().toISOString()) {
  const d = new Date(dob);
  const basic = basicNumber(d.getDate());
  const destiny = destinyNumber(dob);
  const maha = currentMahadasha(dob);
  const antar = currentAntardasha(dob);
  const monthly = currentMonthlyDasha(dob);
  const daily = dailyDasha(dob, targetDate);
  const hours = allHourlyDashas(dob, targetDate);
  const freqMap = buildFrequencyMap(dob, maha.number, antar.number);
  const allNums = Object.keys(freqMap).map(Number);

  // Detect active yogas
  const yogas = detectYogas(allNums, freqMap, basic, destiny);

  // Get modifiers
  const modifiers = getChartModifiers(allNums, freqMap, basic, destiny);

  return {
    basic, destiny, maha: maha.number, antar: antar.number,
    monthly: monthly.number, daily, hours, freqMap, allNums, yogas, modifiers,
    mahaDetails: maha, antarDetails: antar, monthlyDetails: monthly,
  };
}

// ─── Detect all active yogas ─────────────────────────────────────────────────
function detectYogas(nums, freq, basic, destiny) {
  const yogas = [];

  // Raj Yoga (1+2)
  if (nums.includes(1) && nums.includes(2)) {
    const isStrong = destiny === 1 || destiny === 2 || basic === 2;
    yogas.push({ id: 'raj_yoga', name: isStrong ? 'Strong Raj Yoga' : 'Raj Yoga', positive: true });
  }

  // Sun-Ketu Raj Yoga (1+7 without 8)
  if (nums.includes(1) && nums.includes(7) && !nums.includes(8)) {
    yogas.push({ id: 'sun_ketu_raj', name: 'Continuous Luck', positive: true });
  }

  // Easy Money (5+7)
  if (nums.includes(5) && nums.includes(7)) {
    yogas.push({ id: 'easy_money', name: 'Easy Money', positive: true });
  }

  // Bandhan Yoga (9+4 without 5)
  if (nums.includes(9) && nums.includes(4) && !nums.includes(5)) {
    yogas.push({ id: 'bandhan', name: 'Constraint Energy', positive: false });
  }

  // Financial Bandhan (5+4 without 9)
  if (nums.includes(5) && nums.includes(4) && !nums.includes(9)) {
    yogas.push({ id: 'financial_bandhan', name: 'Financial Caution', positive: false });
  }

  // Vipreet Raj (2+8+4)
  if (nums.includes(2) && nums.includes(8) && nums.includes(4)) {
    yogas.push({ id: 'vipreet_raj', name: 'Adversity to Triumph', positive: true });
  }

  // 3-1-9 uplifting
  if (nums.includes(3) && nums.includes(1) && nums.includes(9)) {
    yogas.push({ id: 'uplifting_319', name: 'Full Power Triad', positive: true });
  }

  // Spiritual (3+7+9)
  if (nums.includes(3) && nums.includes(7) && nums.includes(9)) {
    yogas.push({ id: 'spiritual', name: 'Spiritual Alignment', positive: true });
  }

  // Stable Luxury (6+7+5)
  if (nums.includes(6) && nums.includes(7) && nums.includes(5)) {
    yogas.push({ id: 'stable_luxury', name: 'Stable Luxury', positive: true });
  }

  // High Intuition (1+7+8)
  if (nums.includes(1) && nums.includes(7) && nums.includes(8)) {
    yogas.push({ id: 'high_intuition', name: 'High Intuition', positive: true });
  }

  // 1-8 without 7 defamation risk
  if (nums.includes(1) && nums.includes(8) && !nums.includes(7)) {
    yogas.push({ id: 'defamation_risk', name: 'Reputation Caution', positive: false });
  }

  // 7-8 without 1 misfortune
  if (nums.includes(7) && nums.includes(8) && !nums.includes(1)) {
    yogas.push({ id: 'misfortune_78', name: 'Heavy Energy Period', positive: false });
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

  // Core energy of the day from the combination
  if (comboText) {
    // Take first 2 sentences of combo text
    const sentences = comboText.split('. ').slice(0, 2).join('. ');
    parts.push(sentences);
  }

  // Daily energy layer
  parts.push(`Today's frequency adds ${dailyEnergy.essence} to this backdrop — ${dailyEnergy.in_action}.`);

  // Yoga influence if present
  if (yogaInsights.length > 0) {
    parts.push(yogaInsights[0]);
  }

  // Monthly context
  if (monthly !== daily && monthly !== antar) {
    const monthlyEnergy = NUMBER_ENERGY[monthly];
    parts.push(`The monthly undercurrent of ${monthlyEnergy.essence} means ${monthlyEnergy.drive.toLowerCase()} — let that inform your choices today.`);
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
  const { daily, maha, antar, hours, yogas, allNums } = ctx;

  const classified = hours.map(h => {
    const hourNum = h.number;
    const quality = classifyHour(hourNum, daily, maha, antar, yogas, allNums);
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

  // Separate into best, good, caution, avoid
  const best = classified.filter(h => h.classification === 'best');
  const caution = classified.filter(h => h.classification === 'caution' || h.classification === 'avoid');

  return { best, caution, all: classified };
}

function classifyHour(hourNum, daily, maha, antar, yogas, allNums) {
  // Check if this hour creates a positive combination
  const tempNums = [...new Set([...allNums, hourNum])];

  // Best: creates Easy Money, Raj Yoga, 1-9-3, or 1-7
  if (tempNums.includes(5) && tempNums.includes(7) && !allNums.includes(5)) {
    return { type: 'best', reason: 'Easy Money activated this hour', good_for: ['financial decisions', 'business', 'negotiations'], avoid: [] };
  }
  if (tempNums.includes(1) && tempNums.includes(2) && !allNums.includes(1)) {
    return { type: 'best', reason: 'Authority and influence peak this hour', good_for: ['important meetings', 'decisions', 'leadership moments'], avoid: [] };
  }
  if (hourNum === 7 && allNums.includes(1) && !allNums.includes(8)) {
    return { type: 'best', reason: 'Luck is at its peak this hour', good_for: ['important asks', 'key decisions', 'travel'], avoid: [] };
  }
  if (hourNum === 1 && allNums.includes(9)) {
    return { type: 'best', reason: 'Full power available this hour', good_for: ['ambitious moves', 'leadership', 'starting things'], avoid: [] };
  }

  // Caution: creates Bandhan or Financial Bandhan
  if (hourNum === 4 && allNums.includes(9) && !allNums.includes(5)) {
    return { type: 'avoid', reason: 'Constraint energy peaks — avoid major decisions', good_for: ['rest', 'reflection'], avoid: ['contracts', 'major purchases', 'confrontations'] };
  }
  if (hourNum === 4 && allNums.includes(5) && !allNums.includes(9)) {
    return { type: 'caution', reason: 'Financial impulsiveness risk this hour', good_for: ['analysis', 'planning'], avoid: ['purchases', 'financial commitments'] };
  }
  if (hourNum === 8 && allNums.includes(7) && !allNums.includes(1)) {
    return { type: 'caution', reason: 'Heavier energy this hour — stay grounded', good_for: ['deep work', 'spiritual practice'], avoid: ['important launches', 'social events'] };
  }

  // Neutral based on daily energy
  const hourQuality = HOUR_QUALITIES[hourNum];
  const dailyQuality = HOUR_QUALITIES[daily];

  // Check alignment with daily energy
  const aligned = isAligned(hourNum, daily, maha, antar);
  if (aligned.positive) return { type: 'good', reason: aligned.reason, ...hourQuality };
  if (aligned.negative) return { type: 'caution', reason: aligned.reason, good_for: hourQuality.good_for, avoid: hourQuality.avoid };

  return { type: 'neutral', reason: 'Standard energy this hour', ...hourQuality };
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
export function generateWeeklyPrediction(ctx) {
  const { basic, destiny, maha, antar, monthly, yogas, modifiers, freqMap } = ctx;

  const baseText = PERIOD_PREDICTIONS.weekly[antar] || PERIOD_PREDICTIONS.weekly[maha];

  // Add yoga context
  const yogaContext = getYogaContext(yogas, 'weekly');

  // Add modifier context
  const modifierContext = modifiers
    .slice(0, 2)
    .map(m => CHART_MODIFIERS[m])
    .filter(Boolean)
    .join(' ');

  // Finance signal
  const financeSignal = getFinanceSignal(freqMap, maha, antar, 'weekly');

  // Health watch
  const healthWatch = getHealthWatch(basic, destiny, maha, antar);

  // Relationship signal
  const relSignal = getRelationshipSignal(maha, antar, yogas, 'weekly');

  return {
    overview: baseText,
    opportunities: buildOpportunities(maha, antar, yogas, 'weekly'),
    watch_out: buildWatchOut(maha, antar, yogas, freqMap, 'weekly'),
    finance: financeSignal,
    relationships: relSignal,
    health: healthWatch,
    yoga_context: yogaContext,
  };
}

// ─── Generate monthly prediction ─────────────────────────────────────────────
export function generateMonthlyPrediction(ctx) {
  const { basic, destiny, maha, antar, monthly, yogas, modifiers, freqMap } = ctx;

  const baseText = PERIOD_PREDICTIONS.monthly[monthly] || PERIOD_PREDICTIONS.monthly[antar];

  const yogaContext = getYogaContext(yogas, 'monthly');
  const financeSignal = getFinanceSignal(freqMap, maha, antar, 'monthly');
  const healthWatch = getHealthWatch(basic, destiny, maha, antar);
  const relSignal = getRelationshipSignal(maha, antar, yogas, 'monthly');
  const careerSignal = getCareerSignal(maha, antar, yogas, basic, destiny, 'monthly');

  return {
    overview: baseText,
    opportunities: buildOpportunities(maha, antar, yogas, 'monthly'),
    watch_out: buildWatchOut(maha, antar, yogas, freqMap, 'monthly'),
    finance: financeSignal,
    relationships: relSignal,
    health: healthWatch,
    career: careerSignal,
    yoga_context: yogaContext,
  };
}

// ─── Generate yearly prediction ───────────────────────────────────────────────
export function generateYearlyPrediction(ctx) {
  const { basic, destiny, maha, antar, yogas, modifiers, freqMap } = ctx;

  const baseText = PERIOD_PREDICTIONS.yearly[maha];
  const comboText = DASHA_COMBO_PREDICTIONS[`${maha}_${antar}`] || '';

  const yogaContext = getYogaContext(yogas, 'yearly');
  const financeSignal = getFinanceSignal(freqMap, maha, antar, 'yearly');
  const healthWatch = getHealthWatch(basic, destiny, maha, antar);
  const relSignal = getRelationshipSignal(maha, antar, yogas, 'yearly');
  const careerSignal = getCareerSignal(maha, antar, yogas, basic, destiny, 'yearly');

  const allModifiers = modifiers.map(m => CHART_MODIFIERS[m]).filter(Boolean);

  return {
    overview: baseText,
    this_year_specifically: comboText,
    opportunities: buildOpportunities(maha, antar, yogas, 'yearly'),
    watch_out: buildWatchOut(maha, antar, yogas, freqMap, 'yearly'),
    finance: financeSignal,
    relationships: relSignal,
    health: healthWatch,
    career: careerSignal,
    life_context: allModifiers.slice(0, 3),
    yoga_context: yogaContext,
  };
}

// ─── Generate life prediction ─────────────────────────────────────────────────
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
