import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/models.dart';
import '../services/purchase_service.dart';
import 'purchase_provider.dart';
import 'storage_provider.dart';

final proStatusProvider =
    NotifierProvider<ProStatusNotifier, ProStatus>(ProStatusNotifier.new);

class ProStatusNotifier extends Notifier<ProStatus> {
  CustomerInfoUpdateListener? _customerInfoListener;

  @override
  ProStatus build() {
    final cached = ref.read(storageServiceProvider).loadCachedPro();
    ref.onDispose(_detachListener);
    Future.microtask(refreshFromStore);
    return ProStatus(isPro: cached);
  }

  PurchaseService get _purchases => ref.read(purchaseServiceProvider);

  Future<void> _setPro(bool isPro) async {
    state = ProStatus(isPro: isPro, isLoading: false);
    await ref.read(storageServiceProvider).saveCachedPro(isPro);
  }

  void _attachListener() {
    if (_customerInfoListener != null) return;
    _customerInfoListener = (info) {
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

  /// RevenueCat is source of truth when configured; otherwise keep cache.
  Future<void> refreshFromStore() async {
    state = state.copyWith(isLoading: true);
    try {
      if (!_purchases.isConfigured) {
        final cached = ref.read(storageServiceProvider).loadCachedPro();
        state = ProStatus(isPro: cached);
        return;
      }

      _attachListener();
      final isPro = await _purchases.fetchIsPro();
      if (isPro == null) {
        final cached = ref.read(storageServiceProvider).loadCachedPro();
        state = ProStatus(isPro: cached);
        return;
      }
      await _setPro(isPro);
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<PurchaseOutcomeResult> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _purchases.restorePurchases();
      if (result.outcome == PurchaseOutcome.success || result.isPro) {
        await _setPro(result.isPro);
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

  /// Debug-only unlock for testing Pro gates. Not used in release builds.
  Future<void> debugUnlockPro() async {
    assert(kDebugMode);
    if (!kDebugMode) return;
    await _setPro(true);
  }

  /// Debug-only reset for testing Free experience.
  Future<void> debugResetPro() async {
    assert(kDebugMode);
    if (!kDebugMode) return;
    await _setPro(false);
  }
}
