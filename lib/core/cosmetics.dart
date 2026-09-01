import 'package:flutter/material.dart';

import '../models/models.dart';

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

class SnakePalette {
  const SnakePalette({
    required this.head,
    required this.body,
  });

  final Color head;
  final Color body;
}

abstract final class Cosmetics {
  static SnakePalette snakePalette(SnakeSkin skin) {
    switch (skin) {
      case SnakeSkin.classicGreen:
        return const SnakePalette(
          head: Color(0xFF2E7D32),
          body: Color(0xFF66BB6A),
        );
      case SnakeSkin.ember:
        return const SnakePalette(
          head: Color(0xFFC62828),
          body: Color(0xFFEF6C00),
        );
      case SnakeSkin.ocean:
        return const SnakePalette(
          head: Color(0xFF1565C0),
          body: Color(0xFF29B6F6),
        );
      case SnakeSkin.mono:
        return const SnakePalette(
          head: Color(0xFF212121),
          body: Color(0xFF757575),
        );
      case SnakeSkin.neon:
        return const SnakePalette(
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
