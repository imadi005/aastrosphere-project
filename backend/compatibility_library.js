// ═══════════════════════════════════════════════════════════════════════════════
// AASTROSPHERE — DEEP COMPATIBILITY LIBRARY v2
// All content grounded in Vedic planetary relationships (Lo Shu / Cheiro)
// f_f = mutual friends | f_e = one-sided | e_e = mutual enemies | n_n = neutral
// ═══════════════════════════════════════════════════════════════════════════════

export const PLANET_NAMES_COMPAT = {
  1:'Sun', 2:'Moon', 3:'Jupiter', 4:'Rahu', 5:'Mercury',
  6:'Venus', 7:'Ketu', 8:'Saturn', 9:'Mars',
};

// ─── Planetary relationship map (standard Vedic) ─────────────────────────────
export const VEDIC_RELATIONS = {
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

export function getRelType(a, b) {
  const r = VEDIC_RELATIONS[a];
  if (!r) return 'n';
  if (r.f.includes(b)) return 'f';
  if (r.e.includes(b)) return 'e';
  return 'n';
}

// ─── What each number brings to any relationship ──────────────────────────────
export const NUMBER_IN_RELATIONSHIP = {
  1: {
    brings: "direction, decisiveness, and the confidence that makes others feel protected",
    needs: "genuine admiration, space to lead, acknowledgment that their effort is seen",
    blind_spot: "can dominate without noticing — the room arranges itself around them before anyone objects",
    love_language: "acts of service — shows love by solving, building, protecting, not by saying",
    friendship_style: "the friend you call in a crisis, not the one who checks in daily — shows up when it matters most",
    conflict_style: "direct and forceful, allergic to passive aggression, needs resolution not extended silence",
    planet: "Sun",
  },
  2: {
    brings: "emotional attunement, loyalty that doesn't require asking, and creative depth",
    needs: "genuine reciprocity, to feel truly seen and not just useful, reassurance during silence",
    blind_spot: "absorbs others' emotional states as their own — can lose track of where they end and others begin",
    love_language: "words of affirmation — needs to hear it explicitly, feeling it is not enough",
    friendship_style: "remembers everything, is present at a level that can feel overwhelming, the friend who shows up unrequested",
    conflict_style: "avoids direct confrontation until something snaps, needs time to process before words come, can go cold",
    planet: "Moon",
  },
  3: {
    brings: "wisdom, ethical grounding, and a presence that makes people want to be better",
    needs: "respect for their values, intellectual alignment, family acknowledgment, to be consulted not just heard",
    blind_spot: "holds others to the same standards they hold themselves — the bar is rarely announced and rarely reachable",
    love_language: "acts of service — provides, protects, shows up consistently over time",
    friendship_style: "the advisor, the one who tells you what you need to hear not what you want — rare and valuable",
    conflict_style: "principled and firm, debates with evidence, rarely backs down when they believe they are right",
    planet: "Jupiter",
  },
  4: {
    brings: "unconventional thinking, research depth, and the ability to see what others miss",
    needs: "freedom from rigidity, patience for their chaos, a partner who enjoys the unexpected",
    blind_spot: "starts five things for every one they finish — the graveyard of abandoned projects",
    love_language: "quality time — present but on their own unpredictable schedule",
    friendship_style: "the adventure friend — electric to be around, impossible to rely on for logistics",
    conflict_style: "unpredictable reactions, spirals or vanishes, needs space before they can re-engage",
    planet: "Rahu",
  },
  5: {
    brings: "sharp intelligence, financial clarity, and communication that cuts through noise",
    needs: "intellectual respect, genuine appreciation for their sharpness, financial compatibility",
    blind_spot: "applies calculator logic to emotional situations — correct analysis, wrong instrument",
    love_language: "gift-giving — shows love through quality, through providing, through the thoughtful thing",
    friendship_style: "the friend who solves your problems efficiently, less good at sitting with feelings that have no solution",
    conflict_style: "logical and cutting, can deliver the accurate devastating observation at exactly the wrong moment",
    planet: "Mercury",
  },
  6: {
    brings: "beauty, warmth, social ease, and the ability to make any space feel more alive",
    needs: "aesthetic harmony in the environment, appreciation for what they create, emotional reciprocity",
    blind_spot: "the standard is high and unannounced — most people fail it without ever knowing it existed",
    love_language: "physical touch and quality time — the most physically and aesthetically invested number",
    friendship_style: "socially generous, makes everyone feel welcome, occasionally unreliable when things get hard",
    conflict_style: "can say precisely cutting things when hurt, withdraws when the aesthetic or emotional standard is unmet",
    planet: "Venus",
  },
  7: {
    brings: "philosophical depth, unusual luck, and a quality of attention that makes people feel profoundly understood",
    needs: "intellectual and spiritual resonance, freedom to disappear and return, understanding of their natural detachment",
    blind_spot: "emotional availability is genuinely difficult — not chosen distance, structural absence",
    love_language: "quality time — depth over breadth in all things, the long slow conversation over everything else",
    friendship_style: "the most interesting person in the room who moves cities every few years — profound and unreliable",
    conflict_style: "withdraws completely, very hard to reach when gone, comes back on their own timeline",
    planet: "Ketu",
  },
  8: {
    brings: "unwavering dedication, patience that outlasts everyone else, and a loyalty built over years not weeks",
    needs: "acknowledgment that their sustained effort is seen, emotional validation, consistency in return",
    blind_spot: "carries old hurts the way other people carry keys — quietly, always",
    love_language: "acts of service — gives everything over time, needs to see equivalent investment",
    friendship_style: "the friend who still calls on the hard anniversary ten years later, shows up through difficulty not fun",
    conflict_style: "slow to ignite and deep when it comes, holds grievances in silence, explicit repair is required",
    planet: "Saturn",
  },
  9: {
    brings: "passion, physical protection, competitive fire, and a courage that makes others feel braver",
    needs: "genuine respect, meaningful challenge, freedom to act, honesty over softness",
    blind_spot: "picks battles with the same energy regardless of whether they are worth fighting",
    love_language: "physical touch and direct words — loves loudly and needs to receive the same",
    friendship_style: "will fight for you before you've asked and expect nothing back — the most instinctively loyal number",
    conflict_style: "explosive and direct, fast to anger and sometimes fast to forgive, needs to physically discharge before talking",
    planet: "Mars",
  },
};

// ─── All 45 pair dynamics — grounded in planetary relationship ────────────────
export const PAIR_DYNAMICS = {

  // ══ MUTUAL FRIENDS (f_f) ════════════════════════════════════════════════════

  '1_3': { // Sun friends Jupiter, Jupiter friends Sun
    rel: 'f_f',
    core: "Sun and Jupiter — two of the most naturally aligned planets. Authority meets wisdom. What 1 initiates, 3 gives depth to. What 3 knows, 1 has the nerve to act on. Together they build things that last.",
    strength: "Neither diminishes the other. 1's boldness is grounded by 3's wisdom. 3's knowledge is activated by 1's courage. The decisions they make together are both fast and sound — a rare combination.",
    tension: "1 trusts instinct, 3 trusts judgment. When instinct and judgment disagree, both can be stubborn about who's right.",
    close_connection: "The rare connection that combines drive and wisdom. Each makes the other more complete.",
    friendship: "The friend who tells you what to do (3) and the friend who actually does it (1). Deeply enriching over time.",
    growth: "1 learns that wisdom makes boldness durable. 3 learns that knowledge requires nerve to become useful.",
    today_boost: ["Authority and wisdom running together — strategic decisions made today carry real weight", "Good day for bold conversations that require both confidence and judgment"],
    today_watch: ["3 may hold 1 to ethical standards that feel constraining today — the friction is productive"],
  },

  '1_5': { // Sun friends Mercury, Mercury friends Sun
    rel: 'f_f',
    core: "Sun and Mercury — authority and intelligence in natural alignment. One of the strongest combinations for any practical endeavor. Both are driven by results, both are sharp, both understand that execution matters.",
    strength: "1's confidence creates the space for 5's intelligence to land. 5's analytical precision gives 1's decisions real backing. Together they cover the full spectrum from bold idea to sharp implementation.",
    tension: "Neither naturally slows down for emotional processing. The efficiency can feel cold to people around them — and occasionally to each other.",
    close_connection: "The combination that gets things done at the highest level. Requires deliberate emotional investment to go beyond partnership into genuine depth.",
    friendship: "The power friendship that makes things happen. May occasionally forget to just be present without an agenda.",
    growth: "Both learn that emotional investment is not a distraction from results — it's what makes results sustainable.",
    today_boost: ["Sharp and capable together today — negotiations, financial decisions, and important conversations all peak", "Good day for any shared practical endeavor requiring both boldness and intelligence"],
    today_watch: ["The efficiency of this combination can come across as cold today — one moment of genuine warmth changes the dynamic"],
  },

  '1_9': { // Sun friends Mars, Mars friends Sun
    rel: 'f_f',
    core: "Sun and Mars — both fire, both action, both forward. The most energized combination in the system. When directed at something external, they are nearly unstoppable. The risk is entirely internal.",
    strength: "Shared courage, shared ambition, shared willingness to fight for what matters. Neither intimidates the other. Neither slows the other down.",
    tension: "When they turn the energy on each other, the collision is memorable. Two people who never back down in the same room.",
    close_connection: "Intensely passionate and intensely volatile. The relationship that is never boring and occasionally devastating.",
    friendship: "The most loyal and combustible friendship. Will defend each other to anyone — and occasionally need defense from each other.",
    growth: "Both learn that not every battle justifies the energy it costs. The most important skill for this combination is choosing.",
    today_boost: ["Maximum combined fire today — external challenges, competition, and bold joint action all peak", "Good day to direct this energy at something that requires real courage"],
    today_watch: ["One trigger away from a memorable argument — consciously direct outward before turning inward"],
  },

  '2_3': { // Moon friends Jupiter, Jupiter friends Moon
    rel: 'f_f',
    core: "Moon and Jupiter — emotional intelligence meets wisdom. 2 brings the feeling, 3 brings the framework. Together they can navigate human situations with a depth that neither achieves alone.",
    strength: "3 helps 2 find clarity when emotions cloud the picture. 2 helps 3 remember that wisdom without compassion is just being right. Each corrects the other's natural lean.",
    tension: "3's tendency to judge can land on 2's sensitivity like a verdict. 2's emotional oscillations can exhaust 3's need for consistency.",
    close_connection: "Grounded and caring. The relationship where wisdom and feeling are both respected. Not the most passionate — the most sustaining.",
    friendship: "The advisor friendship — 3 speaks truth, 2 receives it with the emotional intelligence to actually use it.",
    growth: "2 learns that clarity is a gift, not a judgment. 3 learns that leading with the heart before the head is not weakness.",
    today_boost: ["Deep conversations land well today — emotional intelligence and wisdom operating simultaneously", "Good day for any conversation that requires both honesty and care"],
    today_watch: ["3 may be more critical than usual today — 2 will feel it as rejection when it was analysis"],
  },

  '3_9': { // Jupiter friends Mars, Mars friends Jupiter
    rel: 'f_f',
    core: "Jupiter and Mars — wisdom and courage in natural alignment. 3 knows what's right. 9 has the nerve to do it. Together they can take principled bold action that neither can sustain alone.",
    strength: "3's wisdom prevents 9's courage from becoming recklessness. 9's energy prevents 3's wisdom from becoming paralysis. The combination produces action that is both brave and sound.",
    tension: "3 thinks before acting. 9 acts before thinking. The timing conflict is constant and occasionally costly.",
    close_connection: "The relationship with a shared mission. Principled and passionate in equal measure.",
    friendship: "The friendship that actually changes things. Both want a world that's different — and together they have what it takes.",
    growth: "3 learns that sometimes the right moment is now, not after more preparation. 9 learns that some moves require wisdom they don't yet have.",
    today_boost: ["Principled bold action today — advocacy, stands that matter, and the courageous right move all peak", "Good day for joint decisions that require both conviction and nerve"],
    today_watch: ["9 may move before 3 is ready — coordinate timing explicitly before acting jointly"],
  },

  '4_4': { // Rahu friends Rahu (self)
    rel: 'f_f',
    core: "Double Rahu — the most creatively explosive and practically volatile combination. Together they see angles others miss entirely. The ideas generated in this pairing are genuinely original. The follow-through requires external structure.",
    strength: "Neither judges the other's unconventional thinking. Maximum originality. Maximum freedom from conventional limits.",
    tension: "Neither provides the grounding the other needs. Financial instability doubles. The brilliant idea generation has no built-in execution mechanism.",
    close_connection: "Exciting and exhausting. The relationship full of stories and restarts.",
    friendship: "The adventure friendship that produces extraordinary experiences and zero reliable logistics.",
    growth: "Both need to build one anchor in their lives — a practice, a discipline, a person — before they can anchor each other.",
    today_boost: ["Most original thinking available — creative problems that have resisted conventional solutions get solved today"],
    today_watch: ["Financial decisions need an external third opinion today — do not execute together without verification"],
  },

  '4_6': { // Rahu friends Venus, Venus friends Rahu
    rel: 'f_f',
    core: "Rahu and Venus — the unexpected and the beautiful in natural flow. 4 brings the original angle, 6 brings the aesthetic richness. Together they produce work that is both surprising and beautiful — a rare combination.",
    strength: "4's unconventional thinking + 6's aesthetic sensibility = creative output that genuinely surprises. The best work of this pairing looks effortless from the outside.",
    tension: "4's instability is hard for 6's need for harmony. When 4 is in chaos mode, 6's beauty-radar goes into alert.",
    close_connection: "Initially very exciting — the unexpected person who also happens to be beautiful in every sense. Long-term requires 4 to provide more consistency.",
    friendship: "Creative, socially rich, and occasionally unreliable. The friend group wants to be around this pairing.",
    growth: "4 learns that harmony is not a trap — it's what makes the creative work sustainable. 6 learns that originality sometimes requires accepting beautiful chaos.",
    today_boost: ["Unconventional beauty available — creative output today has both originality and aesthetic quality"],
    today_watch: ["Financial decisions involving this combination today need scrutiny — 4's impulse + 6's indulgence is a risky combination"],
  },

  '4_7': { // Rahu friends Ketu, Ketu friends Rahu
    rel: 'f_f',
    core: "Rahu and Ketu — the two shadow planets in natural alignment. This is the most spiritually and philosophically profound pairing. Both are seekers. Neither is satisfied with surface. Together they can access depths that other combinations can't reach — and neither provides the practical grounding that daily life requires.",
    strength: "Mutual recognition of something beyond the conventional. Neither judges the other's seeking. The conversations go places most conversations can't.",
    tension: "Zero practical grounding between them. Neither stabilizes the other's instability. External structure is not optional for this pairing — it's essential.",
    close_connection: "Spiritually profound and practically chaotic. The relationship that changes both people permanently.",
    friendship: "The most philosophically interesting friendship available — unreliable and unforgettable in equal measure.",
    growth: "Both must build individual anchors before they can be anchors for each other.",
    today_boost: ["Spiritual and philosophical depth peaks today — honest existential conversation available that most days can't support"],
    today_watch: ["Practical matters today require external input — neither is grounded enough for financial or logistical decisions"],
  },

  // ══ MUTUAL ENEMIES (e_e) ════════════════════════════════════════════════════

  '1_7': { // Sun enemy Ketu, Ketu enemy Sun
    rel: 'e_e',
    core: "Sun and Ketu — the two most contrary energies in the system. Sun demands presence, authority, and visibility. Ketu withdraws, seeks the invisible, and is comfortable disappearing. Neither understands what the other is doing or why.",
    strength: "The very incomprehensibility can be compelling. Each experiences something in the other they cannot access in themselves.",
    tension: "1 reads 7's detachment as abandonment or disrespect. 7 reads 1's need for visibility as ego. Both readings have some truth.",
    close_connection: "Unusual and often genuinely profound when it works. Requires 7 to stay present against their nature and 1 to release the need for constant acknowledgment.",
    friendship: "Fascinating and frustrating. 1 finds 7 unreliable. 7 finds 1 exhausting. And yet.",
    growth: "1 learns that presence isn't always about being seen. 7 learns that commitment to another person is a spiritual practice, not a contradiction.",
    today_boost: ["The contrast between these energies can produce insight today that sameness can't — different angles on the same problem"],
    today_watch: ["1's need for acknowledgment and 7's detachment are both elevated today — the gap will feel wider"],
  },

  '2_4': { // Moon enemy Rahu, Rahu enemy Moon
    rel: 'e_e',
    core: "Moon and Rahu — emotional depth meeting radical instability. 2 needs consistency and emotional safety. 4 generates unpredictability and resists patterns. The combination is creatively electric and emotionally challenging.",
    strength: "4's unconventional thinking breaks 2 out of emotional loops that have become grooves. 2's emotional attunement gives 4's chaos a human anchor it rarely has.",
    tension: "4's instability directly triggers 2's abandonment fears. 2's need for emotional consistency feels suffocating to 4's need for freedom.",
    close_connection: "Complicated in the way that leaves marks. The relationship that produces creative breakthroughs and emotional turbulence in equal measure.",
    friendship: "Creative partnership works well. Emotional reliance does not. Know which you're in.",
    growth: "2 learns that 4's unpredictability is not personal abandonment. 4 learns that some consistency is a form of love, not a cage.",
    today_boost: ["Creative output today benefits from both energies — emotional depth + unconventional thinking"],
    today_watch: ["Financial and practical decisions together today are high-risk — keep them completely separate"],
  },

  '2_5': { // Moon enemy Mercury, Mercury enemy Moon
    rel: 'e_e',
    core: "Moon and Mercury — feeling and thinking in fundamental tension. 2 processes the world through emotion and intuition. 5 processes through analysis and logic. Both approaches are real. Neither trusts the other's instrument.",
    strength: "5's clarity can help 2 articulate something felt but not yet understood. 2's emotional intelligence can give 5's analysis the human context that transforms it.",
    tension: "5 applies logic to 2's emotional experience and calls it help. 2 calls it cold. They're both right.",
    close_connection: "Works when 5 genuinely learns emotional language — not as performance but as respect. 2 needs to hear it. 5 needs to say it.",
    friendship: "The friend who understands you (2) and the one who explains you to yourself (5). Occasionally maddening. Often invaluable.",
    growth: "5 learns that some things aren't problems to be solved. 2 learns that clarity is not the enemy of depth.",
    today_boost: ["Communication peaks today when both accept their different languages — write something together"],
    today_watch: ["5 will think 2 is being irrational today. 2 will feel 5 is being cold. Both are half-right — neither is fully wrong"],
  },

  '2_8': { // Moon enemy Saturn, Saturn enemy Moon
    rel: 'e_e',
    core: "Moon and Saturn — two of the deepest givers in the system, running in planetary opposition. Both invest enormous emotional and practical energy in the people they love. The problem is that neither asks for what they need — and what they need is very different.",
    strength: "Extraordinary mutual loyalty when aligned. Neither gives up easily. The long arc of this connection can produce something genuinely durable.",
    tension: "Both suppress needs indefinitely. 2 suppresses emotional needs. 8 suppresses requests for acknowledgment. The accumulated silence becomes distance.",
    close_connection: "One of the most durable connections in the system — love that survives what kills other relationships. Requires both to learn to ask.",
    friendship: "The friendship that shows up for every hard thing without being asked. And never discusses what it costs.",
    growth: "Both desperately need to learn to name what they need. The dynamic is unsustainable on silence alone.",
    today_boost: ["Showing up for each other today without waiting to be asked — this is what this pairing does best"],
    today_watch: ["Neither will ask for what they need today — one person must break the pattern or the day passes in mutual sacrifice"],
  },

  '3_5': { // Jupiter enemy Mercury, Mercury enemy Jupiter
    rel: 'e_e',
    core: "Jupiter and Mercury — wisdom and intelligence in planetary opposition. 3 operates from values, ethics, and long-term principles. 5 operates from analysis, efficiency, and what works now. Both are thinking — with fundamentally different starting points.",
    strength: "5's commercial intelligence + 3's ethical grounding = decisions that are both smart and right. Rare and valuable in professional contexts.",
    tension: "3 thinks 5 is transactional. 5 thinks 3 is impractical. Both observations have merit.",
    close_connection: "Intellectually rich when both respect the other's frame. Requires deliberate emotional investment from both.",
    friendship: "The friend who knows what's right (3) and the friend who knows what works (5). Together they can navigate almost anything.",
    growth: "3 learns that efficiency is not the enemy of integrity. 5 learns that principles are not obstacles to intelligence — they are competitive advantages.",
    today_boost: ["Strategic decision-making peaks when both frames are active — sound and smart simultaneously"],
    today_watch: ["5 may push for a shortcut 3 won't accept today — the disagreement is productive, not a dealbreaker"],
  },

  '3_6': { // Jupiter enemy Venus, Venus enemy Jupiter
    rel: 'e_e',
    core: "Jupiter and Venus — wisdom and beauty in planetary tension. 3 values depth, ethics, and substance. 6 values beauty, harmony, and aesthetic richness. Neither considers the other's primary value frivolous — but neither naturally prioritizes it either.",
    strength: "3's depth gives 6's beauty substance. 6's beauty gives 3's wisdom a more appealing form. Together they create things with both soul and surface.",
    tension: "3 may judge 6's aesthetic investments as vanity. 6 may find 3's principled rigidity suffocating.",
    close_connection: "Deeply complementary when both respect the other's language. The marriage-quality combination that builds a beautiful and meaningful life.",
    friendship: "The advisor friend (3) and the beautiful one (6) — each makes the other more complete and occasionally more frustrated.",
    growth: "3 learns that beauty is not superficial — it is a form of truth. 6 learns that substance outlasts beauty, and that depth is its own aesthetic.",
    today_boost: ["Values and beauty converging — creative work with genuine ethical grounding available today"],
    today_watch: ["3 may hold 6 to standards that weren't announced today — 6 will feel judged before they understand why"],
  },

  '5_9': { // Mercury enemy Mars, Mars enemy Mercury
    rel: 'e_e',
    core: "Mercury and Mars — intelligence and energy in planetary tension. 5 thinks, calculates, and plans. 9 charges, acts, and corrects course in motion. Neither naturally respects the other's process — but together they cover the full spectrum from analysis to execution.",
    strength: "5's intelligence gives 9's energy direction. 9's courage gives 5's analysis a deadline. The combination produces action that is both smart and bold.",
    tension: "9 thinks 5 is overthinking. 5 thinks 9 is acting recklessly. Both are occasionally right.",
    close_connection: "Competitive and passionate. Works when both are on the same team — becomes exhausting when they compete directly.",
    friendship: "The intellectual friend (5) and the warrior friend (9) — extraordinary when their skills are aimed at the same target.",
    growth: "5 learns that sometimes analysis is procrastination. 9 learns that some moves require the intelligence they've been skipping.",
    today_boost: ["Street-smart competitive energy — commercial instinct and bold action both peak today together"],
    today_watch: ["9's impatience + 5's sharpness can produce a cutting exchange today — redirect before it escalates"],
  },

  // ══ ONE FRIEND ONE ENEMY (e_f / f_e) ═══════════════════════════════════════

  '1_2': { // Sun enemy Moon, Moon friends Sun
    rel: 'e_f',
    core: "Sun and Moon — the most fundamental polarity in Vedic astrology. 1 pulls toward authority, action, and external impact. 2 pulls toward depth, feeling, and internal attunement. The Moon is drawn to the Sun's light. The Sun doesn't always notice the Moon's pull.",
    strength: "1 provides direction that 2's sensitivity can humanize. 2 provides emotional intelligence that 1's authority can act on. Together they cover what each lacks most.",
    tension: "1 can dominate without registering that 2 is giving way rather than agreeing. 2 can give far more than they should and quietly build resentment.",
    close_connection: "One of the most common pairings in numerology — classically complementary, practically complicated. Works when 1 genuinely acknowledges and 2 genuinely asks.",
    friendship: "2 becomes the emotional infrastructure. 1 becomes the practical engine. Both get what they need if 1 notices what 2 is providing.",
    growth: "1 learns to receive — not just give and protect. 2 learns to ask explicitly rather than give and wait to be noticed.",
    today_boost: ["Authority softened by emotional intelligence today — the conversation that requires both confidence and sensitivity"],
    today_watch: ["2 may feel invisible in 1's momentum today — one deliberate acknowledgment is worth more than a hundred practical gestures"],
  },

  '4_8': { // Rahu enemy Saturn, Saturn friends Rahu
    rel: 'e_f',
    core: "Rahu and Saturn — the most chronically misaligned combination in terms of pace and planning. 4 is fast, instinctive, and comfortable with chaos. 8 is slow, deliberate, and deeply uncomfortable with it. 8 is drawn to 4's freedom. 4 is destabilized by 8's weight.",
    strength: "8's patience and structure can eventually bring out 4's best work. When 4 has a stable container to return to, the ideas actually get finished.",
    tension: "The timing conflict is constant. 4 acts before 8 has processed. 8 decides after 4 has already moved on. Frustration is the default state.",
    close_connection: "Requires extraordinary patience from 8 and genuine gratitude from 4. When it works, 4 produces their best work in 8's consistent presence.",
    friendship: "8 will always be the reliable one. The question is whether 8 builds resentment for it over time.",
    growth: "4 learns that 8's slowness is not stubbornness — it's how they protect the thing being built. 8 learns that 4's speed occasionally creates windows that patience would miss.",
    today_boost: ["8's karmic stability can genuinely ground 4's best thinking today — practical creativity is available"],
    today_watch: ["The pace difference is sharpest today — 4 will feel constrained, 8 will feel rushed. Name it before it becomes conflict"],
  },

  // ══ NEUTRAL + ENEMY (n_e) ════════════════════════════════════════════════════

  '1_4': { // Sun neutral Rahu, Rahu enemy Sun
    rel: 'n_e',
    core: "Sun sees Rahu as neutral — manageable, interesting even. Rahu sees Sun as a threat to its freedom. This asymmetry creates a dynamic where 1 thinks things are going well when 4 is quietly chafing.",
    strength: "1's direction can channel 4's unconventional energy into something that actually lands. 4's originality can break 1 out of conventional approaches.",
    tension: "4's resistance to 1's authority is structural, not personal — and 1 tends to take it personally.",
    close_connection: "Initially exciting for 1. Long-term requires 1 to understand that 4's resistance is not disloyalty.",
    friendship: "The bold friend (1) and the unconventional one (4). Stimulating and occasionally destabilizing.",
    growth: "1 learns that not everyone needs to be led. 4 learns that structure is not the same as control.",
    today_boost: ["4's unconventional angle can genuinely improve 1's direction today — ask before assuming"],
    today_watch: ["Financial decisions together today need independent verification — 4's impulse and 1's confidence can compound poorly"],
  },

  '1_6': { // Sun neutral Venus, Venus enemy Sun
    rel: 'n_e',
    core: "Sun is neutral to Venus — appreciates the beauty without being transformed by it. Venus is threatened by Sun's dominance of space and attention. 1 can unknowingly crowd out 6's need for harmony and aesthetic expression.",
    strength: "1's ambition and 6's charm create a socially and professionally potent combination. Together they project an image that opens doors.",
    tension: "6's sharp tongue when their standards are unmet vs 1's ego when their authority is questioned. Both take criticism poorly in different ways.",
    close_connection: "Highly attractive combination that requires 1 to make room and 6 to communicate disappointment before it becomes contempt.",
    friendship: "The ambitious friend (1) and the stylish one (6) — complement each other socially, occasionally clash on priorities.",
    growth: "1 learns that appreciation is not weakness — it is what keeps 6 present. 6 learns to name disappointment directly rather than cutting.",
    today_boost: ["Socially and professionally both peak — public appearances and important first impressions are favored"],
    today_watch: ["If 6 is disappointed today and 1 hasn't noticed, the reaction will be disproportionate to the apparent offense"],
  },

  '1_8': { // Sun neutral Saturn, Saturn enemy Sun
    rel: 'n_e',
    core: "Sun is neutral to Saturn — respects the work ethic without fully understanding the pace. Saturn is wary of Sun — authority that hasn't been earned through time feels suspect. 8 watches 1's confidence carefully for whether it's warranted.",
    strength: "When 1's initiative meets 8's discipline, what they build is both bold and durable. Neither half of this combination is achievable alone.",
    tension: "1 wants results now. 8 knows they come through sustained effort over time. The timeline disagreement is structural.",
    close_connection: "Built on mutual respect for work ethic. Not passionate in the conventional sense — durable in a way passion rarely is.",
    friendship: "The most reliable long-term friendship. Neither leaves when things get hard.",
    growth: "1 learns that patience compounds in ways that speed cannot. 8 learns that 1's boldness creates the opportunities that patience can then build on.",
    today_boost: ["Shared discipline today — good day to begin something that requires both launch energy and long-term commitment"],
    today_watch: ["Both want credit today and neither will ask for it — explicit acknowledgment prevents the slow burn"],
  },

  '2_6': { // Moon neutral Venus, Venus enemy Moon
    rel: 'n_e',
    core: "Moon is comfortable with Venus — emotional depth and beauty feel naturally aligned. Venus is more guarded with Moon — the emotional intensity can crowd the harmony. 2 often gives more emotionally than 6 is ready to receive.",
    strength: "The most aesthetically and emotionally rich pairing. What they create together has both beauty and genuine feeling.",
    tension: "6's sharp tongue when standards are unmet can devastate 2's sensitivity. 2's emotional weight can overwhelm 6's need for lightness.",
    close_connection: "One of the most romantically charged combinations. The highs are extraordinary. The lows require both to know how to repair.",
    friendship: "The creative friendship that produces beautiful things and occasionally painful conversations.",
    growth: "2 learns that emotional intensity is not always what beauty requires. 6 learns that the depth 2 offers is rarer than the beauty they can always find.",
    today_boost: ["Maximum warmth and creative energy today — the most beautiful day for joint expression"],
    today_watch: ["Sharp words from 6 today will land on 2 like a verdict. 6 needs to choose carefully."],
  },

  '2_7': { // Moon neutral Ketu, Ketu neutral Moon — actually both neutral
    rel: 'n_n',
    core: "Moon and Ketu — emotional depth and philosophical depth. Neither is on the surface. Together they can access a quality of understanding that is genuinely rare — if 7 stays present long enough for 2 to feel safe.",
    strength: "Mutual recognition of depth. 2 feels understood without explaining. 7 feels free without abandoning.",
    tension: "7's structural detachment leaves 2 in prolonged uncertainty about where they stand.",
    close_connection: "Quietly profound when it works. Requires 7 to make peace with closeness and 2 to make peace with 7's need for space.",
    friendship: "The most philosophically enriching friendship available — if 7 doesn't vanish when things get complicated.",
    growth: "2 learns that detachment is not rejection. 7 learns that staying is a form of spiritual depth, not its opposite.",
    today_boost: ["Intuitive connection today — the right thing to say to each other arrives without effort"],
    today_watch: ["7 may feel unusually detached today — 2 shouldn't read abandonment into temporary withdrawal"],
  },

  '3_8': { // Jupiter neutral Saturn, Saturn neutral Jupiter — both neutral
    rel: 'n_n',
    core: "Jupiter and Saturn — wisdom and karma. Both understand that what matters takes time. Both have high standards. Both give more than they take. The combination is deeply steady and occasionally too serious.",
    strength: "Mutual respect for depth, ethics, and sustained effort. What they build together lasts because both refuse to cut corners.",
    tension: "Neither brings lightness. Joy needs to be scheduled deliberately or it doesn't happen.",
    close_connection: "The relationship that builds a legacy. Not the most passionate — the most enduring.",
    friendship: "The most reliable long-term friendship in the system. Neither disappears when things become difficult.",
    growth: "Both learn that celebrating the journey is not a distraction from the destination — it is part of what makes the destination worth reaching.",
    today_boost: ["Long-term planning and sustained joint work peak today — what's built now lasts"],
    today_watch: ["Both may be too serious today — deliberate lightness is not self-indulgence, it's maintenance"],
  },

  '3_7': { // Jupiter neutral Ketu, Ketu neutral Jupiter — both neutral
    rel: 'n_n',
    core: "Jupiter and Ketu — the two most philosophically and spiritually inclined planets in neutral alignment. Together they go deeper than either goes alone. The challenge is that 7's instability tests 3's need for consistency.",
    strength: "Shared love of knowledge, meaning, and depth. The insight that emerges from their conversations is genuinely rare.",
    tension: "7's tendency to vanish or change direction frustrates 3's need for the ethical consistency of following through.",
    close_connection: "Philosophically profound and practically uncertain. Requires 7 to commit to presence.",
    friendship: "The most intellectually enriching friendship possible — assuming 7 stays in the city.",
    growth: "3 learns to trust the journey when the destination isn't visible. 7 learns that commitment is a philosophical practice, not its opposite.",
    today_boost: ["Deep conversation available today — the insight that emerges reorients things"],
    today_watch: ["7 may want to change plans today — 3 should not fight it but should name the pattern"],
  },

  '6_9': { // Venus neutral Mars, Mars enemy Venus — n_e
    rel: 'n_e',
    core: "Venus and Mars — beauty and passion in a charged asymmetry. 9's energy is drawn to 6's magnetism. 6 finds 9's intensity compelling and occasionally threatening. The most romantically volatile combination.",
    strength: "Maximum passion and aesthetic richness together. What they create has both fire and beauty.",
    tension: "9's explosive anger + 6's sharp tongue when hurt = fights that leave permanent marks. Both say the thing that cannot be unsaid.",
    close_connection: "The most romantically charged combination. Never boring. The words said in conflict need to be chosen with extraordinary care.",
    friendship: "Intensely loyal and occasionally explosive — the friendship that people on the outside are both drawn to and wary of.",
    growth: "9 learns that 6's words are weapons at a level that 9's volume doesn't match. 6 learns that 9's anger passes faster than 6 expects.",
    today_boost: ["Passionate and beautiful today — quality time together creates memory worth having"],
    today_watch: ["If this tips into conflict today, the words will be remembered long after the reason for them is forgotten"],
  },

  // ══ NEUTRAL + FRIEND (n_f) ══════════════════════════════════════════════════

  '2_9': { // Moon neutral Mars, Mars friends Moon
    rel: 'n_f',
    core: "Moon and Mars — emotional depth and warrior energy in an interesting asymmetry. 9 is drawn to and protective of 2. 2 is both comforted and occasionally overwhelmed by 9's intensity.",
    strength: "9 protects 2 with a fierceness that 2 didn't know they needed. 2 grounds 9's volatility with emotional attunement 9 rarely receives.",
    tension: "9's explosive edge can shatter 2's sensitivity in ways 9 doesn't fully register.",
    close_connection: "Intensely romantic and intensely volatile. The relationship that feels like a novel being written in real time.",
    friendship: "9 will fight for 2 before being asked. 2 is the emotional anchor 9 doesn't know they need.",
    growth: "9 learns that 2's sensitivity is not fragility — it is precision instrumentation that 9's bluntness damages. 2 learns that 9's anger is not directed at them even when it feels like it is.",
    today_boost: ["Passionate energy available — channel into creative work, physical activity, or the honest conversation"],
    today_watch: ["9's edge today will cut 2 more deeply than 9 intends — 9 needs to register the gap between intent and impact"],
  },

  '4_5': { // Rahu neutral Mercury, Mercury friends Rahu — actually let me check
    rel: 'n_f',
    core: "Rahu and Mercury in an asymmetric alignment — 5 is drawn to 4's unconventional angle and research depth. 4 is neutral to 5's precision. Together they can produce genuinely interesting commercial and intellectual work — if 4's chaos doesn't overwhelm 5's need for reliable information.",
    strength: "5's analytical precision + 4's research instinct = unusually deep commercial intelligence",
    tension: "4's unpredictability disrupts 5's need for reliable information. Financial decisions together carry elevated risk.",
    close_connection: "Intellectually stimulating and financially complicated. Better as intellectual partnership than primary relationship.",
    friendship: "Good for ideas and research together. Difficult for financial matters or logistics.",
    growth: "4 learns that 5's verification isn't distrust — it's precision. 5 learns that some of 4's instincts are correct in ways that defy explanation.",
    today_boost: ["Brainstorming and research together — interesting commercial ideas available today"],
    today_watch: ["Keep financial matters separate today — the combined impulse is stronger than the combined judgment"],
  },

  '5_6': { // Mercury neutral Venus, Venus friends Mercury — n_f
    rel: 'n_f',
    core: "Mercury and Venus in pleasant asymmetry — 6 is naturally drawn to 5's intelligence and commercial sharpness. 5 is neutral to 6's beauty but can see its commercial value. Together they combine aesthetic and intelligence in ways that work especially well in creative commerce.",
    strength: "5's commercial intelligence + 6's aesthetic sensibility = work that is both beautiful and successful",
    tension: "5 optimizes. 6 indulges. Their approaches to spending and creating are fundamentally different.",
    close_connection: "The relationship that looks extraordinary from the outside. Requires both to invest in depth, not just appearance.",
    friendship: "The commercially successful and aesthetically gifted duo. People want to be around this pairing.",
    growth: "5 learns that beauty has commercial value beyond aesthetics. 6 learns that optimization isn't the enemy of beauty — it's what makes it sustainable.",
    today_boost: ["Creative commerce peaks today — the pitch, the presentation, the beautiful business decision"],
    today_watch: ["Spending decisions today involving beauty or luxury need 5's scrutiny — 6's standard is high and expensive"],
  },

  '5_8': { // Mercury neutral Saturn, Saturn friends Mercury — n_f
    rel: 'n_f',
    core: "Mercury and Saturn in productive asymmetry — 8 is drawn to 5's intelligence and precision. 5 is neutral to 8's pace but values what 8 builds. Together they are one of the most methodically excellent financial combinations — if they can reconcile 5's speed with 8's deliberateness.",
    strength: "5's analytical sharpness + 8's disciplined patience = financial decisions that are both intelligent and durable",
    tension: "5 wants to move. 8 wants to be sure. The timing conflict is constant and occasionally costly.",
    close_connection: "Built on intellectual respect. Not the most passionate — the most practically sound.",
    friendship: "The business partnership that lasts decades and produces actual results.",
    growth: "5 learns that 8's pace creates compounding returns that speed cannot match. 8 learns that 5's windows are real and close faster than 8 moves.",
    today_boost: ["Methodical financial intelligence available today — the joint financial decision is likely to be the right one"],
    today_watch: ["Coordinate before acting — 5 will have already moved before 8 has processed the information"],
  },

  '6_7': { // Venus neutral Ketu, Ketu friends Venus — n_f
    rel: 'n_f',
    core: "Venus and Ketu in a fortunate asymmetry — 7 is naturally drawn to 6's beauty and warmth. 6 finds 7 philosophically interesting but occasionally hard to hold onto. Together they produce outcomes that are both beautiful and mysteriously fortunate.",
    strength: "7's luck arrives around the things 6 creates. 6's beauty gives 7's philosophical seeking a physical form.",
    tension: "7's structural detachment leaves 6 feeling unappreciated for what they create and provide.",
    close_connection: "One of the more fortunate romantic combinations. Lucky and beautiful — which is rarer than either alone.",
    friendship: "The friendship that seems blessed from the outside — and is, to an unusual degree.",
    growth: "7 learns to acknowledge what 6 brings before 6 stops bringing it. 6 learns that 7's attention, when it arrives, is more complete than most people's constant presence.",
    today_boost: ["Lucky and beautiful today — social events, creative investments, and romantic expression all favored"],
    today_watch: ["7 may seem more distant than usual today — 6 should not interpret disappearance as judgment"],
  },

  '6_8': { // Venus neutral Saturn, Saturn friends Venus — n_f
    rel: 'n_f',
    core: "Venus and Saturn in interesting asymmetry — 8 is drawn to 6's beauty and warmth, though 6 is neutral to 8's weight. Together they build beautiful things that last — 6 provides the taste, 8 provides the staying power.",
    strength: "8's patience and effort + 6's aesthetic vision = the beautiful life that is actually earned and therefore appreciated",
    tension: "6 wants it now. 8 knows it takes time. The pace difference can feel like deprivation to 6 and ingratitude from 8's perspective.",
    close_connection: "The beautiful home and life built over years. Not instantaneous — genuinely satisfying.",
    friendship: "6 inspires 8 to notice and appreciate beauty. 8 grounds 6's indulgence with real-world constraints.",
    growth: "6 learns that earned beauty satisfies more deeply than acquired beauty. 8 learns that beauty is not a luxury — it is part of what makes sustained effort worth it.",
    today_boost: ["Long-term creative and aesthetic work peaks today — the effort finally shows"],
    today_watch: ["6 may feel 8 is moving too slowly on something today — the timeline is right even if it doesn't feel like it"],
  },

  // ══ SAME NUMBER (both neutral to self, modulated by planetary nature) ════════

  '1_1': {
    rel: 'n_n',
    core: "Two Suns in the same space. The natural pull is toward leadership — and neither will easily follow. The ceiling for this combination is extraordinary: if domains are divided clearly, two Suns can build an empire. Without that clarity, the collision is constant.",
    strength: "Mutual recognition of ambition and drive. Neither diminishes the other's goals. Shared language of results.",
    tension: "Power struggles are not occasional — they are structural. Both default to leading. The question is who leads what.",
    close_connection: "Intense and equal. Long-term requires explicit division of authority — not competition for the same space.",
    friendship: "The friendship that keeps score, pushes each other, and occasionally goes too far. Also the one that produces the most.",
    growth: "Both learn that the best authority is the kind that doesn't need to prove itself.",
    today_boost: ["Both running authority energy today — decisions made together carry double weight"],
    today_watch: ["Whose idea it is and who gets credit for it will matter more today than it should — address it directly"],
  },

  '2_2': {
    rel: 'n_n',
    core: "Double Moon — the most emotionally attuned combination possible. When both are in a good place, the understanding between them is almost psychic. When one is struggling, the other follows. There is no emotional ballast in this pairing — only resonance.",
    strength: "Neither has to explain. The depth of mutual attunement is rare and real. Creative and emotional output together is extraordinary.",
    tension: "Mood contagion runs both directions. When both are down simultaneously, there is nothing to provide stability.",
    close_connection: "The relationship that feels telepathic. Requires both to maintain individual emotional stability.",
    friendship: "The most emotionally intimate friendship — can become codependent if both are not careful.",
    growth: "Both need independent practices that maintain their emotional equilibrium — otherwise they amplify each other's lows.",
    today_boost: ["Creative and emotional output together peaks today — what they produce carries unusual depth"],
    today_watch: ["If one is struggling today, the other will feel it without being told — check in before connecting"],
  },

  '3_3': {
    rel: 'n_n',
    core: "Double Jupiter — the most ethically aligned combination. Shared values, shared worldview, mutual respect for wisdom and principle. Also the most prone to principled impasse — two people who are both right in different ways.",
    strength: "Deep alignment on what matters. Neither compromises the other's integrity. The most values-consistent partnership.",
    tension: "Both believe they are right — because they often are. The debates are not about ego but about genuine conviction, which makes them harder to resolve.",
    close_connection: "Deeply respectful. Occasionally too principled to be spontaneous. The relationship that other people call 'solid.'",
    friendship: "Will still be friends in 40 years. Will have argued about the same things for 40 years.",
    growth: "Both learn that being right together is not the same as being connected. The relationship needs more than alignment — it needs play.",
    today_boost: ["Strategic planning and important joint decisions are exceptionally well-supported today"],
    today_watch: ["If a principled disagreement emerges today, neither will let it go — choose whether it's worth the energy"],
  },

  '4_4': {
    rel: 'f_f',
    core: "Double Rahu — the most creatively explosive and practically volatile combination. Together they see angles others miss entirely. The ideas generated in this pairing are genuinely original. The follow-through requires external structure.",
    strength: "Neither judges the other's unconventional thinking. Maximum originality. Maximum freedom from conventional limits.",
    tension: "Neither provides the grounding the other needs. Financial instability doubles. The brilliant idea generation has no built-in execution mechanism.",
    close_connection: "Exciting and exhausting. The relationship full of stories and restarts.",
    friendship: "The adventure friendship that produces extraordinary experiences and zero reliable logistics.",
    growth: "Both need to build one anchor in their lives — a practice, a discipline, a person — before they can anchor each other.",
    today_boost: ["Most original thinking available — creative problems that have resisted conventional solutions get solved today"],
    today_watch: ["Financial decisions need an external third opinion today — do not execute together without verification"],
  },

  '5_5': {
    rel: 'n_n',
    core: "Double Mercury — the sharpest analytical combination. Business and financial intelligence at its peak. Also the most anxiety-prone — two calculating minds in the same space, each running faster than the conversation can keep up.",
    strength: "Commercial instinct that borders on prescient. Financial decisions made together are unusually reliable.",
    tension: "Overthinking amplified. Analysis paralysis doubles. Anxiety can become the emotional climate of the relationship.",
    close_connection: "Intellectually electric. Requires deliberate emotional investment — neither provides it naturally.",
    friendship: "The most commercially successful friendship in the system. Makes things happen.",
    growth: "Both learn that the relationship deserves to be an end in itself, not just a vehicle for shared efficiency.",
    today_boost: ["Most financially and commercially sharp day together — the important business decision is best made today"],
    today_watch: ["Anxiety can amplify between them today — check in on each other's mental load, not just the agenda"],
  },

  '6_6': {
    rel: 'n_n',
    core: "Double Venus — maximum beauty, warmth, social grace, and the most cutting combined tongue when disappointed. What they create together is aesthetically extraordinary. What they say to each other when hurt is also extraordinary — in the wrong direction.",
    strength: "The most beautiful social and creative pairing. Everything they produce together has an extraordinary quality.",
    tension: "Both have unannounced high standards. Both have sharp tongues when those standards are unmet. The disappointment cycles can be elaborate.",
    close_connection: "The relationship everyone envies from outside. Requires both to speak disappointment before it becomes contempt.",
    friendship: "The most socially magnetic friendship. Also the most likely to have complicated feelings about the same people.",
    growth: "Both learn that perfection is not the standard — presence is. Including their own.",
    today_boost: ["Most beautiful day for joint expression — creative and social output peaks"],
    today_watch: ["Words said in frustration between these two today will be quoted back for months. Choose carefully."],
  },

  '7_7': {
    rel: 'n_n',
    core: "Double Ketu — the most psychically attuned and least practically grounded combination. They understand each other at a level that requires no explanation. They also both tend to disappear at the same time.",
    strength: "Mutual understanding that is nearly wordless. Neither judges the other's seeking. The conversation goes places others can't follow.",
    tension: "Double instability. When both are unsettled, there is no anchor between them.",
    close_connection: "Profound and unpredictable. The relationship that is never quite certain but always deeply real.",
    friendship: "Both can disappear for months and return as if no time passed. Unusual and genuine.",
    growth: "Both need one external anchor each — a practice, a place, a commitment — before they can be reliable for each other.",
    today_boost: ["Psychic-level intuitive connection today — the right words arrive without effort"],
    today_watch: ["Neither is especially grounded today — practical decisions should wait"],
  },

  '8_8': {
    rel: 'n_n',
    core: "Double Saturn — the most karmic combination. Maximum loyalty, maximum patience, maximum suppressed needs. Both give everything and ask for nothing. The danger is not conflict — it is the accumulation of unspoken needs that becomes distance.",
    strength: "Unbreakable loyalty over time. The combination that survives what kills everything else.",
    tension: "Both suppress what they need indefinitely. The silence becomes a comfortable trap.",
    close_connection: "The relationship that lasts — for better or for worse. Requires both to learn one difficult skill: asking.",
    friendship: "The most reliably present friendship. The one that is still there thirty years later.",
    growth: "Both learn that asking for what they need is an act of respect, not weakness. The other person cannot give what they don't know is needed.",
    today_boost: ["Long-term work together peaks today — what is built now compounds"],
    today_watch: ["Neither will ask for what they need today — one must break the pattern or both leave the day unsatisfied"],
  },

  '9_9': {
    rel: 'n_n',
    core: "Double Mars — maximum intensity, maximum passion, maximum volatility. When directed at something external, this combination is genuinely formidable. When the energy turns inward, the damage is real.",
    strength: "The most energized and courageous combination. Neither backs down. Together they attempt things others won't.",
    tension: "When they fight each other, neither stops at reasonable. The collateral damage is significant.",
    close_connection: "The most passionate combination. Burns very bright. Requires both to commit to directing energy outward.",
    friendship: "Will fight for each other to the end — and occasionally fight each other to the end.",
    growth: "Both learn to ask one question before responding in anger: is this the right target for this energy?",
    today_boost: ["Maximum combined courage today — the bold joint action that requires real nerve"],
    today_watch: ["If the energy turns inward today, it escalates fast. Redirect before the first word."],
  },

  // ══ REMAINING NEUTRAL-NEUTRAL PAIRS ═════════════════════════════════════════

  '3_4': {
    rel: 'n_n',
    core: "Jupiter and Rahu — wisdom and disruption in neutral alignment. 3 provides the ethical and intellectual frame. 4 provides the unconventional angle that breaks the frame open. The friction is productive when both are pointing at the same problem.",
    strength: "Research depth + principled framework = insights that are both original and sound",
    tension: "3 finds 4's chaos difficult. 4 finds 3's rules limiting. Neither is wrong.",
    close_connection: "Better as intellectual partnership than primary relationship. The ideas generated together are worth the friction.",
    friendship: "The researcher (4) and the sage (3). Enriching when 4 actually shows up.",
    growth: "3 learns that some important truths only emerge through chaos. 4 learns that structure enables rather than prevents original thinking.",
    today_boost: ["Research and unconventional problem-solving together today — the interesting angle arrives"],
    today_watch: ["Joint financial commitments today need independent verification"],
  },

  '4_9': {
    rel: 'n_n',
    core: "Rahu and Mars — instability and explosive energy in neutral alignment. The combination generates maximum kinetic force with minimum grounding. Together they are capable of extraordinary physical and creative output — and of spectacular misfires.",
    strength: "Physical and competitive energy at maximum. Neither constrains the other.",
    tension: "Legal risks. Frustration cycles. The feeling of being trapped in each other's chaos.",
    close_connection: "Passionate and complicated. The feeling of being unable to fully leave or fully stay.",
    friendship: "Intense and occasionally turbulent. The friendship with the most stories.",
    growth: "Both need to understand which constraints are real and which are self-generated — they perpetuate each other's if they don't.",
    today_boost: ["Physical activity and competitive situations together — direct the energy outward"],
    today_watch: ["Do not make joint legal or financial decisions today. The impulse-to-action pipeline has no brakes."],
  },

  '5_7': {
    rel: 'n_n',
    core: "Mercury and Ketu — intelligence and intuition in interesting neutral alignment. 5 calculates. 7 intuits. Together they can access both modes simultaneously — which produces financial and strategic decisions of unusual quality.",
    strength: "5's financial precision + 7's quiet luck = one of the most fortunate financial combinations",
    tension: "Easy come, easy go. Neither naturally holds what arrives together.",
    close_connection: "Fortunate and interesting. 7's depth gives 5's precision something genuinely worth calculating for.",
    friendship: "The friendship where things just work out — with unusual frequency.",
    growth: "Both learn that the fortune this combination generates requires stewardship, not just generation.",
    today_boost: ["Financial luck is structurally active today — the right opportunity should be acted on"],
    today_watch: ["Save something from what arrives today — the pattern of this combination is to generate and release"],
  },

  '7_8': {
    rel: 'n_n',
    core: "Ketu and Saturn — luck and karma in neutral alignment. 7's fortune can lift 8's heavy sustained effort at exactly the right moment. 8's discipline can give 7's instability a container that actually holds. When this works, it's transformative.",
    strength: "7's luck arrives precisely when 8's effort has built the foundation it needs",
    tension: "7's detachment frustrates 8's need for acknowledgment. 8's heaviness dampens 7's natural lightness.",
    close_connection: "Spiritually rich and practically challenging. The combination that produces unexpected breakthroughs in long-standing efforts.",
    friendship: "8 does the work. 7 provides the unexpected breakthrough that makes it matter.",
    growth: "7 learns to work alongside luck rather than waiting for it. 8 learns to trust what cannot be controlled.",
    today_boost: ["Patience meets fortune today — the unexpected development in a long-standing effort arrives"],
    today_watch: ["8 may feel 7 isn't taking things seriously enough today — this is 7's way, not disrespect"],
  },

  '7_9': {
    rel: 'n_n',
    core: "Ketu and Mars — fortune and courage in neutral alignment. 7's luck protects 9's bold moves at a higher rate than probability suggests. Together they take larger risks with better outcomes.",
    strength: "Fortune backing courage — bold joint moves work out more often than they should",
    tension: "9's explosive energy can destroy what 7's luck built. The protection is real but not infinite.",
    close_connection: "Fortunate and passionate. The bold decisions together tend to land.",
    friendship: "9 charges. 7's luck somehow makes it work. The friendship that lives several lives.",
    growth: "9 learns to pause long enough for luck to operate. 7 learns that sometimes courage is the thing that activates fortune.",
    today_boost: ["Bold joint moves are protected today — good day for the decision that requires both guts and luck"],
    today_watch: ["9 may push harder than 7's luck can protect — calibrate the boldness"],
  },

  '8_9': {
    rel: 'n_n',
    core: "Saturn and Mars — discipline and passion in neutral alignment. 8 sustains. 9 generates. Together they produce maximum output — 9 creates the energy, 8 turns it into something durable. The most productive pairing for sustained high-output work.",
    strength: "9's intensity + 8's patience = output that is both powerful and lasting",
    tension: "9's impatience eventually pushes 8 past their threshold. 8's deliberateness frustrates 9's need to move.",
    close_connection: "Passionate and demanding. Both give everything. Both need everything.",
    friendship: "9 runs. 8 makes sure they don't fall. Each extends the other's range.",
    growth: "9 learns that 8's pace is sustainability, not resistance. 8 learns that 9's urgency creates windows that patience would miss.",
    today_boost: ["Maximum sustained output today — physical and professional both peak together"],
    today_watch: ["9 may push 8 past their threshold today — check the temperature before the explosion"],
  },
};

// ─── Today compatibility engine ───────────────────────────────────────────────
export function getTodayCompatibility(daily1, daily2, basic1, basic2, periods1 = [], periods2 = [], yogas1 = [], yogas2 = []) {
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

  const dr1 = getTodayRel(daily1, daily2);
  const dr2 = getTodayRel(daily2, daily1);
  let dailyPts = (todayPts(dr1) + todayPts(dr2)) / 2; // 0-3
  let score = Math.round((dailyPts / 3) * 100); // raw 0-100

  // Period layer for uniqueness
  if (periods1.length >= 2 && periods2.length >= 2) {
    const [maha1num, antar1num, monthly1num] = periods1;
    const [maha2num, antar2num, monthly2num] = periods2;
    const mahaRel = getTodayRel(maha1num, maha2num);
    const antarRel = getTodayRel(antar1num, antar2num);
    const monthlyRel = getTodayRel(monthly1num, monthly2num);
    const periodBoost = (todayPts(mahaRel)-1)*8 + (todayPts(antarRel)-1)*5 + (todayPts(monthlyRel)-1)*3;
    score += periodBoost;
  }
  const basicBoost = Math.round(((todayPts(getTodayRel(basic1,basic2))+todayPts(getTodayRel(basic2,basic1)))/2 - 1) * 6);
  score += basicBoost;
  score = Math.min(96, Math.max(12, Math.round(score)));

  let energy = score >= 70 ? 'flowing' : score >= 45 ? 'steady' : 'tense';
  if (sameNum) energy = 'amplified';

  const labels = {1:'Sun',2:'Moon',3:'Jupiter',4:'Rahu',5:'Mercury',6:'Venus',7:'Ketu',8:'Saturn',9:'Mars'};
  const dayLabel = sameNum ? `${labels[daily1]} × ${labels[daily2]}` : `${labels[daily1]} meets ${labels[daily2]}`;

  const headline = _getDayHeadline(daily1, daily2, sameNum);
  const detail = _getDayDetail(daily1, daily2, sameNum, dr1, dr2);
  const doTogether = _getDayDo(daily1, daily2, sameNum);
  const watchTogether = _getDayWatch(daily1, daily2, sameNum);

  if (yogas1.includes('easy_money') || yogas2.includes('easy_money')) {
    score = Math.min(96, score + 6);
    doTogether.push('Financial luck is active between you today — act on what presents itself');
  }

  return {
    score: Math.min(96, Math.max(12, score)),
    energy,
    day_label: dayLabel,
    headline,
    detail,
    do_together: doTogether.slice(0, 3),
    watch_together: watchTogether.slice(0, 2),
  };
}

function _getDayHeadline(d1, d2, same) {
  if (same) {
    const amplified = {
      1:"Double Sun day — authority and confidence amplified. Everything initiated today carries double weight.",
      2:"Double Moon day — emotional depth and creative sensitivity at maximum. What's felt today is felt completely.",
      3:"Double Jupiter day — wisdom and clarity doubled. The decisions made today have unusual soundness.",
      4:"Double Rahu day — maximum unpredictability. Original thinking peaks, practical grounding requires effort.",
      5:"Double Mercury day — sharpest commercial and financial thinking of the cycle. Act on what the analysis shows.",
      6:"Double Venus day — maximum beauty and warmth between you. What's expressed today is expressed completely.",
      7:"Double Ketu day — deep intuitive resonance. The unspoken understanding peaks today.",
      8:"Double Saturn day — maximum karmic weight. What's built or repaired today compounds.",
      9:"Double Mars day — maximum energy and intensity. Direct it outward before it turns inward.",
    };
    return amplified[d1] || "Same energy amplified today — everything is more.";
  }
  const map = {
    '1_2':"Sun meets Moon — authority softens into attunement today. The bold and the sensitive in the same room.",
    '1_3':"Sun meets Jupiter — authority backed by wisdom. The strategic decision today is both fast and sound.",
    '1_4':"Sun meets Rahu — direction meets disruption. Stay curious about the unconventional angle.",
    '1_5':"Sun meets Mercury — authority and intelligence aligned. The sharpest day for joint practical decisions.",
    '1_6':"Sun meets Venus — confidence and beauty together. Socially and professionally both peak.",
    '1_7':"Sun meets Ketu — bold action with luck behind it. Today's opportunity is real.",
    '1_8':"Sun meets Saturn — initiative meets patience. One wants to move, one wants to wait. Both are right.",
    '1_9':"Sun meets Mars — two fires in the same space. Direct the energy before it directs you.",
    '2_3':"Moon meets Jupiter — emotional intelligence and wisdom together. The advice given today lands deeply.",
    '2_4':"Moon meets Rahu — sensitivity meets instability. Creative energy peaks, practical grounding drops.",
    '2_5':"Moon meets Mercury — feeling and thinking in conversation. Communication clarity available today.",
    '2_6':"Moon meets Venus — maximum warmth and creative depth. The most beautiful day for genuine connection.",
    '2_7':"Moon meets Ketu — emotional depth and philosophical detachment. Understanding arrives without words.",
    '2_8':"Moon meets Saturn — sensitivity meets heaviness. Show up for each other before being asked.",
    '2_9':"Moon meets Mars — depth and intensity together. Passion is available and so is volatility.",
    '3_4':"Jupiter meets Rahu — wisdom stress-tests the unconventional. The friction today is productive.",
    '3_5':"Jupiter meets Mercury — wisdom and intelligence. The analysis today is both smart and sound.",
    '3_6':"Jupiter meets Venus — values and beauty converging. Creative work with substance today.",
    '3_7':"Jupiter meets Ketu — wisdom and seeking together. The deep conversation available today is rare.",
    '3_8':"Jupiter meets Saturn — patience and wisdom. Long-term thinking has maximum clarity today.",
    '3_9':"Jupiter meets Mars — wisdom and courage aligned. The principled bold move today is right.",
    '4_5':"Rahu meets Mercury — original thinking meets sharp analysis. Interesting ideas, verify before executing.",
    '4_6':"Rahu meets Venus — unconventional beauty. The creative output today surprises even you.",
    '4_7':"Rahu meets Ketu — both shadow planets active. Deep and destabilizing in equal measure.",
    '4_8':"Rahu meets Saturn — chaos meets patience. 8 grounds what 4 generates today.",
    '4_9':"Rahu meets Mars — maximum energy with minimum grounding. Physical outlet is essential.",
    '5_6':"Mercury meets Venus — commercial intelligence and beauty together. Creative commerce peaks.",
    '5_7':"Mercury meets Ketu — financial intelligence and luck aligned. The opportunity today is real.",
    '5_8':"Mercury meets Saturn — sharp analysis and patient discipline. The financial decision today holds.",
    '5_9':"Mercury meets Mars — intelligence and courage. Competitive instinct at its sharpest.",
    '6_7':"Venus meets Ketu — beauty and fortune together. Lucky and beautiful simultaneously.",
    '6_8':"Venus meets Saturn — earned beauty. The long creative effort finally shows today.",
    '6_9':"Venus meets Mars — beauty and passion. Channel it before it combusts.",
    '7_8':"Ketu meets Saturn — fortune meets sustained effort. The unexpected breakthrough in a long project.",
    '7_9':"Ketu meets Mars — luck and courage together. Bold moves are protected today.",
    '8_9':"Saturn meets Mars — discipline and intensity. Maximum sustained output is available.",
  };
  const key = [Math.min(d1,d2),Math.max(d1,d2)].join('_');
  return map[key] || `${PLANET_NAMES_COMPAT[d1]} meets ${PLANET_NAMES_COMPAT[d2]} today.`;
}

function _getDayDetail(d1, d2, same, dr1, dr2) {
  if (same) {
    const details = {
      1:"Both running Sun energy today — everything initiated together carries real weight. The confidence is warranted. The risk is that the ego is also doubled. Choose the one thing worth directing this toward.",
      2:"Both in Moon mode — the emotional attunement between you today is at its peak. Whatever is created or expressed carries unusual depth. The shadow is that if one is off, the other will follow.",
      3:"Double Jupiter — the clearest strategic thinking available in this pairing. What you plan today is likely to be sound. The risk is getting too serious to enjoy being together.",
      4:"Double Rahu — original thinking peaks. The creative ideas today are genuinely interesting. The execution will require external structure that neither of you will naturally provide.",
      5:"Double Mercury — the sharpest financial and commercial day of the cycle. The analysis is accurate. Trust it, act on it, and don't let overthinking delay the window.",
      6:"Double Venus — maximum warmth and aesthetic richness. What you create or express together today has a quality that other days can't match. Say the things that deserve to be said.",
      7:"Double Ketu — the wordless understanding between you peaks today. The intuitive reads are accurate. Practical matters should wait — this day is for depth, not logistics.",
      8:"Double Saturn — maximum karmic weight. Whatever effort is made today compounds. Whatever is repaired today holds. Don't waste it on things that don't matter.",
      9:"Double Mars — both running at maximum intensity. The energy available today is extraordinary. The only question is direction. Choose the external challenge before the internal one chooses you.",
    };
    return details[d1] || "Same energy doubled between you — everything is amplified in both directions today.";
  }
  const map = {
    '1_2':"One of you is in authority mode, the other in attunement mode. The combination covers both fronts that most situations need — direction and human intelligence. The risk is 1 moving so fast that 2's reading of the room gets left behind.",
    '1_3':"Authority and wisdom running simultaneously. The decisions made today are both fast and sound — a rare combination. Neither the boldness nor the judgment is operating alone.",
    '1_4':"Direction meets disruption. 1's instinct to lead meets 4's instinct to question everything. The unconventional angle 4 brings today is probably worth more than the friction it creates.",
    '1_5':"Two results-oriented energies in alignment. The practical decisions made together today are likely to be the right ones. Neither overthinks; neither shrinks from the ask.",
    '1_6':"Confidence and warmth together. Whatever this pairing presents publicly today lands with unusual force. The audience reads you as a unit worth noticing.",
    '1_7':"The bold move has fortune behind it today. 1 provides the nerve; 7's energy provides the quiet luck. The ask that seemed too large — today the conditions are right.",
    '1_8':"One wants to move now, one wants to be sure first. Both are correct about different things. The patience is not stubbornness — it is how 8 protects the thing being built.",
    '1_9':"Fire meets fire. Everything you aim at together today gets hit. The only variable is whether you're aiming at the same target.",
    '2_3':"Emotional intelligence and wisdom operating simultaneously. The insight produced today has both feeling and clarity — the combination that makes it actually useful rather than just accurate.",
    '2_4':"Emotional depth meets radical creativity. The ideas generated today are genuinely original. The practical application should wait for a more grounded moment.",
    '2_5':"The heart and the mind in conversation. 2 feels what 5 can articulate. 5 understands what 2 can express. Communication today is unusually clear.",
    '2_6':"Maximum warmth between you today. Whatever is expressed has a richness that other days can't produce. This is one of those days that becomes a memory worth having.",
    '2_7':"Both operating below the surface today. The understanding between you is near-wordless. Trust the reads — they're more accurate than usual.",
    '2_8':"Both in giving mode today. The mutual support is real and unrequested. The risk is that neither asks for what they need — and today both need something.",
    '2_9':"Depth and intensity in the same space. The connection available today is real and charged. Channel it deliberately or it finds its own direction.",
    '3_4':"Wisdom stress-tests unconventional thinking. The friction between you today is productive — 4's instinct to question 3's framework occasionally reveals something important.",
    '3_5':"Two of the best analytical minds in the system running simultaneously. The strategic analysis today is unusually reliable. Whatever you plan together now is likely to hold.",
    '3_6':"Values and beauty converging. The creative work done together today has both substance and aesthetic quality — rare and worth protecting.",
    '3_7':"The deep conversation available in this pairing today goes somewhere most conversations can't. Make the time. The insight that arrives reorients things.",
    '3_8':"Patient wisdom and patient work. The foundation laid today through sustained principled effort lasts in a way that faster work doesn't.",
    '3_9':"Conviction and courage running together. The principled bold move today has both the knowledge and the nerve behind it.",
    '4_5':"Original thinking plus sharp analysis. The commercial idea that emerges today is genuinely interesting. Verify before executing — the enthusiasm is real, and so is the Rahu.",
    '4_6':"Unconventional and beautiful. Whatever you create together today has an originality that surprises even you.",
    '4_7':"Both running deep seeking energy. The conversation goes places most conversations don't. Light on practical output — heavy on insight.",
    '4_8':"Chaos finds an unexpected counterweight in patience today. 8 grounds what 4 generates. The dynamic works when both accept their role.",
    '4_9':"Maximum kinetic energy with minimal grounding. The only productive outlet today is physical. Everything else risks escalating.",
    '5_6':"Commercial and aesthetic both peak today. The pitch, the presentation, the beautiful business decision — all favored.",
    '5_7':"Financial luck is structurally active. The opportunity that arrives today between you is real. Act on it before analysis delays it past the window.",
    '5_8':"Sharp methodical intelligence. The financial decision made together today is built on both analysis and patience. It will hold.",
    '5_9':"Street smart and competitive energy together. The business instinct today is sharper together than alone. Move while the window is open.",
    '6_7':"Lucky and beautiful simultaneously. Whatever you plan today, something better than planned tends to happen.",
    '6_8':"The long creative effort showing its first real results. Today is the day the sustained work becomes visible.",
    '6_9':"The most romantically charged day in this pairing's cycle. Quality time today creates quality memory. Worth protecting from both schedules.",
    '7_8':"The unexpected breakthrough in the sustained effort. 7's luck arrives precisely when 8's work has built the foundation it needed. Today is that convergence.",
    '7_9':"Fortune backing courage. The bold move that seemed to require more luck than was available — today it is.",
    '8_9':"Maximum sustained output. The combination of 8's discipline and 9's intensity produces more today than either produces alone.",
  };
  const key = [Math.min(d1,d2),Math.max(d1,d2)].join('_');
  return map[key] || "Your energies are running in interesting ways today. Pay attention to what emerges.";
}

function _getDayDo(d1, d2, same) {
  const map = {
    '1_1':["Make the joint bold decision that's been waiting","Be visible together today — authority doubled"],
    '1_2':["Have the conversation requiring both confidence and sensitivity","Make the ask — you're more persuasive as a unit today"],
    '1_3':["Make the strategic decision that's been pending — today it's both fast and sound","Take the principled bold move"],
    '1_4':["Let the unconventional angle inform the direction before committing","Brainstorm freely — capture what emerges"],
    '1_5':["Close the deal or make the important practical decision","Any shared financial or professional move belongs today"],
    '1_6':["Show up together publicly — you read as a unit worth watching","Express appreciation — it lands with unusual force today"],
    '1_7':["Make the ask that requires fortune to back it","Say yes to the opportunity that presents itself"],
    '1_8':["Start the thing requiring both launch energy and sustained commitment","Trust the timeline — what 8 is protecting will matter"],
    '1_9':["Direct the combined energy at an external challenge","The competitive situation belongs today — go into it together"],
    '2_2':["Create something together — the emotional output today is extraordinary","Say what deserves to be said"],
    '2_3':["Have the honest conversation — emotional intelligence + wisdom available simultaneously","Create something requiring both feeling and sound judgment"],
    '2_4':["Generate freely — don't filter the ideas today","Creative output without worrying about viability yet"],
    '2_5':["Communicate what's been hard to say — it will land today","Collaborate on anything requiring both emotional and analytical intelligence"],
    '2_6':["Spend time without agenda — today just being together is the point","Create something beautiful"],
    '2_7':["Trust the intuitive reads on each other — they're accurate today","Go deep — the surface conversation wastes what's available"],
    '2_8':["Show up for each other without waiting to be asked","One of you asks for what you need today — break the silence"],
    '2_9':["Channel the intensity into physical activity or creative passion","Express the depth of the connection — it wants to be said"],
    '3_3':["Make the strategic joint decision — double wisdom supporting it","Plan something long-term together"],
    '3_4':["Let wisdom stress-test the unconventional idea — the friction is useful","Research together"],
    '3_5':["Make the expert decision — combined analysis today is most reliable","Write, plan, or strategize — the output will hold"],
    '3_6':["Create something with both substance and beauty","Have the values conversation — you're more aligned than you know"],
    '3_7':["Have the philosophical conversation — it goes somewhere today","Travel or change scene — the insight arrives in movement"],
    '3_8':["Work on the long-term project — today's foundation lasts","Make the patient ethical decision together"],
    '3_9':["Take the principled bold stand together","Advocate for something that matters — the combination is powerful today"],
    '4_4':["Generate without filtering — let the original ideas emerge","Creative work — don't worry about viability yet"],
    '4_5':["Brainstorm the commercial idea — intelligence verifies what originality generates","Research together"],
    '4_6':["Create something with unconventional beauty","Let the surprise in today's collaboration happen"],
    '4_7':["Have the honest existential conversation — it goes places today","Acknowledge what you're both seeking"],
    '4_8':["8 grounds 4's best thinking today — work on the creative project together","Let the practical anchor the original"],
    '4_9':["Physical activity together — this is the productive outlet today","Competitive sport or physical challenge"],
    '5_5':["Make the important financial or commercial decision — the analysis is peak today","Execute on what the intelligence is showing"],
    '5_6':["Make the commercial creative move","Present or pitch together — most persuasive today"],
    '5_7':["Act on the financial opportunity — today's luck is real","Make the financial decision together"],
    '5_8':["Make the important joint financial decision","Plan long-term financial strategy together"],
    '5_9':["Execute the competitive business move","Negotiate or close — street smart energy peaks today"],
    '6_6':["Create something extraordinary together","Say what deserves to be said — it lands completely today"],
    '6_7':["Make plans and let them become something better","Romantic or social investment today — it compounds"],
    '6_8':["Celebrate the long-term creative effort that's finally showing","Invest in something beautiful together that will last"],
    '6_9':["Spend quality time — this is the most romantically charged day","Create something passionate together"],
    '7_7':["Trust the intuitive understanding — it's most accurate today","The deep conversation that doesn't require explanation"],
    '7_8':["Make the move that luck and effort together have prepared","Trust the unexpected opportunity — it's real today"],
    '7_9':["Make the bold joint move — fortune is behind it","Take the risk that courage and luck together make reasonable"],
    '8_8':["Long-term work together — what's built today compounds","Explicit acknowledgment of what the other is doing"],
    '8_9':["High-output work together — physical or professional","Complete the demanding joint project"],
    '9_9':["Direct the energy at an external challenge — together","The bold competitive move belongs today"],
  };
  const key = same ? `${d1}_${d2}` : [Math.min(d1,d2),Math.max(d1,d2)].join('_');
  return map[key] || ["Spend intentional time together — the energy is worth honoring"];
}

function _getDayWatch(d1, d2, same) {
  const map = {
    '1_1':["Whose idea it is will matter more than it should today — address it directly","Power struggle risk is elevated — choose the one thing worth directing this toward"],
    '1_2':["Check in — 1's drive can miss 2's emotional undercurrent","2 may feel unseen in 1's momentum today — one acknowledgment changes it"],
    '1_3':["3 may hold 1 to ethical standards that feel constraining — the friction is productive"],
    '1_4':["Financial decisions together need independent verification today"],
    '1_5':["Cold efficiency could damage something warm — one genuine human moment changes the dynamic"],
    '1_6':["If 6 is disappointed today and 1 hasn't noticed — the reaction will be disproportionate"],
    '1_7':["Luck is real but not unlimited — don't overextend on the fortune today"],
    '1_8':["Both want credit today and neither will ask — acknowledge explicitly"],
    '1_9':["One trigger away from a memorable argument — direct outward first"],
    '2_2':["If one is struggling today, the other will mirror it — check in before connecting"],
    '2_3':["3 may be more judgmental than usual — 2 will feel it as verdict not analysis"],
    '2_4':["Keep finances separate today — the combination creates impulsive decisions"],
    '2_5':["5 will think 2 is being irrational. 2 will feel 5 is cold. Both are partially right."],
    '2_6':["Words from 6 today will land on 2 more deeply than 6 intends — choose carefully"],
    '2_7':["7 is more detached than usual today — 2 shouldn't read abandonment into withdrawal"],
    '2_8':["Neither will ask for what they need — one must break the pattern today"],
    '2_9':["9's edge today will cut 2 more deeply than 9 intends — register the gap"],
    '3_3':["If a principled disagreement emerges today, neither will let it go — is it worth the energy?"],
    '3_4':["Joint financial commitments today need verification"],
    '3_5':["5 may push for a shortcut 3 won't accept — the disagreement is productive"],
    '3_6':["3 may hold 6 to unannounced standards today — 6 will feel judged before understanding why"],
    '3_7':["7 may want to change plans — 3 should name the pattern without fighting it"],
    '3_8':["Both may be too serious today — lightness is maintenance, not distraction"],
    '3_9':["9 may move before 3 is ready — coordinate timing before acting"],
    '4_4':["Financial decisions require external input today — do not execute without verification"],
    '4_5':["Keep financial matters completely separate today"],
    '4_6':["Financial complications possible — keep separate from the creative collaboration"],
    '4_7':["Practical matters today need to wait — neither is grounded enough"],
    '4_8':["The pace difference is sharpest today — name it before it becomes conflict"],
    '4_9':["Do not make joint legal or financial decisions today — the impulse has no brakes"],
    '5_5':["Anxiety can double today — check in on mental load, not just the agenda"],
    '5_6':["Luxury spending today needs 5's scrutiny — 6's standard is high and expensive"],
    '5_7':["Save something from what arrives — the pattern is to generate and release"],
    '5_8':["5 will have moved before 8 has processed — coordinate timing explicitly"],
    '5_9':["Keep the competition directed outward — internal competition wastes the energy"],
    '6_6':["Words said in frustration today will be quoted back for months — choose them carefully"],
    '6_7':["7 may seem more distant than usual — 6 should not interpret this as judgment"],
    '6_8':["6 may feel 8 is moving too slowly — the timeline is right even if it doesn't feel like it"],
    '6_9':["If this tips into conflict today, the words will outlast the reason for them"],
    '7_7':["Neither is especially grounded today — practical decisions should wait"],
    '7_8':["8 may feel 7 isn't taking things seriously enough — it's 7's way, not disrespect"],
    '7_9':["9 may push harder than 7's luck can protect — calibrate the boldness"],
    '8_8':["Neither will ask for what they need today — one must go first"],
    '8_9':["9 may push 8 past their threshold — check the temperature before the explosion"],
    '9_9':["If the energy turns inward today, it escalates fast — redirect before the first word"],
  };
  const key = same ? `${d1}_${d2}` : [Math.min(d1,d2),Math.max(d1,d2)].join('_');
  return map[key] || ["Check in with each other before the day runs away from you"];
}

// ─── Relationship type detector ────────────────────────────────────────────────
export function detectRelationshipInsight(basic1, destiny1, basic2, destiny2) {
  const key = [Math.min(basic1, basic2), Math.max(basic1, basic2)].join('_');
  const pair = PAIR_DYNAMICS[key];
  const destinyKey = [Math.min(destiny1, destiny2), Math.max(destiny1, destiny2)].join('_');
  const destinyPair = PAIR_DYNAMICS[destinyKey];
  return {
    core: pair?.core || "An interesting combination of two distinct energies.",
    strength: pair?.strength || "Each brings something the other lacks.",
    tension: pair?.tension || "The differences require conscious navigation.",
    close_connection: pair?.close_connection || "Genuine connection is available when both invest.",
    friendship: pair?.friendship || "As friends: each enriches the other's perspective.",
    growth: pair?.growth || "Both grow by engaging with what the other represents.",
    destiny_note: destinyPair ? `On a life path level: ${destinyPair.core}` : null,
  };
}
