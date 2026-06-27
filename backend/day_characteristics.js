// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — TODAY'S CHARACTER (plain, grounded English — no jargon)
// Reads the 4 time layers + natal and returns a SHORT, COHERENT set of day notes.
// Key rules:
//   • Conflicts are reconciled (energy + caution → one nuanced headline, not two cards)
//   • One note per theme group (no "high-energy" AND "bold mover" duplication)
//   • Grounded adult tone — no cutesy labels, no planets, no fear
// ═══════════════════════════════════════════════════════════════════════════════

const FRIENDLY = {
  1:[1,2,3,9], 2:[1,2,3,6], 3:[1,2,3,5,9], 4:[4,5,7],
  5:[3,4,5,6], 6:[2,5,6,7], 7:[4,6,7], 8:[8], 9:[1,3,9],
};
const ENEMY = {
  1:[4,6,8], 2:[4,5,8,9], 3:[4,6,8], 4:[1,2,3,9],
  5:[1,2,8,9], 6:[1,3,4,9], 7:[1,2,3,8,9], 8:[1,2,3,4,5,6,9], 9:[2,4,5,6,8],
};
const rel = (a, b) => FRIENDLY[a]?.includes(b) ? 'f' : ENEMY[a]?.includes(b) ? 'e' : 'n';

// Headline character of the day (from today's number). `kind` drives conflict logic.
const DAY_CORE = {
  1: { label:'A day to lead',          text:"Today favors taking charge and starting what you've been putting off.", kind:'drive' },
  2: { label:'A people-first day',     text:"Today leans toward relationships and emotions more than tasks.",        kind:'soft'  },
  3: { label:'A clear-headed day',     text:"Your judgment is sharp today — good for decisions and planning.",        kind:'mind'  },
  4: { label:'A day for care',         text:"Today rewards slowing down and checking the details before you act.",    kind:'care'  },
  5: { label:'A sharp, practical day', text:"Strong for money, deals, and clear communication.",                      kind:'mind'  },
  6: { label:'A warm day',             text:"Today favors relationships, comfort, and creative work.",                 kind:'soft'  },
  7: { label:'A quiet, intuitive day', text:"Trust your instinct today — things tend to settle in your favour.",       kind:'calm'  },
  8: { label:'A steady, patient day',  text:"Progress is slow but solid — patience counts more than speed today.",    kind:'care'  },
  9: { label:'An energetic day',       text:"Strong drive today, well suited to decisive action.",                     kind:'drive' },
};

