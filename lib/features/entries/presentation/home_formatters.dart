import 'dart:convert';

import '../domain/problem_entry.dart';

class GroupedEntries {
  const GroupedEntries({required this.dateLabel, required this.entries});

  final String dateLabel;
  final List<ProblemEntry> entries;
}

List<GroupedEntries> groupEntriesByDate(
  List<ProblemEntry> entries, {
  DateTime? now,
}) {
  final sortedEntries = [...entries]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final groups = <String, List<ProblemEntry>>{};

  for (final entry in sortedEntries) {
    final dateLabel = formatEntryDate(entry.createdAt, now: now);
    groups.putIfAbsent(dateLabel, () => []).add(entry);
  }

  return groups.entries
      .map(
        (entry) => GroupedEntries(dateLabel: entry.key, entries: entry.value),
      )
      .toList();
}

String formatEntryDate(DateTime date, {DateTime? now}) {
  final currentDate = now ?? DateTime.now();
  final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final entryDate = DateTime(date.year, date.month, date.day);

  if (entryDate == today) {
    return 'Сегодня';
  }
  if (entryDate == yesterday) {
    return 'Вчера';
  }

  return '${date.day} ${_ruMonths[date.month - 1]}';
}

String formatEntryForAI(ProblemEntry entry, int index) {
  return const JsonEncoder.withIndent('  ').convert({
    'index': index + 1,
    'createdAt': entry.createdAt.toIso8601String(),
    'updatedAt': entry.updatedAt.toIso8601String(),
    'title': entry.title.isEmpty ? 'Без названия' : entry.title,
    'situation': entry.situation,
    'thoughts': entry.thoughts,
    'bodyFeelings': entry.bodyFeelings,
    'bodyZones': entry.bodyZones,
    'consequences': entry.consequences,
    'withoutProblem': entry.withoutProblem,
  });
}

String buildEntriesAiPrompt(List<ProblemEntry> entries) {
  final jsonEntries = const JsonEncoder.withIndent('  ').convert([
    for (var i = 0; i < entries.length; i++) _entryForAi(entries[i], i),
  ]);

  return '''Системная инструкция для AI:
Ты — внимательный аналитик дневника самоанализа в мобильном приложении «Problem?». Твоя задача — помогать пользователю замечать повторяющиеся трудности, последствия и возможные направления самостоятельной работы.

Правила работы:
- Не ставь диагнозы и не утверждай наличие психических расстройств.
- Не заменяй психотерапевта, врача или кризисную помощь.
- Не делай выводов, если данных недостаточно; явно отмечай неопределенность.
- Опирайся только на переданные записи, не выдумывай факты.
- Пиши бережно, конкретно и на русском языке.
- Если видишь признаки риска для безопасности пользователя или других людей, мягко порекомендуй обратиться за срочной очной помощью или в местные экстренные службы.

Пользовательская задача:
Проанализируй записи из дневника самоанализа и подготовь структурированный ответ.

Что нужно сделать:
1. Кратко опиши общую картину: какие темы повторяются и в каких ситуациях.
2. Составь каталог проблем. Считай проблемой то, что отнимает время, мешает действиям, ухудшает самочувствие или качество жизни.
3. Для каждой заметной проблемы укажи:
   - наблюдаемые триггеры;
   - типичные мысли;
   - телесные реакции;
   - последствия;
   - что пользователь хотел бы делать без этой проблемы.
4. Оцени, какие проблемы выглядят наиболее влияющими на качество жизни. Объясни критерии оценки.
5. Предположи возможные связи между проблемами: что может поддерживать другие трудности. Формулируй это как гипотезы, а не как факты.
6. Предложи практичную очередность самостоятельной работы: лучше по одной проблеме за раз, начиная с наиболее значимой или поддерживающей другие.
7. Дай 3-5 мягких вопросов для дальнейшего самоанализа.

Формат ответа:
- «Краткое резюме»
- «Повторяющиеся темы»
- «Каталог проблем»
- «Что может быть главным узлом»
- «Предлагаемая очередность работы»
- «Вопросы для следующей записи»
- «Ограничения анализа»

Данные записей переданы ниже в JSON. Поля:
- `situation`: что происходит;
- `thoughts`: о чем пользователь думает;
- `bodyFeelings`: телесные ощущения;
- `bodyZones`: области тела;
- `consequences`: как проблема мешает жить;
- `withoutProblem`: что пользователь делал бы без проблемы.

```json
$jsonEntries
```''';
}

Map<String, Object> _entryForAi(ProblemEntry entry, int index) {
  return {
    'index': index + 1,
    'createdAt': entry.createdAt.toIso8601String(),
    'updatedAt': entry.updatedAt.toIso8601String(),
    'title': entry.title.isEmpty ? 'Без названия' : entry.title,
    'situation': entry.situation,
    'thoughts': entry.thoughts,
    'bodyFeelings': entry.bodyFeelings,
    'bodyZones': entry.bodyZones,
    'consequences': entry.consequences,
    'withoutProblem': entry.withoutProblem,
  };
}

const _ruMonths = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];
