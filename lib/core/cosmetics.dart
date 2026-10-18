import 'package:flutter/material.dart';

import '../models/models.dart';
import 'palette.dart';

class BoardPalette {
  const BoardPalette({
    required this.board,
    required this.grid,
    required this.obstacle,
    required this.food,
  });

  final Color board;
  final Color grid;
  final Color obstacle;
  final Color food;
}

class SkinPalette {
  const SkinPalette({
    required this.head,
    required this.body,
  });

  final Color head;
  final Color body;
}

abstract final class Cosmetics {
  /// Pocket Arcade base + Pro skin / board theme.
  /// Remaps snake, paper, and grid only — fruit always stays [base] fruit.
  static SnakePalette playPalette({
    required SnakePalette base,
    required SnakeSkin skin,
    required BoardTheme boardTheme,
  }) {
    var paper = base.paper;
    var grid = base.grid;
    var snake = base.snake;
    var snakeHead = base.snakeHead;

    if (skin != SnakeSkin.classicGreen) {
      final skinColors = skinPalette(skin);
      snake = skinColors.body;
      snakeHead = skinColors.head;
    }

    if (boardTheme != BoardTheme.classic) {
      final board = boardPalette(boardTheme);
      paper = board.board;
      grid = board.grid;
    }

    return SnakePalette(
      cream: base.cream,
      paper: paper,
      grid: grid,
      ink: base.ink,
      inkSoft: base.inkSoft,
      snake: snake,
      snakeHead: snakeHead,
      belly: base.belly,
      fruit: base.fruit,
      fruitStem: base.fruitStem,
      play: base.play,
      playText: base.playText,
    );
  }

  /// Obstacle fill for non-classic board themes; null → painter fallback.
  static Color? obstacleColor(BoardTheme boardTheme) {
    if (boardTheme == BoardTheme.classic) return null;
    return boardPalette(boardTheme).obstacle;
  }

  static SkinPalette skinPalette(SnakeSkin skin) {
    switch (skin) {
      case SnakeSkin.classicGreen:
        return const SkinPalette(
          head: Color(0xFF2E7D32),
          body: Color(0xFF66BB6A),
        );
      case SnakeSkin.ember:
        return const SkinPalette(
          head: Color(0xFFC62828),
          body: Color(0xFFEF6C00),
        );
      case SnakeSkin.ocean:
        return const SkinPalette(
          head: Color(0xFF1565C0),
          body: Color(0xFF29B6F6),
        );
      case SnakeSkin.mono:
        return const SkinPalette(
          head: Color(0xFF212121),
          body: Color(0xFF757575),
        );
      case SnakeSkin.neon:
        return const SkinPalette(
          head: Color(0xFF00E676),
          body: Color(0xFF76FF03),
        );
    }
  }

  static BoardPalette boardPalette(BoardTheme theme) {
    switch (theme) {
      case BoardTheme.classic:
        return const BoardPalette(
          board: Color(0xFFE8F5E9),
          grid: Color(0x332E7D32),
          obstacle: Color(0xFF5D4037),
          food: Color(0xFFD32F2F),
        );
      case BoardTheme.midnight:
        return const BoardPalette(
          board: Color(0xFF1A237E),
          grid: Color(0x33FFFFFF),
          obstacle: Color(0xFF90A4AE),
          food: Color(0xFFFF4081),
        );
      case BoardTheme.sand:
        return const BoardPalette(
          board: Color(0xFFFFF8E1),
          grid: Color(0x338D6E63),
          obstacle: Color(0xFF6D4C41),
          food: Color(0xFFE65100),
        );
      case BoardTheme.highContrast:
        return const BoardPalette(
          board: Color(0xFFFFFFFF),
          grid: Color(0xFF000000),
          obstacle: Color(0xFF000000),
          food: Color(0xFFFFD600),
        );
      case BoardTheme.forest:
        return const BoardPalette(
          board: Color(0xFF1B5E20),
          grid: Color(0x33A5D6A7),
          obstacle: Color(0xFF3E2723),
          food: Color(0xFFFFEE58),
        );
    }
  }

  static String modeLabel(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.wrap:
        return 'Wrap';
      case GameMode.noWalls:
        return 'No Walls';
      case GameMode.obstacles:
        return 'Obstacles';
    }
  }

  static String sizeLabel(BoardSize size) {
    switch (size) {
      case BoardSize.small:
        return 'Small';
      case BoardSize.medium:
        return 'Medium';
      case BoardSize.large:
        return 'Large';
    }
  }

  static String skinLabel(SnakeSkin skin) {
    switch (skin) {
      case SnakeSkin.classicGreen:
        return 'Classic Green';
      case SnakeSkin.ember:
        return 'Ember';
      case SnakeSkin.ocean:
        return 'Ocean';
      case SnakeSkin.mono:
        return 'Mono';
      case SnakeSkin.neon:
        return 'Neon';
    }
  }

  static String boardThemeLabel(BoardTheme theme) {
    switch (theme) {
      case BoardTheme.classic:
        return 'Classic';
      case BoardTheme.midnight:
        return 'Midnight';
      case BoardTheme.sand:
        return 'Sand';
      case BoardTheme.highContrast:
        return 'High Contrast';
      case BoardTheme.forest:
        return 'Forest';
    }
  }
}
