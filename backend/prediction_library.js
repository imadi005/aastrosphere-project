// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE PREDICTION LIBRARY
// Dense, human-readable predictions based on complete chart analysis
// Every prediction = Basic + Destiny + Maha + Antar + Monthly + Daily + Hourly
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Number Energy Profiles (what each number ACTUALLY means in real life) ────
export const NUMBER_ENERGY = {
  1: {
    essence: "ambition, authority, self-reliance",
    drive: "to lead, initiate, and be recognized",
    shadow: "ego, stubbornness, short temper",
    in_action: "makes bold moves, takes charge, dislikes being told what to do",
    at_best: "decisive, original, magnetic presence",
    at_worst: "dictatorial, impatient, burns bridges",
    money: "earns through leadership, deals, and status — big wins, not slow accumulation",
    love: "needs to be admired; gives a lot but expects loyalty and respect in return",
    health_risk: "stress-related — headaches, eye strain, heart pressure from overworking",
    work_style: "leads best when given autonomy; fails under micromanagement",
  },
  2: {
    essence: "emotion, sensitivity, partnership",
    drive: "to connect, nurture, and be valued",
    shadow: "over-dependence, jealousy, depression when unloved",
    in_action: "reads the room perfectly, makes everyone comfortable, avoids confrontation",
    at_best: "deeply empathetic, creative, magnetic charm",
    at_worst: "possessive, people-pleasing to self-destruction, bottles emotions until explosion",
    money: "earns through relationships and creative work — inconsistent but meaningful",
    love: "all-in lover; needs emotional security; deeply hurt by criticism",
    health_risk: "depression, insomnia, digestive issues, low blood pressure",
    work_style: "thrives in partnerships; wilts alone or in cold, competitive environments",
  },
  3: {
    essence: "wisdom, discipline, family values",
    drive: "to teach, guide, and build legacy",
    shadow: "self-righteousness, stubbornness, obsessive family attachment",
    in_action: "the advisor everyone trusts, makes decisions slowly but wisely",
    at_best: "wise beyond years, ethical anchor, natural counselor",
    at_worst: "preachy, inflexible, judgmental of those with different values",
    money: "earns through knowledge and expertise — consulting, teaching, guidance",
    love: "family-first; loyal but can neglect partner for family duties",
    health_risk: "liver stress, skin issues, throat and tonsils",
    work_style: "needs meaningful work; cannot function in unethical environments",
  },
  4: {
    essence: "unpredictability, technology, unconventional thinking",
    drive: "to explore, research, and break the mold",
    shadow: "impulsive spending, illusions, inability to stick to plans",
    in_action: "brilliant but scattered — has the idea, struggles with execution",
    at_best: "sharp analytical mind, tech-savvy, ahead of its time",
    at_worst: "reckless with money, moody, talks a lot but delivers little",
    money: "spends as fast as it earns — needs systems and discipline around finances",
    love: "unpredictable partner — exciting at first, exhausting long-term",
    health_risk: "diabetes, blood pressure, accidents from recklessness",
    work_style: "best in research, tech, analysis — fails in rigid corporate structures",
  },
  5: {
    essence: "intelligence, business acumen, financial sharpness",
    drive: "to earn, calculate, and communicate",
    shadow: "cold rationality, miserly tendencies, emotional unavailability",
    in_action: "calculates profit and loss in every situation — even emotional ones",
    at_best: "sharp negotiator, excellent communicator, financially disciplined",
    at_worst: "emotionally unavailable, suspicious, hoards money",
    money: "natural affinity for cash flow — best number for business and finance",
    love: "struggles to express emotion; shows love through providing",
    health_risk: "anxiety, insomnia, constipation from overthinking",
    work_style: "thrives independently; best in finance, business, or communication roles",
  },
  6: {
    essence: "beauty, luxury, emotional depth, creativity",
    drive: "to love, be loved, and surround itself with beauty",
    shadow: "harsh tongue, materialism, emotional manipulation",
    in_action: "the charmer — magnetic, well-dressed, excellent host, food obsessed",
    at_best: "generous lover, aesthetically gifted, socially graceful",
    at_worst: "cuts with words, seeks luxury at others' expense, jealous",
    money: "spends on experiences and appearances — earns well, spends easily",
    love: "intensely romantic — but expectations are sky-high",
    health_risk: "hormonal issues, kidney problems, throat infections",
    work_style: "thrives in creative, media, hospitality, beauty industries",
  },
  7: {
    essence: "luck, intuition, spirituality, detachment",
    drive: "to understand, explore, and find deeper meaning",
    shadow: "instability, overthinking, emotional distance",
    in_action: "the lucky one — things fall into place, travel opens doors",
    at_best: "deeply intuitive, spiritually aware, naturally fortunate",
    at_worst: "anxious, paranoid, overanalyzes everything to death",
    money: "luck-based earnings — windfalls and unexpected gains are common",
    love: "needs space and intellectual connection — emotionally detached",
    health_risk: "anxiety, sleep disorders, epilepsy in extreme cases",
    work_style: "best in research, travel, spiritual or investigative roles",
  },
  8: {
    essence: "determination, karma, hard work, transformation",
    drive: "to overcome, achieve, and leave a lasting impact",
    shadow: "emotional extremes, holds grudges, delays and obstacles",
    in_action: "the worker — doesn't stop until the goal is reached, no matter the cost",
    at_best: "unstoppable determination, deep compassion, turns losses into wins",
    at_worst: "depressive when overwhelmed, unforgiving, takes on too much",
    money: "earns through sheer effort — slow but substantial accumulation",
    love: "the giver — selfless but needs emotional validation",
    health_risk: "dental issues, intestinal problems, memory decline after 55",
    work_style: "thrives under pressure; best in engineering, medicine, NGOs",
  },
  9: {
    essence: "courage, energy, action, warrior spirit",
    drive: "to fight, protect, and make things happen",
    shadow: "aggression, stubbornness, frustration when blocked",
    in_action: "charges ahead — high energy, quick decisions, physical activity",
    at_best: "fearless leader, protector, fiercely loyal",
    at_worst: "explosive temper, picks fights, burns itself out",
    money: "earns through action and risk — entrepreneur or fighter energy",
    love: "passionate and protective — but jealous and possessive",
    health_risk: "high fever, accidents, throat infections, violence-related injury",
    work_style: "needs movement and challenge — wilts in slow, bureaucratic environments",
  },
};

