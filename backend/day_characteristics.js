// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — TODAY'S CHARACTER (plain English, no jargon)
// Replaces the vague "score / 100". Reads the 4 time layers + natal and returns a
// LIST of simple day-characteristics (multiple can apply). Focused on TODAY.
//
// Tone is balanced — 'good' / 'neutral' / 'gentle' (never scary). No planet names.
// Many rules → the SET that fires is combinatorial, so far more than 44 day-profiles.
// ═══════════════════════════════════════════════════════════════════════════════

const FRIENDLY = {
  1:[1,2,3,9], 2:[1,2,3,6], 3:[1,2,3,5,9], 4:[4,5,7],
  5:[3,4,5,6], 6:[2,5,6,7], 7:[4,6,7], 8:[8], 9:[1,3,9],
};
const ENEMY = {
  1:[4,6,8], 2:[4,5,8,9], 3:[4,6,8], 4:[1,2,3,9],
  5:[1,2,8,9], 6:[1,3,4,9], 7:[1,2,3,8,9], 8:[1,2,3,4,5,6,9], 9:[2,4,5,6,8],
};

// Plain word for each number's energy (used inside generated text). No planets.
const THEME = {
  1:'drive', 2:'emotion', 3:'clear thinking', 4:'caution',
  5:'money and words', 6:'warmth', 7:'intuition', 8:'patience', 9:'energy',
};

// The headline character of the day (always shown), from today's number.
const DAY_CORE = {
  1: { label:'Lead the way',   text:"Today's energy pushes you to take charge and start things." },
  2: { label:'Heart-led day',  text:"Today is about people and feelings more than ticking off tasks." },
  3: { label:'Clear-minded day',text:"Your thinking is sharp and positive — good for plans and decisions." },
  4: { label:'Careful day',    text:"Today asks you to slow down and double-check before acting." },
  5: { label:'Sharp & social', text:"Strong energy for talking, deals, and money matters." },
  6: { label:'Warm day',       text:"A gentle day for relationships, comfort, and creativity." },
  7: { label:'Lucky & quiet',  text:"Trust your gut today — things tend to quietly fall into place." },
  8: { label:'Slow-burn day',  text:"Progress is steady but quiet — patience pays off today." },
  9: { label:'High-energy day',text:"Lots of drive today — great for action, just stay calm with it." },
};

const rel = (a, b) => FRIENDLY[a]?.includes(b) ? 'f' : ENEMY[a]?.includes(b) ? 'e' : 'n';

