// ═══════════════════════════════════════════════════════════════
// AASTROSPHERE NUMEROLOGY ENGINE
// Ported from web app — Saurabh Avasthi framework
// ═══════════════════════════════════════════════════════════════

export const PLANET_NAMES = {
  1: 'Sun', 2: 'Moon', 3: 'Jupiter', 4: 'Rahu',
  5: 'Mercury', 6: 'Venus', 7: 'Ketu', 8: 'Saturn', 9: 'Mars'
};

export const DASHA_DURATIONS = { 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9 };

export const MONTHLY_DURATIONS = { 1:8, 2:16, 3:24, 4:32, 5:41, 6:49, 7:57, 8:65, 9:73 };

export const WEEKDAY_VALUES = { 0:1, 1:2, 2:9, 3:5, 4:3, 5:6, 6:8 };

export const NUMBER_POSITION_MAP = {
  1:[0,1], 2:[2,0], 3:[0,0], 4:[2,2],
  5:[1,2], 6:[1,0], 7:[1,1], 8:[2,1], 9:[0,2]
};

export const LUCKY_INFO = {
  1: { colors:['Golden','Orange'], direction:'East', luckyNumbers:[1,3] },
  2: { colors:['Milky white','Cream'], direction:'Northwest', luckyNumbers:[1,3] },
  3: { colors:['Yellow','Orange'], direction:'Northeast', luckyNumbers:[1,3] },
  4: { colors:['Blue','Black'], direction:'Southwest', luckyNumbers:[6,5] },
  5: { colors:['Green'], direction:'North', luckyNumbers:[6,5] },
  6: { colors:['White','Metallic'], direction:'Southeast', luckyNumbers:[6,5] },
  7: { colors:['Sandal Grey'], direction:'Southwest', luckyNumbers:[7,9] },
  8: { colors:['Blue','Black'], direction:'West', luckyNumbers:[8,7] },
  9: { colors:['Red'], direction:'South', luckyNumbers:[7,9] },
};

// ─── Core calculations ────────────────────────────────────────
export function reduceToSingle(n) {
  n = Number(n);
  while (n > 9) {
    n = String(n).split('').reduce((a, b) => a + Number(b), 0);
  }
  return n;
}

export function sumDigits(str) {
  return String(str).split('').reduce((a, b) => a + Number(b), 0);
}

export function basicNumber(day) {
  const raw = sumDigits(day);
  return raw > 9 ? reduceToSingle(raw) : raw;
}

export function destinyNumber(dob) {
  const d = new Date(dob);
  const s = `${d.getDate()}${d.getMonth()+1}${d.getFullYear()}`;
  return reduceToSingle(sumDigits(s));
}

export function supportiveNumbers(day) {
  day = Number(day);
  if (day <= 9 || day === 10 || day === 20 || day === 30) return [];
  return String(day).split('').map(Number);
}

export function chartDigits(dob) {
  const d = new Date(dob);
  const day = d.getDate();
  const month = d.getMonth() + 1;
  const year = d.getFullYear();
  const yearLast2 = year % 100;
  const destiny = destinyNumber(dob);
  const basic = basicNumber(day);
  const supportive = supportiveNumbers(day);

  const digits = [
    ...String(day).split('').map(Number),
    ...String(month).split('').map(Number),
    ...String(yearLast2).padStart(2,'0').split('').map(Number),
  ].filter(n => n !== 0);

  const result = [...digits, destiny];
  if (!(day <= 9 || day === 10 || day === 20 || day === 30)) result.push(basic);
  supportive.forEach(s => { if (!result.includes(s)) result.push(s); });
  return result;
}

// ─── Dasha calculations ───────────────────────────────────────
export function buildDashaCycle(basic) {
  const all = [1,2,3,4,5,6,7,8,9];
  const idx = all.indexOf(basic);
  return [...all.slice(idx), ...all.slice(0, idx)];
}

