import 'enums.dart';

class GameRun {
  const GameRun({
    required this.id,
    required this.finishedAt,
    required this.mode,
    required this.boardSize,
    required this.increasingSpeed,
    required this.score,
    required this.foodEaten,
    required this.isPersonalBest,
  });

  final String id;
  final DateTime finishedAt;
  final GameMode mode;
  final BoardSize boardSize;
  final bool increasingSpeed;
  final int score;
  final int foodEaten;
  final bool isPersonalBest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'finishedAt': finishedAt.toIso8601String(),
        'mode': mode.name,
        'boardSize': boardSize.name,
        'increasingSpeed': increasingSpeed,
        'score': score,
        'foodEaten': foodEaten,
        'isPersonalBest': isPersonalBest,
      };

  factory GameRun.fromJson(Map<String, dynamic> json) {
    return GameRun(
      id: json['id'] as String,
      finishedAt: DateTime.parse(json['finishedAt'] as String),
      mode: GameMode.values.byName(json['mode'] as String),
      boardSize: BoardSize.values.byName(json['boardSize'] as String),
      increasingSpeed: json['increasingSpeed'] as bool,
      score: json['score'] as int,
      foodEaten: json['foodEaten'] as int,
      isPersonalBest: json['isPersonalBest'] as bool,
    );
  }
}
