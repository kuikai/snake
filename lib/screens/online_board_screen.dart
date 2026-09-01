import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/cosmetics.dart' hide SnakePalette;
import '../core/palette.dart';
import '../models/models.dart';
import '../providers/online_scores_provider.dart';

class OnlineBoardScreen extends ConsumerStatefulWidget {
  const OnlineBoardScreen({super.key});

  @override
  ConsumerState<OnlineBoardScreen> createState() => _OnlineBoardScreenState();
}

class _OnlineBoardScreenState extends ConsumerState<OnlineBoardScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onlineBoardProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >
        _scroll.position.maxScrollExtent - 240) {
      ref.read(onlineBoardProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(onlineBoardProvider);
    final prefs = ref.watch(onlineScoresPrefsProvider);
    final service = ref.watch(onlineScoresServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? SnakePalette.dark : SnakePalette.light;
    final myUid = service.currentUid;

    return Scaffold(
      backgroundColor: palette.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: palette.inkSoft),
                  ),
                  Expanded(
                    child: Text(
                      'live board',
                      style: GoogleFonts.fraunces(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Text(
                prefs.shareOnline
                    ? 'public. top 1000.'
                    : 'view only · sharing off',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: palette.inkSoft,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FilterRow(
                palette: palette,
                filter: board.filter,
                onChanged: (next) {
                  ref.read(onlineBoardProvider.notifier).setFilter(next);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _BoardBody(
                palette: palette,
                board: board,
                myUid: myUid,
                scrollController: _scroll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.palette,
    required this.filter,
    required this.onChanged,
  });

  final SnakePalette palette;
  final OnlineBoardFilter filter;
  final ValueChanged<OnlineBoardFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final mode in GameMode.values) ...[
                _FilterChip(
                  palette: palette,
                  label: Cosmetics.modeLabel(mode),
                  selected: filter.mode == mode,
                  onTap: () => onChanged(filter.copyWith(mode: mode)),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final size in BoardSize.values) ...[
                _FilterChip(
                  palette: palette,
                  label: Cosmetics.sizeLabel(size),
                  selected: filter.size == size,
                  onTap: () => onChanged(filter.copyWith(size: size)),
                ),
                const SizedBox(width: 6),
              ],
              _FilterChip(
                palette: palette,
                label: 'Speed',
                selected: filter.increasingSpeed,
                onTap: () => onChanged(
                  filter.copyWith(increasingSpeed: !filter.increasingSpeed),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final SnakePalette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: palette.paper.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? palette.ink.withValues(alpha: 0.35)
                  : palette.inkSoft.withValues(alpha: 0.22),
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.figtree(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
              color: palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardBody extends StatelessWidget {
  const _BoardBody({
    required this.palette,
    required this.board,
    required this.myUid,
    required this.scrollController,
  });

  final SnakePalette palette;
  final OnlineBoardState board;
  final String? myUid;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final message = board.message;
    final showStatus = board.status == OnlineBoardStatus.empty ||
        board.status == OnlineBoardStatus.offline ||
        board.status == OnlineBoardStatus.stub ||
        (board.status == OnlineBoardStatus.loading && board.entries.isEmpty);

    if (showStatus) {
      final text = switch (board.status) {
        OnlineBoardStatus.empty => 'no scores yet',
        OnlineBoardStatus.offline =>
          message ?? 'offline. local bests still count.',
        OnlineBoardStatus.stub =>
          message ?? 'online board not configured yet',
        _ => 'loading…',
      };
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: palette.inkSoft,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      itemCount: board.entries.length +
          (board.hasMore ? 1 : 0) +
          (!board.youOnBoard ? 1 : 0),
      itemBuilder: (context, index) {
        if (!board.youOnBoard && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'not on the board',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: palette.inkSoft,
              ),
            ),
          );
        }

        final offset = board.youOnBoard ? 0 : 1;
        final entryIndex = index - offset;

        if (entryIndex >= board.entries.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.inkSoft,
                ),
              ),
            ),
          );
        }

        final entry = board.entries[entryIndex];
        final isYou = entry.isYou(myUid);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${entry.rank}',
                  style: GoogleFonts.fraunces(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: palette.inkSoft,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.nickname,
                  style: GoogleFonts.figtree(
                    fontWeight: isYou ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16,
                    color: palette.ink,
                  ),
                ),
              ),
              if (isYou)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    'you',
                    style: GoogleFonts.figtree(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: palette.inkSoft,
                    ),
                  ),
                ),
              Text(
                '${entry.score}',
                style: GoogleFonts.fraunces(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: palette.ink,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
