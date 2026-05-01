import 'package:flutter_test/flutter_test.dart';
import 'package:problem_mobile/features/entries/domain/entries_repository.dart';
import 'package:problem_mobile/features/entries/domain/entry_draft.dart';
import 'package:problem_mobile/features/entries/domain/entry_metadata.dart';
import 'package:problem_mobile/features/entries/domain/problem_entry.dart';
import 'package:problem_mobile/features/entries/presentation/entries_app_state.dart';

void main() {
  late _MemoryEntriesRepository repository;
  late EntriesAppState state;

  setUp(() {
    repository = _MemoryEntriesRepository();
    state = EntriesAppState(repository: repository);
  });

  tearDown(() {
    state.dispose();
  });

  test('loadEntries загружает записи из репозитория', () async {
    repository.entries = [
      _entry(id: '1', situation: 'Ситуация'),
    ];

    await state.loadEntries();

    expect(state.isLoading, isFalse);
    expect(state.entries, hasLength(1));
    expect(state.entries.first.id, '1');
  });

  test('saveDraftAsEntry сохраняет черновик и сбрасывает его', () async {
    state.updateDraft(situation: 'Работа вызывает тревогу');

    final entry = await state.saveDraftAsEntry();

    expect(entry.title, 'Работа вызывает тревогу');
    expect(state.entries, hasLength(1));
    expect(state.draft.isEmpty, isTrue);
  });

  test('loadEntryForEditing и updateEditingEntry обновляют запись', () async {
    repository.entries = [
      _entry(id: '1', situation: 'Старая ситуация'),
    ];
    await state.loadEntries();

    final loaded = state.loadEntryForEditing('1');
    state.updateDraft(situation: 'Новая ситуация');
    final updated = await state.updateEditingEntry();

    expect(loaded, isTrue);
    expect(updated?.situation, 'Новая ситуация');
    expect(state.editingEntryId, isNull);
    expect(state.draft.isEmpty, isTrue);
    expect(state.entries.single.situation, 'Новая ситуация');
  });

  test('deleteEntry удаляет запись и сбрасывает редактирование этой записи', () async {
    repository.entries = [
      _entry(id: '1', situation: 'Ситуация'),
    ];
    await state.loadEntries();
    state.loadEntryForEditing('1');

    await state.deleteEntry('1');

    expect(state.entries, isEmpty);
    expect(state.editingEntryId, isNull);
    expect(state.draft.isEmpty, isTrue);
  });
}

class _MemoryEntriesRepository implements EntriesRepository {
  List<ProblemEntry> entries = [];

  @override
  Future<List<ProblemEntry>> getEntries() async => entries;

  @override
  Future<ProblemEntry> addEntry(EntryDraft draft) async {
    final entry = _entry(
      id: '${entries.length + 1}',
      situation: draft.situation,
      thoughts: draft.thoughts,
      bodyFeelings: draft.bodyFeelings,
      bodyZones: draft.bodyZones,
      consequences: draft.consequences,
      withoutProblem: draft.withoutProblem,
    );
    entries = [entry, ...entries];
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    entries = entries.where((entry) => entry.id != id).toList();
  }

  @override
  Future<ProblemEntry?> updateEntry(
    String id,
    EntryDraft draft, {
    DateTime? createdAt,
  }) async {
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return null;
    }

    final updated = _entry(
      id: id,
      situation: draft.situation,
      thoughts: draft.thoughts,
      bodyFeelings: draft.bodyFeelings,
      bodyZones: draft.bodyZones,
      consequences: draft.consequences,
      withoutProblem: draft.withoutProblem,
      createdAt: createdAt ?? entries[index].createdAt,
    );
    entries[index] = updated;
    return updated;
  }
}

ProblemEntry _entry({
  required String id,
  required String situation,
  String thoughts = '',
  String bodyFeelings = '',
  List<String> bodyZones = const [],
  String consequences = '',
  String withoutProblem = '',
  DateTime? createdAt,
}) {
  final created = createdAt ?? DateTime.parse('2026-05-01T10:00:00.000Z');
  final combinedText = '$situation $thoughts $consequences';

  return ProblemEntry(
    id: id,
    situation: situation,
    thoughts: thoughts,
    bodyFeelings: bodyFeelings,
    bodyZones: bodyZones,
    consequences: consequences,
    withoutProblem: withoutProblem,
    emoji: getEmoji(combinedText),
    title: generateTitle(situation),
    tags: extractTags(combinedText),
    createdAt: created,
    updatedAt: DateTime.parse('2026-05-01T11:00:00.000Z'),
  );
}
