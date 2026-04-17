// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — DEEP HOURLY PREDICTION ENGINE
// Every hour reading = hourNum + daily + maha + antar + monthly + natal + yogas
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Hour number profiles — what each number FEELS like as an hour ────────────
export const HOUR_PROFILES = {
  1: {
    essence: 'authority and initiation',
    peak_for: ['bold decisions', 'starting something important', 'leadership conversations', 'public-facing work', 'asking for what you want'],
    not_for: ['passive waiting', 'emotional processing', 'administrative tasks'],
    body: 'energy is high — the mind is ahead of the moment',
    best_single_action: 'Make the ask or start the thing',
  },
  2: {
    essence: 'connection and sensitivity',
    peak_for: ['emotional conversations', 'creative work', 'reading people', 'collaboration', 'reaching out to someone who matters'],
    not_for: ['financial decisions', 'confrontation', 'isolation'],
    body: 'the emotional antenna is extended — you feel more',
    best_single_action: 'Connect with someone or create something',
  },
  3: {
    essence: 'clarity and wisdom',
    peak_for: ['learning', 'planning', 'giving or receiving advice', 'writing', 'teaching', 'important calls'],
    not_for: ['impulsive moves', 'financial risk', 'shortcuts'],
    body: 'mental clarity is high — the signal is clean',
    best_single_action: 'Think through the decision or have the important conversation',
  },
  4: {
    essence: 'disruption and research',
    peak_for: ['research', 'analysis', 'investigation', 'understanding something complex'],
    not_for: ['purchases', 'launches', 'first impressions', 'financial commitments', 'important agreements'],
    body: 'the mind runs fast but the ground is unstable — verify everything',
    best_single_action: 'Research, do not commit',
  },
  5: {
    essence: 'intelligence and commerce',
    peak_for: ['financial decisions', 'business conversations', 'negotiation', 'communication', 'analysis', 'deals'],
    not_for: ['emotional conversations', 'creative flow', 'rest'],
    body: 'the calculator is running — sharp and slightly anxious',
    best_single_action: 'Make the financial or business move',
  },
  6: {
    essence: 'beauty and harmony',
    peak_for: ['creative work', 'social connection', 'romantic investment', 'aesthetic decisions', 'presenting yourself'],
    not_for: ['harsh feedback', 'confrontation', 'purely transactional work'],
    body: 'the senses are heightened — beauty and disharmony both land harder',
    best_single_action: 'Create, connect, or express appreciation',
  },
  7: {
    essence: 'luck and intuition',
    peak_for: ['important decisions', 'key meetings', 'travel', 'spiritual work', 'following instinct', 'taking the chance'],
    not_for: ['forcing outcomes', 'overplanning', 'anxiety spiraling'],
    body: 'the luck is quiet and real — things have a way of working out',
    best_single_action: 'Take the chance you have been overthinking',
  },
  8: {
    essence: 'discipline and karma',
    peak_for: ['sustained focus work', 'completing what was started', 'building', 'exercise', 'anything requiring patience'],
    not_for: ['shortcuts', 'impulsive moves', 'expecting quick results'],
    body: 'the engine runs slow and strong — results come from sustained effort',
    best_single_action: 'Do the hard work without expecting immediate feedback',
  },
  9: {
    essence: 'energy and courage',
    peak_for: ['physical activity', 'competitive situations', 'bold action', 'confronting something difficult', 'high-output work'],
    not_for: ['delicate emotional conversations', 'patience-requiring tasks', 'financial decisions when frustrated'],
    body: 'energy is high and potentially volatile — needs a directed channel',
    best_single_action: 'Channel the energy into something physical or competitive',
  },
};

// ─── What each MAHA doing to the hour ─────────────────────────────────────────
export const MAHA_HOUR_MODIFIER = {
  1: { amplifies: [1, 3, 9, 5], dampens: [4, 8], flavor: 'authority amplified' },
  2: { amplifies: [2, 6, 5], dampens: [8, 4], flavor: 'sensitivity amplified' },
  3: { amplifies: [3, 1, 9], dampens: [4, 8], flavor: 'wisdom amplified' },
  4: { amplifies: [4, 7], dampens: [1, 8, 5], flavor: 'disruption amplified' },
  5: { amplifies: [5, 1, 9, 7], dampens: [4, 8], flavor: 'sharpness amplified' },
  6: { amplifies: [6, 2, 7], dampens: [4, 8, 9], flavor: 'beauty amplified' },
  7: { amplifies: [7, 5, 1, 6], dampens: [8, 4], flavor: 'luck amplified' },
  8: { amplifies: [8, 3, 5], dampens: [7, 1, 6], flavor: 'discipline amplified' },
  9: { amplifies: [9, 1, 5, 3], dampens: [4, 8], flavor: 'courage amplified' },
};

