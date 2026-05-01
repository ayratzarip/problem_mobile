import 'package:flutter/material.dart';

class LargeTextArea extends StatelessWidget {
  const LargeTextArea({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hintText,
    this.minLines = 8,
    this.maxLines = 12,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: label.toUpperCase(),
          hintText: hintText,
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
