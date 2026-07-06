import 'package:drift/drift.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/habits/data/habit_mapper.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract — repository is swappable (local ↔ remote)
// ---------------------------------------------------------------------------

abstract interface class IHabitRepository {
  Stream<List<HabitModel>> watchHabits();
  Future<List<HabitModel>> getUnsyncedHabits();
  Future<int> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(int id);
  Future<void> markComplete(HabitModel habit);
  Future<void> unmarkComplete(HabitModel habit);
  Future<void> markHabitSynced({
    required int localId,
    String? remoteId,
    required DateTime updatedAt,
  });
  Future<void> upsertFromRemote(HabitModel remoteHabit);
}

// ---------------------------------------------------------------------------
// Local implementation — Drift + SQLite
// ---------------------------------------------------------------------------

class HabitRepository implements IHabitRepository {
  final AppDatabase _db;

  HabitRepository(this._db);

  // ── Read ─────────────────────────────────────────────────────────────────

  @override
  Stream<List<HabitModel>> watchHabits() {
    return (_db.select(_db.habits)
          ..where((h) => h.deletedAt.isNull())
          ..orderBy([(h) => OrderingTerm(expression: h.createdAt)]))
        .watch()
        .map((rows) => rows.map(HabitMapper.fromRow).toList());
  }

  @override
  Future<List<HabitModel>> getUnsyncedHabits() async {
    final rows = await (_db.select(
      _db.habits,
    )..where((h) => h.isSynced.equals(false))).get();
    return rows.map(HabitMapper.fromRow).toList();
  }

  // ── Write ────────────────────────────────────────────────────────────────

  @override
  Future<int> addHabit(HabitModel habit) {
    final now = DateTime.now();
    return _db
        .into(_db.habits)
        .insert(
          HabitMapper.toInsertCompanion(
            habit.copyWith(isSynced: false, createdAt: now, updatedAt: now),
          ),
        );
  }

  @override
  Future<void> updateHabit(HabitModel habit) {
    final now = DateTime.now();
    return (_db.update(_db.habits)..where((h) => h.id.equals(habit.id))).write(
      HabitMapper.toUpdateCompanion(
        habit.copyWith(isSynced: false, updatedAt: now),
      ),
    );
  }

  @override
  Future<void> deleteHabit(int id) async {
    final now = DateTime.now();
    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }

