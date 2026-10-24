import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../game/engine.dart';
import '../models/models.dart';
import '../services/feedback_service.dart';
import 'high_scores_provider.dart';
import 'pro_status_provider.dart';
import 'settings_provider.dart';

final gameProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

class GameController extends Notifier<GameState> {
  Timer? _timer;
  bool isNewHighScore = false;
  bool _recordedThisOver = false;

  FeedbackService get _feedback => ref.read(feedbackServiceProvider);

  @override
  GameState build() {
    ref.onDispose(_tearDown);
    final isPro = ref.read(proStatusProvider).isPro;
    final settings =
        ref.read(settingsProvider.notifier).effectiveForPlay(isPro: isPro);
    return SnakeEngine.newRun(
      mode: settings.lastMode,
      boardSize: settings.lastBoardSize,
      increasingSpeed: settings.lastIncreasingSpeed,
    );
  }

  void startRun() {
    _stopTimer();
    isNewHighScore = false;
    _recordedThisOver = false;
    final isPro = ref.read(proStatusProvider).isPro;
    final settings =
        ref.read(settingsProvider.notifier).effectiveForPlay(isPro: isPro);
    state = SnakeEngine.start(
      SnakeEngine.newRun(
        mode: settings.lastMode,
        boardSize: settings.lastBoardSize,
        increasingSpeed: settings.lastIncreasingSpeed,
      ),
    );
    _syncLoop();
  }

  void startClassic() => startRun();

  void queueDirection(Direction direction) {
    final before = state.queuedDirection;
    final next = SnakeEngine.queueDirection(state, direction);
    state = next;
    if (next.queuedDirection != null && next.queuedDirection != before) {
      unawaited(_feedback.turn());
    }
  }

  void pause() {
    if (state.status != RunStatus.running) return;
    state = SnakeEngine.pause(state);
    _syncLoop();
  }

  void resume() {
    if (state.status != RunStatus.paused) return;
    state = SnakeEngine.start(state);
    _syncLoop();
  }

  void togglePause() {
    if (state.status == RunStatus.running) {
      pause();
    } else if (state.status == RunStatus.paused) {
      resume();
    }
  }

  Future<void> finalizeAndRestart() async {
    await finalizeRunIfNeeded();
    unawaited(_feedback.button());
    startRun();
  }

  Future<void> finalizeRunIfNeeded() async {
    if (state.status != RunStatus.gameOver) return;
    await _recordFinishedRun(state);
  }

  void _onTick() {
    if (state.status != RunStatus.running) return;

    final previous = state;
    final next = SnakeEngine.tick(previous);

    if (next.status == RunStatus.gameOver) {
      unawaited(_feedback.death());
      _handleGameOver(next);
      return;
    }

    if (next.score > previous.score) {
      unawaited(_feedback.eat());
    }

    state = next;
    if (next.tickMs != previous.tickMs) {
      _syncLoop();
    }
  }

  void _handleGameOver(GameState next) {
    isNewHighScore =
        ref.read(highScoresProvider.notifier).wouldBePersonalBest(next);
    state = next;
    _syncLoop();
    unawaited(_recordFinishedRun(next));
  }

  Future<void> _recordFinishedRun(GameState game) async {
    if (_recordedThisOver) return;
    _recordedThisOver = true;
    final result =
        await ref.read(highScoresProvider.notifier).recordRun(game);
    isNewHighScore = result.isPersonalBest;
  }

  void _syncLoop() {
    _stopTimer();
    final running = state.status == RunStatus.running;
    unawaited(_setAwake(running));
    if (!running) return;

    _timer = Timer.periodic(
      Duration(milliseconds: state.tickMs),
      (_) => _onTick(),
    );
  }

  Future<void> _setAwake(bool awake) async {
    try {
      if (awake) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Platform may not support wakelock (e.g. some desktop targets).
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tearDown() {
    _stopTimer();
    unawaited(_setAwake(false));
  }
}