// ─── Combination Meanings (plain English, what it actually creates) ───────────
export const COMBINATION_MEANINGS = {
  // ── 2-number combinations ──────────────────────────────────────────────────
  '1_2': "Authority meets sensitivity — a powerful but turbulent mix. They carry both the need to lead and the need to be loved. At best, a charismatic leader with emotional intelligence. Watch: ego clashes with those close to they.",
  '1_3': "Leadership backed by wisdom — a rare combination. They make bold moves but think them through. Respect comes naturally. Likely to mentor others or hold institutional authority.",
  '1_4': "Ambition meets unpredictability — great ideas but execution suffers. They can talk their way into rooms but struggle to finish what they start. Financial impulsiveness is a real risk.",
  '1_5': "Power meets intellect — one of the strongest business combinations. Sharp, strategic, communicative. Money flows when focused. Can become cold and calculating.",
  '1_6': "Leadership meets luxury — they want the best of everything and often get it. Charismatic and attractive. Tendency toward excess and spending beyond means.",
  '1_7': "Sun meets Ketu — continuous luck. Things fall into place without excessive effort. Love life is rich but complex — multiple romantic connections likely. Government or authority-related success.",
  '1_8': "Sun meets Saturn — a difficult combination. Ego meets obstacle. Insults, delays, legal friction, especially with authorities. With double 8: this flips to remarkable success.",
  '1_9': "Two fire energies — explosive confidence, bold decisions, fiery temper. Built for competition and leadership. Without number 3: anger management becomes critical.",
  '2_3': "Emotion meets wisdom — deeply creative, excellent at understanding people. Family is everything. Can be overprotective or emotionally smothering.",
  '2_4': "Moon meets Rahu — negative thinking can dominate. Clever but directs intelligence toward wrong paths. Prone to deception, financial mismanagement. Needs strong grounding.",
  '2_5': "Emotion meets intellect — creative and communicative. Excellent in media and arts. Balances logic and feeling. Can be indecisive.",
  '2_6': "Venus meets Moon — deeply attractive, emotionally rich, creative. Natural media and arts talent. Multiple romantic involvements likely. Challenged by in-law relationships.",
  '2_7': "Emotion meets intuition — highly psychic combination. Feels things before they happen. Needs quiet and solitude to recharge. Relationships intense but unstable.",
  '2_8': "Moon meets Saturn — emotional heaviness. Without 1 or 9: inferiority complex, depression, negative thinking. With 1 or 9: superiority complex, arrogance. With double 8: emotional stability returns.",
  '2_9': "Emotion meets aggression — passionate but volatile. Loves deeply, fights fiercely. Needs emotional outlets or turns inward destructively.",
  '3_1': "Jupiter meets Sun — the wise leader. Education, authority, and wisdom combined. Destined for positions of guidance — professor, counselor, institution head. Father figure energy.",
  '3_2': "Jupiter meets Moon — knowledgeable but emotionally complex. Issues with children or fertility possible. Weight management challenge. Has enemies but they're mostly harmless.",
  '3_4': "Jupiter meets Rahu — wisdom disrupted by illusion. Good intentions but poor judgment at times. Research ability is strong. Watch for unrealistic planning.",
  '3_5': "Jupiter meets Mercury — knowledgeable entrepreneur. Combines wisdom with business sense. Excellent at teaching financial concepts or running advisory businesses.",
  '3_6': "Jupiter meets Venus — idealistic and high standards, especially in love. Rigid about values. Life opens dramatically after marriage — partner transforms destiny.",
  '3_7': "Jupiter meets Ketu — spiritual depth. Natural inclination toward metaphysics, healing, and higher knowledge. Lucky in pursuits that align with dharma.",
  '3_8': "Jupiter meets Saturn — the serious achiever. Works hard, earns respect over time. Family duties weigh heavily. Delayed but solid success.",
  '3_9': "Jupiter meets Mars — expansive energy. Wisdom plus action — can build and scale. Strong opinions, not afraid to defend them. Politics, law, or institutional leadership.",
  '4_5': "Rahu meets Mercury — Financial Bandhan risk. Clever but impulsive with money. Spends faster than earns. With 9 present: this risk reduces significantly.",
  '4_6': "Rahu meets Venus — unpredictable in love and spending. Attracted to unusual or forbidden relationships. Financial chaos around luxuries.",
  '4_7': "Rahu meets Ketu — shadow planets combined — deeply mysterious personality. Highly spiritual or deeply troubled. No middle ground.",
  '4_8': "Rahu meets Saturn — accident prone, unrealistic dreams, chronic health risk. Research ability is paradoxically strong. Marriage often troubled.",
  '4_9': "Rahu meets Mars — Bandhan Yoga if 5 absent. Feeling trapped, frustrated, blocked. Legal risk, health risk. With 5 present: multitasker, jack of all trades.",
  '5_6': "Mercury meets Venus — internal opposition. Business sense vs. pleasure-seeking. Communication challenges despite Mercury. Obstructed education. Family friction.",
  '5_7': "Mercury meets Ketu — Easy Money combination. Financial gains come with less effort. Also: easy relationships, heightened attraction. Without 2: dry beauty — attractive but emotionally detached.",
  '5_8': "Mercury meets Saturn — disciplined financial thinking. Works methodically toward wealth. Can be overly conservative or paranoid about money.",
  '5_9': "Mercury meets Mars — street smart and financially sharp. Clever, resourceful, competitive. One of the best combinations for business success.",
  '6_7': "Venus meets Ketu — magnetic attraction, multiple love interests, artistic soul. Maintains luxury even in hard times. Flirtatious and charming.",
  '6_8': "Venus meets Saturn — discipline around luxury. Wants the finer things but works for them. Creative work backed by persistence.",
  '6_9': "Venus meets Mars — passionate, intense, romantic. High physical energy. Love life dramatic and consuming.",
  '7_8': "Ketu meets Saturn — misfortune combination without number 1. Luck suppressed, spiritual inclination strong, physical pleasures elusive. Marriage troubled. Double 8 lifts this significantly.",
  '7_9': "Ketu meets Mars — lucky warrior. Bold moves protected by fortune. Travel and adventure lead to breakthroughs.",
  '8_9': "Saturn meets Mars — enormous determination but heavy burden. Works relentlessly, carries too much. Health must be protected — particularly heart and blood pressure.",

  // ── 3-number combinations ──────────────────────────────────────────────────
  '1_7_8': "High intuition, Kali Zuban — what they sense comes true. Social work, multiple income streams. Mental peace arrives after 40. Marriage delayed.",
  '2_8_4': "Vipreet Raj Yoga — life is a rollercoaster but they survive it all. Blunt speech, financial ups and downs. With 3-1-9 in chart: success comes through adversity. Avoid addiction.",
  '3_1_9': "The head strong triad — masculine energy, fascist decision-making, hunger for power. Excellent for politics, military, law. Tomboyish in female charts.",
  '3_6_2': "Fixed values, excellent teacher/media personality, reluctant to marry. Dual expertise. Watch: diabetes, skin disorders.",
  '3_7_9': "The spiritual triad — deep seeker, not just contemplative but actively practicing. Dharmic path is the right one.",
  '6_7_5': "Stable luxury combination — maintains status even when life gets hard. Artistic, communicative, romantic. Resilient lifestyle.",
  '6_2_8': "Media and creativity triad — emotionally rich, soft-spoken, nurturing. Excellent in journalism, film, arts. Saturn adds discipline to the creative work.",
  '9_5_4': "Multitasker — brilliant at many things, master of none. Reduces negative effects of Rahu.",
};