export function currentMahadasha(dob, targetDate = null) {
  const d = new Date(dob);
  const basic = basicNumber(d.getDate());
  const cycle = buildDashaCycle(basic);
  const ref = targetDate ? new Date(targetDate) : new Date();
  // Cannot go before date of birth
  if (ref < d) return { number: basic, planet: PLANET_NAMES[basic], start: d.toISOString(), end: d.toISOString(), isCurrent: false };
  let current = new Date(d);
  let i = 0;

  while (i < 200) {
    const dasha = cycle[i % 9];
    const duration = DASHA_DURATIONS[dasha];
    const end = new Date(current);
    end.setFullYear(end.getFullYear() + duration);

    if (ref >= current && ref < end) {
      return {
        number: dasha,
        planet: PLANET_NAMES[dasha],
        start: current.toISOString(),
        end: end.toISOString(),
        isCurrent: true
      };
    }
    current = end;
    i++;
  }
}

export function mahadashaTimeline(dob, pastYears = 20, futureYears = 50) {
  const d = new Date(dob);
  const basic = basicNumber(d.getDate());
  const cycle = buildDashaCycle(basic);
  const today = new Date();
  let current = new Date(d);
  let i = 0;
  const results = [];

  while (i < 200) {
    const dasha = cycle[i % 9];
    const duration = DASHA_DURATIONS[dasha];
    const end = new Date(current);
    end.setFullYear(end.getFullYear() + duration);

    if (current.getFullYear() >= today.getFullYear() - pastYears &&
        current.getFullYear() <= today.getFullYear() + futureYears) {
      const isCurrent = today >= current && today < end;
      results.push({
        number: dasha,
        planet: PLANET_NAMES[dasha],
        start: current.toISOString(),
        end: end.toISOString(),
        duration: `${duration} yrs`,
        isCurrent,
        isPast: end < today && !isCurrent
      });
    }
    if (current.getFullYear() > today.getFullYear() + futureYears) break;
    current = end;
    i++;
  }
  return results;
}

export function currentAntardasha(dob, targetDate = null) {
  const d = new Date(dob);
  const basic = basicNumber(d.getDate());
  const month = d.getMonth() + 1;
  const day = d.getDate();
  const today = targetDate ? new Date(targetDate) : new Date();

  // Cannot go before date of birth
  if (today < d) return { number: basic, planet: PLANET_NAMES[basic], start: d.toISOString(), end: d.toISOString(), isCurrent: false };
  const bdayThisYear = new Date(today.getFullYear(), month - 1, day);
  const antarYear = today < bdayThisYear ? today.getFullYear() - 1 : today.getFullYear();

  const weekday = new Date(antarYear, month - 1, day).getDay();
  const weekdayVal = WEEKDAY_VALUES[weekday];
  const yearLast2 = antarYear % 100;
  const raw = basic + month + yearLast2 + weekdayVal;
  const antar = reduceToSingle(raw);

  const start = new Date(antarYear, month - 1, day);
  const end = new Date(antarYear + 1, month - 1, day - 1);

  return {
    number: antar,
    planet: PLANET_NAMES[antar],
    start: start.toISOString(),
    end: end.toISOString(),
    isCurrent: true
  };
}

export function antardashaTimeline(dob, pastYears = 5, futureYears = 10) {
  const d = new Date(dob);
  const basic = basicNumber(d.getDate());
  const month = d.getMonth() + 1;
  const day = d.getDate();
  const today = new Date();
  const results = [];

  const bdayThisYear = new Date(today.getFullYear(), month - 1, day);
  const currentAntarYear = today < bdayThisYear ? today.getFullYear() - 1 : today.getFullYear();

  for (let y = today.getFullYear() - pastYears; y <= today.getFullYear() + futureYears; y++) {
    const weekday = new Date(y, month - 1, day).getDay();
    const weekdayVal = WEEKDAY_VALUES[weekday];
    const yearLast2 = y % 100;
    const raw = basic + month + yearLast2 + weekdayVal;
    const antar = reduceToSingle(raw);
    const start = new Date(y, month - 1, day);
    const end = new Date(y + 1, month - 1, day - 1);
    const isCurrent = y === currentAntarYear;

    results.push({
      year: y,
      number: antar,
      planet: PLANET_NAMES[antar],
      start: start.toISOString(),
      end: end.toISOString(),
      isCurrent,
      isPast: end < today && !isCurrent
    });
  }
  return results;
}

