// ═══════════════════════════════════════════════════════════════════════════════
// IN-APP PURCHASE VERIFICATION — Google Play + App Store receipt validation.
//
// Product ids here MUST exactly match the ids you create in the Play Console /
// App Store Connect, which MUST exactly match pricing.js (QUESTION_PACKS /
// SUBSCRIPTION_PLANS ids) — that's the single source of truth this file reads
// from to decide what to grant.
//
// Required env vars (see the block comments below each verifier for where to
// get them — nothing here works until these are set):
//   GOOGLE_PLAY_SERVICE_ACCOUNT_JSON — full service account JSON, one string
//   ANDROID_PACKAGE_NAME             — e.g. "com.aastrosphere.app"
//   APPLE_SHARED_SECRET              — App Store Connect → app → In-App Purchases → App-Specific Shared Secret
// ═══════════════════════════════════════════════════════════════════════════════

import { JWT } from 'google-auth-library';
import { getDb, FieldValue } from './firebaseAdmin.js';
import { QUESTION_PACKS, SUBSCRIPTION_PLANS } from './pricing.js';

const PLAY_SCOPE = 'https://www.googleapis.com/auth/androidpublisher';

let playClient = null;
function getPlayClient() {
  if (playClient) return playClient;
  const raw = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON;
  if (!raw) {
    throw new Error(
      'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON env var is not set. Create a service ' +
      'account in the Google Cloud project linked to your Play Console, grant it ' +
      'access under Play Console → Users and permissions, then paste its JSON key here.'
    );
  }
  const creds = JSON.parse(raw);
  playClient = new JWT({
    email: creds.client_email,
    key: creds.private_key,
    scopes: [PLAY_SCOPE],
  });
  return playClient;
}

function findProduct(productId) {
  const pack = QUESTION_PACKS.find(p => p.id === productId);
  if (pack) return { type: 'pack', ...pack };
  const plan = SUBSCRIPTION_PLANS.find(p => p.id === productId);
  if (plan) return { type: 'subscription', ...plan };
  return null;
}

/**
 * Verifies a Google Play purchase token against the Android Publisher API.
 * Throws on any failure (network, invalid token, wrong package, etc.) —
 * callers should treat a thrown error as "do not grant anything".
 */
