// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — ASK ENGINE
// Builds system prompt with full 6-layer chart + pre-calculated timeline
// Classifies question → injects relevant knowledge chunk
// ═══════════════════════════════════════════════════════════════════════════════

import {
  basicNumber, destinyNumber, currentMahadasha, currentAntardasha,
  currentMonthlyDasha, buildFrequencyMap, antardashaTimeline, supportiveNumbers
} from './numerology.js';
import { buildChartContext, getDeepNumberProfile, getDashaExperience } from './prediction_engine.js';
import { PAIR_DYNAMICS, NUMBER_IN_RELATIONSHIP, VEDIC_RELATIONS, getRelType } from './compatibility_library.js';
import { MAHA_CONTEXT, ANTAR_CONTEXT, MONTHLY_CONTEXT } from './daily_prediction_library.js';
import { analyzeDayChart, getDayScore } from './chart_analysis_library.js';

function red(n){while(n>9){n=String(n).split('').reduce((a,b)=>a+parseInt(b),0);}return n;}
const WLORDS = [1,2,9,5,3,6,8];
const PNAME = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};

// ─── Question classifier — broad keywords Hindi/English/Hinglish ──────────────
export function classifyQuestion(text) {
  const t = text.toLowerCase();

  // Finance — broadest category
  if (t.match(/pais|money|income|earn|paisa|paison|salary|job|naukri|business|karobar|loss|nuksan|debt|karz|invest|profit|faida|financial|rupee|rupay|fund|saving|bachao|kharcha|spend|broke|poor|ameer|rich|wealth|daulat|lakshmi|loan|udhar|transaction|deal|contract|afford|budget|stock|trade|bank|account|flow|ruk|band|nahi aa|nahi mil|khatam|zero|0 ho/)) return 'finance';

  // Relationship — love/breakup/marriage
  if (t.match(/love|pyaar|mohabbat|breakup|break up|ex|wapas|phir milenge|milegi|milega|shaadi|marriage|shadi|vivah|rishta|relation|partner|girlfriend|boyfriend|ladki|ladka|girl|boy|wife|husband|pati|patni|divorce|talak|attract|pasand|like karta|like karti|dil|feelings|sath|saath|alag|judaa|door|paas|propose|date|dating/)) return 'relationship';

  // Health
  if (t.match(/health|bimari|beemari|sick|hospital|doctor|dawa|medicine|dard|pain|bukhar|fever|surgery|operation|tension|stress|mental|anxiety|depression|thaka|tired|neend|sleep|khana|diet|weight|cancer|blood|sugar|bp|pressure|treatment|disease/)) return 'health';

  // Career
  if (t.match(/career|naukri|job|promotion|interview|office|boss|colleague|company|resign|quit|change|badlao|kaam|work|profession|success|failure|exam|study|padhai|result|rank|college|abroad|foreign|settle|opportunities|growth|business partner/)) return 'career';

  // Timing/lucky
  if (t.match(/kab|when|kitne din|kitne time|lucky|luckiest|acha din|best day|best time|sahi time|sahi waqt|future|bhavishya|next|agle|coming|aane wala|predict|batao kab|kal|tomorrow|aaj|today|is mahine|this month|is saal|this year/)) return 'timing';

  // Family
  if (t.match(/family|ghar|parents|maa|papa|bhai|bahen|beta|beti|child|bachha|sasural|in-laws|relatives|rishtedaar|gharwale/)) return 'family';

  return 'general';
}