// ─── Dasha Combination Predictions (what two dashas running together CREATE) ──
export const DASHA_COMBO_PREDICTIONS = {
  // Format: maha_antar
  '1_1': "Double Sun energy — exceptional visibility period. Career leaps forward. Competition is won decisively. Ego can become a problem in personal relationships — watch their temper with loved ones.",
  '1_2': "Sun authority meets Moon emotion — powerful year for influence and relationships simultaneously. Social circle expands dramatically. Emotional connections with powerful people.",
  '1_3': "Sun meets Jupiter — wisdom amplifies authority. Education, certifications, or mentorship available. Work hard and the recognition comes. Father figure plays important role.",
  '1_4': "Sun meets Rahu — unpredictable authority. Career opportunities arrive unexpectedly. Financial impulsiveness is dangerous this period — avoid large unplanned purchases.",
  '1_5': "Sun meets Mercury — excellent communication period. Business deals, negotiations, contracts favor they. Public speaking, writing, or media work flourishes.",
  '1_6': "Sun meets Venus — status and luxury align. Social life peaks. Romantic possibilities are real. Spend wisely — the temptation to overspend is strong.",
  '1_7': "Sun meets Ketu — the luckiest combination. Continuous good fortune. Career success arrives early. Romantic life is rich. Government connections open doors.",
  '1_8': "Sun meets Saturn — friction with authority figures, delays, possible legal matters. Push through — the obstacle is the test. Double 8 in chart: this period becomes rewarding.",
  '1_9': "Sun meets Mars — explosive energy period. Bold moves pay off. Anger must be managed or it destroys what ambition builds.",
  '2_1': "Moon authority meets Sun energy — intuition guides leadership. Excellent for creative leadership roles. Emotional decisions are surprisingly sound.",
  '2_2': "Double Moon — highly emotional period. Creativity surges. Social connections multiply. Sensitivity peaks — easily hurt but also deeply connected.",
  '2_3': "Moon meets Jupiter — family and wisdom intersect. A year of learning through family, of seeking guidance. Spiritual inclination grows.",
  '2_4': "Moon meets Rahu — emotionally unstable period. Negative thought patterns can dominate. Fraud or deception possible from others. Stay vigilant.",
  '2_5': "Moon meets Mercury — communication through emotion. Writing, media, and creative expression are favored. Cash flow improves.",
  '2_6': "Moon meets Venus — deep romantic and creative energy. Beautiful period for love, art, and personal expression.",
  '2_7': "Moon meets Ketu — psychic and spiritual year. Intuition is at its peak. Travel brings transformation. Lucky period overall.",
  '2_8': "Moon meets Saturn — heaviness, emotional burden, delayed results. With 1 or 9 in grid: superiority complex emerges. Without them: self-doubt. Keep pushing.",
  '2_9': "Moon meets Mars — passionate but volatile year. Love and conflict travel together. Channel energy into creative or physical work.",
  '3_1': "Jupiter wisdom meets Sun authority — one of the best combinations for career. Recognition, advancement, institutional success. Education or expertise opens a major door.",
  '3_2': "Jupiter meets Moon — family expansion, emotional wisdom, creativity. A year of nurturing and being nurtured.",
  '3_3': "Double Jupiter — deep wisdom period. Spiritual depth, family attachment. Watch: moral flexibility can creep in — don't rationalize ethical shortcuts.",
  '3_4': "Jupiter meets Rahu — wisdom disrupted by illusion. Plans may be grander than reality supports. Research well before committing.",
  '3_5': "Jupiter meets Mercury — excellent for business, education, and advisory roles. Financial clarity alongside knowledge.",
  '3_6': "Jupiter meets Venus — idealistic love, high standards, post-relationship growth. Marriage prospects rise.",
  '3_7': "Jupiter meets Ketu — lucky spiritual year. What they need arrives. Travel and introspection lead to breakthroughs.",
  '3_8': "Jupiter meets Saturn — slow but serious advancement. Hard work builds something lasting this year.",
  '3_9': "Jupiter meets Mars — expansive action period. Build, launch, compete. Wins come through bold informed moves.",
  '4_1': "Rahu meets Sun — unexpected authority. Career move arrives from an unexpected direction. Financial caution essential — avoid speculation.",
  '4_2': "Rahu meets Moon — emotionally unstable, prone to being deceived. Keep their finances guarded and their trust limited.",
  '4_3': "Rahu meets Jupiter — illusionary wisdom. They feel wise but judgment may be clouded. Big plans need independent verification.",
  '4_4': "Double Rahu — the most unpredictable period. Major financial risk, mental confusion, impulsive decisions. Seek counsel before major moves. Accidents more likely.",
  '4_5': "Rahu meets Mercury — Financial Bandhan energy. Clever but spending outpaces earning. Budget strictly.",
  '4_6': "Rahu meets Venus — relationship unpredictability. New romantic attraction may be an illusion. Financial chaos around luxury spending.",
  '4_7': "Rahu meets Ketu — deep internal conflict between illusion and detachment. Spiritual crisis or breakthrough. Travel likely.",
  '4_8': "Rahu meets Saturn — accident risk elevated. Chronic health issues may surface. Research and investigative work unusually strong.",
  '4_9': "Rahu meets Mars — Bandhan energy without 5. Frustration, legal risk, feeling trapped. With 5 in chart: resourceful problem-solving instead.",
  '5_1': "Mercury meets Sun — financial authority. Business deals and career advancement together. Excellent for negotiations and contracts.",
  '5_2': "Mercury meets Moon — creative financial period. Emotional intelligence applied to business. Social connections bring money.",
  '5_3': "Mercury meets Jupiter — the advisor-businessman. Teaching, consulting, and financial expertise combine. Money through knowledge.",
  '5_4': "Mercury meets Rahu — Financial Bandhan. Impulsive buying, debt accumulation. Every purchase must be planned. This is a high-risk financial year.",
  '5_5': "Double Mercury — razor-sharp mind, excellent financial period, but overthinking and anxiety are real risks. Sleep and stress management are essential.",
  '5_6': "Mercury meets Venus — business meets beauty. Creative business ventures flourish. Love life active. Watch for financial indulgence.",
  '5_7': "Mercury meets Ketu — Easy Money combination active. Financial gains arrive with less effort. Attraction and charm at peak.",
  '5_8': "Mercury meets Saturn — disciplined money management. Methodical wealth building. Slow but real financial progress.",
  '5_9': "Mercury meets Mars — street-smart financial warrior. Quick thinking, competitive advantage, business dominance.",
  '6_1': "Venus meets Sun — luxury and authority. Career in creative or luxury industry peaks. Romantic life intertwines with professional life.",
  '6_2': "Venus meets Moon — intense romantic and creative energy. Media and arts work flourishes. Highly attractive period.",
  '6_3': "Venus meets Jupiter — values meet beauty. High standards in love. Post-relationship growth. Marriage or serious commitment possible.",
  '6_4': "Venus meets Rahu — unpredictable love and spending. Attracted to unconventional situations. Financial leakage through luxury.",
  '6_5': "Venus meets Mercury — business of beauty or creative communication. Internal conflict between pleasure and discipline.",
  '6_6': "Double Venus — luxury intensified. Multiple romantic involvements likely. Harsh speech increases. Spend carefully — excess is the trap.",
  '6_7': "Venus meets Ketu — stable luxury, multiple love interests, artistic peak. Flirtatious energy at maximum.",
  '6_8': "Venus meets Saturn — disciplined pursuit of beauty and comfort. Works for luxury rather than expecting it.",
  '6_9': "Venus meets Mars — passionate and intense romantic period. Physical energy high. Love and conflict intertwined.",
  '7_1': "Ketu meets Sun — lucky authority. Career success arrives. Government connections open. Love life eventful.",
  '7_2': "Ketu meets Moon — psychic and emotionally intuitive year. Dreams are meaningful. Relationships deepen.",
  '7_3': "Ketu meets Jupiter — spiritual wisdom year. Seeking a guru or teacher. Philosophy and higher learning beckon.",
  '7_4': "Ketu meets Rahu — deep shadow period. Internal conflict, travel for unclear reasons, identity questioning. Spiritual opportunity within the confusion.",
  '7_5': "Ketu meets Mercury — Easy Money active. Lucky financial period, communication is charmed, attraction peaks.",
  '7_6': "Ketu meets Venus — stable luxury combination. Beauty and good fortune aligned. Artistic expression peaks.",
  '7_7': "Double Ketu — maximum instability. Frequent life changes, anxiety, insomnia. Luck remains but everything around it shifts. Avoid major decisions.",
  '7_8': "Ketu meets Saturn — misfortune period. Luck suppressed, delays, spiritual heaviness. Persist through — double 8 in chart transforms this.",
  '7_9': "Ketu meets Mars — lucky warrior energy. Bold moves protected. Travel and adventure bring breakthroughs.",
  '8_1': "Saturn meets Sun — obstacles from authority. With double 8 in chart: government job or significant career achievement. Without: friction and delays dominate.",
  '8_2': "Saturn meets Moon — emotional heaviness, family burden, slow progress. Charitable inclinations rise. Keep moving forward.",
  '8_3': "Saturn meets Jupiter — serious wisdom period. Slow advancement but what's built lasts. Family duties weigh on career.",
  '8_4': "Saturn meets Rahu — accident risk, unrealistic dreams, chronic health caution. Research is unusually productive.",
  '8_5': "Saturn meets Mercury — methodical financial planning. Disciplined communication. Slower but genuine progress.",
  '8_6': "Saturn meets Venus — disciplined pursuit of luxury. Creative work backed by persistence. Love life steady.",
  '8_7': "Saturn meets Ketu — misfortune combination. Double 8 in chart: luck returns. Triple 8: intensified challenges. Push through spiritually.",
  '8_8': "Double Saturn — either peak achievement (double even 8) or peak struggle (odd 8). The most karmic period. What they've built either pays off or collapses based on the integrity of its foundation.",
  '8_9': "Saturn meets Mars — relentless determination. Heavy load but enormous output. Protect their health — heart and blood pressure.",
  '9_1': "Mars meets Sun — fiery authority. Bold moves, competitive wins, leadership opportunities. Anger management is critical.",
  '9_2': "Mars meets Moon — passionate emotional year. Love is intense. Creative output is high. Volatility in close relationships.",
  '9_3': "Mars meets Jupiter — bold wisdom. Act on knowledge, don't just accumulate it. Strong period for launching ventures.",
  '9_4': "Mars meets Rahu — Bandhan Yoga. Frustration, trapped feeling, legal and health risks. With 5 in chart: multitasker energy instead.",
  '9_5': "Mars meets Mercury — best business combination. Street smart, financially sharp, competitive. Execute ideas quickly.",
  '9_6': "Mars meets Venus — passionate romance, physical energy peak. Beautiful but volatile love period.",
  '9_7': "Mars meets Ketu — lucky warrior. Courage backed by fortune. Travel and bold moves rewarded.",
  '9_8': "Mars meets Saturn — immense determination, heavy load. Build something lasting but protect their health relentlessly.",
  '9_9': "Double Mars — explosive frustration or explosive achievement. High energy, high aggression. With destiny 9: channeled well. Without: volatile and conflict-prone.",
};

