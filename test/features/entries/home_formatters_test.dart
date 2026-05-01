import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:problem_mobile/features/entries/domain/problem_entry.dart';
import 'package:problem_mobile/features/entries/presentation/home_formatters.dart';

void main() {
  group('formatEntryDate', () {
    final now = DateTime.parse('2026-05-01T21:00:00.000');

    test('возвращает Сегодня и Вчера для ближайших дат', () {
      expect(
        formatEntryDate(DateTime.parse('2026-05-01T10:00:00.000'), now: now),
        'Сегодня',
      );
      expect(
        formatEntryDate(DateTime.parse('2026-04-30T10:00:00.000'), now: now),
        'Вчера',
      );
    });

    test('возвращает дату с русским названием месяца', () {
      expect(
        formatEntryDate(DateTime.parse('2026-04-28T10:00:00.000'), now: now),
        '28 апреля',
      );
    });
  });

  test('groupEntriesByDate сортирует записи и группирует по датам', () {
    final groups = groupEntriesByDate([
      _entry(id: 'old', createdAt: DateTime.parse('2026-04-28T10:00:00.000')),
      _entry(id: 'today', createdAt: DateTime.parse('2026-05-01T10:00:00.000')),
      _entry(
        id: 'yesterday',
        createdAt: DateTime.parse('2026-04-30T10:00:00.000'),
      ),
    ], now: DateTime.parse('2026-05-01T21:00:00.000'));

    expect(groups.map((group) => group.dateLabel), [
      'Сегодня',
      'Вчера',
      '28 апреля',
    ]);
    expect(groups.first.entries.single.id, 'today');
  });

  test('formatEntryForAI возвращает JSON без тегов', () {
    final json = formatEntryForAI(
      _entry(
        id: '1',
        situation: 'Сижу дома',
        thoughts: 'Думаю о работе',
        bodyFeelings: 'Ком в горле',
        bodyZones: const ['Горло'],
        consequences: 'Потерял час',
        withoutProblem: 'Пошел бы гулять',
        tags: const ['Работа'],
      ),
      0,
    );
    final data = jsonDecode(json) as Map<String, dynamic>;

    expect(data['index'], 1);
    expect(data['situation'], 'Сижу дома');
    expect(data['bodyZones'], ['Горло']);
    expect(data.containsKey('tags'), isFalse);
  });

  test('buildEntriesAiPrompt содержит системную инструкцию и JSON', () {
    final prompt = buildEntriesAiPrompt([
      _entry(
        id: '1',
        situation: 'Сижу дома',
        thoughts: 'Думаю о работе',
        bodyFeelings: 'Ком в горле',
        bodyZones: const ['Горло'],
        consequences: 'Потерял час',
        withoutProblem: 'Пошел бы гулять',
        tags: const ['Работа'],
      ),
    ]);

    expect(prompt, contains('Системная инструкция для AI:'));
    expect(prompt, contains('мобильном приложении «Problem?»'));
    expect(prompt, contains('Не ставь диагнозы'));
    expect(prompt, contains('```json'));
    expect(prompt, contains('"bodyZones": ['));
    expect(prompt, contains('"Горло"'));
    expect(prompt, isNot(contains('Теги')));
    expect(prompt, isNot(contains('Telegram Mini App')));
  });

  test('buildEntriesAiPrompt передает несколько записей JSON-массивом', () {
    final prompt = buildEntriesAiPrompt([
      _entry(id: '1', situation: 'Первая'),
      _entry(
        id: '2',
        situation: 'Вторая',
        createdAt: DateTime.parse('2026-04-02T10:00:00.000'),
      ),
    ]);

    expect(prompt, contains('"index": 1'));
    expect(prompt, contains('"index": 2'));
    expect(
      prompt.indexOf('"index": 2'),
      greaterThan(prompt.indexOf('"index": 1')),
    );
    expect(prompt, contains('"situation": "Вторая"'));
  });
}

ProblemEntry _entry({
  required String id,
  String situation = 'Ситуация',
  String thoughts = '',
  String bodyFeelings = '',
  List<String> bodyZones = const [],
  String consequences = '',
  String withoutProblem = '',
  List<String> tags = const [],
  DateTime? createdAt,
}) {
  final date = createdAt ?? DateTime.parse('2026-05-01T10:00:00.000');
  return ProblemEntry(
    id: id,
    situation: situation,
    thoughts: thoughts,
    bodyFeelings: bodyFeelings,
    bodyZones: bodyZones,
    consequences: consequences,
    withoutProblem: withoutProblem,
    emoji: '😌',
    title: situation,
    tags: tags,
    createdAt: date,
    updatedAt: date,
  );
}
