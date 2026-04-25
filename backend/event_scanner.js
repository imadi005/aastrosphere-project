// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — EVENT SCANNER ENGINE
// Scans any time period day-by-day, finds exact dates for all event types
// accident / finance / opportunity / relationship / health / career / karma
// ═══════════════════════════════════════════════════════════════════════════════

import {
  basicNumber, destinyNumber, currentMahadasha, currentAntardasha,
  currentMonthlyDasha, buildFrequencyMap
} from './numerology.js';
import { analyzeDayChart, getDayScore } from './chart_analysis_library.js';

function red(n){while(n>9){n=String(n).split('').reduce((a,b)=>a+parseInt(b),0);}return n;}
const WLORDS = [1,2,9,5,3,6,8];
const PNAME = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};

function fmt(d) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
}

// ─── Scan a date range day by day ────────────────────────────────────────────
export function scanPeriod(dob, startDate, endDate, eventTypes = null) {
  const natalNums = Object.keys(buildFrequencyMap(dob)).map(Number);
  const basic = basicNumber(new Date(dob).getDate());
  const destiny = destinyNumber(dob);
  
  const results = {
    accident: [], finance: [], opportunity: [], relationship: [],
    health: [], career: [], karma: [], spiritual: [],
  };

  let cursor = new Date(startDate);
  const end = new Date(endDate);

  while (cursor <= end) {
    const dateStr = cursor.toISOString();
    const maha = currentMahadasha(dob, dateStr);
    const antar = currentAntardasha(dob, dateStr);
    const monthly = currentMonthlyDasha(dob, dateStr);
    const daily = red(monthly.number + WLORDS[cursor.getDay()]);
    const score = getDayScore({ basic, destiny, maha: maha.number, antar: antar.number, monthly: monthly.number, daily, natalNums });

    const findings = analyzeDayChart({
      basic, destiny,
      maha: maha.number, antar: antar.number,
      monthly: monthly.number, daily,
      hourly: null, natalNums
    });

    for (const f of findings) {
      if (eventTypes && !eventTypes.includes(f.type)) continue;
      if (!results[f.type]) results[f.type] = [];
      results[f.type].push({
        date: cursor.toISOString().slice(0,10),
        dateLabel: fmt(cursor),
        level: f.level,
        label: f.label,
        detail: f.detail,
        score,
        layers: { maha: maha.number, antar: antar.number, monthly: monthly.number, daily }
      });
    }

    cursor.setDate(cursor.getDate() + 1);
  }

  return results;
}

// ─── Group consecutive days into windows ─────────────────────────────────────
function groupIntoWindows(days) {
  if (!days.length) return [];
  const windows = [];
  let window = [days[0]];

  for (let i = 1; i < days.length; i++) {
    const prev = new Date(days[i-1].date);
    const curr = new Date(days[i].date);
    const gap = (curr - prev) / (1000 * 60 * 60 * 24);
    if (gap <= 7) {
      window.push(days[i]);
    } else {
      windows.push(window);
      window = [days[i]];
    }
  }
  windows.push(window);
  return windows;
}

// ─── Format scan results for system prompt injection ─────────────────────────
export function formatScanResults(results, eventType = null) {
  const types = eventType ? [eventType] : Object.keys(results);
  const output = [];

  const TYPE_LABELS = {
    accident: '⚠️ Physical Risk / Accident',
    finance: '💰 Financial',
    opportunity: '✦ Opportunity / Peak Days',
    relationship: '❤️ Relationship',
    health: '🏥 Health',
    career: '📈 Career / Action',
    karma: '⊗ Karmic / Saturn',
    spiritual: '◈ Spiritual / Intuition',
  };

  for (const type of types) {
    const days = results[type];
    if (!days || !days.length) continue;

    const windows = groupIntoWindows(days);
    const highDays = days.filter(d => d.level === 'high');
    const peakDay = highDays.length > 0
      ? highDays.reduce((a, b) => a.score > b.score ? a : b)
      : days.reduce((a, b) => a.score > b.score ? a : b);

    output.push(`\n${TYPE_LABELS[type] || type.toUpperCase()}:`);
    output.push(`Total risk/event days: ${days.length}`);
    if (highDays.length > 0) output.push(`High-level days: ${highDays.length}`);

    // Show windows with exact dates
    for (const win of windows.slice(0, 5)) {
      const start = win[0].dateLabel;
      const end = win[win.length-1].dateLabel;
      const maxLevel = win.some(d => d.level === 'high') ? 'HIGH' : 'MEDIUM';
      const label = win[0].label;
      if (win.length === 1) {
        output.push(`  • ${start} [${maxLevel}] — ${label}`);
      } else {
        output.push(`  • ${start} to ${end} [${maxLevel}] — ${label}`);
      }
    }
    output.push(`  → Most intense day: ${peakDay.dateLabel} (${peakDay.label})`);
    if (peakDay.layers) {
      output.push(`    Layers: maha=${PNAME[peakDay.layers.maha]} antar=${PNAME[peakDay.layers.antar]} monthly=${PNAME[peakDay.layers.monthly]} daily=${PNAME[peakDay.layers.daily]}`);
    }
  }

  return output.join('\n');
}

