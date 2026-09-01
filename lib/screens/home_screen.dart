import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_router.dart';
import '../core/cosmetics.dart' hide SnakePalette;
import '../core/palette.dart';
import '../models/models.dart';
import '../providers/high_scores_provider.dart';
import '../providers/pro_status_provider.dart';
import '../providers/settings_provider.dart';
import '../services/feedback_service.dart';
import '../widgets/home_feature_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _lightBg = 'assets/home_bg_light.jpg';
  static const _darkBg = 'assets/home_bg_dark.jpg';

  Future<void> _openPaywall(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.paywall);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classicBest = ref.watch(classicHighScoreProvider);
    final isPro = ref.watch(proStatusProvider).isPro;
    ref.watch(settingsProvider);
    final play = ref
        .read(settingsProvider.notifier)
        .effectiveForPlay(isPro: isPro);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? SnakePalette.dark : SnakePalette.light;

    return Scaffold(
      backgroundColor: palette.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Image.asset(
              isDark ? _darkBg : _lightBg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      if (!isPro)
                        TextButton(
                          onPressed: () => _openPaywall(context),
                          style: TextButton.styleFrom(
                            foregroundColor: palette.inkSoft,
                          ),
                          child: Text(
                            'Unlock Pro',
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isPro)
                        Chip(
                          avatar: Icon(
                            Icons.workspace_premium,
                            size: 18,
                            color: palette.ink,
                          ),
                          label: Text(
                            'Pro',
                            style: GoogleFonts.figtree(color: palette.ink),
                          ),
                          backgroundColor:
                              palette.paper.withValues(alpha: 0.85),
                        ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'High Scores',
                        icon: Icon(
                          Icons.emoji_events_outlined,
                          color: palette.inkSoft,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.highScores);
                        },
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        icon: Icon(
                          Icons.settings_outlined,
                          color: palette.inkSoft,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Snake',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                          fontWeight: FontWeight.w700,
                          fontSize: 52,
                          color: palette.ink,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'best $classicBest',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.figtree(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: palette.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: _ModePicker(
                    palette: palette,
                    play: play,
                    isPro: isPro,
                    onPaywall: () => _openPaywall(context),
                    onMode: (mode) {
                      ref.read(settingsProvider.notifier).setLastMode(mode);
                    },
                    onSize: (size) {
                      ref
                          .read(settingsProvider.notifier)
                          .setLastBoardSize(size);
                    },
                    onSpeed: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .setLastIncreasingSpeed(value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 280,
                      height: 54,
                      child: FilledButton(
                        onPressed: () async {
                          await ref.read(feedbackServiceProvider).button();
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed(AppRoutes.game);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1915),
                          foregroundColor: const Color(0xFFF3EDE2),
                          disabledBackgroundColor: const Color(0xFF1C1915),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(280, 54),
                          maximumSize: const Size(280, 54),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Play',
                          style: GoogleFonts.fraunces(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            height: 1.0,
                            color: const Color(0xFFF3EDE2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(flex: 4, child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({
    required this.palette,
    required this.play,
    required this.isPro,
    required this.onPaywall,
    required this.onMode,
    required this.onSize,
    required this.onSpeed,
  });

  final SnakePalette palette;
  final GameSettings play;
  final bool isPro;
  final VoidCallback onPaywall;
  final ValueChanged<GameMode> onMode;
  final ValueChanged<BoardSize> onSize;
  final ValueChanged<bool> onSpeed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChipRow(
          children: [
            for (final mode in GameMode.values)
              HomeFeatureChip(
                label: Cosmetics.modeLabel(mode),
                selected: play.lastMode == mode,
                locked: !isPro && mode != GameMode.classic,
                palette: palette,
                onTap: () => onMode(mode),
                onLockedTap: onPaywall,
              ),
          ],
        ),
        const SizedBox(height: 8),
        _ChipRow(
          children: [
            for (final size in BoardSize.values)
              HomeFeatureChip(
                label: Cosmetics.sizeLabel(size),
                selected: play.lastBoardSize == size,
                locked: !isPro && size != BoardSize.medium,
                palette: palette,
                onTap: () => onSize(size),
                onLockedTap: onPaywall,
              ),
            HomeFeatureChip(
              label: 'Speed',
              selected: play.lastIncreasingSpeed,
              locked: !isPro,
              palette: palette,
              onTap: () => onSpeed(!play.lastIncreasingSpeed),
              onLockedTap: onPaywall,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            children[i],
          ],
        ],
      ),
    );
  }
}
