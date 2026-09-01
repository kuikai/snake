import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'providers/purchase_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/storage_provider.dart';
import 'services/purchase_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  final purchases = PurchaseService();
  await purchases.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        purchaseServiceProvider.overrideWithValue(purchases),
      ],
      child: const SnakeApp(),
    ),
  );
}

class SnakeApp extends ConsumerWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Snake',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