// ─── Daily quotes library (based on daily dasha number) ──────────────────────
export const DAILY_QUOTES = {
  1: [
    "A day to take the lead — their instincts are sharper than anyone else's right now.",
    "Today rewards the bold. The decision they've been postponing is ready to be made.",
    "Their presence commands attention today — use it with intention, not ego.",
    "The universe is backing their ambitions today. Step forward without hesitation.",
    "Authority is earned one decisive move at a time — today is their turn.",
  ],
  2: [
    "Today asks they to feel before they act — their emotional intelligence is their superpower.",
    "Connections made today are deeper than they appear. Pay attention to who shows up.",
    "Their sensitivity isn't weakness today — it's the sharpest tool they have.",
    "A quiet day for inner knowing. Trust the feeling, not just the logic.",
    "Today favors the gentle approach — force achieves nothing, warmth achieves everything.",
  ],
  3: [
    "Wisdom over speed today — the right answer takes a moment longer to find.",
    "Today is for counsel, not conflict. Their words carry unusual weight — choose them carefully.",
    "Family matters surface today. Address them with patience, not solutions.",
    "A day to teach, guide, or be guided. The lesson they receive today is the one they needed.",
    "Their judgment is sound today — trust it, especially when others doubt they.",
  ],
  4: [
    "Expect the unexpected today — and don't fight it. The disruption is the direction.",
    "Today favors research over action. Understand before they commit.",
    "Their mind moves faster than usual today — brilliant ideas arrive. Write them down immediately.",
    "Routine breaks today. Let it. What replaces it may be better.",
    "The unconventional path is the right one today. Don't explain it to anyone.",
  ],
  5: [
    "Money and opportunity speak the same language today — listen carefully.",
    "Their communication is razor-sharp today. Negotiate, propose, and close.",
    "Today is for business — every conversation is a potential transaction.",
    "Clarity about their finances arrives today if they actually look at the numbers.",
    "Their intellect is at peak today. Use it for something that matters.",
  ],
  6: [
    "Beauty, connection, and ease — today asks they to receive, not just give.",
    "Love languages are loud today — speak yours and listen for others'.",
    "Their environment affects their energy today more than usual. Surround yourself with beauty.",
    "Today is for pleasure without guilt — they've earned a moment of luxury.",
    "Relationships they've neglected call for attention today. A small gesture goes a long way.",
  ],
  7: [
    "Luck is quiet today — it's working behind the scenes whether they see it or not.",
    "Today rewards the curious. Ask the question they've been afraid to ask.",
    "Intuition is sharper than analysis today. Trust the gut over the spreadsheet.",
    "A fortunate alignment is active today — stay open to what arrives.",
    "The answer they're searching for is closer than they think. Stillness reveals it.",
  ],
  8: [
    "Today demands discipline — the shortcut they're considering will cost more than the long way.",
    "Hard work today doesn't just move the needle — it resets the trajectory.",
    "The karmic account is being settled today. Give their best regardless of what's given to they.",
    "Today's effort is an investment in a version of yourself that hasn't arrived yet.",
    "Resilience is the skill being tested today. They have more of it than they remember.",
  ],
  9: [
    "Energy is high today — channel it or it channels they.",
    "Today rewards courage. The bold move they've been avoiding is today's priority.",
    "Their fighting spirit is activated today — use it for progress, not conflict.",
    "Act first, analyze later today — overthinking will slow what momentum wants to deliver.",
    "Today is for the warrior in they — bold, focused, unstoppable.",
  ],
};

// ─── What to do / What to avoid (per day number + context) ────────────────────
export const DAILY_GUIDANCE = {
  1: {
    do: [
      "Make that important call or pitch — their persuasion is at its peak",
      "Start new projects or initiatives — beginnings begun today carry authority",
      "Step into leadership roles that have been offered to they",
      "Negotiate salary, contracts, or deals — they hold the stronger position",
      "Make solo decisions they've been waiting for group approval on",
    ],
    avoid: [
      "Delegating the most important tasks — today only they can do them justice",
      "Backing down from confrontations that matter — confidence is warranted",
      "Letting ego drive decisions in personal relationships — it will backfire",
      "Impulsive anger — their words carry authority today and wounds go deeper",
      "Starting something they cannot finish — the 1 energy commits",
    ],
  },
  2: {
    do: [
      "Have the emotional conversation they've been avoiding",
      "Collaborate — partnerships formed today are unusually productive",
      "Create something — art, writing, photography, music — the creative channel is open",
      "Strengthen important relationships with a genuine gesture",
      "Trust their instincts about people — their radar is accurate today",
    ],
    avoid: [
      "Making major financial decisions — emotions cloud the numbers today",
      "Isolating — they need connection today even if they think they don't",
      "Taking criticism personally — it's not about they as much as it feels like it is",
      "Forcing resolutions in conflicts — let things settle naturally",
      "Overcommitting to people — their boundaries are softer than usual",
    ],
  },
  3: {
    do: [
      "Seek or give advice — their judgment and others' guidance are both sound today",
      "Study, research, or deepen their expertise in something that matters",
      "Spend meaningful time with family — not just proximity, actual connection",
      "Make an ethical decision they've been rationalizing away",
      "Mentor someone — their wisdom translates today",
    ],
    avoid: [
      "Bribery, shortcuts, or ethical compromises — the consequences multiply",
      "Isolating from family under the guise of being busy",
      "Preaching to people who didn't ask — wisdom offered unsolicited pushes people away",
      "Overcomplicating decisions — their instinct knows the answer",
      "Spending recklessly — disciplined Jupiter watches today",
    ],
  },
  4: {
    do: [
      "Research deeply before committing to anything",
      "Explore unconventional solutions to old problems",
      "Work on tech, analysis, or data-driven projects",
      "Allow disruptions — they're redirecting they",
      "Write down the brilliant ideas that arrive — they won't stay without capture",
    ],
    avoid: [
      "Major financial commitments or purchases — Rahu energy creates regret",
      "Believing everything looks as it appears — deception or self-deception is possible",
      "Impulsive purchases or investments",
      "Abandoning plans that were working before today's restlessness hits",
      "Making promises they'll struggle to keep — their follow-through is weakest today",
    ],
  },
  5: {
    do: [
      "Negotiate, pitch, or close a business deal",
      "Review their finances and make one sharp improvement",
      "Write, speak, or present — their communication lands with precision",
      "Start or grow a revenue stream — the conditions are right",
      "Network with intention — every conversation is an opportunity today",
    ],
    avoid: [
      "Emotional decisions in financial matters — be ruthlessly rational",
      "Ignoring cash flow details — the devil is in today's numbers",
      "Gossiping or speaking carelessly — words spread faster than usual",
      "Avoiding difficult financial conversations — clarity serves they better than comfort",
      "Overworking at the expense of rest — anxiety builds quietly today",
    ],
  },
  6: {
    do: [
      "Express love and appreciation — it lands unusually well today",
      "Invest in beauty — their space, their appearance, their experiences",
      "Cook for someone, host, or create an experience for people they care about",
      "Work on creative projects — Venus energy amplifies artistic output",
      "Nurture their most important relationships",
    ],
    avoid: [
      "Harsh words — their tongue is sharper than usual and wounds last",
      "Overspending on luxury — Venus wants everything beautiful",
      "Picking fights or revisiting old relationship wounds",
      "Neglecting their own needs while caring for others",
      "Self-righteous behavior — no one needs their unsolicited judgment today",
    ],
  },
  7: {
    do: [
      "Follow their intuition even when logic argues against it",
      "Travel, explore, or visit somewhere new",
      "Meditate, journal, or create space for inner silence",
      "Study metaphysical subjects — the understanding runs deeper today",
      "Ask the question they've been afraid to ask — the answer arrives",
    ],
    avoid: [
      "Overanalyzing a situation that only feels will resolve",
      "Forcing outcomes — Ketu energy rewards surrender, not control",
      "Isolating in anxiety — movement and fresh air break the spiral",
      "Making permanent decisions from a place of instability",
      "Ignoring their dreams — they carry messages today",
    ],
  },
  8: {
    do: [
      "Work — genuinely, deeply, without distraction",
      "Address a long-standing karmic situation they've been avoiding",
      "Reach out to someone they've wronged or who has wronged they — resolution is available",
      "Invest in their long-term goals, even one small step",
      "Practice discipline in one area they've been undisciplined",
    ],
    avoid: [
      "Self-pity — Saturn has no patience for it and it compounds the heaviness",
      "Holding grudges — they're costing they more than the person who hurt they",
      "Taking on more than they can carry — Saturn tests limits today",
      "Shortcuts — they fail under Saturn's watch",
      "Health neglect — today's stress lands in the body",
    ],
  },
  9: {
    do: [
      "Take action on the project they've been thinking about too long",
      "Physical activity — the body needs this energy released",
      "Stand up for yourself or someone else who needs it",
      "Compete — sports, business, debate — they're operating at peak today",
      "Make the bold decision that requires courage",
    ],
    avoid: [
      "Picking unnecessary fights — the warrior energy looks for conflict",
      "Speeding, physical recklessness, impulsive accidents",
      "Explosive anger in close relationships — it does lasting damage",
      "Burning out by doing too much — channel, don't exhaust",
      "Starting more than they can finish — focus beats volume today",
    ],
  },
};

