import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/palette.dart';

/// First-time opt-in sheet for posting bests to the live board.
Future<String?> showShareScoresSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final palette = isDark ? SnakePalette.dark : SnakePalette.light;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: const _ShareScoresSheetBody(),
      );
    },
  );
}

class _ShareScoresSheetBody extends StatefulWidget {
  const _ShareScoresSheetBody();

  @override
  State<_ShareScoresSheetBody> createState() => _ShareScoresSheetBodyState();
}

class _ShareScoresSheetBodyState extends State<_ShareScoresSheetBody> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _post() {
    final name = _controller.text.trim();
    if (name.length < 3 || name.length > 12) {
      setState(() => _error = '3–12 characters');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? SnakePalette.dark : SnakePalette.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'post your bests to the live board',
          style: GoogleFonts.fraunces(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'public. top 1000.',
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: palette.inkSoft,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 12,
          style: GoogleFonts.figtree(color: palette.ink),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_ ]')),
          ],
          decoration: InputDecoration(
            labelText: 'nickname',
            labelStyle: GoogleFonts.figtree(color: palette.inkSoft),
            errorText: _error,
            filled: true,
            fillColor: palette.paper.withValues(alpha: 0.85),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.inkSoft.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.inkSoft.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.ink.withValues(alpha: 0.45)),
            ),
          ),
          onSubmitted: (_) => _post(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _post,
            style: FilledButton.styleFrom(
              backgroundColor: palette.play,
              foregroundColor: palette.playText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Post',
              style: GoogleFonts.figtree(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Not now',
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w600,
              color: palette.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}
