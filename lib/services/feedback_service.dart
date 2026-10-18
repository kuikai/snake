import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

/// Cheap SFX + haptics. Respects Settings toggles.
class FeedbackService {
  FeedbackService(this._ref);

  final Ref _ref;
  final AudioPlayer _eatPlayer = AudioPlayer();

  bool get _soundEnabled => _ref.read(settingsProvider).soundEnabled;
  bool get _hapticsEnabled => _ref.read(settingsProvider).hapticsEnabled;

  Future<void> turn() async {
    if (_hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> eat() async {
    if (_hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
    if (!_soundEnabled) return;
    try {
      await _eatPlayer.stop();
      await _eatPlayer.play(AssetSource('sfx/eat.wav'));
    } catch (_) {
      // Asset / platform audio may fail on some targets; stay silent.
    }
  }

  Future<void> death() async {
    if (_hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> button() async {
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> dispose() async {
    await _eatPlayer.dispose();
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final service = FeedbackService(ref);
  ref.onDispose(() {
    // ignore: discarded_futures
    service.dispose();
  });
  return service;
});
