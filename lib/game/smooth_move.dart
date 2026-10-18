import '../models/grid_point.dart';

/// Signed one-cell step from [from] to [to].
///
/// In wrap mode a jump of `gridSize - 1` is a step through the edge (±1),
/// never a slide across the board.
double cellStepDelta(int from, int to, int gridSize, {required bool wrap}) {
  var delta = to - from;
  if (wrap) {
    if (delta > 1) delta -= gridSize;
    if (delta < -1) delta += gridSize;
  }
  return delta.toDouble();
}

({double x, double y}) lerpCell({
  required GridPoint from,
  required GridPoint to,
  required double t,
  required int gridSize,
  required bool wrap,
}) {
  final dx = cellStepDelta(from.x, to.x, gridSize, wrap: wrap);
  final dy = cellStepDelta(from.y, to.y, gridSize, wrap: wrap);
  return (x: from.x + dx * t, y: from.y + dy * t);
}

GridPoint previousCellForSegment({
  required List<GridPoint> previous,
  required List<GridPoint> current,
  required int index,
}) {
  if (index < previous.length) return previous[index];
  return current[index];
}

/// Cell-space origins to paint so a wrapping segment is clipped at the edge
/// and continues on the opposite side instead of stretching across the board.
List<({double x, double y})> paintCellPositions({
  required double x,
  required double y,
  required int gridSize,
}) {
  final xs = <double>[x];
  if (x < 0) {
    xs.add(x + gridSize);
  } else if (x + 1 > gridSize) {
    xs.add(x - gridSize);
  }

  final ys = <double>[y];
  if (y < 0) {
    ys.add(y + gridSize);
  } else if (y + 1 > gridSize) {
    ys.add(y - gridSize);
  }

  return [
    for (final px in xs)
      for (final py in ys)
        (x: px, y: py),
  ];
}
