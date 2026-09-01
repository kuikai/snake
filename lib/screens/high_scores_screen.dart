import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_router.dart';
import '../core/cosmetics.dart' hide SnakePalette;
import '../core/palette.dart';
import '../models/models.dart';
import '../providers/high_scores_provider.dart';
import '../providers/online_scores_provider.dart';
import '../providers/pro_status_provider.dart';
import '../widgets/share_scores_sheet.dart';

class HighScoresScreen extends ConsumerWidget {
  const HighScoresScreen({super.key});

  Future<void> _onShareToggle(
    BuildContext context,
    WidgetRef ref, {
    required bool wantOn,
    required bool isPro,
  }) async {
    if (!isPro) {
      await Navigator.of(context).pushNamed(AppRoutes.paywall);
      return;
    }

    if (!wantOn) {
      await ref.read(onlineScoresPrefsProvider.notifier).turnOff();
      return;
    }

    final nickname = await showShareScoresSheet(context);
    if (!context.mounted) return;
    if (nickname == null) return;
    await ref
        .read(onlineScoresPrefsProvider.notifier)
        .turnOnWithNickname(nickname);
  }

  Future<void> _openBoard(BuildContext context, bool isPro) async {
    if (!isPro) {
      await Navigator.of(context).pushNamed(AppRoutes.paywall);
      return;
    }
    await Navigator.of(context).pushNamed(AppRoutes.onlineBoard);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(highScoresProvider);
    final isPro = ref.watch(proStatusProvider).isPro;
    final onlinePrefs = ref.watch(onlineScoresPrefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? SnakePalette.dark : SnakePalette.light;

    return Scaffold(
      backgroundColor: palette.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, color: palette.inkSoft),
                ),
                Expanded(
                  child: Text(
                    'scores',
                    style: GoogleFonts.fraunces(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: palette.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Classic best',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w500,
                color: palette.inkSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${scores.classicBest}',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w700,
                fontSize: 40,
                color: palette.ink,
              ),
            ),
            Text(
              '20×20 Classic',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w500,
                color: palette.inkSoft,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'live board',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'public. top 1000.',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: palette.inkSoft,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'share scores online',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                  color: palette.ink,
                ),
              ),
              value: isPro && onlinePrefs.shareOnline,
              activeThumbColor: palette.cream,
              activeTrackColor: palette.ink,
              onChanged: (value) => _onShareToggle(
                context,
                ref,
                wantOn: value,
                isPro: isPro,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _openBoard(context, isPro),
                style: TextButton.styleFrom(
                  foregroundColor: palette.ink,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'open live board',
                  style: GoogleFonts.figtree(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (!isPro) ...[
              const SizedBox(height: 20),
              Text(
                'Pro keeps personal bests per mode and size, plus your last 30 runs.',
                style: GoogleFonts.figtree(color: palette.inkSoft),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.paywall);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.ink,
                    side: BorderSide(
                      color: palette.inkSoft.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Unlock Pro',
                    style: GoogleFonts.figtree(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            if (isPro) ...[
              const SizedBox(height: 28),
              Text(
                'Personal bests',
                style: GoogleFonts.fraunces(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 8),
              if (scores.bestByKey.isEmpty)
                Text(
                  'no runs yet.',
                  style: GoogleFonts.figtree(color: palette.inkSoft),
                )
              else
                ..._sortedBests(scores.bestByKey).map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _labelForKey(entry.key),
                            style: GoogleFonts.figtree(color: palette.ink),
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: GoogleFonts.fraunces(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: palette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Recent runs',
                style: GoogleFonts.fraunces(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 8),
              if (scores.recent.isEmpty)
                Text(
                  'no runs yet.',
                  style: GoogleFonts.figtree(color: palette.inkSoft),
                )
              else
                ...scores.recent.map(
                  (run) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${run.score}  ·  ${_runLabel(run)}',
                                style: GoogleFonts.figtree(
                                  fontWeight: FontWeight.w600,
                                  color: palette.ink,
                                ),
                              ),
                              Text(
                                _formatDate(run.finishedAt.toLocal()),
                                style: GoogleFonts.figtree(
                                  fontSize: 13,
                                  color: palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (run.isPersonalBest)
                          Text(
                            'PB',
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.w700,
                              color: palette.inkSoft,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static List<MapEntry<String, int>> _sortedBests(Map<String, int> bests) {
    final entries = bests.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  static String _labelForKey(String key) {
    final parts = key.split('_');
    if (parts.length < 3) return key;
    final speed = parts.last;
    final size = parts[parts.length - 2];
    final mode = parts.sublist(0, parts.length - 2).join('_');

    GameMode? modeEnum;
    for (final value in GameMode.values) {
      if (value.storageKey == mode) {
        modeEnum = value;
        break;
      }
    }
    BoardSize? sizeEnum;
    for (final value in BoardSize.values) {
      if (value.storageKey == size) {
        sizeEnum = value;
        break;
      }
    }

    final modeLabel =
        modeEnum != null ? Cosmetics.modeLabel(modeEnum) : mode;
    final sizeLabel =
        sizeEnum != null ? Cosmetics.sizeLabel(sizeEnum) : size;
    final speedLabel = speed == 'speed1' ? ' · Speed' : '';
    return '$modeLabel · $sizeLabel$speedLabel';
  }

  static String _runLabel(GameRun run) {
    final speed = run.increasingSpeed ? ' · Speed' : '';
    return '${Cosmetics.modeLabel(run.mode)} · '
        '${Cosmetics.sizeLabel(run.boardSize)}$speed';
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}
