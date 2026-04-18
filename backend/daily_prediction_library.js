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
export const BASIC_DAILY_GUIDANCE = {
  // Basic 1 (Sun natal)
  1: {
    1: { do: ["Lead on the thing you've been hesitating about — today you have full authority backing", "Make the career move or important ask you've been postponing", "Be visible — today is the day to be seen doing the right thing"], avoid: ["Letting confidence tip into arrogance — others are watching how you handle the power", "Starting unnecessary battles — save the courage for what matters", "Making unilateral decisions that affect others without consulting them"] },
    2: { do: ["Soften the authority into genuine connection today — your people need you present, not just powerful", "Have the honest personal conversation you've been avoiding", "Create something — your artistic output is surprisingly strong today"], avoid: ["Coldness or detachment — Moon day asks for warmth from you specifically", "Major financial decisions — your judgment is emotionally colored today", "Ignoring the emotional undercurrent of whatever situation you're in"] },
    3: { do: ["Make the strategic long-term decision that requires both boldness and wisdom", "Seek out the person whose judgment you respect and have the real conversation", "Plan the next significant move — today your planning is sound and your nerve is steady"], avoid: ["Ethical shortcuts — Jupiter day amplifies the consequences for you specifically", "Moving fast on things that need more thought", "Dismissing advice from people who know more about specific domains"] },
    4: { do: ["Research the thing you've been assuming about — today the investigation is sharp", "Let the disruption redirect rather than resist it — something better is coming", "Ask the unconventional question that breaks the stalemate"], avoid: ["Financial commitments of any size today — Rahu disrupts your Sun natal in specific ways", "Trusting first impressions — verify before deciding", "Acting on the confidence today — it's partially Rahu talking"] },
    5: { do: ["Make the bold business or financial decision — Mercury day activates your Sun authority", "Negotiate from strength — you're unusually persuasive today", "Close the thing that's been dragging"], avoid: ["Letting others' hesitation become your hesitation", "Cold efficiency that alienates people you need later", "Moving so fast you miss the detail that matters"] },
    6: { do: ["Express genuine appreciation to someone who has been holding something together for you", "Invest in beauty — your environment, your presentation, your experience", "Lead with warmth today — it lands more powerfully than authority"], avoid: ["Harsh words when you're frustrated — Sun + Venus day means you'll be quoted", "Overspending on experiences justified by your position", "Confusing what's attractive with what's right"] },
    7: { do: ["Trust the instinct on the important decision even if the analysis doesn't fully support it", "Make the bold ask — luck is backing your Sun energy today", "Take the meeting or conversation you almost cancelled"], avoid: ["Overthinking the opportunity until it passes", "Forcing the outcome you want when something better is trying to arrive", "Ignoring the gut read on the person or situation"] },
    8: { do: ["Do the hard sustained work that only you can do today", "Complete what was started — your follow-through today has unusual power", "Build the system or structure that the long-term requires"], avoid: ["Expecting recognition today — it comes through the effort, not from announcing it", "Shortcuts on anything that has your name on it", "Letting impatience override the timing"] },
    9: { do: ["Make the courageous bold move — full Sun authority plus Mars energy", "Physical activity — the body is running strong today", "Confront the thing you've been avoiding — you have both the energy and the nerve today"], avoid: ["Picking unnecessary fights — the power is real, the justification for fighting is often not", "Recklessness disguised as boldness", "Burning bridges in the heat of the moment"] },
  },

  // Basic 2 (Moon natal)
  2: {
    1: { do: ["Lead with emotional intelligence today — your natural attunement makes your authority land differently than others'", "Have the honest conversation about what you actually need", "Make the one bold move you've been preparing emotionally for"], avoid: ["Suppressing your emotional read to seem more 'authority-like'", "Letting someone else's confidence override your instinct", "Taking on leadership responsibilities that deplete your emotional reserves"] },
    2: { do: ["Create — today's double Moon energy is extraordinary for artistic and emotional output", "Reach out to the person you've been thinking about", "Go deep in the conversation that matters most"], avoid: ["Major financial decisions — double Moon means emotional coloring of everything practical", "Isolating — today's energy needs expression not containment", "Absorbing others' problems as your own responsibility"] },
    3: { do: ["Seek the wise counsel you've been avoiding asking for", "Give advice from genuine experience — it lands with unusual depth today", "Write something honest — the words are clear today"], avoid: ["Emotional decisions that bypass your own wisdom", "Holding others to emotional standards you haven't communicated", "Over-giving to people who haven't shown they deserve it"] },
    4: { do: ["Let today's disruption surface what you've been feeling but not saying", "Research the situation that's been making you anxious — knowing beats not knowing", "Find the creative angle that the conventional approach misses"], avoid: ["Financial decisions today — Moon + Rahu is the most emotionally reactive combination for financial matters", "Trusting the heightened emotional sensitivity as fact — it's information, not conclusion", "Making relationship decisions based on today's heightened feelings"] },
    5: { do: ["Communicate what you've been feeling with unusual clarity today", "The financial decision that requires emotional intelligence to make well — today is the day", "Write, present, or pitch with genuine heart — it works today"], avoid: ["Letting Mercury's coldness suppress your Moon warmth — you need both", "Overthinking what your feelings are telling you clearly", "Financial moves that ignore the emotional cost"] },
    6: { do: ["Invest in the relationship that deserves investment — today it lands completely", "Create something beautiful — double creative energy available", "Express genuine appreciation to someone who has been showing up for you"], avoid: ["Harsh words when disappointed — Moon + Venus means they cut deeper than usual and last longer", "Over-spending on the feeling of luxury rather than genuine quality", "Losing yourself in caring for others while neglecting your own emotional needs"] },
    7: { do: ["Trust the psychic read you're getting on the situation — it's accurate today", "Follow the intuition that has been persistent even when logic disagrees", "Allow the fortunate thing that wants to arrive — stop managing it"], avoid: ["Confusing anxiety with intuition — they feel similar and are different", "Making major decisions from the heightened sensitivity", "Disappearing when what's needed is presence"] },
    8: { do: ["Do the emotional work you've been avoiding — today's Saturn energy gives it structure", "Show up for the person who needs you without making it about your own emotional state", "Complete the creative project — persistence today has unusual reward"], avoid: ["Expecting today's effort to produce today's result — it compounds later", "Emotional heaviness becoming withdrawal rather than processing", "Taking on others' emotional burdens as your ongoing responsibility"] },
    9: { do: ["Channel the Mars energy into physical expression — Moon + Mars needs a body outlet", "Have the passionate honest conversation that needs having", "Protect something or someone that genuinely deserves protection today"], avoid: ["Explosive emotional responses — Moon + Mars is the most volatile combination for you", "Arguments that don't need having", "Physical recklessness — the energy is high and the Moon natals are accident-prone on 9 days"] },
  },

  // Basic 3 (Jupiter natal)
  3: {
    1: { do: ["Make the principled bold move — your wisdom + Sun authority day is genuinely powerful", "Lead from ethics and knowledge — the combination is rare and people follow it", "Make the institutional or career move that requires both courage and integrity"], avoid: ["Ego-driven decisions dressed up as principled ones — you can tell the difference", "Moving faster than your wisdom supports", "Compromising the standard for expediency"] },
    2: { do: ["Advise from the heart today — wisdom + Moon = the rare combination of true and kind", "Listen with your full attention to the person in front of you", "Creative work that requires both craft and genuine feeling"], avoid: ["Judgment dressed as concern — Moon day makes it land harder than intended", "Emotional decisions that bypass your own sound judgment", "Holding the emotional standard too high for where someone actually is"] },
    3: { do: ["Double Jupiter — the clearest thinking and most sound judgment available", "Make the important long-term decision you've been considering", "Plan, write, or advise — today's output will hold"], avoid: ["Moral rigidity that prevents genuine connection", "Being right in a way that wins the argument and loses the relationship", "Over-seriousness — double Jupiter can forget that joy is also wisdom"] },
    4: { do: ["Apply your wisdom to the disruptive situation — your judgment stabilizes what Rahu unsettles", "Research the unconventional angle — today you can evaluate it clearly", "Ask the question that breaks the impasse"], avoid: ["Financial decisions — even your Jupiter wisdom is disrupted by Rahu today", "Trusting the confident-seeming instinct without verification", "Letting Rahu's chaos override your grounded perspective"] },
    5: { do: ["Expert advisory work — your wisdom + Mercury commercial day is extraordinarily valuable", "The knowledge-to-income conversion: teach, consult, advise for compensation", "Write the strategic document — it's both smart and sound today"], avoid: ["Ethical shortcuts for commercial convenience — Jupiter natal makes the cost permanent", "Giving away expertise for free when it has genuine market value", "Mercury's speed overriding Jupiter's depth"] },
    6: { do: ["Advise on the relationship or creative matter — your wisdom + Venus harmony = rare clarity", "Invest in beauty with genuine discernment today", "The creative project that requires both craft and values"], avoid: ["3 holding 6-day beauty to ethical standards that miss the point", "Sacrificing quality for conventional 'wisdom'", "Being too serious on a day that rewards presence and warmth"] },
    7: { do: ["Trust the philosophical direction that's been clarifying — today it arrives with more certainty", "The wise intuitive decision — Jupiter wisdom + Ketu luck = sound AND fortunate", "The journey, conversation, or pursuit that has genuine depth"], avoid: ["Overthinking the fortunate thing that's trying to arrive", "Ketu's instability being mistaken for wisdom's uncertainty", "Holding back from the lucky opportunity because it wasn't planned"] },
    8: { do: ["Saturn day activates your Jupiter karma in the best way — long-term principled work", "The ethical difficult thing you've been avoiding — today it has full support", "Build something that will outlast the current moment"], avoid: ["Shortcuts — Jupiter + Saturn day means the karma runs in both directions today", "Heavy-handedness in the name of principle", "Expecting others to share your tolerance for sustained effort"] },
    9: { do: ["Stand for something — Jupiter wisdom + Mars courage is the principled bold action combination", "The advocacy, the ethical confrontation, the thing that required both knowledge and nerve", "Physical activity that also serves a purpose beyond itself"], avoid: ["Anger overriding the wisdom — Mars energy is available AND it bypasses judgment easily today", "Self-righteousness dressed as courage", "9's aggression misusing Jupiter's certainty"] },
  },

  // Basic 4 (Rahu natal)
  4: {
    1: { do: ["The unconventional bold move — your Rahu native + Sun authority = unexpectedly powerful leadership today", "Research the authority situation before acting — today you can see it clearly", "The creative leadership angle that others haven't considered"], avoid: ["Overconfident financial moves — Rahu natal + Sun day creates an inflated sense of certainty", "Acting on the authority feeling without verification", "Burning bridges in the name of bold action"] },
    2: { do: ["Creative work is extraordinary today — Rahu's originality + Moon's depth", "The emotionally honest creative project", "Reach out to the unconventional collaboration"], avoid: ["Financial decisions today — double Rahu influence on finances is significant", "Emotional decisions that feel certain — they aren't", "Taking on others' instability as your responsibility"] },
    3: { do: ["Let Jupiter's wisdom evaluate your unconventional instinct today — the combination is unusually good", "Research before the wise person advises you to research — you're ahead of it today", "The problem that requires original thinking plus sound judgment"], avoid: ["Rahu's impatience overriding Jupiter day's call for wisdom", "Committing to unverified plans even when they feel right", "Financial decisions — even when Jupiter day seems to support them"] },
    4: { do: ["Double Rahu — extraordinary original thinking and research ability today", "Investigate the thing that doesn't add up — today you'll find what's there", "Generate the ideas freely — something genuinely valuable is in the stream today"], avoid: ["Any financial commitment today — double Rahu makes this the highest-risk financial day", "Acting on the brilliant feeling without verification", "Trusting first impressions on anything important"] },
    5: { do: ["The original commercial insight — Rahu's angle + Mercury's sharpness", "Research the financial opportunity before committing", "The communication that breaks convention usefully"], avoid: ["Financial commitments today — Mercury day's confidence + Rahu natal = overconfident", "Impulsive purchases justified as investments", "Moving without verification on what feels like a sure thing"] },
    6: { do: ["The unexpected beauty — Rahu originality + Venus day = genuinely surprising creative output", "The unconventional social connection that opens something", "Create without the conventional rules today — it works"], avoid: ["Financial decisions through aesthetic or relational channels today", "Trusting the attractive new person or opportunity without checking", "Over-spending on the feeling of beauty rather than its substance"] },
    7: { do: ["Two seeking energies running — the depth available today is genuine and rare", "Trust the instinct that has been persistent across multiple days", "The spiritual or philosophical direction that's been calling"], avoid: ["Neither Rahu nor Ketu is grounded — practical decisions should wait for a more stable day", "Double shadow planet energy means the intuition is both heightened AND unreliable", "Financial decisions absolutely — this is the least reliable financial day"] },
    8: { do: ["Saturn day provides the rare grounding your Rahu natal needs", "The methodical research project — today you can actually finish it", "The disciplined approach to the creative work"], avoid: ["Rahu's impatience fighting Saturn's timing — Saturn wins but Rahu makes the conflict painful", "Shortcuts — they cost more when Rahu natal meets Saturn day", "Rushing what Saturn day is asking to be done properly"] },
    9: { do: ["Physical activity — Mars day channels Rahu's energy productively", "The bold unconventional move that requires both nerve and originality", "The physical outlet for the energy that would otherwise become anxiety or impulsiveness"], avoid: ["Joint legal or financial decisions today — this is the highest risk combination for both", "Anger-driven decisions — Rahu + Mars day is explosive", "Aggressive driving, physical recklessness, confrontational behavior"] },
  },

  // Basic 5 (Mercury natal)
  5: {
    1: { do: ["Make the bold business or financial decision — Mercury natal + Sun authority day", "Negotiate from strength — you're at your most persuasive", "The career move that requires both commercial intelligence and confidence"], avoid: ["Cold efficiency that damages relationships you'll need", "Moving so fast you miss the detail that changes the analysis", "Ego-driven decisions dressed as strategic ones"] },
    2: { do: ["Communicate what you've been calculating but not saying — today it lands", "The creative project that requires both emotional truth and commercial intelligence", "Reach out to the person who combines emotional and business relevance"], avoid: ["Treating emotional information as a calculation problem — Moon day specifically resists this", "Making financial decisions from emotional reasoning", "Missing the human element in a situation that's asking for it"] },
    3: { do: ["Expert advisory work — Mercury intelligence + Jupiter wisdom day", "The strategic document or plan — sharp AND sound today", "Teach or consult on something that genuinely has both depth and commercial value"], avoid: ["Mercury's speed overriding Jupiter's call for depth and consideration", "Ethical shortcuts in commercial contexts — Jupiter day tracks them", "Over-explaining what only needs to be said once"] },
    4: { do: ["Research the financial opportunity before acting on it — today your analytical ability is sharp enough to see what's real", "The commercial investigation — you can find the angle others miss today", "Ask the question that breaks the conventional analysis open"], avoid: ["Financial commitments today — Mercury natal + Rahu day is high financial risk", "Trusting confident analysis that hasn't been externally verified", "Impulsive business decisions that feel analytically sound"] },
    5: { do: ["Double Mercury — the sharpest financial and commercial day of the current cycle", "Make the most important financial or business decision today", "The negotiation, the deal, the pitch — all at maximum today"], avoid: ["Overthinking past the action window — the analysis is done, act on it", "Anxiety masquerading as due diligence", "Letting the sharp mind find problems with the good decision"] },
    6: { do: ["The commercial creative project — Mercury intelligence + Venus beauty day", "Present or pitch the beautiful idea — it works today", "The aesthetic investment that also has financial logic"], avoid: ["Over-spending on luxury justified as investment", "Venus day indulgence vs Mercury natal's financial responsibility — one must win", "Cold commercial optimization of something that needs warmth today"] },
    7: { do: ["Act on the financial opportunity — Mercury + Ketu = Easy Money combination", "The business decision that requires both intelligence and instinct — today both are available", "Trust the read on the commercial situation even without full data"], avoid: ["Letting analysis delay the fortunate opportunity past the window", "Saving everything that luck brings — Easy Money tendency is to cycle through", "Overthinking what the instinct is showing clearly"] },
    8: { do: ["Methodical financial planning — Mercury precision + Saturn discipline", "The long-term financial move that requires both analysis and patience", "Build the financial system or structure that compounds over time"], avoid: ["Mercury's speed versus Saturn day's requirement for deliberateness — coordinate before acting", "Shortcuts in financial planning", "Expecting the methodical financial decision to produce immediate results"] },
    9: { do: ["The competitive business move — Mercury intelligence + Mars courage", "Close the negotiation that requires both sharpness and nerve", "The bold commercial decision that others hesitate on"], avoid: ["5's tongue combined with 9's energy can be cutting in ways that damage permanent relationships", "Competitive instinct overriding commercial judgment", "Reckless financial boldness disguised as street smarts"] },
  },

  // Basic 6 (Venus natal)
  6: {
    1: { do: ["Lead with grace and warmth — your Venus natal + Sun authority day is unusually magnetic", "The public-facing or social leadership move", "Express appreciation to the person who has been carrying something for you"], avoid: ["Authority that crowds out beauty and warmth — Sun day can make 6 natals heavy-handed", "Harsh reactions when your standard isn't met — today they'll be remembered", "Prioritizing visibility over the genuine moment in front of you"] },
    2: { do: ["Double Venus/Moon creative energy — the most beautiful creative output of the cycle", "Express what's genuinely felt — today the words are as beautiful as the feeling", "The romantic or deeply personal investment that has been waiting"], avoid: ["Financial decisions made from romantic or aesthetic feeling", "Harsh words when disappointed — double sensitivity means double damage today", "Losing yourself in someone else's emotional needs"] },
    3: { do: ["The beautiful and principled creative decision — Venus + Jupiter = values-aligned aesthetic", "Advise on the relationship or creative matter with genuine wisdom", "The creative work that has both beauty and substance"], avoid: ["3's standards making 6's beauty feel judged rather than appreciated — adjust the register", "Over-seriousness on a day that needs warmth and creative play", "Sacrificing aesthetic quality for conventional wisdom"] },
    4: { do: ["The unexpected beautiful thing — Rahu's originality working with your Venus sensibility", "The unconventional social connection that opens a creative door", "Create without the conventional rules today"], avoid: ["Financial decisions through relationship or aesthetic channels today", "Trusting the attractiveness of a new person or opportunity without verification", "Rahu's financial disruption + Venus natal's spending impulse — high risk combination"] },
    5: { do: ["The commercial creative project — Mercury business day + Venus aesthetic sensibility", "Present the beautiful thing with commercial intelligence backing it", "The aesthetic investment that also makes financial sense"], avoid: ["Venus overspending + Mercury's commercial justification for it — both voices say yes today", "Pure commercial optimization of something that needs warmth and beauty", "Over-spending justified as aesthetic investment"] },
    6: { do: ["Double Venus — maximum creative, social, and romantic energy today", "The most important creative or romantic expression of the current period", "Say what deserves to be said — today it lands with complete beauty"], avoid: ["Words said in frustration today will outlast the reason for them — by months", "Over-spending on aesthetics and experience", "Using beauty as armor rather than expression"] },
    7: { do: ["The beautiful lucky thing — Ketu fortune + Venus aesthetic = rare combination", "The social or romantic risk that fortune is backing today", "Follow the beautiful instinct even when the logic isn't complete"], avoid: ["7's detachment and 6's need for appreciation are in conflict today — one must give", "Over-complicating a moment that wants to be simple and beautiful", "Forcing the outcome when fortune prefers to deliver it"] },
    8: { do: ["The creative work that requires sustained effort — today it shows results", "The beautiful long-term project that has been built piece by piece", "Earned beauty rather than acquired beauty — today the distinction matters"], avoid: ["6 natal's spending impulse + 8 day's heaviness = unsatisfied purchases", "Indulgence before the work is done", "Beauty as compensation for the emotional weight of Saturn day"] },
    9: { do: ["Passionate creative work — Mars energy + Venus aesthetic = extraordinary output", "The romantic investment that requires genuine courage", "Physical expression of the creative impulse"], avoid: ["Harsh words when frustrated — 9 day energy + 6 natal tongue = the most cutting combination", "Passion tipping into aggression in a context that needs beauty", "Dramatic emotional moves that damage what was carefully built"] },
  },

  // Basic 7 (Ketu natal)
  7: {
    1: { do: ["The bold move that your luck has been setting up — Sun authority + Ketu fortune", "Act on the instinct that has been building — today is the day it converts", "The leadership move that requires both courage and luck"], avoid: ["Overthinking the fortunate opportunity until the window closes", "Sun day's authority crowding out Ketu natal's quiet luck — let both operate", "Forcing visibility when today's luck prefers a more subtle entry"] },
    2: { do: ["Psychic-level attunement available today — the reads are accurate, act on them", "The deep intuitive creative work", "The conversation that has been waiting for the right unspoken alignment"], avoid: ["Moon day's emotional sensitivity + Ketu detachment = unpredictable emotional state — navigate carefully", "Major decisions from the heightened emotional sensitivity", "Disappearing into detachment when connection is what's needed"] },
    3: { do: ["The philosophical insight that arrives with unusual clarity today", "Trust the wise intuition — Jupiter + Ketu = the most sound instinct available", "The deep conversation that requires both wisdom and genuine seeking"], avoid: ["Ketu's instability frustrating Jupiter day's call for consistency", "Wanting to change the plan that wisdom has been building toward", "Detachment from the very wisdom that's trying to reach you today"] },
    4: { do: ["Two seeking energies — the depth available today is extraordinary", "The investigation into the genuinely unusual or metaphysical angle", "Trust the intuition even when it defies conventional analysis"], avoid: ["Double shadow planet influence — no financial decisions today under any circumstances", "The intuition is both heightened and unreliable today — verify the important reads", "Disappearing into the seeking when practical matters need you present"] },
    5: { do: ["Easy Money energy active — Mercury + Ketu is one of the most fortunate financial combinations", "Act on the financial opportunity — the luck is structural today", "The business decision that requires both intelligence and instinct"], avoid: ["Letting financial analysis delay the lucky opportunity past its window", "Easy come easy go — save something from what arrives today", "7 natal's detachment allowing the fortunate financial thing to pass unnoticed"] },
    6: { do: ["Lucky and beautiful — Ketu fortune + Venus day = fortunate aesthetic and social outcomes", "The social or romantic move that luck is behind today", "Follow the beautiful instinct without over-managing it"], avoid: ["Ketu's detachment leaving 6-day beauty unappreciated — notice what's available", "Over-complicating the fortunate simple thing", "7's disappearing tendency on a day that rewards presence and connection"] },
    7: { do: ["Double Ketu — maximum intuition and philosophical depth today", "The psychic read on the important situation — trust it", "The spiritual practice or deep conversation that this combination uniquely supports"], avoid: ["Neither energy is grounded — no practical financial or logistical decisions today", "Double instability means double unreliability on practical matters", "The wordless understanding becoming permanent withdrawal from practical life"] },
    8: { do: ["Ketu luck meets Saturn discipline — the unexpected breakthrough in sustained effort", "The patient persistent work that today's luck can suddenly accelerate", "Show up for the long-term project — something shifts today"], avoid: ["Saturn's heaviness suppressing Ketu's quiet luck — allow the unexpected good thing", "7 natal's detachment making Saturn's effort feel pointless — it isn't", "Expecting the breakthrough to be obvious — it may be quiet today"] },
    9: { do: ["Courageous luck — Mars energy + Ketu fortune = the bold move that's protected", "The physical or competitive challenge that fortune is backing today", "Take the risk that courage and luck together make reasonable"], avoid: ["9's explosive energy + 7's instability = accidents and reckless decisions", "Recklessness mistaken for the courageous luck that's actually available", "The Mars aggression bypassing the Ketu luck entirely"] },
  },

  // Basic 8 (Saturn natal)
  8: {
    1: { do: ["The disciplined leadership move — authority that has been genuinely earned", "The long-game career decision that others will understand later", "Do the hard visible thing — Sun day supports what Saturn has been building"], avoid: ["Ego moves that haven't been earned through effort — Sun day amplifies what's real", "Expecting recognition today — it arrives through the sustained work, not the announcement", "Impatience with the timeline Saturn has established"] },
    2: { do: ["Show up for the relationship with sustained genuine attention — Moon day rewards this", "The creative work that requires both discipline and emotional depth", "The honest conversation that has been needing structure and feeling simultaneously"], avoid: ["Emotional heaviness becoming withdrawal from connection", "Saturn's heaviness suppressing Moon day's call for warmth — one hard thing done gently", "Unspoken needs on both sides — name yours today"] },
    3: { do: ["Principled long-term work — Jupiter wisdom + Saturn natal = what's built with ethics lasts", "The ethical difficult decision that others avoid — today it has full support", "Strategic planning with genuine depth and staying power"], avoid: ["Both Saturn and Jupiter can be over-serious — schedule lightness deliberately", "Holding others to the Saturn-Jupiter standard without communicating it", "The principled decision that's right but delivered in a way that alienates"] },
    4: { do: ["Saturn's patience grounding Rahu day's chaos — you are the stabilizing force today", "The methodical research that benefits from your disciplined attention", "The practical anchor in a situation that needs one"], avoid: ["Rahu's speed fighting Saturn natal's deliberateness — the conflict is internal and external today", "Shortcuts — Saturn natal + Rahu day means they cost triple today", "Accident risk is genuinely elevated — move carefully in physical environments"] },
    5: { do: ["Methodical financial intelligence — Mercury day's sharpness + Saturn's discipline", "The long-term financial plan that requires both analysis and patience", "Systematic savings and investment decisions"], avoid: ["Mercury's speed vs Saturn natal's deliberateness — coordinate timing before acting on analysis", "Shortcuts in financial planning", "Mercury's anxiety + Saturn's heaviness = unnecessary worst-case thinking today"] },
    6: { do: ["Earned beauty — the creative effort that's been sustained is showing results today", "The long-term aesthetic investment paying off", "Show the work — Venus day appreciates what Saturn has been building"], avoid: ["Saturn natal's heaviness dampening Venus day's lightness — allow the warmth", "Indulgence before the work is done", "6 day luxury spending + 8 natal's financial weight — not the day for large aesthetic purchases"] },
    7: { do: ["Saturn's persistence meets Ketu's luck — the unexpected breakthrough in long-standing effort", "Show up fully for the work — today the luck finds what the effort has prepared", "The patient long-term move that fortune is today accelerating"], avoid: ["Saturn's heaviness preventing Ketu's luck from landing — allow the unexpected good thing", "8 natal's grimness on a day that has genuine fortune available", "Missing the quiet lucky development because you're focused only on the effort"] },
    8: { do: ["Double Saturn — maximum karmic impact today. What's built with integrity compounds enormously", "The most important long-term work — today's effort has extraordinary staying power", "Repair something that was damaged — the repair today holds permanently"], avoid: ["Shortcuts of any kind today — double Saturn means they come back at compound interest", "Emotional heaviness without the counterweight of genuine accomplishment", "Giving up on what matters when the discomfort is exactly the point"] },
    9: { do: ["Relentless achiever energy — Mars + Saturn = extraordinary sustained output today", "The physically and professionally demanding work that only you can do", "High-intensity sustained effort — today it converts"], avoid: ["9 day energy pushing 8 natal's threshold — monitor the physical and emotional charge carefully", "Mars aggression bypassing Saturn's wisdom — anger-driven decisions today have permanent consequences", "Spreading the Saturn-Mars energy too thin — pick the one thing"] },
  },

  // Basic 9 (Mars natal)
  9: {
    1: { do: ["Maximum authority and courage — both available simultaneously today", "The competitive leadership move that requires real nerve", "The confrontation that needs having — do it today when you have full backing"], avoid: ["Unnecessary battles — the power today is real and the damage of misusing it is also real", "Anger bypassing the authority you actually have", "Recklessness that wastes the full-power window today"] },
    2: { do: ["Channel the passion into genuine connection today — Moon + Mars can be tender and fierce", "The creative work that has both passion and emotional depth", "Physical expression of something you feel deeply"], avoid: ["9 natal's explosive edge on Moon day — emotional volatility is highest today", "Arguments that damage the relationship Moon day is amplifying", "Physical recklessness — 9 natal + 2 day is the highest physical energy emotional combination"] },
    3: { do: ["The principled courageous stand — Jupiter wisdom + Mars natal = you know what's right AND have the nerve", "The ethical confrontation that others avoid", "Leadership through conviction — wisdom directing the courage"], avoid: ["Self-righteousness — being right with Mars energy doesn't require being aggressive about it", "9 natal anger overriding Jupiter day's call for wisdom before action", "Acting before Jupiter's judgment has processed what Mars wants to do"] },
    4: { do: ["Physical activity — Rahu day's energy needs a physical outlet through your Mars natal", "The bold unconventional move that requires both nerve and originality", "Challenge the conventional wisdom physically or intellectually"], avoid: ["9 natal + 4 day = the highest legal and financial risk combination — avoid joint decisions", "Anger-driven impulsive action — Rahu amplifies Mars natal's worst tendency today", "Aggressive driving, physical confrontations, reckless bets"] },
    5: { do: ["Street smart competitive intelligence — Mercury business day + Mars natal", "The competitive negotiation or business move requiring both sharpness and nerve", "Close the thing that requires both commercial intelligence and boldness"], avoid: ["Mercury sharpness + Mars tongue = the most cutting verbal combination — choose words carefully", "Reckless financial boldness justified as competitive intelligence", "Winning the argument at the cost of the relationship"] },
    6: { do: ["Passionate creative work — the most intensely beautiful creative day available", "The romantic or passionate expression that requires both fire and beauty", "Physical creative work that expresses genuine feeling"], avoid: ["9 natal frustration + 6 day's sharp tongue = the most memorable harmful combination verbally — pause before speaking", "Passion tipping into aggression in a context that needs beauty", "Dramatic moves that damage what was carefully built by Venus today"] },
    7: { do: ["Courageous luck — Ketu fortune backing Mars courage today", "The brave decision that requires both guts and trust", "Travel, the competitive challenge, the bold move that luck is supporting"], avoid: ["9's explosive energy + Ketu instability = accident and reckless decision risk elevated today", "Recklessness mistaken for the genuine courageous luck that's available", "Mars aggressiveness bypassing Ketu's quiet fortune entirely"] },
    8: { do: ["Maximum sustained output — Mars passion + Saturn discipline today", "The hardest most demanding work available — full physical and professional capacity", "Channel the energy into something that requires everything today"], avoid: ["Mars impatience + 8 day Saturn timing = conflict between urgent and deliberate — bridge them", "9 natal anger when Saturn day blocks the path — the block is the teaching", "Spreading across multiple things when maximum depth is what today rewards"] },
    9: { do: ["Double Mars — maximum physical and competitive energy today", "The most demanding physical or competitive challenge available", "The courageous thing that requires everything — today you have it"], avoid: ["If this turns inward, the explosion is significant — redirect with absolute intention", "Legal and physical risks are genuinely elevated — every aggressive impulse needs a pause before action", "Double Mars energy finding conflict where none was necessary"] },
  },
};

