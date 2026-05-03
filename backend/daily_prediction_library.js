// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — DEEP DAILY PREDICTION LIBRARY
// All predictions use: natal(basic) + maha + antar + monthly + daily
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Maha dasha context — what the multi-year period is doing ─────────────────
export const MAHA_CONTEXT = {
  1: { theme: "Sun period — authority, recognition, and leadership are the multi-year direction", signal: "The Sun period favors visibility, bold moves, and career advancement. What you build now is seen.", finance: "Income through authority and leadership roles. Bold financial moves are supported.", caution: "Ego can override wisdom this period — check yourself when confidence becomes certainty." },
  2: { theme: "Moon period — emotional depth, creative work, and deep relationships are being activated", signal: "The Moon period amplifies sensitivity, intuition, and creative output. What you feel is accurate.", finance: "Income through creative work and emotional intelligence. Relationships bring opportunity.", caution: "Emotional swings can affect decisions — ground yourself before committing." },
  3: { theme: "Jupiter period — wisdom, growth, and ethical decisions shape the multi-year arc", signal: "The Jupiter period is one of genuine expansion — through knowledge, values, and right action.", finance: "Income through expertise, advisory work, and principled decisions. The long arc is favorable.", caution: "Over-expansion is the Jupiter trap — not every opportunity is the right one." },
  4: { theme: "Rahu period — disruption, unconventional paths, and unexpected developments define this chapter", signal: "The Rahu period breaks patterns. What seemed fixed is being questioned. The unconventional path opens.", finance: "Income can arrive through unexpected channels. Financial caution is essential — verify everything.", caution: "This period amplifies impulsiveness and financial risk — slow down before committing." },
  5: { theme: "Mercury period — communication, commerce, and sharp intelligence are the period's tools", signal: "The Mercury period rewards clarity, quick thinking, and commercial intelligence.", finance: "This is among the strongest financial periods. Business decisions made with care hold.", caution: "Overthinking and anxiety are the Mercury period's shadow — act on the analysis." },
  6: { theme: "Venus period — beauty, relationships, and creative richness define this multi-year arc", signal: "The Venus period brings aesthetic and relational richness. What's beautiful is also what works.", finance: "Income through creative work, beauty, and relationships. Spending impulse is elevated.", caution: "Indulgence and over-spending are the Venus period risks — beauty requires discipline too." },
  7: { theme: "Ketu period — spiritual depth, withdrawal, and unexpected fortune shape this chapter", signal: "The Ketu period is one of inner work and unusual luck. What appears to be loss is often redirection.", finance: "Fortune can arrive unexpectedly. Financial caution — Ketu is unstable, not lucky in the conventional sense.", caution: "Detachment can become avoidance this period — stay engaged with what matters." },
  8: { theme: "Saturn period — karma, discipline, and sustained effort are the period's language", signal: "The Saturn period is the great teacher. What is built with integrity lasts. Shortcuts cost double.", finance: "Slow and genuine income accumulation. Long-term financial moves are supported. Speculation is not.", caution: "Emotional heaviness and delay are Saturn's tools — they are teaching, not punishing." },
  9: { theme: "Mars period — courage, energy, and decisive action define this multi-year arc", signal: "The Mars period demands physical and professional engagement. Energy is available — use it deliberately.", finance: "Bold financial moves supported. Recklessness is not courage — choose the risks deliberately.", caution: "Aggression, anger, and impulsive action are the Mars period risks. Pause before reacting." },
};

