import 'package:flutter/widgets.dart';

import 'entries_app_state.dart';

class EntriesStateScope extends InheritedNotifier<EntriesAppState> {
  const EntriesStateScope({
    required EntriesAppState state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static EntriesAppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<EntriesStateScope>();
    assert(scope != null, 'EntriesStateScope не найден в дереве виджетов');
    return scope!.notifier!;
  }
}
