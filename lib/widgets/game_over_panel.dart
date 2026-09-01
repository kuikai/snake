import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/palette.dart';

/// Full-screen end-of-run view — no card overlay on the board.
class GameOverPanel extends StatelessWidget {
  const GameOverPanel({
    super.key,
    required this.score,
    required this.isNewHighScore,
    required this.continuesLeft,
    required this.onAgain,
    required this.onMenu,
    this.palette = SnakePalette.dark,
    this.onContinue,
    this.onUpgrade,
  });

  final int score;
  final bool isNewHighScore;
  final int continuesLeft;
  final VoidCallback onAgain;
  final VoidCallback onMenu;
  final SnakePalette palette;
  final VoidCallback? onContinue;
  final VoidCallback? onUpgrade;

  String _voiceLine() {
    if (isNewHighScore) return 'new best.';
    if (score >= 5) return 'nice run.';
    return 'oof.';
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = continuesLeft > 0 && onContinue != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            '$score',
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.w700,
              fontSize: 72,
              color: palette.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _voiceLine(),
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: palette.inkSoft,
            ),
          ),
          const Spacer(flex: 3),
          if (canContinue) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onContinue,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.ink,
                  side: BorderSide(color: palette.inkSoft.withValues(alpha: 0.5)),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Continue · $continuesLeft left',
                  style: GoogleFonts.figtree(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onAgain,
              style: FilledButton.styleFrom(
                backgroundColor: palette.play,
                foregroundColor: palette.playText,
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Again',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onMenu,
            child: Text(
              'Menu',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: palette.inkSoft,
              ),
            ),
          ),
          if (onUpgrade != null) ...[
            const SizedBox(height: 8),
            Text(
              'want another shot?',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: palette.inkSoft,
              ),
            ),
            TextButton(
              onPressed: onUpgrade,
              child: Text(
                r'Unlock · $1.99',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: palette.ink,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
