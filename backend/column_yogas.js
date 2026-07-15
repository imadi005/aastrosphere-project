// ═══════════════════════════════════════════════════════════════════════════
// COLUMN YOGAS — Grid Column 1 (3-6-2) and Column 2 (1-7-8)
//
// Source: 22-minute recorded explanation by Pankajj Kumar Mishra (astrologer),
// July 2026. Transcribed and encoded here as the SINGLE source of truth for
// these combinations — both the chatbot (prediction_engine.js) and the
// astrologer-side chart tools (predictions.js) call into this file, so the
// logic can never drift between the two surfaces again.
//
// GRID POSITIONS (matches NUMBER_POSITION_MAP):
//   Column 1 (left):   3 (top) · 6 (middle) · 2 (bottom)
//   Column 2 (middle): 1 (top) · 7 (middle) · 8 (bottom)
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
// ═══════════════════════════════════════════════════════════════════════════

const has = (freq, n) => (freq[n] || 0) > 0;
const count = (freq, n) => freq[n] || 0;
const isEven = (n) => n > 0 && n % 2 === 0;

// ─── COLUMN 1 — Jupiter(3) / Venus(6) / Moon(2) ─────────────────────────────
export function analyzeColumn1(annualFreq) {
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
    out.push({ id: 'col1_3_2', name: 'Jupiter-Moon (no Venus)', positive: false, description: desc });
  }

  // ── 3 & 6 present, 2 missing ──
  if (n3 && n6 && !n2) {
    let desc = 'Strong, rigid personal ethics. Drawn to higher education and religious or dharmic practice. ' +
      'Major life success typically arrives after marriage — the life partner often changes the trajectory.';
    if (c3 > 1) desc += ' Repeated 3 softens this — more flexible, less duty-bound, adapts more easily in relationships.';
    if (c6 > 1) desc += ' Repeated 6 turns speech blunt or harsh — frequent relationship conflict as a result.';
    out.push({ id: 'col1_3_6', name: 'Jupiter-Venus (no Moon)', positive: false, description: desc });
  }

  // ── 6 & 2 present, 3 missing ──
  if (n6 && n2 && !n3) {
    let desc = 'Attractive, magnetic presence with a strong pull toward artistic pursuits — painting, music, ' +
      'dance, acting. Enjoys being seen, often drawn to media, photography, or content creation. Strong ' +
      'attraction to the opposite sex, with a real possibility of multiple relationships. More emotional than ' +
      'most, and often doesn\u2019t settle easily with a spouse.';
    if (c2 > 1) desc += ' Repeated 2 amplifies all of this — creativity and emotional intensity both increase substantially.';
    if (c6 > 1) desc += ' Repeated 6 turns speech blunt or harsh, causing recurring conflict — relationships become unstable, ' +
      'breaking and reforming — even as personal magnetism keeps increasing.';
    out.push({ id: 'col1_6_2', name: 'Venus-Moon (no Jupiter)', positive: false, description: desc });
  }

  return out;
}

// ─── COLUMN 2 — Sun(1) / Ketu(7) / Saturn(8) ────────────────────────────────
export function analyzeColumn2(annualFreq) {
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
    out.push({ id: 'misfortune_78', name: 'Ketu-Saturn (no Sun)', positive: positive78, description: desc });
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
    out.push({ id: 'defamation_risk', name: 'Sun-Saturn (no Ketu)', positive: positive18, description: desc });
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

// Convenience: run both columns and return a flat array in the same
// {id, name, positive, description} shape used across the codebase.
export function analyzeColumnYogas(annualFreq) {
  return [...analyzeColumn1(annualFreq), ...analyzeColumn2(annualFreq)];
}
