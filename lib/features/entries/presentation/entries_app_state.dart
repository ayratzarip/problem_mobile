import 'package:flutter/foundation.dart';

import '../domain/entries_repository.dart';
import '../domain/entry_draft.dart';
import '../domain/problem_entry.dart';

class EntriesAppState extends ChangeNotifier {
  EntriesAppState({required EntriesRepository repository})
    : _repository = repository;

  final EntriesRepository _repository;

  List<ProblemEntry> _entries = [];
  EntryDraft _draft = const EntryDraft();
  bool _isLoading = false;
  String? _editingEntryId;

  List<ProblemEntry> get entries => List.unmodifiable(_entries);
  EntryDraft get draft => _draft;
  bool get isLoading => _isLoading;
  String? get editingEntryId => _editingEntryId;

  bool get hasDraftChanges => !_draft.isEmpty;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.getEntries();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDraft(EntryDraft draft) {
    _draft = draft;
    notifyListeners();
  }

  void updateDraft({
    String? situation,
    String? thoughts,
    String? bodyFeelings,
    List<String>? bodyZones,
    String? consequences,
    String? withoutProblem,
  }) {
    _draft = _draft.copyWith(
      situation: situation,
      thoughts: thoughts,
      bodyFeelings: bodyFeelings,
      bodyZones: bodyZones,
      consequences: consequences,
      withoutProblem: withoutProblem,
    );
    notifyListeners();
  }

  void resetDraft() {
    _draft = const EntryDraft();
    _editingEntryId = null;
    notifyListeners();
  }

  Future<ProblemEntry> saveDraftAsEntry() async {
    final entry = await _repository.addEntry(_draft);
    _entries = [entry, ..._entries];
    _draft = const EntryDraft();
    _editingEntryId = null;
    notifyListeners();
    return entry;
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    _entries = _entries.where((entry) => entry.id != id).toList();
    if (_editingEntryId == id) {
      _editingEntryId = null;
      _draft = const EntryDraft();
    }
    notifyListeners();
  }

  bool loadEntryForEditing(String id) {
    ProblemEntry? entry;
    for (final currentEntry in _entries) {
      if (currentEntry.id == id) {
        entry = currentEntry;
        break;
      }
    }

    if (entry == null) {
      return false;
    }

    _editingEntryId = id;
    _draft = entry.toDraft();
    notifyListeners();
    return true;
  }

  Future<ProblemEntry?> updateEditingEntry({DateTime? createdAt}) async {
    final id = _editingEntryId;
    if (id == null) {
      return null;
    }

    final updated = await _repository.updateEntry(
      id,
      _draft,
      createdAt: createdAt,
    );
    if (updated == null) {
      return null;
    }

    _entries = _entries
        .map((entry) => entry.id == updated.id ? updated : entry)
        .toList();
    _draft = const EntryDraft();
    _editingEntryId = null;
    notifyListeners();
    return updated;
  }
}
