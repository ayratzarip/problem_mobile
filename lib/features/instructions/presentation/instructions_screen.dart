import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/bottom_primary_button.dart';
import '../../../shared/widgets/instruction_accordion.dart';
import '../../../shared/widgets/search_field.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = _instructionItems.where((item) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return item.title.toLowerCase().contains(query) ||
          item.content.toLowerCase().contains(query);
    }).toList();
    final groups = _query.trim().isEmpty
        ? _instructionGroups
        : [_InstructionGroup(items: items)];

    return AppScaffold(
      title: 'Инструкции',
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          12,
          AppSpacing.screenPadding,
          AppSpacing.listBottomPaddingSingleCta,
        ),
        children: [
          SearchField(
            hintText: 'Поиск по инструкциям...',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 22),
          for (final group in groups) ...[
            if (group.title != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  group.title!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            for (final item in group.items) ...[
              InstructionAccordion(
                title: item.title,
                content: item.content,
                icon: item.icon,
                iconColor: item.iconColor,
                initiallyExpanded: item.initiallyExpanded,
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 14),
          ],
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ничего не найдено. Попробуйте изменить поисковый запрос.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Версия приложения 1.0.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      bottomBar: BottomPrimaryButton(
        label: 'Всё понятно',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _InstructionItem {
  const _InstructionItem({
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
    this.initiallyExpanded = false,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;
  final bool initiallyExpanded;
}

class _InstructionGroup {
  const _InstructionGroup({required this.items, this.title});

  final String? title;
  final List<_InstructionItem> items;
}

const _instructionGroups = [
  _InstructionGroup(
    items: [
      _InstructionItem(
        title: 'Как создать новую запись',
        content:
            'Нажмите на синюю кнопку «Новая запись» внизу главного экрана. Последовательно заполните 5 шагов: Ситуация, Мысли, Тело, Последствия, Без проблемы. На каждом шаге есть подсказки и вопросы-помощники.',
        icon: Icons.edit_note,
        iconColor: AppColors.primary,
        initiallyExpanded: true,
      ),
      _InstructionItem(
        title: 'Как редактировать запись',
        content:
            'На главном экране нажмите на карточку записи, которую хотите изменить. Откроется окно редактирования, где вы сможете внести правки в любой раздел или изменить дату и время события. Не забудьте нажать "Сохранить изменения".',
        icon: Icons.edit,
        iconColor: Colors.deepOrange,
      ),
    ],
  ),
  _InstructionGroup(
    title: 'Что писать в описании',
    items: [
      _InstructionItem(
        title: '1. Ситуация (Что происходит?)',
        content:
            'Опишите факты: что произошло или что происходит прямо сейчас. Без эмоций, как если бы это снимала камера. Например: "Сижу на диване, не могу начать работать" или "Начальник повысил голос".',
        icon: Icons.info_outline,
        iconColor: Colors.blue,
      ),
      _InstructionItem(
        title: '2. Мысли (О чем думаю?)',
        content:
            'Запишите всё, что приходит в голову. Если сложно, представьте, что объясняете другу или что написано в облачке над вашей головой в комиксе.',
        icon: Icons.psychology_alt_outlined,
        iconColor: Colors.purple,
      ),
      _InstructionItem(
        title: '3. Тело (Что ощущаю?)',
        content:
            'Оцените тонус мышц (напряжение/расслабление) в теле и лице. Затем прислушайтесь к ощущениям внутри (ком в горле, тяжесть в груди). Эмоции всегда отражаются в теле.',
        icon: Icons.accessibility_new,
        iconColor: Colors.red,
      ),
      _InstructionItem(
        title: '4. Последствия (Как мешает?)',
        content:
            'Как эта проблема мешает жить? Это может быть потеря времени (2 часа тревоги) или препятствие к действию (хотел пойти, но остался дома).',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.amber,
      ),
      _InstructionItem(
        title: '5. Без проблемы',
        content:
            'Представьте, что проблемы нет. Что бы вы делали? Это помогает осознать ценность изменений. Например: "Если бы не тревога, я бы почитал книгу".',
        icon: Icons.sentiment_satisfied_alt,
        iconColor: Colors.green,
      ),
    ],
  ),
  _InstructionGroup(
    items: [
      _InstructionItem(
        title: 'Как работать с AI',
        content:
            'На главном экране нажмите кнопку "Скопировать для AI" (доступна, если есть записи). Ваш журнал будет скопирован в буфер обмена в специальном формате с промптом для нейросети. Вставьте этот текст в чат с любым AI (ChatGPT, Claude и т.д.) для получения анализа и рекомендаций.',
        icon: Icons.smart_toy_outlined,
        iconColor: Colors.indigo,
      ),
    ],
  ),
  _InstructionGroup(
    title: 'Безопасность',
    items: [
      _InstructionItem(
        title: 'Конфиденциальность',
        content:
            'Все записи хранятся только локально на вашем телефоне. Приложение не отправляет дневник на серверы, не использует облачную синхронизацию и не передает данные третьим лицам. Никто, кроме вас, не имеет доступа к вашему дневнику.',
        icon: Icons.lock_outline,
        iconColor: Colors.blueGrey,
      ),
    ],
  ),
];

final _instructionItems = [
  for (final group in _instructionGroups) ...group.items,
];