// ─── Build pre-calculated timeline ───────────────────────────────────────────
function buildTimeline(dob, targetDate) {
  const today = new Date(targetDate);
  const antars = antardashaTimeline(dob, 2, 4);
  const timeline = [];

  for (const antar of antars) {
    const antarEnd = new Date(antar.end);
    let cursor = new Date(antar.start);
    let lastM = null;

    while (cursor < antarEnd) {
      const m = currentMonthlyDasha(dob, cursor.toISOString());
      if (!lastM || lastM !== m.number) {
        const mEnd = new Date(m.end);
        const isPast = mEnd < today;
        const isCurrent = cursor <= today && mEnd >= today;

        // Find luckiest day
        let luckyDay = null;
        let d = new Date(isCurrent ? today : cursor);
        const searchEnd = new Date(Math.min(mEnd.getTime(), cursor.getTime() + 60*24*60*60*1000));
        while (d <= searchEnd) {
          const daily = red(m.number + WLORDS[d.getDay()]);
          if ([5,7,1].includes(daily)) { luckyDay = d.toISOString().slice(0,10); break; }
          d.setDate(d.getDate()+1);
        }

        timeline.push({
          antar: antar.number, antarName: PNAME[antar.number],
          monthly: m.number, monthlyName: PNAME[m.number],
          start: cursor.toISOString().slice(0,7),
          end: mEnd.toISOString().slice(0,10),
          status: isPast ? 'past' : isCurrent ? 'current' : 'future',
          luckyDay,
          antarEnd: antar.end?.slice(0,10),
        });
        lastM = m.number;
      }
      cursor.setDate(cursor.getDate()+5);
    }
  }
  return timeline;
}

// ─── Period quality labels ────────────────────────────────────────────────────
function getPeriodQuality(antar, monthly, basic, destiny) {
  const RELS = VEDIC_RELATIONS;
  function r(a,b){return RELS[a]?.f.includes(b)?'friendly':RELS[a]?.e.includes(b)?'tense':'neutral';}

  const antarBasic = r(antar, basic);
  const monthlyBasic = r(monthly, basic);
  const antarMonthly = r(antar, monthly);

  if (antarBasic === 'friendly' && monthlyBasic === 'friendly') return 'strong';
  if (antarBasic === 'tense' && monthlyBasic === 'tense') return 'very_difficult';
  if (antarBasic === 'tense' || monthlyBasic === 'tense') return 'difficult';
  if (antarBasic === 'friendly' || monthlyBasic === 'friendly') return 'good';
  return 'neutral';
}

// ─── Format timeline for system prompt ───────────────────────────────────────
function formatTimeline(timeline, basic, destiny) {
  const QUALITY_LABELS = {
    strong: '✓ strong',
    good: '~ good',
    neutral: '— neutral',
    difficult: '↓ difficult',
    very_difficult: '↓↓ very difficult',
  };

  const relevantPeriods = timeline.filter(t =>
    t.status === 'current' ||
    (t.status === 'future' && t.start <= new Date(Date.now() + 18*30*24*60*60*1000).toISOString().slice(0,7)) ||
    (t.status === 'past' && t.start >= new Date(Date.now() - 12*30*24*60*60*1000).toISOString().slice(0,7))
  );

  return relevantPeriods.map(t => {
    const q = getPeriodQuality(t.antar, t.monthly, basic, destiny);
    const marker = t.status === 'current' ? '[NOW]' : t.status === 'past' ? '[PAST]' : '[COMING]';
    const lucky = t.luckyDay ? ` | lucky: ${t.luckyDay}` : '';
    const antarEndNote = t.status === 'current' && t.antarEnd ? ` | ${t.antarName} antar ends: ${t.antarEnd}` : '';
    return `${marker} ${t.start}–${t.end} | ${t.antarName}(${t.antar}) antar + ${t.monthlyName}(${t.monthly}) monthly | ${QUALITY_LABELS[q]}${lucky}${antarEndNote}`;
  }).join('\n');
}

