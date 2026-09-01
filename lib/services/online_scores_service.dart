import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/firebase_bootstrap.dart';
import '../models/models.dart';
import 'storage_service.dart';

/// Optional Pro online board. Local scores stay authoritative.
class OnlineScoresService {
  OnlineScoresService(this._storage);

  final StorageService _storage;

  static const pageSize = 50;
  static const maxRank = 1000;
  static const collection = 'scores';

  bool get isConfigured => FirebaseBootstrap.isConfigured;

  OnlineScoresPrefs loadPrefs() => _storage.loadOnlineScoresPrefs();

  Future<void> savePrefs(OnlineScoresPrefs prefs) =>
      _storage.saveOnlineScoresPrefs(prefs);

  String docId({
    required String uid,
    required GameMode mode,
    required BoardSize size,
    required bool increasingSpeed,
  }) {
    final speed = increasingSpeed ? 'speed1' : 'speed0';
    return '${uid}_${mode.storageKey}_${size.storageKey}_$speed';
  }

  /// Init Firebase + anonymous auth only when configured and sharing is on.
  Future<String?> ensureAnonymousUser() async {
    final prefs = loadPrefs();
    if (!prefs.shareOnline) return null;
    if (!await FirebaseBootstrap.ensureInitialized()) return null;

    final auth = FirebaseAuth.instance;
    final existing = auth.currentUser;
    if (existing != null) return existing.uid;

    try {
      final credential = await auth.signInAnonymously();
      return credential.user?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> setShareOnline(bool enabled, {String? nickname}) async {
    final current = loadPrefs();
    if (!enabled) {
      await savePrefs(current.copyWith(shareOnline: false));
      return;
    }

    final name = (nickname ?? current.nickname)?.trim();
    await savePrefs(
      current.copyWith(
        shareOnline: true,
        nickname: name,
      ),
    );
    await ensureAnonymousUser();
  }

  Future<void> setNickname(String nickname) async {
    final current = loadPrefs();
    await savePrefs(current.copyWith(nickname: nickname.trim()));
  }

  /// Submit only on personal-best beats, and only while opted in.
  Future<void> submitPersonalBest({
    required GameMode mode,
    required BoardSize size,
    required bool increasingSpeed,
    required int score,
  }) async {
    final prefs = loadPrefs();
    if (!prefs.shareOnline) return;
    final nickname = prefs.nickname?.trim();
    if (nickname == null || nickname.length < 3) return;

    final uid = await ensureAnonymousUser();
    if (uid == null) return;
    if (!FirebaseBootstrap.isInitialized) return;

    final id = docId(
      uid: uid,
      mode: mode,
      size: size,
      increasingSpeed: increasingSpeed,
    );

    try {
      final ref = FirebaseFirestore.instance.collection(collection).doc(id);
      final existing = await ref.get();
      if (existing.exists) {
        final previous = (existing.data()?['score'] as num?)?.toInt() ?? 0;
        if (score <= previous) return;
      }

      await ref.set({
        'uid': uid,
        'nickname': nickname,
        'mode': mode.storageKey,
        'size': size.storageKey,
        'increasingSpeed': increasingSpeed,
        'score': score,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Offline / stub / rules — never block play.
    }
  }

  Future<({OnlineBoardPage page, DocumentSnapshot? cursor})> fetchPage({
    required GameMode mode,
    required BoardSize size,
    required bool increasingSpeed,
    required int alreadyLoaded,
    DocumentSnapshot? cursor,
  }) async {
    if (!isConfigured) {
      return (
        page: const OnlineBoardPage(
          entries: [],
          status: OnlineBoardStatus.stub,
          hasMore: false,
          loadedCount: 0,
          message: 'online board not configured yet',
        ),
        cursor: null,
      );
    }

    if (!await FirebaseBootstrap.ensureInitialized()) {
      return (
        page: const OnlineBoardPage(
          entries: [],
          status: OnlineBoardStatus.offline,
          hasMore: false,
          loadedCount: 0,
          message: 'offline. local bests still count.',
        ),
        cursor: null,
      );
    }

    if (alreadyLoaded >= maxRank) {
      return (
        page: OnlineBoardPage(
          entries: const [],
          status: OnlineBoardStatus.ready,
          hasMore: false,
          loadedCount: alreadyLoaded,
        ),
        cursor: cursor,
      );
    }

    final remaining = maxRank - alreadyLoaded;
    final limit = remaining < pageSize ? remaining : pageSize;

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(collection)
          .where('mode', isEqualTo: mode.storageKey)
          .where('size', isEqualTo: size.storageKey)
          .where('increasingSpeed', isEqualTo: increasingSpeed)
          .orderBy('score', descending: true)
          .limit(limit);

      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }

      final snap = await query.get();
      final entries = <OnlineScoreEntry>[];
      for (var i = 0; i < snap.docs.length; i++) {
        final data = snap.docs[i].data();
        entries.add(_entryFrom(data, alreadyLoaded + i + 1));
      }

      final loadedCount = alreadyLoaded + entries.length;
      final hasMore = snap.docs.length == limit && loadedCount < maxRank;
      final nextCursor = snap.docs.isEmpty ? cursor : snap.docs.last;

      if (entries.isEmpty && alreadyLoaded == 0) {
        return (
          page: const OnlineBoardPage(
            entries: [],
            status: OnlineBoardStatus.empty,
            hasMore: false,
            loadedCount: 0,
            message: 'no scores yet',
          ),
          cursor: null,
        );
      }

      return (
        page: OnlineBoardPage(
          entries: entries,
          status: OnlineBoardStatus.ready,
          hasMore: hasMore,
          loadedCount: loadedCount,
        ),
        cursor: nextCursor,
      );
    } catch (_) {
      return (
        page: OnlineBoardPage(
          entries: const [],
          status: OnlineBoardStatus.offline,
          hasMore: false,
          loadedCount: alreadyLoaded,
          message: 'offline. local bests still count.',
        ),
        cursor: cursor,
      );
    }
  }

  Future<OnlineScoreEntry?> fetchMyScore({
    required GameMode mode,
    required BoardSize size,
    required bool increasingSpeed,
  }) async {
    if (!await FirebaseBootstrap.ensureInitialized()) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final id = docId(
        uid: uid,
        mode: mode,
        size: size,
        increasingSpeed: increasingSpeed,
      );
      final mine =
          await FirebaseFirestore.instance.collection(collection).doc(id).get();
      if (!mine.exists) return null;
      return _entryFrom(mine.data()!, 0);
    } catch (_) {
      return null;
    }
  }

  /// True when [myScore] cannot fit in the public top 1000 for this key.
  Future<bool> isOutsideTopThousand({
    required GameMode mode,
    required BoardSize size,
    required bool increasingSpeed,
    required int myScore,
  }) async {
    if (!FirebaseBootstrap.isInitialized) return false;
    try {
      final snap = await FirebaseFirestore.instance
          .collection(collection)
          .where('mode', isEqualTo: mode.storageKey)
          .where('size', isEqualTo: size.storageKey)
          .where('increasingSpeed', isEqualTo: increasingSpeed)
          .where('score', isGreaterThan: myScore)
          .limit(maxRank)
          .get();
      return snap.docs.length >= maxRank;
    } catch (_) {
      return false;
    }
  }

  String? get currentUid {
    if (!FirebaseBootstrap.isInitialized) return null;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  OnlineScoreEntry _entryFrom(Map<String, dynamic> data, int rank) {
    final updated = data['updatedAt'];
    DateTime updatedAt;
    if (updated is Timestamp) {
      updatedAt = updated.toDate();
    } else {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return OnlineScoreEntry(
      uid: data['uid'] as String? ?? '',
      nickname: data['nickname'] as String? ?? 'player',
      mode: _modeFrom(data['mode'] as String?),
      size: _sizeFrom(data['size'] as String?),
      increasingSpeed: data['increasingSpeed'] as bool? ?? false,
      score: (data['score'] as num?)?.toInt() ?? 0,
      updatedAt: updatedAt,
      rank: rank,
    );
  }

  GameMode _modeFrom(String? key) {
    for (final mode in GameMode.values) {
      if (mode.storageKey == key) return mode;
    }
    return GameMode.classic;
  }

  BoardSize _sizeFrom(String? key) {
    for (final size in BoardSize.values) {
      if (size.storageKey == key) return size;
    }
    return BoardSize.medium;
  }
}
