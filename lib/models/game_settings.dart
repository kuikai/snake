import 'package:flutter/material.dart';

import 'enums.dart';

class GameSettings {
  const GameSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.lastMode = GameMode.classic,
    this.lastBoardSize = BoardSize.medium,
    this.lastIncreasingSpeed = false,
    this.skin = SnakeSkin.classicGreen,
    this.boardTheme = BoardTheme.classic,
  });

  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final GameMode lastMode;
  final BoardSize lastBoardSize;
  final bool lastIncreasingSpeed;
  final SnakeSkin skin;
  final BoardTheme boardTheme;

  GameSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    GameMode? lastMode,
    BoardSize? lastBoardSize,
    bool? lastIncreasingSpeed,
    SnakeSkin? skin,
    BoardTheme? boardTheme,
  }) {
    return GameSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      lastMode: lastMode ?? this.lastMode,
      lastBoardSize: lastBoardSize ?? this.lastBoardSize,
      lastIncreasingSpeed: lastIncreasingSpeed ?? this.lastIncreasingSpeed,
      skin: skin ?? this.skin,
      boardTheme: boardTheme ?? this.boardTheme,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'lastMode': lastMode.name,
        'lastBoardSize': lastBoardSize.name,
        'lastIncreasingSpeed': lastIncreasingSpeed,
        'skin': skin.name,
        'boardTheme': boardTheme.name,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      themeMode: _themeModeFrom(json['themeMode'] as String?),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      lastMode: GameMode.values.byName(
        json['lastMode'] as String? ?? GameMode.classic.name,
      ),
      lastBoardSize: BoardSize.values.byName(
        json['lastBoardSize'] as String? ?? BoardSize.medium.name,
      ),
      lastIncreasingSpeed: json['lastIncreasingSpeed'] as bool? ?? false,
      skin: SnakeSkin.values.byName(
        json['skin'] as String? ?? SnakeSkin.classicGreen.name,
      ),
      boardTheme: BoardTheme.values.byName(
        json['boardTheme'] as String? ?? BoardTheme.classic.name,
      ),
    );
  }

  static ThemeMode _themeModeFrom(String? name) {
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
