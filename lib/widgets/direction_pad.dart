import 'package:flutter/material.dart';

import '../core/palette.dart';
import '../models/models.dart';

/// Quiet circular D-pad — board should win, not the controls.
class DirectionPad extends StatelessWidget {
  const DirectionPad({
    super.key,
    required this.onDirection,
    this.palette = SnakePalette.dark,
  });

  final ValueChanged<Direction> onDirection;
  final SnakePalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PadButton(
          icon: Icons.keyboard_arrow_up,
          onPressed: () => onDirection(Direction.up),
          palette: palette,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PadButton(
              icon: Icons.keyboard_arrow_left,
              onPressed: () => onDirection(Direction.left),
              palette: palette,
            ),
            const SizedBox(width: 56, height: 56),
            _PadButton(
              icon: Icons.keyboard_arrow_right,
              onPressed: () => onDirection(Direction.right),
              palette: palette,
            ),
          ],
        ),
        _PadButton(
          icon: Icons.keyboard_arrow_down,
          onPressed: () => onDirection(Direction.down),
          palette: palette,
        ),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({
    required this.icon,
    required this.onPressed,
    required this.palette,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final SnakePalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: palette.paper.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 28,
            color: palette.inkSoft.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