// ─── What maha + daily combination signals for today ─────────────────────────
export const MAHA_DAILY_SIGNAL = {
  // Saturn maha (8)
  '8_1': "Saturn period + Sun day — authority born from sustained effort. Today's boldness has karmic backing.",
  '8_2': "Saturn period + Moon day — emotional weight meets creative depth. Show up for the relationship.",
  '8_3': "Saturn period + Jupiter day — double wisdom. The long-term ethical decision has full support today.",
  '8_4': "Saturn period + Rahu day — discipline meets disruption. Verify before acting on anything financial.",
  '8_5': "Saturn period + Mercury day — methodical financial intelligence. The careful financial decision holds.",
  '8_6': "Saturn period + Venus day — earned beauty. The creative effort is showing results today.",
  '8_7': "Saturn period + Ketu day — the unexpected breakthrough in a long-standing effort. Something shifts.",
  '8_8': "Double Saturn — what's built today through genuine integrity compounds. No shortcuts.",
  '8_9': "Saturn period + Mars day — maximum sustained output. The hardest work produces the most today.",
  // Ketu antar (7) layered on daily
  '7_1': "Ketu chapter + Sun day — luck is backing the bold move. Make the ask.",
  '7_2': "Ketu chapter + Moon day — deep intuitive attunement available. The reads are accurate.",
  '7_3': "Ketu chapter + Jupiter day — wisdom meets fortune. Sound AND lucky.",
  '7_4': "Ketu chapter + Rahu day — both shadow planets active. No practical financial decisions.",
  '7_5': "Ketu chapter + Mercury day — Easy Money energy. Act on the financial opportunity today.",
  '7_6': "Ketu chapter + Venus day — beautiful and lucky simultaneously.",
  '7_7': "Double Ketu — maximum intuition. Trust completely. Act practically with caution.",
  '7_8': "Ketu chapter + Saturn day — patience meets fortune. The sustained work converts today.",
  '7_9': "Ketu chapter + Mars day — courageous luck. The bold move is protected.",
};

