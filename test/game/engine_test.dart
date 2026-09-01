import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake/core/game_config.dart';
import 'package:snake/game/engine.dart';
import 'package:snake/models/models.dart';

GameState _classicRunning({
  List<GridPoint>? snake,
  Direction direction = Direction.right,
  GridPoint? food,
  Direction? queuedDirection,
}) {
  final gridSize = GameConfig.mediumGrid;
  final center = gridSize ~/ 2;
  final body = snake ??
      [
        GridPoint(center, center),
        GridPoint(center - 1, center),
        GridPoint(center - 2, center),
      ];
  // Place food far from snake so movement tests don't accidentally eat.
  final foodPoint = food ?? const GridPoint(0, 0);
  return GameState(
    status: RunStatus.running,
    mode: GameMode.classic,
    boardSize: BoardSize.medium,
    increasingSpeed: false,
    gridSize: gridSize,
    snake: body,
    direction: direction,
    queuedDirection: queuedDirection,
    food: foodPoint,
    obstacles: const [],
    score: 0,
    foodEaten: 0,
    continuesLeft: 0,
    tickMs: GameConfig.baseTickMs,
  );
}

void main() {
  group('SnakeEngine Classic', () {
    test('newRun places length-3 snake at center facing right', () {
      final state = SnakeEngine.newRun(random: Random(1));
      expect(state.status, RunStatus.ready);
      expect(state.mode, GameMode.classic);
      expect(state.gridSize, 20);
      expect(state.snake, hasLength(GameConfig.startLength));
      expect(state.direction, Direction.right);

      final center = state.gridSize ~/ 2;
      expect(state.snake.first, GridPoint(center, center));
      expect(state.snake[1], GridPoint(center - 1, center));
      expect(state.snake[2], GridPoint(center - 2, center));
    });

    test('cannot reverse into current direction', () {
      var state = _classicRunning(direction: Direction.right);
      state = SnakeEngine.queueDirection(state, Direction.left);
      expect(state.queuedDirection, isNull);

      state = SnakeEngine.queueDirection(state, Direction.up);
      expect(state.queuedDirection, Direction.up);
    });

    test('queues at most one pending direction', () {
      var state = _classicRunning(direction: Direction.right);
      state = SnakeEngine.queueDirection(state, Direction.up);
      state = SnakeEngine.queueDirection(state, Direction.down);
      expect(state.queuedDirection, Direction.down);
    });

    test('tick moves one cell and pops tail when not eating', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(0, 0),
      );
      state = SnakeEngine.tick(state);
      expect(state.snake, const [
        GridPoint(6, 5),
        GridPoint(5, 5),
        GridPoint(4, 5),
      ]);
      expect(state.score, 0);
      expect(state.status, RunStatus.running);
    });

    test('eat increases length and score by 1; food never on body', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(6, 5),
      );
      state = SnakeEngine.tick(state, random: Random(42));

      expect(state.score, 1);
      expect(state.foodEaten, 1);
      expect(state.snake, hasLength(4));
      expect(state.snake.first, const GridPoint(6, 5));
      expect(state.snake.contains(state.food), isFalse);
    });

    test('wall collision ends the run', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(19, 5),
          GridPoint(18, 5),
          GridPoint(17, 5),
        ],
        direction: Direction.right,
        food: const GridPoint(0, 0),
      );
      state = SnakeEngine.tick(state);
      expect(state.status, RunStatus.gameOver);
    });

    test('self collision ends the run', () {
      // Head about to turn into its own body.
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(5, 6),
          GridPoint(4, 6),
          GridPoint(4, 5),
        ],
        direction: Direction.left,
        food: const GridPoint(0, 0),
      );
      // Queue up would be fine; force move left into body at (4,5).
      state = SnakeEngine.tick(state);
      expect(state.status, RunStatus.gameOver);
    });

    test('pause ignores direction changes; resume then accepts', () {
      var state = _classicRunning();
      state = SnakeEngine.pause(state);
      expect(state.status, RunStatus.paused);

      state = SnakeEngine.queueDirection(state, Direction.up);
      expect(state.queuedDirection, isNull);

      state = SnakeEngine.start(state);
      state = SnakeEngine.queueDirection(state, Direction.up);
      expect(state.queuedDirection, Direction.up);
    });

    test('consumes queued direction on tick', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(0, 0),
        queuedDirection: Direction.up,
      );
      state = SnakeEngine.tick(state);
      expect(state.direction, Direction.up);
      expect(state.snake.first, const GridPoint(5, 4));
      expect(state.queuedDirection, isNull);
    });

    test('plays a full Classic run in memory until game over', () {
      var state = SnakeEngine.newRun(random: Random(7));
      state = SnakeEngine.start(state);

      // Drive into the right wall without turning.
      var ticks = 0;
      while (state.status != RunStatus.gameOver && ticks < 1000) {
        state = SnakeEngine.tick(state, random: Random(7 + ticks));
        ticks++;
      }

      expect(state.status, RunStatus.gameOver);
      expect(ticks, greaterThan(0));
      expect(ticks, lessThan(1000));
    });

    test('continue restores snapshot and decrements continuesLeft', () {
      final snapshot = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(0, 0),
      ).copyWith(continuesLeft: 3);

      final death = snapshot.copyWith(status: RunStatus.gameOver);
      final restored = SnakeEngine.useContinue(
        deathState: death,
        snapshot: snapshot,
      );

      expect(restored.status, RunStatus.running);
      expect(restored.continuesLeft, 2);
      expect(restored.snake, snapshot.snake);
      expect(restored.food, snapshot.food);
    });
  });
}
