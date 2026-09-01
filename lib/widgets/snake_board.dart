import 'package:flutter/material.dart';

import '../core/palette.dart';
import '../models/models.dart';

/// Pocket Arcade board painter — dark Game face from UI personality §11.
class SnakeBoardPainter extends CustomPainter {
  SnakeBoardPainter({
    required this.state,
    required this.palette,
  });

  final GameState state;
  final SnakePalette palette;

  static const _boardRadius = 20.0;
  static const _gap = 2.0;
  static const _cellCorner = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / state.gridSize;
    final boardRect = Offset.zero & size;
    final boardRRect = RRect.fromRectAndRadius(
      boardRect,
      const Radius.circular(_boardRadius),
    );

    canvas.save();
    canvas.clipRRect(boardRRect);

    canvas.drawRRect(boardRRect, Paint()..color = palette.paper);

    final gridPaint = Paint()
      ..color = palette.grid.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (var i = 1; i < state.gridSize; i++) {
      final offset = i * cell;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    final inset = _gap / 2;

    for (final obstacle in state.obstacles) {
      _drawSegment(
        canvas,
        obstacle,
        cell,
        inset,
        Paint()..color = palette.inkSoft.withValues(alpha: 0.55),
      );
    }

    for (var i = state.snake.length - 1; i >= 1; i--) {
      _drawSegment(
        canvas,
        state.snake[i],
        cell,
        inset,
        Paint()..color = palette.snake,
      );
    }

    if (state.snake.isNotEmpty) {
      final head = state.snake.first;
      _drawSegment(
        canvas,
        head,
        cell,
        inset,
        Paint()..color = palette.snakeHead,
      );
      _drawEyes(canvas, head, cell, state.direction);
    }

    _drawFruit(canvas, state.food, cell);

    canvas.restore();
  }

  void _drawSegment(
    Canvas canvas,
    GridPoint point,
    double cell,
    double inset,
    Paint paint,
  ) {
    final rect = Rect.fromLTWH(
      point.x * cell + inset,
      point.y * cell + inset,
      cell - inset * 2,
      cell - inset * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(_cellCorner)),
      paint,
    );
  }

  void _drawEyes(
    Canvas canvas,
    GridPoint head,
    double cell,
    Direction direction,
  ) {
    final center = Offset(
      (head.x + 0.5) * cell,
      (head.y + 0.5) * cell,
    );

    final Offset along;
    final Offset across;
    switch (direction) {
      case Direction.up:
        along = Offset(0, -cell * 0.16);
        across = Offset(cell * 0.16, 0);
      case Direction.down:
        along = Offset(0, cell * 0.16);
        across = Offset(cell * 0.16, 0);
      case Direction.left:
        along = Offset(-cell * 0.16, 0);
        across = Offset(0, cell * 0.16);
      case Direction.right:
        along = Offset(cell * 0.16, 0);
        across = Offset(0, cell * 0.16);
    }

    final pupil = Paint()..color = palette.cream;
    final radius = cell * 0.075;
    canvas.drawCircle(center + along - across, radius, pupil);
    canvas.drawCircle(center + along + across, radius, pupil);
  }

  void _drawFruit(Canvas canvas, GridPoint food, double cell) {
    final center = Offset(
      (food.x + 0.5) * cell,
      (food.y + 0.5) * cell,
    );
    final radius = cell * 0.42;

    canvas.drawCircle(center, radius, Paint()..color = palette.fruit);

    // Tiny stem — reads as fruit in ~200ms.
    final stem = Paint()
      ..color = palette.fruitStem
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 1),
      Offset(center.dx, center.dy - radius - cell * 0.1),
      stem,
    );
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) {
    return oldDelegate.state != state || oldDelegate.palette != palette;
  }
}

class SnakeBoard extends StatelessWidget {
  const SnakeBoard({
    super.key,
    required this.state,
    this.palette = SnakePalette.dark,
  });

  final GameState state;
  final SnakePalette palette;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CustomPaint(
            painter: SnakeBoardPainter(
              state: state,
              palette: palette,
            ),
          ),
        ),
      ),
    );
  }
}