// ─── What each DAILY number does to the hour quality ─────────────────────────
export const DAILY_HOUR_CONTEXT = {
  // daily 1 day — authority day
  1: {
    1: { quality: "peak", reason: "Maximum authority window — the full Sun energy is available", do: ["bold moves", "important asks", "leadership decisions", "presentations"], avoid: ["passive waiting", "showing weakness unnecessarily"] },
    2: { quality: "good", reason: "Authority softens into connection — emotional conversations land well", do: ["team conversations", "relationship investment", "creative work"], avoid: ["coldness", "dismissing feelings"] },
    3: { quality: "best", reason: "Wisdom meets authority — the best hour for strategic decisions", do: ["planning", "important calls", "giving advice", "setting direction"], avoid: ["impulsive moves", "shortcuts"] },
    4: { quality: "caution", reason: "Disruption enters an authority day — verify before committing", do: ["research", "background checking", "analysis"], avoid: ["launches", "financial commitments", "first impressions"] },
    5: { quality: "best", reason: "Sharp intelligence amplifies authority — ideal for negotiation", do: ["deals", "negotiations", "financial decisions", "business conversations"], avoid: ["emotional decisions", "hesitation"] },
    6: { quality: "good", reason: "Authority day meets beauty hour — visible and attractive simultaneously", do: ["presentations", "social events", "creative leadership", "romantic expression"], avoid: ["harshness", "purely transactional behavior"] },
    7: { quality: "best", reason: "Luck enters an authority day — fortune favors the bold", do: ["the postponed ask", "important meetings", "travel", "key decisions"], avoid: ["overthinking the opportunity"] },
    8: { quality: "mixed", reason: "Karmic resistance on an authority day — push through with patience", do: ["sustained work", "completing started tasks", "disciplined effort"], avoid: ["expecting quick recognition", "shortcuts"] },
    9: { quality: "peak", reason: "Fire meets fire — maximum energy and competitive drive", do: ["physical action", "competition", "bold moves", "important confrontations"], avoid: ["unnecessary fights", "recklessness"] },
  },
  // daily 2 day — emotional/creative day
  2: {
    1: { quality: "good", reason: "Emotional day meets authority hour — lead with heart", do: ["team check-ins", "honest conversations", "compassionate leadership"], avoid: ["coldness", "purely transactional interactions"] },
    2: { quality: "peak", reason: "Maximum emotional depth — the connection available this hour is real", do: ["meaningful conversations", "creative work", "emotional honesty", "reaching out"], avoid: ["isolation", "financial decisions", "confrontation"] },
    3: { quality: "good", reason: "Emotional intelligence meets wisdom — advice given now lands deeply", do: ["counseling", "teaching", "writing", "important reflective conversations"], avoid: ["hasty judgments", "impulsive moves"] },
    4: { quality: "low", reason: "Emotional day meets disruption hour — heightened volatility", do: ["rest", "routine tasks", "creative work in solitude"], avoid: ["major decisions", "financial commitments", "confrontations"] },
    5: { quality: "good", reason: "Sharp mind enters an emotional day — balance heart and calculator", do: ["practical planning", "emotionally intelligent business", "communication"], avoid: ["ignoring feelings", "cold transactions"] },
    6: { quality: "peak", reason: "Venus on a Moon day — maximum creative and romantic energy", do: ["creative work", "romantic expression", "social connection", "aesthetic investment"], avoid: ["harsh words", "financial overindulgence"] },
    7: { quality: "best", reason: "Luck enters the emotional day — something good is arriving", do: ["following instinct", "the unexpected meeting", "travel", "open decisions"], avoid: ["forcing what should arrive naturally"] },
    8: { quality: "low", reason: "Emotional day meets karmic heaviness — feelings go deeper this hour", do: ["quiet focused work", "journaling", "processing", "completion tasks"], avoid: ["social obligations that drain", "high-pressure decisions"] },
    9: { quality: "mixed", reason: "Mars enters the emotional day — passion and volatility together", do: ["physical activity to release emotional energy", "passionate creative work"], avoid: ["arguments", "explosive emotional responses"] },
  },
  // daily 3 day — wisdom/clarity day
  3: {
    1: { quality: "best", reason: "Authority enters a wisdom day — strategic decision has full backing", do: ["strategic planning", "important leadership moves", "major decisions", "institutional action"], avoid: ["ego-driven choices", "bypassing the wisdom"] },
    2: { quality: "good", reason: "Wisdom softens into empathy — guidance given from the heart", do: ["counseling", "family conversations", "emotional support", "deep listening"], avoid: ["staying only in the head", "detachment"] },
    3: { quality: "peak", reason: "Double wisdom — clearest thinking of the day", do: ["planning", "writing", "learning", "complex problem solving", "advisory conversations"], avoid: ["shortcuts", "impulsive moves", "ethical compromises"] },
    4: { quality: "caution", reason: "Disruption enters a wisdom day — the plan needs testing", do: ["research", "checking assumptions", "playing devil advocate"], avoid: ["committing to untested plans", "financial moves based on projections"] },
    5: { quality: "best", reason: "Business intelligence meets wisdom — best hour for expert advice and deals", do: ["expert advisory", "knowledge-to-income work", "important negotiations", "writing"], avoid: ["ethical shortcuts", "pure transaction without wisdom"] },
    6: { quality: "good", reason: "Beauty enters a wisdom day — creative decisions have clarity", do: ["creative work", "aesthetic choices", "relationship investment", "values-aligned decisions"], avoid: ["compromising standards for convenience"] },
    7: { quality: "best", reason: "Fortune on a wisdom day — the right answer arrives from unexpected direction", do: ["trusting instinct over analysis", "the ask", "travel", "following the philosophical pull"], avoid: ["forcing the outcome through analysis alone"] },
    8: { quality: "good", reason: "Discipline meets wisdom — what is built this hour lasts", do: ["sustained important work", "long-term planning", "completing meaningful projects"], avoid: ["shortcuts that undermine the wisdom"] },
    9: { quality: "good", reason: "Courage meets wisdom — the principled bold move is available", do: ["standing up for something", "bold advocacy", "physical activity", "important confrontation"], avoid: ["recklessness", "anger overriding the wisdom"] },
  },
  // daily 4 day — unstable/research day
  4: {
    1: { quality: "caution", reason: "Authority enters an unstable day — verify before acting on confidence", do: ["research", "second opinions", "checking facts"], avoid: ["overconfident moves", "committing based on projection"] },
    2: { quality: "caution", reason: "Emotional sensitivity meets disruption — feelings may not reflect reality", do: ["rest", "creative work in solitude", "processing"], avoid: ["major emotional decisions", "confrontations", "trusting the anxiety"] },
    3: { quality: "good", reason: "Wisdom stabilizes the disruption day — thinking is clearer this hour", do: ["research", "planning", "writing", "analysis"], avoid: ["committing without independent verification"] },
    4: { quality: "low", reason: "Double disruption — maximum instability. Do not commit to anything", do: ["research only", "observation", "understanding"], avoid: ["all financial commitments", "launches", "important decisions", "trusting first impressions"] },
    5: { quality: "caution", reason: "Sharp mind on an unstable day — analysis looks right but needs verification", do: ["financial analysis", "research", "background checking"], avoid: ["executing on current analysis alone", "impulsive purchases"] },
    6: { quality: "good", reason: "Beauty enters the disruption day — creative and social work flows", do: ["creative work", "social connection", "aesthetic decisions"], avoid: ["financial commitments disguised as aesthetic ones"] },
    7: { quality: "mixed", reason: "Luck and disruption together — the opportunity is real but needs checking", do: ["evaluate quickly", "do basic verification", "trust feeling after checking"], avoid: ["acting purely on excitement", "skipping verification"] },
    8: { quality: "caution", reason: "Karmic heaviness enters the disruption day — accident risk is elevated", do: ["slow careful focused work", "physical caution", "methodical tasks"], avoid: ["rushing", "skipping steps", "physical recklessness"] },
    9: { quality: "low", reason: "Explosive energy on an unstable day — legal and anger risk peaks", do: ["physical activity to discharge the energy", "solo work"], avoid: ["confrontations", "angry decisions", "aggressive driving"] },
  },
  // daily 5 day — sharp/business day
  5: {
    1: { quality: "best", reason: "Maximum authority and intelligence — the power negotiation hour", do: ["deals", "negotiations", "pitches", "important business conversations", "career moves"], avoid: ["hesitation", "giving away ground unnecessarily"] },
    2: { quality: "good", reason: "Emotional intelligence meets business day — read the room while making the deal", do: ["relationship-based business", "partnership conversations", "emotional sales"], avoid: ["cold transactional approach", "ignoring the person behind the deal"] },
    3: { quality: "best", reason: "Expertise meets business sharpness — advisory and knowledge-income hour", do: ["expert conversations", "teaching for pay", "consulting", "writing", "strategic advice"], avoid: ["giving away expertise for free when it has value"] },
    4: { quality: "caution", reason: "Disruption enters the sharp day — financial decisions need extra verification", do: ["research", "financial analysis", "understanding the full picture"], avoid: ["impulsive purchases", "committing to incomplete financial plans"] },
    5: { quality: "peak", reason: "Maximum Mercury — sharpest financial thinking of the entire cycle", do: ["the most important financial decision", "complex analysis", "negotiation", "business strategy"], avoid: ["letting anxiety misuse the sharpness", "overthinking past the decision"] },
    6: { quality: "good", reason: "Creative commerce — business and beauty working together", do: ["creative business decisions", "presenting the work", "aesthetic investments with logic"], avoid: ["pure luxury spending without business logic"] },
    7: { quality: "best", reason: "Easy Money energy this hour — financial luck is structural", do: ["the financial ask", "the deal", "the investment decision", "the pitch"], avoid: ["letting the opportunity pass through hesitation"] },
    8: { quality: "good", reason: "Disciplined intelligence — the methodical financial decision holds", do: ["long-term financial planning", "systematic saving", "careful investment"], avoid: ["shortcuts", "analysis paralysis that prevents decision"] },
    9: { quality: "best", reason: "Street smart energy at peak — competitive financial instinct running", do: ["competitive business moves", "bold financial bets", "entrepreneurial action"], avoid: ["impulsive risk without analysis", "shortcuts that backfire"] },
  },
  // daily 6 day — beauty/harmony day
  6: {
    1: { quality: "good", reason: "Authority enters a harmony day — lead with grace", do: ["creative leadership", "presenting the work", "public visibility with warmth"], avoid: ["harshness", "purely transactional authority"] },
    2: { quality: "peak", reason: "Venus meets Moon — maximum romantic and creative energy", do: ["romantic expression", "creative work", "deep emotional connection", "reaching out"], avoid: ["financial decisions from romantic feeling", "harsh words"] },
    3: { quality: "good", reason: "Wisdom enters the beauty day — values-aligned creative decisions", do: ["values-driven creative work", "quality over quantity", "important relationship conversations"], avoid: ["compromising the standard for convenience"] },
    4: { quality: "caution", reason: "Disruption enters a harmony day — relationship complications possible", do: ["creative work in solitude", "research", "processing"], avoid: ["financial decisions tied to relationships", "trusting new connections without verification"] },
    5: { quality: "good", reason: "Creative commerce — monetization of beauty and charm", do: ["creative business", "communication that sells", "aesthetic presentations"], avoid: ["overspending on luxury as business expense"] },
    6: { quality: "peak", reason: "Double Venus — maximum beauty, social magnetism, and creative flow", do: ["most important creative work", "romantic expression", "social events", "aesthetic investments"], avoid: ["harsh speech", "financial overindulgence", "words said in frustration"] },
    7: { quality: "best", reason: "Luck enters the beauty day — romantic and creative fortune peaks", do: ["the romantic ask", "creative launch", "social events", "pitch of the beautiful idea"], avoid: ["overthinking the moment"] },
    8: { quality: "good", reason: "Disciplined beauty — earning the aesthetic life through work", do: ["creative work requiring sustained effort", "completing the long project", "quality over speed"], avoid: ["shortcuts in creative work", "spending on beauty before earning it"] },
    9: { quality: "mixed", reason: "Mars enters the beauty day — passion is available but so is the sharp tongue", do: ["passionate creative work", "the romantic pursuit", "physical activity"], avoid: ["words said in frustration", "dramatic relationship moves"] },
  },
  // daily 7 day — intuition/luck day
  7: {
    1: { quality: "best", reason: "Luck amplifies authority — the bold move has fortune behind it", do: ["the ask", "the leadership move", "career decisions", "public action"], avoid: ["overthinking instead of acting"] },
    2: { quality: "good", reason: "Psychic sensitivity peaks this hour on a lucky day", do: ["following emotional instinct", "deep connection", "creative work from feeling", "trusting reads"], avoid: ["forcing what should arrive naturally"] },
    3: { quality: "best", reason: "Wisdom meets luck — the insight this hour is accurate and actionable", do: ["trusting philosophical and strategic instinct", "the important conversation", "intuitive planning"], avoid: ["ignoring wisdom because logic disagrees"] },
    4: { quality: "mixed", reason: "Disruption enters the lucky day — the opportunity needs basic verification", do: ["evaluate quickly", "verify the key fact", "trust instinct after checking"], avoid: ["pure excitement without any verification"] },
    5: { quality: "best", reason: "Easy Money hour on a lucky day — financial fortune is active", do: ["the financial decision", "the investment", "the deal", "asking for money"], avoid: ["letting analysis delay the move past the window"] },
    6: { quality: "best", reason: "Romantic and social luck peaks this hour", do: ["romantic expression", "social events", "creative work", "the conversation that matters"], avoid: ["overcomplicating a moment that wants to be simple"] },
    7: { quality: "peak", reason: "Double Ketu — maximum luck and intuition simultaneously", do: ["the biggest ask of the day", "the most important decision", "trusting the gut completely", "travel"], avoid: ["forcing what the luck wants to deliver naturally"] },
    8: { quality: "mixed", reason: "Karmic resistance enters the lucky day — luck requires effort to access", do: ["showing up for the opportunity", "disciplined pursuit", "not giving up when harder"], avoid: ["passively waiting for luck without effort", "shortcuts bypassing karmic requirement"] },
    9: { quality: "best", reason: "Courageous luck — the bold move is protected this hour", do: ["the physical challenge", "the competitive move", "the brave conversation", "travel"], avoid: ["recklessness mistaken for courage"] },
  },
  // daily 8 day — karmic/discipline day
  8: {
    1: { quality: "mixed", reason: "Authority on a karmic day — recognition requires more effort than usual", do: ["disciplined leadership", "sustained effort at visibility", "the long-game career move"], avoid: ["expecting immediate recognition", "ego moves not yet earned"] },
    2: { quality: "caution", reason: "Emotional weight peaks this hour on a heavy day", do: ["quiet focused work", "processing", "journaling", "gentle self-care"], avoid: ["major emotional decisions", "social obligations that drain"] },
    3: { quality: "good", reason: "Wisdom enters the karmic day — the long-term decision has clarity", do: ["strategic planning", "important writing", "the decision that compounds over time", "ethical choices"], avoid: ["ethical shortcuts", "decisions that compromise values"] },
    4: { quality: "low", reason: "Disruption meets karma — accident and financial risk peak", do: ["slow careful work", "physical caution", "rest if possible"], avoid: ["rushing", "financial commitments", "physical recklessness", "anything irreversible"] },
    5: { quality: "good", reason: "Disciplined intelligence on a karmic day — methodical financial decisions hold", do: ["systematic financial planning", "long-term investment", "business planning"], avoid: ["shortcuts", "quick financial moves bypassing due diligence"] },
    6: { quality: "good", reason: "Beauty earned through discipline — the creative effort converts", do: ["sustained creative work", "the long project", "quality over speed", "meaningful aesthetic investment"], avoid: ["shortcuts in creative work", "luxury before the work is done"] },
    7: { quality: "mixed", reason: "Luck meets karma — fortune is available but requires showing up", do: ["taking the opportunity with full effort", "decision backed by genuine work"], avoid: ["waiting for luck without doing the work", "passive hoping"] },
    8: { quality: "peak", reason: "Double Saturn — maximum karmic impact. Effort here compounds for years", do: ["the hardest most important work of the day", "completing what has ethical weight", "effort that compounds"], avoid: ["all shortcuts", "anything compromising integrity", "giving up on what matters"] },
    9: { quality: "best", reason: "Relentless achiever energy — maximum output is available this hour", do: ["the physically and professionally demanding task", "high output work", "the goal requiring everything"], avoid: ["spreading energy too thin", "anger-driven decisions"] },
  },
  // daily 9 day — energy/courage day
  9: {
    1: { quality: "peak", reason: "Maximum fire — authority and courage simultaneously", do: ["the bold leadership move", "competition", "the confrontation that needs having", "the ask requiring courage"], avoid: ["unnecessary fight", "anger overriding the authority"] },
    2: { quality: "mixed", reason: "Passion meets sensitivity — love and volatility in the same hour", do: ["passionate emotional expression", "creative work", "physical activity to manage the charge"], avoid: ["explosive emotional responses", "arguments that will not resolve"] },
    3: { quality: "good", reason: "Courageous wisdom — standing for what is right with knowledge behind it", do: ["advocacy", "important principled conversations", "teaching with conviction", "the ethical stand"], avoid: ["self-righteousness", "anger overriding the wisdom"] },
    4: { quality: "low", reason: "Bandhan energy peak — frustration and constraint collide", do: ["physical activity to discharge frustration", "understanding constraints vs self-imposed ones"], avoid: ["confrontations", "legal risks", "anger-driven decisions", "aggressive driving"] },
    5: { quality: "best", reason: "Street smart warrior — business instinct and competitive energy peak", do: ["the competitive business move", "the bold financial decision", "negotiation requiring courage"], avoid: ["overconfidence skipping verification", "shortcuts that look smart"] },
    6: { quality: "good", reason: "Passionate beauty — creative and romantic energy with fire behind it", do: ["passionate creative work", "romantic expression with conviction", "physical activity"], avoid: ["harsh words to people you love", "passion tipping into aggression"] },
    7: { quality: "best", reason: "Courageous luck — fortune protects the bold move this hour", do: ["the brave decision", "travel", "the competitive challenge", "guts and luck combined"], avoid: ["recklessness mistaken for courage"] },
    8: { quality: "best", reason: "Relentless achiever energy — output is at maximum this hour", do: ["the most demanding task on the list", "high intensity physical or professional work", "sustained effort"], avoid: ["spreading energy too thin", "picking fights instead of working"] },
    9: { quality: "peak", reason: "Double Mars — maximum intensity. Physical outlet is mandatory", do: ["the most physically demanding or competitive task", "the challenge requiring maximum energy"], avoid: ["explosive anger", "legal risks", "accidents from recklessness"] },
  },
};

