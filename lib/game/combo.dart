import 'dart:math';

import '../core/game_config.dart';
import '../models/enums.dart';
import '../models/grid_point.dart';

/// Shortest cell distance from [from] to [to].
///
/// Wrap uses the shorter way around each axis. Other modes use Manhattan.
/// Never returns less than 1, so an apple on the head still has a budget.
int foodCellDistance({
  required GridPoint from,
  required GridPoint to,
  required int gridSize,
  required GameMode mode,
}) {
  final wrap = mode == GameMode.wrap;
  final dx = _axisDistance(from.x, to.x, gridSize, wrap: wrap);
  final dy = _axisDistance(from.y, to.y, gridSize, wrap: wrap);
  return max(1, dx + dy);
}

int _axisDistance(int from, int to, int gridSize, {required bool wrap}) {
  final direct = (from - to).abs();
  if (!wrap) return direct;
  return min(direct, gridSize - direct);
}

/// Combo to use on the following apple.
///
/// [steps] includes the eat tick. [distance] is the distance stored when this
/// apple appeared. A fast eat is also inside the steady window, so fast is
/// checked first.
int comboAfterEat({
  required int combo,
  required int steps,
  required int distance,
}) {
  if (_isFastEat(steps: steps, distance: distance)) {
    return min(GameConfig.comboMax, combo + 1);
  }
  if (_isSteadyEat(steps: steps, distance: distance)) {
    return combo;
  }
  return max(GameConfig.comboMin, combo - 1);
}

bool _isFastEat({required int steps, required int distance}) {
  return steps <= distance + GameConfig.comboFastSlack;
}

bool _isSteadyEat({required int steps, required int distance}) {
  final limit =
      distance * GameConfig.comboSteadyFactor + GameConfig.comboSteadySlack;
  return steps <= limit;
}
