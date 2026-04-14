// ═══════════════════════════════════════════════════════════════
// AASTROSPHERE PREDICTIONS ENGINE
// Based on Vedic Numerology — Saurabh Avasthi framework
// ═══════════════════════════════════════════════════════════════

import {
  basicNumber, destinyNumber, currentMahadasha, currentAntardasha,
  currentMonthlyDasha, dailyDasha, hourlyDasha, buildGrid,
  buildFrequencyMap, PLANET_NAMES
} from './numerology.js';

// ─── Planet descriptions ──────────────────────────────────────
export const PLANET_DESC = {
  1: { name: 'Sun', hindi: 'Surya', energy: 'Solar', domain: 'Authority, Leadership, Father, Government' },
  2: { name: 'Moon', hindi: 'Chandra', energy: 'Lunar', domain: 'Emotions, Mother, Creativity, Mind' },
  3: { name: 'Jupiter', hindi: 'Guru', energy: 'Expansive', domain: 'Wisdom, Knowledge, Family, Luck' },
  4: { name: 'Rahu', hindi: 'Rahu', energy: 'Shadow', domain: 'Illusion, Technology, Foreign, Unexpected' },
  5: { name: 'Mercury', hindi: 'Budh', energy: 'Communicative', domain: 'Business, Intelligence, Communication, Finance' },
  6: { name: 'Venus', hindi: 'Shukra', energy: 'Venusian', domain: 'Love, Luxury, Beauty, Relationships' },
  7: { name: 'Ketu', hindi: 'Ketu', energy: 'Spiritual', domain: 'Moksha, Intuition, Travel, Detachment' },
  8: { name: 'Saturn', hindi: 'Shani', energy: 'Karmic', domain: 'Discipline, Hard Work, Delays, Justice' },
  9: { name: 'Mars', hindi: 'Mangal', energy: 'Fiery', domain: 'Energy, Courage, Action, Aggression' },
};

