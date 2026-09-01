import 'enums.dart';
import 'game_run.dart';

class HighScoreKey {
  const HighScoreKey({
    required this.mode,
    required this.size,
    required this.increasingSpeed,
  });

  final GameMode mode;
  final BoardSize size;
  final bool increasingSpeed;

  /// Format: `classic_medium_speed0`
  String get storageKey =>
      '${mode.storageKey}_${size.storageKey}_speed${increasingSpeed ? 1 : 0}';

  @override
  bool operator ==(Object other) {
    return other is HighScoreKey &&
        other.mode == mode &&
        other.size == size &&
        other.increasingSpeed == increasingSpeed;
  }

  @override
  int get hashCode => Object.hash(mode, size, increasingSpeed);
}

class HighScores {
  const HighScores({
    this.classicBest = 0,
    this.bestByKey = const {},
    this.recent = const [],
  });

  final int classicBest;
  final Map<String, int> bestByKey;
  final List<GameRun> recent;

  HighScores copyWith({
    int? classicBest,
    Map<String, int>? bestByKey,
    List<GameRun>? recent,
  }) {
    return HighScores(
      classicBest: classicBest ?? this.classicBest,
      bestByKey: bestByKey ?? this.bestByKey,
      recent: recent ?? this.recent,
    );
  }

  Map<String, dynamic> toJson() => {
        'classicBest': classicBest,
        'bestByKey': bestByKey,
        'recent': recent.map((run) => run.toJson()).toList(),
      };

  factory HighScores.fromJson(Map<String, dynamic> json) {
    final rawBest = json['bestByKey'];
    final bestByKey = <String, int>{};
    if (rawBest is Map) {
      rawBest.forEach((key, value) {
        if (key is String && value is int) {
          bestByKey[key] = value;
        }
      });
    }

    final rawRecent = json['recent'];
    final recent = <GameRun>[];
    if (rawRecent is List) {
      for (final item in rawRecent) {
        if (item is Map<String, dynamic>) {
          recent.add(GameRun.fromJson(item));
        } else if (item is Map) {
          recent.add(GameRun.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return HighScores(
      classicBest: json['classicBest'] as int? ?? 0,
      bestByKey: bestByKey,
      recent: recent,
    );
  }
}
