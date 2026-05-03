// ═══════════════════════════════════════════════════════════════════════════════
// DAY DEFINITION LIBRARY
// 2-3 line day definition based on Maha + Daily combination
// Antar adds a flavor modifier at the end
// Formula: DAY_CORE[maha][daily] + ' ' + ANTAR_FLAVOR[antar]
// ═══════════════════════════════════════════════════════════════════════════════

// ── CORE DAY DEFINITIONS: Maha x Daily (81 combos) ───────────────────────────
export const DAY_CORE = {

  // ── MAHA 1 (SUN) ─────────────────────────────────────────────────────────
  '1_1': 'Authority meets authority. Recognition moves have maximum backing today. Leadership actions taken now carry lasting weight.',
  '1_2': 'Sun period softened by Moon day. Emotions are more active than usual. A good day for connecting, not commanding.',
  '1_3': 'Sun authority meets Jupiter wisdom. Ideal for teaching, advising, or making decisions that require both confidence and ethics.',
  '1_4': 'Sun clarity disrupted by Rahu day. Confusion and ego clashes likely. Verify before committing — nothing is as it appears today.',
  '1_5': 'Sun leadership + Mercury intelligence. Communication and negotiation carry authority. A sharp day for business decisions.',
  '1_6': 'Sun authority softened by Venus day. Charm and social grace are stronger than force today. Relationships respond well.',
  '1_7': 'Sun meets Ketu luck. Unexpected recognition or breakthrough possible. Trust your instincts over logic today.',
  '1_8': 'Sun ambition meets Saturn patience. Hard work is required — results come, but slowly. Discipline produces more than urgency.',
  '1_9': 'Sun authority + Mars energy. Leadership peaks. Bold action gets results. Guard against ego-driven aggression.',

  // ── MAHA 2 (MOON) ────────────────────────────────────────────────────────
  '2_1': 'Moon sensitivity sharpened by Sun day. Visibility increases — be mindful of what you project publicly today.',
  '2_2': 'Double Moon. Emotional depth at maximum. Creative and intuitive power is high. Mental health requires gentle attention.',
  '2_3': 'Moon creativity meets Jupiter wisdom. A nourishing, spiritually rich day. Family and learning both flourish.',
  '2_4': 'Moon emotions disrupted by Rahu. Instability and confusion in feelings. Do not make permanent decisions under today\'s energy.',
  '2_5': 'Moon sensitivity + Mercury quickness. Thoughts and feelings are equally active. Writing and expression come naturally.',
  '2_6': 'Double soft energy — Moon and Venus. Romantic, creative, and socially warm. A day for connection over productivity.',
  '2_7': 'Moon intuition meets Ketu luck. Psychic sensitivity is high. What you feel deeply is accurate — trust it today.',
  '2_8': 'Moon emotions meet Saturn weight. A heavy emotional load is possible. Routine and structure are medicine today.',
  '2_9': 'Moon sensitivity meets Mars aggression. Emotional reactivity peaks. Channel this intensity into creation, not conflict.',

  // ── MAHA 3 (JUPITER) ─────────────────────────────────────────────────────
  '3_1': 'Jupiter wisdom amplified by Sun authority. Teaching, leadership, and ethical decisions carry maximum power today.',
  '3_2': 'Jupiter morality meets Moon feeling. A day of deep family connection and spiritual reflection. Advice given today lands well.',
  '3_3': 'Double Jupiter. Wisdom and generosity at peak. Spiritual insights, philosophical clarity, and genuine guidance emerge.',
  '3_4': 'Jupiter ethics disrupted by Rahu confusion. Guard against spiritual arrogance or being misled by appearances today.',
  '3_5': 'Jupiter wisdom + Mercury business acumen. Learning, teaching, and financial planning all benefit from today\'s clarity.',
  '3_6': 'Jupiter expansion meets Venus beauty. Generosity and creativity combine. A good day for artistic or family investments.',
  '3_7': 'Jupiter meets Ketu\'s spiritual depth. Profound insights emerge. Meditation, study, and prayer produce unusually clear answers.',
  '3_8': 'Jupiter growth slowed by Saturn discipline. Long-term planning is favored over quick expansion. Patience is today\'s teacher.',
  '3_9': 'Jupiter wisdom + Mars action. Principled ambition. Projects launched today with both courage and integrity tend to succeed.',

  // ── MAHA 4 (RAHU) ────────────────────────────────────────────────────────
  '4_1': 'Rahu illusion + Sun ego. A dangerous combination for overconfidence. Double-check everything before acting today.',
  '4_2': 'Rahu confusion + Moon sensitivity. Emotional decisions feel right but may not be. Seek a trusted opinion before committing.',
  '4_3': 'Rahu disruption meets Jupiter wisdom. Some clarity is possible through study or guidance. Avoid shortcuts and speculation.',
  '4_4': 'Double Rahu. Maximum confusion, instability, and deception risk. This is a day to observe, not to act or decide.',
  '4_5': 'Rahu chaos + Mercury intelligence. Sharp thinking cuts through confusion today. Research carefully — then act with precision.',
  '4_6': 'Rahu illusion meets Venus desire. Romantic or financial temptations feel real but may be misleading. Proceed with caution.',
  '4_7': 'Rahu disruption + Ketu luck. An unusual day — sudden clarity or sudden confusion. Trust gut over logic, verify before trusting.',
  '4_8': 'Rahu confusion + Saturn delays. Nothing moves easily today. The best action is maintaining, not building.',
  '4_9': 'HIGHEST RISK COMBINATION. Rahu + Mars daily = maximum accident and impulsive decision risk. Slow down in everything today.',

  // ── MAHA 5 (MERCURY) ─────────────────────────────────────────────────────
  '5_1': 'Mercury intelligence + Sun authority. Business decisions made with confidence today tend to stick. Communication commands respect.',
  '5_2': 'Mercury sharp mind softened by Moon day. Intuitive business thinking — balance analysis with gut feeling today.',
  '5_3': 'Mercury business + Jupiter wisdom. Ideal for negotiations, educational investments, and long-term financial planning.',
  '5_4': 'Mercury clarity disrupted by Rahu. Information may be incomplete or misleading. Verify all sources before deciding.',
  '5_5': 'Double Mercury. Commercial instinct at peak. Multiple opportunities appear. Guard against overcommitment and scattered focus.',
  '5_6': 'Mercury + Venus. Business meets relationships. Financial discussions in personal contexts go well. Partnerships benefit today.',
  '5_7': 'Easy Money yoga activated. Mercury intelligence + Ketu luck = financial gains arrive with less effort. Act on what presents itself.',
  '5_8': 'Mercury plans + Saturn patience. Excellent for detailed work, financial planning, and systematic progress — not quick wins.',
  '5_9': 'Mercury speed + Mars energy. Fast decisions, fast movement. Results come quickly — and so do mistakes. Stay focused.',

  // ── MAHA 6 (VENUS) ───────────────────────────────────────────────────────
  '6_1': 'Venus beauty meets Sun authority. Public image and professional relationships both benefit. A day for visible, graceful leadership.',
  '6_2': 'Venus + Moon. Double softness. Romantic, creative, and emotionally rich. A day for connection, art, and genuine care.',
  '6_3': 'Venus pleasure meets Jupiter wisdom. A day of refined generosity — give and create with intention.',
  '6_4': 'Venus desires + Rahu illusion. Romantic or financial temptations may not deliver what they promise. Caution before commitment.',
  '6_5': 'Venus + Mercury. Business through relationships. Charming communication opens doors. Partnerships and deals benefit today.',
  '6_6': 'Double Venus. Maximum comfort-seeking, beauty appreciation, and relationship focus. High risk of overindulgence.',
  '6_7': 'Venus luck + Ketu ease. Things fall into place without forcing. A good day to let events unfold rather than push.',
  '6_8': 'Venus comfort meets Saturn discipline. Real relationships deepen through commitment today. Superficial ones reveal themselves.',
  '6_9': 'Venus warmth + Mars drive. Passionate energy — romantic, creative, or combative depending on how it is channeled.',

  // ── MAHA 7 (KETU) ────────────────────────────────────────────────────────
  '7_1': 'Ketu detachment meets Sun authority. Leadership through wisdom rather than force is favored. Recognition comes unexpectedly.',
  '7_2': 'Ketu spiritual depth + Moon sensitivity. Intuition is at its clearest. Deep emotional truths surface — be ready to receive them.',
  '7_3': 'Ketu wisdom + Jupiter guidance. Profound spiritual insights. A day for study, prayer, and receiving wisdom from elders.',
  '7_4': 'Ketu + Rahu. A karmic, unpredictable day. Sudden reversals, unexpected events. Stay grounded and avoid major decisions.',
  '7_5': 'Ketu ease + Mercury intelligence. Analytical clarity arrives effortlessly today. Solutions to complex problems surface naturally.',
  '7_6': 'Ketu luck + Venus ease. Things fall into place. Financial and romantic situations resolve with minimal effort today.',
  '7_7': 'Double Ketu. Maximum spiritual depth and detachment from material concerns. Meditation and inner work produce breakthroughs.',
  '7_8': 'Ketu luck meets Saturn discipline. Progress requires effort, but the direction is clear. Steady action produces lasting results.',
  '7_9': 'Ketu spiritual depth + Mars energy. Bold spiritual action is favored. Teaching, protecting, or standing for principles works well.',

  // ── MAHA 8 (SATURN) ──────────────────────────────────────────────────────
  '8_1': 'Saturn discipline meets Sun authority. Hard-earned recognition arrives. Leadership through consistency, not shortcuts.',
  '8_2': 'Saturn weight + Moon sensitivity. Emotional heaviness is possible. Routine, movement, and connection are the medicine today.',
  '8_3': 'Saturn patience + Jupiter wisdom. A day of ethical clarity. Long-term plans made today are built to last.',
  '8_4': 'Saturn delays + Rahu confusion. Total stagnation possible. Hold the line without breaking — this period passes.',
  '8_5': 'Saturn discipline + Mercury intelligence. Detailed analytical work, systematic planning, and careful decisions all benefit.',
  '8_6': 'Saturn commitment meets Venus comfort. Real progress in relationships requires sacrifice today. Genuine values clarify.',
  '8_7': 'Saturn discipline + Ketu ease. Effort is rewarded with unexpected results. What feels hard actually moves faster than expected.',
  '8_8': 'Double Saturn. Maximum karmic weight, discipline, and patience required. Character is being forged. Do not break.',
  '8_9': 'Saturn endurance + Mars energy. Immense work capacity today. Physical effort compounds. Guard health — rest is strategic.',

  // ── MAHA 9 (MARS) ────────────────────────────────────────────────────────
  '9_1': 'Mars courage + Sun authority. Leadership peaks. Confidence is contagious. Guard against ego — results speak louder.',
  '9_2': 'Mars aggression meets Moon sensitivity. Emotional intensity is high. Creative output absorbs this energy productively.',
  '9_3': 'Mars action + Jupiter wisdom. Principled ambition. Start what requires both courage and ethics today.',
  '9_4': 'HIGHEST RISK. Mars daily + Rahu maha = maximum accident and impulsive decision risk. Every physical movement needs caution.',
  '9_5': 'Mars speed + Mercury intelligence. Fast thinking, fast results. Multiple tasks move simultaneously. Guard against overcommitment.',
  '9_6': 'Mars ambition meets Venus relationships. Career and romance both active. Passionate energy — channel it into creation.',
  '9_7': 'Mars action + Ketu ease. Work feels aligned today. Effort produces more than expected. A good day to push forward.',
  '9_8': 'Mars determination + Saturn patience. Heavy load but clear direction. Persistence today builds something that lasts.',
  '9_9': 'Double Mars. Maximum energy, boldness, and anger risk. Channel into physical work or structured ambition. Conflict is costly.',
};

