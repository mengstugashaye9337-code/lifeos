import 'package:drift/drift.dart' as drift;
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';

class TaskMapper {
  TaskMapper._();

  // ── DB Row → Domain Model ──────────────────────────────────────────────

  static TaskModel fromRow(Task row) => TaskModel(
    id: row.id,
    title: row.title,
    description: row.description,
    dueDate: row.dueDate,
    isCompleted: row.isCompleted,
    priority: TaskPriorityX.fromDb(row.priority),
    createdAt: row.createdAt,
    isSynced: row.isSynced,
    remoteId: row.remoteId,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );

  // ── Domain Model → DB Companion (for insert) ─────────────────────────────

  static TasksCompanion toInsertCompanion(TaskModel model) =>
      TasksCompanion.insert(
        title: model.title,
        description: drift.Value(model.description),
        dueDate: drift.Value(model.dueDate),
        priority: drift.Value(model.priority.toDbValue()),
        isSynced: drift.Value(model.isSynced),
        updatedAt: drift.Value(model.updatedAt),
        remoteId: drift.Value(model.remoteId),
      );

  // ── Domain Model → DB Companion (for update) ─────────────────────────────

  static TasksCompanion toUpdateCompanion(TaskModel model) => TasksCompanion(
    id: drift.Value(model.id),
    title: drift.Value(model.title),
    description: drift.Value(model.description),
    dueDate: drift.Value(model.dueDate),
    isCompleted: drift.Value(model.isCompleted),
    priority: drift.Value(model.priority.toDbValue()),
    isSynced: drift.Value(model.isSynced),
    remoteId: drift.Value(model.remoteId),
    updatedAt: drift.Value(model.updatedAt),
    deletedAt: drift.Value(model.deletedAt),
  );

  // ── Sync coordinator helper — mark row clean after remote push ───────────

  static TasksCompanion toSyncedCompanion({
    required int id,
    required String remoteId,
    required DateTime updatedAt,
  }) => TasksCompanion(
    id: drift.Value(id),
    remoteId: drift.Value(remoteId),
    updatedAt: drift.Value(updatedAt),
    isSynced: const drift.Value(true),
  );
}
