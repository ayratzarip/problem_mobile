import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Инструкции'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.edit_note),
              title: Text('Как создать новую запись'),
              subtitle: Text('Экран инструкций будет детализирован на следующем этапе.'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Конфиденциальность'),
              subtitle: Text('Записи хранятся только локально на телефоне.'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Всё понятно'),
        ),
      ),
    );
  }
}
