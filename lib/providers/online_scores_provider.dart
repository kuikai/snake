import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/online_scores_service.dart';
import 'storage_provider.dart';

final onlineScoresServiceProvider = Provider<OnlineScoresService>((ref) {
  return OnlineScoresService(ref.watch(storageServiceProvider));
});

final onlineScoresPrefsProvider =
    NotifierProvider<OnlineScoresPrefsNotifier, OnlineScoresPrefs>(
  OnlineScoresPrefsNotifier.new,
);

class OnlineScoresPrefsNotifier extends Notifier<OnlineScoresPrefs> {
  @override
  OnlineScoresPrefs build() {
    return ref.read(onlineScoresServiceProvider).loadPrefs();
  }

  Future<void> turnOff() async {
    await ref.read(onlineScoresServiceProvider).setShareOnline(false);
    state = ref.read(onlineScoresServiceProvider).loadPrefs();
  }

  Future<void> turnOnWithNickname(String nickname) async {
    final service = ref.read(onlineScoresServiceProvider);
    await service.setShareOnline(true, nickname: nickname);
    state = service.loadPrefs();

    // Push current local personal bests once on opt-in.
    final bests = ref.read(storageServiceProvider).loadHighScores().bestByKey;
    for (final entry in bests.entries) {
      final parsed = _parseBestKey(entry.key);
      if (parsed == null) continue;
      await service.submitPersonalBest(
        mode: parsed.mode,
        size: parsed.size,
        increasingSpeed: parsed.increasingSpeed,
        score: entry.value,
      );
    }
  }
}

({GameMode mode, BoardSize size, bool increasingSpeed})? _parseBestKey(
  String key,
) {
  final parts = key.split('_');
  if (parts.length < 3) return null;
  final speed = parts.last;
  final sizeKey = parts[parts.length - 2];
  final modeKey = parts.sublist(0, parts.length - 2).join('_');

  GameMode? mode;
  for (final value in GameMode.values) {
    if (value.storageKey == modeKey) mode = value;
  }
  BoardSize? size;
  for (final value in BoardSize.values) {
    if (value.storageKey == sizeKey) size = value;
  }
  if (mode == null || size == null) return null;
  return (
    mode: mode,
    size: size,
    increasingSpeed: speed == 'speed1',
  );
}

class OnlineBoardFilter {
  const OnlineBoardFilter({
    this.mode = GameMode.classic,
    this.size = BoardSize.medium,
    this.increasingSpeed = false,
  });

  final GameMode mode;
  final BoardSize size;
  final bool increasingSpeed;

  OnlineBoardFilter copyWith({
    GameMode? mode,
    BoardSize? size,
    bool? increasingSpeed,
  }) {
    return OnlineBoardFilter(
      mode: mode ?? this.mode,
      size: size ?? this.size,
      increasingSpeed: increasingSpeed ?? this.increasingSpeed,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OnlineBoardFilter &&
        other.mode == mode &&
        other.size == size &&
        other.increasingSpeed == increasingSpeed;
  }

  @override
  int get hashCode => Object.hash(mode, size, increasingSpeed);
}

class OnlineBoardState {
  const OnlineBoardState({
    required this.filter,
    required this.entries,
    required this.status,
    required this.hasMore,
    this.youRank,
    this.youOnBoard = true,
    this.message,
    this.cursor,
  });

  final OnlineBoardFilter filter;
  final List<OnlineScoreEntry> entries;
  final OnlineBoardStatus status;
  final bool hasMore;
  final int? youRank;
  final bool youOnBoard;
  final String? message;
  final DocumentSnapshot? cursor;