// ─── Yoga descriptions ────────────────────────────────────────────────────────
function describeYogas(yogas) {
  const YOGA_DESC = {
    easy_money: 'Easy Money Yoga (5+7 in natal): financial luck arrives with less friction. But needs active monthly window.',
    financial_bandhan: 'Financial Bandhan (4+5 without 9): money flows in but flows out. Must save FIRST before spending.',
    vipreet_raj: 'Vipreet Raj Yoga: hardship periods reverse into unexpected success. The worse it feels, the bigger the reversal.',
    raj_yoga: 'Raj Yoga: authority and recognition supported. Bold career/visibility moves backed.',
    spiritual: 'Spiritual Yoga: deep intuition and philosophical understanding elevated.',
    high_intuition: 'High Intuition Yoga: gut instinct is accurate — trust first reads.',
    uplifting_319: 'Uplifting 319 Yoga: courage, wisdom and authority combine — leadership supported.',
    bandhan: 'Bandhan Yoga: feeling trapped or constrained. Navigate the constraint, do not fight it.',
    accident_prone: 'Accident-prone combination in natal: physical caution always recommended.',
  };
  return yogas.filter(y => !y.combo_key).map(y =>
    `- ${YOGA_DESC[y.id] || y.id}${y.positive ? '' : ' [shadow side active]'}`
  ).join('\n');
}

// ─── Compatibility context for other person ───────────────────────────────────
function buildCompatibilityContext(dob1, dob2, targetDate) {
  const b1 = basicNumber(new Date(dob1).getDate());
  const d1 = destinyNumber(dob1);
  const b2 = basicNumber(new Date(dob2).getDate());
  const d2 = destinyNumber(dob2);
  const maha2 = currentMahadasha(dob2);
  const antar2 = currentAntardasha(dob2);
  const monthly2 = currentMonthlyDasha(dob2, targetDate);

  const pair = PAIR_DYNAMICS[[Math.min(b1,b2), Math.max(b1,b2)].join('_')];
  const destPair = PAIR_DYNAMICS[[Math.min(d1,d2), Math.max(d1,d2)].join('_')];

  const relBB = getRelType(b1, b2);
  const relDD = getRelType(d1, d2);

  return `
OTHER PERSON'S CHART (DOB: ${dob2}):
Basic: ${b2} (${PNAME[b2]}) | Destiny: ${d2} (${PNAME[d2]})
Their current period: ${PNAME[maha2.number]} maha + ${PNAME[antar2.number]} antar + ${PNAME[monthly2.number]} monthly
Their antar ends: ${antar2.end?.slice(0,10)}

COMPATIBILITY:
Basic-to-basic: ${PNAME[b1]}(${b1}) vs ${PNAME[b2]}(${b2}) = ${relBB}
Destiny-to-destiny: ${PNAME[d1]}(${d1}) vs ${PNAME[d2]}(${d2}) = ${getRelType(d1,d2)}
Core dynamic: ${pair?.core || 'unique combination'}
Strength: ${pair?.strength || ''}
Tension: ${pair?.tension || ''}
Growth: ${pair?.growth || ''}
`;
}

