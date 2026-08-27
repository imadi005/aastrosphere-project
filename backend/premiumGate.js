// ═══════════════════════════════════════════════════════════════════════════════
// PREMIUM CONTENT GATING — shared helpers used by /api/chart, /api/insights/*,
// and /api/compatibility to withhold premium fields from non-subscribers.
//
// Security note: gating happens SERVER-SIDE by omitting the real value from
// the JSON response entirely — never by sending the full data and asking the
// client to hide it. A locked field always comes back as:
//   { locked: true, preview: "<short teaser>" }
// never as the real content plus a flag.
// ═══════════════════════════════════════════════════════════════════════════════

import { getAuth, getDb } from './firebaseAdmin.js';

// Same env var / bypass list used by authMiddleware.js's requireCredits —
// test accounts see full premium content everywhere, same as unlimited asks.
const TEST_UIDS = (process.env.TEST_ACCOUNT_UIDS || '')
  .split(',')
  .map(u => u.trim())
  .filter(Boolean);

/**
 * Unlike requireAuth, this never blocks the request. If a valid Firebase ID
 * token is present, req.uid is set; otherwise the request proceeds anonymously
 * and every route falls back to the free-tier view. This lets logged-out or
 * token-less clients still get a (locked) response instead of a hard 401.
 */
export async function optionalAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const match = header.match(/^Bearer (.+)$/);
  if (!match) { req.uid = null; return next(); }
  try {
    const decoded = await getAuth().verifyIdToken(match[1]);
    req.uid = decoded.uid;
  } catch (e) {
    req.uid = null;
  }
  next();
}

/** Reads the same subscriptionActive/subscriptionExpiresAt fields the Ask credits system uses. */
export async function isSubscribed(uid) {
  if (!uid) return false;
  if (TEST_UIDS.includes(uid)) return true;
  try {
    const snap = await getDb().collection('users').doc(uid).get();
    if (!snap.exists) return false;
    const data = snap.data();
    const expiresAt = data.subscriptionExpiresAt?.toMillis?.() ?? 0;
    return data.subscriptionActive === true && expiresAt > Date.now();
  } catch (e) {
    return false; // Firestore hiccup — fail closed to the free view, not open.
  }
}

/** Wraps a value as a locked placeholder — never leaks the real content. */
export function locked(preview) {
  return { locked: true, preview };
}

/** Returns the real value if subscribed, otherwise a locked placeholder. */
export function gate(subscribed, value, preview) {
  return subscribed ? value : locked(preview);
}

/**
 * Whole-response gating for endpoints that return one flat prediction object
 * (Weekly/Monthly/Yearly Insights, the deep profile, Compatibility). Keeps
 * only `freeKeys` from `raw` when not subscribed, and adds `locked: true` +
 * `locked_preview`. When subscribed, returns `raw` unchanged (no `locked`
 * key at all, so the client's single check — `data['locked'] == true` —
 * works the same way across every gated endpoint).
 */
export function gateResponse(raw, freeKeys, subscribed, preview) {
  if (subscribed) return raw;
  const out = {};
  for (const k of freeKeys) out[k] = raw[k];
  out.locked = true;
  out.locked_preview = preview;
  return out;
}
