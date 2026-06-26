// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — USER-FACING DAILY CONTENT (PLAIN ENGLISH)
// Purpose: everything shown on the Today card in simple language.
// NO planet names, NO "dasha", NO "Ketu chapter", NO "Saturn's weight".
// Keeps the SAME underlying logic (daily number + rating) — only the words change.
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Varied day tags (changes day to day, not fixed per number) ──────────────
// Picked by date so the same "daily number" doesn't always show the same tag.
const DAY_TAGS = {
  1: ["Take charge", "Lead today", "Bold moves", "Step up", "Your move", "Start it"],
  2: ["Connect today", "Heart-led day", "Reach out", "People day", "Feelings matter", "Soft focus"],
  3: ["Think clearly", "Smart choices", "Plan ahead", "Good judgment", "Decide well", "Steady mind"],
  4: ["Double-check", "Stay careful", "Verify first", "Slow down", "Question it", "Go steady"],
  5: ["Money day", "Make the deal", "Sharp thinking", "Business mode", "Talk it out", "Numbers day"],
  6: ["Warm day", "Connect & create", "Easy flow", "Social day", "Enjoy today", "Light & open"],
  7: ["Trust your gut", "Lucky day", "Quiet wins", "Follow instinct", "Let it flow", "Soft luck"],
  8: ["Put in work", "Stay patient", "Build slowly", "Effort pays", "Grind day", "Keep going"],
  9: ["High energy", "Take action", "Be bold", "Push forward", "Move fast", "Full power"],
};

// ─── Plain one/two-line summary of the day (base = good/favorable tone) ───────
const DAY_SUMMARY_BASE = {
  1: "A strong day to take the lead and act on what you've been putting off. Your confidence is backed today — make the move.",
  2: "Today leans emotional and creative. Good for honest talks, reaching out, and anything that needs a personal touch.",
  3: "Your judgment is clear today. A good day to plan, decide, advise, or handle anything important that needs a steady head.",
  4: "Today feels a little uncertain — things may not be what they seem. Slow down, check the details, and avoid big commitments.",
  5: "A sharp day for money and communication. Good for deals, negotiations, and decisions that need a clear, practical head.",
  6: "A warm, easy day. Good for relationships, creative work, and enjoying things without forcing them.",
  7: "Quiet luck is on your side today. Trust your gut over heavy analysis — the right things tend to fall into place.",
  8: "A slow, work-heavy day. Progress is real but won't show right away. Stay patient and keep at it — effort counts today.",
  9: "High energy today. Great for bold action and getting things done — just channel it so it doesn't turn into conflict.",
};

// ─── Rating-aware opener — shifts the tone for tougher days ───────────────────
function summaryFor(daily, rating) {
  const base = DAY_SUMMARY_BASE[daily] || "Take today as it comes and act with a little extra awareness.";
  if (rating === 'favorable') return base;
  if (rating === 'good') return base;
  if (rating === 'caution') return `Take it a bit easy today. ${base}`;
  if (rating === 'avoid') return `A tricky day — keep things low-key and hold off on big decisions. ${base}`;
  return base;
}

// ─── One clear priority line (plain) ─────────────────────────────────────────
const DAY_PRIORITY = {
  1: "Make the move you've been delaying.",
  2: "Have the conversation that matters.",
  3: "Make that important decision today.",
  4: "Check the details before you commit.",
  5: "Handle the money or work decision now.",
  6: "Spend time on a relationship that matters.",
  7: "Follow your instinct on the big call.",
  8: "Finish what you started — keep going.",
  9: "Tackle the thing you've been avoiding.",
};

// ─── Short DO items (2–4 words each) ─────────────────────────────────────────
const DAY_DO = {
  1: ["Take the lead", "Make the call", "Start it today", "Speak up", "Decide and act", "Go first"],
  2: ["Reach out", "Listen well", "Create something", "Be honest", "Call a friend", "Show you care"],
  3: ["Plan ahead", "Decide calmly", "Give advice", "Write it down", "Think it through", "Make the choice"],
  4: ["Verify everything", "Research first", "Ask questions", "Stay flexible", "Double-check", "Read the details"],
  5: ["Close the deal", "Negotiate", "Send the message", "Check the numbers", "Make the pitch", "Talk it out"],
  6: ["Connect warmly", "Enjoy the moment", "Be generous", "Make it nice", "Spend time together", "Create something"],
  7: ["Trust your gut", "Take the meeting", "Stay calm", "Let it happen", "Follow instinct", "Keep it quiet"],
  8: ["Keep working", "Stay consistent", "Finish tasks", "Be patient", "Stick to routine", "Push through"],
  9: ["Take action", "Move fast", "Face it head-on", "Get moving", "Exercise", "Tackle it now"],
};

// ─── Short AVOID items (2–4 words each) ──────────────────────────────────────
const DAY_AVOID = {
  1: ["Ego trips", "Forcing others", "Overconfidence", "Going it alone", "Ignoring advice"],
  2: ["Money from emotion", "Taking it personally", "Overthinking feelings", "Isolating yourself", "Mood swings"],
  3: ["Cutting corners", "Rushing decisions", "Ignoring your gut", "Lecturing others", "Over-promising"],
  4: ["Big purchases", "Quick commitments", "Trusting blindly", "Signing anything", "Easy-looking deals"],
  5: ["Overthinking", "Greedy moves", "Skipping details", "Rushing money", "Risky bets"],
  6: ["Overspending", "Harsh words", "Overindulging", "Forcing closeness", "Emotional buys"],
  7: ["Forcing outcomes", "Over-analyzing", "Chasing too hard", "Ignoring instinct", "Sudden flips"],
  8: ["Shortcuts", "Impatience", "Giving up early", "Overloading", "Breaking routine"],
  9: ["Picking fights", "Rash decisions", "Reckless speed", "Acting on anger", "Rushing physically"],
};

