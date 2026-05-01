import 'package:flutter_test/flutter_test.dart';
import 'package:problem_mobile/features/entries/domain/problem_entry.dart';

void main() {
  test('ProblemEntry сериализуется в JSON и обратно', () {
    final entry = ProblemEntry(
      id: 'entry-1',
      situation: 'Ситуация',
      thoughts: 'Мысли',
      bodyFeelings: 'Ком в горле',
      bodyZones: const ['Горло'],
      consequences: 'Потерял час',
      withoutProblem: 'Пошел бы гулять',
      emoji: '😰',
      title: 'Ситуация',
      tags: const ['Тревога'],
      createdAt: DateTime.parse('2026-05-01T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-05-01T10:05:00.000Z'),
    );

    final restored = ProblemEntry.fromJson(entry.toJson());

    expect(restored.id, entry.id);
    expect(restored.situation, entry.situation);
    expect(restored.bodyZones, entry.bodyZones);
    expect(restored.tags, entry.tags);
    expect(restored.createdAt, entry.createdAt);
    expect(restored.updatedAt, entry.updatedAt);
  });
}
