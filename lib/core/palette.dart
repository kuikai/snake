import 'package:flutter/material.dart';

/// Locked Pocket Arcade colors. Do not invent extra brand colors.
final class SnakePalette {
  const SnakePalette({
    required this.cream,
    required this.paper,
    required this.grid,
    required this.ink,
    required this.inkSoft,
    required this.snake,
    required this.snakeHead,
    required this.belly,
    required this.fruit,
    required this.fruitStem,
    required this.play,
    required this.playText,
  });

  final Color cream;
  final Color paper;
  final Color grid;
  final Color ink;
  final Color inkSoft;
  final Color snake;
  final Color snakeHead;
  final Color belly;
  final Color fruit;
  final Color fruitStem;
  final Color play;
  final Color playText;

  static const light = SnakePalette(
    cream: Color(0xFFF3EDE2),
    paper: Color(0xFFE7DCCB),
    grid: Color(0xFFD4C6B0),
    ink: Color(0xFF1C1915),
    inkSoft: Color(0xFF5C554C),
    snake: Color(0xFF2B6B3A),
    snakeHead: Color(0xFF1E4D28),
    belly: Color(0xFF7CB389),
    fruit: Color(0xFFE24B2E),
    fruitStem: Color(0xFF3A6B32),
    play: Color(0xFF1C1915),
    playText: Color(0xFFF3EDE2),
  );

  static const dark = SnakePalette(
    cream: Color(0xFF141814),
    paper: Color(0xFF1C231C),
    grid: Color(0xFF2C362C),
    ink: Color(0xFFEDE6DA),
    inkSoft: Color(0xFFA39B8E),
    snake: Color(0xFF5AA86A),
    snakeHead: Color(0xFFC6E3B0),
    belly: Color(0xFF3E7A4A),
    fruit: Color(0xFFFF6A4A),
    fruitStem: Color(0xFF8FCB84),
    play: Color(0xFFEDE6DA),
    playText: Color(0xFF141814),
  );
}