// ─── MAHA modifier — how the multi-year period colors the hour ────────────────
export const MAHA_HOUR_LAYER = {
  1: (hourNum) => {
    if ([1, 3, 5, 9].includes(hourNum)) return 'The current multi-year energy amplifies this hour.';
    if (hourNum === 8) return 'Ego meets karmic resistance this hour — patience over pride.';
    return null;
  },
  2: (hourNum) => {
    if ([2, 5, 6].includes(hourNum)) return 'The current period deepens the emotional and creative quality of this hour.';
    if (hourNum === 8) return 'Emotional heaviness peaks this hour in the current period.';
    return null;
  },
  3: (hourNum) => {
    if ([1, 3, 5, 9].includes(hourNum)) return 'The wisdom of the current period makes this an especially clear hour for decisions.';
    if (hourNum === 4) return "The current period\'s wisdom is disrupted this hour — verify before acting.";
    return null;
  },
  4: (hourNum) => {
    if (hourNum === 7) return 'Unexpected luck cuts through the disruption this hour.';
    if ([1, 5, 8].includes(hourNum)) return 'The Rahu period adds instability to this hour — double-check everything.';
    return null;
  },
  5: (hourNum) => {
    if ([1, 5, 7, 9].includes(hourNum)) return 'Mercury period sharpens this hour — the financial and business instinct is at its most accurate.';
    if (hourNum === 4) return 'The Financial Bandhan tendency peaks this hour — the spending impulse is strongest.';
    return null;
  },
  6: (hourNum) => {
    if ([2, 6, 7].includes(hourNum)) return 'Venus period amplifies the beauty and connection of this hour.';
    if ([4, 9].includes(hourNum)) return "The current period\'s indulgent energy meets disruption — manage the impulse.";
    return null;
  },
  7: (hourNum) => {
    if ([1, 5, 6, 7].includes(hourNum)) return 'Ketu period brings luck to this hour — things have an unusual tendency to work out.';
    if (hourNum === 8) return 'The karmic suppression of this period is felt strongly this hour — persist.';
    return null;
  },
  8: (hourNum) => {
    if ([3, 5, 8].includes(hourNum)) return 'Saturn period gives this hour a disciplined quality — effort here compounds.';
    if ([1, 6, 7].includes(hourNum)) return 'The karmic period creates resistance here — push through with integrity.';
    return null;
  },
  9: (hourNum) => {
    if ([1, 5, 9].includes(hourNum)) return 'Mars period amplifies this hour — maximum energy is available.';
    if (hourNum === 4) return 'Bandhan risk peaks this hour in the current period — manage the frustration.';
    return null;
  },
};