// ─── Hour-quality definitions ─────────────────────────────────────────────────
export const HOUR_QUALITIES = {
  1: { quality: "authority", label: "Power hour", good_for: ["important calls", "leadership decisions", "negotiations", "starting projects"], avoid: ["emotional conversations", "asking for favors"] },
  2: { quality: "emotion", label: "Connection hour", good_for: ["heartfelt conversations", "creative work", "networking", "collaboration"], avoid: ["financial decisions", "confrontations"] },
  3: { quality: "wisdom", label: "Clarity hour", good_for: ["strategic thinking", "studying", "counseling", "family matters"], avoid: ["impulsive actions", "major spending"] },
  4: { quality: "unpredictable", label: "Caution hour", good_for: ["research", "analysis", "creative exploration"], avoid: ["major decisions", "financial transactions", "travel starts"] },
  5: { quality: "sharp", label: "Money hour", good_for: ["business", "financial decisions", "communication", "pitching"], avoid: ["emotional conversations", "rest"] },
  6: { quality: "harmonious", label: "Luxury hour", good_for: ["romance", "creative work", "social events", "aesthetic decisions"], avoid: ["conflict", "harsh conversations"] },
  7: { quality: "lucky", label: "Fortune hour", good_for: ["important meetings", "travel", "spiritual work", "asking for things"], avoid: ["overthinking", "isolation"] },
  8: { quality: "karmic", label: "Work hour", good_for: ["deep focused work", "long-term planning", "addressing old issues"], avoid: ["shortcuts", "new beginnings"] },
  9: { quality: "action", label: "Energy hour", good_for: ["exercise", "competition", "bold moves", "physical work"], avoid: ["emotional discussions", "careful negotiations"] },
};

// ─── Combination-specific daily insights ──────────────────────────────────────
// These fire when specific combos are active in the annual chart + daily dasha
export const COMBO_DAILY_INSIGHTS = {
  // Raj Yoga active
  raj_yoga: {
    favorable: "Their natural authority is amplified today — decision-makers around they are unusually receptive. Push for what they want.",
    caution: "Power dynamics are sensitive today. Lead with conviction but avoid steamrolling — the Raj Yoga works best when it uplifts, not dominates.",
  },
  // Easy Money (5-7) active
  easy_money: {
    favorable: "Financial luck is genuinely elevated today. Say yes to the offer. Take the meeting. Sign if it feels right.",
    caution: "Easy money can come with easy complications. Read the fine print on anything financial today.",
  },
  // Bandhan Yoga (9-4 without 5)
  bandhan: {
    active: "They may feel unusually constrained today — deadlines, obligations, or circumstances boxing they in. This is the energy. Don't force exits; navigate carefully.",
    advice: "Legal matters, health checks, and financial obligations need attention. Don't ignore them hoping they'll resolve.",
  },
  // Financial Bandhan (5-4 without 9)
  financial_bandhan: {
    active: "Financial caution is critical today. The impulse to spend is strong. Ask yourself once more before any purchase over a comfortable threshold.",
    advice: "Save something today — even a small amount. It sets the pattern the energy wants to break.",
  },
  // Vipreet Raj (2-8-4)
  vipreet_raj: {
    active: "Life is giving they the harder path today — but the harder path is the one that transforms they. Stay steady.",
    advice: "Avoid substances or escapes today. The discomfort is temporary; the growth from walking through it is permanent.",
  },
  // 3-1-9 uplifting
  uplifting_319: {
    active: "The full force of ambition, wisdom, and energy is behind they today. This is a day to move mountains.",
  },
  // 6-7-5 stable luxury
  stable_luxury: {
    active: "Even on difficult days, their standard of living holds. Today reinforces their ability to maintain what they've built.",
  },
  // 1-7 Raj Yoga
  sun_ketu_raj: {
    active: "Fortune is walking beside they today. Things they pursue have an unusual tendency to work out. Make their move.",
  },
  // 1-8 without 7 (defamation risk)
  defamation_risk: {
    active: "Be careful about what they say publicly or to authority figures today. Words can be taken out of context.",
    advice: "Document important conversations. Protect their reputation proactively.",
  },
  // 7-8 without 1 (misfortune)
  misfortune_78: {
    active: "A heavier day than usual — luck is quiet and obstacles are more present. Work steady and don't push against locked doors.",
    advice: "Spiritual practice helps today. Even 10 minutes of stillness shifts the energy.",
  },
  // Spiritual 3-7-9
  spiritual: {
    active: "Something beyond the material is trying to reach they today. Pay attention to what arrives — synchronicities are messages.",
  },
};