// ─── Detect scan intent from question ────────────────────────────────────────
export function detectScanIntent(text) {
  const t = text.toLowerCase();

  // Year detection
  const yearMatch = t.match(/\b(20\d{2}|19\d{2})\b/);
  const year = yearMatch ? parseInt(yearMatch[1]) : null;

  // Month detection
  const MONTHS = {
    jan:0, january:0, feb:1, february:1, mar:2, march:2, apr:3, april:3,
    may:4, jun:5, june:5, jul:6, july:6, aug:7, august:7,
    sep:8, september:8, oct:9, october:9, nov:10, november:10, dec:11, december:11
  };
  let month = null;
  for (const [name, num] of Object.entries(MONTHS)) {
    if (t.includes(name)) { month = num; break; }
  }

  // Time range keywords
  const isLastYear = t.match(/last year|pichhle saal|pichle saal/i);
  const isThisYear = t.match(/this year|is saal|2026/i);
  const isNext = t.match(/next year|agle saal|coming|aane wala/i);
  const isPast = t.match(/tha|thi|hua|hui|hogi|mein kya tha|ka kya tha|chances tha|kab tha/i);

  // Event type
  let eventType = null;
  if (t.match(/accident|chot|injury|hurt|crash|gir|fall|risk|khatara/i)) eventType = 'accident';
  else if (t.match(/paise|money|income|finance|profit|loss|earn/i)) eventType = 'finance';
  else if (t.match(/opportunity|mauka|lucky|best day|acha din|peak/i)) eventType = 'opportunity';
  else if (t.match(/love|pyaar|relation|shaadi|breakup|partner/i)) eventType = 'relationship';
  else if (t.match(/health|bimari|sick|hospital/i)) eventType = 'health';
  else if (t.match(/career|job|naukri|promotion/i)) eventType = 'career';

  if (!year && !isLastYear && !isThisYear && !isPast) return null;

  return { year, month, eventType, isPast: !!(isPast || isLastYear), isLastYear, isThisYear, isNext };
}

// ─── Build date range from scan intent ───────────────────────────────────────
export function buildDateRange(intent, today) {
  const now = new Date(today);
  let start, end;

  if (intent.isLastYear) {
    start = new Date(now.getFullYear() - 1, 0, 1);
    end = new Date(now.getFullYear() - 1, 11, 31);
  } else if (intent.isThisYear) {
    start = new Date(now.getFullYear(), 0, 1);
    end = new Date(now.getFullYear(), 11, 31);
  } else if (intent.isNext) {
    start = new Date(now.getFullYear() + 1, 0, 1);
    end = new Date(now.getFullYear() + 1, 11, 31);
  } else if (intent.year) {
    if (intent.month !== null) {
      // Specific month
      start = new Date(intent.year, intent.month, 1);
      end = new Date(intent.year, intent.month + 1, 0);
    } else {
      // Full year
      start = new Date(intent.year, 0, 1);
      end = new Date(intent.year, 11, 31);
    }
  } else {
    return null;
  }

  // Don't scan future beyond 1 year
  const maxFuture = new Date(now);
  maxFuture.setFullYear(maxFuture.getFullYear() + 1);
  if (end > maxFuture) end = maxFuture;

  return {
    start: start.toISOString().slice(0,10),
    end: end.toISOString().slice(0,10),
    label: intent.month !== null
      ? `${['January','February','March','April','May','June','July','August','September','October','November','December'][intent.month]} ${intent.year}`
      : intent.year ? `${intent.year}` : intent.isLastYear ? 'last year' : 'this year'
  };
}

// ─── Main: build scan context for system prompt ───────────────────────────────
export async function buildScanContext(dob, question, today) {
  const intent = detectScanIntent(question);
  if (!intent) return null;

  const range = buildDateRange(intent, today);
  if (!range) return null;

  // Limit scan to 366 days max
  const start = new Date(range.start);
  const end = new Date(range.end);
  const days = Math.round((end - start) / (1000*60*60*24));
  if (days > 366) return null;

  try {
    const eventTypes = intent.eventType ? [intent.eventType] : null;
    const results = scanPeriod(dob, range.start, range.end, eventTypes);
    const formatted = formatScanResults(results, intent.eventType);

    if (!formatted.trim()) {
      return `\nSCAN: ${range.label} — No significant ${intent.eventType || 'event'} windows found in this period.`;
    }

    return `\nSCAN RESULTS FOR ${range.label.toUpperCase()}:\n${formatted}`;
  } catch(e) {
    return null;
  }
}
