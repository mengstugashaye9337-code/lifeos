import 'package:drift/drift.dart' as drift;
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

class HabitMapper {
  HabitMapper._(); // not instantiable — pure static utility

  // ── DB Row → Domain Model ──────────────────────────────────────────────

  static HabitModel fromRow(Habit row) => HabitModel(
    id: row.id,
    remoteId: row.remoteId,
    title: row.title,
    frequency: HabitFrequencyX.fromDb(row.frequency),
    streak: row.streak,
    createdAt: row.createdAt,
    isSynced: row.isSynced,
    lastCompletedDate: row.lastCompletedDate,
    updatedAt: row.updatedAt,
  );

  // ── Domain Model → DB Companion (for insert) ───────────────────────────

  static HabitsCompanion toInsertCompanion(HabitModel model) =>
      HabitsCompanion.insert(
        title: model.title,
        frequency: model.frequency.toDbValue(),
      );

  // ── Domain Model → DB Companion (for update) ──────────────────────────

  static HabitsCompanion toUpdateCompanion(HabitModel model) => HabitsCompanion(
    id: drift.Value(model.id),
    remoteId: drift.Value(model.remoteId),
    title: drift.Value(model.title),
    frequency: drift.Value(model.frequency.toDbValue()),
    streak: drift.Value(model.streak),
    isSynced: drift.Value(model.isSynced),
    lastCompletedDate: drift.Value(model.lastCompletedDate),
    updatedAt: drift.Value(model.updatedAt),
  );

  // ── Streak-only update companion ──────────────────────────────────────
  // Used by markComplete/unmarkComplete — avoids touching unrelated fields

  static HabitsCompanion toStreakCompanion({
    required int id,
    required int streak,
    required DateTime? lastCompletedDate,
  }) => HabitsCompanion(
    id: drift.Value(id),
    streak: drift.Value(streak),
    lastCompletedDate: drift.Value(lastCompletedDate),
  );
}
