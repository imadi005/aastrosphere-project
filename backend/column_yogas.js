// ═══════════════════════════════════════════════════════════════════════════
// COLUMN & ROW YOGAS — Grid Column 1 (3-6-2), Column 2 (1-7-8),
// Column 3 (9-5-4), and Row 3 / bottom row (2-8-4)
//
// Source: recorded explanations by Pankajj Kumar Mishra (astrologer),
// July + Sept 2026. Transcribed and encoded here as the SINGLE source of
// truth for these combinations — the chatbot (prediction_engine.js), the
// astrologer-side chart tools (predictions.js), and the daily caution
// alerts (chart_analysis_library.js) all call into this file, so the logic
// can never drift between surfaces.
//
// GRID POSITIONS (matches NUMBER_POSITION_MAP):
//   Column 1 (left):   3 (top) · 6 (middle) · 2 (bottom)
//   Column 2 (middle): 1 (top) · 7 (middle) · 8 (bottom)
//   Column 3 (right):  9 (top) · 5 (middle) · 4 (bottom)
//   Row 3 (bottom):    2 (left) · 8 (middle) · 4 (right)
//
// CORE RULE FROM THE RECORDING (applies to every combination below):
//   Whether a number counts as "present" or "missing" is judged against the
//   FULL COMBINED chart — natal digits + Mahadasha + Antardasha + Monthly —
//   NOT natal digits alone. If a number that was natally missing arrives via
//   a running dasha, the "missing" reading no longer applies; the reading
//   shifts entirely to the all-three-present combination for as long as that
//   dasha is active. A repeated number (via dasha) still only introduces its
//   OWN modifier effect (see below), it does not on its own complete a
//   missing slot unless it's the specific missing number.
//
// DASHA-NEGATIVE GATE (Sept 2026 update — applies to every negative-flagged
// combination in this file): a negative yoga is structurally always present
// once its numbers line up, but it only actually manifests while the
// CURRENTLY RUNNING dasha (Mahadasha or Antardasha) is itself negative, per
// dasha_polarity.js. Antardasha negative = strong/fast impact. Mahadasha
// negative (Antardasha not) = slower/weaker impact. Neither negative = the
// yoga is dormant — described in the reading, but not actively biting right
// now. Callers pass `dashaCtx = { natalFreq, basic, destiny, maha, antar }`
// to get this gating; omitting it just skips the active/dormant framing.
// ═══════════════════════════════════════════════════════════════════════════

import { currentDashaGate, dashaNumberPolarity } from './dasha_polarity.js';

const has = (freq, n) => (freq[n] || 0) > 0;
const count = (freq, n) => freq[n] || 0;
const isEven = (n) => n > 0 && n % 2 === 0;

// Appends an "active/dormant" sentence to a description when dashaCtx is
// available, using the shared dasha-negative gate.
function gateSuffix(annualFreq, dashaCtx) {
  if (!dashaCtx) return { active: undefined, intensity: undefined, suffix: '' };
  const gate = currentDashaGate({ ...dashaCtx, fullFreq: annualFreq });
  const suffix = gate.active
    ? ` Currently active — the running ${gate.source === 'antar' ? 'Antardasha' : 'Mahadasha'} is negative, so this is ${gate.intensity === 'strong' ? 'strongly and quickly' : 'more slowly'} in effect right now.`
    : ' Currently dormant — the running dasha is not itself negative, so this combination is not actively biting right now.';
  return { active: gate.active, intensity: gate.intensity, suffix };
}