// ─── Knowledge chunks per question type ───────────────────────────────────────
const KNOWLEDGE = {
  finance: `
FINANCE KNOWLEDGE:
- Saturn maha = slow compounding income. No shortcuts. What is built with integrity lasts.
- Ketu antar = material detachment. Money flow slows or stops. Financial luck can arrive unexpectedly but also leaves unexpectedly.
- Rahu antar = financial chaos, impulsive decisions, get-rich-quick traps. Verify everything.
- Mars antar = financial momentum and action. Energy converts to income.
- Mercury monthly(5) = sharpest financial window. Deals, negotiations, income possible.
- Ketu monthly(7) = unexpected financial luck. Easy Money activates.
- Rahu monthly(4) = financial instability. Avoid major commitments.
- Saturn monthly(8) = delay, karmic debt collecting. Effort required, returns slow.
- Financial Bandhan remedy: save BEFORE spending, never after. Set aside first.
- Easy Money yoga: activated on Mercury(5) and Ketu(7) monthly windows.
- Odd 8 in natal = financial effort required, not effortless accumulation.
- Even 8s (2,4,6...) in natal = wealth building support.
`,
  relationship: `
RELATIONSHIP KNOWLEDGE:
- Venus monthly(6) = most romantic, relationship-opening window.
- Moon monthly(2) = deep emotional connection, creativity, sensitivity.
- Ketu antar = emotional detachment, partner may pull away. NOT permanent.
- Rahu antar = chaos in relationships. Impulsive decisions including breakups.
- Mars antar = passionate but volatile. Relationships intensify.
- Saturn antar = karmic relationships. Long-term serious connections form.
- Breakup during Rahu antar/monthly = impulsive, not necessarily final.
- Reconnection most natural when BOTH charts are in softer periods (Venus/Moon monthly).
- Destiny compatibility (both-ways friendly) = strong long-term pull.
- Basic compatibility (one-way) = attraction but work needed.
- Enemy planets in basic = friction but also intense attraction.
`,
  health: `
HEALTH KNOWLEDGE:
- Mars(9) dominant = blood pressure, inflammation, accidents, aggression.
- Saturn(8) dominant = chronic issues, bones, joints, fatigue, depression.
- Ketu(7) = mysterious symptoms, spiritual health, detox needed.
- Rahu(4) = mental health, anxiety, unusual symptoms, misdiagnosis risk.
- Moon(2) in natal = emotional health tied to physical. Gut issues.
- Sun(1) = vitality, immunity, heart.
- Mercury(5) = nervous system, communication-related stress.
- Saturn maha = chronic fatigue, joint issues, mental heaviness is common.
- Mars monthly = high energy but accident risk elevated.
- Ketu monthly = immune dip possible, also healing acceleration.
`,
  career: `
CAREER KNOWLEDGE:
- Saturn maha = career built through sustained effort. Slow promotions. No shortcuts. What is built lasts.
- Sun monthly(1) = visibility, authority, best time for promotions/recognition.
- Mercury monthly(5) = business deals, negotiations, communication-based income.
- Jupiter monthly(3) = wisdom-based work, advisory, teaching, planning.
- Mars antar = action, competition, leadership opportunities.
- Rahu antar = unconventional career paths open. Also instability.
- Ketu antar = career detachment phase. Inner work. Don't make major moves.
- Basic 5 (Mercury) = commerce, communication, intelligence-based careers.
- Destiny 4 (Rahu) = unconventional paths, research, technology, disruption.
`,
  timing: `
TIMING KNOWLEDGE:
- Use pre-calculated timeline to identify current, past and upcoming periods.
- Lucky days calculated from monthly dasha + WLORDS formula.
- Basic 5 (Mercury): luckiest days = daily 5, 7, 1.
- Mercury monthly(5) and Ketu monthly(7) = best financial windows.
- Venus monthly(6) and Moon monthly(2) = best relationship windows.
- Sun monthly(1) and Mars monthly(9) = best action/career windows.
- Saturn monthly(8) = best for long-term building, not quick wins.
- Always give specific date when asked "kab" — use lucky day from timeline.
`,
  family: `
FAMILY KNOWLEDGE:
- Saturn maha = karmic family dynamics surface. Old wounds reopen to heal.
- Moon(2) in natal/maha = deeply family-oriented, emotional family bonds.
- Jupiter(3) = wisdom, elder guidance, family expansion (children/marriage).
- Rahu = family disruption, unconventional family situations.
- Ketu = detachment from family, spiritual separation, not permanent.
- Mars = family conflicts, aggression, also protection.
- Saturn antar = family responsibilities increase. Karmic duty period.
`,
  general: `
GENERAL KNOWLEDGE:
- Answer based on the user's full chart — natal, maha, antar, monthly, daily.
- Always identify the current period quality and what it means for the question.
- Give specific timing using the pre-calculated timeline.
- Give one remedy or action when relevant.
- Vipreet Raj: hardship reverses into gain. Never tell user to give up in hard periods.
`,
};

