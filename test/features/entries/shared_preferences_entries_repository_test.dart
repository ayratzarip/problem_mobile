import 'package:flutter_test/flutter_test.dart';
import 'package:problem_mobile/features/entries/data/shared_preferences_entries_repository.dart';
import 'package:problem_mobile/features/entries/domain/entry_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;

  SharedPreferencesEntriesRepository createRepository() {
    return SharedPreferencesEntriesRepository(
      now: () => now,
      idGenerator: () => 'fixed-id',
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.parse('2026-05-01T10:00:00.000Z');
  });

  test('addEntry создает запись с метаданными и сохраняет ее первой', () async {
    final repository = createRepository();

    final entry = await repository.addEntry(
      const EntryDraft(
        situation: 'Начальник сказал, что отчет не готов',
        thoughts: 'Боюсь ошибиться',
        bodyFeelings: 'Напряжение в плечах',
        consequences: 'Не могу работать',
        withoutProblem: 'Спокойно закончил бы отчет',
      ),
    );

    expect(entry.id, 'fixed-id');
    expect(entry.title, 'Начальник сказал, что отчет не готов');
    expect(entry.emoji, '😨');
    expect(entry.tags, ['Работа', 'Страх']);
    expect(entry.createdAt, now);
    expect(entry.updatedAt, now);

    final entries = await repository.getEntries();
    expect(entries, hasLength(1));
    expect(entries.first.id, 'fixed-id');
  });

  test(
    'updateEntry обновляет запись и сохраняет исходную дату создания',
    () async {
      final repository = createRepository();
      final original = await repository.addEntry(
        const EntryDraft(situation: 'Старая ситуация'),
      );

      now = DateTime.parse('2026-05-01T11:00:00.000Z');
      final updated = await repository.updateEntry(
        original.id,
        const EntryDraft(
          situation: 'Новая ситуация',
          consequences: 'Потерял время на тревогу',
        ),
      );

      expect(updated, isNotNull);
      expect(updated!.situation, 'Новая ситуация');
      expect(updated.title, 'Новая ситуация');
      expect(updated.tags, ['Тревога']);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, now);
    },
  );

  test('updateEntry может изменить дату создания', () async {
    final repository = createRepository();
    final original = await repository.addEntry(
      const EntryDraft(situation: 'Ситуация'),
    );
    final customCreatedAt = DateTime.parse('2026-04-14T10:52:00.000Z');

    final updated = await repository.updateEntry(
      original.id,
      original.toDraft(),
      createdAt: customCreatedAt,
    );

    expect(updated!.createdAt, customCreatedAt);
  });

  test('deleteEntry удаляет запись', () async {
    final repository = createRepository();
    final entry = await repository.addEntry(
      const EntryDraft(situation: 'Ситуация'),
    );

    await repository.deleteEntry(entry.id);

    expect(await repository.getEntries(), isEmpty);
  });

  test('getEntries возвращает пустой список при поврежденном JSON', () async {
    SharedPreferences.setMockInitialValues({entriesStorageKey: 'not json'});
    final repository = createRepository();

    expect(await repository.getEntries(), isEmpty);
  });
}
