// ═══════════════════════════════════════════════════════════════════════════════
// FIREBASE ADMIN — server-side Firebase access (auth verification + Firestore).
//
// Vercel has no persistent filesystem for secrets, so the service account JSON
// is read from an environment variable, not a committed file:
//   FIREBASE_SERVICE_ACCOUNT_JSON = the full service account JSON, as one string
//
// To get this: Firebase Console → Project Settings → Service Accounts →
// "Generate new private key" → paste the entire file's contents as the value
// of this env var in Vercel (Project Settings → Environment Variables).
// NEVER commit the JSON file itself to the repo.
// ═══════════════════════════════════════════════════════════════════════════════

import admin from 'firebase-admin';

let initialized = false;

function init() {
  if (initialized) return;
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw) {
    throw new Error(
      'FIREBASE_SERVICE_ACCOUNT_JSON env var is not set. ' +
      'Auth-protected endpoints will fail until this is configured in Vercel.'
    );
  }
  const serviceAccount = JSON.parse(raw);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  initialized = true;
}

export function getAuth() {
  init();
  return admin.auth();
}

export function getDb() {
  init();
  return admin.firestore();
}

export const FieldValue = admin.firestore.FieldValue;
