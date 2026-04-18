// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — DEEP COMPATIBILITY LIBRARY
// Works for ALL relationships: romantic, friendship, family, colleague
// ═══════════════════════════════════════════════════════════════════════════════

// ─── What each number BRINGS to a relationship ────────────────────────────────
export const NUMBER_IN_RELATIONSHIP = {
  1: {
    brings: "direction, confidence, decisiveness",
    needs: "admiration, space to lead, acknowledgment",
    blind_spot: "can dominate without realizing it",
    love_language: "acts of service and quality time — shows love by doing, not saying",
    friendship_style: "loyal protector, shows up in crises, not the daily check-in type",
    conflict_style: "direct and forceful, dislikes passive aggression, needs resolution not drama",
  },
  2: {
    brings: "emotional depth, loyalty, intuition",
    needs: "reassurance, reciprocity, to feel genuinely seen",
    blind_spot: "absorbs others' emotions, can lose themselves",
    love_language: "words of affirmation — needs to hear it as much as feel it",
    friendship_style: "the friend who remembers everything, deeply present, occasionally overwhelming",
    conflict_style: "avoids direct confrontation, needs time to process, can go cold when hurt",
  },
  3: {
    brings: "wisdom, stability, a grounding presence",
    needs: "ethical alignment, respect for their values, family acknowledgment",
    blind_spot: "can moralize, holds people to impossible standards",
    love_language: "acts of service — provides, protects, shows up consistently",
    friendship_style: "the advisor friend, gives honest counsel, not always emotionally warm",
    conflict_style: "principled and firm, rarely backs down when they believe they're right",
  },
  4: {
    brings: "unpredictability, fresh perspectives, research ability",
    needs: "freedom, novelty, patience for their chaos",
    blind_spot: "starts things without finishing, financially impulsive",
    love_language: "quality time and physical touch — present but not always consistent",
    friendship_style: "exciting and unreliable in equal measure — the adventure friend",
    conflict_style: "unpredictable reactions, can spiral or disappear, needs space",
  },
  5: {
    brings: "intelligence, financial clarity, sharp communication",
    needs: "intellectual respect, appreciation for their sharpness, financial compatibility",
    blind_spot: "treats emotions like calculations, can feel cold",
    love_language: "gift-giving — shows love through providing and quality",
    friendship_style: "the smart friend who solves your problems, less good at sitting with feelings",
    conflict_style: "logical and sometimes cold, can be cutting with words",
  },
  6: {
    brings: "beauty, warmth, aesthetic richness, social ease",
    needs: "beauty in the environment, appreciation for their taste, emotional reciprocity",
    blind_spot: "sharp tongue when hurt, high standards that others can't meet",
    love_language: "physical touch and quality time — the most romantic number",
    friendship_style: "the fun friend — social, generous, occasionally unreliable under pressure",
    conflict_style: "can say cutting things, withdraws when standards are unmet",
  },
  7: {
    brings: "depth, luck, philosophical richness",
    needs: "intellectual and spiritual connection, freedom, understanding of their detachment",
    blind_spot: "emotional unavailability, instability, can vanish when overwhelmed",
    love_language: "quality time — needs depth not breadth in all connections",
    friendship_style: "deeply interesting but hard to pin down, the friend who moves cities",
    conflict_style: "withdraws completely, hard to reach, needs time and space to return",
  },
  8: {
    brings: "dedication, patience, deep loyalty over time",
    needs: "acknowledgment of their effort, emotional validation, consistency from others",
    blind_spot: "holds grudges, emotional extremes, can carry old hurts for years",
    love_language: "acts of service — gives everything, needs to see the same",
    friendship_style: "the most loyal friend over time, shows up through difficulty, not through fun",
    conflict_style: "slow to anger but deep when it comes, holds grudges, needs explicit repair",
  },
  9: {
    brings: "passion, protection, intensity, courage",
    needs: "respect, freedom, a worthy challenge, emotional honesty",
    blind_spot: "explosive when frustrated, picks unnecessary battles",
    love_language: "physical touch and words of affirmation — loves loudly",
    friendship_style: "the friend who will fight for you without being asked",
    conflict_style: "explosive and direct, quick to anger and (sometimes) quick to forgive",
  },
};

