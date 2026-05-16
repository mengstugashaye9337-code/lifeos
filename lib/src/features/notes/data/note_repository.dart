import 'package:lifeos/src/database/app_database.dart';

class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  // Stream all notes (Real-time updates for the Grid View)
  Stream<List<Note>> watchNotes() {
    return _db.select(_db.notes).watch();
  }

  // Add a new note
  Future<int> addNote(NotesCompanion note) {
    return _db.into(_db.notes).insert(note);
  }

  // Update an existing note (Essential for the Editor auto-save)
  Future<bool> updateNote(Note note) {
    return _db.update(_db.notes).replace(note);
  }

  // Delete a note
  Future<int> deleteNote(int id) {
    return (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }
}
