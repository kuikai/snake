import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/palette.dart';

/// Quiet paper tag for Home feature picks — not Material FilterChip.
class HomeFeatureChip extends StatelessWidget {
  const HomeFeatureChip({
    super.key,
    required this.label,
    required this.selected,
    required this.locked,
    required this.palette,
    required this.onTap,
    this.onLockedTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final SnakePalette palette;
  final VoidCallback onTap;
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final isActive = selected && !locked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: locked ? onLockedTap : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: palette.paper.withValues(alpha: locked ? 0.7 : 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? palette.ink.withValues(alpha: 0.35)
                  : palette.inkSoft.withValues(alpha: 0.22),
              width: isActive ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locked) ...[
                Icon(
                  Icons.lock_outline,
                  size: 12,
                  color: palette.inkSoft,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.figtree(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                  color: locked ? palette.inkSoft : palette.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