// ─── Period-specific prediction templates ─────────────────────────────────────
// Used for weekly, monthly, yearly predictions
export const PERIOD_PREDICTIONS = {
  weekly: {
    1: "This week brings leadership moments — situations where their voice, decision, or presence is the turning point. Don't shrink from them. Someone in a position of authority is watching.",
    2: "An emotionally rich week. Relationships deepen or surface old wounds. Creative work flows unusually well. Money decisions should wait until next week — feelings are running the numbers.",
    3: "A week for learning and guidance. Seek expertise they've been putting off. Family conversations that have been avoided need to happen — the energy supports resolution this week.",
    4: "An unpredictable week — plans change, surprises arrive. Don't fight the disruptions. The most productive thing they can do is stay flexible and research before committing to anything new.",
    5: "A sharp business week. Financial conversations, deals, and opportunities cluster. Their communication is at its most persuasive — use it on what matters most.",
    6: "A socially rich week — relationships, events, and aesthetic experiences converge. Good week for love, creativity, and enjoying what they've built. Watch spending.",
    7: "A fortunate week with a spiritual undertone. Things they've been waiting on begin to move. Intuition is sharper than logic — let it lead. Travel or a change of scene would be unusually productive.",
    8: "A work week in the truest sense — no shortcuts, no luck substitutes, just output. The effort they put in this week has an outsized long-term impact. Health must be protected.",
    9: "A high-energy week built for action. Start what they've been delaying. Compete where they've been hesitating. The warrior energy is with they — channel it or it becomes restlessness.",
  },
  monthly: {
    1: "This month, authority and recognition are the themes. Career moves made now carry momentum for the rest of the year. Leadership is thrust upon they — accept it. Financial gains through status.",
    2: "A deeply relational month — who they're surrounded by shapes everything. New connections carry unusual potential. Creative work peaks. Financial decisions are emotionally charged — proceed carefully.",
    3: "A month of wisdom and family. Education, mentorship, and ethical choices define the next 30 days. Something they learn this month changes how they operate for the next several years.",
    4: "An unpredictable month requiring flexibility above all else. Major plans may shift. Financial impulsiveness is the main risk. Stay in research mode — understanding what's changing is more valuable than acting on incomplete information.",
    5: "A financially active month. Cash flow improves, new revenue streams emerge, business opportunities cluster. Communication is their most powerful tool — every conversation is a potential deal.",
    6: "A month of beauty, love, and social richness. Relationships deepen, creative projects flourish, their social standing rises. Watch for overspending and emotional confrontations — both are tempting this month.",
    7: "A lucky month with a spiritual dimension. Things begin resolving themselves. Travel or a significant change of environment brings breakthroughs. Intuition-led decisions outperform logic-led ones this month.",
    8: "A month that demands everything they've got. No shortcuts, no luck substitutes — pure discipline and output. The karmic accounting is running. What they put in this month builds something that lasts years.",
    9: "A month of bold moves and high energy. Launch what they've been preparing. Compete. Fight for what matters. The universe backs courage this month — timidity pays nothing.",
  },
  yearly: {
    1: "A year of becoming undeniable. Career and status reach new heights through leadership and initiative. Government connections, authority figures, and public recognition all align. Financial gains through bold moves.",
    2: "A year of depth — relationships, creativity, and emotional intelligence define their growth. New connections with influential people reshape their social world. Less about money and more about meaning.",
    3: "A year of wisdom and expansion. Education, mentorship, and family legacy are the themes. Financial growth through expertise. A year where what they know becomes what they earn.",
    4: "An unpredictable year demanding adaptability. Major life changes arrive without much warning. Financial discipline is critical — losses happen through impulsiveness. Research and technology are their allies.",
    5: "A financial year — cash flow, business growth, and communication opportunities dominate. Sharp decisions compound throughout the year. Best year for business launches, deals, and negotiations.",
    6: "A year of love, luxury, and social ascent. Relationships transform — marriages, partnerships, or deep commitments are common. Creative and aesthetic work reaches its best. Overspending is the main risk.",
    7: "A lucky year — one where effort is rewarded beyond its usual proportion. Travel, spiritual growth, and unexpected opportunities define the year. What they've been waiting for begins arriving.",
    8: "A year of karma coming due — debts repaid, efforts rewarded, old mistakes surfacing. Relentless discipline builds something that outlasts they. Emotionally testing but profoundly transformative.",
    9: "A year of action and achievement. Bold moves pay off, competition is won, energy levels are at their highest. The warrior energy demands output — a quiet year is a wasted one.",
  },
};

