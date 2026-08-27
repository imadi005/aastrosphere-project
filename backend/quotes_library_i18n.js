// ═══════════════════════════════════════════════════════════════════════════════
// Hindi translation of quotes_library.js's DAILY_QUOTES — same structure (9 keys,
// same quote count per key, same order) so the existing selection index in
// prediction_engine.js (`quotes[safeIdx]`) picks the matching quote in either
// language. Any key missing here falls back to English automatically (see the
// `localized()` pattern already used in user_daily_content.js).
//
// STATUS: placeholder — currently mirrors the English quotes 1:1. A background
// task is translating these into natural Hindi; until that lands, Hindi-locale
// users see the same (English) quote text they always have — no regression.
// ═══════════════════════════════════════════════════════════════════════════════

import { DAILY_QUOTES } from './quotes_library.js';

export const DAILY_QUOTES_I18N = {
  hi: DAILY_QUOTES,
};
