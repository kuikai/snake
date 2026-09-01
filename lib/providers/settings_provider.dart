import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'storage_provider.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, GameSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<GameSettings> {
  @override
  GameSettings build() {
    return ref.read(storageServiceProvider).loadSettings();
  }

  Future<void> _save(GameSettings next) async {
    state = next;
    await ref.read(storageServiceProvider).saveSettings(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _save(state.copyWith(themeMode: mode));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _save(state.copyWith(soundEnabled: enabled));
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _save(state.copyWith(hapticsEnabled: enabled));
  }

  Future<void> setLastMode(GameMode mode) async {
    await _save(state.copyWith(lastMode: mode));
  }

  Future<void> setLastBoardSize(BoardSize size) async {
    await _save(state.copyWith(lastBoardSize: size));
  }

  Future<void> setLastIncreasingSpeed(bool enabled) async {
    await _save(state.copyWith(lastIncreasingSpeed: enabled));
  }

  Future<void> setSkin(SnakeSkin skin) async {
    await _save(state.copyWith(skin: skin));
  }

  Future<void> setBoardTheme(BoardTheme theme) async {
    await _save(state.copyWith(boardTheme: theme));
  }

  Future<void> updateSettings(GameSettings settings) async {
    await _save(settings);
  }

  /// Free users always play Classic / Medium / no speed ramp.
  GameSettings effectiveForPlay({required bool isPro}) {
    if (isPro) return state;
    return state.copyWith(
      lastMode: GameMode.classic,
      lastBoardSize: BoardSize.medium,
      lastIncreasingSpeed: false,
      skin: SnakeSkin.classicGreen,
      boardTheme: BoardTheme.classic,
    );
  }
}
