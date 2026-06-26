// ═══════════════════════════════════════════════════════════════════════════════
// DAY SCORE + GOOD FOR / BAD FOR LIBRARY
// Score: 0-100, tilted toward positive (never below 25 unless avoid combination)
// Good For / Bad For: 3-4 word tags, not do's/don'ts — activity categories
// ═══════════════════════════════════════════════════════════════════════════════

const PNAME = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};

// ── Score base by rating ───────────────────────────────────────────────────────
const RATING_BASE = {
  favorable: 82,
  good:      68,
  caution:   48,
  avoid:     30,
};

// ── Score modifiers ────────────────────────────────────────────────────────────
// Positive yogas boost, negative bring down
const YOGA_MODIFIERS = {
  easy_money:       +10,
  raj_yoga:         +10,
  sun_ketu_raj:     +8,
  uplifting_319:    +9,
  high_intuition:   +6,
  spiritual:        +4,
  vipreet_raj:      +5,
  financial_bandhan: -6,
  bandhan:          -8,
  maha_antar_combo: +3,
};

// ── Good For tags: maha x daily (key activities this combination supports) ────
const GOOD_FOR_TAGS = {
  // Maha 8 (Saturn) combos
  '8_1': ['career moves', 'public visibility', 'leadership decisions', 'long-term planning'],
  '8_2': ['deep creative work', 'journaling', 'emotional processing', 'quiet reflection'],
  '8_3': ['strategic planning', 'mentorship', 'family discussions', 'ethical decisions'],
  '8_4': ['research', 'reading', 'background work', 'analysis'],
  '8_5': ['financial planning', 'business strategy', 'negotiations', 'data review'],
  '8_6': ['relationship work', 'creative projects', 'meaningful conversations', 'rest'],
  '8_7': ['meditation', 'spiritual practice', 'intuitive work', 'investments'],
  '8_8': ['deep focused work', 'building systems', 'paying debts', 'repairs'],
  '8_9': ['physical training', 'high-output work', 'competitive moves', 'execution'],
  // Maha 9 (Mars) combos
  '9_1': ['bold career moves', 'public leadership', 'competitive wins', 'starting projects'],
  '9_2': ['creative expression', 'emotional honesty', 'relationship depth', 'writing'],
  '9_3': ['ethical leadership', 'teaching', 'principled action', 'family bonding'],
  '9_4': ['research only', 'planning', 'background tasks', 'careful movement'],
  '9_5': ['business execution', 'fast negotiations', 'closing deals', 'commercial moves'],
  '9_6': ['passion projects', 'romantic gestures', 'creative output', 'artistic work'],
  '9_7': ['bold spiritual action', 'intuitive moves', 'taking chances', 'travel'],
  '9_8': ['maximum output', 'physical endurance', 'building foundations', 'sustained work'],
  '9_9': ['competitive challenges', 'physical training', 'ambitious projects', 'sports'],
  // Maha 7 (Ketu) combos
  '7_1': ['quiet leadership', 'spiritual authority', 'recognition without seeking', 'teaching'],
  '7_2': ['meditation', 'creative flow', 'intuitive work', 'deep rest'],
  '7_3': ['study', 'philosophical inquiry', 'wisdom seeking', 'spiritual reading'],
  '7_4': ['stillness', 'observation', 'background research', 'patience'],
  '7_5': ['effortless financial moves', 'investments', 'business insights', 'opportunities'],
  '7_6': ['effortless connections', 'romance', 'beauty appreciation', 'receiving'],
  '7_7': ['deep meditation', 'retreats', 'inner work', 'spiritual practice'],
  '7_8': ['methodical work', 'careful progress', 'patient building', 'discipline'],
  '7_9': ['principled bold moves', 'aligned action', 'courage with conviction', 'initiation'],
  // Maha 1 (Sun) combos
  '1_1': ['career visibility', 'public moves', 'leadership', 'authority decisions'],
  '1_2': ['honest conversations', 'emotional leadership', 'creative work', 'connecting'],
  '1_3': ['teaching', 'mentoring', 'ethical decisions', 'family leadership'],
  '1_4': ['questioning assumptions', 'due diligence', 'verification', 'independent thinking'],
  '1_5': ['business meetings', 'negotiations', 'pitching', 'financial decisions'],
  '1_6': ['public charm', 'relationship leadership', 'appreciation', 'graceful authority'],
  '1_7': ['intuitive authority', 'unexpected recognition', 'spiritual leadership', 'wisdom'],
  '1_8': ['disciplined work', 'earned recognition', 'sustained effort', 'follow-through'],
  '1_9': ['bold leadership', 'competitive decisions', 'taking charge', 'courageous action'],
  // Maha 2 (Moon) combos
  '2_1': ['public visibility', 'emotional leadership', 'creative authority', 'connection'],
  '2_2': ['deep creative work', 'emotional honesty', 'artistic expression', 'intimacy'],
  '2_3': ['family time', 'meaningful gatherings', 'emotional wisdom', 'nurturing'],
  '2_4': ['writing feelings', 'private reflection', 'holding back decisions', 'observation'],
  '2_5': ['intuitive business', 'emotional intelligence', 'creative commerce', 'empathetic communication'],
  '2_6': ['romance', 'creative collaboration', 'emotional art', 'deep connection'],
  '2_7': ['meditation', 'intuitive practice', 'spiritual sensitivity', 'receiving guidance'],
  '2_8': ['emotional discipline', 'consistent routine', 'quiet sustained work', 'grounding'],
  '2_9': ['channeling intensity', 'physical creative work', 'emotional output', 'bold expression'],
  // Maha 3 (Jupiter) combos
  '3_1': ['teaching with authority', 'principled leadership', 'ethical decisions', 'wisdom-led action'],
  '3_2': ['family healing', 'emotional wisdom', 'creative mentoring', 'nurturing guidance'],
  '3_3': ['learning', 'deep study', 'philosophical work', 'wisdom traditions'],
  '3_4': ['questioning beliefs', 'research', 'verifying advice', 'careful inquiry'],
  '3_5': ['strategic learning', 'smart investments', 'educational purchases', 'wise business'],
  '3_6': ['generous giving', 'cultural experiences', 'inspired creativity', 'spiritual beauty'],
  '3_7': ['meditation', 'sacred study', 'deep spiritual practice', 'receiving wisdom'],
  '3_8': ['patient building', 'long-term vision', 'ethical foundations', 'disciplined growth'],
  '3_9': ['principled action', 'courageous ethics', 'inspired leadership', 'purposeful moves'],
  // Maha 4 (Rahu) combos
  '4_1': ['careful questioning', 'verification', 'independent thinking', 'due diligence'],
  '4_2': ['private reflection', 'writing confusions', 'observation', 'emotional rest'],
  '4_3': ['seeking wise counsel', 'external perspective', 'questioning assumptions', 'learning from elders'],
  '4_4': ['creative brainstorming', 'generating options', 'idea capture', 'imaginative work'],
  '4_5': ['deep research', 'information gathering', 'background verification', 'fact-checking'],
  '4_6': ['honest relationship reflection', 'questioning attractions', 'private creative work', 'beauty without commitment'],
  '4_7': ['grounding practices', 'intuitive caution', 'stillness', 'observation'],
  '4_8': ['maintaining status quo', 'clearing backlogs', 'debt repayment', 'existing commitments'],
  '4_9': ['ultra-careful movement', 'controlled physical work', 'deliberate action only', 'structured tasks'],
  // Maha 5 (Mercury) combos
  '5_1': ['bold business moves', 'confident negotiations', 'leadership communication', 'closing deals'],
  '5_2': ['intuitive business', 'emotional intelligence in commerce', 'following financial gut', 'empathetic pitching'],
  '5_3': ['strategic investments', 'educational purchases', 'wise business planning', 'learning for profit'],
  '5_4': ['deep research', 'information verification', 'due diligence', 'background checks'],
  '5_5': ['major financial decisions', 'peak negotiation', 'business pitches', 'deal closing'],
  '5_6': ['partnership deals', 'business relationships', 'creative commerce', 'joint ventures'],
  '5_7': ['effortless financial moves', 'lucky investments', 'intuitive business', 'receiving opportunities'],
  '5_8': ['financial planning', 'systematic analysis', 'long-term investment', 'methodical research'],
  '5_9': ['competitive business', 'fast execution', 'bold commercial moves', 'aggressive negotiation'],
  // Maha 6 (Venus) combos
  '6_1': ['public charm', 'visible beauty', 'graceful leadership', 'professional elegance'],
  '6_2': ['romance', 'deep emotional art', 'intimate connection', 'creative expression'],
  '6_3': ['generous giving', 'artistic education', 'cultural experiences', 'inspired creativity'],
  '6_4': ['private beauty work', 'honest relationship reflection', 'quiet creative projects', 'avoiding commitments'],
  '6_5': ['business partnerships', 'joint ventures', 'commercial creativity', 'charming negotiations'],
  '6_6': ['rest and restoration', 'beauty rituals', 'indulging meaningfully', 'deep self-care'],
  '6_7': ['effortless romance', 'graceful receiving', 'beauty without effort', 'easy connections'],
  '6_8': ['committed relationships', 'disciplined creativity', 'sustained artistic work', 'honoring commitments'],
  '6_9': ['passionate creation', 'romantic boldness', 'artistic intensity', 'energetic expression'],
};

