import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/revenue_cat_config.dart';
import '../models/models.dart';
import '../services/purchase_service.dart';
import 'purchase_provider.dart';
import 'storage_provider.dart';

final proStatusProvider =
    NotifierProvider<ProStatusNotifier, ProStatus>(ProStatusNotifier.new);

class ProStatusNotifier extends Notifier<ProStatus> {
  CustomerInfoUpdateListener? _customerInfoListener;
  int _refreshToken = 0;

  @override
  ProStatus build() {
    ref.onDispose(_detachListener);
    Future.microtask(refreshFromStore);

    final override = _testOverride();
    if (override != null) return ProStatus(isPro: override);

    // Release without RevenueCat must not trust a sticky debug cache.
    if (!_purchases.isConfigured && !_localUnlockAllowed) {
      return const ProStatus(isPro: false);
    }

    final cached = ref.read(storageServiceProvider).loadCachedPro();
    return ProStatus(isPro: cached);
  }

  bool get _localUnlockAllowed => RevenueCatConfig.allowsLocalProUnlock;

  /// Null means follow the store. Ignored on App Store builds.
  bool? _testOverride() {
    if (!_localUnlockAllowed) return null;
    return ref.read(storageServiceProvider).loadProTestOverride();
  }

  PurchaseService get _purchases => ref.read(purchaseServiceProvider);

  Future<void> _setPro(bool isPro) async {
    state = ProStatus(isPro: isPro, isLoading: false);
    final storage = ref.read(storageServiceProvider);
    await storage.saveCachedPro(isPro);
  }

  void _attachListener() {
    if (_customerInfoListener != null) return;
    _customerInfoListener = (info) {
      if (_testOverride() != null) return;
      final isPro = _purchases.hasProEntitlement(info);
      unawaited(_setPro(isPro));
    };
    _purchases.addCustomerInfoListener(_customerInfoListener!);
  }

  void _detachListener() {
    final listener = _customerInfoListener;
    if (listener == null) return;
    _purchases.removeCustomerInfoListener(listener);
    _customerInfoListener = null;
  }

  /// RevenueCat is source of truth when configured.
  /// A tester override (debug or TestFlight) wins until Reset Pro.
  /// Unconfigured App Store build → Free.
  Future<void> refreshFromStore() async {
    final token = ++_refreshToken;
    final override = _testOverride();
    if (override != null) {
      state = ProStatus(isPro: override);
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      if (!_purchases.isConfigured) {
        if (token != _refreshToken) return;
        if (_localUnlockAllowed) {
          final cached = ref.read(storageServiceProvider).loadCachedPro();
          state = ProStatus(isPro: cached);
        } else {
          await _setPro(false);
        }
        return;
      }

      _attachListener();
      final isPro = await _purchases.fetchIsPro();
      if (token != _refreshToken) return;
      if (isPro == null) {
        final cached = ref.read(storageServiceProvider).loadCachedPro();
        state = ProStatus(isPro: cached);
        return;
      }
      await _setPro(isPro);
    } finally {
      if (token == _refreshToken && state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<PurchaseOutcomeResult> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _purchases.restorePurchases();
      final override = _testOverride();
      if (result.isPro) {
        _refreshToken++;
        await ref.read(storageServiceProvider).saveProTestOverride(null);
        await _setPro(true);
      } else if (override != null) {
        state = ProStatus(isPro: override);
      } else if (result.outcome == PurchaseOutcome.success) {
        await _setPro(false);
      } else {
        state = state.copyWith(isLoading: false);
      }
      return result;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<PurchaseOutcomeResult> purchasePro() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _purchases.purchasePro();
      if (result.isPro) {
        _refreshToken++;
        final storage = ref.read(storageServiceProvider);
        if (!_purchases.isConfigured && _localUnlockAllowed) {
          await storage.saveProTestOverride(true);
        } else if (_purchases.isConfigured) {
          await storage.saveProTestOverride(null);
        }
        await _setPro(true);
      } else {
        state = state.copyWith(isLoading: false);
      }
      return result;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Local unlock for debug runs and TestFlight (`PRO_TEST_UNLOCK`).
  Future<void> debugUnlockPro() async {
    if (!_localUnlockAllowed) return;
    _refreshToken++;
    await ref.read(storageServiceProvider).saveProTestOverride(true);
    await _setPro(true);
  }

  /// Back to Free for testing. App Store builds ignore this.
  Future<void> debugResetPro() async {
    if (!_localUnlockAllowed) return;
    _refreshToken++;
    await ref.read(storageServiceProvider).saveProTestOverride(false);
    await _setPro(false);
  }
}
