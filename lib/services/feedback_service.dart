import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

/// Cheap system SFX + haptics. Respects Settings toggles.
class FeedbackService {
  FeedbackService(this._ref);

  final Ref _ref;

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
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
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
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(ref);
});
