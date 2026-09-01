import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pro_status_provider.dart';
import '../providers/purchase_provider.dart';
import '../services/purchase_service.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  static const _benefits = [
    '3 continues per run',
    'Small, Medium, and Large boards',
    'Wrap, No Walls, Obstacles, Increasing Speed',
    'Snake skins and board themes',
    'Personal bests and run history',
  ];

  String _messageFor(PurchaseOutcomeResult result) {
    switch (result.outcome) {
      case PurchaseOutcome.success:
        return result.isPro
            ? 'Pro unlocked.'
            : (result.message ?? 'Purchase completed.');
      case PurchaseOutcome.cancelled:
        return 'Purchase cancelled.';
      case PurchaseOutcome.notConfigured:
        return result.message ??
            'RevenueCat is not configured yet.';
      case PurchaseOutcome.productMissing:
        return result.message ?? 'Product not found.';
      case PurchaseOutcome.error:
        return result.message ?? 'Something went wrong.';
    }
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(proStatusProvider.notifier).purchasePro();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_messageFor(result))),
    );

    if (result.isPro) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(proStatusProvider.notifier).restorePurchases();
    if (!context.mounted) return;

    final text = result.outcome == PurchaseOutcome.success
        ? (result.isPro
            ? 'Purchases restored. Pro is unlocked.'
            : 'No previous Pro purchase found.')
        : _messageFor(result);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

    if (result.isPro) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pro = ref.watch(proStatusProvider);
    final configured = ref.watch(purchaseServiceProvider).isConfigured;

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Pro')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Snake Pro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                r'One-time unlock — $1.99',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              if (!configured) ...[
                const SizedBox(height: 12),
                Text(
                  'Store billing is stubbed until RevenueCat API keys are set.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              ..._benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(benefit)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: pro.isLoading ? null : () => _purchase(context, ref),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: pro.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(r'Purchase — $1.99'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: pro.isLoading ? null : () => _restore(context, ref),
                child: const Text('Restore Purchase'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