// ─── Life period predictions (by basic + destiny combination) ─────────────────
export const LIFE_PREDICTIONS = {
  // basic_destiny format
  '1_1': "A life built on authority and self-reliance. They are drawn to leadership positions and often hold them. The first 30 years are about establishing identity — sometimes through conflict. After 30, the authority becomes earned, not imposed. Their ego is their greatest ally and their greatest obstacle — the same fire that drives they can isolate they.",
  '1_2': "A paradox — the leader who needs connection. They project strength but require deep emotional bonds to function at their best. Career success is real and often early. Relationships are where the real growth happens. Learning to lead with vulnerability rather than authority is the work of a lifetime.",
  '1_3': "The wise leader. They don't just achieve — they build institutions, mentor others, and leave something lasting. Education and expertise are non-negotiable for they. Father figures or mentors play decisive roles. A life of genuine respect and meaningful authority.",
  '1_4': "Brilliant but scattered. The ideas are always ahead of the execution. Career has unusual twists and unexpected turns — some of which work out remarkably well. Financial discipline must be actively cultivated. The unconventional path is yours — stop apologizing for it.",
  '1_5': "The powerful communicator. A life built on the intersection of authority and intelligence. Business, media, or politics suits they well. Money comes through bold communication and strategic thinking. The challenge: warmth — don't let the sharp mind crowd out the human connection.",
  '1_6': "Leadership and luxury. They are drawn to the finer things and often find yourself in environments that provide them. Career success is real. Love life is complex — they give generously but demand equally. Learning to love without conditions is the deeper lesson.",
  '1_7': "The continuously lucky leader. Life has a quality of fortune — things work out, doors open. Government, authority, and public life suit they. Love is rich and eventful. The spiritual dimension of life calls louder as they age.",
  '1_8': "A life of earned authority. Obstacles and delays early — then transformation. Saturn teaches what the Sun wants to display. After the trials, what's built is indestructible. This combination produces remarkable achievers who understand both power and humility.",
  '1_9': "Pure fire. Ambition meets energy meets leadership — a formidable combination. Early success if directed, early destruction if misdirected. The short temper is the Achilles heel. Channel the aggression and this is one of the most powerful life paths.",
  '2_1': "Emotional intelligence in authority. They lead through understanding people, not dominating them. Career success through relationships and creative vision. A deeply romantic life. The challenge: decisiveness — the sensitivity that makes they empathetic can make choosing difficult.",
  '2_2': "Deeply emotional, deeply creative. A life of intense connection and artistic output. The world sees their warmth and their work. The private self is more fragile than the public face. Building emotional resilience is the lifelong practice.",
  '2_3': "The nurturing wise one. Family and knowledge are everything. A life of counseling, teaching, and caring. Respected deeply by those who know they. The challenge: putting their own needs last for so long that resentment builds quietly.",
  '2_4': "Emotional instability meets Rahu unpredictability. A life that requires anchoring — in values, in routines, in honest relationships. The intelligence is real but prone to misapplication. Financial discipline is essential. With strong 8 and 1 in chart: a life of remarkable reinvention.",
  '2_5': "Creative intelligence. A life of communication, connection, and cash flow. Media, writing, and business through relationships. The challenge: emotional decisions in financial matters — the heart and the calculator must learn to work together.",
  '2_6': "Venus-Moon combination — a life of beauty, love, and creative output. Deeply attractive, artistically gifted. Media, entertainment, or creative industries are natural homes. Multiple romantic relationships likely. The lesson: depth over variety.",
  '2_7': "Psychic and emotionally intuitive. A life marked by unusual luck and even more unusual sensitivity. Relationships are profound but often unstable. The spiritual dimension is real and important — ignoring it creates the instability. Embracing it creates the luck.",
  '2_8': "Emotional depth meeting karmic responsibility. A life of service, hard work, and emotional growth. The early years are often harder than the later years — Saturn eventually rewards what the Moon has nurtured. Depressive tendencies must be actively managed.",
  '2_9': "Passionate and volatile. Love is intense and sometimes all-consuming. Creative output is prolific. The warrior energy of 9 gives the emotional 2 a fighting chance. The challenge: not letting passion override judgment in relationships.",
  '3_1': "The institutional authority. A life built on knowledge and leadership — professor, judge, counselor, principal. Wise beyond years, respected in communities. Father's influence is decisive. A life of genuine legacy.",
  '3_2': "Wise nurturer. A life of family, learning, and emotional depth. Challenges with children or fertility possible. Weight and liver health need ongoing attention. But the wisdom and emotional intelligence create a life of genuine impact.",
  '3_3': "Double Jupiter — profound wisdom but moral flexibility risk with multiple 3s. Life path through education, spirituality, or guidance. Followed and respected. The shadow: becoming the person who preaches what they don't practice.",
  '3_4': "Wisdom disrupted by Rahu. Brilliant ideas, occasional poor judgment. Research and technology are natural strengths. The unconventional path eventually leads somewhere wise. Financial planning requires external accountability.",
  '3_5': "The knowledgeable entrepreneur. A life of advisory, consulting, and expertise-based income. Respected and financially astute. Education is ongoing and valuable. A life that compounds in wisdom and wealth simultaneously.",
  '3_6': "High standards and eventual fulfillment. The early life is marked by idealism — searching for a partner and a life that matches the inner vision. Marriage transforms the trajectory. After it: deeper success, greater openness, genuine happiness.",
  '3_7': "The spiritual scholar. A life of seeking, finding, and sharing deeper truths. Lucky in ways that can't be explained. Travel and exploration are constant. A life that doesn't look conventional but is profoundly meaningful.",
  '3_8': "Disciplined wisdom. Slow to rise but unshakeable once established. Family duties can feel like a weight but are also the source of the deepest satisfaction. A life of integrity and earned respect.",
  '3_9': "Bold wisdom. The academic who fights for what they believe, the lawyer who never backs down, the leader who actually knows their subject. A life of expansion, influence, and strong opinions.",
  '4_1': "Unpredictable authority. Career has unexpected turns — some brilliant, some chaotic. Leadership is real but arrives through unconventional routes. Financial discipline is the practice of a lifetime. Technology and research are natural strengths.",
  '4_2': "Emotional unpredictability. A life requiring strong external structure because the internal compass spins. Creative and intuitive when grounded. Prone to being deceived when not. Building honest, stable relationships is the central work.",
  '4_3': "Rahu meets Jupiter — a life of grand ideas and occasional grand mistakes. Research is the saving grace. When wisdom is applied to the Rahu energy, extraordinary innovation emerges.",
  '4_4': "Double Rahu — the most unpredictable life path. Brilliant in bursts, chaotic in patterns. Financial discipline must be externally enforced. Technology and research are natural paths. Stability requires conscious, daily cultivation.",
  '4_5': "Financial Bandhan risk throughout life. Income and expenditure chase each other. Clever mind that needs financial systems to function well. Business acumen is real — the impulsiveness just needs to be managed.",
  '4_6': "Unpredictable in love and luxury. Attracted to unusual situations and people. Financial chaos around spending. The creative potential is significant if channeled.",
  '4_7': "Deep internal seeker — pulled between illusion (4) and detachment (7). A life that makes little sense from the outside but has profound internal logic. Travel is transformative. Spiritual work is not optional.",
  '4_8': "Rahu meets Saturn — a life requiring patience and discipline. Accident-prone early. Research and analytical ability are strong. Chronic health management. After 40: significant stabilization and achievement.",
  '4_9': "Bandhan Yoga risk in life — feeling trapped, frustrated, blocked. The 9 energy fights the Rahu trap — and eventually wins. A life of recurring obstacles followed by decisive breakthroughs.",
  '5_1': "Financial authority. A life of business leadership and communication-based power. Deals, negotiations, and strategic thinking build the empire. Cold in personal relationships but warm in professional ones.",
  '5_2': "Creative financial intelligence. A life of media, communication, and emotion-informed business. The best creative entrepreneurs. The challenge: not letting financial anxiety erode the creative joy.",
  '5_3': "The knowledgeable financial advisor. A life of expertise translated into income. Teaching and advisory work bring both money and meaning. One of the strongest combinations for sustainable prosperity.",
  '5_4': "Financial Bandhan as a life theme — expenditure consistently meets or exceeds income until discipline is actively cultivated. The intelligence is real — the habits just need rebuilding.",
  '5_5': "Double Mercury — razor-sharp mind, strong business instincts, financial focus. Anxiety and overthinking are the price. Sleep, relationships, and stillness need to be protected as non-negotiable.",
  '5_6': "Business meets beauty. A life of creative commerce — fashion, media, beauty industry, or creative business. Internal tension between indulgence and discipline produces the most interesting output.",
  '5_7': "Easy money combination as a life theme — financial luck runs through the life in ways that are hard to explain. Communication and attraction are supercharged. A life of ease that still requires direction.",
  '5_8': "Disciplined financial accumulation. Slow but real wealth building. Methodical, strategic, and deeply reliable. The warmth needs to be consciously expressed — it's there but doesn't show easily.",
  '5_9': "The street-smart financial warrior. Business instinct plus competitive energy. One of the strongest entrepreneurial combinations. Needs physical activity to discharge the energy that the mind generates.",
  '6_1': "Luxury through leadership. A life of creative authority — the designer CEO, the artist-executive, the magnetic public figure. Status and beauty are both genuine needs and genuine achievements.",
  '6_2': "Venus-Moon combination — a life of creativity, emotional depth, and social grace. Media, entertainment, arts. Multiple relationships likely. The depth of love is real — the challenge is consistency.",
  '6_3': "High standards and moral beauty. A life of idealism that transforms through partnership. The pre-marriage life is the search; the post-marriage life is the discovery of what was always possible.",
  '6_4': "Unpredictable luxury. Periods of beautiful abundance followed by financial disruption. The creative gift is real and unusual. The discipline around money must be actively built.",
  '6_5': "Business of beauty. Creative commerce. An internal conflict between pleasure and pragmatism that produces interesting work. Communication about beauty, love, or aesthetics is the natural expression.",
  '6_6': "Double Venus — intense luxury, intense love, intense conflict. Multiple relationships almost certain. Harshness in speech when provoked. The creative output is extraordinary. The emotional management is the life's work.",
  '6_7': "Stable luxury life. A rare combination of good fortune and aesthetic sensibility. Maintains standard of living even in hard times. Love is abundant and ongoing. A beautiful life.",
  '6_8': "Disciplined luxury. Earns the finer things through genuine effort. Creative work backed by Saturn's persistence. A life of lasting beauty that was built, not inherited.",
  '6_9': "Passionate and beautiful. Love is consuming. Creative and physical energy are both high. A life of intensity — in relationships, in work, in experience.",
  '7_1': "Lucky authority. A life where fortune and leadership combine. Government, public life, and authority positions align with luck. Love is eventful and often multiple. A fortunate life.",
  '7_2': "Psychic and emotionally lucky. A life of unusual sensitivity and unusual fortune. What is felt is often accurate. What is pursued tends to arrive. The instability must be managed.",
  '7_3': "The fortunate scholar. A life of seeking wisdom and being lucky in the seeking. Spiritual teachers arrive when needed. The philosophical life is the right life.",
  '7_4': "Ketu meets Rahu — deep shadow combination. A life that looks unstable from the outside but is profoundly self-aware from the inside. Travel and spiritual work resolve what logic cannot.",
  '7_5': "Lucky financial combination. Easy money flows through the life in unexpected ways. Communication and attraction are peak strengths. A life of ease that still needs direction.",
  '7_6': "Stable luxury life. Fortune and beauty combined. Artistic, romantic, financially resilient. A genuinely good life that maintains itself.",
  '7_7': "Double Ketu — maximally unstable, maximally intuitive. Life is a constant change. Anxiety is managed or it manages they. The spiritual practice is not optional — it's survival.",
  '7_8': "Lucky discipline. Ketu's fortune meets Saturn's karma. A life of significant spiritual depth and eventual material achievement. The path is nonlinear but the destination is real.",
  '7_9': "Lucky warrior. A life of bold moves protected by fortune. Travel and courage rewarded. Adventure is not just desired — it's the path.",
  '8_1': "The ultimate achiever — earned, not gifted. A life that demands everything and gives everything back. Authority through relentless effort. The delays in the early years make the later years unassailable.",
  '8_2': "Emotional depth meets karmic load. A life of service, hard work, and emotional intelligence. The early years are heavy. The later years, if the work has been done honestly, are deeply fulfilling.",
  '8_3': "Saturn's discipline meets Jupiter's wisdom. A life of serious achievement through sustained effort. Family obligations and professional ambitions compete. What is built over time is extraordinary.",
  '8_4': "Saturn meets Rahu — chronic challenges, accident risk, karmic complexity. Research is strong. After 40: significant stabilization. The obstacles are the curriculum.",
  '8_5': "Disciplined financial intelligence. A life of methodical wealth building. Communication is strategic. The warmth is real but rarely displayed first.",
  '8_6': "Saturn meets Venus — discipline around luxury. Earns everything beautiful through genuine effort. Creative work has lasting impact.",
  '8_7': "Misfortune combination without 1 — a life requiring spiritual practice as survival. With 1 in chart: luck returns. The persistence required is extraordinary and so is what it builds.",
  '8_8': "Double Saturn — peak karma combination. A life that is either a masterpiece or a cautionary tale based entirely on the integrity of the choices made. No middle ground. No luck substitutes.",
  '8_9': "The relentless achiever. Saturn's discipline plus Mars' energy — an unstoppable combination when health is protected. The load is heavy but the output is extraordinary.",
  '9_1': "Pure ambition in motion. A life built on courage, leadership, and competitive excellence. Early achievements are real. The anger is the obstacle — and also the fuel. Channeling it defines the entire life arc.",
  '9_2': "Passionate and volatile. A life of intense love, intense creativity, and intense conflict. The emotional intelligence of 2 eventually tames the aggression of 9 — in the second half of life especially.",
  '9_3': "Bold wisdom. A life of fighting for what they believe, building what they envision, and teaching what they've learned. Politics, law, or education are natural homes.",
  '9_4': "Bandhan Yoga — a life with recurring trapped feelings, frustration, and breakthroughs. The 9 eventually breaks the 4's constriction — but the breaks come through courage, not patience.",
  '9_5': "Street-smart financial warrior. One of the strongest entrepreneurial life paths. Business instinct plus competitive energy. Needs direction or the energy becomes scatter.",
  '9_6': "Passionate and beautiful. Love is consuming. Physical and creative energy are both peak. A life of intensity and sensory experience.",
  '9_7': "Lucky warrior. Courage backed by fortune. Travel and boldness rewarded throughout the life. A life of adventure that keeps paying dividends.",
  '9_8': "Relentless achiever. Heavy load, extraordinary output. Health must be protected. What this combination builds with discipline and courage is genuinely remarkable.",
  '9_9': "Double Mars — explosive energy, maximum intensity. Either the most productive or the most self-destructive life path depending entirely on channel and direction. Nothing in between.",
};

