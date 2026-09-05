// ═══════════════════════════════════════════════════════════════════════════
// DASHA POLARITY — shared "is this number's dasha negative right now" engine
//
// Source: voice-note rules from Pankajj Kumar Mishra (astrologer), Sept 2026.
// Encoded here as the SINGLE source of truth so every negative yoga across
// the codebase (column_yogas.js, prediction_engine.js, predictions.js,
// chart_analysis_library.js) reads the same rule instead of drifting.
//
// CORE PRINCIPLE FROM THE SOURCE: any negative yoga in a chart is only
// actually negative while the person's CURRENT dasha is itself negative.
// Antardasha negative → strong/fast impact. Mahadasha negative → slower/
// weaker impact. Either being negative is enough to activate the yoga;
// neither negative means the yoga is structurally present but dormant.
//
// Per-number rules for "is this number's own dasha negative":
//   1 — Destiny 1: any repetition always positive, no negative case.
//       Non-destiny-1: single occurrence (missing → dasha fills it) =
//       positive. Multiple occurrence = negative (lack of leadership/
//       authority/discipline).
//   4 — Dasha of 4 is ALWAYS base-negative (delusion / unmet expectations /
//       fraud risk). Severity modulated by parity of 4's total count in the
//       full chart: even (2 or 4) = softened, resolves; odd = amplified.
//   8 — Missing natally, dasha brings a single 8 = negative (struggle).
//       Already present natally: even total repetition (2 or 4) = positive,
//       delays ease. Odd repetition beyond the first (3, 5) = worse,
//       disease-yoga risk increases.
//   9 — Multiple appearance = negative, UNLESS Basic AND Destiny are BOTH 9
//       (then repetition doesn't hurt, brings progress instead).
//   2,3,5,6,7 — general rule: missing natally + dasha brings a single
//       occurrence = positive (per that number's own domain). Already
//       present natally + dasha repeats it = negative.
//
// Basic/Destiny protection: whenever the CURRENTLY RUNNING dasha (maha or
// antar) equals the person's own Basic or Destiny number, the money/power
// dimension of that dasha is positive regardless of repetition count —
// EXCEPT for dashas of 4 and 7, which never get this protection.
// ═══════════════════════════════════════════════════════════════════════════

const has = (freq, n) => (freq[n] || 0) > 0;
const count = (freq, n) => freq[n] || 0;
const isEven = (n) => n > 0 && n % 2 === 0;

const BASIC_DESTINY_EXCEPTION_NUMS = new Set([4, 7]);

/**
 * Polarity of a specific number's own dasha, judged against the full
 * combined chart (natal + Mahadasha + Antardasha + Monthly).
 *
 * ctx: { natalFreq, fullFreq, basic, destiny }
 * Returns { negative, moneyPowerPositive, severity?, note }
 */
