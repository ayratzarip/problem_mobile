import 'package:flutter/material.dart';

class BottomPrimaryButton extends StatelessWidget {
  const BottomPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (icon != null) ...[const SizedBox(width: 10), Icon(icon, size: 22)],
      ],
    );

    return FilledButton(onPressed: onPressed, child: child);
  }
}
