import 'package:drift/drift.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/notes/data/note_mapper.dart';
import 'package:lifeos/src/features/notes/domain/note_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract — swappable local ↔ remote
// ---------------------------------------------------------------------------

abstract interface class INoteRepository {
  Stream<List<NoteModel>> watchNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(int id);
}

// ---------------------------------------------------------------------------
// Local implementation — Drift + SQLite
// ---------------------------------------------------------------------------

class NoteRepository implements INoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  // ── Read ──────────────────────────────────────────────────────────────

  @override
  Stream<List<NoteModel>> watchNotes() {
    return (_db.select(_db.notes)..orderBy([
          (n) => OrderingTerm(
            expression: n.createdAt,
            mode: OrderingMode.desc, // newest first
          ),
        ]))
        .watch()
        .map((rows) => rows.map(NoteMapper.fromRow).toList());
  }

  // ── Write ─────────────────────────────────────────────────────────────

  @override
  Future<void> addNote(NoteModel note) =>
      _db.into(_db.notes).insert(NoteMapper.toInsertCompanion(note));

  @override
  Future<void> updateNote(NoteModel note) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(note.id))).write(
        NoteMapper.toUpdateCompanion(note),
      );

  @override
  Future<void> deleteNote(int id) =>
      (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
}