// ─── Number characteristics ───────────────────────────────────
export const NUMBER_TRAITS = {
  1: {
    keywords: ['Leadership', 'Authority', 'Ambition', 'Independence'],
    positive: ['Active', 'Ambitious', 'Confident', 'Leader', 'Courageous', 'Determined', 'Visionary', 'Original'],
    negative: ['Aggressive', 'Stubborn', 'Impatient', 'Domineering', 'Arrogant'],
    destructive: ['Bully', 'Egotistical', 'Ruthless', 'Tyrannical', 'Narcissistic'],
    core: 'The Pioneer — driven to lead, initiate, and achieve recognition. "Hum jahan khade hote hain, line wahin se shuru hoti hai."',
    dasha_positive: 'Financial growth, status elevation, name and fame, career advancement, leadership roles, competition victories, awards and recognition.',
    dasha_negative_single_without_3_9: 'Confidence decreases, leadership qualities diminish, reduced ego, mellowed attitude, less assertive — softer phase.',
    dasha_with_destiny: 'Dictatorial tendencies emerge. Exceptional leadership but heightened ego and dominating attitude.',
  },
  2: {
    keywords: ['Emotion', 'Creativity', 'Partnership', 'Intuition'],
    positive: ['Cooperative', 'Friendly', 'Compassionate', 'Adaptable', 'Supportive', 'Sensitive', 'Tactful'],
    negative: ['Easily hurt', 'Indecisive', 'Insecure', 'Overemotional', 'Self-doubting'],
    destructive: ['Deceptive', 'Manipulative', 'Passive-aggressive', 'Cruel'],
    core: 'The Nurturer — deeply emotional, creative, and empathetic. Seeks partnership and emotional security.',
    dasha_positive: 'Social circle expands, contact with influential people, networking success, becoming more visible and influential.',
    dasha_behavior: 'Emotional sensitivity increases, creativity surges, more self-expressive, sentimental and nostalgic.',
  },
  3: {
    keywords: ['Wisdom', 'Knowledge', 'Family', 'Discipline'],
    positive: ['Cheerful', 'Humorous', 'Enthusiastic', 'Creative', 'Wise', 'Disciplined', 'Knowledgeable'],
    negative: ['Bored', 'Impulsive', 'Moody', 'Restless', 'Irresponsible'],
    destructive: ['Gossip', 'Greed', 'Jealous', 'Vindictive'],
    core: 'The Wise One — values knowledge, family, and ethics. Natural counselor and advisor.',
    dasha_positive: 'Learning, family bonding, spiritual growth, seeking a guru, life purpose clarity, educational pursuits.',
    dasha_33_warning: 'When 3 Dasha creates 33 — moral flexibility temporarily, spiritual showmanship, family bonds loosen.',
  },
  4: {
    keywords: ['Illusion', 'Unpredictability', 'Research', 'Technology'],
    positive: ['Sharp mind', 'Out-of-box thinking', 'Perfectionist', 'Researcher', 'Good memory'],
    negative: ['Unpredictable', 'Illogical', 'Spendthrift', 'Mood swings', 'Talkative without execution'],
    destructive: ['Deceptive', 'Illusionary', 'Compulsive'],
    core: 'Rahu energy — expect the unexpected. Sharp analytical mind but prone to illusion and impulsive spending.',
    dasha_positive: 'When 4 Dasha creates 44 — clarity of thought, logical behavior, meaningful travels, financial gains, increased earnings.',
    dasha_negative: 'Financial expenses, job loss, debt accumulation, scam vulnerability, accidents, mental confusion.',
    dasha_444_warning: 'Overwhelming confusion, delusions, financial turbulence, legal troubles, career instability.',
  },
  5: {
    keywords: ['Business', 'Intelligence', 'Communication', 'Finance'],
    positive: ['Adaptable', 'Clever', 'Calculative', 'Sharp mind', 'Good communicator', 'Routine follower'],
    negative: ['Impatient', 'Restless', 'Money-minded to a fault'],
    destructive: ['Prone to fraud', 'Overindulgence', 'Gambling tendency'],
    core: 'Mercury energy — sharp, calculative, business-minded. Natural affinity for money and communication.',
    dasha_positive: 'Increased cash flow, new opportunities, career advancement, financial security, business growth.',
    dasha_55: 'Dual thought, overthinking, anxiety — BUT financial abundance, wealth accumulation.',
    dasha_555_warning: 'Overconfidence, complete money focus, potential for fraudulent activity.',
    fraud_committer: '9-555 combination. Fraud victim: 555-4 combination. Protection: presence of 3 and 1.',
  },
  6: {
    keywords: ['Love', 'Luxury', 'Beauty', 'Relationships'],
    positive: ['Artistic', 'Humanitarian', 'Nurturing', 'Creative', 'Responsible', 'Musical'],
    negative: ['Argues', 'Needs appreciation', 'Self-righteous', 'Sweet tooth'],
    destructive: ['Domestic tyranny', 'Conceit'],
    core: 'Venus energy — seeks beauty, luxury, harmony. Food lover, fashion conscious, emotionally deep.',
    dasha_positive: 'Luxurious lifestyle, relationship strengthening, romantic developments, career in arts/hospitality/beauty.',
    dasha_66_warning: 'Conflicts increase, harsh speech, foul language, luxuries at others\' expense, ego-driven behavior.',
  },
  7: {
    keywords: ['Spirituality', 'Travel', 'Intuition', 'Liberation'],
    positive: ['Dignified', 'Intuitive', 'Spiritual', 'Lucky', 'Studious', 'Nature lover'],
    negative: ['Aloof', 'Melancholy', 'Skeptical', 'Lives in past'],
    destructive: ['Cheat', 'Sarcastic', 'Secret motives', 'Faithless'],
    core: 'Ketu energy — central stability, luck, travel, and spiritual inclination. The stabilizer of the grid.',
    dasha_positive: 'Luck increases, desires fulfilled, reduced struggles, travel opportunities, spiritual growth.',
    dasha_77: 'Instability, life changes, increased analytical tendency, anxiety, relationship challenges.',
    dasha_777_warning: 'Heightened anxiety, insomnia, substance use tendency, major life disruptions.',
  },
  8: {
    keywords: ['Discipline', 'Hard work', 'Karma', 'Determination'],
    positive: ['Determined', 'Disciplined', 'Compassionate', 'Humanitarian', 'Ethical'],
    negative: ['Struggles', 'Delays', 'Egoistic', 'Mood swings', 'Holds grudges'],
    destructive: ['Extreme behavior', 'Cannot forgive'],
    core: 'Saturn energy — the karmic number. Determination turns challenges to opportunities. Cycle of cause and effect.',
    dasha_88: 'BLESSINGS — professional success, financial prosperity, emotional stability, life purpose fulfillment.',
    dasha_single: 'Hard work required, disappointments, delays, financial struggles, health challenges.',
    dasha_888_warning: 'Heightened obstacles, financial struggles intensify, health concerns, emotional turmoil.',
    special: 'Shape of 8 cyclic without lifting pen. Horizontal = infinity. Karmic cause and effect.',
  },
  9: {
    keywords: ['Energy', 'Courage', 'Action', 'Leadership'],
    positive: ['Energetic', 'Bold', 'Courageous', 'Committed', 'Resourceful', 'Survivalist'],
    negative: ['Argumentative', 'Stubborn', 'Aggressive', 'Impulsive'],
    destructive: ['Violent', 'Ruthless'],
    core: 'Mars energy — warrior spirit. Highly active, bold decision-maker. "Sharp like a weapon."',
    dasha_positive: 'Confidence boost, personal growth, career advancements, leadership roles — generally positive period.',
    dasha_99_warning: 'Frustration increases, violent outbursts, legal issues, financial challenges, relationship strain.',
  },
};

