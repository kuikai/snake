import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake/core/game_config.dart';
import 'package:snake/game/combo.dart';
import 'package:snake/game/engine.dart';
import 'package:snake/models/models.dart';

void main() {
  group('foodCellDistance', () {
    test('classic uses Manhattan and floors at 1', () {
      expect(
        foodCellDistance(
          from: const GridPoint(2, 3),
          to: const GridPoint(5, 7),
          gridSize: 20,
          mode: GameMode.classic,
        ),
        7,
      );
      expect(
        foodCellDistance(
          from: const GridPoint(4, 4),
          to: const GridPoint(4, 4),
          gridSize: 20,
          mode: GameMode.obstacles,
        ),
        1,
      );
    });

    test('wrap takes the shorter way around', () {
      expect(
        foodCellDistance(
          from: const GridPoint(0, 5),
          to: const GridPoint(19, 5),
          gridSize: 20,
          mode: GameMode.wrap,
        ),
        1,
      );
      expect(
        foodCellDistance(
          from: const GridPoint(0, 5),
          to: const GridPoint(19, 5),
          gridSize: 20,
          mode: GameMode.classic,
        ),
        19,
      );
    });
  });

  group('comboAfterEat', () {
    test('distance 6 climbs, holds, then drops', () {
      expect(comboAfterEat(combo: 1, steps: 8, distance: 6), 2);
      expect(comboAfterEat(combo: 2, steps: 9, distance: 6), 2);
      expect(comboAfterEat(combo: 2, steps: 16, distance: 6), 2);
      expect(comboAfterEat(combo: 2, steps: 17, distance: 6), 1);
    });

    test('stays inside x1 and x5', () {
      expect(
        comboAfterEat(combo: GameConfig.comboMax, steps: 1, distance: 1),
        GameConfig.comboMax,
      );
      expect(
        comboAfterEat(combo: GameConfig.comboMin, steps: 30, distance: 1),
        GameConfig.comboMin,
      );
    });
  });

  group('engine combo', () {
    const snake = [GridPoint(5, 5), GridPoint(4, 5), GridPoint(3, 5)];

    test('newRun starts at x1 with the opening apple distance', () {
      final state = SnakeEngine.newRun(random: Random(1));
      expect(state.combo, GameConfig.comboMin);
      expect(state.ticksSinceFood, 0);
      expect(
        state.foodDistance,
        foodCellDistance(
          from: state.snake.first,
          to: state.food,
          gridSize: state.gridSize,
          mode: state.mode,
        ),
      );
    });

    test('first apple pays 1 and a fast eat raises the combo', () {
      var state = _running(snake: snake, food: const GridPoint(6, 5));
      state = SnakeEngine.tick(state, random: Random(1));
      expect(state.score, 1);
      expect(state.combo, 2);
      expect(state.ticksSinceFood, 0);
    });

    test('the next apple pays the raised combo', () {
      var state = _running(snake: snake, food: const GridPoint(6, 5));
      state = SnakeEngine.tick(state, random: Random(1));
      final head = state.snake.first;
      final nextFood = head.moved(state.direction);
      state = state.copyWith(
        food: nextFood,
        ticksSinceFood: 0,
        foodDistance: foodCellDistance(
          from: head,
          to: nextFood,
          gridSize: state.gridSize,
          mode: state.mode,
        ),
      );
      state = SnakeEngine.tick(state, random: Random(1));
      expect(state.score, 3);
      expect(state.combo, 3);
    });

    test('a steady eat holds the combo', () {
      var state = _running(
        snake: snake,
        food: const GridPoint(6, 5),
        combo: 2,
        ticksSinceFood: 9,
        foodDistance: 6,
      );
      state = SnakeEngine.tick(state, random: Random(1));
      expect(state.score, 2);
      expect(state.combo, 2);
      expect(state.ticksSinceFood, 0);
    });

    test('a slow eat drops the combo', () {
      var state = _running(
        snake: snake,
        food: const GridPoint(6, 5),
        combo: 3,
        ticksSinceFood: 16,
        foodDistance: 6,
      );
      state = SnakeEngine.tick(state, random: Random(1));
      expect(state.score, 3);
      expect(state.combo, 2);
    });

    test('combo stops at x5 and x1', () {
      var capped = _running(
        snake: snake,
        food: const GridPoint(6, 5),
        combo: GameConfig.comboMax,
      );
      capped = SnakeEngine.tick(capped, random: Random(1));
      expect(capped.score, GameConfig.comboMax);
      expect(capped.combo, GameConfig.comboMax);

      var floored = _running(
        snake: snake,
        food: const GridPoint(6, 5),
        ticksSinceFood: 19,
      );
      floored = SnakeEngine.tick(floored, random: Random(1));
      expect(floored.score, 1);
      expect(floored.combo, GameConfig.comboMin);
    });

    test('eating a critter does not change the combo', () {
      var state = _running(
        snake: snake,
        food: const GridPoint(0, 0),
        combo: 4,
        ticksSinceFood: 2,
        critter: const Critter(
          kind: CritterKind.mouse,
          position: GridPoint(6, 5),
          ticksLeft: 4,
        ),
      );
      state = SnakeEngine.tick(state);
      expect(state.score, GameConfig.scorePerCritter);
      expect(state.combo, 4);
      expect(state.ticksSinceFood, 3);
      expect(state.foodEaten, 0);
    });

    test('pause does not advance the apple clock', () {
      var state = _running(ticksSinceFood: 4);
      state = SnakeEngine.pause(state);
      state = SnakeEngine.tick(state);
      expect(state.status, RunStatus.paused);
      expect(state.ticksSinceFood, 4);
      expect(state.combo, GameConfig.comboMin);
    });
  });
}

GameState _running({
  List<GridPoint>? snake,
  GridPoint food = const GridPoint(6, 5),
  int combo = GameConfig.comboMin,
  int ticksSinceFood = 0,
  int foodDistance = 1,
  Critter? critter,
}) {
  final body =
      snake ?? const [GridPoint(5, 5), GridPoint(4, 5), GridPoint(3, 5)];
  return GameState(
    status: RunStatus.running,
    mode: GameMode.classic,
    boardSize: BoardSize.medium,
    increasingSpeed: false,
    gridSize: GameConfig.mediumGrid,
    snake: body,
    direction: Direction.right,
    queuedDirection: null,
    food: food,
    obstacles: const [],
    score: 0,
    foodEaten: 0,
    tickMs: GameConfig.baseTickMs,
    combo: combo,
    ticksSinceFood: ticksSinceFood,
    foodDistance: foodDistance,
    critter: critter,
  );
}
