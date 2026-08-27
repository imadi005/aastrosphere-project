import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
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

  void dispose() {
    _sub?.cancel();
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
          break;

        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
          _completeOnce(PurchaseOutcome.cancelled);
          break;

        case PurchaseStatus.error:
          debugPrint('PurchaseService: store reported error — ${purchase.error}');
          if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
          _completeOnce(PurchaseOutcome.failed);
          break;

        case PurchaseStatus.purchased:
          final verified = await _verifyWithBackend(purchase);
          if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
          _completeOnce(verified ? PurchaseOutcome.success : PurchaseOutcome.failed);
          break;

        case PurchaseStatus.restored:
          break; // handled above, unconditionally
      }
    }
  }

  Future<bool> _verifyWithBackend(PurchaseDetails purchase) async {
    try {
      if (Platform.isAndroid) {
        final androidPurchase = (purchase as GooglePlayPurchaseDetails).billingClientPurchase;
        await ApiService.verifyPurchase(
          platform: 'android',
          productId: purchase.productID,
          purchaseToken: androidPurchase.purchaseToken,
        );
        return true;
      } else if (Platform.isIOS) {
        final receipt = await SKReceiptManager.retrieveReceiptData();
        await ApiService.verifyPurchase(
          platform: 'ios',
          productId: purchase.productID,
          receiptData: receipt,
        );
        return true;
      }
      return false;
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
