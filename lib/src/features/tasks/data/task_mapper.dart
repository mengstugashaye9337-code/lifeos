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
  );

  // ── Domain Model → DB Companion (for insert) ─────────────────────────────

  static TasksCompanion toInsertCompanion(TaskModel model) =>
      TasksCompanion.insert(
        title: model.title,
        description: drift.Value(model.description),
        dueDate: drift.Value(model.dueDate),
        priority: drift.Value(model.priority.toDbValue()),
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
  );
}