// ─── Basic number pair dynamics ───────────────────────────────────────────────
// What this combination creates — for any relationship type
export const PAIR_DYNAMICS = {
  '1_1': {
    core: "Two leaders in the same space. Either one leads and one follows — which neither wants — or you build something extraordinary together by dividing domains clearly.",
    strength: "Shared ambition, mutual respect for drive, neither takes the other lightly",
    tension: "Power struggles. Two egos that need to lead. Arguments about who is right.",
    romantic: "Intense attraction — both confident and magnetic. Long-term requires explicit territory division.",
    friendship: "Exciting, competitive, occasionally exhausting. The friendship that keeps score.",
    growth: "This combination either elevates both people or triggers each other's worst traits. The ceiling is very high.",
    today_boost: ["Both running the same authority energy — decisions made together today carry"],
    today_watch: ["Power struggle risk elevated — who leads needs to be decided before important conversations"],
  },
  '1_2': {
    core: "The natural leader and the natural nurturer. Classically complementary — but 1 can dominate and 2 can over-give until resentment builds.",
    strength: "1 provides direction, 2 provides emotional intelligence. Together they cover what each lacks.",
    tension: "1 forgets to acknowledge 2's emotional needs. 2 gives more than they should and quietly resents it.",
    romantic: "One of the most common romantic pairings. Works when 1 learns to receive and 2 learns to ask.",
    friendship: "2 is the support system, 1 is the ambitious friend. Both get what they need if 1 appreciates.",
    growth: "1 learns to be vulnerable. 2 learns to lead occasionally.",
    today_boost: ["1's initiative + 2's sensitivity makes this a day for honest conversations that land"],
    today_watch: ["2 may feel unacknowledged today if 1 is in full drive mode — check in"],
  },
  '1_3': {
    core: "Authority meets wisdom. This combination builds things that last — institutions, families, businesses. Both understand leadership but express it differently.",
    strength: "1 acts, 3 thinks. Together they balance speed with soundness.",
    tension: "1 finds 3 too cautious, 3 finds 1 too reckless. Values alignment is essential.",
    romantic: "Deeply respectful. Neither diminishes the other. Can feel more like partnership than romance.",
    friendship: "The mentor-mentee dynamic works in either direction. Reliable, mutually enriching.",
    growth: "1 learns patience. 3 learns boldness.",
    today_boost: ["Authority + wisdom — the best day for joint decisions that require both speed and soundness"],
    today_watch: ["3 may hold 1 to ethical standards that feel constraining today"],
  },
  '1_4': {
    core: "The bold and the unpredictable. 1 wants to build, 4 wants to explore. Together they can create genuinely innovative things — if 4 finishes what they start.",
    strength: "1's drive + 4's unconventional thinking = genuinely novel outcomes",
    tension: "1 is frustrated by 4's inconsistency. 4 feels controlled by 1's need for direction.",
    romantic: "Initially exciting — 4's unpredictability attracts 1's need to win. Long-term is challenging.",
    friendship: "Adventure friendship. Don't count on 4 for logistics. Do count on them for ideas.",
    growth: "1 learns flexibility. 4 learns to finish things.",
    today_boost: ["Unconventional ideas from 4 can break through 1's established patterns today"],
    today_watch: ["Financial decisions made together today need extra verification"],
  },
  '1_5': {
    core: "Power and intelligence combined. One of the strongest professional pairings in numerology. Both driven by results, both sharp.",
    strength: "Exceptional business partnership. Complementary skills with shared ambition.",
    tension: "Both can be cold. Neither naturally provides emotional warmth.",
    romantic: "Works when both prioritize the relationship the way they prioritize goals. Can feel like a merger.",
    friendship: "The power duo friendship — gets things done, occasionally forgets to have fun.",
    growth: "Both learn that emotional investment isn't weakness.",
    today_boost: ["Sharp day for business decisions, negotiations, and any shared financial moves"],
    today_watch: ["Neither will back down today — choose the battles worth fighting"],
  },
  '1_6': {
    core: "Ambition meets beauty. 1 builds, 6 makes it beautiful. Together they create an exceptional life — as long as 6's standards are respected.",
    strength: "1 provides stability and direction, 6 provides warmth and aesthetic richness",
    tension: "6's sharp tongue when disappointed vs 1's ego. Both take criticism poorly.",
    romantic: "Highly attractive combination. 1 admires 6's beauty, 6 admires 1's strength.",
    friendship: "The successful ambitious friend (1) and the stylish one (6). Complement each other socially.",
    growth: "1 learns appreciation. 6 learns to express disappointment without cutting.",
    today_boost: ["Social and professional both work today — good for joint appearances and meetings"],
    today_watch: ["If either is disappointed today, the reaction can be disproportionate"],
  },
  '1_7': {
    core: "Authority backed by fortune. What 1 initiates, 7's luck tends to support. One of the most naturally fortunate combinations.",
    strength: "Lucky together. Things work out at higher rates than with other combinations.",
    tension: "7's detachment can feel like abandonment to relationships that need presence.",
    romantic: "Unusual and often fortunate. 7 provides depth and luck, 1 provides direction.",
    friendship: "The loyal bold friend (1) and the lucky philosophical one (7). Enriching.",
    growth: "1 learns to trust without controlling. 7 learns to stay present.",
    today_boost: ["Fortune is structurally present — good day for bold asks and important meetings together"],
    today_watch: ["7 may feel emotionally unavailable today — don't push for depth when detachment is up"],
  },
  '1_8': {
    core: "Two builders with very different timelines. 1 wants results now, 8 knows they come with time. Both ultimately want the same thing — legacy.",
    strength: "Deep mutual respect for work ethic. Neither finds the other lazy.",
    tension: "1's impatience vs 8's slowness. Recognition dynamics — both want to be seen.",
    romantic: "Built on mutual respect. Not passionate in the conventional sense — durable.",
    friendship: "The most reliable long-term friendship. Shows up through hardship.",
    growth: "1 learns patience. 8 learns to celebrate progress, not just completion.",
    today_boost: ["Shared discipline energy — good day for sustained joint work"],
    today_watch: ["Ego tension possible — both want credit today"],
  },
  '1_9': {
    core: "Fire on fire. The most energized combination. When directed well — unstoppable. When misdirected — combustible.",
    strength: "Shared courage, ambition, and willingness to fight for what matters",
    tension: "Two explosive tempers. When they fight, it's memorable and damaging.",
    romantic: "Intensely attractive and intensely volatile. The relationship that's never boring.",
    friendship: "The most loyal and combustible friendship. Will defend each other to anyone else.",
    growth: "Both learn that not every battle is worth fighting.",
    today_boost: ["Maximum combined energy — bold joint moves, competitive situations, anything requiring courage"],
    today_watch: ["Explosive argument risk elevated — one trigger away from a memorable fight today"],
  },
  '2_2': {
    core: "Maximum emotional depth. The most sensitively attuned combination. Beautiful when both are in a good place. Devastating when both are in a bad one.",
    strength: "Mutual understanding at a level others can't provide. Neither has to explain.",
    tension: "When both are down, there's no ballast. Mood contagion runs both ways.",
    romantic: "Deeply intimate. The relationship that feels psychic. Requires both to maintain individual stability.",
    friendship: "The most emotionally close friendship. Shares everything. Can become codependent.",
    growth: "Both learn to maintain individual emotional regulation.",
    today_boost: ["Creative work together peaks today — the artistic and emotional output is extraordinary"],
    today_watch: ["If one is off, the other will be too — check in before connecting today"],
  },
  '2_3': {
    core: "Empathy meets wisdom. Naturally enriching — 2 provides emotional intelligence, 3 provides sound judgment. Each grows through the other.",
    strength: "2 helps 3 be less rigid. 3 helps 2 be less reactive.",
    tension: "3's judgment can feel like criticism to 2's sensitivity. 2's emotions can feel overwhelming to 3.",
    romantic: "Grounded and caring. Not the most passionate — the most reliable.",
    friendship: "The advice friendship. 3 gives it, 2 receives it (and eventually gives back).",
    growth: "2 learns clarity. 3 learns to lead with heart before head.",
    today_boost: ["Good day for meaningful conversations — 2's emotional intelligence + 3's wisdom land well together"],
    today_watch: ["3 may be more judgmental than usual today — 2 will feel it acutely"],
  },
  '2_4': {
    core: "Emotional sensitivity meets Rahu's unpredictability. Together they can create remarkable creative work — or mutual chaos.",
    strength: "Both highly creative. 2's emotional depth + 4's unconventional mind = original output",
    tension: "4's instability amplifies 2's anxiety. Financial decisions together are particularly risky.",
    romantic: "Exciting and complicated. 4's unpredictability triggers 2's abandonment fears.",
    friendship: "Creative but unreliable. Great for projects, difficult for stable support.",
    growth: "2 learns not to make 4's stability their responsibility. 4 learns consistency has value.",
    today_boost: ["Creative projects benefit from both energies today"],
    today_watch: ["Financial and practical matters should be handled separately today"],
  },
  '2_5': {
    core: "Heart meets calculator. 2 brings emotional depth, 5 brings sharp intelligence. Together they can communicate and create in ways neither can alone.",
    strength: "5's clarity helps 2 articulate what they feel. 2's depth gives 5's ideas genuine warmth.",
    tension: "5 can feel cold to 2's sensitivity. 2 can feel overwhelming to 5's logic.",
    romantic: "Works when 5 learns emotional language. 2 needs to hear it — 5 needs to say it.",
    friendship: "The friend who understands you (2) and the friend who explains you to yourself (5).",
    growth: "5 learns emotional expression. 2 learns intellectual clarity.",
    today_boost: ["Communication is strong today — writing, presenting, important conversations all favored"],
    today_watch: ["5 may feel 2 is being irrational today — 2 may feel 5 is being cold"],
  },
  '2_6': {
    core: "Two of the most emotionally and creatively gifted numbers. Together — extraordinary beauty and depth. The most aesthetically and relationally rich combination.",
    strength: "Maximum creative and romantic potential. Warmth, beauty, depth all present.",
    tension: "Both sensitive, both have sharp tongues when hurt. Both can withdraw.",
    romantic: "One of the most romantically charged combinations. High highs, complicated lows.",
    friendship: "The creative friendship that produces something beautiful together.",
    growth: "Both learn that depth doesn't require drama.",
    today_boost: ["Most romantically and creatively charged day of the current cycle together"],
    today_watch: ["Sharp words from either direction land especially hard today"],
  },
  '2_7': {
    core: "Emotional depth meets philosophical depth. Together they can access insight that neither reaches alone. Requires 7 to stay present.",
    strength: "Deep mutual understanding. 2 feels, 7 understands. Both operate below the surface.",
    tension: "7's detachment leaves 2 feeling unseen. 2's need for closeness overwhelms 7.",
    romantic: "Deeply unusual and often profound. Works when 7 commits to presence.",
    friendship: "The most philosophically enriching friendship, if 7 doesn't vanish.",
    growth: "2 learns that detachment isn't rejection. 7 learns to stay.",
    today_boost: ["Intuitive connection peaks today — the right thing to say arrives without trying"],
    today_watch: ["7 may feel more detached than usual today — 2 shouldn't interpret this personally"],
  },
  '2_8': {
    core: "The deepest giver and the deepest worker. Both give more than they ask for. Together they build something genuinely lasting — if resentment doesn't accumulate.",
    strength: "Extraordinary mutual loyalty. Neither gives up easily.",
    tension: "Both give and neither asks. The unspoken needs accumulate into distance.",
    romantic: "One of the most durable romantic combinations. The love that survives everything.",
    friendship: "The friendship that shows up for every crisis without being asked.",
    growth: "Both learn to ask explicitly for what they need.",
    today_boost: ["Mutual support energy is strong — good day to show up for each other"],
    today_watch: ["Neither will ask for what they need today — one of you needs to break the pattern"],
  },
  '2_9': {
    core: "Emotional depth meets warrior energy. 2 softens 9, 9 activates 2. One of the most passionate combinations.",
    strength: "9 protects 2 fiercely. 2 grounds 9's volatility with genuine care.",
    tension: "9's explosiveness shatters 2's sensitivity. The fights can be devastating.",
    romantic: "Intensely romantic and intensely volatile. The relationship that feels like a novel.",
    friendship: "9 defends 2 to anyone. 2 is the emotional anchor 9 doesn't know they need.",
    growth: "9 learns that 2's sensitivity is not weakness. 2 learns that 9's anger is not abandonment.",
    today_boost: ["Passionate energy available — channeled into creative or physical shared activity"],
    today_watch: ["9's frustration today could hurt 2 deeply — 9 needs to watch the edge"],
  },
  '3_3': {
    core: "Double wisdom. The most intellectually and ethically aligned combination. Deeply enriching — and occasionally rigid.",
    strength: "Shared values, shared worldview, mutual respect for knowledge",
    tension: "Both think they're right. Moral debates that go nowhere.",
    romantic: "Deeply respectful. Occasionally too principled to be spontaneous.",
    friendship: "The philosophical friendship. Will still be friends in 40 years.",
    growth: "Both learn that being right isn't always the point.",
    today_boost: ["Strategic and advisory conversations at peak — planning together lands well today"],
    today_watch: ["Neither will back down from a principled position today"],
  },
  '3_4': {
    core: "Wisdom meets unconventional thinking. 3 provides the ethical frame, 4 provides the novel angle. Together they can produce genuinely original work.",
    strength: "Research ability combined with wisdom = rare insight",
    tension: "3 finds 4's chaos frustrating. 4 finds 3's rules limiting.",
    romantic: "Unusual pairing. Works better as intellectual partnership than romance.",
    friendship: "The researcher (4) and the sage (3). Genuinely enriching if 4 shows up.",
    growth: "3 learns flexibility. 4 learns that structure enables creativity.",
    today_boost: ["Research and unconventional thinking together — good day for problem-solving"],
    today_watch: ["Financial joint decisions need verification today"],
  },
  '3_5': {
    core: "The two best business-wisdom combinations. Expertise meets commercial intelligence. One of the strongest professional pairings.",
    strength: "3 provides credibility and ethical grounding. 5 provides financial sharpness.",
    tension: "3 may find 5 too transactional. 5 may find 3 too principled for business.",
    romantic: "Intellectually rich but requires deliberate emotional investment from both.",
    friendship: "The power duo that gets things done ethically.",
    growth: "3 learns commercial thinking. 5 learns that ethics is competitive advantage.",
    today_boost: ["Expert business conversations, deals, and advisory work all peak today together"],
    today_watch: ["5 may push for a shortcut that 3 won't accept — the disagreement is productive"],
  },
  '3_6': {
    core: "Wisdom meets beauty. 3 provides values and substance, 6 provides warmth and aesthetic richness. Together they create deeply meaningful and beautiful things.",
    strength: "3's depth + 6's warmth = the most complete person combination",
    tension: "3's rigidity vs 6's desire for beauty without judgment",
    romantic: "Marriage-quality combination. Deeply aligned on what matters.",
    friendship: "The advisor friend (3) and the beautiful one (6). Each makes the other more.",
    growth: "3 learns aesthetic appreciation. 6 learns that substance outlasts beauty.",
    today_boost: ["Creative work with ethical grounding — the best day for values-aligned joint projects"],
    today_watch: ["3 may hold 6 to standards that feel heavy today"],
  },
  '3_7': {
    core: "Wisdom meets fortune and seeking. Together they go deeper than either goes alone. Philosophically and spiritually the richest combination.",
    strength: "Shared love of knowledge, depth, and meaning. Lucky together.",
    tension: "7's instability frustrates 3's need for consistency.",
    romantic: "Philosophically profound. Requires 7 to stay committed.",
    friendship: "The most intellectually enriching friendship possible.",
    growth: "3 learns to trust the journey. 7 learns to commit to the destination.",
    today_boost: ["Deep conversations, travel, and philosophical exploration — peak day together"],
    today_watch: ["7 may want to change plans today — 3 may resist"],
  },
  '3_8': {
    core: "Wisdom and karma running together. Both understand that what's worth building takes time. Deep mutual respect.",
    strength: "Shared patience, shared ethics, shared work ethic",
    tension: "Can become too serious. Joy needs to be deliberately scheduled.",
    romantic: "Deeply durable. The relationship that builds a legacy.",
    friendship: "The most reliable long-term friendship. Neither leaves when it gets hard.",
    growth: "Both learn to celebrate the journey, not just the destination.",
    today_boost: ["Long-term planning and sustained joint work peak today"],
    today_watch: ["Both may be too serious today — lighten deliberately"],
  },
  '3_9': {
    core: "The principled sage and the courageous warrior. Together they fight for what's right. One of the most effective activist and leadership combinations.",
    strength: "3's wisdom + 9's courage = principled action that actually lands",
    tension: "3 wants to think first, 9 wants to act first. Always.",
    romantic: "Deeply principled and passionate. The relationship with a shared mission.",
    friendship: "The friendship that changes things together.",
    growth: "3 learns to act before all information is in. 9 learns to think before acting.",
    today_boost: ["Bold principled joint action — advocacy, leadership, and competition all peak"],
    today_watch: ["9 may move faster than 3 is ready for today"],
  },
  '4_4': {
    core: "Double Rahu. Maximum creative potential and maximum instability simultaneously. Everything is amplified.",
    strength: "Unconventional thinking at extraordinary levels. Together they see what others miss.",
    tension: "Financial chaos when combined. Neither provides stability.",
    romantic: "Exciting and exhausting in equal measure. Unlikely to be boring.",
    friendship: "The adventure friendship that's full of stories and empty of stability.",
    growth: "Both desperately need external structure they won't naturally create.",
    today_boost: ["Most original and unconventional thinking available — creative problems get solved"],
    today_watch: ["Financial matters today require external input — don't decide together alone"],
  },
  '4_5': {
    core: "Financial Bandhan potential. 4's impulsiveness + 5's business sharpness can either build or deplete quickly.",
    strength: "5's intelligence can channel 4's ideas into viable business",
    tension: "4 spends, 5 calculates — but may calculate wrong because 4's chaos affects 5's clarity",
    romantic: "Intellectually stimulating and financially complicated.",
    friendship: "Good for ideas, difficult for money matters together.",
    growth: "4 learns verification. 5 learns to budget against 4's impulsiveness.",
    today_boost: ["Business ideas and research together — interesting day for brainstorming"],
    today_watch: ["Keep finances completely separate today"],
  },
  '4_6': {
    core: "Unexpected beauty. 4 brings originality, 6 brings aesthetic richness. Together they produce creative work that surprises.",
    strength: "Original and beautiful output when combined",
    tension: "4's instability is hard for 6's need for aesthetic harmony",
    romantic: "Initially very exciting. Long-term requires 4 to provide more stability.",
    friendship: "Creative and socially interesting.",
    growth: "4 learns to honor 6's need for harmony. 6 learns to embrace 4's chaos.",
    today_boost: ["Creative and aesthetic projects — unconventional beauty available today"],
    today_watch: ["Financial complications possible through relationship today"],
  },
  '4_7': {
    core: "Two shadow planets together. The deepest internal complexity. Both are seeking something beyond the surface. Together they can go profoundly deep — or profoundly destabilized.",
    strength: "Neither judges the other's seeking. Mutual understanding of restlessness.",
    tension: "Maximum instability. Neither provides grounding.",
    romantic: "Spiritually profound and practically chaotic.",
    friendship: "The most interesting friendship to have — difficult to rely on.",
    growth: "Both need to build one anchor each before they can anchor each other.",
    today_boost: ["Spiritual and philosophical depth available — good day for honest existential conversations"],
    today_watch: ["Practical and financial matters need to wait — neither is grounded today"],
  },
  '4_8': {
    core: "Rahu meets karma. 4's fast decisions + 8's deliberate patience = perpetual timing conflict.",
    strength: "8's patience can eventually bring out 4's best",
    tension: "The most chronically misaligned timing combination.",
    romantic: "Requires extraordinary patience from 8.",
    friendship: "8 will always be the reliable one. The question is whether 8 resents it.",
    growth: "4 learns that 8's slowness is wisdom. 8 learns that 4's speed occasionally wins.",
    today_boost: ["8's karmic energy can steady 4's chaos today if 8 holds firm"],
    today_watch: ["Accident risk elevated when these two are in action together today"],
  },
  '4_9': {
    core: "Bandhan combination. Both feel constrained together — not by each other but by circumstances their combination creates.",
    strength: "Maximum physical and intellectual energy — extraordinary output when directed",
    tension: "Legal risks, frustration cycles, the feeling of being trapped together",
    romantic: "Passionate and complicated. The feeling of being unable to leave and unable to stay.",
    friendship: "Intense and occasionally turbulent.",
    growth: "Both need to understand which constraints are real vs self-created.",
    today_boost: ["Physical activities and competitive situations together work today"],
    today_watch: ["Do not make joint legal or financial decisions today"],
  },
  '5_5': {
    core: "Double Mercury. The sharpest and potentially most financially successful combination. Also the most anxious.",
    strength: "Business together is exceptional. Both read opportunities and people accurately.",
    tension: "Overthinking amplified. Both can spiral into anxiety simultaneously.",
    romantic: "Intellectually electric. Requires both to develop emotional language.",
    friendship: "The power business friendship that makes money together.",
    growth: "Both learn that the relationship needs to be an end in itself, not a means to efficiency.",
    today_boost: ["Most financially sharp day together — business decisions and negotiations peak"],
    today_watch: ["Anxiety can double today — check in on each other's mental load"],
  },
  '5_6': {
    core: "Business meets beauty. Commerce and aesthetics. Together they can build something that makes money AND looks extraordinary.",
    strength: "5's intelligence + 6's aesthetic = creative commerce at its best",
    tension: "5 optimizes, 6 indulges. Spending patterns differ fundamentally.",
    romantic: "The relationship that looks amazing from the outside.",
    friendship: "The successful-and-stylish duo.",
    growth: "5 learns to appreciate beauty as value. 6 learns that optimization isn't soulless.",
    today_boost: ["Creative business, presentations, and aesthetic-commercial projects peak together"],
    today_watch: ["Financial decisions involving luxury today need scrutiny"],
  },
  '5_7': {
    core: "Easy Money combination. Financial luck runs through this pairing consistently. One of the most fortunate financial combinations.",
    strength: "Lucky together financially. The right opportunities arrive more often than average.",
    tension: "Easy come, easy go. Neither naturally saves from what arrives together.",
    romantic: "Fortunate and interesting. 7's depth balances 5's calculation.",
    friendship: "The friendship where things just work out.",
    growth: "Both learn to hold what luck brings instead of cycling through it.",
    today_boost: ["Financial luck structurally active — good day for shared financial decisions"],
    today_watch: ["Save something from what arrives today — the luck doesn't manage itself"],
  },
  '5_8': {
    core: "Sharp intelligence meets karmic discipline. One of the most methodical and financially sound combinations.",
    strength: "5's intelligence + 8's patience = the most reliable financial decisions",
    tension: "5 moves fast, 8 moves deliberately. Timing clashes constantly.",
    romantic: "Built on intellectual respect. Not passionate — reliable.",
    friendship: "The business partnership that lasts decades.",
    growth: "5 learns 8's patience pays compound interest. 8 learns 5's speed occasionally wins windows.",
    today_boost: ["Methodical financial and business decisions together — the analysis is sharp today"],
    today_watch: ["5 wants to move faster than 8 is ready — coordinate before acting"],
  },
  '5_9': {
    core: "Street smart meets warrior. Two of the most competitive numbers together. Business partnerships here can be extraordinarily successful.",
    strength: "Maximum business and competitive instinct. Neither slows the other down.",
    tension: "Both want to win. Conflict over direction of the shared energy.",
    romantic: "Competitive and passionate. Works when both can be on the same team.",
    friendship: "The most competitive and commercially successful friendship.",
    growth: "Both learn that competing with the world is better than competing with each other.",
    today_boost: ["Most commercially sharp day together — business moves, negotiations, competitive situations"],
    today_watch: ["Keep the competition directed outward — internal competition is wasteful today"],
  },
  '6_6': {
    core: "Double Venus. Maximum beauty, warmth, social grace — and maximum sharpness when hurt. The most aesthetically extraordinary combination.",
    strength: "The most beautiful social and creative pairing. Everything they create together is extraordinary.",
    tension: "Both have sharp tongues. Both have high standards. The disappointment cycles.",
    romantic: "Extraordinarily beautiful together. The relationship everyone envies.",
    friendship: "The most socially stunning friendship.",
    growth: "Both learn that beauty doesn't require perfection — including in each other.",
    today_boost: ["Creative and social peaks — the most beautiful day for joint expression"],
    today_watch: ["Words spoken in frustration today between these two will be remembered"],
  },
  '6_7': {
    core: "Beauty meets fortune. One of the most aesthetically and financially lucky combinations. What they create together tends to be both beautiful and successful.",
    strength: "7's luck + 6's beauty = outcomes that look effortless from the outside",
    tension: "7's detachment leaves 6 feeling unappreciated.",
    romantic: "One of the most fortunate romantic combinations. Lucky and beautiful.",
    friendship: "The friend group everyone wants to be part of.",
    growth: "7 learns to appreciate what 6 creates. 6 learns that 7's detachment isn't indifference.",
    today_boost: ["Lucky and beautiful day together — social events, creative work, romantic investment"],
    today_watch: ["7 may seem distant today — 6 shouldn't interpret this as disinterest"],
  },
  '6_8': {
    core: "Beauty earned through effort. 6 wants luxury, 8 earns it slowly. Together they build beautiful things that last.",
    strength: "8's effort + 6's taste = earned luxury that's genuinely appreciated",
    tension: "6 wants it now, 8 says wait. Timing tension throughout.",
    romantic: "The beautiful home and life built over time.",
    friendship: "6 inspires 8 to appreciate beauty. 8 grounds 6's indulgence.",
    growth: "6 learns that earned beauty satisfies more. 8 learns that beauty is not frivolous.",
    today_boost: ["Long-term creative and aesthetic work together peaks today"],
    today_watch: ["6 may feel 8 is not moving fast enough on something today"],
  },
  '6_9': {
    core: "Passion meets beauty. The most romantically intense and aesthetically rich combination. Also the most volatile.",
    strength: "Maximum romantic chemistry. The relationship that produces extraordinary creative and physical output.",
    tension: "9's temper + 6's sharp tongue = fights that leave marks",
    romantic: "The most romantically charged combination. Never boring. Sometimes devastating.",
    friendship: "Intensely loyal and occasionally explosive.",
    growth: "9 learns 6's words are weapons. 6 learns 9's anger is temporary.",
    today_boost: ["Most romantic and passionate day together — channel into creative work or quality time"],
    today_watch: ["Argument today between these two will be memorable — both are running hot"],
  },
  '7_7': {
    core: "Double Ketu. Maximum intuition, maximum instability. Together they understand each other at a level that's almost psychic — and can vanish on each other without warning.",
    strength: "The deepest mutual understanding possible. Nobody judges the other's seeking.",
    tension: "Double instability. When both are unsettled, there's no anchor.",
    romantic: "Profound and unpredictable. Neither can fully commit.",
    friendship: "The friendship where both can disappear for months and return like it was yesterday.",
    growth: "Both need an external anchor — a practice, a place, a commitment.",
    today_boost: ["Psychic-level intuitive connection — the right thing to say arrives without effort"],
    today_watch: ["Neither is grounded today — practical decisions should wait"],
  },
  '7_8': {
    core: "Spiritual luck meets karmic discipline. 7's fortune can lift 8's heaviness. 8's discipline can ground 7's instability. When it works — transformative.",
    strength: "7's luck arrives at exactly the moment 8's effort has built the foundation",
    tension: "7's detachment frustrates 8's need for acknowledgment. 8's heaviness dampens 7's lightness.",
    romantic: "Spiritually profound and practically challenging.",
    friendship: "The friendship where 8 does the work and 7 provides the unexpected breakthrough.",
    growth: "7 learns to work alongside luck. 8 learns to trust what they can't control.",
    today_boost: ["Patience meets fortune today — unexpected breakthrough in a long-standing effort"],
    today_watch: ["8 may feel 7 is not taking things seriously enough today"],
  },
  '7_9': {
    core: "Lucky warrior. 7's fortune protects 9's bold moves. Together they take bigger risks and have them pay off more often than probability suggests.",
    strength: "Fortune + courage = bold moves that actually work",
    tension: "9's explosiveness can destroy what 7's luck built.",
    romantic: "Fortunate and passionate. The bold decisions together tend to work out.",
    friendship: "The friendship where 9 charges and 7's luck somehow makes it land.",
    growth: "9 learns to pause before 7's luck runs out. 7 learns that courage is required, not just fortune.",
    today_boost: ["Bold joint moves are protected today — good day for the decision that requires courage"],
    today_watch: ["9 may push too hard today — 7's luck has limits"],
  },
  '8_8': {
    core: "Double Saturn. The most karmic combination. Peak loyalty, peak patience — and the most accumulated unexpressed needs. Both give everything and neither asks.",
    strength: "Unbreakable loyalty. The friendship or love that survives decades.",
    tension: "Both suppress needs indefinitely. The resentment that builds in silence.",
    romantic: "The marriage that lasts forever — for better or worse.",
    friendship: "The most reliable friend you will ever have — and the most emotionally unexpressed.",
    growth: "Both desperately need to learn to ask for what they need.",
    today_boost: ["Long-term work together peaks — what you build today lasts"],
    today_watch: ["Neither will ask for what they need today — one of you has to go first"],
  },
  '8_9': {
    core: "Discipline meets passion. 8's slow build + 9's explosive energy = maximum output when aligned. Also the most exhausting combination.",
    strength: "Extraordinary productive output. 9 generates, 8 sustains.",
    tension: "9's impatience with 8's pace. 8's frustration with 9's recklessness.",
    romantic: "Passionate and demanding. Both give everything — both need everything.",
    friendship: "The friend who runs (9) and the one who makes sure they don't fall (8).",
    growth: "9 learns that 8's slowness is sustainability. 8 learns that 9's speed creates opportunities.",
    today_boost: ["Maximum productive energy together — physical and professional output peaks"],
    today_watch: ["Explosive argument risk if 9 pushes 8 past their threshold today"],
  },
  '9_9': {
    core: "Double Mars. Maximum energy, maximum passion, maximum volatility. When directed together — unstoppable. When directed at each other — unforgettable conflict.",
    strength: "The most energized and courageous combination. Nothing intimidates them together.",
    tension: "When they fight each other, the collateral damage is significant.",
    romantic: "Intensely passionate. The relationship that burns brightest.",
    friendship: "Will fight for each other to the end — and occasionally fight each other to the end.",
    growth: "Both need to commit to directing energy outward, not inward.",
    today_boost: ["Maximum combined courage and energy — the boldest joint actions are possible today"],
    today_watch: ["Internal conflict today between these two will be explosive — redirect outward deliberately"],
  },
};