export function dashaNumberPolarity(n, ctx) {
  const { natalFreq, fullFreq, basic, destiny } = ctx;
  const isBasicOrDestiny = n === basic || n === destiny;
  const moneyPowerProtected = isBasicOrDestiny && !BASIC_DESTINY_EXCEPTION_NUMS.has(n);

  // ── Number 1 — fully Destiny-gated ──
  if (n === 1) {
    if (destiny === 1) {
      return { negative: false, moneyPowerPositive: true, note: 'Destiny 1 — any repetition of 1 is positive.' };
    }
    const c = count(fullFreq, 1);
    if (c >= 2) return { negative: true, moneyPowerPositive: false, note: 'Non-destiny-1, multiple 1 — lack of leadership/authority/discipline.' };
    return { negative: false, moneyPowerPositive: false, note: 'Single 1, non-destiny — positive leadership/authority induction.' };
  }

  // ── Number 4 — always base-negative, parity of total count modulates severity ──
  if (n === 4) {
    const c = count(fullFreq, 4);
    const softened = isEven(c) && c > 0;
    return {
      negative: true,
      moneyPowerPositive: false, // 4 is on the exception list — never protected
      severity: softened ? 'mild' : 'amplified',
      note: softened
        ? 'Rahu dasha — delusion / unmet-expectation / fraud-risk effects occur but resolve (even repetition of 4).'
        : 'Rahu dasha — delusion / unmet-expectation / fraud-risk effects amplified (odd repetition of 4).',
    };
  }

  // ── Number 8 — parity-of-repetition rule ──
  if (n === 8) {
    const wasMissing = !has(natalFreq, 8);
    const c = count(fullFreq, 8);
    if (wasMissing && c === 1) {
      return { negative: true, moneyPowerPositive: moneyPowerProtected, note: 'Saturn dasha filling a natally-missing 8 — struggle, heavy effort.' };
    }
    if (!wasMissing) {
      if (isEven(c) && c > 0) return { negative: false, moneyPowerPositive: true, note: 'Even repetition of natally-present 8 — delays ease, strong positive results.' };
      if (!isEven(c) && c > 1) return { negative: true, moneyPowerPositive: moneyPowerProtected, note: 'Odd repetition (3+) of natally-present 8 — struggle and disease-risk amplify.' };
    }
    return { negative: false, moneyPowerPositive: moneyPowerProtected, note: 'Baseline 8, no repetition shift.' };
  }

  // ── Number 9 — multiple appearance negative, unless Basic AND Destiny are both 9 ──
  if (n === 9) {
    const c = count(fullFreq, 9);
    if (basic === 9 && destiny === 9) {
      return { negative: false, moneyPowerPositive: true, note: 'Basic and Destiny both 9 — repetition does not hurt, brings progress.' };
    }
    if (c >= 2) return { negative: true, moneyPowerPositive: moneyPowerProtected, note: 'Multiple 9 (without Basic+Destiny both 9) — negative impact.' };
    return { negative: false, moneyPowerPositive: moneyPowerProtected, note: 'Baseline 9, no repetition shift.' };
  }

  // ── Remaining numbers 2, 3, 5, 6, 7 — general missing/present rule ──
  const wasMissing = !has(natalFreq, n);
  const c = count(fullFreq, n);
  if (wasMissing && c === 1) {
    return { negative: false, moneyPowerPositive: true, note: `Dasha fills natally-missing ${n} — positive, per its own domain.` };
  }
  if (!wasMissing && c >= 1) {
    return { negative: true, moneyPowerPositive: moneyPowerProtected, note: `Natally-present ${n} repeating via dasha — negative, except money/power if Basic/Destiny.` };
  }
  return { negative: false, moneyPowerPositive: moneyPowerProtected, note: 'Baseline, no repetition shift.' };
}

/**
 * The general gate used to decide whether a structural negative yoga
 * (Bandhan, Misfortune, Defamation, Depression, etc.) is actually
 * manifesting right now, based on whether the CURRENTLY RUNNING dasha
 * layers (Mahadasha / Antardasha) are themselves negative.
 *
 * ctx: { maha, antar, natalFreq, fullFreq, basic, destiny }
 * Returns { active, intensity: 'strong'|'mild'|'none', source?, polarity? }
 */
export function currentDashaGate(ctx) {
  const { maha, antar, natalFreq, fullFreq, basic, destiny } = ctx;
  const base = { natalFreq, fullFreq, basic, destiny };
  const antarPolarity = antar ? dashaNumberPolarity(antar, base) : null;
  const mahaPolarity = maha ? dashaNumberPolarity(maha, base) : null;

  if (antarPolarity?.negative) return { active: true, intensity: 'strong', source: 'antar', polarity: antarPolarity };
  if (mahaPolarity?.negative) return { active: true, intensity: 'mild', source: 'maha', polarity: mahaPolarity };
  return { active: false, intensity: 'none' };
}

/**
 * Symmetric counterpart to currentDashaGate — the gate used to decide
 * whether a structural POSITIVE yoga (Raj Yoga, Easy Money, Spiritual,
 * Vipreet Raj, etc.) is actually manifesting right now. Per the same source
 * rule: any yoga only truly activates while the CURRENTLY RUNNING dasha is
 * itself of the matching polarity — positive dasha activates positive
 * yogas (from natal chart or from the dasha itself), negative dasha
 * activates negative ones (see currentDashaGate). Antardasha dominates when
 * it is itself positive (strong/fast); Mahadasha being positive with a
 * negative Antardasha still gives a mild activation.
 */
export function currentPositiveDashaGate(ctx) {
  const { maha, antar, natalFreq, fullFreq, basic, destiny } = ctx;
  const base = { natalFreq, fullFreq, basic, destiny };
  const antarPolarity = antar ? dashaNumberPolarity(antar, base) : null;
  const mahaPolarity = maha ? dashaNumberPolarity(maha, base) : null;

  if (antarPolarity && !antarPolarity.negative) return { active: true, intensity: 'strong', source: 'antar', polarity: antarPolarity };
  if (mahaPolarity && !mahaPolarity.negative) return { active: true, intensity: 'mild', source: 'maha', polarity: mahaPolarity };
  return { active: false, intensity: 'none' };
}

export { has, count, isEven };