// ─── ANTAR modifier — the inner chapter's flavor on the hour ─────────────────
export const ANTAR_HOUR_LAYER = {
  1: { peak_hours: [1, 3, 9], low_hours: [8, 4], peak_note: 'The inner chapter supports authority and boldness this hour.', low_note: 'The inner chapter creates friction this hour — be patient.' },
  2: { peak_hours: [2, 5, 6], low_hours: [8, 4], peak_note: 'Emotional intelligence from the inner chapter enhances this hour.', low_note: 'The emotional depth of the inner chapter makes this hour heavy.' },
  3: { peak_hours: [1, 3, 5], low_hours: [4], peak_note: 'Wisdom from the inner chapter makes this a particularly clear hour.', low_note: null },
  4: { peak_hours: [7], low_hours: [1, 5, 8], peak_note: 'Intuition cuts through the disruption this hour.', low_note: 'The Rahu inner chapter adds volatility to this hour — verify before committing.' },
  5: { peak_hours: [5, 1, 7, 9], low_hours: [4], peak_note: 'Mercury inner chapter sharpens the financial instinct this hour.', low_note: 'Impulsive spending risk is elevated this hour.' },
  6: { peak_hours: [2, 6, 7], low_hours: [9], peak_note: 'Venus inner chapter deepens the beauty and connection of this hour.', low_note: 'The tongue is sharper than usual this hour — choose words carefully.' },
  7: { peak_hours: [5, 7, 1], low_hours: [8], peak_note: 'Ketu inner chapter brings quiet luck to this hour.', low_note: 'The spiritual heaviness of the inner chapter is felt this hour.' },
  8: { peak_hours: [3, 5, 8], low_hours: [7, 1], peak_note: 'Saturn inner chapter gives this hour staying power — effort compounds.', low_note: 'Karmic resistance peaks this hour in the inner chapter.' },
  9: { peak_hours: [1, 9, 5], low_hours: [4], peak_note: 'Mars inner chapter amplifies courage and energy this hour.', low_note: 'Frustration risk peaks this hour — physical activity recommended.' },
};

