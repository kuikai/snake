import 'dart:math';

import '../core/game_config.dart';
import '../models/models.dart';

/// Picks a random empty cell. Never on snake, obstacles, or [extraBlocked].
GridPoint spawnFood({
  required int gridSize,
  required List<GridPoint> snake,
  required List<GridPoint> obstacles,
  Iterable<GridPoint> extraBlocked = const [],
  Random? random,
}) {
  final occupied = <GridPoint>{...snake, ...obstacles, ...extraBlocked};
  final empty = <GridPoint>[];
  for (var y = 0; y < gridSize; y++) {
    for (var x = 0; x < gridSize; x++) {
      final point = GridPoint(x, y);
      if (!occupied.contains(point)) {
        empty.add(point);
      }
    }
  }
  if (empty.isEmpty) {
    return const GridPoint(0, 0);
  }
  final rng = random ?? Random();
  return empty[rng.nextInt(empty.length)];
}

/// Spawns a critter 2–5 Manhattan tiles from [head], or null if no legal cell.
Critter? spawnCritter({
  required int gridSize,
  required GridPoint head,
  required List<GridPoint> snake,
  required GridPoint food,
  required List<GridPoint> obstacles,
  Random? random,
}) {
  final occupied = <GridPoint>{...snake, food, ...obstacles};
  final candidates = <GridPoint>[];
  for (var y = 0; y < gridSize; y++) {
    for (var x = 0; x < gridSize; x++) {
      final point = GridPoint(x, y);
      if (occupied.contains(point)) continue;
      final distance = (point.x - head.x).abs() + (point.y - head.y).abs();
      if (distance < GameConfig.critterMinManhattan ||
          distance > GameConfig.critterMaxManhattan) {
        continue;
      }
      candidates.add(point);
    }
  }
  if (candidates.isEmpty) return null;

  final rng = random ?? Random();
  final position = candidates[rng.nextInt(candidates.length)];
  final kind = CritterKind.values[rng.nextInt(CritterKind.values.length)];
  return Critter(
    kind: kind,
    position: position,
    ticksLeft: GameConfig.critterLifetimeTicks,
  );
}

/// Deterministic obstacle layout that never blocks the start corridor
/// (full center row — snake starts there facing right).
List<GridPoint> placeObstacles({
  required BoardSize boardSize,
  required int gridSize,
  required List<GridPoint> snake,
}) {
  final count = GameConfig.obstaclesBySize[boardSize]!;
  final center = gridSize ~/ 2;
  final blocked = <GridPoint>{...snake};
  for (var x = 0; x < gridSize; x++) {
    blocked.add(GridPoint(x, center));
  }

  final placed = <GridPoint>[];
  var cursor = 0;
  for (var y = 0; y < gridSize && placed.length < count; y++) {
    for (var x = 0; x < gridSize && placed.length < count; x++) {
      cursor++;
      if (cursor % 3 != 0) continue;
      final point = GridPoint(x, y);
      if (blocked.contains(point)) continue;
      placed.add(point);
      blocked.add(point);
    }
  }
  return placed;
}
