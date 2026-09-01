import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_router.dart';
import '../core/palette.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../providers/high_scores_provider.dart';
import '../providers/pro_status_provider.dart';
import '../services/feedback_service.dart';
import '../widgets/direction_pad.dart';
import '../widgets/game_over_panel.dart';
import '../widgets/snake_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  static const _swipeThreshold = 24.0;
  static const _palette = SnakePalette.dark;

  Offset? _panStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startRun();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(gameProvider.notifier).pause();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final start = _panStart;
    _panStart = null;
    if (start == null) return;

    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance >= 200) {
      _queueFromDelta(velocity);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _panStart ??= details.localPosition;
    final start = _panStart!;
    final delta = details.localPosition - start;
    if (delta.distance < _swipeThreshold) return;
    _queueFromDelta(delta);
    _panStart = details.localPosition;
  }

  void _queueFromDelta(Offset delta) {
    final direction = delta.dx.abs() > delta.dy.abs()
        ? (delta.dx > 0 ? Direction.right : Direction.left)
        : (delta.dy > 0 ? Direction.down : Direction.up);
    ref.read(gameProvider.notifier).queueDirection(direction);
  }

  Future<bool> _onBack() async {
    final status = ref.read(gameProvider).status;
    if (status == RunStatus.running) {
      ref.read(gameProvider.notifier).pause();
      return false;
    }
    return true;
  }

  Future<void> _goToMenu() async {
    await ref.read(feedbackServiceProvider).button();
    await ref.read(gameProvider.notifier).finalizeRunIfNeeded();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openPaywall() async {
    await Navigator.of(context).pushNamed(AppRoutes.paywall);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final scores = ref.watch(highScoresProvider);
    final isPro = ref.watch(proStatusProvider).isPro;
    final isNewHighScore = ref.read(gameProvider.notifier).isNewHighScore;
    final isGameOver = game.status == RunStatus.gameOver;
    final runKey = HighScoreKey(
      mode: game.mode,
      size: game.boardSize,
      increasingSpeed: game.increasingSpeed,
    );
    final bestForRun = scores.bestByKey[runKey.storageKey] ??
        (runKey.mode == GameMode.classic &&
                runKey.size == BoardSize.medium &&
                !runKey.increasingSpeed
            ? scores.classicBest
            : 0);

    return PopScope(
      canPop: game.status != RunStatus.running,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          await ref.read(gameProvider.notifier).finalizeRunIfNeeded();
          return;
        }
        final allow = await _onBack();
        if (allow && context.mounted) {
          await ref.read(gameProvider.notifier).finalizeRunIfNeeded();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: _palette.cream,
        body: SafeArea(
          child: isGameOver
              ? GameOverPanel(
                  score: game.score,
                  isNewHighScore: isNewHighScore,
                  continuesLeft: game.continuesLeft,
                  palette: _palette,
                  onContinue: game.continuesLeft > 0
                      ? () {
                          ref.read(gameProvider.notifier).useContinue();
                        }
                      : null,
                  onAgain: () {
                    ref.read(gameProvider.notifier).finalizeAndRestart();
                  },
                  onMenu: _goToMenu,
                  onUpgrade: isPro ? null : _openPaywall,
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          '${game.score}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fraunces(
                            fontWeight: FontWeight.w700,
                            fontSize: 40,
                            color: _palette.ink,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'best $bestForRun',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.figtree(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: _palette.inkSoft,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onPanStart: (details) {
                                  _panStart = details.localPosition;
                                },
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                onTap: () {
                                  if (game.status == RunStatus.paused) {
                                    ref.read(gameProvider.notifier).resume();
                                  } else if (game.status ==
                                      RunStatus.running) {
                                    ref.read(gameProvider.notifier).pause();
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SnakeBoard(
                                      state: game,
                                      palette: _palette,
                                    ),
                                    if (game.status == RunStatus.paused)
                                      _StatusBanner(
                                        label: 'paused',
                                        palette: _palette,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DirectionPad(
                          palette: _palette,
                          onDirection: (direction) {
                            ref
                                .read(gameProvider.notifier)
                                .queueDirection(direction);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    if (game.status == RunStatus.running ||
                        game.status == RunStatus.paused)
                      Positioned(
                        top: 4,
                        right: 8,
                        child: IconButton(
                          tooltip: game.status == RunStatus.paused
                              ? 'Resume'
                              : 'Pause',
                          onPressed: () {
                            ref.read(gameProvider.notifier).togglePause();
                          },
                          icon: Icon(
                            game.status == RunStatus.paused
                                ? Icons.play_arrow
                                : Icons.pause,
                            color: _palette.inkSoft,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.label,
    required this.palette,
  });

  final String label;
  final SnakePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: palette.cream.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: palette.ink,
        ),
      ),
    );
  }
}
