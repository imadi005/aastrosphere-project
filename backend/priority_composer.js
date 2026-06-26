// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — TODAY'S PRIORITY COMPOSER (plain English)
// Builds the 2-pointer priority (DO + AVOID) from ALL FOUR layers:
//   maha (life phase) + antar (sub-current) + monthly (this month) + daily (today)
// ~45 fragments → 6,561 unique combinations. No planet/dasha jargon.
//
//   DO    = MAHA_LEAD[maha] + DAILY_FOCUS[daily] + MONTHLY_TAIL[monthly]
//   AVOID = DAILY_CAUTION[daily] + ANTAR_TAIL[antar]
// ═══════════════════════════════════════════════════════════════════════════════

// Life-phase opener (maha) — sets the context, flows into the daily action.
const MAHA_LEAD = {
  1: "With recognition on your side right now, ",
  2: "In this people-and-feelings phase, ",
  3: "In this growth-and-learning phase, ",
  4: "With things a little unclear in this phase, ",
  5: "In this fast, business-minded phase, ",
  6: "In this warm, relationship-focused phase, ",
  7: "In this quiet, intuitive phase, ",
  8: "In this slow, build-it-right phase, ",
  9: "In this high-energy phase, ",
};

// Core action for today (daily) — the main thing to do.
const DAILY_FOCUS = {
  1: "take the lead and start what you've been putting off",
  2: "have the honest conversation that's been waiting",
  3: "make the decision or plan you've been sitting on",
  4: "slow down and double-check before committing to anything",
  5: "handle the money, deal, or important message head-on",
  6: "put real effort into a relationship or something creative",
  7: "trust your gut on the call that matters",
  8: "finish the hard task you keep pushing aside",
  9: "take the bold action you've been holding back",
};

// This-month nudge (monthly) — closes the DO line.
const MONTHLY_TAIL = {
  1: " — this month rewards stepping forward.",
  2: " — this month favors connection over rushing.",
  3: " — the timing this month suits thoughtful moves.",
  4: " — but move carefully this month.",
  5: " — this month is good for practical action.",
  6: " — this month favors warmth and balance.",
  7: " — trust the timing this month.",
  8: " — steady effort pays off most this month.",
  9: " — there's real momentum this month, so use it.",
};

// Core caution for today (daily) — the main thing to avoid.
const DAILY_CAUTION = {
  1: "Don't let ego or overconfidence take over",
  2: "Don't make money or work choices from pure emotion",
  3: "Don't rush or cut corners",
  4: "Don't sign, buy big, or trust blindly",
  5: "Don't overthink it or get greedy",
  6: "Don't overspend or say something harsh",
  7: "Don't force an outcome that needs time",
  8: "Don't take shortcuts or give up early",
  9: "Don't pick fights or rush in recklessly",
};

// Sub-current nuance (antar) — closes the AVOID line.
const ANTAR_TAIL = {
  1: " — stand firm, but don't steamroll people.",
  2: " — and stay aware of how others feel.",
  3: " — keep it honest and clear.",
  4: " — verify anything that feels uncertain first.",
  5: " — keep your words and numbers precise.",
  6: " — don't let comfort turn into excess.",
  7: " — and listen to that quiet inner signal.",
  8: " — patience will serve you better than pressure.",
  9: " — channel the energy, don't let it boil over.",
};

const clamp9 = (n) => {
  const x = Number(n);
  if (!x || x < 1) return 1;
  return ((Math.floor(x) - 1) % 9) + 1;
};

export function buildPriority(maha, antar, monthly, daily) {
  const m = clamp9(maha), a = clamp9(antar), mo = clamp9(monthly), d = clamp9(daily);
  const doLine = MAHA_LEAD[m] + DAILY_FOCUS[d] + MONTHLY_TAIL[mo];
  const avoidLine = DAILY_CAUTION[d] + ANTAR_TAIL[a];
  return { do: doLine, avoid: avoidLine };
}