// ─── Today's combined energy ──────────────────────────────────────────────────
// What happens when two daily numbers meet
export function getTodayCompatibility(daily1, daily2, basic1, basic2, periods1 = [], periods2 = [], yogas1 = [], yogas2 = []) {
  const pair = [Math.min(daily1, daily2), Math.max(daily1, daily2)].join('_');
  const sameNum = daily1 === daily2;

  // Score logic — book-accurate planetary relationships for daily numbers
  const PLANET_RELS_TODAY = {
    1:{f:[3,9,5],e:[2,7]}, 2:{f:[1,3],e:[4,5,8]}, 3:{f:[1,2,9],e:[5,6]},
    4:{f:[4,6,7],e:[1,2,8]}, 5:{f:[1,4],e:[2,3,9]}, 6:{f:[4,5],e:[1,2,3]},
    7:{f:[4,6],e:[1,2]}, 8:{f:[4,5,6],e:[1,2,3]}, 9:{f:[1,2,3],e:[5,6]},
  };
  function getTodayRel(a,b) {
    const r=PLANET_RELS_TODAY[a]; if(!r) return 'n';
    if(r.f.includes(b)) return 'f'; if(r.e.includes(b)) return 'e'; return 'n';
  }
  function todayPts(r){return r==='f'?3:r==='n'?1:0;}

  // Daily relationship (both directions)
  const dr1 = getTodayRel(daily1, daily2);
  const dr2 = getTodayRel(daily2, daily1);
  let dailyPts = (todayPts(dr1) + todayPts(dr2)) / 2; // 0-3
  let score = Math.round((dailyPts / 3) * 100); // raw 0-100

  // Period layer for uniqueness — each person's maha/antar affects today
  if (periods1.length >= 2 && periods2.length >= 2) {
    const [maha1num, antar1num, monthly1num] = periods1;
    const [maha2num, antar2num, monthly2num] = periods2;
    const mahaRel = getTodayRel(maha1num, maha2num);
    const antarRel = getTodayRel(antar1num, antar2num);
    const monthlyRel = getTodayRel(monthly1num, monthly2num);
    const periodBoost = (todayPts(mahaRel)-1)*8 + (todayPts(antarRel)-1)*5 + (todayPts(monthlyRel)-1)*3;
    score += periodBoost;
  }
  // Basic numbers add base resonance
  score += Math.round(((todayPts(getTodayRel(basic1,basic2))+todayPts(getTodayRel(basic2,basic1)))/2 - 1) * 6);
  score = Math.min(96, Math.max(12, Math.round(score)));

  let energy = score >= 70 ? 'flowing' : score >= 45 ? 'steady' : 'tense';

  let headline = '';
  let detail = '';
  let doTogether = [];
  let watchTogether = [];
  let dayLabel = '';

  if (sameNum) { energy = 'amplified'; }

  // Day label
  const labels = {
    1: 'Authority', 2: 'Connection', 3: 'Clarity', 4: 'Research',
    5: 'Business', 6: 'Harmony', 7: 'Fortune', 8: 'Karma', 9: 'Energy'
  };

  if (sameNum) {
    dayLabel = `${labels[daily1]} × 2`;
    headline = `You're running the same ${labels[daily1].toLowerCase()} energy today — everything is amplified between you.`;
    detail = `When two people run the same daily number, their interaction intensifies in every direction. What's good is very good. What's tense is very tense. Today rewards deliberate connection — don't leave it to chance.`;
    doTogether = [`Channel the shared ${labels[daily1].toLowerCase()} energy into one joint focus`];
    watchTogether = [`Avoid amplifying each other's shadow today — if one is off, the other will mirror it`];
  } else {
    dayLabel = `${labels[daily1]} meets ${labels[daily2]}`;
    headline = _getDayHeadline(daily1, daily2);
    detail = _getDayDetail(daily1, daily2);
    doTogether = _getDayDo(daily1, daily2);
    watchTogether = _getDayWatch(daily1, daily2);
  }

  // Yoga bonus
  const hasEasyMoney1 = yogas1.includes('easy_money');
  const hasEasyMoney2 = yogas2.includes('easy_money');
  if (hasEasyMoney1 || hasEasyMoney2) {
    score = Math.min(95, score + 8);
    doTogether.push('Financial luck is active in this pairing today — act on it');
  }

  return {
    score: Math.min(99, Math.max(10, score)),
    energy,
    day_label: dayLabel,
    headline,
    detail,
    do_together: doTogether.slice(0, 3),
    watch_together: watchTogether.slice(0, 2),
  };
}

