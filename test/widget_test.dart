import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snake/main.dart';
import 'package:snake/providers/purchase_provider.dart';
import 'package:snake/providers/storage_provider.dart';
import 'package:snake/services/purchase_service.dart';
import 'package:snake/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home screen opens with Snake title', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final purchases = PurchaseService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          purchaseServiceProvider.overrideWithValue(purchases),
        ],
        child: const SnakeApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Snake'), findsWidgets);
    expect(find.textContaining('best '), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });
}
