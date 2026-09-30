// ═══════════════════════════════════════════════════════════════════════════════
// ASK CHATBOT — PRICING PLANS (single source of truth)
//
// Real cost per question (Sonnet, with system-prompt caching): ~₹0.85, worst
// case ~₹1.00. Store commission assumed at 15% (small-business tier, both
// Play Store and App Store). Numbers below were sized against those two
// figures — see the pricing conversation for the full margin math.
//
// This file is DATA ONLY — no purchase/verification logic lives here. That
// belongs in the (future) IAP verification endpoint, which will call
// grantCredits() / activateSubscription() from authMiddleware.js after
// validating a receipt against these same plan ids.
// ═══════════════════════════════════════════════════════════════════════════════

export const QUESTION_PACKS = [
  { id: 'pack_small', label: 'Small', questions: 3, priceInr: 19 },
  { id: 'pack_popular', label: 'Popular', questions: 10, priceInr: 39, popular: true },
  { id: 'pack_value', label: 'Value', questions: 50, priceInr: 199 },
];

// Single premium tier. Also unlocks full Chart/Insights/Circle content (see
// premiumGate.js) at zero marginal cost, since none of that hits the LLM.
export const SUBSCRIPTION_PLANS = [
  { id: 'sub_monthly', label: 'Monthly', priceInr: 199, periodDays: 30 },
  { id: 'sub_annual', label: 'Annual', priceInr: 2359, periodDays: 365 },
];

// Free trial size lives in authMiddleware.js (FREE_TRIAL_CREDITS) since it's
// read inside a Firestore transaction — re-exported here just so callers
// that only need pricing data don't have to import the auth module too.
export { FREE_TRIAL_CREDITS } from './authMiddleware.js';
