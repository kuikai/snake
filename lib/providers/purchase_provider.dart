import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/purchase_service.dart';

/// Overridden in [main] after [PurchaseService.init].
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  throw UnimplementedError('purchaseServiceProvider must be overridden in main');
});
