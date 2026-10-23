import 'package:flutter/material.dart';

import '../core/palette.dart';
import '../models/models.dart';

/// Which triangle of the envelope a tap landed in.
///
/// The two diagonals of [size] are the boundaries, normalized so a wide
/// rectangle still splits corner to corner. A point on a diagonal goes up
/// or down.
Direction directionFromPadOffset(Offset local, Size size) {
  final halfWidth = size.width / 2;
  final halfHeight = size.height / 2;
  if (halfWidth == 0 || halfHeight == 0) return Direction.up;

  final nx = (local.dx - halfWidth) / halfWidth;
  final ny = (local.dy - halfHeight) / halfHeight;
  if (ny.abs() >= nx.abs()) {
    return ny < 0 ? Direction.up : Direction.down;
  }
  return nx < 0 ? Direction.left : Direction.right;
}

/// Wide envelope control. The whole rectangle is the hit target.
class DirectionPad extends StatelessWidget {
  const DirectionPad({
    super.key,
    required this.onDirection,
    this.palette = SnakePalette.dark,
  });

  final ValueChanged<Direction> onDirection;
  final SnakePalette palette;

  static const double cornerRadius = 16;
  static const double _minHeight = 160;
  static const double _maxHeight = 210;
  static const double _heightRatio = 0.58;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _Envelope(
          width: _padWidth(constraints.maxWidth),
          onDirection: onDirection,
          palette: palette,
        );
      },
    );
  }

  static double _padWidth(double maxWidth) {
    if (!maxWidth.isFinite || maxWidth <= 0) return 320;
    return maxWidth;
  }
}

class _Envelope extends StatelessWidget {
  const _Envelope({
    required this.width,
    required this.onDirection,
    required this.palette,
  });

  final double width;
  final ValueChanged<Direction> onDirection;
  final SnakePalette palette;

  @override
  Widget build(BuildContext context) {
    final height = (width * DirectionPad._heightRatio)
        .clamp(DirectionPad._minHeight, DirectionPad._maxHeight)
        .toDouble();
    final size = Size(width, height);

    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          onDirection(directionFromPadOffset(details.localPosition, size));
        },
        child: CustomPaint(
          painter: _EnvelopePainter(palette),
          child: _EnvelopeIcons(palette: palette, height: height),
        ),
      ),
    );
  }
}

class _EnvelopeIcons extends StatelessWidget {
  const _EnvelopeIcons({required this.palette, required this.height});

  final SnakePalette palette;
  final double height;

  @override
  Widget build(BuildContext context) {
    final iconSize = (height * 0.28).clamp(32.0, 48.0);
    final color = palette.ink.withValues(alpha: 0.85);
    return Stack(
      children: [
        _mark(
          const Alignment(0, -2 / 3),
          Icons.keyboard_arrow_up,
          iconSize,
          color,
        ),
        _mark(
          const Alignment(-2 / 3, 0),
          Icons.keyboard_arrow_left,
          iconSize,
          color,
        ),
        _mark(
          const Alignment(2 / 3, 0),
          Icons.keyboard_arrow_right,
          iconSize,
          color,
        ),
        _mark(
          const Alignment(0, 2 / 3),
          Icons.keyboard_arrow_down,
          iconSize,
          color,
        ),
      ],
    );
  }

  Widget _mark(
    Alignment alignment,
    IconData icon,
    double iconSize,
    Color color,
  ) {
    return Align(
      alignment: alignment,
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  const _EnvelopePainter(this.palette);

  final SnakePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(DirectionPad.cornerRadius),
    );
    canvas.drawRRect(shape, Paint()..color = palette.paper);
    canvas.save();
    canvas.clipRRect(shape);
    final line = Paint()
      ..color = palette.ink.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), line);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), line);
    canvas.restore();
    canvas.drawRRect(shape, line);
  }

  @override
  bool shouldRepaint(covariant _EnvelopePainter oldDelegate) {
    return oldDelegate.palette.paper != palette.paper ||
        oldDelegate.palette.ink != palette.ink;
  }
}