// ── Bad For tags ───────────────────────────────────────────────────────────────
const BAD_FOR_TAGS = {
  '8_1': ['seeking quick wins', 'shortcuts', 'shortcuts in visibility', 'impulsive leadership'],
  '8_2': ['financial decisions', 'isolation', 'major commitments', 'high-pressure tasks'],
  '8_3': ['speculation', 'rushing expansion', 'overextending', 'quick fixes'],
  '8_4': ['major decisions', 'new launches', 'trusting new people', 'financial commitments'],
  '8_5': ['rushed analysis', 'shortcuts in planning', 'impatient moves', 'quick deals'],
  '8_6': ['overindulgence', 'luxury spending', 'superficial connection', 'avoiding hard talks'],
  '8_7': ['forcing outcomes', 'material focus', 'ignoring signals', 'rushing results'],
  '8_8': ['shortcuts of any kind', 'emotional avoidance', 'giving up early', 'distraction'],
  '8_9': ['spreading too thin', 'angry decisions', 'ignoring physical signals', 'overcommitting'],
  '9_1': ['ego-driven moves', 'unnecessary fights', 'recklessness', 'burning bridges'],
  '9_2': ['home arguments', 'reactive messages', 'emotional spending', 'pressure on others'],
  '9_3': ['righteous aggression', 'moving before clarity', 'moralizing loudly', 'forced action'],
  '9_4': ['rushing physically', 'impulsive moves', 'driving fast', 'angry decisions'],
  '9_5': ['cutting too sharp verbally', 'reckless boldness', 'starting fights', 'scattering focus'],
  '9_6': ['romantic conflict', 'pressure on partners', 'intense arguments', 'burning connections'],
  '9_7': ['hesitation past the moment', 'performing courage', 'wasting aligned energy', 'doubt'],
  '9_8': ['spreading across targets', 'ignoring the body', 'Mars impatience', 'shortcuts'],
  '9_9': ['internal conflict', 'picking fights', 'legal risks', 'reckless physical moves'],
  '7_1': ['chasing recognition', 'loud authority', 'performing confidence', 'ego moves'],
  '7_2': ['suppressing sensitivity', 'rationalizing gut feelings', 'forced logic', 'isolation'],
  '7_3': ['spiritual arrogance', 'withdrawing from life', 'overthinking wisdom', 'certainty'],
  '7_4': ['sudden major decisions', 'charismatic leaders blindly', 'acting on visions alone', 'rushing'],
  '7_5': ['overanalyzing opportunities', 'forcing easy gains', 'complexity over simplicity', 'hesitation'],
  '7_6': ['forcing outcomes', 'pushing flow', 'rejecting easy things', 'complacency confusion'],
  '7_7': ['material distractions', 'forced spiritual experiences', 'comparison', 'noise'],
  '7_8': ['abandoning slow progress', 'mistaking slow for stopped', 'urgency', 'shortcutting'],
  '7_9': ['action without conviction', 'courage as performance', 'wasted energy', 'forcing'],
  '1_1': ['arrogance', 'unilateral decisions', 'announcing before doing', 'ego battles'],
  '1_2': ['career decisions while emotional', 'projecting strength when vulnerable', 'dismissing feelings', 'overspending'],
  '1_3': ['unsolicited advice', 'moralizing', 'overextending', 'overconfidence'],
  '1_4': ['signing anything unread', 'trusting blindly', 'permanent decisions', 'rushing'],
  '1_5': ['overconfidence in reading others', 'missing important details', 'arrogance in negotiation', 'agreeing without costing'],
  '1_6': ['using charm to avoid substance', 'overcommitting', 'neglecting own needs', 'performance over presence'],
  '1_7': ['forcing recognition', 'performing authority', 'chasing visibility', 'overthinking signals'],
  '1_8': ['expecting recognition today', 'shortcuts with your name on them', 'announcing effort', 'impatience'],
  '1_9': ['starting unnecessary fights', 'recklessness as confidence', 'burning bridges', 'ego aggression'],
  '2_1': ['suppressing emotion publicly', 'over-explaining yourself', 'seeking approval', 'comparison'],
  '2_2': ['isolation', 'emotional decisions in private', 'ruminating', 'using sensitivity to avoid conflict'],
  '2_3': ['advice nobody asked for', 'overextending emotionally', 'financial decisions under family pressure', 'ignoring own needs'],
  '2_4': ['major decisions under confusion', 'trusting too fast', 'signing while uncertain', 'emotional purchases'],
  '2_5': ['emotional spending', 'mixing personal and financial', 'waiting for perfect clarity', 'letting urgency rush you'],
  '2_6': ['overcommitting to others', 'using affection to avoid truth', 'emotional overspending', 'confusing comfort with connection'],
  '2_7': ['rationalizing intuition away', 'numbing sensitivity', 'second-guessing clear signals', 'forcing logic onto feeling'],
  '2_8': ['complete isolation', 'self-criticism', 'screens for connection', 'canceling commitments'],
  '2_9': ['home arguments', 'reactive communication', 'physical recklessness', 'letting passion become aggression'],
  '3_1': ['moralizing without acting', 'leading through lecture', 'overconfidence in complex reads', 'overcommitting verbally'],
  '3_2': ['unsolicited advice', 'emotional decisions as wise choices', 'neglecting own spiritual needs', 'over-extending for others'],
  '3_3': ['spiritual arrogance', 'overconfidence in learning areas', 'expanding beyond what can be honored', 'shortcuts in learning'],
  '3_4': ['following guidance without verifying', 'overcommitting on optimism', 'spiritual bypassing', 'decisions under social pressure'],
  '3_5': ['speculation as vision', 'optimistic projections without data', 'impossible timelines', 'expanding prematurely'],
  '3_6': ['overindulgence', 'giving to avoid conversations', 'aesthetic perfectionism', 'spreading too thin'],
  '3_7': ['intellectual arrogance', 'overthinking what practice quiets', 'withdrawing from life', 'wisdom as shield'],
  '3_8': ['expanding before foundation is ready', 'ignoring what Saturn is teaching', 'impatience with growth', 'treating wisdom as substitute for work'],
  '3_9': ['righteous anger without wisdom', 'acting before full picture', 'aggression in defense of principle', 'moving too fast'],
  '4_1': ['signing anything', 'trusting authority blindly', 'ego moves needing false confidence', 'rushing'],
  '4_2': ['major relationship decisions', 'new people trusted quickly', 'confusing feeling with fact', 'emotional purchases'],
  '4_3': ['shortcuts and speculation', 'following without discernment', 'large plans on unverified beliefs', 'optimism without numbers'],
  '4_4': ['any financial commitment', 'impulsive changes', 'trusting exciting new things', 'irreversible decisions'],
  '4_5': ['deals requiring instant decisions', 'unusually high return investments', 'mixing money with relationships', 'acting without second opinion'],
  '4_6': ['romantic commitments now', 'financial decisions under relationship pressure', 'confusing intensity with compatibility', 'ignoring warning signs'],
  '4_7': ['acting on visions into irreversible action', 'following revelations blindly', 'psychic claims by strangers', 'decisions justified by signs'],
  '4_8': ['new ventures or launches', 'forcing progress', 'reacting to delays with anger', 'adding new obligations'],
  '4_9': ['rushing physically', 'aggressive driving', 'sharp tools carelessly', 'angry decisions'],
  '5_1': ['overconfidence in others', 'skipping important details', 'letting win become lecture', 'ego-led terms'],
  '5_2': ['emotional spending', 'mixing personal into financial', 'waiting for certainty', 'letting urgency rush'],
  '5_3': ['speculation dressed as strategy', 'optimistic timelines', 'confusing knowledge with wisdom', 'endless research as avoidance'],
  '5_4': ['fast deals needing instant decision', 'trusting exciting pitch', 'acting without verification', 'FOMO-driven decisions'],
  '5_5': ['capturing every opportunity', 'anxiety as due diligence', 'overanalyzing clear decisions', 'over-thinking when analysis is done'],
  '5_6': ['personal finances without explicit agreement', 'spending on appearance for insecurity', 'commercial coldness in relational context', 'confusing romantic with financial decision'],
  '5_7': ['overanalyzing good opportunities', 'forcing easy gains', 'dismissing what came without struggle', 'adding complexity where clarity exists'],
  '5_8': ['Mercury speed on Saturn day', 'shortcuts in financial planning', 'expecting quick returns from long-term action', 'abandoning sound plans for faster ones'],
  '5_9': ['cutting too sharp verbally', 'competitive instinct over commercial judgment', 'reckless boldness as street smarts', 'burning bridges in deals'],
  '6_1': ['vanity reading as insecurity', 'charm to avoid professional decisions', 'appearance spending for confidence', 'social grace as substitute for competence'],
  '6_2': ['emotional decisions in romantic flush', 'affection to avoid difficult conversation', 'overspending on experiences', 'confusing chemistry with compatibility'],
  '6_3': ['overindulgence', 'generosity past genuine capacity', 'aesthetic perfectionism preventing finishing', 'spreading across too many relationships'],
  '6_4': ['romantic commitments', 'financial decisions wanting to impress', 'ignoring clear warning signs', 'confusing attraction with trustworthiness'],
  '6_5': ['personal and financial mixed without clarity', 'commercial coldness in relational context', 'spending to manage relationship anxiety', 'agreeing to terms to preserve feeling'],
  '6_6': ['overconsumption', 'pleasure over genuine rest', 'relationships that take not give', 'indulgence regretted tomorrow'],
  '6_7': ['forcing outcomes already arriving', 'thinking flow means complacency', 'rejecting what came without struggle', 'mistaking ease for laziness'],
  '6_8': ['comfort-seeking avoiding hard conversation', 'spending on luxury to postpone honesty', 'confusing pleasant with right', 'maintaining by avoidance not choice'],
  '6_9': ['romantic conflict', 'passion as pressure on others', 'aggression in creative contexts', 'burning bridges in relationships'],
};