// Rotate a subset so the same number doesn't always show identical chips.
function rotate(arr, n, start) {
  const out = [];
  for (let i = 0; i < n && i < arr.length; i++) out.push(arr[(start + i) % arr.length]);
  return out;
}

// ─── Plain full insight (for the "Full insight" detail — simple, no jargon) ───
const DAY_INSIGHT = {
  1: "Today your confidence is strong, so it's a good day to take charge and start things you've been putting off. People are more likely to follow your lead, so don't wait for someone else to make the first move. Just don't let it tip into ego or pushing people around. Make your decisions, speak up, and act — today rewards those who step forward.",
  2: "Today is more about people and feelings than ticking off tasks. It's a good day for honest conversations, sorting out a relationship, or anything that needs a gentle, personal touch. Trust your feelings, but don't let them push you into money or work decisions you'd normally think twice about. Spend time with the people who matter — that's where today's value is.",
  3: "Your mind is clear today, so it's a great day to plan, decide, or sort out anything important. If you've been stuck on a choice, this is the day to make it. You may also find yourself giving good advice to others. Don't rush or cut corners — your judgment is sharp, so use it properly.",
  4: "Today things may feel a little off or confusing, and not everything is as it seems. It's not a great day for big decisions, signing anything, or making major purchases. Slow down, double-check the details, and ask questions before you commit. If something feels unclear, it's okay to wait — a clearer day is coming.",
  5: "Today your thinking is sharp and practical, which makes it a strong day for money, deals, and communication. If you have a negotiation, an important message, or a financial decision, handle it now. You'll be good at spotting what makes sense and what doesn't. Just don't overthink it or get greedy — keep things simple and clear.",
  6: "Today has an easy, pleasant feel to it. It's a good day for relationships, creative work, and enjoying things without forcing them. Spend time with people you care about, or put effort into something that makes life a bit nicer. Watch your spending and don't overdo it — enjoy today, but keep some balance.",
  7: "Today luck quietly works in your favour, and your gut feeling is more reliable than usual. Instead of overthinking, trust your instinct on the important calls — the right things tend to fall into place on their own. It's a calmer, more reflective day, so don't force outcomes or chase too hard. Let things happen and stay open.",
  8: "Today is a slow, work-heavy day where progress is real but won't show right away. Keep your head down and put in the effort — what you build today tends to last, even if you don't see results immediately. Avoid shortcuts and don't give up just because things feel heavy. Patience and steady work are what pay off today.",
  9: "Today your energy is high, which makes it a great day to take bold action and finish things you've been avoiding. Put that energy into work, exercise, or tackling a tough task head-on. Just be careful — the same energy can turn into anger or rushed decisions if you're not aware. Use the drive, but stay in control.",
};

export function buildPlainInsight(daily, rating) {
  const base = DAY_INSIGHT[daily] || "Take today as it comes and act with a little extra awareness.";
  if (rating === 'avoid') return `This is a quieter, trickier day, so keep things low-key and avoid big moves. ${base}`;
  if (rating === 'caution') return `Take today a bit easy. ${base}`;
  return base;
}

// ─── Varied phrasings for the rating badge (so "favorable" isn't the only word) ─
// Underlying rating stays the same (drives color); only the shown text rotates.
const RATING_LABELS = {
  favorable: ["Great day", "Strong day", "Day's with you", "Go for it", "Good energy", "On your side", "Bright day", "Smooth day"],
  good:      ["Good day", "Solid day", "Decent day", "Mostly good", "Steady & up", "Fair day"],
  caution:   ["Mixed day", "Go steady", "Take it slow", "Be mindful", "Stay careful", "Handle with care"],
  avoid:     ["Slow day", "Take it easy", "Low-key day", "Quiet day", "Keep it light", "Rest & recharge"],
};

function ratingLabelFor(rating, dayOfYear) {
  const pool = RATING_LABELS[rating] || RATING_LABELS.caution;
  return pool[dayOfYear % pool.length];
}

// ─── Main builder — returns everything the Today card needs, in plain English ─
export function buildUserDailyContent(daily, rating, dayOfYear = 0) {
  const tags = DAY_TAGS[daily] || DAY_TAGS[1];
  const tag = tags[(dayOfYear + (daily || 1)) % tags.length];

  return {
    tag,                                   // short, varies day to day
    rating_label: ratingLabelFor(rating, dayOfYear), // varied badge text (e.g. "Strong day")
    summary: summaryFor(daily, rating),    // plain 1–2 line day summary
    insight: buildPlainInsight(daily, rating), // plain full insight (no jargon)
    priority: DAY_PRIORITY[daily] || DAY_PRIORITY[1], // one clear line
    do: rotate(DAY_DO[daily] || DAY_DO[1], 4, dayOfYear),     // 4 short items, rotate by date
    avoid: rotate(DAY_AVOID[daily] || DAY_AVOID[1], 3, dayOfYear), // 3 short items, rotate by date
  };
}