export function currentMonthlyDasha(dob, targetDate = null) {
  // Monthly Dasha starts from Antar Dasha number (not basic)
  // Cycle: antarNum → antarNum+1 → ... each lasting MONTHLY_DURATIONS[n] days
  // Resets every birthday when new Antar Dasha begins

  const d = new Date(dob);
  const month = d.getMonth() + 1;
  const day = d.getDate();
  const today = targetDate ? new Date(targetDate) : new Date();
  const basic = basicNumber(d.getDate());

  // Find last birthday = Antar Dasha start date
  const bdayThisYear = new Date(today.getFullYear(), month - 1, day);
  const antarStart = today < bdayThisYear
    ? new Date(today.getFullYear() - 1, month - 1, day)
    : bdayThisYear;

  // Calculate Antar number for that birthday year
  const antarYear = antarStart.getFullYear();
  const weekday = new Date(antarYear, month - 1, day).getDay();
  const weekdayVal = WEEKDAY_VALUES[weekday];
  const yearLast2 = antarYear % 100;
  const raw = basic + month + yearLast2 + weekdayVal;
  const antarNum = reduceToSingle(raw);

  // Monthly cycle starts from antarNum
  const cycle = buildDashaCycle(antarNum);

  let current = new Date(antarStart);
  for (let i = 0; i < 200; i++) {
    const dasha = cycle[i % 9];
    const durationDays = MONTHLY_DURATIONS[dasha];
    const end = new Date(current);
    end.setDate(end.getDate() + durationDays);

    if (today >= current && today < end) {
      return {
        number: dasha,
        planet: PLANET_NAMES[dasha],
        start: current.toISOString(),
        end: end.toISOString(),
        isCurrent: true
      };
    }
    current = end;
  }
}

export function dailyDasha(dob, date) {
  // Daily = Monthly + day_lord_of_that_day (12hr weekday values)
  const monthly = currentMonthlyDasha(dob, date);
  const monthlyNum = monthly ? monthly.number : basicNumber(new Date(dob).getDate());
  const d = new Date(date);
  const weekday = d.getDay(); // 0=Sun,1=Mon...6=Sat
  const dayLord = WEEKDAY_VALUES[weekday];
  return reduceToSingle(monthlyNum + dayLord);
}

export function hourlyDasha(dob, date, hour) {
  // Hourly = Daily + hour (12-hour format)
  const daily = dailyDasha(dob, date);
  const hour12 = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
  return reduceToSingle(daily + hour12);
}

export function allHourlyDashas(dob, date) {
  const daily = dailyDasha(dob, date);
  const hours = [];
  for (let h = 0; h < 24; h++) {
    const hour12 = h === 0 ? 12 : h > 12 ? h - 12 : h;
    const num = reduceToSingle(daily + hour12);
    hours.push({ hour: h, number: num, planet: PLANET_NAMES[num] });
  }
  return hours;
}

// ─── Grid ─────────────────────────────────────────────────────
export function buildFrequencyMap(dob, mahaOverride, antarOverride, monthlyOverride, natalOnly = false) {
  const digits = chartDigits(dob);
  const map = {};
  digits.forEach(n => { map[n] = (map[n] || 0) + 1; });

  // natalOnly = true → DOB digits only, no dasha additions
  if (natalOnly) return map;

  const maha = mahaOverride ?? currentMahadasha(dob).number;
  const antar = antarOverride ?? currentAntardasha(dob).number;
  const monthly = monthlyOverride ?? currentMonthlyDasha(dob).number;

  // Always add ALL dashas — even if same number as natal or each other
  // e.g. natal has 8, maha=8, monthly=8 → 8 appears 3 times in grid
  map[maha]    = (map[maha]    || 0) + 1;
  map[antar]   = (map[antar]   || 0) + 1;
  map[monthly] = (map[monthly] || 0) + 1;
  return map;
}

