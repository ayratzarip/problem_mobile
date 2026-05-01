import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entries_repository.dart';
import '../domain/entry_draft.dart';
import '../domain/entry_metadata.dart';
import '../domain/problem_entry.dart';

const entriesStorageKey = 'journal_entries';

typedef DateTimeProvider = DateTime Function();
typedef EntryIdGenerator = String Function();

class SharedPreferencesEntriesRepository implements EntriesRepository {
  SharedPreferencesEntriesRepository({
    SharedPreferences? preferences,
    String storageKey = entriesStorageKey,
    DateTimeProvider? now,
    EntryIdGenerator? idGenerator,
  })  : _preferences = preferences,
        _storageKey = storageKey,
        _now = now ?? DateTime.now,
        _idGenerator = idGenerator ?? _generateId;

  SharedPreferences? _preferences;
  final String _storageKey;
  final DateTimeProvider _now;
  final EntryIdGenerator _idGenerator;

  @override
  Future<List<ProblemEntry>> getEntries() async {
    return _readEntries();
  }

  @override
  Future<ProblemEntry> addEntry(EntryDraft draft) async {
    final entries = await _readEntries();
    final now = _now();
    final entry = _buildEntry(
      id: _idGenerator(),
      draft: draft,
      createdAt: now,
      updatedAt: now,
    );

    await _saveEntries([entry, ...entries]);
    return entry;
  }

  @override
  Future<ProblemEntry?> updateEntry(
    String id,
    EntryDraft draft, {
    DateTime? createdAt,
  }) async {
    final entries = await _readEntries();
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return null;
    }

    final previous = entries[index];
    final updated = _buildEntry(
      id: previous.id,
      draft: draft,
      createdAt: createdAt ?? previous.createdAt,
      updatedAt: _now(),
    );

    entries[index] = updated;
    await _saveEntries(entries);
    return updated;
  }

  @override
  Future<void> deleteEntry(String id) async {
    final entries = await _readEntries();
    await _saveEntries(entries.where((entry) => entry.id != id).toList());
  }

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<List<ProblemEntry>> _readEntries() async {
    final prefs = await _prefs;
    final rawValue = prefs.getString(_storageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((entry) => ProblemEntry.fromJson(Map<String, Object?>.from(entry)))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> _saveEntries(List<ProblemEntry> entries) async {
    final prefs = await _prefs;
    final jsonEntries = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonEntries));
  }

  ProblemEntry _buildEntry({
    required String id,
    required EntryDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final combinedText =
        '${draft.situation} ${draft.thoughts} ${draft.consequences}';

    return ProblemEntry(
      id: id,
      situation: draft.situation,
      thoughts: draft.thoughts,
      bodyFeelings: draft.bodyFeelings,
      bodyZones: draft.bodyZones,
      consequences: draft.consequences,
      withoutProblem: draft.withoutProblem,
      emoji: getEmoji(combinedText),
      title: generateTitle(draft.situation),
      tags: extractTags(combinedText),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = Random().nextInt(0x7fffffff).toRadixString(36);
    return '$timestamp-$suffix';
  }
}