// ─── Combination library ──────────────────────────────────────
export const COMBINATIONS = {
  // Pairs
  '1_9': {
    name: 'Sun-Mars',
    condition: 'without 3 in first row',
    behavior: 'Fiery temperament, intellectual, independent, engineering/surgery mindset, anger management challenge.',
    prediction: 'Professional success through hard work, higher education, careers in engineering, law, medicine.',
  },
  '3_1': {
    name: 'Jupiter-Sun (Wise Leader)',
    condition: 'without 9',
    behavior: 'Highly educated, diligent, respected for wisdom, effective communicator.',
    prediction: 'Professional fame through hard work, educational institute leadership, speech-centric professions. Father\'s role pivotal.',
  },
  '9_5': {
    name: 'Mars-Mercury',
    behavior: 'Sharp-minded, street smart, clever, money-oriented, quick-witted.',
    prediction: 'Financial success, entrepreneurial ventures, effective communication, competitive edge.',
    warning_955: 'Highly clever financial focus. 9-555: clever but potentially fraudulent.',
    warning_99_5: 'Double 9 weakens Mercury — slower mind, lower intellect in financial matters.',
  },
  '9_4': {
    name: 'Bandhan Yoga',
    condition: 'without 5',
    behavior: 'Feeling of suffocation, unsatisfied, frustrated, trapped in profession/relationships.',
    prediction: 'Challenges in freedom, hospitalization risk, legal disputes, imprisonment possible.',
    warning_odd4: 'Odd 4 (444) worsens. Even 4 (44) mitigates. With 99 = further intensified.',
    is_negative_yoga: true,
  },
  '5_4': {
    name: 'Financial Bandhan Yoga',
    condition: 'without 9',
    behavior: 'Impulsive spending, spendthrift nature, lack of financial discipline, debt accumulation.',
    prediction: 'Financial challenges throughout life. Save money in someone else\'s name.',
    warning_odd4: 'Odd 4 (444) = severely amplified financial ruin.',
    positive_44: 'Even 4 (44) transforms to positive — increased earnings, financial stability.',
    is_negative_yoga: true,
  },
  '8_4': {
    name: 'Saturn-Rahu',
    behavior: 'Accident prone, irrational behavior, unrealistic dreams, marital problems.',
    prediction: 'Chronic health conditions (diabetes/thyroid), financial challenges, research success possible.',
    warning_triple: 'Triple 8+4 = magnified. Even 44 = reduced negative.',
  },
  '2_8': {
    name: 'Moon-Saturn',
    condition: 'without 4',
    behavior_with_1_9: 'Superiority complex, arrogance.',
    behavior_without_1_9: 'Inferiority complex, lack of confidence.',
    prediction: 'Depressive nature, negative thinking, emotional challenges, family responsibilities.',
    warning: 'Even 88 = reduced negative. Odd 888 = intensified.',
  },
  '2_4': {
    name: 'Moon-Rahu',
    condition: 'without 8',
    behavior: 'Negative thoughts dominant, clever but misguided, meticulous planner, criminal tendencies.',
    prediction: 'Legal issues, financial instability, emotional turmoil.',
    positive_44: 'Even 4 (44) mitigates negative effects.',
  },
  '2_6': {
    name: 'Venus-Moon',
    condition: 'without 3',
    behavior: 'Attractive, charming, emotional, creative, media savvy, multiple affairs possible.',
    prediction: 'Success in media, photography, content creation, artistic professions. Challenges with in-laws.',
  },
  '3_2': {
    name: 'Jupiter-Moon',
    condition: 'without 6',
    behavior: 'Knowledgeable in creative pursuits, arrogant, tendency to gain weight.',
    prediction: 'Child-related challenges, large number of enemies (but harmless), obstruction in education.',
  },
  '3_6': {
    name: 'Jupiter-Venus',
    condition: 'without 2',
    behavior: 'Idealistic, rigid ethics, high marriage expectations, ego-driven.',
    prediction: 'POST MARRIAGE SUCCESS — life partner transforms destiny. Higher education, religious involvement.',
    warning_multi6: 'Multiple 6 = harsh abusive speech.',
  },
  '7_8': {
    name: 'Ketu-Saturn (Misfortune)',
    condition: 'without 1',
    behavior: 'Spiritual, healer, pessimistic, indifferent to worldly matters.',
    prediction: 'Bad luck, marital challenges, devoid of physical pleasures, reduced luck factor.',
    positive_88: 'Even 88 = luck improves dramatically.',
    warning_888: 'Triple 888 = grave situation.',
    is_negative_yoga: true,
  },
  '1_8': {
    name: 'Sun-Saturn (Defamation)',
    condition: 'without 7',
    behavior: 'Insults and humiliations, strained father-son relationship.',
    prediction: 'Legal issues with government, career obstacles, losses due to authorities.',
    positive_88: 'With 88 = SUCCESS and prosperity.',
    warning_888: 'With 888 = worse situation.',
  },
  '1_7': {
    name: 'Sun-Ketu (Raj Yoga)',
    condition: 'without 8',
    behavior: 'Highly lucky, love affairs before and after marriage.',
    prediction: 'RAJ YOGA — continuous luck, early career success, government job potential, ongoing prosperity.',
    is_positive_yoga: true,
  },
  '6_7': {
    name: 'Venus-Ketu',
    behavior: 'Attractive, multiple love interests, artistic, business-minded.',
    prediction: 'Stable love affairs, flirtatious tendencies, maintains status and lifestyle.',
  },
  '7_5': {
    name: 'Ketu-Mercury',
    condition: 'without 6',
    behavior: 'Multiple love affairs (superficial), emotional detachment, good communicator.',
    prediction: 'Interest in occult/astrology, communication-based careers. Easy money combination.',
    warning_77_55: 'Double 77+55 = alcohol tendency, unstable relationships, anxiety, insomnia.',
  },
  '6_5': {
    name: 'Venus-Mercury',
    condition: 'without 7',
    behavior: 'Internal opposition, business acumen but poor negotiation.',
    prediction: 'Obstruction in higher education, family struggles, failed relationships.',
  },

  // Triples — vertical
  '3_7_9': {
    name: 'Jupiter-Ketu-Mars (Spiritual)',
    behavior: 'Powerful spiritual combination. Active spiritual pursuit, not just contemplative.',
    prediction: 'Deep spiritual quest, potential for spiritual leadership or guidance.',
    is_positive_yoga: true,
  },
  '3_6_2': {
    name: 'Jupiter-Venus-Moon',
    behavior: 'Fixed morals, inflexible, teaching/media inclined, reluctant to marry.',
    prediction: 'Dual knowledge expertise, success in teaching/media. Health watch: diabetes, skin disorders.',
  },
  '1_7_8': {
    name: 'Sun-Ketu-Saturn (High Intuition)',
    behavior: 'Very high intuition ("Kali Zuban"), physical dissatisfaction, social worker tendency.',
    prediction: 'MENTAL PEACE AFTER 40, multiple income sources, delayed marriage, spiritual/social work.',
  },

  // Horizontals
  '3_1_9': {
    name: 'Jupiter-Sun-Mars (Head Strong Leader)',
    behavior: 'Masculine personality, strong decisive choices, stubborn, hunger for power.',
    prediction: 'Professional success, higher education, doctor/judge/engineer/lawyer. Father\'s blessings key.',
    special: 'Tomboyish quality in female charts.',
    is_positive_yoga: true,
  },
  '6_7_5': {
    name: 'Venus-Ketu-Mercury (Stable Luxury)',
    behavior: 'Loves luxuries, business acumen, artistic, romantic, plants and music lover.',
    prediction: 'MAINTAINS STATUS even in hard times. Resilience. Communication/counseling career success.',
  },
  '2_8_4': {
    name: 'Moon-Saturn-Rahu (Vipreet Raj Yoga)',
    behavior: 'Rollercoaster life, blunt/candid communication, short-tempered, superiority complex.',
    prediction: 'VIPREET RAJ YOGA potential if avoids addiction. With 3-1-9 in upper zone = success. No upper zone = downfall.',
    positive_44_88: 'With 44 or 88 = stabilizes. Multiple 22 = worsens fluctuations.',
  },
  '6_2_8': {
    name: 'Venus-Moon-Saturn (Creative Media)',
    behavior: 'Extremely creative, feminine qualities (both genders), soft-spoken, nurturing.',
    prediction: 'Success in media, journalism, film, arts, broadcasting. Emotional depth in creative work.',
  },
};

