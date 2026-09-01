import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/game_config.dart';
import '../models/models.dart';
import 'storage_provider.dart';

final highScoresProvider =
    NotifierProvider<HighScoresNotifier, HighScores>(HighScoresNotifier.new);

final classicHighScoreProvider = Provider<int>((ref) {
  return ref.watch(highScoresProvider).classicBest;
});

class RecordRunResult {
  const RecordRunResult({required this.isPersonalBest});

  final bool isPersonalBest;
}

class HighScoresNotifier extends Notifier<HighScores> {
  @override
  HighScores build() {
    return ref.read(storageServiceProvider).loadHighScores();
  }

  HighScoreKey keyFor(GameState game) {
    return HighScoreKey(
      mode: game.mode,
      size: game.boardSize,
      increasingSpeed: game.increasingSpeed,
    );
  }

  int bestFor(HighScoreKey key) {
    return state.bestByKey[key.storageKey] ?? 0;
  }

  bool wouldBePersonalBest(GameState game) {
    final key = keyFor(game);
    if (game.score > bestFor(key)) return true;
    if (_isClassicTrack(game) && game.score > state.classicBest) return true;
    return false;
  }

  /// Saves classic best when [score] beats the current best.
  Future<bool> recordClassicScore(int score) async {
    if (score <= state.classicBest) return false;
    final next = state.copyWith(classicBest: score);
    state = next;
    await ref.read(storageServiceProvider).saveHighScores(next);
    return true;
  }

  /// Persists a finished run: recent history + personal bests.
  Future<RecordRunResult> recordRun(GameState game) async {
    final key = keyFor(game);
    final keyString = key.storageKey;
    final previousBest = state.bestByKey[keyString] ?? 0;
    final isKeyBest = game.score > previousBest;

    var classicBest = state.classicBest;
    var isClassicBest = false;
    if (_isClassicTrack(game) && game.score > classicBest) {
      classicBest = game.score;
      isClassicBest = true;
    }

    final bestByKey = Map<String, int>.from(state.bestByKey);
    if (isKeyBest) {
      bestByKey[keyString] = game.score;
    }

    final run = GameRun(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      finishedAt: DateTime.now(),
      mode: game.mode,
      boardSize: game.boardSize,
      increasingSpeed: game.increasingSpeed,
      score: game.score,
      foodEaten: game.foodEaten,
      isPersonalBest: isKeyBest,
    );

    final recent = <GameRun>[run, ...state.recent];
    if (recent.length > GameConfig.maxHistory) {
      recent.removeRange(GameConfig.maxHistory, recent.length);
    }

    final next = state.copyWith(
      classicBest: classicBest,
      bestByKey: bestByKey,
      recent: recent,
    );
    state = next;
    await ref.read(storageServiceProvider).saveHighScores(next);

    return RecordRunResult(isPersonalBest: isKeyBest || isClassicBest);
  }

  bool _isClassicTrack(GameState game) {
    return game.mode == GameMode.classic &&
        game.boardSize == BoardSize.medium &&
        !game.increasingSpeed;
  }
}