// ─── What monthly + daily generates (immediate flavor) ───────────────────────
export const MONTHLY_DAILY_FLAVOR = {
  // Same number = amplified
  '1_1': "Maximum Sun energy — authority, confidence, and bold action doubled.",
  '2_2': "Maximum Moon energy — emotional depth and creative sensitivity doubled.",
  '3_3': "Maximum Jupiter wisdom — the clearest planning day of the month.",
  '4_4': "Maximum Rahu disruption — double the instability, double the creative potential. No financial decisions.",
  '5_5': "Maximum Mercury — the sharpest business and financial day of the entire monthly period.",
  '6_6': "Maximum Venus — the most beautiful and warmth-rich day of the month.",
  '7_7': "Maximum Ketu — the most intuitive and potentially the luckiest day of the month.",
  '8_8': "Maximum Saturn — the heaviest and most karmic day of the month. Work with integrity.",
  '9_9': "Maximum Mars — the most energized and potentially most volatile day of the month.",
};

// ─── Build full 6-layer daily insight ────────────────────────────────────────
export function buildFullDailyInsight(ctx) {
  const { basic, destiny, maha, antar, monthly, daily, yogas, natalNums } = ctx;

  const mahaCtx = MAHA_CONTEXT[maha];
  const antarCtx = ANTAR_CONTEXT[antar];
  const dailyLayer = DAILY_LAYER[daily];
  const mahaDaily = MAHA_DAILY_SIGNAL[`${maha}_${daily}`];
  const monthlyFlavor = MONTHLY_DAILY_FLAVOR[`${monthly}_${daily}`];

  // Core insight — combine layers
  const parts = [];

  // 1. What's happening in the big picture (maha)
  parts.push(mahaCtx.signal);

  // 2. What today's daily specifically activates on top of it
  if (mahaDaily) {
    parts.push(mahaDaily);
  } else {
    parts.push(dailyLayer.signal);
  }

  // 3. Monthly amplification if notable
  if (monthlyFlavor) {
    parts.push(monthlyFlavor);
  } else if (monthly === antar) {
    // Monthly and antar same = inner chapter being amplified this month
    parts.push(`${antarCtx.theme} — amplified this month.`);
  }

  // 4. Antar chapter context
  parts.push(antarCtx.doing);

  return parts.join(' ');
}

// ─── Get personalized do/avoid for today ─────────────────────────────────────
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
