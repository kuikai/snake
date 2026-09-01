enum Direction { up, down, left, right }

enum GameMode { classic, wrap, noWalls, obstacles }

enum BoardSize { small, medium, large }

enum SnakeSkin { classicGreen, ember, ocean, mono, neon }

enum BoardTheme { classic, midnight, sand, highContrast, forest }

enum RunStatus { ready, running, paused, gameOver }

extension DirectionX on Direction {
  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }
}

extension GameModeX on GameMode {
  String get storageKey {
    switch (this) {
      case GameMode.classic:
        return 'classic';
      case GameMode.wrap:
        return 'wrap';
      case GameMode.noWalls:
        return 'noWalls';
      case GameMode.obstacles:
        return 'obstacles';
    }
  }
}

extension BoardSizeX on BoardSize {
  String get storageKey {
    switch (this) {
      case BoardSize.small:
        return 'small';
      case BoardSize.medium:
        return 'medium';
      case BoardSize.large:
        return 'large';
    }
  }
}
