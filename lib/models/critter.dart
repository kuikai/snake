import 'grid_point.dart';

enum CritterKind { mouse, rat, lizard }

/// Rare bonus prey. In-memory only; short-lived.
class Critter {
  const Critter({
    required this.kind,
    required this.position,
    required this.ticksLeft,
  });

  final CritterKind kind;
  final GridPoint position;
  final int ticksLeft;

  Critter copyWith({
    CritterKind? kind,
    GridPoint? position,
    int? ticksLeft,
  }) {
    return Critter(
      kind: kind ?? this.kind,
      position: position ?? this.position,
      ticksLeft: ticksLeft ?? this.ticksLeft,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'position': position.toJson(),
        'ticksLeft': ticksLeft,
      };

  factory Critter.fromJson(Map<String, dynamic> json) {
    return Critter(
      kind: CritterKind.values.byName(json['kind'] as String),
      position: GridPoint.fromJson(
        Map<String, dynamic>.from(json['position'] as Map),
      ),
      ticksLeft: json['ticksLeft'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Critter &&
        other.kind == kind &&
        other.position == position &&
        other.ticksLeft == ticksLeft;
  }

  @override
  int get hashCode => Object.hash(kind, position, ticksLeft);
}
