import 'dart:collection';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake/core/game_config.dart';
import 'package:snake/game/engine.dart';
import 'package:snake/game/spawn.dart';
import 'package:snake/models/models.dart';

GameState _classicRunning({
  List<GridPoint>? snake,
  Direction direction = Direction.right,
  GridPoint? food,
  Direction? queuedDirection,
  Critter? critter,
  int foodEaten = 0,
  int score = 0,
  int applesUntilCritterRoll = GameConfig.critterCooldownApples,
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
    score: score,
    foodEaten: foodEaten,
    tickMs: GameConfig.baseTickMs,
    critter: critter,
    applesUntilCritterRoll: applesUntilCritterRoll,
  );
}

/// Deterministic RNG for engine tests (implements [Random]).
class _SeqRandom implements Random {
  _SeqRandom({
    List<double> doubles = const [],
    List<int> ints = const [],
  })  : _doubles = Queue.of(doubles),
        _ints = Queue.of(ints);

  final Queue<double> _doubles;
  final Queue<int> _ints;

  @override
  bool nextBool() => nextDouble() < 0.5;

  @override
  double nextDouble() => _doubles.isEmpty ? 0.99 : _doubles.removeFirst();

  @override
  int nextInt(int max) {
    final value = _ints.isEmpty ? 0 : _ints.removeFirst();
    return value % max;
  }
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
      expect(state.critter, isNull);
      expect(state.applesUntilCritterRoll, GameConfig.critterCooldownApples);

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

    test('game over stays game over', () {
      final death = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(0, 0),
      ).copyWith(status: RunStatus.gameOver);

      final next = SnakeEngine.tick(death);

      expect(next.status, RunStatus.gameOver);
      expect(next.snake, death.snake);
      expect(next.food, death.food);
    });
  });

  group('Critters', () {
    test('spawnCritter stays 2–5 Manhattan from head and avoids apple', () {
      const head = GridPoint(10, 10);
      const food = GridPoint(12, 10);
      final snake = [
        head,
        const GridPoint(9, 10),
        const GridPoint(8, 10),
      ];
      final critter = spawnCritter(
        gridSize: 20,
        head: head,
        snake: snake,
        food: food,
        obstacles: const [],
        random: Random(3),
      );

      expect(critter, isNotNull);
      final distance =
          (critter!.position.x - head.x).abs() + (critter.position.y - head.y).abs();
      expect(distance, inInclusiveRange(2, 5));
      expect(critter.position, isNot(food));
      expect(snake.contains(critter.position), isFalse);
      expect(critter.ticksLeft, GameConfig.critterLifetimeTicks);
    });

    test('no spawn roll before 3 apples eaten', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(6, 5),
        foodEaten: 0,
        applesUntilCritterRoll: 3,
      );
      // Force a would-be successful roll; cooldown still blocks it.
      state = SnakeEngine.tick(
        state,
        random: _SeqRandom(doubles: [0.0], ints: [0, 0, 0]),
      );
      expect(state.foodEaten, 1);
      expect(state.applesUntilCritterRoll, 2);
      expect(state.critter, isNull);
    });

    test('15% roll can spawn after cooldown reaches zero', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(6, 5),
        foodEaten: 2,
        applesUntilCritterRoll: 1,
      );
      // spawnFood nextInt, then nextDouble < 0.15, then position + kind ints.
      state = SnakeEngine.tick(
        state,
        random: _SeqRandom(doubles: [0.05], ints: [0, 0, 1]),
      );
      expect(state.foodEaten, 3);
      expect(state.applesUntilCritterRoll, 0);
      expect(state.critter, isNotNull);
      expect(state.critter!.ticksLeft, GameConfig.critterLifetimeTicks);
    });

    test('eating critter scores +5, grows +1, starts cooldown', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(0, 0),
        score: 3,
        foodEaten: 3,
        applesUntilCritterRoll: 0,
        critter: const Critter(
          kind: CritterKind.mouse,
          position: GridPoint(6, 5),
          ticksLeft: 4,
        ),
      );
      state = SnakeEngine.tick(state);
      expect(state.score, 8);
      expect(state.foodEaten, 3);
      expect(state.snake, hasLength(4));
      expect(state.critter, isNull);
      expect(state.applesUntilCritterRoll, GameConfig.critterCooldownApples);
    });

    test('critter expires after 5 ticks with no penalty', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(0, 0),
        score: 2,
        critter: const Critter(
          kind: CritterKind.lizard,
          position: GridPoint(10, 10),
          ticksLeft: 5,
        ),
      );

      for (var i = 0; i < 5; i++) {
        state = SnakeEngine.tick(state);
      }

      expect(state.critter, isNull);
      expect(state.score, 2);
      expect(state.applesUntilCritterRoll, GameConfig.critterCooldownApples);
    });

    test('pause does not age critter ticks', () {
      var state = _classicRunning(
        critter: const Critter(
          kind: CritterKind.rat,
          position: GridPoint(10, 10),
          ticksLeft: 3,
        ),
      );
      state = SnakeEngine.pause(state);
      state = SnakeEngine.tick(state);
      expect(state.status, RunStatus.paused);
      expect(state.critter!.ticksLeft, 3);
    });

    test('failed roll leaves cooldown at zero for next apple', () {
      var state = _classicRunning(
        snake: const [
          GridPoint(5, 5),
          GridPoint(4, 5),
          GridPoint(3, 5),
        ],
        food: const GridPoint(6, 5),
        foodEaten: 3,
        applesUntilCritterRoll: 0,
      );
      state = SnakeEngine.tick(
        state,
        random: _SeqRandom(doubles: [0.9], ints: [0]),
      );
      expect(state.critter, isNull);
      expect(state.applesUntilCritterRoll, 0);
    });
  });
}
