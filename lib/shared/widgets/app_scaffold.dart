import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.bottomBar,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      appBar: title == null && leading == null && actions == null
          ? null
          : AppBar(
              leading: leading,
              title: title == null ? null : Text(title!),
              actions: actions,
            ),
      body: body,
      bottomNavigationBar: bottomBar == null
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  32,
                  AppSpacing.screenPadding,
                  14,
                ),
                child: bottomBar!,
              ),
            ),
    );
  }
}
