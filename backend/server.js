import express from 'express';
import cors from 'cors';
import {
  NUMBER_TRAITS, COMBINATIONS, YOGAS, COMPATIBILITY as COMPAT_TABLE,
  HEALTH_MAP, PROFESSION_MAP, LUCKY_INFO_FULL,
  analyzeGrid, getDashaBehavior, getDashaPrediction,
  generatePrediction, prashna, PLANET_DESC
} from './predictions.js';
import {
  basicNumber, destinyNumber, supportiveNumbers, chartDigits,
  currentMahadasha, currentAntardasha, currentMonthlyDasha,
  mahadashaTimeline, antardashaTimeline,
  dailyDasha, hourlyDasha, allHourlyDashas,
  buildGrid, buildFrequencyMap, getDayRating,
  compatibility, karmicDebt, nameNumerology,
  PLANET_NAMES, LUCKY_INFO
} from './numerology.js';
import {
  buildChartContext,
  generateDailyPrediction,
  generateHourlyPredictions,
  generateWeeklyPrediction,
  generateMonthlyPrediction,
  generateYearlyPrediction,
  generateLifePrediction,
  getDeepCombination,
  getPersonalPattern,
  getDashaExperience,
  getDeepNumberProfile,
  getHonestWarnings,
  getDeepPeriodText,
} from './prediction_engine.js';

const app = express();
app.use(cors());
app.use(express.json());

// ─── Health check ─────────────────────────────────────────────
app.get('/', (req, res) => res.json({ status: 'Aastrosphere API running' }));