// ─── Special Yogas ────────────────────────────────────────────
export const YOGAS = {
  raj_yoga: {
    name: 'Raj Yoga',
    trigger: '1-2 combination',
    benefits: ['Top position in field', 'High rise in career', 'Ease in work', 'Government authority connection'],
    note: 'Basic 2 + Destiny 1 = strong Raj Yoga. Destiny 4/8 = weak Raj Yoga. Born on 11/22 dates = lucky.',
  },
  easy_money: {
    name: 'Easy Money',
    trigger: '5-7 combination',
    benefits: ['Easy financial gains', 'Easy relationships', 'Heightened attraction'],
    note: 'Without 2 = dry attraction, beautiful without emotion (good for modeling). With 2 = ultimate attraction.',
  },
  bandhan: {
    name: 'Bandhan Yoga',
    trigger: '9-4 without 5',
    effects: ['Suffocation', 'Unsatisfied', 'Legal issues', 'Hospitalization risk'],
  },
  financial_bandhan: {
    name: 'Financial Bandhan Yoga',
    trigger: '5-4 without 9',
    effects: ['Impulsive spending', 'Debt', 'Financial instability'],
  },
  spiritual: {
    name: 'Spiritual Yoga',
    trigger: '3-7-9',
    benefits: ['Deep spiritual quest', 'Moksha seeking', 'Active spiritual practice'],
  },
  stable_luxury: {
    name: 'Stable Luxury / Multimillionaire',
    trigger: '2-7-9 or 3-7-4',
    benefits: ['Financial stability', 'Wealth accumulation', 'Multimillionaire potential'],
  },
  profession_stable: {
    name: 'Profession Stable',
    trigger: '3-7-4',
    benefits: ['Stable career', 'Consistent growth', 'Professional security'],
    warning: 'If any of 3/7/4 becomes negative via Dasha = negative effects added.',
  },
  vipreet_raj: {
    name: 'Vipreet Raj Yoga',
    trigger: '2-8-4',
    condition: 'Must avoid addiction',
    benefits: ['Despite adversity — achieves desires', 'Overcomes obstacles'],
  },
};

