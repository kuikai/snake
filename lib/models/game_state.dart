import '../core/game_config.dart';
import 'enums.dart';
import 'grid_point.dart';

class GameState {
  const GameState({
    required this.status,
    required this.mode,
    required this.boardSize,
    required this.increasingSpeed,
    required this.gridSize,
    required this.snake,
    required this.direction,
    required this.queuedDirection,
    required this.food,
    required this.obstacles,
    required this.score,
    required this.foodEaten,
    required this.continuesLeft,
    required this.tickMs,
  });

  final RunStatus status;
  final GameMode mode;
  final BoardSize boardSize;
  final bool increasingSpeed;
  final int gridSize;
  final List<GridPoint> snake;
  final Direction direction;
  final Direction? queuedDirection;
  final GridPoint food;
  final List<GridPoint> obstacles;
  final int score;
  final int foodEaten;
  final int continuesLeft;
  final int tickMs;

  /// Places snake in the center, facing right, length 3.
  /// Spawns food on an empty cell. Optionally places obstacles.
  factory GameState.newRun({
    required GameMode mode,
    required BoardSize boardSize,
    required bool increasingSpeed,
    required bool isPro,
  }) {
    final gridSize = GameConfig.gridSizeFor(boardSize);
    final center = gridSize ~/ 2;
    final snake = <GridPoint>[
      for (var i = 0; i < GameConfig.startLength; i++)
        GridPoint(center - i, center),
    ];

    final obstacles = mode == GameMode.obstacles
        ? _placeObstacles(boardSize: boardSize, gridSize: gridSize, snake: snake)
        : const <GridPoint>[];

    final food = _spawnFood(
      gridSize: gridSize,
      snake: snake,
      obstacles: obstacles,
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

  GameState copyWith({
    RunStatus? status,
    GameMode? mode,
    BoardSize? boardSize,
    bool? increasingSpeed,
    int? gridSize,
    List<GridPoint>? snake,
    Direction? direction,
    Direction? queuedDirection,
    bool clearQueuedDirection = false,
    GridPoint? food,
    List<GridPoint>? obstacles,
    int? score,
    int? foodEaten,
    int? continuesLeft,
    int? tickMs,
  }) {
    return GameState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      boardSize: boardSize ?? this.boardSize,
      increasingSpeed: increasingSpeed ?? this.increasingSpeed,
      gridSize: gridSize ?? this.gridSize,
      snake: snake ?? this.snake,
      direction: direction ?? this.direction,
      queuedDirection:
          clearQueuedDirection ? null : (queuedDirection ?? this.queuedDirection),
      food: food ?? this.food,
      obstacles: obstacles ?? this.obstacles,
      score: score ?? this.score,
      foodEaten: foodEaten ?? this.foodEaten,
      continuesLeft: continuesLeft ?? this.continuesLeft,
      tickMs: tickMs ?? this.tickMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'mode': mode.name,
        'boardSize': boardSize.name,
        'increasingSpeed': increasingSpeed,
        'gridSize': gridSize,
        'snake': snake.map((p) => p.toJson()).toList(),
        'direction': direction.name,
        'queuedDirection': queuedDirection?.name,
        'food': food.toJson(),
        'obstacles': obstacles.map((p) => p.toJson()).toList(),
        'score': score,
        'foodEaten': foodEaten,
        'continuesLeft': continuesLeft,
        'tickMs': tickMs,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      status: RunStatus.values.byName(json['status'] as String),
      mode: GameMode.values.byName(json['mode'] as String),
      boardSize: BoardSize.values.byName(json['boardSize'] as String),
      increasingSpeed: json['increasingSpeed'] as bool,
      gridSize: json['gridSize'] as int,
      snake: (json['snake'] as List)
          .map((e) => GridPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      direction: Direction.values.byName(json['direction'] as String),
      queuedDirection: json['queuedDirection'] == null
          ? null
          : Direction.values.byName(json['queuedDirection'] as String),
      food: GridPoint.fromJson(Map<String, dynamic>.from(json['food'] as Map)),
      obstacles: (json['obstacles'] as List)
          .map((e) => GridPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      score: json['score'] as int,
      foodEaten: json['foodEaten'] as int,
      continuesLeft: json['continuesLeft'] as int,
      tickMs: json['tickMs'] as int,
    );
  }

  static GridPoint _spawnFood({
    required int gridSize,
    required List<GridPoint> snake,
    required List<GridPoint> obstacles,
  }) {
    final occupied = {...snake, ...obstacles};
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        final point = GridPoint(x, y);
        if (!occupied.contains(point)) {
          return point;
        }
      }
    }
    // Board full — return a fallback (should not happen in normal play).
    return const GridPoint(0, 0);
  }

  /// Deterministic obstacle layout that never blocks the start corridor
  /// (center row, snake facing right).
  static List<GridPoint> _placeObstacles({
    required BoardSize boardSize,
    required int gridSize,
    required List<GridPoint> snake,
  }) {
    final count = GameConfig.obstaclesBySize[boardSize]!;
    final center = gridSize ~/ 2;
    final blocked = <GridPoint>{...snake};
    // Keep the start corridor clear: center row around the snake.
    for (var x = 0; x < gridSize; x++) {
      blocked.add(GridPoint(x, center));
    }

    final placed = <GridPoint>[];
    var cursor = 0;
    for (var y = 0; y < gridSize && placed.length < count; y++) {
      for (var x = 0; x < gridSize && placed.length < count; x++) {
        cursor++;
        // Skip some cells for a sparse, deterministic scatter.
        if (cursor % 3 != 0) continue;
        final point = GridPoint(x, y);
        if (blocked.contains(point)) continue;
        placed.add(point);
        blocked.add(point);
      }
    }
    return placed;
  }
}