// ─── Antar dasha context — what inner chapter is running ─────────────────────
export const ANTAR_CONTEXT = {
  1: { theme: "Authority chapter — leadership opportunities are being activated within the larger period", doing: "This chapter is creating openings for recognition, leadership, and bold action.", overlay: "Whatever the maha period is teaching, this chapter activates it through initiative and visibility." },
  2: { theme: "Connection chapter — emotional relationships and creative work are being highlighted", doing: "This chapter deepens emotional connections and amplifies creative sensitivity.", overlay: "The emotional intelligence available now is unusually high." },
  3: { theme: "Wisdom chapter — sound judgment and ethical decisions are being supported", doing: "This chapter activates the advisory, the principled decision, the long-term view.", overlay: "Trust your judgment this chapter — it's operating at a higher level than usual." },
  4: { theme: "Disruption chapter — unexpected changes and unconventional paths are being activated", doing: "This chapter breaks patterns that needed breaking. The disruption is directional, not random.", overlay: "Verify financial decisions carefully — Rahu chapter amplifies both opportunity and risk." },
  5: { theme: "Intelligence chapter — commercial and communication sharpness are running", doing: "This chapter activates financial instinct, communication clarity, and business intelligence.", overlay: "The analytical capacity is sharp right now — trust the numbers, act on the analysis." },
  6: { theme: "Harmony chapter — creative work and relationships are being activated", doing: "This chapter brings beauty, social warmth, and romantic possibility into the foreground.", overlay: "Aesthetic and relational investments made now carry weight beyond this chapter." },
  7: { theme: "Luck chapter — unexpected fortune and spiritual depth are the inner chapter's gifts", doing: "This chapter brings quiet luck and philosophical depth. Things work out without forcing.", overlay: "Trust intuition over analysis this chapter. The luck is real but subtle." },
  8: { theme: "Karma chapter — sustained effort and ethical commitment are being demanded", doing: "This chapter is clarifying what was built on solid ground versus what was built on convenience.", overlay: "Shortcuts taken now compound into problems later. The discipline required is the point." },
  9: { theme: "Energy chapter — passion, courage, and physical intensity are being activated", doing: "This chapter raises the energy. Physical vitality, competitive instinct, and boldness are available.", overlay: "Channel the energy into something deliberate — it will find its own direction if you don't." },
};

// ─── Monthly dasha — this period's immediate flavor ──────────────────────────
export const MONTHLY_CONTEXT = {
  1: "Sun month — authority and visibility are the month's dominant current.",
  2: "Moon month — emotional depth and creative sensitivity are elevated this month.",
  3: "Jupiter month — wisdom, sound judgment, and ethical clarity are running this month.",
  4: "Rahu month — unpredictability and unconventional possibilities define this month.",
  5: "Mercury month — commercial and intellectual sharpness peak this month.",
  6: "Venus month — beauty, warmth, and social ease are the month's texture.",
  7: "Ketu month — quiet luck and spiritual depth are available this month.",
  8: "Saturn month — discipline, karmic effort, and sustained work are this month's demand.",
  9: "Mars month — energy, courage, and physical intensity are the month's fuel.",
};

// ─── Daily number layer — what today specifically brings ─────────────────────
export const DAILY_LAYER = {
  1: { quality: "Authority day", signal: "Today carries Sun energy — initiative, confidence, and bold decisions are backed.", best_for: "Starting things, making asks, taking visible action", watch: "Ego overriding judgment" },
  2: { quality: "Connection day", signal: "Today carries Moon energy — emotional depth and creative sensitivity are elevated.", best_for: "Meaningful conversations, creative work, reaching out", watch: "Financial decisions made from feeling" },
  3: { quality: "Clarity day", signal: "Today carries Jupiter energy — wisdom and sound judgment are accessible.", best_for: "Planning, advising, writing, important decisions", watch: "Ethical shortcuts — consequences amplify today" },
  4: { quality: "Research day", signal: "Today carries Rahu energy — research ability peaks but stability drops.", best_for: "Investigating, understanding, background checking", watch: "Financial commitments — verify everything twice" },
  5: { quality: "Business day", signal: "Today carries Mercury energy — financial instinct and commercial sharpness peak.", best_for: "Deals, negotiations, financial decisions, communication", watch: "Overthinking past the action window" },
  6: { quality: "Harmony day", signal: "Today carries Venus energy — beauty, warmth, and creative flow are available.", best_for: "Creative work, social connection, romantic expression", watch: "Harsh words — the tongue is sharper today" },
  7: { quality: "Fortune day", signal: "Today carries Ketu energy — luck is quiet and real. Instinct outperforms analysis.", best_for: "Important decisions, key meetings, following hunches", watch: "Forcing outcomes — allow what wants to arrive" },
  8: { quality: "Karma day", signal: "Today carries Saturn energy — effort compounds. Shortcuts cost double.", best_for: "Sustained work, completing what was started, building", watch: "Impatience — today's effort doesn't show immediately" },
  9: { quality: "Energy day", signal: "Today carries Mars energy — physical capacity and competitive instinct peak.", best_for: "Physical activity, bold moves, confronting what's avoided", watch: "Unnecessary conflicts — the aggression is available" },
};