// ── Friendly number pairs ─────────────────────────────────────────────────────
const FRIENDLY = {
  1: [1,2,3,9], 2: [1,2,3,6], 3: [1,2,3,5,9], 4: [4,5,7],
  5: [3,4,5,6], 6: [2,5,6,7], 7: [4,6,7], 8: [8], 9: [1,3,9]
};
const ENEMY = {
  1: [4,6,8], 2: [4,5,8,9], 3: [4,6,8], 4: [1,2,3,9],
  5: [1,2,8,9], 6: [1,3,4,9], 7: [1,2,3,8,9], 8: [1,2,3,4,5,6,9], 9: [2,4,5,6,8]
};

// ── Main export ────────────────────────────────────────────────────────────────
// Score band each rating must stay inside — guarantees score and rating never contradict.
const RATING_BANDS = {
  favorable: [72, 95],
  good:      [60, 80],
  caution:   [40, 58],
  avoid:     [22, 40],
};

export function getDayScore(ctx) {
  const { maha, antar, monthly, daily, basic, destiny, yogas = [], freqMap = {}, rating } = ctx;
  const natalNums = Object.keys(freqMap).map(Number);

  const isAccident = (daily === 4 && [9].includes(maha)) ||
                     (daily === 9 && [4].includes(maha)) ||
                     (daily === 4 && [9].includes(antar)) ||
                     (daily === 9 && [4].includes(antar));

  let score;

  if (rating && RATING_BASE[rating] !== undefined) {
    // ── Rating provided (Today card): anchor the score TO the rating so they agree ──
    // The rating already reflects the full 6-layer chart. We only nudge within its band.
    score = RATING_BASE[rating];
    if (!natalNums.includes(daily)) score += 3;   // absent daily = fresh energy
    if (daily === basic) score += 3;              // amplification
    if (daily === destiny) score += 2;
    if (isAccident) score -= 12;
    for (const yoga of yogas) {
      if (yoga.id === 'financial_bandhan' && [4,8].includes(daily)) score -= 5;
      if (yoga.id === 'bandhan' && [4,8].includes(daily)) score -= 4;
      if (yoga.id === 'easy_money' && [5,7].includes(daily)) score += 6;
      if (yoga.id === 'raj_yoga' && [1,9].includes(daily)) score += 6;
      if (yoga.id === 'uplifting_319' && [3,1,9].includes(daily)) score += 5;
      if (yoga.id === 'high_intuition' && [7,2].includes(daily)) score += 4;
      if (yoga.id === 'vipreet_raj' && [4,8].includes(daily)) score += 3;
    }
    const [lo, hi] = RATING_BANDS[rating];
    score = Math.min(hi, Math.max(lo, Math.round(score)));
  } else {
    // ── No rating (internal accident scanner): compute independently for day-to-day spread ──
    score = 60;
    if (FRIENDLY[basic]?.includes(daily)) score += 15;
    else if (ENEMY[basic]?.includes(daily)) score -= 15;
    else score += 5;
    if (FRIENDLY[destiny]?.includes(daily)) score += 8;
    else if (ENEMY[destiny]?.includes(daily)) score -= 8;
    if (FRIENDLY[maha]?.includes(daily)) score += 8;
    else if (ENEMY[maha]?.includes(daily)) score -= 8;
    if (FRIENDLY[antar]?.includes(daily)) score += 5;
    else if (ENEMY[antar]?.includes(daily)) score -= 5;
    if (!natalNums.includes(daily)) score += 6;
    if (daily === basic) score += 5;
    if (daily === destiny) score += 3;
    if (isAccident) score -= 20;
    for (const yoga of yogas) {
      if (yoga.id === 'financial_bandhan' && [4,8].includes(daily)) score -= 8;
      if (yoga.id === 'bandhan' && [4,8].includes(daily)) score -= 6;
      if (yoga.id === 'easy_money' && [5,7].includes(daily)) score += 10;
      if (yoga.id === 'raj_yoga' && [1,9].includes(daily)) score += 10;
      if (yoga.id === 'uplifting_319' && [3,1,9].includes(daily)) score += 8;
      if (yoga.id === 'high_intuition' && [7,2].includes(daily)) score += 6;
      if (yoga.id === 'vipreet_raj' && [4,8].includes(daily)) score += 5;
    }
    score = Math.min(96, Math.max(22, Math.round(score)));
  }

  // Label derived from the SAME final score — consistent everywhere.
  let label, color;
  if (score >= 72) { label = 'Strong day'; color = 'success'; }
  else if (score >= 58) { label = 'Good day'; color = 'good'; }
  else if (score >= 45) { label = 'Steady day'; color = 'neutral'; }
  else if (score >= 35) { label = 'Careful day'; color = 'caution'; }
  else { label = 'Take it easy'; color = 'avoid'; }

  // Good for / Bad for tags — from maha+daily combo
  const key = `${maha}_${daily}`;
  const goodFor = GOOD_FOR_TAGS[key] || GOOD_FOR_TAGS[`${maha}_5`] || ['focused work', 'planning', 'learning', 'reflection'];
  const badFor  = BAD_FOR_TAGS[key]  || BAD_FOR_TAGS[`${maha}_5`]  || ['impulsive moves', 'major commitments', 'rushing', 'risky decisions'];

  return { score, label, color, good_for: goodFor.slice(0, 4), bad_for: badFor.slice(0, 4) };
}