// ─── Compatibility ────────────────────────────────────────────
export const COMPATIBILITY = {
  1: { good: [3, 6, 8], neutral: [4, 5, 7, 9], bad: [] },
  2: { good: [2, 3, 6, 7, 8, 9], neutral: [4, 5], bad: [1] },
  3: { good: [3, 5, 7, 9], neutral: 'all', bad: [] },
  4: { good: [3, 6, 7, 8], neutral: [1, 9], bad: [5] },
  5: { good: [3, 5, 7, 8, 9], neutral: [1, 6], bad: [4] },
  6: { good: [2, 6, 7], neutral: 'all', bad: [] },
  7: { good: [1, 3, 5, 7, 9], neutral: 'all', bad: [] },
  8: { good: [1, 2, 3, 5, 7, 9], neutral: 'all', bad: [] },
  9: { good: [1, 3, 5, 7], neutral: 'all', bad: [] },
  groups: {
    '1_4_8': 'Ambition, determination, work ethic group',
    '3_6_9': 'Spirituality, creativity, compassion group',
    '2_5_7': 'Curiosity, introspection, intellectual group',
  },
};

// ─── Health mapping ───────────────────────────────────────────
export const HEALTH_MAP = {
  1:  { common: ['Headache', 'Eye problems', 'Migraine'], others: ['Heat stroke', 'Heart problem', 'ENT issues'] },
  2:  { common: ['Depression', 'Insomnia', 'Indigestion'], others: ['Menstrual issues (ladies)', 'Low BP', 'Water retention', 'Nervous system'] },
  3:  { common: ['Liver weakness', 'Skin problems from liver'], others: ['Ear problems', 'Tonsils', 'Thyroid'] },
  4:  { common: ['Diabetes', 'BP', 'Accidents'], others: ['Asthma', 'Heart problem', 'Gas', 'Diagnostic confusion — Ayurveda helps'] },
  5:  { common: ['Anxiety', 'Insomnia', 'Constipation'], others: ['Skin problems', 'Nervous breakdown', 'Weak immunity', 'Overthinking — Solution: gym and physical activity'] },
  6:  { common: ['Gynaecological issues (females)', 'Low sperm count (males)'], others: ['Cough/cold', 'Miscarriage/abortion', 'Urine infection', 'Kidney issues'] },
  7:  { common: ['Anxiety', 'Sleep disorder', 'Overthinking'], others: ['Epilepsy', 'Instability', 'Indigestion'] },
  8:  { common: ['Dental problems', 'Intestinal indigestion'], others: ['Skin allergy', 'Memory loss after 55-60 (destiny 8 especially)', 'Bone issues', 'Arthritis'] },
  9:  { common: ['High fever', 'Violent accidents', 'Throat infections'], others: ['Pimples'] },
};

// ─── Profession mapping ───────────────────────────────────────
export const PROFESSION_MAP = {
  1: ['Administrator', 'Motivational speaker', 'Business', 'Real estate', 'Politics', 'Government jobs'],
  2: ['Photography', 'Media', 'Bollywood', 'Makeup artist', 'Art gallery', 'Salon', 'Creative fields'],
  3: ['Counsellor', 'Teacher', 'Astrology', 'Spiritual work', 'Healing', 'Nursing', 'Journalism'],
  4: ['IT', 'Software development', 'Research', 'Astrology', 'Travel industry'],
  5: ['Finance management', 'Banking', 'Accountancy (CA/CS)', 'Cash counter', 'Business'],
  6: ['Food', 'Restaurant', 'Chef', 'Acting', 'Media', 'Makeup artist', 'Salon'],
  7: ['Travel', 'Religious work', 'IT', 'Research detective', 'Occult science', 'Sales', 'Investigation'],
  8: ['Engineering', 'Medical', 'NGOs', 'Occult science', 'Management'],
  9: ['Security', 'Police', 'Army', 'Lawyer', 'Leadership'],
};

// ─── Lucky info (colors, directions, lucky numbers) ──────────
export const LUCKY_INFO_FULL = {
  1: { colors: ['Golden', 'Orange'], direction: 'East', luckyNumbers: [1, 3] },
  2: { colors: ['Milky white', 'Cream'], direction: 'Northwest', luckyNumbers: [1, 3] },
  3: { colors: ['Yellow', 'Orange'], direction: 'Northeast', luckyNumbers: [1, 3] },
  4: { colors: ['Blue', 'Black'], direction: 'Southwest', luckyNumbers: [6, 5] },
  5: { colors: ['Green'], direction: 'North', luckyNumbers: [6, 5] },
  6: { colors: ['White', 'Metallic'], direction: 'Southeast', luckyNumbers: [6, 5] },
  7: { colors: ['Sandal', 'Grey'], direction: 'Southwest', luckyNumbers: [7, 9] },
  8: { colors: ['Blue', 'Black'], direction: 'West', luckyNumbers: [8, 7] },
  9: { colors: ['Red'], direction: 'South', luckyNumbers: [7, 9] },
};

