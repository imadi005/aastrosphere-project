// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — TODAY'S PRIORITY (combine all 4 layers → one clean do/avoid)
// The four layers are WEIGHED together, not narrated:
//   • maha + antar + monthly decide the CONDITION (strong / mixed / tough)
//     by how they relate to today's number (friend = +1, enemy = -1)
//   • daily sets the THEME (what today is about)
//   • a risk-combo check (e.g. 4+9, 4+8) can override the AVOID
// Output: ONE simple do line + ONE simple avoid line. No jargon, no layer-narration.
// ═══════════════════════════════════════════════════════════════════════════════

const FRIENDLY = {
  1:[1,2,3,9], 2:[1,2,3,6], 3:[1,2,3,5,9], 4:[4,5,7],
  5:[3,4,5,6], 6:[2,5,6,7], 7:[4,6,7], 8:[8], 9:[1,3,9],
};
const ENEMY = {
  1:[4,6,8], 2:[4,5,8,9], 3:[4,6,8], 4:[1,2,3,9],
  5:[1,2,8,9], 6:[1,3,4,9], 7:[1,2,3,8,9], 8:[1,2,3,4,5,6,9], 9:[2,4,5,6,8],
};

// DO — by today's theme (daily) and the combined condition. One clean line each.
const DO = {
  1: { strong:["Take charge of the big thing today — you've got the momentum to pull it off.","Make the bold first move you've been delaying; today backs it."],
       mixed: ["Take the lead on your one main priority and focus there.","Step up where it matters most — don't try to do everything."],
       tough: ["Lead quietly — get your own work right before pushing others.","Pick one important thing and do it well, not ten things at once."] },
  2: { strong:["Have the honest, heartfelt conversation today — it'll land well.","Reach out to someone who matters; the connection is worth it today."],
       mixed: ["Make time for one important person, but keep your feelings steady.","Connect with someone — just don't let emotion drive big decisions."],
       tough: ["Stay close to people you trust and go easy on yourself today.","Lean on a steady friend instead of carrying everything alone."] },
  3: { strong:["Make the decision or plan you've been sitting on — your judgment is sharp.","Sort out the thing you've been overthinking; clarity is on your side."],
       mixed: ["Make your decision, but sleep on anything truly major.","Plan your next step clearly — keep it realistic, not over-ambitious."],
       tough: ["Hold off on big decisions; gather facts and plan quietly today.","Sort small things and get advice before committing to anything large."] },
  4: { strong:["Use your clear head to research and double-check the important things.","Dig into the details you've been avoiding — you'll spot what matters."],
       mixed: ["Check the facts before you commit to anything today.","Slow down and verify — don't take things at face value."],
       tough: ["Avoid big commitments today; just verify and wait for a clearer day.","Don't decide anything major — confusion is high, so hold."] },
  5: { strong:["Handle the deal, negotiation, or money decision today — you're sharp.","Send the important message or close the deal; the timing's good."],
       mixed: ["Make the practical money or work move, but check the numbers twice.","Handle one key transaction or message; don't overthink the rest."],
       tough: ["Hold off on risky money moves; tidy up and plan instead.","Review your finances quietly today rather than making deals."] },
  6: { strong:["Put real effort into a relationship or creative project — it pays off today.","Do something warm or creative; today rewards heart and care."],
       mixed: ["Invest in one relationship or creative task, and watch your spending.","Enjoy the day, but keep comfort and budget in balance."],
       tough: ["Keep relationships light today and avoid money-driven tension.","Focus on simple comfort and rest rather than big gestures."] },
  7: { strong:["Trust your gut on the important call today — your read is accurate.","Follow your instinct; the right things tend to line up today."],
       mixed: ["Trust your instinct, but pair it with a quick reality check.","Go with your gut on small things; sleep on the big ones."],
       tough: ["Stay quiet and observe today rather than forcing any outcome.","Don't chase results — let things settle and trust the timing."] },
  8: { strong:["Finish the hard task you keep avoiding — steady effort really pays today.","Put in the disciplined work; what you build today lasts."],
       mixed: ["Knock out one tough task at a steady pace; don't rush it.","Make slow, solid progress on the work that matters."],
       tough: ["Just maintain today — keep your routine and don't force progress.","Do the basics well and be patient; results come later."] },
  9: { strong:["Take the bold action you've been holding back — your drive is high today.","Tackle the tough thing head-on; you've got the energy for it."],
       mixed: ["Use your energy on one important task, and keep your temper in check.","Push forward on what matters, but don't pick unnecessary fights."],
       tough: ["Burn off the restless energy with exercise before making moves.","Channel the intensity into work, not into conflict, today."] },
};

