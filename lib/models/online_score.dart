import 'enums.dart';

class OnlineScoreEntry {
  const OnlineScoreEntry({
    required this.uid,
    required this.nickname,
    required this.mode,
    required this.size,
    required this.increasingSpeed,
    required this.score,
    required this.updatedAt,
    required this.rank,
  });

  final String uid;
  final String nickname;
  final GameMode mode;
  final BoardSize size;
  final bool increasingSpeed;
  final int score;
  final DateTime updatedAt;
  final int rank;

  bool isYou(String? myUid) => myUid != null && myUid == uid;
}

enum OnlineBoardStatus {
  ready,
  loading,
  empty,
  offline,
  stub,
  error,
}

class OnlineBoardPage {
  const OnlineBoardPage({
    required this.entries,
    required this.status,
    required this.hasMore,
    required this.loadedCount,
    this.youRank,
    this.youOnBoard = true,
    this.message,
  });

  final List<OnlineScoreEntry> entries;
  final OnlineBoardStatus status;
  final bool hasMore;
  final int loadedCount;

  /// Null when the player has no submitted score for this key.
  final int? youRank;

  /// False when the player has a score but is outside the top 1000.
  final bool youOnBoard;
  final String? message;

  static const empty = OnlineBoardPage(
    entries: [],
    status: OnlineBoardStatus.empty,
    hasMore: false,
    loadedCount: 0,
  );
}

class OnlineScoresPrefs {
  const OnlineScoresPrefs({
    this.shareOnline = false,
    this.nickname,
  });

  final bool shareOnline;
  final String? nickname;

  OnlineScoresPrefs copyWith({
    bool? shareOnline,
    String? nickname,
    bool clearNickname = false,
  }) {
    return OnlineScoresPrefs(
      shareOnline: shareOnline ?? this.shareOnline,
      nickname: clearNickname ? null : (nickname ?? this.nickname),
    );
  }
}