function _getDayHeadline(d1, d2) {
  const map = {
    '1_2': "Authority softens into connection today — lead with warmth, not just confidence.",
    '1_3': "Bold decisions backed by wisdom today — the best day for joint strategy.",
    '1_4': "Your direction meets their unpredictability — stay flexible, not rigid.",
    '1_5': "Power and intelligence combined today — exceptional day for business together.",
    '1_6': "Ambition meets beauty today — socially and professionally both peak.",
    '1_7': "Fortune protects your boldness today — good day for the ask.",
    '1_8': "Two builders running different timelines today — patience bridges them.",
    '1_9': "Maximum fire today — channel together before it channels you.",
    '2_3': "Emotional wisdom today — the advice given now lands deeper than usual.",
    '2_4': "Creativity peaks, practicality dips — good day for ideas, not decisions.",
    '2_5': "Heart meets mind today — communication between you flows.",
    '2_6': "Maximum warmth and creativity today — the best day for connection.",
    '2_7': "Intuitive resonance peaks today — you understand each other without words.",
    '2_8': "Deep loyalty runs today — show up for each other without being asked.",
    '2_9': "Passion and sensitivity today — channel it before it combusts.",
    '3_4': "Wisdom tests unconventional thinking today — useful friction.",
    '3_5': "Expert minds together today — best day for joint knowledge work.",
    '3_6': "Values meet beauty today — deeply satisfying joint creative work.",
    '3_7': "Philosophical depth today — the best conversation you'll have this week.",
    '3_8': "Two patient builders today — long-term thinking pays off.",
    '3_9': "Principled courage today — good day to stand for something together.",
    '4_5': "Ideas meet intelligence today — brainstorm freely, verify before executing.",
    '4_6': "Unconventional beauty today — surprising creative output.",
    '4_7': "Two seekers today — deep conversation, minimal practical output.",
    '4_8': "Chaos meets patience today — 8 grounds 4's impulses.",
    '4_9': "Explosive energy today — physical activity channels it best.",
    '5_6': "Business meets beauty today — commercial and aesthetic both peak.",
    '5_7': "Financial luck active today — the right opportunity should be acted on.",
    '5_8': "Sharp methodical thinking today — the joint financial decision is sound.",
    '5_9': "Street smart warrior day — most commercially sharp together.",
    '6_7': "Beautiful and lucky today — the best social and romantic day.",
    '6_8': "Earned beauty today — the long-term creative effort shows.",
    '6_9': "Passion and beauty peak today — channel into quality time.",
    '7_8': "Luck meets persistence today — an unexpected breakthrough is possible.",
    '7_9': "Fortunate courage today — bold joint moves are protected.",
    '8_9': "Maximum sustained output today — the most productive day together.",
  };
  const key = [Math.min(d1,d2), Math.max(d1,d2)].join('_');
  return map[key] || `${d1} meets ${d2} — interesting day between you.`;
}

