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

    // ── 1. ACCIDENT & PHYSICAL RISK ─────────────────────────────────────────────
  // Book-accurate: ALL 6 layers checked simultaneously
  // 4(Rahu) and 9(Mars) must appear TOGETHER across the full chart
  // The more layers confirm the combination, the higher the risk

  const has4 = {
    natal:   natalNums.includes(4),
    basic:   basic === 4,
    destiny: destiny === 4,
    maha:    maha === 4,
    antar:   antar === 4,
    monthly: monthly === 4,
    daily:   daily === 4,
    hourly:  hourly !== null && hourly === 4,
  };
  const has9 = {
    natal:   natalNums.includes(9),
    basic:   basic === 9,
    destiny: destiny === 9,
    maha:    maha === 9,
    antar:   antar === 9,
    monthly: monthly === 9,
    daily:   daily === 9,
    hourly:  hourly !== null && hourly === 9,
  };

  // Count active layers for each
  const count4 = Object.values(has4).filter(Boolean).length;
  const count9 = Object.values(has9).filter(Boolean).length;

  // Condition 1: Rahu(4) + Mars(9) in maha + daily (period-day cross)
  if (has4.maha && has9.daily) {
    findings.push({ type: 'accident', level: 'high', label: 'High Accident Risk', detail: 'High accident risk today. Stay alert, drive carefully, avoid risky physical activities.' });
  }
  // Condition 2: Mars(9) + Rahu(4) in maha + daily
  else if (has9.maha && has4.daily) {
    findings.push({ type: 'accident', level: 'high', label: 'High Accident Risk', detail: 'High accident risk today. Slow down — impulsive moves lead to physical damage.' });
  }
  // Condition 3: Rahu(4) in antar + Mars(9) in daily
  else if (has4.antar && has9.daily) {
    findings.push({ type: 'accident', level: 'high', label: 'Accident Risk', detail: 'High accident risk today. Physical caution essential — avoid rushing.' });
  }
  // Condition 4: Mars(9) in antar + Rahu(4) in daily
  else if (has9.antar && has4.daily) {
    findings.push({ type: 'accident', level: 'high', label: 'Accident Risk', detail: 'High accident risk today. Sudden situations can cause physical harm — stay alert.' });
  }
  // Condition 5: Rahu(4) monthly + Mars(9) daily + must be confirmed by BOTH maha AND natal
  else if (has4.monthly && has9.daily && has4.maha && has9.natal) {
    findings.push({ type: 'accident', level: 'medium', label: 'Physical Caution', detail: 'Accident risk today. Extra care with driving, physical tasks, and machinery.' });
  }
  // Condition 6: Mars(9) monthly + Rahu(4) daily + must be confirmed by BOTH maha AND natal
  else if (has9.monthly && has4.daily && has9.maha && has4.natal) {
    findings.push({ type: 'accident', level: 'medium', label: 'Physical Caution', detail: 'Accident risk today. Verify before acting — impulsive decisions cause physical damage.' });
  }
  // Condition 7: Rahu(4) hour + Mars(9) day + confirmed by maha OR antar (not just natal)
  else if (has4.hourly && has9.daily && (has4.maha || has4.antar || has9.maha || has9.antar)) {
    findings.push({ type: 'accident', level: 'high', label: 'Accident Risk This Hour', detail: 'High accident risk this hour. Avoid speeding, sharp tools, and anything requiring precision right now.' });
  }
  // Condition 8: Mars(9) hour + Rahu(4) day + confirmed by maha OR antar
  else if (has9.hourly && has4.daily && (has4.maha || has4.antar || has9.maha || has9.antar)) {
    findings.push({ type: 'accident', level: 'high', label: 'Accident Risk This Hour', detail: 'High accident risk this hour. Slow down — impulsive moves cause physical damage right now.' });
  }
  // Condition 9: Double Rahu hour+day + Mars confirmed in maha AND natal
  else if (has4.hourly && has4.daily && has9.maha && has9.natal) {
    findings.push({ type: 'accident', level: 'high', label: 'Double Rahu — High Risk', detail: 'Very high accident risk this hour. Do not rush. Double-check everything before you act.' });
  }

  // ── Additional Mars-dominant combinations (from real accident data) ────────
  // Triple Mars: monthly=9 + daily=9 + hourly=9 + Rahu in natal/destiny
  if (!findings.some(f => f.type==='accident')) {
    if (has9.monthly && has9.daily && hourly !== null && has9.hourly && (has4.natal || has4.destiny)) {
      findings.push({ type: 'accident', level: 'high', label: 'Triple Mars Active', detail: 'High accident risk. Mars energy is running across three layers simultaneously — physical recklessness is at its peak. Slow down.' });
    }
    // Double Mars (daily+hourly) + Rahu in destiny or natal
    else if (has9.daily && hourly !== null && has9.hourly && (has4.destiny || has4.maha || has4.antar)) {
      findings.push({ type: 'accident', level: 'high', label: 'Mars Hour + Mars Day', detail: 'High accident risk this hour. Aggressive energy meets instability — avoid speeding, sharp tools, and impulsive physical action.' });
    }
    // Double Mars (monthly+daily) + Rahu natal + no hourly data
    else if (has9.monthly && has9.daily && has4.natal && hourly === null) {
      findings.push({ type: 'accident', level: 'medium', label: 'Double Mars Day', detail: 'Elevated accident risk today. Physical energy is running very high across multiple layers — take extra care.' });
    }
    // Rahu destiny + double Mars (any 2 of monthly/daily/hourly)
    else if (has4.destiny && has4.natal && [has9.monthly, has9.daily, has9.hourly].filter(Boolean).length >= 2) {
      findings.push({ type: 'accident', level: 'medium', label: 'Rahu + Double Mars', detail: 'Accident-prone combination today. Your Rahu destiny amplifies the Mars energy — physical caution strongly recommended.' });
    }
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
