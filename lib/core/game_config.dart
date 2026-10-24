import '../models/enums.dart';

/// Locked gameplay constants. Do not scatter magic numbers elsewhere.
abstract final class GameConfig {
  static const int smallGrid = 12;
  static const int mediumGrid = 20;
  static const int largeGrid = 28;

  static const int startLength = 3;
  static const Direction startDirection = Direction.right;

  static const int baseTickMs = 180;
  static const int speedStepEveryFood = 5;
  static const int speedStepMs = 15;
  static const int minTickMs = 80;

  static const int scorePerFood = 1;
  static const int scorePerCritter = 5;

  /// Speed combo applied to the next apple. Climbs on a fast eat, drops on a slow one.
  static const int comboMin = 1;
  static const int comboMax = 5;

  /// Eat within `distance + slack` steps to raise the combo.
  static const int comboFastSlack = 2;

  /// Eat within `distance * factor + slack` steps to hold the combo. Slower drops it.
  static const int comboSteadyFactor = 2;
  static const int comboSteadySlack = 4;

  /// Apples that must be eaten before the first (or next) critter spawn can roll.
  static const int critterCooldownApples = 3;
  static const double critterSpawnChance = 0.15;
  static const int critterLifetimeTicks = 6;
  static const int critterMinManhattan = 2;
  static const int critterMaxManhattan = 5;

  static const Map<BoardSize, int> obstaclesBySize = {
    BoardSize.small: 6,
    BoardSize.medium: 8,
    BoardSize.large: 12,
  };

  static const int maxHistory = 30;

  static const String productId = 'snake_pro';
  static const String entitlementId = 'pro';

  static int gridSizeFor(BoardSize size) {
    switch (size) {
      case BoardSize.small:
        return smallGrid;
      case BoardSize.medium:
        return mediumGrid;
      case BoardSize.large:
        return largeGrid;
    }
  }
}
