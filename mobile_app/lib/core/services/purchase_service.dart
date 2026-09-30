import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Product ids that are consumed (spent) — question packs. Everything else
/// (sub_monthly, sub_annual) is treated as non-consumable/auto-renewing.
/// MUST match backend/pricing.js QUESTION_PACKS ids exactly.
const Set<String> kConsumableProductIds = {'pack_small', 'pack_popular', 'pack_value'};

const Set<String> kAllProductIds = {
  'pack_small', 'pack_popular', 'pack_value',
  'sub_monthly', 'sub_annual',
};

enum PurchaseOutcome { success, cancelled, failed, pending }

/// Thin wrapper around the `in_app_purchase` plugin: buys a product, verifies
/// it server-side, and reports back a simple outcome. One instance per
/// purchase flow — call [dispose] when the initiating screen is done with it.
///
/// IMPORTANT: this code path only works once the matching products exist in
/// Play Console / App Store Connect with these exact ids, and the backend's
/// GOOGLE_PLAY_SERVICE_ACCOUNT_JSON / APPLE_SHARED_SECRET env vars are set —
/// see backend/purchaseVerify.js for what to configure.
class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  Completer<PurchaseOutcome>? _pending;
  String? _pendingProductId;

  /// The `product` object the backend returned for the most recent
  /// successful verify — {type, id, label, questions?/periodDays?,
  /// priceInr, expiresAtMs? (subscriptions only)}. Read this right after
  /// [buy] resolves with [PurchaseOutcome.success] to show a specific
  /// confirmation ("+10 questions added" / "Active until 30 Oct") instead
  /// of a generic one.
  Map<String, dynamic>? lastVerifiedProduct;

  void dispose() {
    _sub?.cancel();
  }

  static const _pendingKeyPrefix = 'pending_purchase_';

  /// A UPI/store purchase can stay in [PurchaseStatus.pending] for minutes —
  /// persisted (not just an in-memory flag) so it survives navigating away
  /// from whatever screen started the purchase, and can be surfaced
  /// elsewhere (e.g. the Account screen) until it resolves or expires.
  static Future<void> _savePendingPurchase(String productId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_pendingKeyPrefix$uid', jsonEncode({
      'productId': productId,
      'startedAt': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  static Future<void> clearPendingPurchase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_pendingKeyPrefix$uid');
  }

  /// The still-unresolved pending purchase for the signed-in user, if any
  /// and if it hasn't expired (30 min — well past any realistic UPI
  /// confirmation delay, so a stuck flag doesn't nag forever).
  static Future<Map<String, dynamic>?> getPendingPurchase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_pendingKeyPrefix$uid');
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final startedAt = data['startedAt'] as int? ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - startedAt > 30 * 60 * 1000) {
      await clearPendingPurchase();
      return null;
    }
    return data;
  }

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<ProductDetailsResponse> queryProducts(Set<String> ids) =>
      _iap.queryProductDetails(ids);

  /// Starts the purchase flow for [product] and resolves once the store (and
  /// then our own backend) has confirmed it — or once it's clearly failed/
  /// been cancelled. Only one purchase can be in flight per instance.
  Future<PurchaseOutcome> buy(ProductDetails product) {
    _pending = Completer<PurchaseOutcome>();
    _pendingProductId = product.id;

    _sub ??= _iap.purchaseStream.listen(_onPurchaseUpdate, onError: (e) {
      debugPrint('PurchaseService: purchase stream error — $e');
      _completeOnce(PurchaseOutcome.failed);
    });

    final param = PurchaseParam(productDetails: product);
    final isConsumable = kConsumableProductIds.contains(product.id);
    final started = isConsumable
        ? _iap.buyConsumable(purchaseParam: param)
        : _iap.buyNonConsumable(purchaseParam: param);

    started.catchError((e) {
      debugPrint('PurchaseService: buy() failed to start — $e');
      _completeOnce(PurchaseOutcome.failed);
      return false;
    });

    return _pending!.future;
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // Restored purchases arrive unsolicited (e.g. iOS can deliver past
      // non-consumables on app start, not just after an explicit restore
      // request) — always verify+grant these regardless of what buy() call,
      // if any, is currently pending.
      if (purchase.status == PurchaseStatus.restored) {
        await _verifyWithBackend(purchase);
        if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
        continue;
      }

      if (purchase.productID != _pendingProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Keep waiting — a later event in this same stream will resolve it.
          // Persisted so it's visible even if the user navigates away (a
          // UPI confirmation can take minutes).
          await _savePendingPurchase(purchase.productID);
          break;

        case PurchaseStatus.canceled:
          await clearPendingPurchase();
          if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
          _completeOnce(PurchaseOutcome.cancelled);
          break;

        case PurchaseStatus.error:
          debugPrint('PurchaseService: store reported error — ${purchase.error}');
          await clearPendingPurchase();
          if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
          _completeOnce(PurchaseOutcome.failed);
          break;

        case PurchaseStatus.purchased:
          final verified = await _verifyWithBackend(purchase);
          await clearPendingPurchase();
          // Only acknowledge/complete with the store once our backend has
          // actually granted the entitlement. If verification failed (e.g.
          // a transient backend/network error), leave the purchase
          // unacknowledged so the store redelivers it — via restorePurchases()
          // or automatically on next launch — instead of silently losing it.
          if (verified && purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _completeOnce(verified ? PurchaseOutcome.success : PurchaseOutcome.failed);
          break;

        case PurchaseStatus.restored:
          break; // handled above, unconditionally
      }
    }
  }

  Future<bool> _verifyWithBackend(PurchaseDetails purchase) async {
    try {
      Map<String, dynamic> result;
      if (Platform.isAndroid) {
        final androidPurchase = (purchase as GooglePlayPurchaseDetails).billingClientPurchase;
        result = await ApiService.verifyPurchase(
          platform: 'android',
          productId: purchase.productID,
          purchaseToken: androidPurchase.purchaseToken,
        );
      } else if (Platform.isIOS) {
        final receipt = await SKReceiptManager.retrieveReceiptData();
        result = await ApiService.verifyPurchase(
          platform: 'ios',
          productId: purchase.productID,
          receiptData: receipt,
        );
      } else {
        return false;
      }
      lastVerifiedProduct = result['product'] as Map<String, dynamic>?;
      return true;
    } catch (e) {
      debugPrint('PurchaseService: backend verification failed — $e');
      return false;
    }
  }

  void _completeOnce(PurchaseOutcome outcome) {
    if (_pending != null && !_pending!.isCompleted) {
      _pending!.complete(outcome);
    }
    _pendingProductId = null;
  }

  /// Restores past non-consumable purchases (subscriptions) — required by
  /// both Apple and Google policy so a user who reinstalls or switches
  /// devices can get their subscription back without paying again. Restored
  /// purchases arrive asynchronously via the purchase stream and are
  /// verified+granted in [_onPurchaseUpdate] — this call just kicks that off.
  Future<void> restorePurchases() {
    _sub ??= _iap.purchaseStream.listen(_onPurchaseUpdate, onError: (e) {
      debugPrint('PurchaseService: purchase stream error — $e');
    });
    return _iap.restorePurchases();
  }
}
