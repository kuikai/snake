import 'package:flutter_test/flutter_test.dart';
import 'package:snake/game/smooth_move.dart';
import 'package:snake/models/models.dart';

void main() {
  group('smooth move lerp', () {
    test('defaults missing persist key to off', () {
      final settings = GameSettings.fromJson({
        'themeMode': 'system',
        'soundEnabled': true,
        'hapticsEnabled': true,
      });
      expect(settings.smoothMove, isFalse);
    });

    test('non-wrap steps one cell', () {
      final mid = lerpCell(
        from: const GridPoint(4, 5),
        to: const GridPoint(5, 5),
        t: 0.5,
        gridSize: 20,
        wrap: false,
      );
      expect(mid.x, 4.5);
      expect(mid.y, 5);
    });

    test('wrap right does not cross the board', () {
      const grid = 20;
      final mid = lerpCell(
        from: const GridPoint(19, 5),
        to: const GridPoint(0, 5),
        t: 0.5,
        gridSize: grid,
        wrap: true,
      );
      expect(mid.x, 19.5);
      expect(mid.y, 5);

      final copies = paintCellPositions(x: mid.x, y: mid.y, gridSize: grid);
      expect(copies, hasLength(2));
      expect(copies.map((p) => p.x), containsAll(<double>[19.5, -0.5]));
    });

    test('wrap left does not cross the board', () {
      const grid = 20;
      final mid = lerpCell(
        from: const GridPoint(0, 7),
        to: const GridPoint(19, 7),
        t: 0.5,
        gridSize: grid,
        wrap: true,
      );
      expect(mid.x, -0.5);
      expect(mid.y, 7);
    });

    test('growing tail stays on its cell', () {
      const previous = [
        GridPoint(5, 5),
        GridPoint(4, 5),
        GridPoint(3, 5),
      ];
      const current = [
        GridPoint(6, 5),
        GridPoint(5, 5),
        GridPoint(4, 5),
        GridPoint(3, 5),
      ];
      expect(
        previousCellForSegment(previous: previous, current: current, index: 3),
        const GridPoint(3, 5),
      );
    });
  });
}