// ─── COLUMN 1 — Jupiter(3) / Venus(6) / Moon(2) ─────────────────────────────
export function analyzeColumn1(annualFreq, dashaCtx) {
  const n3 = has(annualFreq, 3), n6 = has(annualFreq, 6), n2 = has(annualFreq, 2);
  const c3 = count(annualFreq, 3), c6 = count(annualFreq, 6), c2 = count(annualFreq, 2);
  const out = [];

  // ── All three present — a distinct, generally constructive combination ──
  if (n3 && n6 && n2) {
    out.push({
      id: 'col1_all_present',
      name: 'Grounded Creativity',
      positive: true,
      description: 'Jupiter, Venus and Moon all active together — creative or artistic instincts backed by ' +
        'ethics and emotional steadiness, rather than any single one of the individual 3-6 or 6-2 or 3-2 ' +
        'patterns pulling on its own.',
    });
    return out; // all-three overrides the individual missing-based readings below
  }

  // ── 3 & 2 present, 6 missing ──
  if (n3 && n2 && !n6) {
    let desc = 'Tendency to carry extra weight; may attract rivals but they rarely cause real harm. ' +
      'Drawn toward creativity-rich education. Common friction point: children — their studies, health, ' +
      'or upbringing. May also face some obstruction in their own education. Can come across as arrogant, ' +
      'which creates friction in both professional and personal life.';
    if (c3 > 1) desc += ' Repeated 3 softens this — more flexible, less rigid, adapts more easily in relationships.';
    if (c6 > 1) desc += ' Note: if 6 later becomes active more than once, speech tends to turn blunt and harsh, straining relationships.';
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'col1_3_2', name: 'Jupiter-Moon (no Venus)', positive: false, active, intensity, description: desc + suffix });
  }

  // ── 3 & 6 present, 2 missing ──
  if (n3 && n6 && !n2) {
    let desc = 'Strong, rigid personal ethics. Drawn to higher education and religious or dharmic practice. ' +
      'Major life success typically arrives after marriage — the life partner often changes the trajectory.';
    if (c3 > 1) desc += ' Repeated 3 softens this — more flexible, less duty-bound, adapts more easily in relationships.';
    if (c6 > 1) desc += ' Repeated 6 turns speech blunt or harsh — frequent relationship conflict as a result.';
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'col1_3_6', name: 'Jupiter-Venus (no Moon)', positive: false, active, intensity, description: desc + suffix });
  }

  // ── 6 & 2 present, 3 missing ──
  if (n6 && n2 && !n3) {
    let desc = 'Attractive, magnetic presence with a strong pull toward artistic pursuits — painting, music, ' +
      'dance, acting. Enjoys being seen, often drawn to media, photography, or content creation. Strong ' +
      'attraction to the opposite sex, with a real possibility of multiple relationships. More emotional than ' +
      'most, and often doesn’t settle easily with a spouse.';
    if (c2 > 1) desc += ' Repeated 2 amplifies all of this — creativity and emotional intensity both increase substantially.';
    if (c6 > 1) desc += ' Repeated 6 turns speech blunt or harsh, causing recurring conflict — relationships become unstable, ' +
      'breaking and reforming — even as personal magnetism keeps increasing.';
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'col1_6_2', name: 'Venus-Moon (no Jupiter)', positive: false, active, intensity, description: desc + suffix });
  }

  return out;
}

// ─── COLUMN 2 — Sun(1) / Ketu(7) / Saturn(8) ────────────────────────────────
export function analyzeColumn2(annualFreq, dashaCtx) {
  const n1 = has(annualFreq, 1), n7 = has(annualFreq, 7), n8 = has(annualFreq, 8);
  const c7 = count(annualFreq, 7), c8 = count(annualFreq, 8);
  const out = [];

  // ── All three present — "High Intuition", already a known positive read ──
  if (n1 && n7 && n8) {
    out.push({
      id: 'high_intuition',
      name: 'High Intuition',
      positive: true,
      description: 'Sun, Ketu and Saturn all active together — sharp intuitive instincts backed by discipline. ' +
        'This is its own distinct combination, not the bad-luck or defamation reading that applies when one ' +
        'of the three is missing.',
    });
    return out; // all-three overrides the individual missing-based readings below
  }

  // ── 7 & 8 present, 1 missing ──
  if (n7 && n8 && !n1) {
    let desc = 'Tends to experience bad luck and unfortunate events. Often develops a genuine pull toward ' +
      'spiritual practice, with real growth through it. Marital/physical intimacy can be a recurring source ' +
      'of difficulty. A pessimistic streak — seeing the negative side of situations — shapes thinking and, ' +
      'over time, outcomes.';
    let positive78 = false;
    if (c7 > 1) desc += ' Repeated 7 deepens the bad-luck factor — everything above intensifies.';
    if (isEven(c8) && c8 > 0) { desc += ' An even count of 8 (double, or four times) meaningfully improves this combination — delays and setbacks ease significantly.'; positive78 = true; }
    else if (!isEven(c8) && c8 > 1) { desc += ' An odd count of 8 beyond the first (three times, etc.) worsens this combination substantially.'; }
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'misfortune_78', name: 'Ketu-Saturn (no Sun)', positive: positive78, active: positive78 ? undefined : active, intensity: positive78 ? undefined : intensity, description: desc + (positive78 ? '' : suffix) });
  }

  // ── 1 & 8 present, 7 missing ──
  if (n1 && n8 && !n7) {
    let desc = 'Real risk of litigation or friction with government bodies/authorities, leading to financial ' +
      'or emotional loss and career setbacks. Insult or public embarrassment is a recurring theme. This takes ' +
      'a real toll on mental resilience — significant patience is needed to rebuild after such episodes.';
    let positive18 = false;
    if (isEven(c8) && c8 > 0) { desc += ' An even count of 8 (double, or four times) flips this combination positive — such people go on to achieve real success and wealth.'; positive18 = true; }
    else if (!isEven(c8) && c8 > 1) { desc += ' An odd count of 8 beyond the first (three times, etc.) makes this significantly harder — real struggle is needed to reach success.'; }
    desc += ' A repeated 1 makes no difference either way to this particular reading.';
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'defamation_risk', name: 'Sun-Saturn (no Ketu)', positive: positive18, active: positive18 ? undefined : active, intensity: positive18 ? undefined : intensity, description: desc + (positive18 ? '' : suffix) });
  }

  // ── 1 & 7 present, 8 missing ──
  if (n1 && n7 && !n8) {
    let desc = 'A genuinely fortunate combination — success tends to come early and with comparatively little ' +
      'struggle, including early-career or government-role opportunities. A love affair before or after ' +
      'marriage is common, sometimes leading to more than one marriage. Considered close to a Raj Yoga in ' +
      'classical Vedic terms — influential, lucky, prosperous.';
    if (c7 > 1) desc += ' Repeated 7 introduces some instability and repeated change — but such people still succeed, building real inner strength to push through it.';
    desc += ' A repeated 1 makes no difference either way to this particular reading.';
    out.push({ id: 'sun_ketu_raj', name: 'Sun-Ketu (no Saturn) — Raj Yoga', positive: true, description: desc });
  }

  return out;
}

