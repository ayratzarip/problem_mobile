import 'package:flutter/material.dart';

class InstructionAccordion extends StatelessWidget {
  const InstructionAccordion({
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: DecoratedBox(
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: SizedBox.square(
              dimension: 34,
              child: Icon(icon, color: iconColor, size: 21),
            ),
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(66, 0, 16, 16),
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
