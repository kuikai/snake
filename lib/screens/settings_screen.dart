import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/app_router.dart';
import '../core/cosmetics.dart';
import '../models/models.dart';
import '../providers/pro_status_provider.dart';
import '../providers/settings_provider.dart';
import '../services/feedback_service.dart';
import '../services/purchase_service.dart';
import '../widgets/pro_choice_chip.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ref.read(proStatusProvider.notifier).restorePurchases();
    if (!context.mounted) return;

    final text = switch (result.outcome) {
      PurchaseOutcome.success when result.isPro =>
        'Purchases restored. Pro is unlocked.',
      PurchaseOutcome.success => 'No previous Pro purchase found.',
      _ => result.message ?? 'Restore finished.',
    };

    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showAbout(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: 'Snake',
      applicationVersion: '${info.version} (${info.buildNumber})',
      applicationLegalese:
          r'Offline Classic Snake. Pro is a $1.99 one-time unlock.',
      children: const [
        SizedBox(height: 12),
        Text(
          'Free: unlimited Classic on 20×20.\n'
          'Pro: modes, sizes, continues, skins, themes, and history.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final pro = ref.watch(proStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          const ListTile(
            title: Text('Theme'),
            subtitle: Text('Light / Dark / System'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selected) {
                ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(selected.first);
              },
            ),
          ),
          const Divider(),
          const _SectionHeader('Feedback'),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Short system effects during play'),
            value: settings.soundEnabled,
            onChanged: (value) async {
              await ref.read(settingsProvider.notifier).setSoundEnabled(value);
              if (value) {
                await ref.read(feedbackServiceProvider).button();
              }
            },
          ),
          SwitchListTile(
            title: const Text('Haptics'),
            subtitle: const Text('Vibration on turn, eat, and death'),
            value: settings.hapticsEnabled,
            onChanged: (value) async {
              await ref
                  .read(settingsProvider.notifier)
                  .setHapticsEnabled(value);
              if (value) {
                await HapticFeedback.lightImpact();
              }
            },
          ),
          const Divider(),
          const _SectionHeader('Cosmetics'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'Snake skin',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skin in SnakeSkin.values)
                  ProChoiceChip(
                    label: Cosmetics.skinLabel(skin),
                    selected: settings.skin == skin,
                    locked: !pro.isPro && skin != SnakeSkin.classicGreen,
                    onSelected: () {
                      ref.read(settingsProvider.notifier).setSkin(skin);
                    },
                    onLockedTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.paywall);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'Board theme',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final theme in BoardTheme.values)
                  ProChoiceChip(
                    label: Cosmetics.boardThemeLabel(theme),
                    selected: settings.boardTheme == theme,
                    locked: !pro.isPro && theme != BoardTheme.classic,
                    onSelected: () {
                      ref.read(settingsProvider.notifier).setBoardTheme(theme);
                    },
                    onLockedTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.paywall);
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Purchases'),
          if (!pro.isPro)
            ListTile(
              title: const Text('Unlock Pro'),
              subtitle: const Text(r'$1.99 one-time'),
              leading: const Icon(Icons.workspace_premium_outlined),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.paywall);
              },
            ),
          ListTile(
            title: const Text('Pro status'),
            subtitle: Text(pro.isPro ? 'Pro unlocked' : 'Free'),
            trailing: pro.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          ListTile(
            title: const Text('Restore Purchase'),
            subtitle: const Text('Restore a previous Pro unlock'),
            leading: const Icon(Icons.restore),
            enabled: !pro.isLoading,
            onTap: () => _restorePurchases(context, ref),
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            title: const Text('About Snake'),
            subtitle: const Text('Version and info'),
            leading: const Icon(Icons.info_outline),
            onTap: () => _showAbout(context),
          ),
          if (kDebugMode) ...[
            const Divider(),
            const _SectionHeader('Debug'),
            ListTile(
              title: const Text('Unlock Pro'),
              subtitle: const Text('Debug only — not in release'),
              leading: const Icon(Icons.lock_open),
              onTap: () async {
                await ref.read(proStatusProvider.notifier).debugUnlockPro();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pro unlocked (debug)')),
                );
              },
            ),
            ListTile(
              title: const Text('Reset Pro'),
              subtitle: const Text('Back to Free for testing'),
              leading: const Icon(Icons.lock_outline),
              onTap: () async {
                await ref.read(proStatusProvider.notifier).debugResetPro();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pro reset (debug)')),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
