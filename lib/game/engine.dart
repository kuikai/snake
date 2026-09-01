import 'dart:math';

import '../core/game_config.dart';
import '../models/models.dart';
import 'collision.dart';
import 'spawn.dart';

/// Pure headless Snake engine. No Flutter / UI imports.
///
/// Tick contract:
/// 1. Consume queued direction if legal (not a 180° reverse).
/// 2. Move head one cell.
/// 3. Check collisions.
/// 4. Eat (grow + score) or pop tail.
abstract final class SnakeEngine {
  static GameState newRun({
    GameMode mode = GameMode.classic,
    BoardSize boardSize = BoardSize.medium,
    bool increasingSpeed = false,
    bool isPro = false,
    Random? random,
  }) {
    final gridSize = GameConfig.gridSizeFor(boardSize);
    final center = gridSize ~/ 2;
    final snake = <GridPoint>[
      for (var i = 0; i < GameConfig.startLength; i++)
        GridPoint(center - i, center),
    ];

    final obstacles = mode == GameMode.obstacles
        ? placeObstacles(
            boardSize: boardSize,
            gridSize: gridSize,
            snake: snake,
          )
        : const <GridPoint>[];

    final food = spawnFood(
      gridSize: gridSize,
      snake: snake,
      obstacles: obstacles,
      random: random,
    );

    return GameState(
      status: RunStatus.ready,
      mode: mode,
      boardSize: boardSize,
      increasingSpeed: increasingSpeed,
      gridSize: gridSize,
      snake: snake,
      direction: GameConfig.startDirection,
      queuedDirection: null,
      food: food,
      obstacles: obstacles,
      score: 0,
      foodEaten: 0,
      continuesLeft: isPro ? GameConfig.continuesPerRun : 0,
      tickMs: GameConfig.baseTickMs,
    );
  }

  /// Queue at most one pending turn. Ignores 180° reverse of current direction.
  /// Ignored while paused or game over.
  static GameState queueDirection(GameState state, Direction input) {
    if (state.status == RunStatus.paused ||
        state.status == RunStatus.gameOver) {
      return state;
    }
    if (input == state.direction.opposite) {
      return state;
    }
    return state.copyWith(queuedDirection: input);
  }

  static GameState start(GameState state) {
    if (state.status == RunStatus.ready || state.status == RunStatus.paused) {
      return state.copyWith(status: RunStatus.running);
    }
    return state;
  }

  static GameState pause(GameState state) {
    if (state.status == RunStatus.running) {
      return state.copyWith(status: RunStatus.paused);
    }
    return state;
  }

  /// Advance one cell. No-op unless [RunStatus.running].
  static GameState tick(GameState state, {Random? random}) {
    if (state.status != RunStatus.running) {
      return state;
    }

    var direction = state.direction;
    Direction? queued = state.queuedDirection;
    if (queued != null) {
      if (queued != direction.opposite) {
        direction = queued;
      }
      queued = null;
    }

    final next = nextHeadPosition(
      head: state.snake.first,
      direction: direction,
      gridSize: state.gridSize,
      mode: state.mode,
    );

    // Classic / Obstacles solid wall.
    if (next == null) {
      return state.copyWith(
        status: RunStatus.gameOver,
        direction: direction,
        clearQueuedDirection: true,
      );
    }

    // No Walls: clamped into the same cell → no movement this tick.
    if (state.mode == GameMode.noWalls && next == state.snake.first) {
      return state.copyWith(
        direction: direction,
        clearQueuedDirection: true,
      );
    }

    if (hitsSelf(next, state.snake) || hitsObstacle(next, state.obstacles)) {
      return state.copyWith(
        status: RunStatus.gameOver,
        direction: direction,
        clearQueuedDirection: true,
      );
    }

    final ate = next == state.food;
    final newSnake = <GridPoint>[next, ...state.snake];
    if (!ate) {
      newSnake.removeLast();
      return state.copyWith(
        snake: newSnake,
        direction: direction,
        clearQueuedDirection: true,
      );
    }

    final foodEaten = state.foodEaten + 1;
    final score = state.score + GameConfig.scorePerFood;
    var tickMs = state.tickMs;
    if (state.increasingSpeed &&
        foodEaten % GameConfig.speedStepEveryFood == 0) {
      tickMs = max(GameConfig.minTickMs, tickMs - GameConfig.speedStepMs);
    }

    final food = spawnFood(
      gridSize: state.gridSize,
      snake: newSnake,
      obstacles: state.obstacles,
      random: random,
    );

    return state.copyWith(
      snake: newSnake,
      direction: direction,
      clearQueuedDirection: true,
      food: food,
      score: score,
      foodEaten: foodEaten,
      tickMs: tickMs,
    );
  }

  /// Restore [snapshot] from before the death move; spend one continue.
  static GameState useContinue({
    required GameState deathState,
    required GameState snapshot,
  }) {
    if (deathState.status != RunStatus.gameOver ||
        deathState.continuesLeft <= 0) {
      return deathState;
    }
    return snapshot.copyWith(
      status: RunStatus.running,
      continuesLeft: deathState.continuesLeft - 1,
      clearQueuedDirection: true,
    );
  }
}
