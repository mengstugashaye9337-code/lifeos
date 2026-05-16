import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/notes/data/note_repository.dart';
import 'package:lifeos/src/database/app_database.dart';

part 'note_provider.g.dart';

@riverpod
NoteRepository noteRepository(Ref ref) {
  // We grab the shared database instance
  final db = ref.watch(appDatabaseProvider);
  return NoteRepository(db);
}

@riverpod
Stream<List<Note>> noteListStream(Ref ref) {
  // We use the repository to watch for data changes
  return ref.watch(noteRepositoryProvider).watchNotes();
}