// ─── Build complete system prompt ─────────────────────────────────────────────
export function buildSystemPrompt(dob, targetDate, questionType, otherDob = null) {
  const ctx = buildChartContext(dob, targetDate);
  const profile = getDeepNumberProfile(ctx.basic, ctx.destiny, ctx.maha, ctx.natalNums);
  const dasha = getDashaExperience(ctx.maha, ctx.antar);
  const timeline = buildTimeline(dob, targetDate);
  const timelineStr = formatTimeline(timeline, ctx.basic, ctx.destiny);
  const yogaStr = describeYogas(ctx.yogas);

  const compatSection = otherDob
    ? buildCompatibilityContext(dob, otherDob, targetDate)
    : '';

  const currentPeriod = timeline.find(t => t.status === 'current');
  const nextGoodPeriod = timeline.find(t =>
    t.status === 'future' && ['strong','good'].includes(getPeriodQuality(t.antar, t.monthly, ctx.basic, ctx.destiny))
  );

  return `You are an Ank Jyotish (Vedic numerology) assistant representing Pankajj Kumar Mishra, an expert Ank Jyotish and Palmist.

PERSONA & TONE:
- Speak in the same language the user writes in — Hindi, English, or Hinglish exactly as they use it.
- Use "aapka" / "aap" (respectful) when speaking in Hindi/Hinglish.
- Be direct, warm, and accurate. Like a trusted astrologer speaking one-on-one.
- Short responses. No long paragraphs. No bullet lists unless listing specific dates.
- Never use planet names unless user asks. Say "is period mein" not "Saturn maha mein".
- Never say "as per your chart" or "according to numerology" — just say it directly.
- If other person's DOB is not known but needed for accuracy, ask naturally in 1 line at the end.
- Always give at least one specific date or time window when answering timing questions.

SYSTEM DATE: ${targetDate}

USER'S COMPLETE CHART (DOB: ${dob}):
Basic Number: ${ctx.basic} (${PNAME[ctx.basic]})
Destiny Number: ${ctx.destiny} (${PNAME[ctx.destiny]})
Maha Dasha: ${ctx.maha} (${PNAME[ctx.maha]}) — ${[0,1,2,3,4,5,6,7,8,9][ctx.maha] || ctx.maha} year period, ends: ${currentPeriod?.mahaEnd || 'see timeline'}
Antar Dasha: ${ctx.antar} (${PNAME[ctx.antar]}) — current chapter, ends: ${currentPeriod?.antarEnd || 'see timeline'}
Monthly Dasha: ${ctx.monthly} (${PNAME[ctx.monthly]}) — ends: ${currentPeriod?.end || 'see timeline'}
Daily Number today: ${ctx.daily} (${PNAME[ctx.daily]})
Natal Numbers PRESENT (with frequency): ${Object.entries(ctx.natalFreq || {}).map(([k,v]) => k + (v>1 ? '(x'+v+')' : '')).join(', ')}
Numbers ABSENT from natal (= POSITIVE/LUCKY when active): ${[1,2,3,4,5,6,7,8,9].filter(n => !ctx.natalNums.includes(n)).join(', ') || 'none — all numbers present'}
IMPORTANT: Numbers listed as PRESENT above are IN the chart. Do NOT say they are absent. Double-check before every analysis.

PERSONALITY PATTERN:
${profile?.pattern || ''}
Money pattern: ${profile?.money_pattern || ''}
Love pattern: ${profile?.love_pattern || ''}
Work pattern: ${profile?.work_pattern || ''}
Shadow: ${profile?.shadow || ''}

CURRENT PERIOD EXPERIENCE:
${dasha?.what_it_feels_like || ''}
What is actually happening: ${dasha?.what_is_actually_happening || ''}
Antar context: ${dasha?.antar_context || ''}

ACTIVE YOGAS:
${yogaStr}

PERIOD TIMELINE (past 12 months + next 18 months with lucky days):
${timelineStr}

${compatSection}

${KNOWLEDGE[questionType] || KNOWLEDGE.general}

STRICT RULES ABOUT DASHA DURATIONS (NEVER DEVIATE):
- Sun(1) = 1 year, Moon(2) = 2 years, Jupiter(3) = 3 years, Rahu(4) = 4 years
- Mercury(5) = 5 years, Venus(6) = 6 years, Ketu(7) = 7 years, Saturn(8) = 8 years, Mars(9) = 9 years
- These are FIXED. Never say Jupiter is 12 or 16 years. Never use Vedic Vimshottari durations.
- This system uses Ank Jyotish durations ONLY — number = years exactly.

MOST IMPORTANT RULE — MISSING NUMBER = POSITIVE (NEVER GET THIS WRONG):
- If a number is ABSENT from natal chart, that dasha/period is POSITIVE and lucky for the person.
- If a number is PRESENT in natal chart, that dasha/period brings challenges/lessons related to that energy.
- Example: Natal has no 9 (Mars) → Any Mars period (maha/antar/monthly) = POSITIVE, expansive, energetic.
- Example: Natal has no 7 (Ketu) → Ketu period = LUCKY, spiritual breakthroughs, unexpected gains.
- Example: Natal has 8 (Saturn) → Saturn period = heavy, karmic, delays, hard work required.
- ALWAYS check natal numbers before calling any period negative or positive.
- User's natal numbers are listed above. Cross-reference every period against this list.

ANTARDASHA DATES — USE EXACT DATES FROM TIMELINE (NEVER APPROXIMATE):
- Each antardasha has exact start and end dates in the timeline provided.
- Never say "March-August" if the actual date is "August 11". Use the exact dates given.
- If asked about a specific period, check the timeline and give the exact start and end date.

RESPONSE RULES:
1. Reference past period experiences to show accuracy ("pichle 2-3 mahine mein aisa feel hua hoga...")
2. Give current period explanation without jargon
3. Give specific turnaround timing with exact month
4. Give luckiest upcoming day from timeline
5. Give ONE remedy or action — specific, not generic
6. Keep total response under 120 words
7. If other person mentioned but no DOB — give partial answer, ask DOB in last line naturally
8. You have full memory of past conversations. Reference them naturally when relevant — "jaise aapne pehle poocha tha..." or "last time we discussed..."
9. NEVER ask for information already given in conversation history. Check history before asking anything.`;
}

