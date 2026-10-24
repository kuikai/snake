import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake/core/game_config.dart';
import 'package:snake/core/palette.dart';
import 'package:snake/models/models.dart';
import 'package:snake/widgets/snake_board.dart';

void main() {
  test('paints mouse critter to screenshots/critter_mouse.png', () async {
    final state = GameState(
      status: RunStatus.running,
      mode: GameMode.classic,
      boardSize: BoardSize.medium,
      increasingSpeed: false,
      gridSize: GameConfig.mediumGrid,
      snake: const [
        GridPoint(8, 10),
        GridPoint(7, 10),
        GridPoint(6, 10),
        GridPoint(5, 10),
      ],
      direction: Direction.right,
      queuedDirection: null,
      food: const GridPoint(14, 6),
      obstacles: const [],
      score: 4,
      foodEaten: 4,
      tickMs: GameConfig.baseTickMs,
      critter: const Critter(
        kind: CritterKind.mouse,
        position: GridPoint(10, 8),
        ticksLeft: 4,
      ),
      applesUntilCritterRoll: 0,
    );

    const size = Size(360, 360);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    SnakeBoardPainter(
      state: state,
      palette: SnakePalette.dark,
    ).paint(canvas, size);

    final image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    expect(bytes, isNotNull);

    final dir = Directory('screenshots');
    await dir.create(recursive: true);
    final png = bytes!.buffer.asUint8List();
    await File('screenshots/critter_mouse.png').writeAsBytes(png);
    await File('screenshots/latest.png').writeAsBytes(png);
  });
}