// ─── Core analysis function ───────────────────────────────────
export function analyzeGrid(dob, mahaNum, antarNum) {
  const freqMap = buildFrequencyMap(dob, mahaNum, antarNum);
  const detected = [];

  // Check all pairs
  const nums = Object.keys(freqMap).map(Number);

  // Raj Yoga detection
  if (nums.includes(1) && nums.includes(2)) {
    detected.push({ yoga: 'Raj Yoga', description: YOGAS.raj_yoga.benefits.join(', ') });
  }

  // Easy Money
  if (nums.includes(5) && nums.includes(7)) {
    detected.push({ yoga: 'Easy Money (5-7)', description: YOGAS.easy_money.benefits.join(', ') });
  }

  // Bandhan Yoga
  if (nums.includes(9) && nums.includes(4) && !nums.includes(5)) {
    detected.push({ yoga: 'Bandhan Yoga', description: 'Feeling of suffocation, legal/health risks.', isNegative: true });
  }

  // Financial Bandhan
  if (nums.includes(5) && nums.includes(4) && !nums.includes(9)) {
    detected.push({ yoga: 'Financial Bandhan', description: 'Impulsive spending, debt accumulation risk.', isNegative: true });
  }

  // Spiritual Yoga
  if (nums.includes(3) && nums.includes(7) && nums.includes(9)) {
    detected.push({ yoga: 'Spiritual Yoga (3-7-9)', description: 'Deep spiritual inclination and pursuit.' });
  }

  // 3-1-9 Head Strong
  if (nums.includes(3) && nums.includes(1) && nums.includes(9)) {
    detected.push({ yoga: '3-1-9 Uplifting', description: 'Strong decisions, potential for high achievement.' });
  }

  // Vipreet Raj
  if (nums.includes(2) && nums.includes(8) && nums.includes(4)) {
    detected.push({ yoga: 'Vipreet Raj Yoga', description: 'Rollercoaster but can overcome adversity if addictions avoided.' });
  }

  // 1-7 (without 8) — Raj Yoga
  if (nums.includes(1) && nums.includes(7) && !nums.includes(8)) {
    detected.push({ yoga: 'Sun-Ketu Raj Yoga (1-7)', description: 'Highly lucky, love affairs, early career success.', isPositive: true });
  }

  // 7-8 without 1 — Misfortune
  if (nums.includes(7) && nums.includes(8) && !nums.includes(1)) {
    detected.push({ yoga: 'Ketu-Saturn Misfortune (7-8)', description: 'Luck delayed, bad luck in negative Dasha.', isNegative: true });
  }

  // 1-8 without 7 — Defamation
  if (nums.includes(1) && nums.includes(8) && !nums.includes(7)) {
    detected.push({ yoga: 'Sun-Saturn Defamation (1-8)', description: 'Risk of insults, legal issues, strained father relationship.', isNegative: true });
  }

  // 6-7-5 Stable Luxury
  if (nums.includes(6) && nums.includes(7) && nums.includes(5)) {
    detected.push({ yoga: 'Stable Luxury Life (6-7-5)', description: 'Maintains status even in hard times, luxurious lifestyle.' });
  }

  return detected;
}

// ─── Dasha behavior text ──────────────────────────────────────
export function getDashaBehavior(dashaNum, countInGrid) {
  const texts = {
    1: {
      0: 'Anger increases, authority and leadership qualities emerge, ego amplifies, strong need for respect, confidence surge — commanding aura.',
      1_no_3_9: 'Softer phase — confidence decreases, leadership diminishes, less ego, mellowed attitude.',
      1_with_3_9: 'Anger increases, authority emerges, ego amplifies, strong presence.',
      destiny: 'Dictatorial tendencies — heightened confidence bordering overconfidence, extreme assertiveness, overwhelming ego.',
    },
    2: {
      0: 'Emotional sensitivity increases, creativity surges, self-expression rises, shyness and sentimentality emerge.',
      present: 'Deeper emotional depth, amplified creativity, heightened empathy, sentimental, self-care priority.',
    },
    3: {
      0: 'Heightened morality, addiction control improves, family attachment deepens, spirituality grows, counselling skills emerge.',
      33: 'Moral flexibility temporarily, spiritual showmanship, family bonds loosen, openness to taboo behaviors.',
      333: 'Same as 33 — already in that state, continuation of existing pattern.',
    },
    4: {
      0: 'Illusion and imaginative thinking, lack of logic, restlessness, moodiness, tries new things impulsively.',
      44: 'TRANSFORMATION — clarity of thought, logical behavior, illusions removed, meaningful travels, enhanced decision-making.',
      444: 'Overwhelming confusion, delusions, compulsive behavior, rational thinking breaks down.',
    },
    5: {
      0: 'Sharp mind, money-minded, good communication, childish/playful, speaks mind, calculative, workaholic.',
      55: 'Dual thought process, overthinking, anxiety, insomnia — but financial abundance and prosperity.',
      555: 'Overconfidence, complete money focus, fraud risk.',
    },
    6: {
      0: 'Luxury-seeking, relationship-focused, appearance-conscious, food interest, direct communication, romantic.',
      66: 'Conflict increases, harsh speech, foul language, luxuries at others\' expense, ego-driven, materialism.',
    },
    7: {
      0: 'Analytical thinking increases, LUCK and desire realization, reduced struggles, spirituality upsurge, travel ease.',
      77: 'Instability, significant life changes, relationship challenges, heightened suspicion, anxiety, insomnia.',
      777: 'Anxiety intensifies, insomnia, substance use tendency, major disruptions.',
    },
    8: {
      0: 'Hard work required, disappointments, delays, financial struggles, negative attitude, charitable inclination.',
      88: 'BLESSINGS — favorable outcomes, discipline, professional success, financial prosperity, emotional stability.',
      888: 'Heightened obstacles, financial struggles, health concerns, depressive tendencies.',
    },
    9: {
      0: 'Confidence boost, boldness, courage, assertive/competitive attitude, commitment strengthens, energy surge.',
      99: 'Frustration increases, violent outbursts, emotional guardedness, difficulty expressing feelings.',
    },
  };
  return texts[dashaNum] || {};
}