  OnlineBoardState copyWith({
    OnlineBoardFilter? filter,
    List<OnlineScoreEntry>? entries,
    OnlineBoardStatus? status,
    bool? hasMore,
    int? youRank,
    bool? youOnBoard,
    String? message,
    DocumentSnapshot? cursor,
    bool clearYou = false,
  }) {
    return OnlineBoardState(
      filter: filter ?? this.filter,
      entries: entries ?? this.entries,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      youRank: clearYou ? null : (youRank ?? this.youRank),
      youOnBoard: youOnBoard ?? this.youOnBoard,
      message: message ?? this.message,
      cursor: cursor,
    );
  }
}

final onlineBoardProvider =
    NotifierProvider<OnlineBoardNotifier, OnlineBoardState>(
  OnlineBoardNotifier.new,
);

class OnlineBoardNotifier extends Notifier<OnlineBoardState> {
  @override
  OnlineBoardState build() {
    return const OnlineBoardState(
      filter: OnlineBoardFilter(),
      entries: [],
      status: OnlineBoardStatus.loading,
      hasMore: false,
    );
  }

  OnlineScoresService get _service => ref.read(onlineScoresServiceProvider);

  Future<void> setFilter(OnlineBoardFilter filter) async {
    state = OnlineBoardState(
      filter: filter,
      entries: const [],
      status: OnlineBoardStatus.loading,
      hasMore: false,
    );
    await refresh();
  }

  Future<void> refresh() async {
    state = OnlineBoardState(
      filter: state.filter,
      entries: const [],
      status: OnlineBoardStatus.loading,
      hasMore: false,
    );

    final result = await _service.fetchPage(
      mode: state.filter.mode,
      size: state.filter.size,
      increasingSpeed: state.filter.increasingSpeed,
      alreadyLoaded: 0,
    );

    final you = await _resolveYou(result.page.entries, result.page.hasMore);

    state = OnlineBoardState(
      filter: state.filter,
      entries: result.page.entries,
      status: result.page.status,
      hasMore: result.page.hasMore,
      youRank: you.rank,
      youOnBoard: you.onBoard,
      message: result.page.message,
      cursor: result.cursor,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == OnlineBoardStatus.loading) return;

    state = state.copyWith(status: OnlineBoardStatus.loading);
    final previous = state.entries;
    final result = await _service.fetchPage(
      mode: state.filter.mode,
      size: state.filter.size,
      increasingSpeed: state.filter.increasingSpeed,
      alreadyLoaded: previous.length,
      cursor: state.cursor,
    );

    final merged = [...previous, ...result.page.entries];
    final you = await _resolveYou(merged, result.page.hasMore);

    state = OnlineBoardState(
      filter: state.filter,
      entries: merged,
      status: result.page.status == OnlineBoardStatus.offline
          ? OnlineBoardStatus.offline
          : OnlineBoardStatus.ready,
      hasMore: result.page.hasMore,
      youRank: you.rank,
      youOnBoard: you.onBoard,
      message: result.page.message,
      cursor: result.cursor,
    );
  }

  Future<({int? rank, bool onBoard})> _resolveYou(
    List<OnlineScoreEntry> entries,
    bool hasMore,
  ) async {
    final uid = _service.currentUid;
    if (uid != null) {
      for (final entry in entries) {
        if (entry.uid == uid) {
          return (rank: entry.rank, onBoard: true);
        }
      }
    }

    final mine = await _service.fetchMyScore(
      mode: state.filter.mode,
      size: state.filter.size,
      increasingSpeed: state.filter.increasingSpeed,
    );
    if (mine == null) return (rank: null, onBoard: true);

    final inList = uid != null && entries.any((e) => e.uid == uid);
    if (inList) {
      final rank = entries.firstWhere((e) => e.uid == uid).rank;
      return (rank: rank, onBoard: true);
    }

    if (!hasMore || entries.length >= OnlineScoresService.maxRank) {
      final outside = await _service.isOutsideTopThousand(
        mode: state.filter.mode,
        size: state.filter.size,
        increasingSpeed: state.filter.increasingSpeed,
        myScore: mine.score,
      );
      if (outside || !hasMore) {
        return (rank: null, onBoard: false);
      }
    }

    return (rank: null, onBoard: true);
  }
}

void maybeSubmitOnlineBest(Ref ref, GameState game, bool isPersonalBest) {
  if (!isPersonalBest) return;
  unawaited(
    ref.read(onlineScoresServiceProvider).submitPersonalBest(
          mode: game.mode,
          size: game.boardSize,
          increasingSpeed: game.increasingSpeed,
          score: game.score,
        ),
  );
}