// ── ANTAR FLAVOR: Adds 1 line about the current chapter (81 combos) ──────────
export const ANTAR_FLAVOR = {
  // Antar 1 (Sun)
  '1_in_1': 'Recognition and visibility are the theme of this chapter.',
  '1_in_2': 'Authority is being built through emotional intelligence right now.',
  '1_in_3': 'Leadership through wisdom is the calling of this chapter.',
  '1_in_4': 'Clarity is hard to find in this chapter — patience before acting.',
  '1_in_5': 'Business authority is this chapter\'s gift.',
  '1_in_6': 'Visible confidence in relationships defines this period.',
  '1_in_7': 'Recognition arrives through spiritual or intuitive channels now.',
  '1_in_8': 'Authority earned through discipline — this chapter rewards consistency.',
  '1_in_9': 'Bold leadership defines this chapter.',
  // Antar 2 (Moon)
  '2_in_1': 'Emotional sensitivity is heightened throughout this period.',
  '2_in_2': 'Deep emotional processing is the work of this chapter.',
  '2_in_3': 'Creativity and family connection are central to this period.',
  '2_in_4': 'Emotional instability is a real risk — ground yourself daily.',
  '2_in_5': 'Intuitive business decisions characterize this chapter.',
  '2_in_6': 'Romantic and emotional depth define this period.',
  '2_in_7': 'Intuition is at its sharpest throughout this chapter.',
  '2_in_8': 'Emotional weight requires consistent routine during this period.',
  '2_in_9': 'Emotional intensity runs high — creative output is the outlet.',
  // Antar 3 (Jupiter)
  '3_in_1': 'Wisdom and learning are central to this chapter.',
  '3_in_2': 'Family bonds and spiritual growth define this period.',
  '3_in_3': 'Philosophical depth and moral clarity are this chapter\'s gifts.',
  '3_in_4': 'Guard against spiritual shortcuts in this chapter.',
  '3_in_5': 'Education and financial wisdom are this period\'s focus.',
  '3_in_6': 'Generosity and creative expansion define this chapter.',
  '3_in_7': 'Profound spiritual insight is available throughout this period.',
  '3_in_8': 'Patient wisdom — this chapter rewards those who build slowly.',
  '3_in_9': 'Principled action and ethical ambition drive this chapter.',
  // Antar 4 (Rahu)
  '4_in_1': 'Unexpected disruptions test clarity throughout this chapter.',
  '4_in_2': 'Emotional confusion is a recurring theme — trust slowly.',
  '4_in_3': 'Illusions around beliefs and guidance — verify sources.',
  '4_in_4': 'Maximum confusion — the most important rule is: do not rush.',
  '4_in_5': 'Business opportunities appear and disappear quickly in this chapter.',
  '4_in_6': 'Romantic and financial illusions are the trap of this period.',
  '4_in_7': 'Sudden reversals and unexpected breakthroughs both happen now.',
  '4_in_8': 'Stagnation and confusion — hold steady without panicking.',
  '4_in_9': 'Impulsive action in this chapter has outsized consequences.',
  // Antar 5 (Mercury)
  '5_in_1': 'Business intelligence is this chapter\'s primary asset.',
  '5_in_2': 'Intuitive financial decisions characterize this period.',
  '5_in_3': 'Learning, communication, and smart planning define this chapter.',
  '5_in_4': 'Information overload is a real risk — filter carefully.',
  '5_in_5': 'Commercial instinct at peak — multiple streams are possible.',
  '5_in_6': 'Partnerships and financial relationships are this chapter\'s focus.',
  '5_in_7': 'Easy gains through intelligence — this chapter rewards clarity.',
  '5_in_8': 'Systematic financial planning defines this period.',
  '5_in_9': 'Fast decisions drive this chapter — accuracy matters more than speed.',
  // Antar 6 (Venus)
  '6_in_1': 'Relationships and beauty are central to this chapter.',
  '6_in_2': 'Deep romantic and creative connection defines this period.',
  '6_in_3': 'Generous, beautiful expansion — this chapter rewards giving.',
  '6_in_4': 'Romantic illusions are this chapter\'s primary risk.',
  '6_in_5': 'Financial and romantic partnerships are this period\'s focus.',
  '6_in_6': 'Maximum Venus energy — comfort-seeking and relationship depth.',
  '6_in_7': 'Things flow without force in this chapter — ease is real.',
  '6_in_8': 'Commitment deepens relationships in this chapter.',
  '6_in_9': 'Passionate intensity in relationships defines this period.',
  // Antar 7 (Ketu)
  '7_in_1': 'Unexpected recognition arrives through this chapter.',
  '7_in_2': 'Spiritual intuition is the dominant gift of this period.',
  '7_in_3': 'Profound wisdom surfaces through silence and study.',
  '7_in_4': 'Unpredictable and karmic — this chapter requires surrender.',
  '7_in_5': 'Effortless clarity and financial ease characterize this period.',
  '7_in_6': 'Luck flows in romantic and financial matters throughout.',
  '7_in_7': 'Maximum spiritual depth and material detachment — inner work pays.',
  '7_in_8': 'Steady effort produces unexpectedly good results in this chapter.',
  '7_in_9': 'Bold spiritual action is rewarded throughout this period.',
  // Antar 8 (Saturn)
  '8_in_1': 'Hard work is building lasting authority during this chapter.',
  '8_in_2': 'Emotional discipline is the work of this Saturn chapter.',
  '8_in_3': 'Patient wisdom and ethical building define this period.',
  '8_in_4': 'Maximum karmic weight — do not force what resists.',
  '8_in_5': 'Systematic, disciplined financial building defines this chapter.',
  '8_in_6': 'Real commitment is tested and strengthened in this period.',
  '8_in_7': 'Effort produces more than expected — Saturn with Ketu ease.',
  '8_in_8': 'Double Saturn chapter — the deepest karmic lessons are active.',
  '8_in_9': 'Immense capacity for work — rest is not weakness in this chapter.',
  // Antar 9 (Mars)
  '9_in_1': 'Bold leadership defines this chapter.',
  '9_in_2': 'Emotional intensity runs through this entire period.',
  '9_in_3': 'Principled ambition drives this chapter forward.',
  '9_in_4': 'Maximum impulsive risk — every decision needs deliberate thought.',
  '9_in_5': 'Fast movement and quick results characterize this chapter.',
  '9_in_6': 'Passionate energy in relationships and work defines this period.',
  '9_in_7': 'Action aligned with purpose — results come faster than expected.',
  '9_in_8': 'Relentless persistence builds the foundation in this chapter.',
  '9_in_9': 'Maximum Mars energy throughout — channel or combust.',
};

// ── Main function: get 2-3 line day definition ────────────────────────────────
export function getDayDefinition(maha, antar, daily) {
  const core = DAY_CORE[`${maha}_${daily}`] || 
    `${maha} Maha + ${daily} Daily energy active. Read the day carefully.`;
  
  const flavor = ANTAR_FLAVOR[`${antar}_in_${maha}`] ||
    ANTAR_FLAVOR[`${antar}_in_5`] || // fallback
    '';
  
  return flavor ? `${core} ${flavor}` : core;
}
