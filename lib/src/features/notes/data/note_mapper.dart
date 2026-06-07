import 'package:drift/drift.dart' as drift;
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/notes/domain/note_model.dart';

class NoteMapper {
  NoteMapper._(); // not instantiable — pure static utility

  // ── DB Row → Domain Model ──────────────────────────────────────────────

  static NoteModel fromRow(Note row) => NoteModel(
    id: row.id,
    title: row.title,
    content: row.content,
    createdAt: row.createdAt,
    isSynced: row.isSynced,
  );

  // ── Domain Model → DB Companion (for insert) ───────────────────────────

  static NotesCompanion toInsertCompanion(NoteModel model) =>
      NotesCompanion.insert(title: model.title, content: model.content);

  // ── Domain Model → DB Companion (for update) ──────────────────────────

  static NotesCompanion toUpdateCompanion(NoteModel model) => NotesCompanion(
    id: drift.Value(model.id),
    title: drift.Value(model.title),
    content: drift.Value(model.content),
    isSynced: drift.Value(model.isSynced),
  );
}