// AVOID — by today's theme and condition. One clean line each.
const AVOID = {
  1: { strong:["Don't let confidence slide into arrogance.","Don't ignore others' input just because you're sure."],
       mixed: ["Don't try to control every detail.","Don't take on more than you can lead well."],
       tough: ["Don't force your authority — it'll backfire today.","Don't let frustration turn into ego battles."] },
  2: { strong:["Don't make money decisions from a high mood.","Don't over-promise because you feel good."],
       mixed: ["Don't take things too personally today.","Don't let emotion steer a work choice."],
       tough: ["Don't withdraw completely — stay a little connected.","Don't make any relationship decision while you're low."] },
  3: { strong:["Don't lecture when people just need to be heard.","Don't get overconfident in your own judgment."],
       mixed: ["Don't rush a decision that deserves a night's thought.","Don't cut ethical corners to move faster."],
       tough: ["Don't commit to anything big while things are unclear.","Don't trust advice that only tells you what you want to hear."] },
  4: { strong:["Don't act on assumptions — confirm first.","Don't skip the boring details today."],
       mixed: ["Don't sign, buy big, or trust blindly.","Don't take any deal that looks too easy."],
       tough: ["Don't make any major commitment today.","Don't believe the first version of a story."] },
  5: { strong:["Don't let sharp thinking turn into greed.","Don't overplay your hand in a negotiation."],
       mixed: ["Don't overthink simple choices.","Don't skip the fine print on money matters."],
       tough: ["Don't gamble or chase quick money today.","Don't make a financial move under pressure."] },
  6: { strong:["Don't overspend just because the mood is good.","Don't overindulge today."],
       mixed: ["Don't say something harsh you'll regret.","Don't spend money to fix a feeling."],
       tough: ["Don't let comfort turn into avoidance.","Don't force closeness that isn't flowing."] },
  7: { strong:["Don't over-explain what your gut already knows.","Don't force a result that wants time."],
       mixed: ["Don't ignore a quiet feeling that something's off.","Don't over-analyse a simple choice."],
       tough: ["Don't push for outcomes — let them come.","Don't make sudden reversals on impulse."] },
  8: { strong:["Don't take shortcuts that undo the work.","Don't expand faster than the foundation allows."],
       mixed: ["Don't give up just because it feels slow.","Don't rush a process that needs patience."],
       tough: ["Don't force progress when nothing's moving.","Don't abandon the routine that keeps you steady."] },
  9: { strong:["Don't let drive turn into recklessness.","Don't start a fight that costs more than it's worth."],
       mixed: ["Don't make rash decisions in the heat of the moment.","Don't rush physically — slow down to stay safe."],
       tough: ["Don't pick fights at home or work today.","Don't act on anger — let it cool first."] },
};

import { DO_I18N, AVOID_I18N, RISK_OVERRIDE_I18N } from './priority_composer_i18n.js';

const clamp9 = (n) => { const x = Number(n); if (!x || x < 1) return 1; return ((Math.floor(x) - 1) % 9) + 1; };

export function buildPriority(maha, antar, monthly, daily, lang) {
  const m = clamp9(maha), a = clamp9(antar), mo = clamp9(monthly), d = clamp9(daily);

  // 1) Combine the three period layers vs today → support score
  let support = 0;
  for (const layer of [m, a, mo]) {
    if (FRIENDLY[layer]?.includes(d)) support += 1;
    else if (ENEMY[layer]?.includes(d)) support -= 1;
  }
  const condition = support >= 2 ? 'strong' : support <= -2 ? 'tough' : 'mixed';

  // 2) Pick a clean line from the matching pool; period mix decides which variant
  const doPool = (lang && DO_I18N[lang]?.[d]) || DO[d];
  const avoidPool = (lang && AVOID_I18N[lang]?.[d]) || AVOID[d];
  const pick = (pools) => { const arr = pools[condition]; return arr[(m * 7 + a * 13 + mo * 5) % arr.length]; };
  const doLine = pick(doPool);
  let avoidLine = pick(avoidPool);

  // 3) Risk-combo override on the AVOID (physical / financial caution)
  const layers = [m, a, mo];
  const pair = (x, y) => (d === x && layers.includes(y)) || (d === y && layers.includes(x));
  const RO = (lang && RISK_OVERRIDE_I18N[lang]) || null;
  if (pair(4, 9)) avoidLine = RO?.pair49 || "Be extra careful with driving, machinery, and anything physical today — don't rush.";
  else if (pair(4, 8)) avoidLine = RO?.pair48 || "Avoid big money commitments today — the odds of a costly mistake are higher than usual.";

  return { do: doLine, avoid: avoidLine };
}