function _getDayDetail(d1, d2) {
  const map = {
    '1_2': "One of you is in authority mode, the other in connection mode. This creates a natural dynamic — the bold one leads, the sensitive one reads the room. Together you cover both fronts.",
    '1_3': "Strategy and wisdom together. Whatever you decide today has both speed and soundness behind it. The rare day where moving fast and moving right are the same direction.",
    '1_4': "Your drive meets their originality. The friction is productive if you stay curious rather than controlling. The unconventional angle they bring today is probably the right one.",
    '1_5': "Two of the sharpest business-oriented energies running simultaneously. The deals, negotiations, and decisions you make together today will hold. Don't waste this window.",
    '1_6': "Confidence and charm together. Whatever you present today lands — socially, professionally, romantically. The audience reads you as a unit worth watching.",
    '1_7': "Fortune is structurally behind the bold moves today. The ask that seemed too big — today is the day to make it, together.",
    '1_8': "One of you wants to move, one wants to wait. The patience isn't stubbornness — it's compounding. Trust it today.",
    '1_9': "Two fire energies. Whatever you aim at together today gets hit. The only variable is whether you're aiming at the same thing.",
    '2_3': "Your emotional intelligence and their wisdom working simultaneously. The insight produced today isn't available on most other days. Write it down.",
    '2_4': "Creative energy is extraordinary. Practical capacity is low. Today is for generating, not executing. The ideas that emerge deserve next week's attention.",
    '2_5': "The heart understands what the mind is trying to say, and the mind can articulate what the heart feels. Rare clarity in communication today.",
    '2_6': "Maximum warmth between you today. Whatever you do together feels richer than usual. This is one of those days that becomes a memory.",
    '2_7': "You understand each other's unspoken things today with unusual accuracy. Trust the read — it's more reliable than usual.",
    '2_8': "Both of you are in giving mode today. The risk is that neither asks for what they need. One of you needs to break the pattern.",
    '2_9': "Emotional depth meets passionate intensity. The connection available today is real — and so is the volatile edge. Choose which one to lean into.",
    '3_4': "Wisdom stress-tests unconventional ideas. The friction between you today is productive — 4's ideas need 3's scrutiny, and 3's certainty needs 4's challenge.",
    '3_5': "Both minds operating at high capacity. The analysis you produce together today is the most reliable of the cycle.",
    '3_6': "Values and beauty converging. Whatever you create together today has both substance and soul. Rare combination.",
    '3_7': "One of the deepest conversations available in this pairing. The insight that arrives today reorients things. Make the time.",
    '3_8': "Patient wisdom and patient work. The foundation laid today doesn't show immediately — but it lasts.",
    '3_9': "The conviction to know what's right and the courage to do it. The principled bold move today has both behind it.",
    '4_5': "Original thinking + commercial intelligence. The business idea today is genuinely interesting. Verify before executing — the enthusiasm is real but so is the Rahu.",
    '4_6': "Unexpected and beautiful. Whatever you create together today has an originality that surprises even you.",
    '4_7': "Both running deep seeking energy. The conversation today goes somewhere most conversations don't. Light on practical output, heavy on insight.",
    '4_8': "The chaos today finds an unlikely counterweight in the patience. 8 grounds what 4 generates. Useful dynamic if both accept their role.",
    '4_9': "Maximum physical and explosive energy. The only productive outlet today is physical activity together. Everything else is likely to combust.",
    '5_6': "The commercial and the beautiful peak simultaneously. The presentation, the pitch, the creative business decision — all favored today.",
    '5_7': "Easy Money energy active. The financial opportunity that arrives today between you is real. Act on it before analysis delays it past the window.",
    '5_8': "The most methodical financial thinking available. The joint decision today is built on sound analysis and patient execution. Make the important financial move.",
    '5_9': "Street smart and competitive. The business instinct today is sharper together than alone. Move before the window closes.",
    '6_7': "Lucky and beautiful. The social and romantic day between you peaks. Whatever you plan today, something better than planned tends to happen.",
    '6_8': "The creative effort finally becoming visible. Today is the day the long-term project shows its first real results.",
    '6_9': "The most romantically charged day in this pairing's cycle. Quality time today creates quality memory. Worth protecting.",
    '7_8': "The unexpected breakthrough in the sustained effort. 7's luck arrives precisely when 8's work has built the foundation. Today is that day.",
    '7_9': "Fortune backing courage. The bold move that seemed risky — today it's protected. Make it together.",
    '8_9': "Maximum sustained output. The combination of 8's discipline and 9's energy produces more today than either produces alone. High output, high physical cost.",
  };
  const key = [Math.min(d1,d2), Math.max(d1,d2)].join('_');
  return map[key] || "Your energies are running in interesting parallel today. Pay attention to what emerges between you.";
}

