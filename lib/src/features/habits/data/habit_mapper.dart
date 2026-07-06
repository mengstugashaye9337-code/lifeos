import 'package:drift/drift.dart' as drift;
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

class HabitMapper {
  HabitMapper._();

  // ── DB Row → Domain Model ──────────────────────────────────────────────

  static HabitModel fromRow(Habit row) => HabitModel(
    id: row.id,
    remoteId: row.remoteId,
    title: row.title,
    frequency: HabitFrequencyX.fromDb(row.frequency),
    streak: row.streak,
    lastCompletedDate: row.lastCompletedDate,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    isSynced: row.isSynced,
    deletedAt: row.deletedAt,
  );

  static HabitModel fromRemoteRow(Map<String, dynamic> row) => HabitModel(
    id: 0,
    remoteId: row['id'] as String?,
    title: row['title'] as String,
    frequency: HabitFrequencyX.fromDb((row['frequency'] as String?) ?? 'daily'),
    streak: (row['streak'] as int?) ?? 0,
    lastCompletedDate: _parseDate(row['last_completed_date']),
    createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
    updatedAt: _parseDate(row['updated_at']) ?? DateTime.now(),
    isSynced: true,
    deletedAt: _parseDate(row['deleted_at']),
  );

  // ── Domain Model → DB Companion (for insert) ───────────────────────────

  static HabitsCompanion toInsertCompanion(HabitModel model) =>
      HabitsCompanion.insert(
        title: model.title,
        frequency: model.frequency.toDbValue(),
        streak: drift.Value(model.streak),
        createdAt: drift.Value(model.createdAt),
        updatedAt: drift.Value(model.updatedAt),
        remoteId: drift.Value(model.remoteId),
        lastCompletedDate: drift.Value(model.lastCompletedDate),
        isSynced: drift.Value(model.isSynced),
        deletedAt: drift.Value(model.deletedAt),
      );

  // ── Domain Model → DB Companion (for update) ──────────────────────────

  static HabitsCompanion toUpdateCompanion(HabitModel model) => HabitsCompanion(
    id: drift.Value(model.id),
    remoteId: drift.Value(model.remoteId),
    title: drift.Value(model.title),
    frequency: drift.Value(model.frequency.toDbValue()),
    streak: drift.Value(model.streak),
    lastCompletedDate: drift.Value(model.lastCompletedDate),
    createdAt: drift.Value(model.createdAt),
    updatedAt: drift.Value(model.updatedAt),
    isSynced: drift.Value(model.isSynced),
    deletedAt: drift.Value(model.deletedAt),
  );

  // ── Streak-only update companion ──────────────────────────────────────

  static HabitsCompanion toStreakCompanion({
    required int id,
    required int streak,
    required DateTime? lastCompletedDate,
  }) => HabitsCompanion(
    id: drift.Value(id),
    streak: drift.Value(streak),
    lastCompletedDate: drift.Value(lastCompletedDate),
    updatedAt: drift.Value(DateTime.now()),
    isSynced: const drift.Value(false),
    deletedAt: const drift.Value(null),
  );

  // ── Sync-only companion — marks habit as synced after push/pull ────────
  // Never touches title, frequency, or streak — sync metadata only

  static HabitsCompanion toSyncedCompanion({
    required int localId,
    drift.Value<String?> remoteId = const drift.Value.absent(),
    required DateTime updatedAt,
  }) => HabitsCompanion(
    id: drift.Value(localId),
    remoteId: remoteId,
    updatedAt: drift.Value(updatedAt),
    isSynced: const drift.Value(true),
  );

  static Map<String, dynamic> toRemoteRow(
    HabitModel habit, {
    required String userId,
  }) {
    return {
      if (habit.remoteId != null) 'id': habit.remoteId,
      'user_id': userId,
      'title': habit.title,
      'frequency': habit.frequency.toDbValue(),
      'streak': habit.streak,
      'last_completed_date': habit.lastCompletedDate?.toIso8601String(),
      'created_at': habit.createdAt.toIso8601String(),
      'updated_at': habit.updatedAt.toIso8601String(),
      'deleted_at': habit.deletedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
