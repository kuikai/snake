import '../models/models.dart';

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
  static const int continuesPerRun = 3;

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