// ─── Extract other person DOB from conversation ───────────────────────────────
export function extractOtherDob(messages) {
  // Look through last few messages for a DOB pattern
  const dobPattern = /\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})\b/g;
  const allText = messages.slice(-6).map(m => m.content).join(' ');
  const matches = [...allText.matchAll(dobPattern)];
  if (matches.length >= 2) {
    // Second DOB = other person
    const m = matches[matches.length - 1];
    const day = m[1].padStart(2,'0');
    const month = m[2].padStart(2,'0');
    const year = m[3].length === 2 ? '20'+m[3] : m[3];
    return `${year}-${month}-${day}`;
  }
  return null;
}

// ─── Extract year from question ──────────────────────────────────────────────
export function extractYearFromQuestion(text) {
  // Match 4-digit year 20xx that appears standalone (not part of full date)
  const t = text;
  // Skip if full date present
  if (/\d{1,2}[\/-]\d{1,2}[\/-]20\d{2}/.test(t)) return null;
  if (/20\d{2}[\/-]\d{1,2}[\/-]\d{1,2}/.test(t)) return null;
  // Skip if month name + year
  if (/(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+20\d{2}/i.test(t)) return null;
  // Match year
  const match = t.match(/\b(20\d{2})\b/);
  if (!match) return null;
  return parseInt(match[1]);
}

// ─── Extract specific date + time from question ───────────────────────────────
export function extractDateTimeFromQuestion(text) {
  // Match dates in various formats: 21/03/2023, 21-03-2023, 21 March 2023, March 21 2023
  const datePatterns = [
    /\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})\b/,
    /\b(\d{4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})\b/,
    /\b(\d{1,2})\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{4})\b/i,
    /\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2})[,\s]+(\d{4})\b/i,
  ];

  const MONTHS = { jan:1,feb:2,mar:3,apr:4,may:5,jun:6,jul:7,aug:8,sep:9,oct:10,nov:11,dec:12 };

  let date = null;
  for (const pattern of datePatterns) {
    const m = text.match(pattern);
    if (m) {
      try {
        let day, month, year;
        if (/^\d{4}/.test(m[0])) {
          year = parseInt(m[1]); month = parseInt(m[2]); day = parseInt(m[3]);
        } else if (/[a-z]/i.test(m[2] || '')) {
          day = parseInt(m[1]); month = MONTHS[(m[2]||'').slice(0,3).toLowerCase()]; year = parseInt(m[3]);
        } else if (/[a-z]/i.test(m[1] || '')) {
          month = MONTHS[(m[1]||'').slice(0,3).toLowerCase()]; day = parseInt(m[2]); year = parseInt(m[3]);
        } else {
          day = parseInt(m[1]); month = parseInt(m[2]); year = parseInt(m[3]);
        }
        if (day && month && year && year > 1900 && year < 2100) {
          date = `${year}-${String(month).padStart(2,'0')}-${String(day).padStart(2,'0')}`;
          break;
        }
      } catch(_) {}
    }
  }

  // Extract time: 9 AM, 9:00 AM, 9 baje, 21:00
  let hour = null;
  const timePatterns = [
    /\b(\d{1,2}):(\d{2})\s*(am|pm)?/i,
    /\b(\d{1,2})\s*(am|pm)\b/i,
    /\b(\d{1,2})\s*baje\b/i,
    /\b(\d{1,2})\s*o'?clock\b/i,
  ];
  for (const tp of timePatterns) {
    const tm = text.match(tp);
    if (tm) {
      let h = parseInt(tm[1]);
      const ampm = (tm[2] || tm[3] || '').toLowerCase();
      if (ampm === 'pm' && h < 12) h += 12;
      if (ampm === 'am' && h === 12) h = 0;
      hour = h;
      break;
    }
  }

  return date || hour !== null ? { date, hour } : null;
}

