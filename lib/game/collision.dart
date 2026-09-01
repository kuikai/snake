import '../models/models.dart';

bool isOutOfBounds(GridPoint point, int gridSize) {
  return point.x < 0 ||
      point.y < 0 ||
      point.x >= gridSize ||
      point.y >= gridSize;
}

/// Wraps a point to the opposite edge (Wrap mode).
GridPoint wrapPoint(GridPoint point, int gridSize) {
  var x = point.x;
  var y = point.y;
  if (x < 0) x = gridSize - 1;
  if (x >= gridSize) x = 0;
  if (y < 0) y = gridSize - 1;
  if (y >= gridSize) y = 0;
  return GridPoint(x, y);
}

/// Next head cell after applying mode edge rules.
/// Returns null when Classic / Obstacles hit a solid wall.
GridPoint? nextHeadPosition({
  required GridPoint head,
  required Direction direction,
  required int gridSize,
  required GameMode mode,
}) {
  final stepped = head.moved(direction);

  switch (mode) {
    case GameMode.classic:
    case GameMode.obstacles:
      if (isOutOfBounds(stepped, gridSize)) return null;
      return stepped;
    case GameMode.wrap:
      return wrapPoint(stepped, gridSize);
    case GameMode.noWalls:
      // Open edges: leaving the board does not kill; clamp so play stays on-grid.
      if (isOutOfBounds(stepped, gridSize)) {
        return GridPoint(
          stepped.x.clamp(0, gridSize - 1),
          stepped.y.clamp(0, gridSize - 1),
        );
      }
      return stepped;
  }
}

bool hitsSelf(GridPoint head, List<GridPoint> snake) {
  return snake.contains(head);
}

bool hitsObstacle(GridPoint head, List<GridPoint> obstacles) {
  return obstacles.contains(head);
}