// ─── Dasha predictions ────────────────────────────────────────
export function getDashaPrediction(dashaNum) {
  const predictions = {
    1: 'Financial growth, status elevation, name and fame, awards/honors, competition victories, career advancement, leadership roles — growth in all aspects.',
    2: 'Social circle expansion, contact with influential people, networking success, becoming more visible and influential, collaborative opportunities.',
    3: 'Inclination toward learning, family love and bonding, seeking a guru, spiritual discourse, seeking life purpose, higher education.',
    4: {
      single: 'Financial expenses/losses, job loss risk, debt accumulation, scam vulnerability, accidents, unwanted travel, mental confusion.',
      double: 'Increased earnings, savings, controlled expenses, business profits, job increment, sudden unexpected gains, debt clearance.',
      triple: 'Financial turbulence, career instability, deceptive ventures, health issues, disrupted relationships, legal troubles.',
    },
    5: {
      single: 'Increased cash flow, new investment opportunities, career advancement, business ventures, financial security.',
      double: 'Extra financial abundance, wealth accumulation, business favorable — manage anxiety.',
      triple: 'Heightened financial ambition, risks, potential fraud activity — exercise caution.',
    },
    6: {
      single: 'Luxurious lifestyle, relationship strengthening, romantic/marital developments, career in arts/hospitality.',
      double: 'Financial extravagance, strained relationships, conflicts, impulsiveness — social consequences.',
    },
    7: {
      single: 'Luck and success, ease overcoming challenges, stability, spiritual growth, travel opportunities.',
      double: 'Instability in career and life, relationship challenges — embrace transformation.',
      triple: 'Addiction risk, professional challenges, impulsive decisions — needs healthy coping.',
    },
    8: {
      single: 'Financial hardship, career challenges, health management needed, shift toward compassion/charity.',
      double: 'Professional advancement, financial growth, improved health, life purpose fulfillment.',
      triple: 'Financial and career setbacks, stress-related health problems, emotional struggles.',
    },
    9: {
      single: 'Personal growth, career advancements, increased activity, leadership opportunities — positive period.',
      double: 'Legal issues, financial challenges, relationship strain, health concerns, conflict-prone.',
    },
  };
  return predictions[dashaNum];
}

// ─── Finance predictions ──────────────────────────────────────
export const FINANCE_INDICATORS = {
  positive: {
    numbers: [1, 5, 6],
    combinations: {
      88: 'Bulk financial gains, bonuses, promotions, share market intuition, government connections.',
      44: 'Increased savings, financial stability, controlled expenses.',
      675: 'Realization of desires — long-held financial goals achieved.',
      319: 'Uplifting period — improvements in personal and financial life.',
    },
    notes: 'Destiny Dasha = good for money and power. Exception: Dasha 2 and 7 may not bring money.',
  },
  negative: {
    numbers: [4],
    combinations: {
      888: 'Prolonged difficulties, severe financial losses, job insecurity.',
      999: 'Frustration, conflicts blocking financial progress.',
      777: 'Sudden job changes, career instability.',
      66: 'Financial extravagance, potential legal issues.',
      94: 'Financial Bandhan — stuck situations, debt.',
      54: 'Financial Bandhan — impulsive spending, debt.',
    },
  },
  career_change_dashas: ['multiples of 7', 'odd 8', '4'],
};

