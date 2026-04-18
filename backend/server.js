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

  // Step 1: mark existing items with daily/hourly highlight (priority: existing items first)
  for (let r = 0; r < 3; r++) {
    for (let c = 0; c < 3; c++) {
      enhancedGrid[r][c] = enhancedGrid[r][c].map(item => {
        if (item.highlight === '' || item.highlight === 'none') {
          if (hourlyNum !== null && item.value === hourlyNum) return {...item, highlight: 'hourly'};
          if (item.value === dailyNum) return {...item, highlight: 'daily'};
        }
        return item;
      });
    }
  }

  // Step 2: inject daily into its grid cell
  // If number already exists with another highlight (e.g. maha=8, daily=8),
  // ADD a second entry so both colors show simultaneously
  const dailyPos = GRID_POSITIONS[dailyNum];
  if (dailyPos) {
    const [dr, dc] = dailyPos;
    const existingDailyIdx = enhancedGrid[dr][dc].findIndex(
      i => i.value === dailyNum && i.highlight === 'daily'
    );
    if (existingDailyIdx < 0) {
      // Always add daily entry — even if same number exists with maha/antar/monthly
      enhancedGrid[dr][dc] = [...enhancedGrid[dr][dc], {
        value: dailyNum,
        highlight: 'daily',
        planet: CELL_PLANETS[`${dr},${dc}`] || '',
        injected: true,
      }];
    }
  }

  // Step 3: inject hourly into its grid cell
  if (hourlyNum !== null) {
    const hourlyPos = GRID_POSITIONS[hourlyNum];
    if (hourlyPos) {
      const [hr, hc] = hourlyPos;
      const existingHourlyIdx = enhancedGrid[hr][hc].findIndex(
        i => i.value === hourlyNum && i.highlight === 'hourly'
      );
      if (existingHourlyIdx < 0) {
        // Always add hourly entry — even if same number exists with other highlights
        enhancedGrid[hr][hc] = [...enhancedGrid[hr][hc], {
          value: hourlyNum,
          highlight: 'hourly',
          planet: CELL_PLANETS[`${hr},${hc}`] || '',
          injected: true,
        }];
      }
    }
  }

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
    karmic, lucky,
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
      if (hourNum === 4 && [9].includes(daily)) risks.push({ level: 'high', reason: 'High accident risk this hour. Avoid speeding, sharp tools, and anything requiring precision.' });
      if (hourNum === 9 && daily === 4) risks.push({ level: 'high', reason: 'High accident risk this hour. Slow down — impulsive moves cause physical damage right now.' });
      if (hourNum === 4 && daily === 4) risks.push({ level: 'high', reason: 'Very high accident risk this hour. Do not rush. Double-check everything before you act.' });
      if (hourNum === 4 && daily === 8) risks.push({ level: 'medium', reason: 'Accident risk this hour. Be careful with physical tasks, driving, and anything mechanical.' });
      if (hourNum === 8 && daily === 4) risks.push({ level: 'medium', reason: 'Accident risk this hour. Move slowly and deliberately — this is not the hour to rush.' });
      if (hourNum === 4 && maha === 9) risks.push({ level: 'high', reason: 'High accident risk this hour. Your body is running hot — physical caution is essential right now.' });
      if (hourNum === 9 && maha === 4) risks.push({ level: 'high', reason: 'High accident risk this hour. Sudden unexpected situations can cause physical harm — stay alert.' });
      if (hourNum === 4 && maha === 8) risks.push({ level: 'medium', reason: 'Accident risk this hour. Slow down, verify before acting, and avoid physical shortcuts.' });
      if (hourNum === 9 && hourNum === daily && maha === 9) risks.push({ level: 'high', reason: 'Very high accident risk this hour. Energy is at its most reckless — physical outlet, not physical risk.' });
      if (hourNum === 4 && antar === 4) risks.push({ level: 'medium', reason: 'Accident risk this hour. Double instability — do not make quick physical decisions right now.' });
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
      if (ctx.daily === 4 && ctx.maha === 9) return { level: 'high', reason: 'Higher accident risk today. Stay alert, drive carefully, avoid risky physical activities.' };
      if (ctx.daily === 9 && ctx.maha === 4) return { level: 'high', reason: 'Higher accident risk today. Slow down before acting — impulsive moves lead to physical damage.' };
      if (ctx.daily === 4 && ctx.monthly === 9) return { level: 'medium', reason: 'Mild accident risk today. Be careful with physical tasks, machinery, and driving.' };
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
import { PAIR_DYNAMICS, NUMBER_IN_RELATIONSHIP, getTodayCompatibility } from './compatibility_library.js';

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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Aastrosphere API running on port ${PORT}`));
