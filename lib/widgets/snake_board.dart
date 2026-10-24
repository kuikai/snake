import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/game_config.dart';
import '../core/palette.dart';
import '../game/smooth_move.dart';
import '../models/models.dart';

/// Pocket Arcade board painter — dark Game face from UI personality §11.
class SnakeBoardPainter extends CustomPainter {
  SnakeBoardPainter({
    required this.state,
    required this.palette,
    this.obstacleColor,
    this.smoothMove = false,
    this.lerpT = 1,
    this.previousSnake,
  });

  final GameState state;
  final SnakePalette palette;
  final Color? obstacleColor;
  final bool smoothMove;
  final double lerpT;
  final List<GridPoint>? previousSnake;

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

    final obstaclePaint = Paint()
      ..color = obstacleColor ?? palette.inkSoft.withValues(alpha: 0.55);
    for (final obstacle in state.obstacles) {
      _drawSegment(canvas, obstacle.x.toDouble(), obstacle.y.toDouble(), cell,
          inset, obstaclePaint);
    }

    _drawSnake(canvas, cell, inset);

    _drawFruit(canvas, state.food, cell);

    final critter = state.critter;
    if (critter != null) {
      _drawCritter(canvas, critter, cell);
    }

    canvas.restore();
  }

  void _drawSnake(Canvas canvas, double cell, double inset) {
    if (state.snake.isEmpty) return;

    final bodyPaint = Paint()..color = palette.snake;
    final headPaint = Paint()..color = palette.snakeHead;
    final wrap = state.mode == GameMode.wrap;
    final previous = previousSnake;
    final useLerp = smoothMove && previous != null && lerpT < 1;

    for (var i = state.snake.length - 1; i >= 1; i--) {
      final pos = _segmentPos(i, previous, useLerp, wrap);
      _drawSegmentCopies(canvas, pos.x, pos.y, cell, inset, bodyPaint);
    }

    final headPos = _segmentPos(0, previous, useLerp, wrap);
    _drawSegmentCopies(canvas, headPos.x, headPos.y, cell, inset, headPaint);
    for (final pos in paintCellPositions(
      x: headPos.x,
      y: headPos.y,
      gridSize: state.gridSize,
    )) {
      _drawEyesAt(canvas, pos.x, pos.y, cell, state.direction);
    }
  }

  ({double x, double y}) _segmentPos(
    int index,
    List<GridPoint>? previous,
    bool useLerp,
    bool wrap,
  ) {
    final to = state.snake[index];
    if (!useLerp || previous == null) {
      return (x: to.x.toDouble(), y: to.y.toDouble());
    }
    final from = previousCellForSegment(
      previous: previous,
      current: state.snake,
      index: index,
    );
    return lerpCell(
      from: from,
      to: to,
      t: lerpT,
      gridSize: state.gridSize,
      wrap: wrap,
    );
  }

  void _drawSegmentCopies(
    Canvas canvas,
    double x,
    double y,
    double cell,
    double inset,
    Paint paint,
  ) {
    for (final pos in paintCellPositions(
      x: x,
      y: y,
      gridSize: state.gridSize,
    )) {
      _drawSegment(canvas, pos.x, pos.y, cell, inset, paint);
    }
  }

  void _drawSegment(
    Canvas canvas,
    double x,
    double y,
    double cell,
    double inset,
    Paint paint,
  ) {
    final rect = Rect.fromLTWH(
      x * cell + inset,
      y * cell + inset,
      cell - inset * 2,
      cell - inset * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(_cellCorner)),
      paint,
    );
  }

  void _drawEyesAt(
    Canvas canvas,
    double headX,
    double headY,
    double cell,
    Direction direction,
  ) {
    final center = Offset(
      (headX + 0.5) * cell,
      (headY + 0.5) * cell,
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

  void _drawCritter(Canvas canvas, Critter critter, double cell) {
    final center = Offset(
      (critter.position.x + 0.5) * cell,
      (critter.position.y + 0.5) * cell,
    );

    switch (critter.kind) {
      case CritterKind.mouse:
        _drawRodent(
          canvas,
          center,
          cell,
          body: const Color(0xFF8B7355),
          scale: 1.56,
        );
      case CritterKind.rat:
        _drawRodent(
          canvas,
          center,
          cell,
          body: const Color(0xFF6B5A48),
          scale: 1.84,
        );
      case CritterKind.lizard:
        _drawLizard(canvas, center, cell);
    }

    _drawCritterLifeTicks(canvas, center, cell, critter.ticksLeft);
  }

  void _drawRodent(
    Canvas canvas,
    Offset center,
    double cell, {
    required Color body,
    required double scale,
  }) {
    final paint = Paint()..color = body;
    final ear = Paint()..color = body.withValues(alpha: 0.85);
    final bodyR = cell * 0.28 * scale;

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, cell * 0.04),
        width: bodyR * 2.1,
        height: bodyR * 1.55,
      ),
      paint,
    );

    final head = center.translate(cell * 0.16 * scale, -cell * 0.06);
    canvas.drawCircle(head, bodyR * 0.72, paint);

    final earR = bodyR * 0.38;
    canvas.drawCircle(
      head.translate(-earR * 0.9, -earR * 1.35),
      earR,
      ear,
    );
    canvas.drawCircle(
      head.translate(earR * 0.55, -earR * 1.45),
      earR,
      ear,
    );

    final tail = Paint()
      ..color = body
      ..strokeWidth = cell * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailStart = center.translate(-bodyR * 0.95, cell * 0.06);
    canvas.drawPath(
      Path()
        ..moveTo(tailStart.dx, tailStart.dy)
        ..quadraticBezierTo(
          tailStart.dx - cell * 0.22 * scale,
          tailStart.dy + cell * 0.12,
          tailStart.dx - cell * 0.32 * scale,
          tailStart.dy - cell * 0.02,
        ),
      tail,
    );
  }

  void _drawLizard(Canvas canvas, Offset center, double cell) {
    // Olive distinct from classic green snake body. Drawn at 2× cell size.
    const bodyColor = Color(0xFF7A8F3E);
    final unit = cell * 2;
    final paint = Paint()..color = bodyColor;
    final leg = Paint()
      ..color = bodyColor
      ..strokeWidth = unit * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: unit * 0.58,
        height: unit * 0.28,
      ),
      paint,
    );
    canvas.drawCircle(center.translate(unit * 0.22, 0), unit * 0.14, paint);

    // Tiny legs — reads as lizard, not snake.
    canvas.drawLine(
      center.translate(-unit * 0.08, unit * 0.06),
      center.translate(-unit * 0.18, unit * 0.2),
      leg,
    );
    canvas.drawLine(
      center.translate(unit * 0.06, unit * 0.06),
      center.translate(unit * 0.16, unit * 0.2),
      leg,
    );
    canvas.drawLine(
      center.translate(-unit * 0.08, -unit * 0.06),
      center.translate(-unit * 0.16, -unit * 0.18),
      leg,
    );
    canvas.drawLine(
      center.translate(unit * 0.06, -unit * 0.06),
      center.translate(unit * 0.14, -unit * 0.18),
      leg,
    );

    final tail = Paint()
      ..color = bodyColor
      ..strokeWidth = unit * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      center.translate(-unit * 0.26, 0),
      center.translate(-unit * 0.4, unit * 0.06),
      tail,
    );
  }

  void _drawCritterLifeTicks(
    Canvas canvas,
    Offset center,
    double cell,
    int ticksLeft,
  ) {
    final paint = Paint()..color = palette.inkSoft.withValues(alpha: 0.7);
    final count = GameConfig.critterLifetimeTicks;
    const gap = 0.1;
    // Sit just under the 2× body. Lizard legs reach about 0.4 cells down.
    final startX = center.dx - (count - 1) * cell * gap / 2;
    final y = center.dy + cell * 0.62;
    for (var i = 0; i < count; i++) {
      final filled = i < ticksLeft;
      canvas.drawCircle(
        Offset(startX + i * cell * 0.1, y),
        cell * 0.035,
        Paint()
          ..color = filled
              ? paint.color
              : palette.inkSoft.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.palette != palette ||
        oldDelegate.obstacleColor != obstacleColor ||
        oldDelegate.smoothMove != smoothMove ||
        oldDelegate.lerpT != lerpT ||
        !listEquals(oldDelegate.previousSnake, previousSnake);
  }
}

class SnakeBoard extends StatefulWidget {
  const SnakeBoard({
    super.key,
    required this.state,
    this.palette = SnakePalette.dark,
    this.obstacleColor,
    this.smoothMove = false,
  });

  final GameState state;
  final SnakePalette palette;
  final Color? obstacleColor;
  final bool smoothMove;

  @override
  State<SnakeBoard> createState() => _SnakeBoardState();
}

class _SnakeBoardState extends State<SnakeBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<GridPoint>? _fromSnake;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.state.tickMs),
    );
    _controller.addListener(() {
      if (widget.smoothMove) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SnakeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = Duration(milliseconds: widget.state.tickMs);

    if (!widget.smoothMove) {
      _fromSnake = null;
      _controller.stop();
      _controller.value = 1;
      return;
    }

    final snakeChanged =
        !listEquals(oldWidget.state.snake, widget.state.snake);
    if (snakeChanged) {
      _fromSnake = List<GridPoint>.from(oldWidget.state.snake);
      _controller.forward(from: 0);
      if (widget.state.status != RunStatus.running) {
        _controller.stop();
      }
    } else if (oldWidget.state.status == RunStatus.running &&
        widget.state.status == RunStatus.paused) {
      _controller.stop();
    } else if (oldWidget.state.status == RunStatus.paused &&
        widget.state.status == RunStatus.running) {
      if (_controller.value < 1) {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lerpT = widget.smoothMove ? _controller.value : 1.0;
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
              state: widget.state,
              palette: widget.palette,
              obstacleColor: widget.obstacleColor,
              smoothMove: widget.smoothMove,
              lerpT: lerpT,
              previousSnake: widget.smoothMove ? _fromSnake : null,
            ),
          ),
        ),
      ),
    );
  }
}