export function buildDayCharacteristics(ctx) {
  const { maha, antar, monthly, daily, basic, destiny, natalNums = [] } = ctx;
  const periods = [maha, antar, monthly];
  const has = (n) => periods.includes(n) || daily === n || natalNums.includes(n);
  const countAcross = (n) => periods.filter(x => x === n).length + (daily === n ? 1 : 0);

  // ── Detect the active caution signals ──
  const physicalCaution = (daily === 4 && has(9)) || (daily === 9 && has(4));
  const foggy = countAcross(4) >= 2 && !physicalCaution;
  const heavy = countAcross(8) >= 2;

  // ── 1. Headline — reconciles core nature with the dominant modifier ──
  let head = { ...DAY_CORE[daily], group:'core', tone:'neutral' };
  if (head.kind === 'drive' && physicalCaution) {
    // energy + caution → ONE nuanced line, not two contradicting cards
    head = {
      label: 'Energetic — but pace yourself',
      text: "Plenty of drive today, but it's a day to avoid rushing and physical risk. Use the energy without letting it run away with you.",
      group: 'core', tone: 'gentle',
    };
  } else if (head.kind === 'drive') {
    head.tone = 'good';
  } else if (head.kind === 'care' || head.kind === 'calm' || head.kind === 'soft') {
    head.tone = 'neutral';
  }
  const out = [head];

  // ── 2. A standalone caution note ONLY if it wasn't folded into the headline ──
  if (physicalCaution && head.group === 'core' && head.kind !== undefined && head.label !== 'Energetic — but pace yourself') {
    out.push({ label:'A day to slow down', text:"Avoid rushing and take physical things easy — haste is where mistakes come from today.", group:'caution', tone:'gentle', priority:88 });
  } else if (foggy) {
    out.push({ label:'Things may feel unclear', text:"Double-check before committing — not everything is as it seems today.", group:'caution', tone:'gentle', priority:84 });
  } else if (heavy) {
    out.push({ label:'A heavier day', text:"Things may move slowly — go easy on yourself and stay patient.", group:'caution', tone:'gentle', priority:80 });
  }

  // ── 3. How the timing sits (combine the 3 period layers) — one note ──
  let support = 0;
  for (const p of periods) { const r = rel(p, daily); if (r === 'f') support++; else if (r === 'e') support--; }
  if (support >= 2)
    out.push({ label:'The timing supports you', text:"Your current chapter backs today's energy — a good day to push forward.", group:'phase', tone:'good', priority:75 });
  else if (support <= -2)
    out.push({ label:'Timing runs against you', text:"Today pushes against your current chapter a little — keep things measured.", group:'phase', tone:'gentle', priority:75 });

  // ── 4. How it fits you (natal) — one note ──
  if (daily === basic)
    out.push({ label:'A day that suits you', text:"Today runs on your natural wavelength — your strengths come easily.", group:'personal', tone:'good', priority:72 });
  else if (rel(basic, daily) === 'f')
    out.push({ label:'Plays to your strengths', text:"Today suits your natural style — lean into it.", group:'personal', tone:'good', priority:60 });
  else if (rel(basic, daily) === 'e')
    out.push({ label:'Asks a bit more of you', text:"Today sits slightly outside your usual comfort zone — handle it steadily.", group:'personal', tone:'gentle', priority:58 });
  else if (daily === destiny)
    out.push({ label:'In line with your path', text:"Today fits the bigger direction you're moving in.", group:'personal', tone:'good', priority:62 });

  // ── 5. One optional standout note (money / relationships / intuition) ──
  if (daily === 7 && natalNums.includes(5))
    out.push({ label:'Good money instincts', text:"Your sense around money is sharp and a little fortunate today.", group:'standout', cat:'money', tone:'good', priority:70 });
  else if ((daily === 5 && has(7)) || (daily === 7 && has(5)))
    out.push({ label:'Money may come easier', text:"A day money tends to flow a little more freely than usual.", group:'standout', cat:'money', tone:'good', priority:66 });
  else if ((daily === 6 && has(2)) || (daily === 2 && has(6)))
    out.push({ label:'Warmth in relationships', text:"Connections feel softer and easier today — a good day to reach out.", group:'standout', cat:'relationship', tone:'good', priority:64 });
  else if (countAcross(7) >= 2)
    out.push({ label:'Strong inner sense', text:"A reflective day — your instincts are especially worth trusting.", group:'standout', cat:'luck', tone:'good', priority:62 });

  // ── Keep one per group, drop duplicate labels, cap to a clean few ──
  const ICON = { drive:'energy', care:'care', calm:'luck', soft:'relationship', mind:'core' };
  const catFor = (c) => {
    if (c.group === 'core') return ICON[DAY_CORE[daily]?.kind] || 'core';
    if (c.group === 'caution') return 'care';
    if (c.group === 'phase') return 'phase';
    if (c.group === 'personal') return 'personal';
    if (c.group === 'standout') return c.cat || 'luck';
    return 'core';
  };
  const seenGroup = new Set();
  const seenLabel = new Set();
  const result = [];
  for (const c of out.sort((a, b) => (b.priority ?? 100) - (a.priority ?? 100))) {
    if (seenGroup.has(c.group) || seenLabel.has(c.label)) continue;
    seenGroup.add(c.group); seenLabel.add(c.label);
    result.push({ label:c.label, text:c.text, category:catFor(c), tone:c.tone, _core:c.group === 'core' });
    if (result.length >= 4) break;
  }
  // headline (core) always first
  result.sort((a, b) => (b._core ? 1 : 0) - (a._core ? 1 : 0));
  return result.map(({ label, text, category, tone }) => ({ label, text, category, tone }));
}
