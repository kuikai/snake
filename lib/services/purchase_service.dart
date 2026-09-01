import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/game_config.dart';
import '../core/revenue_cat_config.dart';

enum PurchaseOutcome {
  success,
  cancelled,
  notConfigured,
  productMissing,
  error,
}

class PurchaseOutcomeResult {
  const PurchaseOutcomeResult({
    required this.outcome,
    this.isPro = false,
    this.message,
  });

  final PurchaseOutcome outcome;
  final bool isPro;
  final String? message;
}

/// RevenueCat wrapper. Falls back to a no-store stub when API keys are missing.
class PurchaseService {
  bool _configured = false;

  bool get isConfigured => _configured;

  Future<void> init() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    final apiKey = Platform.isAndroid
        ? RevenueCatConfig.androidApiKey
        : RevenueCatConfig.iosApiKey;
    if (apiKey.isEmpty) {
      // TODO: Add RevenueCat public SDK keys via --dart-define or RevenueCatConfig.
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (error, stack) {
      debugPrint('RevenueCat configure failed: $error\n$stack');
      _configured = false;
    }
  }

  bool hasProEntitlement(CustomerInfo info) {
    return info.entitlements.all[GameConfig.entitlementId]?.isActive ?? false;
  }

  Future<bool?> fetchIsPro() async {
    if (!_configured) return null;
    try {
      final info = await Purchases.getCustomerInfo();
      return hasProEntitlement(info);
    } catch (error) {
      debugPrint('RevenueCat getCustomerInfo failed: $error');
      return null;
    }
  }

  Future<PurchaseOutcomeResult> purchasePro() async {
    if (!_configured) {
      if (kDebugMode) {
        return const PurchaseOutcomeResult(
          outcome: PurchaseOutcome.notConfigured,
          isPro: true,
          message:
              'RevenueCat keys missing — unlocked Pro in debug stub mode.',
        );
      }
      return const PurchaseOutcomeResult(
        outcome: PurchaseOutcome.notConfigured,
        message:
            'Purchases are not configured yet. Add RevenueCat API keys to enable buying.',
      );
    }

    try {
      final products = await Purchases.getProducts(
        [GameConfig.productId],
        productCategory: ProductCategory.nonSubscription,
      );

      StoreProduct? product;
      if (products.isNotEmpty) {
        product = products.first;
      } else {
        // Fallback: current offering lifetime / any package matching product id.
        final offerings = await Purchases.getOfferings();
        final packages = offerings.current?.availablePackages ?? const [];
        for (final package in packages) {
          if (package.storeProduct.identifier == GameConfig.productId) {
            product = package.storeProduct;
            break;
          }
        }
      }

      if (product == null) {
        return const PurchaseOutcomeResult(
          outcome: PurchaseOutcome.productMissing,
          message:
              'Product snake_pro was not found. Check Play Console / App Store Connect and RevenueCat.',
        );
      }

      final result = await Purchases.purchase(
        PurchaseParams.storeProduct(product),
      );
      final isPro = hasProEntitlement(result.customerInfo);
      return PurchaseOutcomeResult(
        outcome: isPro ? PurchaseOutcome.success : PurchaseOutcome.error,
        isPro: isPro,
        message: isPro
            ? null
            : 'Purchase finished but the Pro entitlement is not active yet.',
      );
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseOutcomeResult(outcome: PurchaseOutcome.cancelled);
      }
      return PurchaseOutcomeResult(
        outcome: PurchaseOutcome.error,
        message: error.message ?? 'Purchase failed.',
      );
    } catch (error) {
      return PurchaseOutcomeResult(
        outcome: PurchaseOutcome.error,
        message: error.toString(),
      );
    }
  }

  Future<PurchaseOutcomeResult> restorePurchases() async {
    if (!_configured) {
      return const PurchaseOutcomeResult(
        outcome: PurchaseOutcome.notConfigured,
        message:
            'Purchases are not configured yet. Add RevenueCat API keys to enable restore.',
      );
    }

    try {
      final info = await Purchases.restorePurchases();
      final isPro = hasProEntitlement(info);
      return PurchaseOutcomeResult(
        outcome: PurchaseOutcome.success,
        isPro: isPro,
        message: isPro ? null : 'No previous Pro purchase found.',
      );
    } on PlatformException catch (error) {
      return PurchaseOutcomeResult(
        outcome: PurchaseOutcome.error,
        message: error.message ?? 'Restore failed.',
      );
    } catch (error) {
      return PurchaseOutcomeResult(
        outcome: PurchaseOutcome.error,
        message: error.toString(),
      );
    }
  }

  void addCustomerInfoListener(CustomerInfoUpdateListener listener) {
    if (!_configured) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoListener(CustomerInfoUpdateListener listener) {
    if (!_configured) return;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }
}