// ─── /api/chart ───────────────────────────────────────────────
// Full chart: grid, basic, destiny, supportive, all dashas
app.post('/api/chart', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    const d = new Date(dob);
    const day = d.getDate();
    const basic = basicNumber(day);
    const destiny = destinyNumber(dob);
    const supportive = supportiveNumbers(day);
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const monthly = currentMonthlyDasha(dob);
    const grid = buildGrid(dob);
    const freqMap = buildFrequencyMap(dob);
    const karmic = karmicDebt(dob);
    const lucky = LUCKY_INFO[destiny];

    res.json({
      basic, basicPlanet: PLANET_NAMES[basic],
      destiny, destinyPlanet: PLANET_NAMES[destiny],
      supportive,
      maha, antar, monthly,
      grid, freqMap,
      karmic, lucky,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/today ───────────────────────────────────────────────
app.post('/api/today', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    const today = new Date().toISOString();
    const ctx = buildChartContext(dob, today);
    const daily = generateDailyPrediction(ctx);
    const hourly = generateHourlyPredictions(ctx);

    res.json({
      date: today,
      daily_number: ctx.daily,
      rating: daily.rating,
      quote: daily.quote,
      insight: daily.insight,
      what_to_do: daily.what_to_do,
      what_to_avoid: daily.what_to_avoid,
      yoga_messages: daily.yoga_messages,
      active_yogas: daily.active_yogas,
      best_hours: hourly.best,
      caution_hours: hourly.caution,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/dashas ──────────────────────────────────────────────
app.post('/api/dashas', (req, res) => {
  try {
    const { dob, type, pastYears, futureYears } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    if (type === 'antardasha') {
      return res.json({ timeline: antardashaTimeline(dob, pastYears || 5, futureYears || 10) });
    }
    res.json({ timeline: mahadashaTimeline(dob, pastYears || 20, futureYears || 50) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/hourly ──────────────────────────────────────────────
app.post('/api/hourly', (req, res) => {
  try {
    const { dob, date } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = date || new Date().toISOString();
    res.json({ hours: allHourlyDashas(dob, targetDate) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/compatibility ───────────────────────────────────────
app.post('/api/compatibility', (req, res) => {
  try {
    const { dob1, dob2 } = req.body;
    if (!dob1 || !dob2) return res.status(400).json({ error: 'dob1 and dob2 required' });

    const result = compatibility(dob1, dob2);
    const chart1 = {
      basic: basicNumber(new Date(dob1).getDate()),
      destiny: destinyNumber(dob1),
      maha: currentMahadasha(dob1),
      antar: currentAntardasha(dob1),
      grid: buildGrid(dob1),
    };
    const chart2 = {
      basic: basicNumber(new Date(dob2).getDate()),
      destiny: destinyNumber(dob2),
      maha: currentMahadasha(dob2),
      antar: currentAntardasha(dob2),
      grid: buildGrid(dob2),
    };

    res.json({ ...result, chart1, chart2 });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/name ────────────────────────────────────────────────
app.post('/api/name', (req, res) => {
  try {
    const { name, dob } = req.body;
    if (!name || !dob) return res.status(400).json({ error: 'name and dob required' });
    res.json(nameNumerology(name, dob));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/karmic ──────────────────────────────────────────────
app.post('/api/karmic', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    res.json(karmicDebt(dob));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/custom-chart ────────────────────────────────────────
// Astrologer feature: chart for any date
app.post('/api/custom-chart', (req, res) => {
  try {
    const { dob, targetDate } = req.body;
    if (!dob || !targetDate) return res.status(400).json({ error: 'dob and targetDate required' });

    const d = new Date(targetDate);
    const daily = dailyDasha(dob, targetDate);
    const hours = allHourlyDashas(dob, targetDate);
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const monthly = currentMonthlyDasha(dob);
    const grid = buildGrid(dob, maha.number, antar.number, monthly.number);
    const rating = getDayRating(dob, targetDate);

    res.json({ targetDate, daily, dailyPlanet: PLANET_NAMES[daily], hours, maha, antar, monthly, grid, rating });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/full ────────────────────────────────────────
// Complete prediction — profile + grid + yogas + dasha behavior + prediction text
app.post('/api/predict/full', (req, res) => {
  try {
    const { dob, targetDate } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const result = generatePrediction(dob, targetDate || new Date().toISOString());
    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/number ─────────────────────────────────────
// Deep meaning of any number — traits, health, profession, dasha behavior
app.post('/api/predict/number', (req, res) => {
  try {
    const { number } = req.body;
    if (!number || number < 1 || number > 9) return res.status(400).json({ error: 'number 1-9 required' });
    res.json({
      number,
      planet: PLANET_DESC[number],
      traits: NUMBER_TRAITS[number],
      health: HEALTH_MAP[number],
      professions: PROFESSION_MAP[number],
      lucky: LUCKY_INFO_FULL[number],
      dasha_behavior: getDashaBehavior(number, 0),
      dasha_prediction: getDashaPrediction(number),
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/yogas ──────────────────────────────────────
// Detect all active yogas in current chart
app.post('/api/predict/yogas', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const yogas = analyzeGrid(dob, maha.number, antar.number);
    const freqMap = buildFrequencyMap(dob, maha.number, antar.number);
    res.json({ yogas, freqMap, maha, antar });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/dasha-insight ──────────────────────────────
// What does current dasha mean — behavior + prediction
app.post('/api/predict/dasha-insight', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const freqMap = buildFrequencyMap(dob, maha.number, antar.number);
    const mahaCount = freqMap[maha.number] || 0;
    const antarCount = freqMap[antar.number] || 0;

    res.json({
      maha: {
        ...maha,
        countInGrid: mahaCount,
        behavior: getDashaBehavior(maha.number, mahaCount),
        prediction: getDashaPrediction(maha.number),
        planet: PLANET_DESC[maha.number],
        traits: NUMBER_TRAITS[maha.number],
      },
      antar: {
        ...antar,
        countInGrid: antarCount,
        behavior: getDashaBehavior(antar.number, antarCount),
        prediction: getDashaPrediction(antar.number),
        planet: PLANET_DESC[antar.number],
        traits: NUMBER_TRAITS[antar.number],
      },
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/health ─────────────────────────────────────
app.post('/api/predict/health', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const basic = basicNumber(new Date(dob).getDate());
    const destiny = destinyNumber(dob);
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const freqMap = buildFrequencyMap(dob, maha.number, antar.number);

    const watchNumbers = [...new Set([basic, destiny, maha.number, antar.number])];
    const healthWatch = watchNumbers.map(n => ({
      number: n,
      planet: PLANET_NAMES[n],
      count: freqMap[n] || 0,
      ...HEALTH_MAP[n],
    }));

    // Period warnings
    const warnings = [];
    if (antar.number === 4) warnings.push('Yearly Dasha 4 is hazardous — extra health caution needed.');
    if (antar.number === 2) warnings.push('Yearly Dasha 2 — watch emotional and mental health.');
    if (freqMap[9] && freqMap[4]) warnings.push('9-4 combination active — mental health and accident risk elevated.');
    if (freqMap[5] && freqMap[4]) warnings.push('5-4 combination active — health and litigation risk.');

    res.json({ healthWatch, warnings, freqMap });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/finance ────────────────────────────────────
app.post('/api/predict/finance', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const freqMap = buildFrequencyMap(dob, maha.number, antar.number);
    const nums = Object.keys(freqMap).map(Number);

    const positive_indicators = [];
    const negative_indicators = [];

    if (nums.includes(1)) positive_indicators.push('Number 1 present — bulk money, promotions, government connections.');
    if (nums.includes(5)) positive_indicators.push('Number 5 present — cash flow, business opportunities, financial gains.');
    if (nums.includes(6)) positive_indicators.push('Number 6 present — financial prosperity and luxury.');
    if ((freqMap[8] || 0) % 2 === 0 && freqMap[8] > 0) positive_indicators.push('Even 8 (88) present — bulk gains, bonuses, promotions.');
    if (nums.includes(1) && nums.includes(9) && nums.includes(3)) positive_indicators.push('319 combination — uplifting period for finances.');
    if (nums.includes(6) && nums.includes(7) && nums.includes(5)) positive_indicators.push('675 combination — realization of desires.');

    if (nums.includes(4) && (freqMap[4] % 2 !== 0)) negative_indicators.push('Odd 4 present — expenses, impulsive spending, financial caution needed.');
    if (nums.includes(9) && nums.includes(4) && !nums.includes(5)) negative_indicators.push('Bandhan Yoga (9-4) — financial restrictions, feeling stuck.');
    if (nums.includes(5) && nums.includes(4) && !nums.includes(9)) negative_indicators.push('Financial Bandhan (5-4) — debt risk, impulsive spending.');
    if ((freqMap[9] || 0) >= 2) negative_indicators.push('Multiple 9 — frustration may affect financial decisions.');

    res.json({
      maha, antar, freqMap,
      positive_indicators,
      negative_indicators,
      overall: positive_indicators.length > negative_indicators.length ? 'favorable' : negative_indicators.length > positive_indicators.length ? 'challenging' : 'mixed',
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/relationship ───────────────────────────────
app.post('/api/predict/relationship', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const antar = currentAntardasha(dob);
    const maha = currentMahadasha(dob);
    const freqMap = buildFrequencyMap(dob, maha.number, antar.number);
    const destiny = destinyNumber(dob);

    const marriage_indicators = [];
    const caution_indicators = [];
    const romance_indicators = [];

    // Marriage favorable
    if ([3, 2, 7, 6, 9].includes(antar.number)) {
      const priority = antar.number === 3 ? 'HIGH' : 'MEDIUM';
      marriage_indicators.push({ priority, text: `Yearly Dasha ${antar.number} — favorable for marriage/deepening relationships.` });
    }

    // Romance
    const nums = Object.keys(freqMap).map(Number);
    if (nums.includes(6) && nums.includes(2)) romance_indicators.push('6-2 combination — strong romantic/attraction energy.');
    if (nums.includes(6) && nums.includes(7)) romance_indicators.push('6-7 combination — multiple love interests, attractive aura.');
    if (nums.includes(7) && nums.includes(5)) romance_indicators.push('7-5 combination — easy attraction, easy relationships.');
    if (nums.includes(1) && nums.includes(7)) romance_indicators.push('1-7 (Raj Yoga) — love affairs, ongoing romantic luck.');

    // Caution
    if (antar.number === 4) caution_indicators.push('Yearly Dasha 4 — risk of cheating or fraud in relationship.');
    if ((freqMap[6] || 0) >= 2) caution_indicators.push('Multiple 6 — conflicts, disputes, harsh speech in relationships.');
    if ((freqMap[7] || 0) >= 2) caution_indicators.push('Multiple 7 — instability, potential separation risk.');
    if ((freqMap[9] || 0) >= 2) caution_indicators.push('Multiple 9 — aggression, physical conflict risk.');
    if (maha.number === 4) caution_indicators.push('Maha Dasha 4 — separation risk, relationship disruptions.');

    res.json({ maha, antar, freqMap, destiny, marriage_indicators, romance_indicators, caution_indicators });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/predict/prashna ────────────────────────────────────
app.post('/api/predict/prashna', (req, res) => {
  try {
    const { number } = req.body;
    if (!number) return res.status(400).json({ error: 'number required (1-108)' });
    res.json(prashna(Number(number)));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// ─── /api/insights/deep ─────────────────────────────────────────
// Returns the deep profile — personal patterns, dasha experience, honest warnings
app.post('/api/insights/deep', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    const d = new Date(dob);
    const basic = basicNumber(d.getDate());
    const destiny = destinyNumber(dob);
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const monthly = currentMonthlyDasha(dob);
    const natalFreq = buildFrequencyMap(dob, undefined, undefined, undefined, true);
    const annualFreq = buildFrequencyMap(dob, maha.number, antar.number, monthly.number);
    const natalNums = Object.keys(natalFreq).map(Number);
    const annualNums = Object.keys(annualFreq).map(Number);

    // Build yogas for warnings
    const ctx = buildChartContext(dob);
    const yogas = ctx.yogas;

    // Core profile
    const basicProfile = getDeepNumberProfile(basic);
    const destinyProfile = getDeepNumberProfile(destiny);
    const combo = getDeepCombination(basic, destiny);
    const pattern = getPersonalPattern(basic, destiny);
    const dashaExp = getDashaExperience(maha.number);
    const warnings = getHonestWarnings(yogas, annualFreq, maha.number, antar.number);

    // Natal combination insights (all natal pairs)
    const natalCombos = [];
    for (let i = 0; i < natalNums.length; i++) {
      for (let j = i+1; j < natalNums.length; j++) {
        const c = getDeepCombination(natalNums[i], natalNums[j]);
        if (c) natalCombos.push({ numbers: [natalNums[i], natalNums[j]], ...c });
      }
    }

    res.json({
      basic, destiny,
      maha: maha.number, antar: antar.number,

      // Who you are
      core_nature: basicProfile ? {
        pattern: basicProfile.pattern,
        internal_conflict: basicProfile.internal_conflict,
        shadow: basicProfile.shadow,
        what_trips_you: basicProfile.what_trips_you,
      } : null,

      // Life direction
      life_direction: destinyProfile ? {
        pattern: destinyProfile.pattern,
        money_pattern: destinyProfile.money_pattern,
        love_pattern: destinyProfile.love_pattern,
        work_pattern: destinyProfile.work_pattern,
        health_real: destinyProfile.health_real,
      } : null,

      // Basic + Destiny combination
      core_combination: combo ? {
        name: combo.name,
        what_it_creates: combo.what_it_creates,
        the_conflict: combo.the_conflict,
        real_life: combo.real_life,
        warning: combo.warning,
        advice: combo.advice,
      } : null,

      // Personal repeating patterns
      personal_patterns: pattern ? {
        money: pattern.money,
        love: pattern.love,
        work: pattern.work,
        recurring_lesson: pattern.recurring_lesson,
      } : null,

      // Current multi-year period experience
      current_chapter: dashaExp ? {
        title: dashaExp.title,
        what_it_feels_like: dashaExp.what_it_feels_like,
        what_is_actually_happening: dashaExp.what_is_actually_happening,
        the_trap: dashaExp.the_trap,
        the_gift: dashaExp.the_gift,
        advice: dashaExp.advice,
      } : null,

      // Active yogas
      active_yogas: yogas,

      // Honest warnings (no sugar coating)
      warnings: warnings.map(w => ({
        short: w.short,
        detail: w.detail,
        probability: w.probability,
      })),

      // Notable natal combinations
      natal_combinations: natalCombos.slice(0, 4).map(c => ({
        numbers: c.numbers,
        name: c.name,
        what_it_creates: c.what_it_creates,
        warning: c.warning,
        advice: c.advice,
      })),
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/insights/daily ──────────────────────────────────────
app.post('/api/insights/daily', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const ctx = buildChartContext(dob);
    const daily = generateDailyPrediction(ctx);
    const hourly = generateHourlyPredictions(ctx);
    res.json({ ...daily, best_hours: hourly.best, caution_hours: hourly.caution });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── /api/insights/weekly ─────────────────────────────────────
app.post('/api/insights/weekly', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = new Date().toISOString();
    const ctx = buildChartContext(dob, targetDate);
    res.json(generateWeeklyPrediction(ctx, targetDate));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── /api/insights/monthly ────────────────────────────────────
app.post('/api/insights/monthly', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = new Date().toISOString();
    const ctx = buildChartContext(dob, targetDate);
    res.json(generateMonthlyPrediction(ctx, targetDate));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── /api/insights/yearly ─────────────────────────────────────
app.post('/api/insights/yearly', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = new Date().toISOString();
    const ctx = buildChartContext(dob, targetDate);
    res.json(generateYearlyPrediction(ctx, targetDate));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── /api/insights/life ───────────────────────────────────────
app.post('/api/insights/life', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const ctx = buildChartContext(dob);
    res.json(generateLifePrediction(ctx));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Aastrosphere API running on port ${PORT}`));