// ─── Build historical date context for system prompt ──────────────────────────
export async function buildHistoricalContext(dob, targetDate, targetHour = null) {
  function red(n){while(n>9){n=String(n).split('').reduce((a,b)=>a+parseInt(b),0);}return n;}
  const WLORDS = [1,2,9,5,3,6,8];
  const PNAME = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};

  try {
    const basic = basicNumber(new Date(dob).getDate());
    const destiny = destinyNumber(dob);
    const maha = currentMahadasha(dob, targetDate);
    const antar = currentAntardasha(dob, targetDate);
    const monthly = currentMonthlyDasha(dob, new Date(targetDate).toISOString());
    const wd = new Date(targetDate).getDay();
    const daily = red(monthly.number + WLORDS[wd]);
    const h12 = targetHour !== null ? (targetHour > 12 ? targetHour - 12 : targetHour === 0 ? 12 : targetHour) : null;
    const hourly = h12 !== null ? red(daily + h12) : null;
    const natalNums = Object.keys(buildFrequencyMap(dob)).map(Number);

    const findings = analyzeDayChart({ basic, destiny, maha: maha.number, antar: antar.number, monthly: monthly.number, daily, hourly, natalNums });
    const score = getDayScore({ basic, destiny, maha: maha.number, antar: antar.number, monthly: monthly.number, daily, natalNums });

    const accidents = findings.filter(f => f.type === 'accident');
    const opportunities = findings.filter(f => f.type === 'opportunity');
    const allFindings = findings.map(f => `[${f.type}/${f.level}] ${f.label}: ${f.detail}`).join('\n');

    return `
HISTORICAL DATE ANALYSIS (${targetDate}${targetHour !== null ? ` at ${targetHour}:00` : ''}):
Chart on that date:
- Maha: ${maha.number} (${PNAME[maha.number]})
- Antar: ${antar.number} (${PNAME[antar.number]})
- Monthly: ${monthly.number} (${PNAME[monthly.number]})
- Daily: ${daily} (${PNAME[daily]})
${hourly !== null ? `- Hourly: ${hourly} (${PNAME[hourly]})` : ''}
Day Score: ${score}/100

Findings on that date:
${allFindings || 'No significant findings'}

Accident risk on that date: ${accidents.length > 0 ? accidents.map(a => `${a.level.toUpperCase()} — ${a.detail}`).join('; ') : 'No accident conditions triggered by the chart'}
`;
  } catch(e) {
    return `\nHistorical analysis for ${targetDate}: Unable to calculate — ${e.message}`;
  }
}

