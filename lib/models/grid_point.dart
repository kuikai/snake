import 'enums.dart';

class GridPoint {
  const GridPoint(this.x, this.y);

  final int x;
  final int y;

  GridPoint moved(Direction direction) {
    switch (direction) {
      case Direction.up:
        return GridPoint(x, y - 1);
      case Direction.down:
        return GridPoint(x, y + 1);
      case Direction.left:
        return GridPoint(x - 1, y);
      case Direction.right:
        return GridPoint(x + 1, y);
    }
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory GridPoint.fromJson(Map<String, dynamic> json) {
    return GridPoint(json['x'] as int, json['y'] as int);
  }

  @override
  bool operator ==(Object other) {
    return other is GridPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'GridPoint($x, $y)';
}
