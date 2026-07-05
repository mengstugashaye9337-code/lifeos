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
    drift.Value<String?> remoteId = const drift.Value.absent(),
    required DateTime updatedAt,
  }) => TasksCompanion(
    id: drift.Value(id),
    remoteId: remoteId,
    updatedAt: drift.Value(updatedAt),
    isSynced: const drift.Value(true),
  );

  // ── Remote JSON ↔ Domain Model (Supabase) ───────────────────────────────

  static TaskModel fromRemoteRow(Map<String, dynamic> row) => TaskModel(
    id: 0, // local DB id is independent from remote UUID
    title: row['title'] as String,
    description: row['description'] as String?,
    dueDate: _parseDate(row['due_date']),
    isCompleted: (row['is_completed'] as bool?) ?? false,
    priority: TaskPriorityX.fromDb((row['priority'] as int?) ?? 1),
    createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
    isSynced: true,
    remoteId: row['id'] as String?,
    updatedAt: _parseDate(row['updated_at']) ?? DateTime.now(),
    deletedAt: _parseDate(row['deleted_at']),
  );

  static Map<String, dynamic> toRemoteRow(
    TaskModel task, {
    required String userId,
  }) {
    return {
      if (task.remoteId != null) 'id': task.remoteId,
      'user_id': userId,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate?.toIso8601String(),
      'is_completed': task.isCompleted,
      'priority': task.priority.toDbValue(),
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
      'deleted_at': task.deletedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
