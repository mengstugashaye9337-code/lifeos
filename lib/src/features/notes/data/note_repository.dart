// lib/src/features/notes/data/note_repository.dart
import 'package:lifeos/src/database/app_database.dart';

class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  Stream<List<Note>> watchNotes() => _db.select(_db.notes).watch();

  Future<int> addNote(NotesCompanion note) => _db.into(_db.notes).insert(note);

  Future<bool> updateNote(Note note) => _db.update(_db.notes).replace(note);

  Future<int> deleteNote(int id) =>
      (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
}
