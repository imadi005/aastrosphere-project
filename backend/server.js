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
  getPrimaryAction,
} from './prediction_engine.js';
import { PAIR_DYNAMICS, NUMBER_IN_RELATIONSHIP, getTodayCompatibility } from './compatibility_library.js';
import { analyzeDayChart, getDayScore } from './chart_analysis_library.js';
import { buildSystemPrompt, classifyQuestion, extractOtherDob, extractDateTimeFromQuestion, buildHistoricalContext, extractYearFromQuestion, buildYearAccidentAnalysis } from './ask_engine.js';
import { buildScanContext } from './event_scanner.js';
import { DEEP_NUMBER_PROFILES, DEEP_COMBINATIONS as DEEP_COMBINATION_LIBRARY } from './deep_library.js';

const app = express();
app.use(cors());
app.use(express.json());

// ─── Health check ─────────────────────────────────────────────
app.get('/', (req, res) => res.json({ status: 'Aastrosphere API running' }));

// ─── /api/chart ───────────────────────────────────────────────
// Full chart: grid, basic, destiny, supportive, all dashas
// ─── Chart builder helper ────────────────────────────────────────────────────
// Grid position map: which [row,col] each number 1-9 occupies
const GRID_POSITIONS = { 1:[0,1], 2:[2,0], 3:[0,0], 4:[2,2], 5:[1,2], 6:[1,0], 7:[1,1], 8:[2,1], 9:[0,2] };
const GRID_PLANETS = ['Jupiter','Sun','Mars','Venus','Ketu','Mercury','Moon','Saturn','Rahu'];
const CELL_PLANETS = {
  '0,0':'Jupiter','0,1':'Sun','0,2':'Mars',
  '1,0':'Venus',  '1,1':'Ketu','1,2':'Mercury',
  '2,0':'Moon',   '2,1':'Saturn','2,2':'Rahu',
};

function buildChartData(dob, targetDate, targetHour = null) {
  const d = new Date(dob);
  const day = d.getDate();
  const basic = basicNumber(day);
  const destiny = destinyNumber(dob);
  const supportive = supportiveNumbers(day);
  const maha = currentMahadasha(dob);
  const antar = currentAntardasha(dob);
  const monthly = currentMonthlyDasha(dob, targetDate);
  const karmic = karmicDebt(dob);
  const lucky = LUCKY_INFO[destiny];

  function redToSingle(n) { while(n > 9) { n = String(n).split('').reduce((a,b)=>a+parseInt(b),0); } return n; }

  // Daily number for the target date
  const targetD = new Date(targetDate);
  const weekday = targetD.getDay();
  const WEEKDAY_LORDS = [1, 2, 9, 5, 3, 6, 8]; // Sun-Sat
  const dayLord = WEEKDAY_LORDS[weekday];
  const dailyNum = redToSingle(monthly.number + dayLord);

  // Hourly number if time provided
  let hourlyNum = null;
  if (targetHour !== null && targetHour >= 0 && targetHour <= 23) {
    const hour12 = targetHour === 0 ? 12 : targetHour > 12 ? targetHour - 12 : targetHour;
    hourlyNum = redToSingle(dailyNum + hour12);
  }

  // Build enhanced grid — inject daily/hourly into their grid cell even if absent from natal
  const rawGrid = buildGrid(dob);

  // Deep clone grid
  const enhancedGrid = rawGrid.map(row => row.map(cell => cell.map(item => ({...item}))));

  // Always inject daily as a FRESH entry — never just highlight existing natal
  // This ensures the number appears twice if it's already in natal chart
  const dailyPos = GRID_POSITIONS[dailyNum];
  if (dailyPos) {
    const [dr, dc] = dailyPos;
    enhancedGrid[dr][dc] = [...enhancedGrid[dr][dc], {
      value: dailyNum,
      highlight: 'daily',
      planet: CELL_PLANETS[`${dr},${dc}`] || '',
      injected: true,
    }];
  }

  // Always inject hourly as a FRESH entry — same logic
  if (hourlyNum !== null) {
    const hourlyPos = GRID_POSITIONS[hourlyNum];
    if (hourlyPos) {
      const [hr, hc] = hourlyPos;
      enhancedGrid[hr][hc] = [...enhancedGrid[hr][hc], {
        value: hourlyNum,
        highlight: 'hourly',
        planet: CELL_PLANETS[`${hr},${hc}`] || '',
        injected: true,
      }];
    }
  }

  // Day analysis — combinations, warnings, opportunities
  const natalNums = Object.keys(buildFrequencyMap(dob)).map(Number);
  const dayAnalysis = analyzeDayChart({
    basic, destiny,
    maha: maha.number, antar: antar.number,
    monthly: monthly.number, daily: dailyNum,
    hourly: hourlyNum,
    natalNums,
  });
  const dayScore = getDayScore({
    basic, destiny,
    maha: maha.number, antar: antar.number,
    monthly: monthly.number, daily: dailyNum,
    natalNums,
  });

  return {
    basic, basicPlanet: PLANET_NAMES[basic],
    destiny, destinyPlanet: PLANET_NAMES[destiny],
    supportive,
    maha, antar, monthly,
    daily: dailyNum,
    hourly: hourlyNum,
    target_date: targetD.toISOString().slice(0, 10),
    target_hour: targetHour,
    grid: enhancedGrid,
    freqMap: buildFrequencyMap(dob, maha.number, antar.number, monthly.number),
    lucky,
    day_analysis: dayAnalysis,
    day_score: dayScore,
  };
}