// ─── NATAL number modifiers — permanent chart effects on hours ────────────────
export const NATAL_HOUR_EFFECT = {
  // What natal numbers do to specific hour qualities
  1: { boosts: [1, 3, 9], note: 'Your natal authority amplifies leadership hours.' },
  2: { boosts: [2, 6], note: 'Your natal sensitivity deepens connection hours.' },
  3: { boosts: [3, 1], note: 'Your natal wisdom enhances clarity hours.' },
  4: { boosts: [4, 7], dampens: [1, 5], note: 'Your natal Rahu makes research hours potent but financial hours need verification.' },
  5: { boosts: [5, 7, 1], note: 'Your natal Mercury makes all financial and communication hours sharper.' },
  6: { boosts: [6, 2], note: 'Your natal Venus amplifies creative and connection hours.' },
  7: { boosts: [7, 5], note: 'Your natal Ketu amplifies luck and intuition hours.' },
  8: { boosts: [8, 3], dampens: [7, 6], note: 'Your natal Saturn makes discipline hours powerful but luck hours require effort.' },
  9: { boosts: [9, 1, 5], note: 'Your natal Mars amplifies energy and competitive hours.' },
};

// ─── Yoga effects on hours ────────────────────────────────────────────────────
export const YOGA_HOUR_EFFECTS = {
  easy_money: {
    peak_hours: [5, 7, 1],
    peak_note: 'Easy Money yoga amplifies financial luck this hour — act on what presents itself.',
    any_note: 'The financial luck of Easy Money yoga is present throughout the day.',
  },
  raj_yoga: {
    peak_hours: [1, 3, 9],
    peak_note: 'Raj Yoga makes this an authority and recognition hour — be visible.',
    any_note: null,
  },
  financial_bandhan: {
    peak_hours: [4, 6],
    peak_note: 'Financial Bandhan makes the spending impulse strongest this hour — avoid purchases.',
    low_hours: [5, 8],
    low_note: 'The discipline this hour can counteract the Financial Bandhan pattern — save now.',
  },
  bandhan: {
    peak_hours: [4, 9],
    peak_note: 'Bandhan yoga peaks this hour — the frustration is real, the outlet needs to be physical.',
    any_note: 'Navigate constraints patiently this hour — explosive responses cost more.',
  },
  uplifting_319: {
    peak_hours: [1, 3, 9],
    peak_note: 'Full Power Triad makes this hour extraordinary — lead, decide, and act.',
    any_note: 'The uplifting energy of the 3-1-9 combination is available this hour.',
  },
  vipreet_raj: {
    peak_hours: [2, 8, 4],
    peak_note: "Adversity-to-triumph energy peaks this hour — what\'s hard now is building something.",
    any_note: null,
  },
  high_intuition: {
    peak_hours: [7, 1, 5],
    peak_note: 'High Intuition yoga makes this the most accurate instinct hour of the day.',
    any_note: 'Trust the first read more than usual this hour.',
  },
  spiritual: {
    peak_hours: [3, 7, 2],
    peak_note: 'The spiritual alignment makes insight available this hour — pause and receive it.',
    any_note: null,
  },
};

