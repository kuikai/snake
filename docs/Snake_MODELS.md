# Snake – Models (create these first)

Put models in `lib/models/` and export from `lib/models/models.dart`.

All models must be JSON serializable.

---

## Enums

```dart
enum Direction { up, down, left, right }

enum GameMode { classic, wrap, noWalls, obstacles }

enum BoardSize { small, medium, large } // 12, 20, 28

enum SnakeSkin { classicGreen, ember, ocean, mono, neon }

enum BoardTheme { classic, midnight, sand, highContrast, forest }

enum RunStatus { ready, running, paused, gameOver }
```

---

## GameConfig (constants, not persisted)

File: `lib/core/game_config.dart`

- smallGrid = 12
- mediumGrid = 20
- largeGrid = 28
- startLength = 3
- startDirection = Direction.right
- baseTickMs = 180
- speedStepEveryFood = 5
- speedStepMs = 15
- minTickMs = 80
- scorePerFood = 1
- continuesPerRun = 3
- obstaclesBySize = { small: 6, medium: 8, large: 12 }
- maxHistory = 30

---

## Point

```dart
class GridPoint {
  final int x;
  final int y;
}
```

- `==` and `hashCode` on x,y
- `moved(Direction)` helper

---

## GameSettings (persisted)

```dart
class GameSettings {
  final ThemeMode themeMode;        // light / dark / system
  final bool soundEnabled;
  final bool hapticsEnabled;
  final GameMode lastMode;          // Free always classic
  final BoardSize lastBoardSize;    // Free always medium
  final bool lastIncreasingSpeed;   // Free always false
  final SnakeSkin skin;             // Free always classicGreen
  final BoardTheme boardTheme;      // Free always classic
}
```

---

## HighScoreBoard (persisted)

```dart
class HighScoreKey {
  final GameMode mode;
  final BoardSize size;
  final bool increasingSpeed;
}

class HighScores {
  final int classicBest;                       // always used by Free
  final Map<String, int> bestByKey;            // Pro personal bests
  final List<GameRun> recent;                  // last 30, newest first
}
```

Key string format: `classic_medium_speed0`  
Example: `obstacles_large_speed1`

---

## GameRun (one finished or continued session, persisted in history)

```dart
class GameRun {
  final String id;
  final DateTime finishedAt;
  final GameMode mode;
  final BoardSize boardSize;
  final bool increasingSpeed;
  final int score;
  final int foodEaten;
  final bool isPersonalBest;
}
```

---

## GameState (in memory only — do not persist every tick)

```dart
class GameState {
  final RunStatus status;
  final GameMode mode;
  final BoardSize boardSize;
  final bool increasingSpeed;
  final int gridSize;
  final List<GridPoint> snake;     // index 0 = head
  final Direction direction;
  final Direction? queuedDirection;
  final GridPoint food;
  final List<GridPoint> obstacles;
  final int score;
  final int foodEaten;
  final int continuesLeft;         // 3 for Pro at start, 0 for Free
  final int tickMs;
}
```

Factory: `GameState.newRun(...)` places snake in the center, facing right, length 3, spawns food, optionally places obstacles.

---

## ProStatus

```dart
class ProStatus {
  final bool isPro;
  final bool isLoading;
}
```

RevenueCat is source of truth. Cache `isPro` locally so offline still works.

---

## Helper rules

- `direction.opposite` must be defined.
- Applying input: if new dir == opposite of current `direction`, ignore. Else set `queuedDirection`.
- On tick: consume `queuedDirection` if legal, then move head, then check collisions, then eat or pop tail.
- Continue: restore a snapshot taken at the start of the last successful tick (before the death move). Decrement `continuesLeft`.