// ─── COLUMN 3 — Mars(9) / Mercury(5) / Rahu(4) ──────────────────────────────
export function analyzeColumn3(annualFreq, dashaCtx) {
  const n9 = has(annualFreq, 9), n5 = has(annualFreq, 5), n4 = has(annualFreq, 4);
  const c5 = count(annualFreq, 5), c9 = count(annualFreq, 9);
  const basic = dashaCtx?.basic, destiny = dashaCtx?.destiny;
  const out = [];

  // ── All three present — Multi-Skilling Yoga ──
  if (n9 && n5 && n4) {
    out.push({
      id: 'col3_all_present',
      name: 'Multi-Skilling Yoga',
      positive: true,
      description: 'Mars, Mercury and Rahu all active together — a multi-skilled, multi-talented, ' +
        'multi-tasking jack-of-all-trades combination. Mostly positive: it mitigates and stabilizes Rahu’s ' +
        'usual negative impact rather than any single one of the individual 9-5, 9-4, or 5-4 patterns pulling ' +
        'on its own. One real downside — mastery in any single field tends to stay out of reach.',
    });
    return out; // all-three overrides the individual missing-based readings below
  }

  // ── 9 & 4 present, 5 missing — Bandhan Yoga ──
  // 5 is the grid blocker between 9 and 4; its absence lets Mars and Rahu
  // connect directly — the classic accident-and-hospitalization combination,
  // and per the source rule also carries a notably higher surgery chance.
  if (n9 && n4 && !n5) {
    let desc = 'Rahu and Mars connect directly with Mercury missing between them — Bandhan Yoga: suffocation, ' +
      'a chronically unsatisfied feeling, legal issues, and hospitalization risk. This combination also ' +
      'carries a notably higher chance of surgery.';
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'bandhan', name: 'Bandhan Yoga', positive: false, active, intensity, description: desc + suffix });
  }

  // ── 9 & 5 present, 4 missing — sharp financial mind, manipulative/fraud risk ──
  if (n9 && n5 && !n4) {
    let desc = 'Mars and Mercury present, Rahu missing — a sharp, talkative mind with a strong grasp of ' +
      'financial matters, but a manipulative streak that can tip into fraudulent tendencies.';
    if (c5 >= 3 && c9 === 1) {
      desc += ' Mercury repeating 3 or more times alongside a single Mars is the specific fraud-committer ' +
        'signature — real risk of getting involved in fraudulent activity.';
    }
    if (c9 >= 2) {
      desc += ' Repeated Mars on top of this makes for a slow learner, with real learning difficulties.';
    }
    if (destiny === 5 && c5 >= 2) {
      desc += ' With Destiny 5 and Mercury repeating, this flips into a strength — fast calculation ability, ' +
        'strong numerical and mental-math skills.';
    }
    out.push({ id: 'col3_sharp_mind_fraud_risk', name: 'Sharp Mind, Fraud Risk', positive: false, description: desc });
  }

  // ── 5 & 4 present, 9 missing — Financial Bandhan, with a fraud-victim escalation ──
  if (n5 && n4 && !n9) {
    let desc = 'Mercury and Rahu present, Mars missing — Financial Bandhan: impulsive spending and ' +
      'debt-accumulation risk.';
    const maleMissing = ![1, 3, 9].some(m => has(annualFreq, m));
    const femalePresent = [2, 6, 8].every(f => has(annualFreq, f));
    if (c5 >= 3 && maleMissing && femalePresent) {
      desc += ' Mercury repeating 3 or more times, with the male numbers (1, 3, 9) all missing and the female ' +
        'numbers (2, 6, 8) all present, escalates this to a real fraud-victim vulnerability — a strong chance ' +
        'of being cheated by someone else. Presence of 1 and 3 is what protects against this.';
    }
    out.push({ id: 'financial_bandhan', name: 'Financial Bandhan', positive: false, description: desc });
  }

  return out;
}