async function verifyAndroidPurchase({ productId, purchaseToken, isSubscription }) {
  const packageName = process.env.ANDROID_PACKAGE_NAME;
  if (!packageName) throw new Error('ANDROID_PACKAGE_NAME env var is not set.');

  const client = getPlayClient();
  const { token } = await client.getAccessToken();

  const path = isSubscription
    ? `purchases/subscriptions/${productId}`
    : `purchases/products/${productId}`;
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/${path}/tokens/${purchaseToken}`;

  const resp = await fetch(url, { headers: { Authorization: `Bearer ${token}` } });
  if (!resp.ok) {
    throw new Error(`Play verification failed: HTTP ${resp.status} — ${await resp.text()}`);
  }
  const body = await resp.json();

  if (isSubscription) {
    // purchaseState isn't on subscriptions v3 — expiryTimeMillis in the future
    // is what actually means "active". cancelReason/paymentState refine this
    // further but expiry is the load-bearing check.
    const expiryMs = parseInt(body.expiryTimeMillis, 10);
    if (!expiryMs || expiryMs < Date.now()) throw new Error('Subscription is not currently active.');
    return { valid: true, expiryMs };
  } else {
    // purchaseState: 0 = purchased, 1 = canceled, 2 = pending
    if (body.purchaseState !== 0) throw new Error(`Purchase not in a completed state (state=${body.purchaseState}).`);
    // consumptionState: 0 = not yet consumed — must ack/consume so Play
    // doesn't auto-refund it after a few days unacknowledged.
    if (body.consumptionState === 0) {
      await fetch(
        `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}:consume`,
        { method: 'POST', headers: { Authorization: `Bearer ${token}` } }
      );
    }
    return { valid: true };
  }
}

/**
 * Verifies an App Store receipt via Apple's verifyReceipt endpoint. Legacy
 * but still functional and far simpler than the JWT-based App Store Server
 * API — tries production first, falls back to sandbox on status 21007 (the
 * documented way to support both TestFlight and live builds transparently).
 */
async function verifyIosPurchase({ productId, receiptData }) {
  const sharedSecret = process.env.APPLE_SHARED_SECRET;
  if (!sharedSecret) throw new Error('APPLE_SHARED_SECRET env var is not set.');

  async function callApple(url) {
    const resp = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 'receipt-data': receiptData, password: sharedSecret, 'exclude-old-transactions': true }),
    });
    return resp.json();
  }

  let body = await callApple('https://buy.itunes.apple.com/verifyReceipt');
  if (body.status === 21007) {
    body = await callApple('https://sandbox.itunes.apple.com/verifyReceipt');
  }
  if (body.status !== 0) throw new Error(`Apple verification failed: status ${body.status}`);

  // Latest receipt info covers both consumables and subscriptions on iOS 7+.
  const entries = body.latest_receipt_info || body.receipt?.in_app || [];
  const match = entries
    .filter(e => e.product_id === productId)
    .sort((a, b) => parseInt(b.purchase_date_ms, 10) - parseInt(a.purchase_date_ms, 10))[0];
  if (!match) throw new Error('No matching transaction for this product id in the receipt.');

  if (match.expires_date_ms) {
    const expiryMs = parseInt(match.expires_date_ms, 10);
    if (expiryMs < Date.now()) throw new Error('Subscription is not currently active.');
    return { valid: true, expiryMs, transactionId: match.transaction_id };
  }
  return { valid: true, transactionId: match.transaction_id };
}

/**
 * Top-level entry point used by the /api/purchase/verify route. Verifies the
 * purchase with the right platform, grants credits or activates the
 * subscription, and records the token so a retried/replayed request can never
 * grant twice (Firestore doc id = the purchase token / transaction id, so the
 * .create() below throws on a duplicate — that's the idempotency guard).
 */
export async function verifyAndGrant({ uid, platform, productId, purchaseToken, receiptData }) {
  const product = findProduct(productId);
  if (!product) throw new Error(`Unknown product id: ${productId}`);

  const idempotencyKey = platform === 'android' ? purchaseToken : receiptData?.slice(-64);
  if (!idempotencyKey) throw new Error('Missing purchase token / receipt.');

  const db = getDb();
  const processedRef = db.collection('processed_purchases').doc(
    // Firestore doc ids can't contain '/', and iOS receipts are long base64 —
    // hash-free is fine here since collisions across purchases are what we want to catch.
    Buffer.from(idempotencyKey).toString('base64url').slice(0, 400)
  );

  // Claim the token first, inside a transaction, so two concurrent requests
  // for the same purchase can't both pass the "already processed?" check.
  const claimed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(processedRef);
    if (snap.exists) return false;
    tx.set(processedRef, { uid, productId, platform, createdAt: FieldValue.serverTimestamp() });
    return true;
  });
  if (!claimed) {
    return { alreadyProcessed: true, product };
  }

  try {
    let result;
    if (platform === 'android') {
      result = await verifyAndroidPurchase({ productId, purchaseToken, isSubscription: product.type === 'subscription' });
    } else if (platform === 'ios') {
      result = await verifyIosPurchase({ productId, receiptData });
    } else {
      throw new Error(`Unknown platform: ${platform}`);
    }

    if (product.type === 'pack') {
      const { grantCredits } = await import('./authMiddleware.js');
      await grantCredits(uid, product.questions);
    } else {
      const { activateSubscription } = await import('./authMiddleware.js');
      const expiresAtMs = result.expiryMs ?? (Date.now() + product.periodDays * 86400000);
      await activateSubscription(uid, expiresAtMs);
    }

    return { alreadyProcessed: false, product };
  } catch (e) {
    // Verification failed — release the claim so a legitimate retry isn't
    // permanently blocked by our own idempotency guard.
    await processedRef.delete().catch(() => {});
    throw e;
  }
}
