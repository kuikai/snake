import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// Overridden in [main] after SharedPreferences is ready.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden in main');
});