app.post('/api/chart', (req, res) => {
  try {
    const { dob, client_date, client_hour } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = client_date ? new Date(client_date).toISOString() : new Date().toISOString();
    const hour = (client_hour !== undefined && client_hour !== null) ? parseInt(client_hour) : new Date().getHours();
    res.json(buildChartData(dob, targetDate, hour));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/chart/date — chart for any date+time ───────────────────────────────
app.post('/api/chart/date', (req, res) => {
  try {
    const { dob, date, hour } = req.body;
    if (!dob || !date) return res.status(400).json({ error: 'dob and date required' });
    const targetHour = (hour !== undefined && hour !== null) ? parseInt(hour) : null;
    res.json(buildChartData(dob, new Date(date).toISOString(), targetHour));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/today ───────────────────────────────────────────────
app.post('/api/today', (req, res) => {
  try {
    const { dob, client_date, client_hour } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    // Always use client's local date/time — server runs UTC which differs by timezone
    const now = client_date ? new Date(client_date) : new Date();
    const today = now.toISOString();
    const currentHour = (client_hour !== undefined && client_hour !== null)
      ? parseInt(client_hour)
      : now.getHours();

    const ctx = buildChartContext(dob, today);
    const daily = generateDailyPrediction(ctx);
    const hourly = generateHourlyPredictions(ctx);

    // Structural yogas (positive — for pills display)
    const structuralYogas = (daily.active_yogas || [])
      .filter(y => !y.combo_key && y.positive);
    
    // Combo yogas (Running Energy, Monthly Energy, Today's Drive)
    const comboYogas = (daily.active_yogas || [])
      .filter(y => y.combo_key);

    // Primary action — chart-specific, from yogas + daily number
    const primaryActionData = getPrimaryAction(ctx);
    const primaryAction = primaryActionData.do;
    const primaryAvoid = primaryActionData.avoid;

    // ── Accident risk detection ──────────────────────────────────────────────
    function getAccidentRisk(hourNum, daily, maha, antar, monthly) {
      const risks = [];
      // 6-layer check — hourly risk only when multiple layers confirm 4+9 combination
      const natalN = Object.keys(ctx.freqMap || {}).map(Number);
      const h4 = { maha: ctx.maha===4, antar: ctx.antar===4, monthly: ctx.monthly===4, daily: daily===4, natal: natalN.includes(4), hour: hourNum===4 };
      const h9 = { maha: ctx.maha===9, antar: ctx.antar===9, monthly: ctx.monthly===9, daily: daily===9, natal: natalN.includes(9), hour: hourNum===9 };
      // Condition 7: Rahu hour + Mars day + confirmed by natal/maha/antar
      if (h4.hour && h9.daily && (h4.maha || h4.antar || h9.maha || h9.antar || h4.natal || h9.natal))
        risks.push({ level: 'high', reason: 'High accident risk this hour. Avoid speeding, sharp tools, and anything requiring precision right now.' });
      // Condition 8: Mars hour + Rahu day + confirmed by natal/maha/antar
      else if (h9.hour && h4.daily && (h4.maha || h4.antar || h9.maha || h9.antar || h4.natal || h9.natal))
        risks.push({ level: 'high', reason: 'High accident risk this hour. Slow down — impulsive moves cause physical damage right now.' });
      // Condition 9: Double Rahu hour+day with natal confirmation
      else if (h4.hour && h4.daily && (h4.natal || h9.natal))
        risks.push({ level: 'high', reason: 'Very high accident risk this hour. Do not rush. Double-check everything before you act.' });
      return risks;
    }

    // Find accident risk hours with 1-hour advance warning
    const accidentRiskHours = [];
    for (const h of (hourly.all || [])) {
      const risks = getAccidentRisk(h.number, ctx.daily, ctx.maha, ctx.antar, ctx.monthly);
      if (risks.length > 0) {
        accidentRiskHours.push({
          hour: h.hour,
          risk_level: risks[0].level,
          reason: risks[0].reason,
          warn_at_hour: h.hour - 1, // notify 1 hour before
          time_label: `${h.hour > 12 ? h.hour - 12 : h.hour === 0 ? 12 : h.hour}:00 ${h.hour < 12 ? 'AM' : 'PM'}`,
          warn_time_label: `${(h.hour-1) > 12 ? (h.hour-1) - 12 : (h.hour-1) === 0 ? 12 : (h.hour-1)}:00 ${(h.hour-1) < 12 ? 'AM' : 'PM'}`,
        });
      }
    }

    // Daily accident risk summary
    const dailyAccidentRisk = (() => {
      const RISK_COMBOS = [
        [4,9],[9,4],[4,4],[4,8],[8,4],[9,9]
      ];
      const hasDailyRisk = RISK_COMBOS.some(([a,b]) => ctx.daily===a && ctx.maha===b)
        || RISK_COMBOS.some(([a,b]) => ctx.daily===a && ctx.antar===b)
        || (ctx.daily === 4 && ctx.monthly === 9)
        || (ctx.daily === 9 && ctx.monthly === 4);
      // Daily risk — only when 4+9 cross confirmed in maha/antar + daily
      const dn = Object.keys(ctx.freqMap || {}).map(Number);
      if (ctx.daily === 4 && ctx.maha === 9) return { level: 'high', reason: 'High accident risk today. Stay alert, drive carefully, avoid risky physical activities.' };
      else if (ctx.daily === 9 && ctx.maha === 4) return { level: 'high', reason: 'High accident risk today. Slow down — impulsive moves lead to physical damage.' };
      else if (ctx.daily === 4 && ctx.antar === 9) return { level: 'high', reason: 'High accident risk today. Physical caution essential — avoid rushing.' };
      else if (ctx.daily === 9 && ctx.antar === 4) return { level: 'high', reason: 'High accident risk today. Sudden situations can cause physical harm — stay alert.' };
      else if (ctx.daily === 4 && ctx.monthly === 9 && (dn.includes(4) || dn.includes(9))) return { level: 'medium', reason: 'Accident risk today. Extra care with driving, physical tasks, and machinery.' };
      else if (ctx.daily === 9 && ctx.monthly === 4 && (dn.includes(4) || dn.includes(9))) return { level: 'medium', reason: 'Accident risk today. Verify before acting — impulsive decisions cause physical damage.' };
      if (hasDailyRisk) return { level: 'medium', reason: 'Elevated physical caution recommended today' };
      return null;
    })();

    // All hours with full detail for clickable cards
    const allHours = (hourly.all || []).map(h => ({
      ...h,
      // Ensure good_for and avoid arrays are present
      good_for: h.good_for || [],
      avoid: h.avoid || [],
    }));

    // Best hours — just hour + 1-liner reason
    const bestHourSummaries = (hourly.best || []).map(h => ({
      hour: h.hour,
      reason: h.reason || '',
      good_for: (h.good_for || []).slice(0, 2),
    }));

    // Caution hours — just hour + 1-liner reason
    const cautionHourSummaries = (hourly.caution || []).map(h => ({
      hour: h.hour,
      reason: h.reason || '',
      avoid: (h.avoid || []).slice(0, 2),
    }));

    res.json({
      date: today,
      daily_number: ctx.daily,
      rating: daily.rating,
      quote: daily.quote,
      insight: daily.insight,
      layers: daily.layers,
      what_to_do: daily.what_to_do,
      what_to_avoid: daily.what_to_avoid,
      primary_action: primaryAction,
      primary_avoid: primaryAvoid,
      structural_yogas: structuralYogas,
      combo_yogas: comboYogas,
      best_hours: bestHourSummaries,
      caution_hours: cautionHourSummaries,
      all_hours: allHours,
      accident_risk_hours: accidentRiskHours,
      daily_accident_risk: dailyAccidentRisk,
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

// ─── /api/compatibility ─────────────────────────────────────────────────────

app.post('/api/compatibility', (req, res) => {
  try {
    const { dob1, dob2, client_date, client_hour } = req.body;
    if (!dob1 || !dob2) return res.status(400).json({ error: 'dob1 and dob2 required' });



    const targetDate = client_date ? new Date(client_date).toISOString() : new Date().toISOString();
    const targetHour = (client_hour !== undefined) ? parseInt(client_hour) : new Date().getHours();

    function red(n) { while(n>9){n=String(n).split('').reduce((a,b)=>a+parseInt(b),0);} return n; }

    // Person 1
    const b1 = basicNumber(new Date(dob1).getDate());
    const d1 = destinyNumber(dob1);
    const maha1 = currentMahadasha(dob1);
    const antar1 = currentAntardasha(dob1);
    const monthly1 = currentMonthlyDasha(dob1, targetDate);
    const freq1 = buildFrequencyMap(dob1, maha1.number, antar1.number, monthly1.number);
    const WLORDS = [1,2,9,5,3,6,8];
    const wd = new Date(targetDate).getDay();
    const daily1 = red(monthly1.number + WLORDS[wd]);
    const h12 = targetHour===0?12:targetHour>12?targetHour-12:targetHour;
    const hourly1 = red(daily1 + h12);
    const yogas1ctx = { basic:b1, destiny:d1, maha:maha1.number, antar:antar1.number,
      monthly:monthly1.number, daily:daily1, yogas:[], freqMap:freq1, natalNums:Object.keys(freq1).map(Number),
      _dob:dob1, allNums:Object.keys(freq1).map(Number), modifiers:[], hours:[], natalFreq:{} };

    // Person 2
    const b2 = basicNumber(new Date(dob2).getDate());
    const d2 = destinyNumber(dob2);
    const maha2 = currentMahadasha(dob2);
    const antar2 = currentAntardasha(dob2);
    const monthly2 = currentMonthlyDasha(dob2, targetDate);
    const freq2 = buildFrequencyMap(dob2, maha2.number, antar2.number, monthly2.number);
    const daily2 = red(monthly2.number + WLORDS[wd]);
    const hourly2 = red(daily2 + h12);

    // Natal compatibility score
    const natalKey = [Math.min(b1,b2), Math.max(b1,b2)].join('_');
    const natalPair = PAIR_DYNAMICS[natalKey] || {};
    const destinyKey = [Math.min(d1,d2), Math.max(d1,d2)].join('_');
    const destinyPair = PAIR_DYNAMICS[destinyKey] || {};

    // ── Book-accurate scoring: Vedic planetary relationship model ────────────
    // Standard planetary friend/enemy/neutral relationships (Lo Shu / Vedic)
    const PLANET_RELS = {
      1: { f:[3,9,5], e:[2,7] },
      2: { f:[1,3],   e:[4,5,8] },
      3: { f:[1,2,9], e:[5,6] },
      4: { f:[4,6,7], e:[1,2,8] },
      5: { f:[1,4],   e:[2,3,9] },
      6: { f:[4,5],   e:[1,2,3] },
      7: { f:[4,6],   e:[1,2] },
      8: { f:[4,5,6], e:[1,2,3] },
      9: { f:[1,2,3], e:[5,6] },
    };
    function getRel(a, b) {
      const r = PLANET_RELS[a];
      if (!r) return 'n';
      if (r.f.includes(b)) return 'f';
      if (r.e.includes(b)) return 'e';
      return 'n';
    }
    function relPts(r) { return r==='f'?3:r==='n'?1:0; }

    // 4 checks, both directions averaged for fairness
    const pts =
      (relPts(getRel(b1,b2)) + relPts(getRel(b2,b1))) / 2 +  // basic-basic
      (relPts(getRel(d1,d2)) + relPts(getRel(d2,d1))) / 2 +  // destiny-destiny
      relPts(getRel(b1,d2)) +                                  // my basic vs their destiny
      relPts(getRel(d1,b2));                                   // my destiny vs their basic
    // Max = 12, raw score 0-100
    let baseScore = Math.round((pts / 12) * 100);

    // Maha dasha layer (+/- 8 based on maha relationship)
    const mahaRel = getRel(maha1.number, maha2.number);
    const mahaBoost = mahaRel==='f'?6 : mahaRel==='e'?-6 : 0;
    baseScore += mahaBoost;

    // Antar dasha layer (+/- 4)
    const antarRel = getRel(antar1.number, antar2.number);
    const antarBoost = antarRel==='f'?4 : antarRel==='e'?-4 : 0;
    baseScore += antarBoost;

    // Shared natal numbers (unique per person, small boost)
    const shared = Object.keys(freq1).filter(n => freq2[n]).length;
    baseScore += Math.min(6, shared);

    baseScore = Math.min(95, Math.max(12, Math.round(baseScore)));

    // Level
    let level, levelIcon;
    if (baseScore >= 80) { level = 'Exceptional'; levelIcon = '✦'; }
    else if (baseScore >= 65) { level = 'Strong'; levelIcon = '◈'; }
    else if (baseScore >= 50) { level = 'Good'; levelIcon = '◇'; }
    else if (baseScore >= 35) { level = 'Challenging'; levelIcon = '△'; }
    else { level = 'Complex'; levelIcon = '○'; }

    // Today's compatibility — include maha+antar+monthly for more variation
    const todayCompat = getTodayCompatibility(daily1, daily2, b1, b2,
      [maha1.number, antar1.number, monthly1.number],
      [maha2.number, antar2.number, monthly2.number]
    );

    // What each brings
    const p1brings = NUMBER_IN_RELATIONSHIP[b1] || {};
    const p2brings = NUMBER_IN_RELATIONSHIP[b2] || {};

    res.json({
      score: baseScore,
      level,
      level_icon: levelIcon,

      // Core dynamic
      core: natalPair.core || 'An interesting combination with unique dynamics.',
      strength: natalPair.strength || 'Each brings something the other lacks.',
      tension: natalPair.tension || 'The differences require conscious navigation.',
      growth: natalPair.growth || 'Both grow through genuine engagement.',

      // Relationship-type specific — label changes based on relation
      relationship_label: (req.body.relation === 'Partner') ? 'As a couple' :
                          (req.body.relation === 'Family') ? 'As family' :
                          (req.body.relation === 'Colleague') ? 'At work' :
                          'Close connection',
      romantic: natalPair.close_connection || natalPair.romantic,
      friendship: natalPair.friendship,

      // Destiny layer
      destiny_note: destinyPair.core ? `On a life path level: ${destinyPair.core}` : null,

      // What each person brings
      person1_brings: {
        basic: b1,
        destiny: d1,
        brings: p1brings.brings,
        needs: p1brings.needs,
        blind_spot: p1brings.blind_spot,
        friendship_style: p1brings.friendship_style,
        conflict_style: p1brings.conflict_style,
      },
      person2_brings: {
        basic: b2,
        destiny: d2,
        brings: p2brings.brings,
        needs: p2brings.needs,
        blind_spot: p2brings.blind_spot,
        friendship_style: p2brings.friendship_style,
        conflict_style: p2brings.conflict_style,
      },

      // Today
      today: {
        score: todayCompat.score,
        energy: todayCompat.energy,
        day_label: todayCompat.day_label,
        headline: todayCompat.headline,
        detail: todayCompat.detail,
        do_together: todayCompat.do_together,
        watch_together: todayCompat.watch_together,
        daily1,
        daily2,
      },
    });
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
    const basicProfile = getDeepNumberProfile(basic, destiny, maha.number, natalNums);
    const destinyProfile = getDeepNumberProfile(destiny, basic, maha.number, natalNums);
    const combo = getDeepCombination(basic, destiny);
    const pattern = getPersonalPattern(basic, destiny);
    const dashaExp = getDashaExperience(maha.number, antar.number);
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
    const { dob, client_date } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = client_date ? new Date(client_date).toISOString() : new Date().toISOString();
    const ctx = buildChartContext(dob, targetDate);
    res.json(generateWeeklyPrediction(ctx, targetDate));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── /api/insights/monthly ────────────────────────────────────
app.post('/api/insights/monthly', (req, res) => {
  try {
    const { dob, client_date } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = client_date ? new Date(client_date).toISOString() : new Date().toISOString();
    const ctx = buildChartContext(dob, targetDate);
    res.json(generateMonthlyPrediction(ctx, targetDate));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─── /api/insights/yearly ─────────────────────────────────────
app.post('/api/insights/yearly', (req, res) => {
  try {
    const { dob, client_date } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });
    const targetDate = client_date ? new Date(client_date).toISOString() : new Date().toISOString();
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

// ─── /api/ask ─────────────────────────────────────────────────────────────────
app.post('/api/ask', async (req, res) => {
  try {
    const { dob, messages, client_date } = req.body;
    if (!dob || !messages || !messages.length) {
      return res.status(400).json({ error: 'dob and messages required' });
    }

    const targetDate = client_date || new Date().toISOString();
    const lastMessage = messages[messages.length - 1].content;

    // Classify question
    const questionType = classifyQuestion(lastMessage);

    // Extract other person DOB if mentioned
    const otherDob = extractOtherDob(messages);

    // Detect historical date/time in question
    const dateTime = extractDateTimeFromQuestion(lastMessage);
    let historicalContext = '';
    if (dateTime?.date) {
      historicalContext = await buildHistoricalContext(dob, dateTime.date, dateTime.hour);
    }

    // Detect year-only question (e.g. "2023 mein kya chances the")
    if (!historicalContext) {
      const year = extractYearFromQuestion(lastMessage);
      const isAccidentQuestion = /accident|risk|danger|chance|khatara|safe|injury|hurt|chot|injury/i.test(lastMessage);
      if (year && isAccidentQuestion) {
        historicalContext = await buildYearAccidentAnalysis(dob, year);
      }
    }

    // Detect period scan intent (e.g. "2023 mein accident kab tha")
    let scanContext = '';
    if (!dateTime?.date) {
      scanContext = await buildScanContext(dob, lastMessage, targetDate) || '';
    }

    // Build system prompt with full chart + relevant knowledge
    let systemPrompt = buildSystemPrompt(dob, targetDate, questionType, otherDob);
    if (historicalContext) systemPrompt += historicalContext;
    if (scanContext) systemPrompt += scanContext;

    // Build conversation — add memory context if history is long
    let anthropicMessages = messages.map(m => ({
      role: m.role,
      content: m.content,
    }));

    // If history > 10 messages, inject a brief memory summary as first user message
    if (anthropicMessages.length > 10) {
      const olderMessages = anthropicMessages.slice(0, -10);
      const recentMessages = anthropicMessages.slice(-10);
      // Summarize older context into a system note
      const memorySummary = olderMessages
        .filter(m => m.role === 'user')
        .map(m => m.content.slice(0, 80))
        .join(' | ');
      // Keep only recent 10 + inject summary
      anthropicMessages = [
        { role: 'user', content: `[Previous conversation summary: ${memorySummary}]` },
        { role: 'assistant', content: 'Understood, I remember our previous conversations.' },
        ...recentMessages,
      ];
    }

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-5',
        max_tokens: 400,
        system: systemPrompt,
        messages: anthropicMessages,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      return res.status(500).json({ error: 'AI error', detail: err });
    }

    const data = await response.json();
    const answer = data.content?.[0]?.text || '';

    res.json({
      answer,
      question_type: questionType,
      other_dob_detected: otherDob,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = process.env.PORT || 3000;

// ─── /api/predict/future-risks ───────────────────────────────
// Scans next 50 years and returns risk windows by type
app.post('/api/predict/future-risks', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    const d = new Date(dob);
    const basic  = basicNumber(d.getDate());
    const destiny = destinyNumber(dob);
    const natalFreq = buildFrequencyMap(dob, undefined, undefined, undefined, true);
    const natalNums = Object.keys(natalFreq).map(Number);
    const today = new Date();
    const endYear = today.getFullYear() + 50;

    // Get maha timeline for 50 yrs
    const mahaList = mahadashaTimeline(dob, 0, 50);

    const riskWindows = [];

    for (const maha of mahaList) {
      const mahaStart = new Date(maha.start);
      const mahaEnd   = new Date(maha.end);
      if (mahaEnd < today) continue;
      if (mahaStart.getFullYear() > endYear) break;

      // For each year in this maha, get antar
      const scanStart = mahaStart < today ? today.getFullYear() : mahaStart.getFullYear();
      const scanEnd   = Math.min(mahaEnd.getFullYear(), endYear);

      const yearsSeen = new Set();
      for (let yr = scanStart; yr <= scanEnd; yr++) {
        if (yearsSeen.has(yr)) continue;
        yearsSeen.add(yr);

        const birthdayThisYear = new Date(yr, d.getMonth(), d.getDate());
        const birthdayPrevYear = new Date(yr - 1, d.getMonth(), d.getDate());
        const antarYear  = today < birthdayThisYear ? yr - 1 : yr;
        const weekday    = new Date(antarYear, d.getMonth(), d.getDate()).getDay();
        const wdVal      = { 0:1,1:2,2:9,3:5,4:3,5:6,6:8 }[weekday] ?? 1;
        const yearLast2  = antarYear % 100;
        const raw        = basic + d.getMonth() + 1 + yearLast2 + wdVal;
        const antar      = ((raw - 1) % 9) + 1; // reduce to 1-9

        const annualNums = [...new Set([...natalNums, maha.number, antar])];
        const risks = [];

        // ── ACCIDENT RISK ──────────────────────────────────────
        if (maha.number === 4 && antar === 9) {
          risks.push({ type: 'accident', level: 'high',
            title: 'Accident Risk',
            msg: 'Very risky year for accidents. Drive slow. Avoid rushing.' });
        } else if (maha.number === 9 && antar === 4) {
          risks.push({ type: 'accident', level: 'high',
            title: 'Accident Risk',
            msg: 'Big accident risk this year. Stay calm. Think before acting.' });
        } else if (maha.number === 4 && natalNums.includes(9)) {
          risks.push({ type: 'accident', level: 'medium',
            title: 'Accident Caution',
            msg: 'Be careful on roads and with sharp tools this year.' });
        } else if (maha.number === 9 && natalNums.includes(4)) {
          risks.push({ type: 'accident', level: 'medium',
            title: 'Accident Caution',
            msg: 'Impulsive actions can cause physical harm. Slow down.' });
        }

        // ── HEALTH RISK ────────────────────────────────────────
        if (maha.number === 2 || antar === 2) {
          risks.push({ type: 'health', level: 'medium',
            title: 'Mental Health Watch',
            msg: 'Risk of sadness, bad sleep, low mood. Talk to someone you trust.' });
        }
        if (maha.number === 6 && antar === 6) {
          risks.push({ type: 'health', level: 'medium',
            title: 'Hormonal Health',
            msg: 'Watch for hormonal or kidney-related issues. Drink more water.' });
        }
        if ((maha.number === 4 || antar === 4) && natalNums.includes(9)) {
          risks.push({ type: 'health', level: 'medium',
            title: 'Blood Pressure Watch',
            msg: 'BP and blood sugar can spike this year. Regular checkups needed.' });
        }
        if (maha.number === 8 && basic === 8) {
          risks.push({ type: 'health', level: 'medium',
            title: 'Bone & Joint Watch',
            msg: 'Joints and bones need care. Avoid overexertion.' });
        }

        // ── FINANCIAL RISK ─────────────────────────────────────
        if (antar === 4 && (natalNums.includes(9) && !natalNums.includes(5))) {
          risks.push({ type: 'finance', level: 'high',
            title: 'Money Loss Risk',
            msg: 'Big chance of impulsive spending or financial loss. Save first, spend later.' });
        } else if (maha.number === 4 || antar === 4) {
          risks.push({ type: 'finance', level: 'medium',
            title: 'Overspending Risk',
            msg: 'Money goes out fast this year. Make a budget and stick to it.' });
        }
        if (annualNums.includes(9) && annualNums.includes(4) && !annualNums.includes(5)) {
          risks.push({ type: 'finance', level: 'high',
            title: 'Bandhan Yoga',
            msg: 'Feeling stuck financially. Do not take big loans this year.' });
        }

        // ── RELATIONSHIP RISK ──────────────────────────────────
        if (maha.number === 4) {
          risks.push({ type: 'relationship', level: 'medium',
            title: 'Relationship Strain',
            msg: 'This long period can bring distance in close relationships. Communicate more.' });
        }
        if (antar === 4 && natalNums.includes(7)) {
          risks.push({ type: 'relationship', level: 'high',
            title: 'Betrayal Risk',
            msg: 'Be careful who you trust this year. Someone close may not be honest.' });
        }
        if (annualNums.filter(n => n === 7).length >= 2 || (natalFreq[7] >= 2 && antar === 7)) {
          risks.push({ type: 'relationship', level: 'medium',
            title: 'Separation Risk',
            msg: 'Instability in relationships. Avoid making permanent decisions out of anger.' });
        }

        // ── CAREER RISK ────────────────────────────────────────
        if (maha.number === 8 && (basic === 1 || destiny === 1)) {
          risks.push({ type: 'career', level: 'medium',
            title: 'Career Block Period',
            msg: 'Hard work required. Results come slowly. Keep going — do not quit.' });
        }
        if (antar === 4 && (basic === 5 || destiny === 5)) {
          risks.push({ type: 'career', level: 'medium',
            title: 'Business Caution',
            msg: 'Avoid starting new business this year. Old commitments need attention.' });
        }

        if (risks.length > 0) {
          riskWindows.push({
            year: yr,
            maha: { number: maha.number, planet: maha.planet },
            antar: { number: antar, planet: ['','Sun','Moon','Jupiter','Rahu','Mercury','Venus','Ketu','Saturn','Mars'][antar] ?? '' },
            risks,
          });
        }
      }
    }

    // Sort by year and deduplicate
    riskWindows.sort((a, b) => a.year - b.year);

    // Summary: count by type
    const summary = { accident: 0, health: 0, finance: 0, relationship: 0, career: 0 };
    for (const w of riskWindows) {
      for (const r of w.risks) {
        if (summary[r.type] !== undefined) summary[r.type]++;
      }
    }

    res.json({ riskWindows, summary, basic, destiny, yearsScanned: endYear - today.getFullYear() });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.listen(PORT, () => console.log(`Aastrosphere API running on port ${PORT}`));

// ─── /api/astro/life-profile — All tabs data in one call ──────────────────────
app.post('/api/astro/life-profile', async (req, res) => {
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

    // ── LIFE PATTERN (natal only) ──────────────────────────────────────────
    const basicProfile = DEEP_NUMBER_PROFILES[basic] || {};
    const destinyProfile = DEEP_NUMBER_PROFILES[destiny] || {};
    const combKey = `${basic}_${destiny}`;
    const combo = DEEP_COMBINATION_LIBRARY[combKey] || DEEP_COMBINATION_LIBRARY[`${destiny}_${basic}`] || null;

    // ── HEALTH ────────────────────────────────────────────────────────────
    const healthNums = [...new Set([basic, destiny, ...natalNums.filter(n => [4,7,8,9].includes(n))])];
    const healthCards = healthNums.map(n => ({
      number: n,
      planet: PLANET_NAMES[n],
      watch: HEALTH_MAP[n] ? HEALTH_MAP[n].common : [],
      manage: HEALTH_MAP[n] ? HEALTH_MAP[n].others.slice(0,2) : [],
    })).filter(h => h.watch.length > 0);

    // ── CAREER ────────────────────────────────────────────────────────────
    const professions = PROFESSION_MAP[destiny] || [];
    const financeCtx = buildChartContext(dob);
    const careerYogas = financeCtx.yogas.filter(y =>
      ['raj_yoga', 'sun_ketu_raj', 'easy_money'].includes(y.id));

    // ── RELATIONSHIP ──────────────────────────────────────────────────────
    const relNums = annualNums;
    const hasEasyMoney57 = relNums.includes(5) && relNums.includes(7);
    const has17 = natalNums.includes(1) && natalNums.includes(7);
    const romance = [];
    if (has17) romance.push({ label: 'Romantic luck is natural for you', icon: 'heart' });
    if (natalNums.includes(6)) romance.push({ label: 'Venus makes you attractive and charming', icon: 'star' });
    if (hasEasyMoney57) romance.push({ label: 'Easy connections happening now', icon: 'link' });
    if (basic === 2 || destiny === 2) romance.push({ label: 'Deep emotional bonds — you love fully', icon: 'heart' });

    const relCautions = [];
    if (maha.number === 9 && (basic === 2 || natalNums.includes(6)))
      relCautions.push('Mars period — short temper in relationships. Think before you speak.');
    if (natalNums.includes(4) && natalNums.includes(9))
      relCautions.push('Rahu + Mars in chart — impulsive decisions can hurt relationships.');
    if (maha.number === 8)
      relCautions.push('Saturn period — relationships feel heavy. Stay patient.');

    // ── CURRENT PERIOD ────────────────────────────────────────────────────
    const mahaKey = `${maha.number}`;
    const antarKey = `${maha.number}_${antar.number}`;
    const dashaCombText = COMBINATIONS[antarKey] || COMBINATIONS[`${antar.number}_${maha.number}`] || null;

    // Simple current summary
    const currentSummary = {
      maha: { number: maha.number, planet: PLANET_NAMES[maha.number], end: maha.end },
      antar: { number: antar.number, planet: PLANET_NAMES[antar.number], end: antar.end },
      monthly: { number: monthly.number, planet: PLANET_NAMES[monthly.number], end: monthly.end },
      combo_text: dashaCombText,
      yogas_active: financeCtx.yogas.map(y => y.name),
      period_rating: annualNums.includes(1) && annualNums.includes(2) ? 'excellent' :
                     annualNums.includes(8) && !annualNums.includes(1) ? 'challenging' :
                     annualNums.includes(4) && annualNums.includes(9) ? 'caution' : 'moderate',
    };

    res.json({
      basic, destiny,
      basic_planet: PLANET_NAMES[basic],
      destiny_planet: PLANET_NAMES[destiny],
      basic_profile: basicProfile,
      destiny_profile: destinyProfile,
      combination: combo,
      natal_nums: natalNums,
      current: currentSummary,
      health: healthCards,
      professions,
      career_yogas: careerYogas,
      finance_overall: financeCtx.yogas.some(y => y.id === 'raj_yoga' || y.id === 'easy_money') ? 'positive' : 'neutral',
      romance,
      rel_cautions: relCautions,
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

// ─── /api/astro/period-risks — Future 50yr risk scanner ──────────────────────
app.post('/api/astro/period-risks', (req, res) => {
  try {
    const { dob } = req.body;
    if (!dob) return res.status(400).json({ error: 'dob required' });

    const d = new Date(dob);
    const basic = basicNumber(d.getDate());
    const destiny = destinyNumber(dob);
    const natalFreq = buildFrequencyMap(dob, undefined, undefined, undefined, true);
    const natalNums = Object.keys(natalFreq).map(Number);
    const today = new Date();
    const endYear = today.getFullYear() + 50;

    // Get Maha timeline for 50 years
    const mahaList = mahadashaTimeline(dob, 0, 52);
    const risks = [];

    for (const maha of mahaList) {
      const mahaStart = new Date(maha.start);
      if (mahaStart.getFullYear() > endYear) break;

      // For each year in this maha period, get antar
      const mahaEndYear = Math.min(new Date(maha.end).getFullYear(), endYear);
      const mahaStartYear = mahaStart.getFullYear();

      // Sample mid-year of each antar within this maha
      for (let yr = Math.max(today.getFullYear(), mahaStartYear); yr <= mahaEndYear; yr++) {
        const sampleDate = new Date(yr, 5, 15).toISOString(); // June 15
        const antar = currentAntardasha(dob, sampleDate);
        const monthly = currentMonthlyDasha(dob, sampleDate);
        const annualNums = Object.keys(buildFrequencyMap(dob, maha.number, antar.number, monthly.number)).map(Number);

        const periodRisks = [];

        // ── ACCIDENT RISK ─────────────────────────────────────────────
        const marsCount = [maha.number, antar.number].filter(n => n === 9).length;
        const rahuCount = [maha.number, antar.number].filter(n => n === 4).length;
        const natalMars = natalNums.includes(9);
        const natalRahu = natalNums.includes(4);

        if (marsCount >= 1 && rahuCount >= 1) {
          periodRisks.push({ type: 'accident', level: 'high', label: 'High Accident Risk', desc: 'Mars + Rahu together. Drive carefully. Avoid risky physical activities.' });
        } else if (marsCount >= 2 || (marsCount >= 1 && natalMars)) {
          periodRisks.push({ type: 'accident', level: 'high', label: 'Mars Overload', desc: 'Too much Mars energy. Physical accidents more likely. Slow down.' });
        } else if ((rahuCount >= 1 && natalRahu) || (marsCount >= 1 && natalRahu)) {
          periodRisks.push({ type: 'accident', level: 'medium', label: 'Physical Caution Period', desc: 'Rahu active. Be careful with machines, vehicles and sharp objects.' });
        }

        // ── HEALTH RISK ───────────────────────────────────────────────
        if (maha.number === 8 && destiny === 8)
          periodRisks.push({ type: 'health', level: 'high', label: 'Double Saturn Period', desc: 'Body under pressure. Bones, teeth and joints need attention.' });
        else if (maha.number === 8 || antar.number === 8)
          periodRisks.push({ type: 'health', level: 'medium', label: 'Saturn Period', desc: 'Fatigue and chronic issues may surface. Rest matters more now.' });
        if (maha.number === 4 || antar.number === 4)
          periodRisks.push({ type: 'health', level: 'medium', label: 'Rahu Period', desc: 'BP and diabetes risk up. Get regular checkups.' });
        if (maha.number === 9 && (basic === 2 || natalNums.includes(6)))
          periodRisks.push({ type: 'health', level: 'medium', label: 'Stress Period', desc: 'High emotional and physical stress. Blood pressure watch.' });

        // ── FINANCE RISK ──────────────────────────────────────────────
        if (maha.number === 4 && !annualNums.includes(1) && !annualNums.includes(5))
          periodRisks.push({ type: 'finance', level: 'high', label: 'Financial Caution', desc: 'Rahu period with no protective numbers. Avoid big investments.' });
        else if ((maha.number === 8 && antar.number === 4) || (maha.number === 4 && antar.number === 8))
          periodRisks.push({ type: 'finance', level: 'high', label: 'Saturn + Rahu', desc: 'Debt risk. Do not take loans. Save first, spend later.' });
        if (annualNums.includes(5) && annualNums.includes(4) && !annualNums.includes(9))
          periodRisks.push({ type: 'finance', level: 'medium', label: 'Overspending Risk', desc: 'Financial bandhan active. Track every expense.' });

        // ── CAREER OPPORTUNITY ────────────────────────────────────────
        const leftPathClear = !natalNums.includes(3) && !natalNums.includes(6);
        if (annualNums.includes(1) && annualNums.includes(2) && leftPathClear)
          periodRisks.push({ type: 'opportunity', level: 'high', label: 'Raj Yoga Active', desc: 'Best time for career growth and authority. Push hard this period.' });
        else if (annualNums.includes(1) && (maha.number === 1 || antar.number === 1))
          periodRisks.push({ type: 'opportunity', level: 'medium', label: 'Career Growth Window', desc: 'Sun energy is strong. Apply for promotions and new roles.' });
        if (annualNums.includes(5) && annualNums.includes(7))
          periodRisks.push({ type: 'opportunity', level: 'medium', label: 'Easy Money Period', desc: 'Money flows more easily. Good time for business and investments.' });

        // ── RELATIONSHIP ──────────────────────────────────────────────
        if (maha.number === 9 && antar.number === 2)
          periodRisks.push({ type: 'relationship', level: 'high', label: 'Relationship Volcano', desc: 'Mars + Moon = emotional explosions. Choose words carefully.' });
        else if (maha.number === 9 || antar.number === 9)
          periodRisks.push({ type: 'relationship', level: 'medium', label: 'Temper Watch', desc: 'Mars energy high. Arguments more likely. Stay calm.' });

        if (periodRisks.length > 0) {
          risks.push({
            year: yr,
            maha: maha.number,
            maha_planet: PLANET_NAMES[maha.number],
            antar: antar.number,
            antar_planet: PLANET_NAMES[antar.number],
            risks: periodRisks,
          });
        }
      }
    }

    // Deduplicate by year (keep highest risk entry per year per type)
    const byYear = {};
    for (const r of risks) {
      if (!byYear[r.year]) byYear[r.year] = { ...r, risks: [] };
      const seen = new Set(byYear[r.year].risks.map(x => x.type + x.label));
      for (const risk of r.risks) {
        if (!seen.has(risk.type + risk.label)) {
          byYear[r.year].risks.push(risk);
          seen.add(risk.type + risk.label);
        }
      }
    }

    const result = Object.values(byYear)
      .sort((a, b) => a.year - b.year)
      .filter(y => y.risks.length > 0);

    res.json({ risks: result, total_years: result.length });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});
