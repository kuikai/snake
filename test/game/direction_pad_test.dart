import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake/models/models.dart';
import 'package:snake/widgets/direction_pad.dart';

void main() {
  const size = Size(200, 120);

  group('directionFromPadOffset', () {
    test('above center is up', () {
      expect(directionFromPadOffset(const Offset(100, 20), size), Direction.up);
    });

    test('left of center is left', () {
      expect(
        directionFromPadOffset(const Offset(20, 60), size),
        Direction.left,
      );
    });

    test('a diagonal corner resolves upward', () {
      expect(directionFromPadOffset(Offset.zero, size), Direction.up);
    });

    test('a corner pocket inside the left triangle is left', () {
      expect(directionFromPadOffset(const Offset(8, 50), size), Direction.left);
    });

    test('below center is down and right of center is right', () {
      expect(
        directionFromPadOffset(const Offset(100, 100), size),
        Direction.down,
      );
      expect(
        directionFromPadOffset(const Offset(180, 60), size),
        Direction.right,
      );
    });
  });
}
