import express from 'express';
import cors from 'cors';
import {
  basicNumber, destinyNumber, supportiveNumbers, chartDigits,
  currentMahadasha, currentAntardasha, currentMonthlyDasha,
  mahadashaTimeline, antardashaTimeline,
  dailyDasha, hourlyDasha, allHourlyDashas,
  buildGrid, buildFrequencyMap, getDayRating,
  compatibility, karmicDebt, nameNumerology,
  PLANET_NAMES, LUCKY_INFO
} from './numerology.js';

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
    const daily = dailyDasha(dob, today);
    const rating = getDayRating(dob, today);
    const hours = allHourlyDashas(dob, today);
    const maha = currentMahadasha(dob);
    const antar = currentAntardasha(dob);
    const monthly = currentMonthlyDasha(dob);
    const basic = basicNumber(new Date(dob).getDate());
    const destiny = destinyNumber(dob);
    const grid = buildGrid(dob);

    const dayInsights = {
      1:'Sun energy is direct today. Take initiative. Ego can get in the way — check it.',
      2:'Moon makes emotions loud. Creativity is high. Avoid conflict, lean into feeling.',
      3:'Jupiter expands everything today. Good for learning, teaching, and honest talk.',
      4:'Rahu brings confusion and speed. Double-check everything. Not a day for big decisions.',
      5:'Mercury is sharp. Communication, numbers, deals — all flow well today.',
      6:'Venus asks for harmony. Relationships take centre stage. Money decisions — wait.',
      7:'Ketu pulls inward. Good for reflection and research. Social energy is low.',
      8:'Saturn demands patience today. Things move slow on purpose. Trust the delay.',
      9:'Mars adds fire. Bold action works. Anger is also close — choose your battles.',
    };

    // Alert logic
    const freqMap = buildFrequencyMap(dob);
    const hasAlert = (maha.number === 4 || antar.number === 4) &&
      (freqMap[8] || freqMap[4]);

    res.json({
      date: today,
      daily, dailyPlanet: PLANET_NAMES[daily],
      rating,
      insight: dayInsights[daily],
      hours,
      maha, antar, monthly,
      basic, basicPlanet: PLANET_NAMES[basic],
      destiny, destinyPlanet: PLANET_NAMES[destiny],
      grid,
      hasAlert,
      alertMessage: hasAlert ? 'Rahu period active. Physical carelessness is high — slow down.' : null,
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Aastrosphere API running on port ${PORT}`));
