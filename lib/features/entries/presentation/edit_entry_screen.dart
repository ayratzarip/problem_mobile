import 'package:flutter/material.dart';

import 'entries_state_scope.dart';

class EditEntryScreen extends StatefulWidget {
  const EditEntryScreen({
    required this.entryId,
    super.key,
  });

  final String entryId;

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late final TextEditingController _situationController;

  @override
  void initState() {
    super.initState();
    _situationController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final state = EntriesStateScope.of(context);
      final found = state.loadEntryForEditing(widget.entryId);
      if (found) {
        _situationController.text = state.draft.situation;
      }
    });
  }

  @override
  void dispose() {
    _situationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = EntriesStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _handleBack),
        title: const Text('Редактирование'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.editingEntryId == null
            ? const Center(child: Text('Запись не найдена'))
            : TextField(
                controller: _situationController,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  labelText: 'Ситуация',
                ),
                onChanged: (value) => state.updateDraft(situation: value),
              ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: state.editingEntryId == null ? null : _handleSave,
          child: const Text('Сохранить изменения'),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    await EntriesStateScope.of(context).updateEditingEntry();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _handleBack() {
    EntriesStateScope.of(context).resetDraft();
    Navigator.of(context).maybePop();
  }
}
