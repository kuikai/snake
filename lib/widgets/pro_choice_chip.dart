import 'package:flutter/material.dart';

/// Choice chip that shows a lock + Pro when [locked].
class ProChoiceChip extends StatelessWidget {
  const ProChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.locked,
    required this.onSelected,
    required this.onLockedTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onSelected;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected && !locked,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (locked) ...[
            const Icon(Icons.lock, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label),
          if (locked) ...[
            const SizedBox(width: 4),
            Text(
              'Pro',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
      ),
      onSelected: (_) {
        if (locked) {
          onLockedTap();
        } else {
          onSelected();
        }
      },
    );
  }
}