function _getDayDo(d1, d2) {
  const map = {
    '1_2': ["Have the important conversation — authority + sensitivity = rare honesty", "Make the ask together — you're more persuasive as a unit today"],
    '1_3': ["Make the joint strategic decision that's been pending", "Take the bold move that wisdom has been preparing"],
    '1_4': ["Let their unconventional angle inform your direction", "Brainstorm before executing — the idea today is worth capturing"],
    '1_5': ["Close the deal or negotiate the important thing", "Make any shared financial or professional move today"],
    '1_6': ["Show up together publicly — you read as a unit worth watching", "Express appreciation — it lands better today than most days"],
    '1_7': ["Make the ask that requires fortune to back it", "Say yes to the opportunity that presents itself"],
    '1_8': ["Start the thing that requires both launch energy and sustained effort", "Trust 8's timeline today — it's right even when slow"],
    '1_9': ["Direct the combined fire at an external challenge", "Compete together — you're strongest as a unit today"],
    '2_3': ["Have the deep conversation that requires both feeling and wisdom", "Create something that requires both emotional truth and sound judgment"],
    '2_4': ["Generate without filtering — let the ideas flow freely today", "Creative output — don't worry about practical viability yet"],
    '2_5': ["Communicate what's been hard to say — it will land today", "Collaborate on anything that requires both emotional and intellectual intelligence"],
    '2_6': ["Spend quality time without agenda — today just being together is the point", "Create something beautiful together"],
    '2_7': ["Trust the intuitive reads on each other today — they're accurate", "Go deep — the surface conversation is a waste of today"],
    '2_8': ["One of you needs to ask for what you need — break the silence", "Show up for each other without waiting to be asked"],
    '2_9': ["Channel the intensity into physical activity or creative passion", "Express the depth of the connection — it wants to be said today"],
    '3_4': ["Let 3's wisdom stress-test 4's idea — the friction is productive", "Research together — the depth today is genuine"],
    '3_5': ["Make the expert decision — your combined analysis today is the most reliable", "Write, plan, or strategize — the output will hold"],
    '3_6': ["Create something that has both substance and beauty", "Have the values conversation — you're aligned more than you know"],
    '3_7': ["Have the philosophical conversation — it goes somewhere today", "Travel or change scene together — the insight arrives in movement"],
    '3_8': ["Work on the long-term project together — today's foundation lasts", "Make the patient, ethical decision together"],
    '3_9': ["Take the principled bold stand together", "Advocate for something that matters — the combination is powerful today"],
    '4_5': ["Brainstorm freely — the commercial idea today is interesting", "Let intelligence verify what originality generates"],
    '4_6': ["Create something with unconventional beauty", "Let the surprise in today's collaboration happen"],
    '5_6': ["Make the commercial creative move", "Present or pitch together — you're most persuasive today"],
    '5_7': ["Act on the financial opportunity — today's luck is structural", "Make the financial decision together"],
    '5_8': ["Make the important joint financial decision", "Plan long-term financial strategy together"],
    '5_9': ["Execute the competitive business move", "Negotiate or close together — street smart energy peaks"],
    '6_7': ["Make plans and let them become something better", "Romantic or social investment today — it compounds"],
    '6_8': ["Celebrate the long-term creative effort that's finally showing", "Invest in something beautiful together that will last"],
    '6_9': ["Spend quality time — this is the most romantically charged day", "Create something passionate together"],
    '7_8': ["Make the move that luck and effort together have prepared", "Trust the unexpected opportunity today — it's real"],
    '7_9': ["Make the bold joint move — fortune is behind it", "Take the risk that courage and luck together make reasonable"],
    '8_9': ["High-output work together — physical or professional", "Complete the demanding joint project"],
  };
  const key = [Math.min(d1,d2), Math.max(d1,d2)].join('_');
  return map[key] || ["Spend intentional time together today — the energy is worth honoring"];
}