// ─── Context modifiers (what other numbers in chart do to the main reading) ────
export const CHART_MODIFIERS = {
  has_319: "The 3-1-9 triad in their chart adds an uplifting force — ambition, wisdom, and energy reinforce each other. Leadership and authority are amplified in whatever period is running.",
  has_675: "The 6-7-5 combination in their chart means their lifestyle is resilient. Even in difficult periods, their standard of living holds and their social standing remains intact.",
  has_284: "The 2-8-4 Vipreet Raj combination in their chart means adversity is their teacher and eventually their throne. The difficult periods transform rather than defeat.",
  has_178: "The 1-7-8 combination gives they unusually high intuition — what they sense about situations and people is usually right. Trust it more than they currently do.",
  has_raj_yoga: "Raj Yoga in their chart means authority positions are their natural territory. Periods when 1 and 2 are both active bring the biggest career leaps.",
  has_easy_money: "Easy Money combination (5-7) means financial luck runs through their life. The money comes, sometimes from unexpected directions. The practice is keeping it.",
  has_bandhan: "Bandhan Yoga in their chart means certain periods will feel constricting. The way through is not force but navigation — understanding the constraint and working with it.",
  has_financial_bandhan: "Financial Bandhan in their chart means money management requires active discipline. Their natural tendency is to spend — building systems that spend for they (savings, investments) is the antidote.",
  has_spiritual_379: "The spiritual 3-7-9 triad means their deepest insights come from spiritual or philosophical engagement. Ignoring this dimension creates the instability; embracing it creates the clarity.",
  multiple_1_no_destiny: "Multiple 1s without destiny 1 in their chart means ambition runs high but recognition can feel elusive. The work is allowing others to lead sometimes — the ego fights it but the wisdom knows it.",
  multiple_2: "Multiple 2s in their chart means emotional sensitivity is their superpower and their vulnerability. Creative output is extraordinary. Emotional resilience requires active cultivation.",
  multiple_4_odd: "Odd multiple 4s in their chart amplify Rahu energy — unpredictability, financial impulsiveness, and illusion are heightened. Daily discipline is the antidote.",
  multiple_4_even: "Even multiple 4s in their chart transform Rahu's chaos into structure. Logical thinking, good planning, and purposeful travel become their strengths.",
  multiple_7: "Multiple 7s in their chart mean instability is a recurring theme — but so is luck. The anxiety is real; so is the resilience. Spiritual practice is not optional.",
  multiple_8_even: "Even multiple 8s in their chart mean Saturn's karma is working in their favor. Opportunities, achievements, and rewards come through persistence.",
  multiple_8_odd: "Odd multiple 8s in their chart mean Saturn's karma requires more work before it pays. The effort is not wasted — it's compounding.",
  multiple_9: "Multiple 9s in their chart mean frustration is a recurring companion. Physical activity, clear goals, and honest communication are the channels that make the Mars energy productive rather than destructive.",
};

// ─── The master prediction engine prompts ─────────────────────────────────────
// These are the instruction sets for how to COMBINE everything into one prediction
export const PREDICTION_LOGIC = {

  how_to_read_daily: `
    A daily prediction is the sum of:
    1. Basic number (WHO the person fundamentally is)
    2. Destiny number (WHERE they're headed, outer world influence)  
    3. Maha dasha (The dominant multi-year theme — like a season)
    4. Antar dasha (The year's specific chapter)
    5. Monthly dasha (This month's focus)
    6. Daily dasha (Today's energy — the day's specific frequency)
    7. Active yogas (The underlying combinations shaping everything)
    
    The daily number is not analyzed alone.
    It's read as: "Basic 5 + Destiny 4 + Maha 8 + Antar 7 + Monthly 7 + Daily 5"
    = Mercury sharpness running through Saturn discipline + double Ketu detachment
    = "A day of sharp thinking but emotional distance — excellent for analytical work,
       challenging for personal connection. The Saturn-Ketu energy wants they working
       quietly and seriously. Don't expect others to be emotionally available."
  `,

  how_to_read_hourly: `
    Hourly = Daily dasha + hour number
    The hour quality layers over the day quality.
    Best hours = when the hour number creates a positive combination with active dashas
    Caution hours = when the hour number creates Bandhan, Financial Bandhan, 
                    or amplifies an already challenging day energy
  `,

  how_to_classify_hours: `
    Given active chart (with all yogas and numbers):
    - BEST hours: Hours where number creates Easy Money (5-7), Raj Yoga (1-2), 
                  uplifting (1-9-3), or aligns with a positive active yoga
    - GOOD hours: Hours where number is compatible with day's energy  
    - CAUTION hours: Hours where number creates Bandhan (9-4 without 5),
                     Financial Bandhan (5-4 without 9), or Misfortune (7-8 without 1)
    - AVOID hours: Hours where number amplifies an already negative combination
  `,
};

export default {
  NUMBER_ENERGY,
  COMBINATION_MEANINGS,
  DASHA_COMBO_PREDICTIONS,
  DAILY_QUOTES,
  DAILY_GUIDANCE,
  HOUR_QUALITIES,
  COMBO_DAILY_INSIGHTS,
  PERIOD_PREDICTIONS,
  LIFE_PREDICTIONS,
  CHART_MODIFIERS,
  PREDICTION_LOGIC,
};
