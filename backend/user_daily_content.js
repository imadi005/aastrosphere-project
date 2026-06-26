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
  1: ["Take the lead", "Make the call", "Start it today", "Speak up"],
  2: ["Reach out", "Listen well", "Create something", "Be honest"],
  3: ["Plan ahead", "Decide calmly", "Give advice", "Write it down"],
  4: ["Verify everything", "Research first", "Ask questions", "Stay flexible"],
  5: ["Close the deal", "Negotiate", "Send the message", "Check the numbers"],
  6: ["Connect warmly", "Enjoy the moment", "Be generous", "Make it nice"],
  7: ["Trust your gut", "Take the meeting", "Stay calm", "Let it happen"],
  8: ["Keep working", "Stay consistent", "Finish tasks", "Be patient"],
  9: ["Take action", "Move fast", "Face it head-on", "Get moving"],
};

// ─── Short AVOID items (2–4 words each) ──────────────────────────────────────
const DAY_AVOID = {
  1: ["Ego trips", "Forcing others", "Overconfidence"],
  2: ["Money from emotion", "Taking things personally", "Overthinking feelings"],
  3: ["Cutting corners", "Rushing decisions", "Ignoring your gut"],
  4: ["Big purchases", "Quick commitments", "Trusting blindly"],
  5: ["Overthinking", "Greedy moves", "Skipping details"],
  6: ["Overspending", "Harsh words", "Overindulging"],
  7: ["Forcing outcomes", "Over-analyzing", "Chasing too hard"],
  8: ["Shortcuts", "Impatience", "Giving up early"],
  9: ["Picking fights", "Rash decisions", "Reckless speed"],
};

// ─── Main builder — returns everything the Today card needs, in plain English ─
export function buildUserDailyContent(daily, rating, dayOfYear = 0) {
  const tags = DAY_TAGS[daily] || DAY_TAGS[1];
  const tag = tags[(dayOfYear + (daily || 1)) % tags.length];

  return {
    tag,                                   // short, varies day to day
    summary: summaryFor(daily, rating),    // plain 1–2 line day summary
    priority: DAY_PRIORITY[daily] || DAY_PRIORITY[1], // one clear line
    do: DAY_DO[daily] || DAY_DO[1],        // 3–4 short items
    avoid: DAY_AVOID[daily] || DAY_AVOID[1], // 2–3 short items
  };
}
