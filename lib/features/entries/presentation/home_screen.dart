import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/bottom_primary_button.dart';
import '../../../shared/widgets/entry_card.dart';
import '../../../shared/widgets/search_field.dart';
import 'entries_state_scope.dart';
import 'home_formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = EntriesStateScope.of(context);
    final filteredEntries = state.entries.where((entry) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }

      return entry.title.toLowerCase().contains(query) ||
          entry.situation.toLowerCase().contains(query) ||
          entry.thoughts.toLowerCase().contains(query) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
    final groupedEntries = groupEntriesByDate(filteredEntries);

    return AppScaffold(
      actions: [
        IconButton(
          tooltip: 'Инструкции',
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.instructions),
          icon: const Icon(Icons.help_outline),
        ),
      ],
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                8,
                AppSpacing.screenPadding,
                AppSpacing.listBottomPaddingDoubleCta,
              ),
              children: [
                Text(
                  'Мои Записи',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                SearchField(
                  hintText: 'Поиск по записям...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 22),
                if (state.entries.isEmpty)
                  const _EmptyEntriesMessage()
                else if (filteredEntries.isEmpty)
                  const _NothingFoundMessage()
                else
                  for (final group in groupedEntries) ...[
                    _DateDivider(label: group.dateLabel),
                    for (final entry in group.entries) ...[
                      EntryCard(
                        entry: entry,
                        onDelete: () => _confirmDeleteEntry(entry.id),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.editEntryPath(entry.id));
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
              ],
            ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomPrimaryButton(
            label: 'Новая запись',
            icon: Icons.add,
            onPressed: () {
              HapticFeedback.lightImpact();
              state.resetDraft();
              Navigator.of(context).pushNamed(AppRoutes.createSituation);
            },
          ),
          if (state.entries.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CopyForAiButton(onPressed: _copyEntriesForAI),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteEntry(String id) async {
    HapticFeedback.mediumImpact();
    final state = EntriesStateScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await state.deleteEntry(id);
    HapticFeedback.mediumImpact();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Запись удалена')));
  }

  Future<void> _copyEntriesForAI() async {
    final entries = EntriesStateScope.of(context).entries;
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('У вас пока нет записей для анализа')),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final prompt = buildEntriesAiPrompt(entries);
    try {
      await Clipboard.setData(ClipboardData(text: prompt));
    } catch (_) {
      if (!mounted) {
        return;
      }
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось скопировать. Попробуйте еще раз.'),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Запрос скопирован в буфер обмена! Вставьте его в чат с AI.',
        ),
      ),
    );
  }
}

class _EmptyEntriesMessage extends StatelessWidget {
  const _EmptyEntriesMessage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(Icons.edit_note, size: 44, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Пока записей нет',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите «Новая запись», чтобы начать вести дневник самоанализа',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NothingFoundMessage extends StatelessWidget {
  const _NothingFoundMessage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 44, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Ничего не найдено',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить поисковый запрос',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CopyForAiButton extends StatelessWidget {
  const _CopyForAiButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.content_copy, size: 20),
      label: const Text('Скопировать для AI'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
