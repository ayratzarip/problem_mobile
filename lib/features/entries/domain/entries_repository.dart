import 'entry_draft.dart';
import 'problem_entry.dart';

abstract interface class EntriesRepository {
  Future<List<ProblemEntry>> getEntries();

  Future<ProblemEntry> addEntry(EntryDraft draft);

  Future<ProblemEntry?> updateEntry(
    String id,
    EntryDraft draft, {
    DateTime? createdAt,
  });

  Future<void> deleteEntry(String id);
}