  @override
  Future<void> markHabitSynced({
    required int localId,
    String? remoteId,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(localId))).write(
      HabitMapper.toSyncedCompanion(
        localId: localId,
        remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
        updatedAt: updatedAt,
      ),
    );
  }

  @override
  Future<void> upsertFromRemote(HabitModel remoteHabit) async {
    if (remoteHabit.remoteId == null) return;

    final existingByRemote =
        await (_db.select(_db.habits)
              ..where((h) => h.remoteId.equals(remoteHabit.remoteId!))
              ..limit(1))
            .getSingleOrNull();

    if (existingByRemote != null &&
        existingByRemote.updatedAt.isAfter(remoteHabit.updatedAt)) {
      return;
    }

    if (existingByRemote == null) {
      await _db
          .into(_db.habits)
          .insert(
            HabitsCompanion.insert(
              title: remoteHabit.title,
              frequency: remoteHabit.frequency.toDbValue(),
              streak: Value(remoteHabit.streak),
              createdAt: Value(remoteHabit.createdAt),
              lastCompletedDate: Value(remoteHabit.lastCompletedDate),
              isSynced: const Value(true),
              remoteId: Value(remoteHabit.remoteId),
              updatedAt: Value(remoteHabit.updatedAt),
              deletedAt: Value(remoteHabit.deletedAt),
            ),
          );
      return;
    }

    await (_db.update(
      _db.habits,
    )..where((h) => h.id.equals(existingByRemote.id))).write(
      HabitsCompanion(
        title: Value(remoteHabit.title),
        frequency: Value(remoteHabit.frequency.toDbValue()),
        streak: Value(remoteHabit.streak),
        createdAt: Value(remoteHabit.createdAt),
        lastCompletedDate: Value(remoteHabit.lastCompletedDate),
        isSynced: const Value(true),
        remoteId: Value(remoteHabit.remoteId),
        updatedAt: Value(remoteHabit.updatedAt),
        deletedAt: Value(remoteHabit.deletedAt),
      ),
    );
  }

  // ── Completion logic ─────────────────────────────────────────────────────

  @override
  Future<void> markComplete(HabitModel habit) async {
    // Guard — never double-complete
    if (habit.isCompletedToday) return;

    await _db.transaction(() async {
      // 1. Insert completion record
      await _db
          .into(_db.habitCompletions)
          .insert(HabitCompletionsCompanion.insert(habitId: habit.id));

      // 2. Recalculate streak from completion history
      final newStreak = await _calculateStreak(
        habitId: habit.id,
        frequency: habit.frequency,
      );

      // 3. Update habit — streak fields only, never touches title/frequency
      await (_db.update(_db.habits)..where((h) => h.id.equals(habit.id))).write(
        HabitMapper.toStreakCompanion(
          id: habit.id,
          streak: newStreak,
          lastCompletedDate: _today(),
        ),
      );
    });
  }

  @override
  Future<void> unmarkComplete(HabitModel habit) async {
    // Guard — nothing to undo
    if (!habit.isCompletedToday) return;

    await _db.transaction(() async {
      // 1. Remove today's completion record only
      final todayStart = _today();
      final todayEnd = todayStart.add(const Duration(days: 1));

      await (_db.delete(_db.habitCompletions)..where(
            (c) =>
                c.habitId.equals(habit.id) &
                c.completedAt.isBiggerOrEqualValue(todayStart) &
                c.completedAt.isSmallerThanValue(todayEnd),
          ))
          .go();

      // 2. Recalculate streak after removal
      final newStreak = await _calculateStreak(
        habitId: habit.id,
        frequency: habit.frequency,
      );

      // 3. Find the new lastCompletedDate after removal
      final lastCompletion =
          await (_db.select(_db.habitCompletions)
                ..where((c) => c.habitId.equals(habit.id))
                ..orderBy([
                  (c) => OrderingTerm(
                    expression: c.completedAt,
                    mode: OrderingMode.desc,
                  ),
                ])
                ..limit(1))
              .getSingleOrNull();

      // 4. Update habit
      await (_db.update(_db.habits)..where((h) => h.id.equals(habit.id))).write(
        HabitMapper.toStreakCompanion(
          id: habit.id,
          streak: newStreak,
          lastCompletedDate: lastCompletion?.completedAt,
        ),
      );
    });
  }

  // ── Streak calculation ───────────────────────────────────────────────────
  //
  // Pulls all completions ordered desc and walks backward from today,
  // counting consecutive days (daily) or weeks (weekly).
  // Fully recalculated from source of truth — never trust the stored integer.

  Future<int> _calculateStreak({
    required int habitId,
    required HabitFrequency frequency,
  }) async {
    final completions =
        await (_db.select(_db.habitCompletions)
              ..where((c) => c.habitId.equals(habitId))
              ..orderBy([
                (c) => OrderingTerm(
                  expression: c.completedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    if (completions.isEmpty) return 0;

    int streak = 0;
    DateTime cursor = _today();

    for (final completion in completions) {
      final completedDay = _stripTime(completion.completedAt);

      if (frequency == HabitFrequency.daily) {
        // Must be either today or the day immediately before cursor
        if (completedDay == cursor ||
            completedDay == cursor.subtract(const Duration(days: 1))) {
          streak++;
          cursor = completedDay.subtract(const Duration(days: 1));
        } else {
          break; // gap found — streak is over
        }
      } else {
        // Weekly — completion must fall within the current or previous week
        final cursorWeek = _weekStart(cursor);
        final completedWeek = _weekStart(completedDay);

        if (completedWeek == cursorWeek ||
            completedWeek == cursorWeek.subtract(const Duration(days: 7))) {
          streak++;
          cursor = completedWeek.subtract(const Duration(days: 7));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  // ── Date helpers ─────────────────────────────────────────────────────────

  DateTime _today() => _stripTime(DateTime.now());

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _weekStart(DateTime dt) {
    final d = _stripTime(dt);
    return d.subtract(Duration(days: d.weekday - 1)); // Monday = 1
  }
}