// ─── Time of day layer — morning/afternoon/evening/night quality ──────────────
export const TIME_OF_DAY_LAYER = {
  early_morning: {
    quality: "The early hours carry the clearest signal — the mind is uncluttered.",
    best_for: ["meditation", "planning", "the most important work", "exercise"],
    context: "fresh start",
  },
  morning: {
    quality: "Morning energy is forward-moving — the day is still being written.",
    best_for: ["important conversations", "creative work", "business", "decisions"],
    context: "momentum",
  },
  afternoon: {
    quality: "Afternoon energy is about sustaining and completing what was started.",
    best_for: ["follow-through", "execution", "finishing tasks", "calls"],
    context: "execution",
  },
  evening: {
    quality: "Evening energy shifts inward — the social and reflective hours.",
    best_for: ["social connection", "creative work", "processing", "relationships"],
    context: "reflection and connection",
  },
  night: {
    quality: "Night energy is for completion and rest — not for launching.",
    best_for: ["completing small tasks", "reading", "planning tomorrow", "rest"],
    context: "completion",
  },
};
export function getTimeOfDay(hour) {
  if (hour >= 5 && hour <= 8) return 'early_morning';
  if (hour >= 9 && hour <= 12) return 'morning';
  if (hour >= 13 && hour <= 17) return 'afternoon';
  if (hour >= 18 && hour <= 21) return 'evening';
  return 'night';
}

