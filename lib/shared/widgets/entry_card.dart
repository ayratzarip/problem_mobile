import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/entries/domain/problem_entry.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
    this.useCard = true,
    this.borderRadius,
    super.key,
  });

  final ProblemEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool useCard;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(entry.createdAt).format(context);
    final previewText = _previewText(entry);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppSpacing.cardRadius);

    final child = InkWell(
      onTap: onTap,
      borderRadius: effectiveBorderRadius,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title.isEmpty ? 'Без названия' : entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  if (previewText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      previewText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Удалить',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );

    if (!useCard) {
      return child;
    }

    return Card(child: child);
  }

  String? _previewText(ProblemEntry entry) {
    for (final value in [
      entry.thoughts,
      entry.bodyFeelings,
      entry.consequences,
      entry.withoutProblem,
    ]) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