export function buildGrid(dob, mahaOverride, antarOverride, monthlyOverride, dailyOverride, hourlyOverride) {
  const maha    = mahaOverride    ?? currentMahadasha(dob).number;
  const antar   = antarOverride   ?? currentAntardasha(dob).number;
  const monthly = monthlyOverride ?? currentMonthlyDasha(dob).number;

  // Start with natal frequency map
  const freqMap = buildFrequencyMap(dob, maha, antar, monthly);
  // daily and hourly also add to count if provided
  if (dailyOverride)  freqMap[dailyOverride]  = (freqMap[dailyOverride]  || 0) + 1;
  if (hourlyOverride) freqMap[hourlyOverride] = (freqMap[hourlyOverride] || 0) + 1;

  const grid = Array(3).fill(null).map(() => Array(3).fill(null).map(() => []));

  Object.entries(freqMap).forEach(([numStr, count]) => {
    const num = parseInt(numStr);
    const pos = NUMBER_POSITION_MAP[num];
    if (!pos) return;
    const [r, c] = pos;

    // All highlights this number needs — in priority order (last slot = highest priority)
    const needed = [];
    if (num === maha)                            needed.push('maha');
    if (num === antar)                           needed.push('antar');
    if (num === monthly)                         needed.push('monthly');
    if (dailyOverride  && num === dailyOverride)  needed.push('daily');
    if (hourlyOverride && num === hourlyOverride) needed.push('hourly');

    // Assign highlights to the LAST N slots in this cell
    for (let i = 0; i < count; i++) {
      const fromEnd = count - 1 - i; // 0=last, 1=second-last, etc.
      const highlight = fromEnd < needed.length
        ? needed[needed.length - 1 - fromEnd]
        : '';
      grid[r][c].push({ value: num, highlight, planet: PLANET_NAMES[num] });
    }
  });

  // Ensure every dasha is visible — inject if not already highlighted
  const ensureDasha = (num, hl) => {
    if (!num) return;
    const pos = NUMBER_POSITION_MAP[num];
    if (!pos) return;
    const [r, c] = pos;
    if (!grid[r][c].some(item => item.highlight === hl)) {
      grid[r][c].push({ value: num, highlight: hl, planet: PLANET_NAMES[num], injected: true });
    }
  };
  ensureDasha(maha,          'maha');
  ensureDasha(antar,         'antar');
  ensureDasha(monthly,       'monthly');
  ensureDasha(dailyOverride,  'daily');
  ensureDasha(hourlyOverride, 'hourly');

  return grid;
}

// ─── Day rating ───────────────────────────────────────────────
export function getDayRating(dob, date) {
  const basic = basicNumber(new Date(dob).getDate());
  const destiny = destinyNumber(dob);
  const daily = dailyDasha(dob, date);
  const freqMap = buildFrequencyMap(dob);

  if (daily === basic || daily === destiny) return 'favorable';
  if ((daily === 4 || daily === 8) && !freqMap[daily]) return 'avoid';
  return 'caution';
}

// ─── Compatibility ────────────────────────────────────────────
const COMPAT_MAP = {
  1:{best:[1,3,5,9],neutral:[2,4,6]},
  2:{best:[2,4,6,8],neutral:[1,3,7]},
  3:{best:[3,6,9],neutral:[1,5,8]},
  4:{best:[2,4,8],neutral:[6,7]},
  5:{best:[1,5,7],neutral:[3,8,9]},
  6:{best:[3,6,9],neutral:[2,4,8]},
  7:{best:[5,7],neutral:[2,4,8]},
  8:{best:[2,4,8],neutral:[5,6]},
  9:{best:[3,6,9],neutral:[1,5]},
};

function basicCompatScore(a, b) {
  if (COMPAT_MAP[a]?.best?.includes(b)) return 30;
  if (COMPAT_MAP[a]?.neutral?.includes(b)) return 18;
  return 8;
}

