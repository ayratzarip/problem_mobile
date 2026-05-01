import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import 'entries_state_scope.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EntriesStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem?'),
        actions: [
          IconButton(
            tooltip: 'Инструкции',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.instructions),
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Мои записи',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                if (state.entries.isEmpty)
                  const _EmptyEntriesMessage()
                else
                  for (final entry in state.entries)
                    Card(
                      child: ListTile(
                        title: Text(entry.title),
                        subtitle: Text(entry.situation),
                        trailing: IconButton(
                          tooltip: 'Удалить',
                          onPressed: () => state.deleteEntry(entry.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.editEntryPath(entry.id),
                        ),
                      ),
                    ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            state.resetDraft();
            Navigator.of(context).pushNamed(AppRoutes.createSituation);
          },
          icon: const Icon(Icons.add),
          label: const Text('Новая запись'),
        ),
      ),
    );
  }
}

class _EmptyEntriesMessage extends StatelessWidget {
  const _EmptyEntriesMessage();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Пока записей нет. Нажмите «Новая запись», чтобы начать.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