// ─── Build full year accident analysis ───────────────────────────────────────
export async function buildYearAccidentAnalysis(dob, year) {
  function red(n){while(n>9){n=String(n).split('').reduce((a,b)=>a+parseInt(b),0);}return n;}
  const WLORDS = [1,2,9,5,3,6,8];
  const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  try {
    const basic = basicNumber(new Date(dob).getDate());
    const destiny = destinyNumber(dob);
    const natalNums = Object.keys(buildFrequencyMap(dob)).map(Number);

    const start = new Date(year + '-01-01');
    const end = new Date(year + '-12-31');
    let cursor = new Date(start);

    const highDays = [];
    const medDays = [];

    while (cursor <= end) {
      const dateStr = cursor.toISOString().slice(0,10);
      const maha = currentMahadasha(dob, dateStr);
      const antar = currentAntardasha(dob, dateStr);
      const monthly = currentMonthlyDasha(dob, cursor.toISOString());
      const wd = cursor.getDay();
      const daily = red(monthly.number + WLORDS[wd]);

      let highHours = [];
      for (let h = 0; h < 24; h++) {
        const h12 = h > 12 ? h - 12 : h === 0 ? 12 : h;
        const hourly = red(daily + h12);
        const hf = analyzeDayChart({ basic, destiny, maha: maha.number, antar: antar.number, monthly: monthly.number, daily, hourly, natalNums });
        if (hf.some(f => f.type === 'accident' && f.level === 'high')) highHours.push(h + ':00');
      }

      if (highHours.length > 0) {
        highDays.push({ date: dateStr, label: cursor.getDate() + ' ' + MONTHS[cursor.getMonth()], highHours });
      } else {
        const df = analyzeDayChart({ basic, destiny, maha: currentMahadasha(dob,dateStr).number, antar: currentAntardasha(dob,dateStr).number, monthly: monthly.number, daily, hourly: null, natalNums });
        if (df.some(f => f.type === 'accident' && f.level === 'medium')) {
          medDays.push(cursor.getDate() + ' ' + MONTHS[cursor.getMonth()]);
        }
      }
      cursor.setDate(cursor.getDate() + 1);
    }

    const byMonth = {};
    highDays.forEach(d => {
      const m = d.date.slice(5,7);
      if (!byMonth[m]) byMonth[m] = [];
      byMonth[m].push(d.label + ' (' + d.highHours.slice(0,2).join(', ') + ')');
    });

    let summary = '\nACCIDENT RISK ANALYSIS FOR ' + year + ':\n';
    summary += 'High-risk days: ' + highDays.length + '\n';
    summary += 'Medium-risk days: ' + medDays.length + '\n\n';

    if (highDays.length > 0) {
      summary += 'HIGH RISK DAYS (with dangerous hours):\n';
      Object.entries(byMonth).forEach(([m, days]) => {
        summary += MONTHS[parseInt(m)-1] + ': ' + days.join(', ') + '\n';
      });
    }
    if (medDays.length > 0) {
      summary += '\nMEDIUM RISK DAYS: ' + medDays.slice(0,15).join(', ') + '\n';
    }
    summary += '\nNote: High-risk hours are when Mars and Rahu energy aligns across multiple layers simultaneously.';
    return summary;
  } catch(e) {
    return 'Year analysis error: ' + e.message;
  }
}
