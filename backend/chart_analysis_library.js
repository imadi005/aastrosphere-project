// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — CHART DAY ANALYSIS LIBRARY
// Analyzes a specific date's full combination for warnings, risks, opportunities
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Planetary relationship map ───────────────────────────────────────────────
const PLANET_RELS = {
  1:{f:[3,9,5],e:[2,7],n:[4,6,8]},
  2:{f:[1,3],e:[4,5,8],n:[6,7,9]},
  3:{f:[1,2,9],e:[5,6],n:[4,7,8]},
  4:{f:[4,6,7],e:[1,2,8],n:[3,5,9]},
  5:{f:[1,4],e:[2,3,9],n:[6,7,8]},
  6:{f:[4,5],e:[1,2,3],n:[7,8,9]},
  7:{f:[4,6],e:[1,2],n:[3,5,8,9]},
  8:{f:[4,5,6],e:[1,2,3],n:[7,9]},
  9:{f:[1,2,3],e:[5,6],n:[4,7,8]},
};
function rel(a,b){const r=PLANET_RELS[a];if(!r)return'n';if(r.f.includes(b))return'f';if(r.e.includes(b))return'e';return'n';}

// ─── Planet names ─────────────────────────────────────────────────────────────
const PNAMES = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};

// ─── COMPREHENSIVE combination analysis ───────────────────────────────────────
export function analyzeDayChart({ basic, destiny, maha, antar, monthly, daily, hourly, natalNums }) {
  const findings = [];

  // ── 1. ACCIDENT & PHYSICAL RISK ───────────────────────────────────────────
  // High risk: 4+9 in any critical layer
  if (daily === 4 && maha === 9) findings.push({ type: 'accident', level: 'high', label: 'High Physical Risk', detail: 'Rahu day in Mars period. Highest accident window — avoid reckless physical action, speeding, sharp tools.' });
  if (daily === 9 && maha === 4) findings.push({ type: 'accident', level: 'high', label: 'High Physical Risk', detail: 'Mars day in Rahu period. Impulsive moves cause accidents — slow down before acting.' });
  if (daily === 4 && antar === 9) findings.push({ type: 'accident', level: 'high', label: 'Physical Caution', detail: 'Rahu day in Mars chapter. Physical risk elevated this day.' });
  if (daily === 9 && antar === 4) findings.push({ type: 'accident', level: 'high', label: 'Physical Caution', detail: 'Mars day in Rahu chapter. Sudden situations risk physical harm.' });
  if (daily === 4 && monthly === 9) findings.push({ type: 'accident', level: 'medium', label: 'Physical Caution', detail: 'Rahu day in Mars month. Extra care with physical activities, driving, machinery.' });
  if (daily === 9 && monthly === 4) findings.push({ type: 'accident', level: 'medium', label: 'Physical Caution', detail: 'Mars day in Rahu month. Impulsive decisions risk physical damage.' });
  if (daily === 4 && daily === basic) findings.push({ type: 'accident', level: 'medium', label: 'Physical Caution', detail: 'Rahu day amplified by Rahu natal. Instability doubled today.' });
  if (daily === 9 && basic === 9) findings.push({ type: 'accident', level: 'medium', label: 'Energy Overflow Risk', detail: 'Double Mars — energy is at maximum. Physical recklessness risk is elevated.' });
  if (daily === 4 && basic === 4) findings.push({ type: 'accident', level: 'high', label: 'Double Rahu Day', detail: 'Rahu in both natal and day. Maximum instability. Do not commit to anything financial or physical without verification.' });
  if (maha === 9 && antar === 4) findings.push({ type: 'accident', level: 'medium', label: 'Ongoing Physical Caution', detail: 'Mars period + Rahu chapter running simultaneously. This is a generally accident-prone phase.' });
  if (maha === 4 && antar === 9) findings.push({ type: 'accident', level: 'medium', label: 'Ongoing Physical Caution', detail: 'Rahu period + Mars chapter. Unexpected situations and impulsive energy are both elevated.' });
  // Hourly accidents
  if (hourly !== null) {
    if (hourly === 4 && daily === 9) findings.push({ type: 'accident', level: 'high', label: 'Accident Hour', detail: `Rahu hour (${PNAMES[4]}) meets Mars day. This specific hour carries the highest accident risk.` });
    if (hourly === 9 && daily === 4) findings.push({ type: 'accident', level: 'high', label: 'Accident Hour', detail: `Mars hour meets Rahu day. Impulsive moves this hour can cause physical damage.` });
    if (hourly === 4 && hourly === daily) findings.push({ type: 'accident', level: 'high', label: 'Double Rahu Hour', detail: 'The hour and day both carry Rahu energy. Maximum instability window.' });
    if (hourly === 4 && maha === 8) findings.push({ type: 'accident', level: 'medium', label: 'Caution Hour', detail: 'Rahu hour in Saturn period. Move slowly, verify before acting.' });
  }

  // ── 2. FINANCIAL RISK ─────────────────────────────────────────────────────
  if (daily === 4 || monthly === 4) {
    const layer = daily === 4 ? 'today' : 'this month';
    findings.push({ type: 'financial', level: daily === 4 ? 'high' : 'medium', label: 'Financial Caution', detail: `Rahu energy active ${layer}. Avoid financial commitments — verify every opportunity twice. What looks like a sure thing may not be.` });
  }
  if (natalNums.includes(4) && daily === 5) findings.push({ type: 'financial', level: 'medium', label: 'Spending Impulse', detail: 'Rahu in your natal chart on a Mercury day. Financial Bandhan tendency peaks — the urge to spend is strong and potentially impulsive.' });
  if (basic === 4 && maha === 5) findings.push({ type: 'financial', level: 'medium', label: 'Financial Period Caution', detail: 'Rahu natal in Mercury period. Business opportunities may look more certain than they are.' });
  if (daily === 4 && antar === 5) findings.push({ type: 'financial', level: 'medium', label: 'Financial Caution', detail: 'Rahu day in Mercury chapter. Sharp financial instinct today but verification is essential.' });

  // ── 3. HEALTH RISKS ───────────────────────────────────────────────────────
  if (daily === 9 && basic === 6) findings.push({ type: 'health', level: 'medium', label: 'Blood Pressure Watch', detail: 'Mars day for a Venus natal. Energy is running high — blood pressure and hormonal balance need monitoring.' });
  if (daily === 8 && basic === 2) findings.push({ type: 'health', level: 'medium', label: 'Mental Load Watch', detail: 'Saturn day for a Moon natal. Emotional heaviness can peak — prioritize sleep and avoid over-committing.' });
  if (maha === 9 && basic === 2) findings.push({ type: 'health', level: 'medium', label: 'Ongoing Health Watch', detail: 'Mars period for a Moon natal. Physical energy is elevated but emotional regulation needs attention throughout this period.' });
  if (daily === 8 && maha === 8) findings.push({ type: 'health', level: 'medium', label: 'Physical Fatigue Risk', detail: 'Double Saturn. The body is under maximum karmic pressure today. Rest is as important as effort.' });
  if (natalNums.includes(9) && natalNums.includes(4)) findings.push({ type: 'health', level: 'medium', label: 'Ongoing Stress Pattern', detail: 'Mars and Rahu both in your natal chart. Anxiety, blood pressure, and accident risk are lifelong areas to monitor.' });

  // ── 4. LEGAL & ANGER RISKS ────────────────────────────────────────────────
  if (daily === 9 && daily === maha) findings.push({ type: 'legal', level: 'high', label: 'Anger Risk', detail: 'Double Mars energy — explosive reactions possible. Legal risks from anger-driven decisions. Pause before reacting.' });
  if (daily === 4 && basic === 9) findings.push({ type: 'legal', level: 'high', label: 'Legal Caution', detail: 'Rahu day for a Mars natal. This is the combination associated with legal risks from impulsive confrontational action.' });
  if (daily === 9 && basic === 4) findings.push({ type: 'legal', level: 'high', label: 'Legal Caution', detail: 'Mars day for a Rahu natal. Explosive energy meets an unstable foundation. Legal and physical risks both elevated.' });
  if (maha === 4 && daily === 9) findings.push({ type: 'legal', level: 'high', label: 'Legal Caution', detail: 'Mars day in Rahu period. This specific combination is linked to legal risks from aggressive impulsive action.' });
  if (daily === 9 && antar === 4) findings.push({ type: 'legal', level: 'medium', label: 'Anger Caution', detail: 'Mars day in Rahu chapter. Frustration levels are elevated — confrontations can escalate beyond intention.' });

  // ── 5. RELATIONSHIP TENSIONS ──────────────────────────────────────────────
  if (daily === 9 && basic === 2) findings.push({ type: 'relationship', level: 'high', label: 'Relationship Volatility', detail: 'Mars day for a Moon natal. The combination that produces the most emotionally intense and potentially explosive relationship moments.' });
  if (daily === 6 && maha === 9) findings.push({ type: 'relationship', level: 'medium', label: 'Sharp Tongue Risk', detail: 'Venus day in Mars period. Words said in frustration today carry unusual weight and last longer than usual.' });
  if (rel(basic, daily) === 'e') findings.push({ type: 'relationship', level: 'medium', label: 'Friction Day', detail: `Your natal planet (${PNAMES[basic]}) and today's energy (${PNAMES[daily]}) are in natural opposition. Navigate interpersonal situations with extra care.` });

  // ── 6. POSITIVE COMBINATIONS ──────────────────────────────────────────────
  if (rel(basic, daily) === 'f' && rel(daily, basic) === 'f') findings.push({ type: 'opportunity', level: 'high', label: 'Peak Day', detail: `${PNAMES[basic]} (your natal) and ${PNAMES[daily]} (today) are mutual friends. This is one of your naturally strongest days.` });
  if (daily === 5 && natalNums.includes(7)) findings.push({ type: 'opportunity', level: 'high', label: 'Easy Money Active', detail: 'Mercury day with Ketu in your chart. Financial luck is structurally active today. Act on what presents itself.' });
  if (daily === 7 && natalNums.includes(5)) findings.push({ type: 'opportunity', level: 'high', label: 'Financial Fortune', detail: 'Ketu day with Mercury in your chart. The Easy Money combination — unexpected financial opportunities are available.' });
  if (daily === 1 && maha === 7) findings.push({ type: 'opportunity', level: 'high', label: 'Lucky Authority', detail: 'Sun day in Ketu period. Bold moves are backed by quiet fortune today. Make the ask.' });
  if (daily === 7 && maha === 1) findings.push({ type: 'opportunity', level: 'high', label: 'Fortune Backs Initiative', detail: 'Ketu day in Sun period. What you initiate today has unusual fortune behind it.' });
  if (rel(maha, daily) === 'f' && rel(antar, daily) === 'f') findings.push({ type: 'opportunity', level: 'high', label: 'Triple Alignment', detail: `${PNAMES[maha]} period + ${PNAMES[antar]} chapter + ${PNAMES[daily]} day all in friendly alignment. Rare triple-layer support today.` });
  if (basic === daily) findings.push({ type: 'opportunity', level: 'high', label: 'Your Day', detail: `Today's energy (${PNAMES[daily]}) matches your natal number. This is one of your naturally powerful days.` });
  if (destiny === daily) findings.push({ type: 'opportunity', level: 'high', label: 'Destiny Day', detail: `Today's energy aligns with your destiny number (${PNAMES[destiny]}). The life path is supported today.` });

  // ── 7. SPIRITUAL / INTUITION ──────────────────────────────────────────────
  if (daily === 7 && natalNums.includes(7)) findings.push({ type: 'spiritual', level: 'high', label: 'Double Ketu', detail: 'Ketu in both natal and day. Maximum intuition and spiritual depth available. Trust instinct completely.' });
  if (daily === 3 && basic === 3) findings.push({ type: 'spiritual', level: 'high', label: 'Double Jupiter', detail: 'Jupiter in both natal and day. Clearest wisdom and sound judgment of the cycle available today.' });
  if (daily === 2 && maha === 2) findings.push({ type: 'spiritual', level: 'medium', label: 'Deep Emotional Day', detail: 'Double Moon energy. Creative and emotional depth at its peak. What is felt today is felt completely.' });

  // ── 8. KARMA DAYS ─────────────────────────────────────────────────────────
  if (daily === 8 && maha === 8) findings.push({ type: 'karma', level: 'high', label: 'Double Saturn', detail: 'Maximum karmic day. What is built with integrity today compounds. Shortcuts cost triple. The effort matters.' });
  if (daily === 8 && basic === 8) findings.push({ type: 'karma', level: 'high', label: 'Saturn Day for Saturn Natal', detail: 'Your most karmic day type. The work done today has the longest-lasting consequences — good or bad.' });
  if (natalNums.filter(n => n === 8).length >= 2 && daily === 8) findings.push({ type: 'karma', level: 'high', label: 'Extreme Saturn Day', detail: 'Multiple 8s in chart on Saturn day. This is a maximum karma day. Act with complete integrity.' });

  // Deduplicate by label
  const seen = new Set();
  const unique = findings.filter(f => {
    const key = f.label + f.type;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  // Sort: accidents first, then legal, then financial, then opportunities
  const order = { accident: 0, legal: 1, financial: 2, health: 3, relationship: 4, karma: 5, spiritual: 6, opportunity: 7 };
  unique.sort((a, b) => (order[a.type] ?? 9) - (order[b.type] ?? 9));

  return unique;
}

// ─── Overall day score ────────────────────────────────────────────────────────
export function getDayScore({ basic, destiny, maha, antar, monthly, daily, natalNums }) {
  let score = 50;
  // Basic vs daily
  const r1 = rel(basic, daily); score += r1==='f'?15:r1==='e'?-15:0;
  const r2 = rel(daily, basic); score += r2==='f'?8:r2==='e'?-8:0;
  // Maha vs daily
  const r3 = rel(maha, daily); score += r3==='f'?10:r3==='e'?-10:0;
  // Antar vs daily
  const r4 = rel(antar, daily); score += r4==='f'?8:r4==='e'?-8:0;
  // Monthly vs daily
  const r5 = rel(monthly, daily); score += r5==='f'?5:r5==='e'?-5:0;
  // Same number bonuses
  if (basic === daily) score += 10;
  if (destiny === daily) score += 5;
  return Math.max(5, Math.min(95, score));
}