export function compatibility(dob1, dob2) {
  const basic1 = basicNumber(new Date(dob1).getDate());
  const basic2 = basicNumber(new Date(dob2).getDate());
  const destiny1 = destinyNumber(dob1);
  const destiny2 = destinyNumber(dob2);
  const maha1 = currentMahadasha(dob1).number;
  const maha2 = currentMahadasha(dob2).number;
  const freq1 = buildFrequencyMap(dob1);
  const freq2 = buildFrequencyMap(dob2);

  const basicScore = basicCompatScore(basic1, basic2);
  const destinyScore = Math.round(basicCompatScore(destiny1, destiny2) * 25 / 30);
  const dashaScore = maha1 === maha2 ? 22 : Math.round(basicCompatScore(maha1, maha2) * 25 / 30) + 5;
  const overlap = Object.keys(freq1).filter(k => freq2[k]).length;
  const overlapScore = Math.min(overlap * 4, 20);

  const total = Math.min(basicScore + destinyScore + dashaScore + overlapScore, 100);

  const labels = [
    [85, 'Soul connection', 'Deep alignment across numbers and periods. Rare bond.'],
    [72, 'Harmonious', 'Strong foundation. Friction exists but growth is mutual.'],
    [58, 'Growth oriented', 'Different energies. Learning happens through each other.'],
    [44, 'Karmic teachers', 'Intense connection. Requires conscious effort from both.'],
    [0,  'Challenging', 'Fundamentally different paths. Growth possible but not easy.'],
  ];

  const [, label, description] = labels.find(([min]) => total >= min);

  return {
    score: total,
    label,
    description,
    breakdown: { basicScore, destinyScore, dashaScore, overlapScore }
  };
}

// ─── Karmic debt ──────────────────────────────────────────────
const KARMIC_INFO = {
  13: { title:'Karmic Debt 13', severity:'High', remedy:'Avoid shortcuts. Build discipline and take steady steps.' },
  14: { title:'Karmic Debt 14', severity:'Medium', remedy:'Learn self-control and establish strong boundaries.' },
  16: { title:'Karmic Debt 16', severity:'High', remedy:'Heal emotional wounds and develop spiritual awareness.' },
  19: { title:'Karmic Debt 19', severity:'Medium', remedy:'Serve others with compassion, let go of control.' },
};

export function karmicDebt(dob) {
  const d = new Date(dob);
  const day = d.getDate();
  const month = d.getMonth() + 1;
  const year = d.getFullYear();
  const total = sumDigits(String(day)) + sumDigits(String(month)) + sumDigits(String(year));
  const hasDebt = [13,14,16,19].includes(total);
  return {
    totalBeforeReduction: total,
    lifePath: reduceToSingle(total),
    hasKarmicDebt: hasDebt,
    ...(hasDebt ? KARMIC_INFO[total] : { title: 'No karmic debt', severity: 'None', remedy: '' })
  };
}

// ─── Name numerology ──────────────────────────────────────────
const LETTER_VALUES = {
  A:1,B:2,C:3,D:4,E:5,F:8,G:3,H:5,I:1,
  J:1,K:2,L:3,M:4,N:5,O:7,P:8,Q:1,R:2,
  S:3,T:4,U:6,V:6,W:6,X:5,Y:1,Z:7
};

const FAVORABLE_NUMBERS = {
  default:[1,3,5,6], 8:[3,5,6], 6:[5,6], 3:[1,3,5], 9:[1,3,5,6,9]
};

export function nameNumerology(name, dob) {
  const destiny = destinyNumber(dob);
  const clean = name.toUpperCase().replace(/[^A-Z]/g,'');
  const digits = clean.split('').map(c => LETTER_VALUES[c] || 0);
  const sum = digits.reduce((a,b) => a+b, 0);
  const nameNumber = reduceToSingle(sum);
  const favorable = FAVORABLE_NUMBERS[destiny] || FAVORABLE_NUMBERS.default;
  const isFavorable = favorable.includes(nameNumber);

  return {
    name,
    digits,
    sum,
    nameNumber,
    isFavorable,
    destinyNumber: destiny,
    message: isFavorable
      ? `Name number ${nameNumber} is favorable for your destiny ${destiny}`
      : `Name number ${nameNumber} is not ideal for destiny ${destiny} — consider adjustment`
  };
}