// ─── Core daily guidance by natal basic + daily combination ──────────────────
// 81 combinations — what YOUR basic number does with today's daily
// BASIC_DAILY_GUIDANCE moved to basic_daily_guidance_library.js
import { BASIC_DAILY_GUIDANCE } from './basic_daily_guidance_library.js';


export function getPersonalizedGuidance(basic, daily, maha, antar, yogas) {
  const guidance = BASIC_DAILY_GUIDANCE[basic]?.[daily];
  const mahaCtx = MAHA_CONTEXT[maha];
  const dailyLayer = DAILY_LAYER[daily];

  let doList = guidance?.do ? [...guidance.do] : [
    `Today is ${dailyLayer.quality}. ${dailyLayer.best_for}.`,
    `The ${mahaCtx.theme.split(' — ')[0]} supports this direction today.`,
  ];

  let avoidList = guidance?.avoid ? [...guidance.avoid] : [
    `Watch for: ${dailyLayer.watch}`,
    mahaCtx.caution,
  ];

  // Yoga overlays
  for (const yoga of yogas) {
    if (yoga.id === 'easy_money' && yoga.positive) {
      doList.unshift("Financial opportunity is structurally backed today — act on what presents itself");
    }
    if (yoga.id === 'financial_bandhan') {
      avoidList.unshift("Financial Bandhan is active — the spending impulse is strongest today. Set aside before spending.");
    }
    if (yoga.id === 'raj_yoga' && yoga.positive) {
      doList.unshift("Raj Yoga is active — authority and recognition moves have maximum backing today");
    }
    if (yoga.id === 'high_intuition') {
      doList.push("High Intuition yoga active — trust the first read over extended analysis today");
    }
    if (yoga.id === 'vipreet_raj') {
      doList.push("The difficulty of today is structural not personal — it is building something real");
    }
    if (yoga.id === 'bandhan') {
      avoidList.push("Bandhan yoga active — navigate the constraint, don't fight it. Find the door.");
    }
  }

  // Antar override for key combinations
  if (antar === 7) { // Ketu antar
    if ([5,7,1].includes(daily)) {
      doList.unshift("Ketu chapter + favorable daily — quiet fortune is available. Act before overanalyzing.");
    }
  }
  if (antar === 4) { // Rahu antar
    avoidList.push("Rahu chapter active — financial decisions today require external verification regardless of confidence level");
  }

  return { do: doList.slice(0, 5), avoid: avoidList.slice(0, 4) };
}

// ─── Day rating using full chart ──────────────────────────────────────────────
export function assessFullDayRating(basic, destiny, maha, antar, monthly, daily, yogas, freqMap) {
  const VEDIC_RELS = {
    1:{f:[3,9,5],e:[2,7]}, 2:{f:[1,3],e:[4,5,8]}, 3:{f:[1,2,9],e:[5,6]},
    4:{f:[4,6,7],e:[1,2,8]}, 5:{f:[1,4],e:[2,3,9]}, 6:{f:[4,5],e:[1,2,3]},
    7:{f:[4,6],e:[1,2]}, 8:{f:[4,5,6],e:[1,2,3]}, 9:{f:[1,2,3],e:[5,6]},
  };
  function rel(a,b) { return VEDIC_RELS[a]?.f.includes(b)?1:VEDIC_RELS[a]?.e.includes(b)?-1:0; }

  let score = 0;

  // Basic vs daily relationship (natal planet meets today's planet)
  score += rel(basic, daily) * 3;
  // Destiny vs daily
  score += rel(destiny, daily) * 2;
  // Maha vs daily
  score += rel(maha, daily) * 2;
  // Antar vs daily
  score += rel(antar, daily) * 2;
  // Monthly vs daily
  score += rel(monthly, daily) * 1;

  // Yogas
  const positiveYogas = yogas.filter(y => y.positive).length;
  const negativeYogas = yogas.filter(y => !y.positive).length;
  score += positiveYogas * 2;
  score -= negativeYogas * 2;

  // Same number = amplification
  if (daily === basic) score += 2;
  if (daily === destiny) score += 1;
  if (daily === maha) score += 1;

  if (score >= 5) return 'favorable';
  if (score >= 1) return 'good';
  if (score >= -2) return 'caution';
  return 'avoid';
}