// ─── ROW 3 (bottom row) — Moon(2) / Saturn(8) / Rahu(4) ─────────────────────
export function analyzeRow3(annualFreq, dashaCtx) {
  const n2 = has(annualFreq, 2), n8 = has(annualFreq, 8), n4 = has(annualFreq, 4);
  const c2 = count(annualFreq, 2), c4 = count(annualFreq, 4);
  const out = [];

  // ── All three present — Vipreet Raj Yoga ──
  if (n2 && n8 && n4) {
    out.push({
      id: 'vipreet_raj',
      name: 'Vipreet Raj Yoga',
      positive: true,
      description: 'Moon, Saturn and Rahu all active together — Vipreet Raj Yoga. A lot of ups and downs, ' +
        'real struggle along the way, but despite all of it, real success is achievable. Any kind of addiction ' +
        'must be avoided — it undermines this combination badly. Two real downsides: difficulties in married ' +
        'life are common, and the unpredictable nature of life events under this combination can keep a ' +
        'person living with underlying fear.',
    });
    return out; // all-three overrides the individual missing-based readings below
  }

  // ── 8 & 4 present, 2 missing — Row Bandhan (accident risk) ──
  // 2 is the blocker between 8 and 4; its absence lets Saturn and Rahu
  // connect directly. Also layers in 8's own odd/even repetition polarity.
  if (n8 && n4 && !n2) {
    let desc = 'Saturn and Rahu connect directly with Moon missing between them — an accident-risk combination.';
    if (dashaCtx) {
      const polarity8 = dashaNumberPolarity(8, { natalFreq: dashaCtx.natalFreq, fullFreq: annualFreq, basic: dashaCtx.basic, destiny: dashaCtx.destiny });
      desc += polarity8.negative
        ? ' Saturn’s own repetition pattern in the chart is currently unfavorable, adding to the risk.'
        : ' Saturn’s own repetition pattern in the chart is currently favorable, easing this.';
    }
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'row_bandhan', name: 'Row Bandhan — Accident Risk', positive: false, active, intensity, description: desc + suffix });
  }

  // ── 2 & 8 present, 4 missing — Depression Yoga ──
  // Same bottom row, missing 4 instead of 2 — per the source rule this
  // carries both depression risk AND accident/mishap risk together.
  if (n2 && n8 && !n4) {
    let desc = 'Moon and Saturn present, Rahu missing — Depression Yoga. Carries emotional-weight and ' +
      'depression risk alongside accident and mishap risk, together capable of significantly disturbing the ' +
      'person overall.';
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'depression_yoga', name: 'Depression Yoga', positive: false, active, intensity, description: desc + suffix });
  }

  // ── 2 & 4 present, 8 missing ──
  if (n2 && n4 && !n8) {
    let desc = 'Moon and Rahu present, Saturn missing — mostly a negative combination: negative thought ' +
      'process, legal issues, difficult financial situations, and disturbances on the emotional front.';
    if (c2 > 1 && !isEven(c4) && c4 > 1) {
      desc += ' Moon repeating multiple times alongside Rahu appearing in odd multiples amplifies the ' +
        'negative impact further.';
    } else if (isEven(c4) && c4 > 0) {
      desc += ' Rahu appearing an even number of times mitigates the negative impact to a large extent.';
    }
    const { active, intensity, suffix } = gateSuffix(annualFreq, dashaCtx);
    out.push({ id: 'row3_2_4', name: 'Moon-Rahu (no Saturn)', positive: false, active, intensity, description: desc + suffix });
  }

  return out;
}

// Convenience: run all four (both columns + column 3 + row 3) and return a
// flat array in the same {id, name, positive, description} shape used
// across the codebase. dashaCtx = { natalFreq, basic, destiny, maha, antar }
// is optional — omit it to skip active/dormant gating (structural-only view).
export function analyzeColumnYogas(annualFreq, dashaCtx) {
  return [
    ...analyzeColumn1(annualFreq, dashaCtx),
    ...analyzeColumn2(annualFreq, dashaCtx),
    ...analyzeColumn3(annualFreq, dashaCtx),
    ...analyzeRow3(annualFreq, dashaCtx),
  ];
}
