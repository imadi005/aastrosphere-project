// ═══════════════════════════════════════════════════════════════════════════════
// AUTH + CREDITS MIDDLEWARE
//
// Firestore schema this relies on — collection `users`, doc id = Firebase uid:
//   {
//     credits: number,              // question credits remaining (consumable packs)
//     subscriptionActive: boolean,  // true if on an active unlimited-ask plan
//     subscriptionExpiresAt: Timestamp | null,
//   }
//
// New users get FREE_TRIAL_CREDITS on their first authenticated call (created
// lazily inside the transaction — no separate "register" endpoint needed).
//
// IMPORTANT: this is enforcement infrastructure only. It does NOT yet grant
// credits from a real purchase — that requires wiring Play Billing / App Store
// receipt validation to call grantCredits()/activateSubscription() below once
// the client-side purchase flow exists. Until then, every real user runs on
// the free trial allowance.
// ═══════════════════════════════════════════════════════════════════════════════

import { getAuth, getDb, FieldValue } from './firebaseAdmin.js';

export const FREE_TRIAL_CREDITS = 3;

/**
 * Verifies the Firebase ID token in the Authorization header.
 * On success, sets req.uid. On failure, responds 401 and does not call next().
 */
export async function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const match = header.match(/^Bearer (.+)$/);
    if (!match) {
      return res.status(401).json({ error: 'Missing Authorization header. Please sign in again.' });
    }
    const decoded = await getAuth().verifyIdToken(match[1]);
    req.uid = decoded.uid;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid or expired session. Please sign in again.' });
  }
}

/**
 * Must run AFTER requireAuth. Atomically checks the user's entitlement:
 *   - Active subscription  → allowed, no credit spent.
 *   - credits > 0          → allowed, 1 credit deducted.
 *   - Neither              → 402 Payment Required, request blocked.
 * New users are created with FREE_TRIAL_CREDITS on their first call here.
 * Uses a Firestore transaction so concurrent requests can't double-spend.
 */
export async function requireCredits(req, res, next) {
  try {
    const db = getDb();
    const ref = db.collection('users').doc(req.uid);

    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);

      if (!snap.exists) {
        // First authenticated call for this user — start their free trial.
        const remaining = FREE_TRIAL_CREDITS - 1;
        tx.set(ref, {
          credits: remaining,
          subscriptionActive: false,
          subscriptionExpiresAt: null,
          createdAt: FieldValue.serverTimestamp(),
        });
        return { allowed: true, creditsRemaining: remaining, viaSubscription: false };
      }

      const data = snap.data();
      const now = Date.now();
      const expiresAt = data.subscriptionExpiresAt?.toMillis?.() ?? 0;
      const hasActiveSub = data.subscriptionActive === true && expiresAt > now;

      if (hasActiveSub) {
        return { allowed: true, creditsRemaining: data.credits ?? 0, viaSubscription: true };
      }

      const credits = data.credits ?? 0;
      if (credits <= 0) {
        return { allowed: false, creditsRemaining: 0, viaSubscription: false };
      }

      tx.update(ref, { credits: FieldValue.increment(-1) });
      return { allowed: true, creditsRemaining: credits - 1, viaSubscription: false };
    });

    if (!result.allowed) {
      return res.status(402).json({
        error: 'out_of_credits',
        message: "You're out of questions. Buy a question pack or subscribe to keep asking.",
      });
    }

    req.creditsRemaining = result.creditsRemaining;
    req.viaSubscription = result.viaSubscription;
    next();
  } catch (e) {
    return res.status(500).json({ error: 'Could not verify your account. Please try again.' });
  }
}

/** Called by the (future) purchase-verification endpoint after a validated consumable purchase. */
export async function grantCredits(uid, amount) {
  const db = getDb();
  await db.collection('users').doc(uid).set(
    { credits: FieldValue.increment(amount) },
    { merge: true }
  );
}

/** Called by the (future) purchase-verification endpoint after a validated subscription purchase. */
export async function activateSubscription(uid, expiresAtMs) {
  const db = getDb();
  await db.collection('users').doc(uid).set(
    {
      subscriptionActive: true,
      subscriptionExpiresAt: new Date(expiresAtMs),
    },
    { merge: true }
  );
}