// ─── Relationship predictions ─────────────────────────────────
export const RELATIONSHIP_INDICATORS = {
  marriage_favorable: {
    yearly_dasha: [3, 2, 7, 6, 9],
    primary: 3,
    notes: 'Yearly Dasha 3 = highest priority for marriage.',
  },
  love_affair: ['62', '66', '67', '75', '17'],
  divorce_risk: {
    single: { 4: 'separation', 8: 'giver but odd=separation', 3: 'family dedicated' },
    multiple: { 3: 'divorce indication', 7: 'instability/divorce', 4: 'separation', 8: 'odd=separation, even=preserves' },
  },
  childbirth_favorable: [3, 6, 2],
  childbirth_avoid: ['multiple 6', 'multiple 7', 'multiple 2', 'odd 8'],
  csection_indicator: 'Presence of 7 (Ketu) and 9 (Mars)',
};

// ─── Property/Real estate ─────────────────────────────────────
export const PROPERTY_INDICATORS = {
  favorable_dasha: [8, 1, 6, 3],
  single_1: 'Consistent property acquisition, real estate profession success.',
  multiple_1_no_destiny: 'Litigation, financial losses, property theft risk. Avoid builders/unauthorized colonies.',
  multiple_1_with_destiny: 'Significant property gains.',
  even_8: 'Bulk properties, gifted properties, property wealth accumulation.',
  ideal_time: 'Dasha 5 (cash flow) + 88 in grid + Dasha 1 = best time to buy.',
  sell: 'Only during positive Dasha periods.',
  avoid_apartment: [4, 8],
  lucky_numbers: { '1_2_3': 1, '4_5_6': 6, '7_8_9': 7 },
};

// ─── Travel predictions ───────────────────────────────────────
export const TRAVEL_INDICATORS = {
  catalysts: [4, 7],
  types: { 6: 'Luxury travel', 5: 'Tourism', 3: 'Expansion travel', 4: 'Gulf/underdeveloped countries', 7: 'Spiritual/developed countries' },
  favorable_yearly_in_maha4: [6, 7, 5],
  unfavorable_yearly_in_maha4: [4, 2, 8],
  yearly_delays: 2,
  yearly_documentary_problems: 4,
  destiny_7: 'Foreign settlement, sponsored/complimentary travel.',
};

// ─── Health period warnings ───────────────────────────────────
export const HEALTH_PERIOD_WARNINGS = {
  4: 'Yearly Dasha 4 is hazardous for health — exercise extra caution.',
  '9_4': 'Combination 9-4 with 66 indicates health problems.',
  '5_4': 'Combination 5-4 with 66 indicates health and litigation issues.',
  2: 'Yearly Dasha 2 brings emotional upset — mental health watch.',
};

// ─── Prashna (Yes/No oracle) ──────────────────────────────────
export function prashna(chosenNumber) {
  if (chosenNumber < 1 || chosenNumber > 108) return { answer: false, reason: 'Number out of range (1-108) — negative indication.' };
  const remainder = chosenNumber % 9;
  const positive = [1, 3, 5, 6, 7, 9];
  const isPositive = positive.includes(remainder === 0 ? 9 : remainder);
  return {
    answer: isPositive,
    remainder: remainder === 0 ? 9 : remainder,
    planet: PLANET_NAMES[remainder === 0 ? 9 : remainder],
    reason: isPositive ? 'Remainder indicates positive outcome.' : 'Remainder indicates negative outcome.',
  };
}

// ─── Master prediction generator ─────────────────────────────
export function generatePrediction(dob, targetDate = new Date().toISOString()) {
  const d = new Date(dob);
  const basic = basicNumber(d.getDate());
  const destiny = destinyNumber(dob);
  const maha = currentMahadasha(dob);
  const antar = currentAntardasha(dob);
  const monthly = currentMonthlyDasha(dob);
  const daily = dailyDasha(dob, targetDate);
  const grid = buildGrid(dob);
  const freqMap = buildFrequencyMap(dob, maha.number, antar.number);
  const yogas = analyzeGrid(dob, maha.number, antar.number);
  const numCount = n => freqMap[n] || 0;

  // Determine dasha behavior key
  const mahaCount = numCount(maha.number);
  const mahaKey = mahaCount === 0 ? '0' : mahaCount === 1 ? '1' : mahaCount === 2 ? '2' : '3+';

  return {
    profile: {
      basic,
      basicPlanet: PLANET_NAMES[basic],
      destiny,
      destinyPlanet: PLANET_NAMES[destiny],
      traits: NUMBER_TRAITS[basic],
      lucky: LUCKY_INFO_FULL[destiny],
      professions: PROFESSION_MAP[destiny],
      health_watch: HEALTH_MAP[basic],
    },
    current_periods: {
      maha,
      antar,
      monthly,
      daily,
      dailyPlanet: PLANET_NAMES[daily],
    },
    grid: {
      layout: grid,
      frequencies: freqMap,
      active_yogas: yogas,
    },
    predictions: {
      dasha_behavior: getDashaBehavior(maha.number, mahaCount),
      maha_prediction: getDashaPrediction(maha.number),
      finance: freqMap[1] || freqMap[5] || freqMap[6] ? 'Positive financial period indicators present.' : 'Watch for financial challenges.',
      relationship: RELATIONSHIP_INDICATORS,
    },
    compatibility: COMPATIBILITY[destiny],
  };
}