// ─── Master classify function — all 6 layers ─────────────────────────────────
export function classifyHourDeep(hour, hourNum, dailyNum, maha, antar, monthly, natalNums, yogas) {
  const dailyCtx = DAILY_HOUR_CONTEXT[dailyNum]?.[hourNum];
  const timeOfDay = getTimeOfDay(hour);
  const tod = TIME_OF_DAY_LAYER[timeOfDay];
  const profile = HOUR_PROFILES[hourNum];
  const mahaLayer = MAHA_HOUR_LAYER[maha]?.(hourNum);
  const antarLayer = ANTAR_HOUR_LAYER[antar];
  const yogaIds = yogas.map(y => y.id);

  // Base quality from daily × hour combination
  let type = dailyCtx?.quality || 'neutral';
  let reason = dailyCtx?.reason || profile.essence;
  let good_for = dailyCtx?.do || profile.peak_for;
  let avoid = dailyCtx?.avoid || profile.not_for;

  // Normalize type
  if (type === 'best' || type === 'peak') type = 'best';
  else if (type === 'low') type = 'caution';
  else if (type === 'mixed') type = 'caution';
  else if (type === 'good') type = 'best';
  else type = 'neutral';

  // Build layered insight (for bottom sheet)
  const layers = [];

  // Layer 1: Daily × Hour (primary)
  if (dailyCtx?.reason) {
    layers.push({ source: 'today', text: dailyCtx.reason });
  }

  // Layer 2: Maha period modifier
  if (mahaLayer) {
    layers.push({ source: 'period', text: mahaLayer });
  }

  // Layer 3: Antar inner chapter
  const isAntarPeak = antarLayer?.peak_hours?.includes(hourNum);
  const isAntarLow = antarLayer?.low_hours?.includes(hourNum);
  if (isAntarPeak && antarLayer.peak_note) {
    layers.push({ source: 'chapter', text: antarLayer.peak_note });
    if (type === 'caution') type = 'neutral'; // antar can lift a caution
  } else if (isAntarLow && antarLayer.low_note) {
    layers.push({ source: 'chapter', text: antarLayer.low_note });
    if (type === 'neutral') type = 'caution'; // antar can lower a neutral
  }

  // Layer 4: Natal numbers
  const natalBoosts = natalNums.filter(n => NATAL_HOUR_EFFECT[n]?.boosts?.includes(hourNum));
  const natalDampens = natalNums.filter(n => NATAL_HOUR_EFFECT[n]?.dampens?.includes(hourNum));
  if (natalBoosts.length > 0) {
    layers.push({ source: 'natal', text: "Your chart\'s permanent numbers amplify this hour." });
    if (type === 'neutral') type = 'best';
  }
  if (natalDampens.length > 0) {
    layers.push({ source: 'natal', text: "Your chart\'s permanent numbers add caution to this hour." });
    if (type === 'best') type = 'neutral';
  }

  // Layer 5: Active yogas
  for (const yogaId of yogaIds) {
    const effect = YOGA_HOUR_EFFECTS[yogaId];
    if (!effect) continue;
    if (effect.peak_hours?.includes(hourNum)) {
      layers.push({ source: 'yoga', text: effect.peak_note });
      if (type === 'neutral') type = 'best';
      if (yogaId === 'financial_bandhan' && type === 'best') type = 'caution'; // override for bandhan
    } else if (effect.any_note) {
      layers.push({ source: 'yoga', text: effect.any_note });
    }
    // Low hours for yoga
    if (effect.low_hours?.includes(hourNum) && effect.low_note) {
      layers.push({ source: 'yoga', text: effect.low_note });
      if (type === 'best') type = 'neutral';
    }
  }

  // Layer 6: Time of day context
  layers.push({ source: 'time', text: tod.quality });

  // Build the summary reason (what shows in the strip card)
  const summaryReason = dailyCtx?.reason || `${profile.essence} — ${tod.context}`;

  // Best single action for this hour
  const bestAction = profile.best_single_action;

  return {
    type,
    reason: summaryReason,
    good_for: good_for.slice(0, 4),
    avoid: avoid.slice(0, 3),
    layers, // all 6 layers for bottom sheet detail
    best_action: bestAction,
    time_of_day: timeOfDay,
    hour_essence: profile.essence,
  };
}