function _getDayWatch(d1, d2) {
  const map = {
    '1_2': ["Check in — the drive mode can miss the emotional undercurrent today", "2 may feel unacknowledged in 1's momentum — one deliberate word fixes it"],
    '1_3': ["3 may hold 1 to ethical standards that feel heavy today — both are right"],
    '1_4': ["Financial decisions together today need external verification", "1's frustration with 4's unpredictability — stay curious"],
    '1_5': ["Cold efficiency today could damage something warm — one of you needs to bring the human element"],
    '1_6': ["Either being disappointed today leads to a disproportionate reaction"],
    '1_7': ["Luck is real but not infinite — don't overextend on the good fortune today"],
    '1_8': ["Ego tension — both want credit today — coordinate explicitly"],
    '1_9': ["One trigger away from a memorable fight — direct energy outward"],
    '2_3': ["3 may be more judgmental than usual today — 2 will feel it acutely"],
    '2_4': ["Keep finances separate today — the combination creates impulsive decisions"],
    '2_5': ["5 may feel 2 is being irrational — 2 may feel 5 is being cold — both are somewhat right"],
    '2_6': ["Sharp words between you today will be remembered longer than usual"],
    '2_7': ["7 is more detached today — 2 shouldn't read abandonment into it"],
    '2_8': ["Neither will ask for what they need — one needs to go first"],
    '2_9': ["9's edge today could cut 2 deeper than 9 intends — 9 needs to watch it"],
    '3_4': ["Joint financial commitments need verification today"],
    '3_5': ["5 may push for a shortcut 3 won't accept — the disagreement is productive, not personal"],
    '3_6': ["3 may hold 6 to standards that feel heavy today"],
    '3_7': ["7 may want to change plans — 3 may resist — compromise"],
    '3_8': ["Both may be too serious today — lightness needs to be deliberate"],
    '3_9': ["9 may move before 3 is ready — coordinate timing explicitly"],
    '4_5': ["Keep finances completely separate today"],
    '4_6': ["Financial complications through the relationship today — keep separate"],
    '5_6': ["Luxury spending today needs scrutiny — the indulgence impulse is elevated"],
    '5_7': ["Save something from what arrives — the luck doesn't manage itself"],
    '5_8': ["5 wants to move faster than 8 is ready — coordinate before acting"],
    '5_9': ["Keep the competition directed outward — internal competition wastes the energy"],
    '6_7': ["7 may seem distant today — 6 shouldn't interpret this as disinterest"],
    '6_8': ["6 may feel 8 is moving too slowly today — trust the timeline"],
    '6_9': ["If it tips into conflict today between these two — the words will leave marks"],
    '7_8': ["8 may feel 7 is not taking things seriously enough — it's 7's way, not disrespect"],
    '7_9': ["9 may push harder than 7's luck can protect — calibrate the boldness"],
    '8_9': ["9's pace may push 8 past their threshold today — check in before the explosion"],
  };
  const key = [Math.min(d1,d2), Math.max(d1,d2)].join('_');
  return map[key] || ["Check in with each other before the day gets away from you"];
}

// ─── Relationship type detector ───────────────────────────────────────────────
export function detectRelationshipInsight(basic1, destiny1, basic2, destiny2) {
  const key = [Math.min(basic1, basic2), Math.max(basic1, basic2)].join('_');
  const pair = PAIR_DYNAMICS[key];

  const destinyKey = [Math.min(destiny1, destiny2), Math.max(destiny1, destiny2)].join('_');
  const destinyPair = PAIR_DYNAMICS[destinyKey];

  return {
    core: pair?.core || "An interesting combination of two distinct energies.",
    strength: pair?.strength || "Each brings something the other lacks.",
    tension: pair?.tension || "The differences require conscious navigation.",
    romantic: pair?.romantic || "Romantic potential depends on individual charts.",
    friendship: pair?.friendship || "As friends: each enriches the other's perspective.",
    growth: pair?.growth || "Both grow by engaging with what the other represents.",
    destiny_note: destinyPair ? `On a life path level: ${destinyPair.core}` : null,
  };
}
