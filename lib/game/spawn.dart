import 'dart:math';

import '../core/game_config.dart';
import '../models/models.dart';

/// Picks a random empty cell. Never on snake or obstacles.
GridPoint spawnFood({
  required int gridSize,
  required List<GridPoint> snake,
  required List<GridPoint> obstacles,
  Random? random,
}) {
  final occupied = <GridPoint>{...snake, ...obstacles};
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
