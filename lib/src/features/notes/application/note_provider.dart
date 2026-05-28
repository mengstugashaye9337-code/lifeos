// lib/src/features/notes/application/note_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/notes/data/note_repository.dart';
import 'package:lifeos/src/database/app_database.dart';

part 'note_provider.g.dart';

@riverpod
NoteRepository noteRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return NoteRepository(db);
}

final noteListStreamProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchNotes();
});
