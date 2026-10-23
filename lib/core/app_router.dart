import 'package:flutter/material.dart';

import '../screens/game_screen.dart';
import '../screens/high_scores_screen.dart';
import '../screens/home_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/settings_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String game = '/game';
  static const String highScores = '/high-scores';
  static const String paywall = '/paywall';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        settings: (_) => const SettingsScreen(),
        game: (_) => const GameScreen(),
        highScores: (_) => const HighScoresScreen(),
        paywall: (_) => const PaywallScreen(),
      };
}