export function buildDayCharacteristics(ctx) {
  const { maha, antar, monthly, daily, basic, destiny, natalNums = [] } = ctx;
  const periods = [maha, antar, monthly];
  const has = (n) => periods.includes(n) || daily === n || natalNums.includes(n);
  const countAcross = (n) => periods.filter(x => x === n).length + (daily === n ? 1 : 0);
  const out = [];

  // ── 1. CORE: today's headline character (always) ──
  out.push({ ...DAY_CORE[daily], category:'core', tone:'neutral', priority:100 });

  // ── 2. How today fits your current life phases (combine the 3 period layers) ──
  let support = 0;
  for (const p of periods) { const r = rel(p, daily); if (r === 'f') support++; else if (r === 'e') support--; }
  if (support >= 2)
    out.push({ label:'Strong tailwind', text:"Your current phases are backing today's energy — a good day to push forward.", category:'phase', tone:'good', priority:92 });
  else if (support <= -2)
    out.push({ label:'A little headwind', text:"Today runs against your current phases a bit — keep it light and don't force big moves.", category:'phase', tone:'gentle', priority:92 });
  else
    out.push({ label:'Mixed currents', text:"Some of today supports you, some pushes back — pick your moments.", category:'phase', tone:'neutral', priority:58 });

  // ── 3. How today fits YOU (natal personality) ──
  if (daily === basic)
    out.push({ label:'Feels like you', text:"Today runs on your natural wavelength — your strengths come easily.", category:'personal', tone:'good', priority:86 });
  else if (rel(basic, daily) === 'f')
    out.push({ label:'Plays to your strengths', text:"Today suits your natural style — lean into it.", category:'personal', tone:'good', priority:68 });
  else if (rel(basic, daily) === 'e')
    out.push({ label:'Stretch day', text:"Today nudges you a bit outside your comfort zone — a chance to grow.", category:'personal', tone:'gentle', priority:66 });
  if (daily === destiny)
    out.push({ label:'On-path day', text:"Today lines up with your bigger direction in life.", category:'personal', tone:'good', priority:74 });

  // ── 4. Amplified theme (today's number echoed in your timing) ──
  if (periods.filter(p => p === daily).length >= 1)
    out.push({ label:'Amplified day', text:`Today's ${THEME[daily]} shows up across your timing too — a concentrated ${THEME[daily]} day.`, category:'core', tone:'neutral', priority:80 });

  // ── 5. Doubled-up influences (a number repeating across layers) ──
  if (countAcross(8) >= 2) out.push({ label:'Heavy day', text:"Things may feel slow or weighty today — be patient with yourself and others.", category:'care', tone:'gentle', priority:78 });
  if (countAcross(7) >= 2) out.push({ label:'Deeply intuitive', text:"A reflective, quiet day — your inner sense is strong, so trust it.", category:'luck', tone:'good', priority:78 });
  if (countAcross(9) >= 2) out.push({ label:'High intensity', text:"Strong energy all around today — great for action, but keep your temper in check.", category:'energy', tone:'gentle', priority:78 });
  if (countAcross(4) >= 2) out.push({ label:'Foggy day', text:"Things may feel unclear today — double-check before you commit to anything.", category:'care', tone:'gentle', priority:78 });
  if (countAcross(1) >= 2) out.push({ label:'Bold day', text:"A strong pull to lead and act — just remember to bring others along.", category:'energy', tone:'good', priority:72 });
  if (countAcross(6) >= 2) out.push({ label:'Warm & social', text:"Relationships and comfort feel extra good today — enjoy the people around you.", category:'relationship', tone:'good', priority:72 });
  if (countAcross(3) >= 2) out.push({ label:'Optimistic day', text:"A naturally hopeful, forward-looking day — good for planning ahead.", category:'core', tone:'good', priority:70 });
  if (countAcross(2) >= 2) out.push({ label:'Tender day', text:"Feelings sit closer to the surface today — be gentle with yourself and others.", category:'care', tone:'gentle', priority:70 });

  // ── 6. Meaningful pairings (today's number meeting what's active) ──
  if ((daily === 4 && has(9)) || (daily === 9 && has(4)))
    out.push({ label:'Careful-pace day', text:"A day to slow down — avoid rushing, take physical things easy, and don't make hasty moves.", category:'care', tone:'gentle', priority:88 });
  if (daily === 7 && natalNums.includes(5))
    out.push({ label:'Lucky money sense', text:"Your instincts around money are sharp and a little lucky today.", category:'money', tone:'good', priority:84 });
  else if ((daily === 5 && has(7)) || (daily === 7 && has(5)))
    out.push({ label:'Easy gains', text:"A day money tends to come a little more easily than usual.", category:'money', tone:'good', priority:80 });
  if ((daily === 6 && has(2)) || (daily === 2 && has(6)))
    out.push({ label:'Love & warmth', text:"Relationships feel softer and warmer today — a good day to connect.", category:'relationship', tone:'good', priority:76 });
  if ((daily === 1 && has(9)) || (daily === 9 && has(1)))
    out.push({ label:'Bold mover', text:"Strong drive to lead and take action — channel it into one big thing.", category:'energy', tone:'good', priority:74 });
  if (daily === 5 && (has(3) || has(6)))
    out.push({ label:'Words land well', text:"A good day for conversations, pitches, and getting your point across.", category:'money', tone:'good', priority:70 });
  if (daily === 8 && has(8))
    out.push({ label:'Patience test', text:"Things move slowly today — steady effort matters far more than speed.", category:'care', tone:'gentle', priority:72 });

  // sort by importance, drop duplicate labels, keep the top few
  const seen = new Set();
  return out
    .sort((a, b) => b.priority - a.priority)
    .filter(c => (seen.has(c.label) ? false : (seen.add(c.label), true)))
    .slice(0, 5)
    .map(({ label, text, category, tone }) => ({ label, text, category, tone }));
}
