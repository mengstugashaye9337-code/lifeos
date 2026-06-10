import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/habits/data/habit_repository.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';
import 'package:lifeos/src/services/notification_provider.dart';

part 'habit_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider — depends on interface, not concrete class
// ---------------------------------------------------------------------------

@riverpod
IHabitRepository habitRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepository(db);
}

// ---------------------------------------------------------------------------
// Habits stream — reactive list of domain models
// ---------------------------------------------------------------------------

@riverpod
Stream<List<HabitModel>> habitListStream(Ref ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
}

// ---------------------------------------------------------------------------
// Habit mutations — owns mutations + notification side effects
// ---------------------------------------------------------------------------

@riverpod
class HabitNotifier extends _$HabitNotifier {
  @override
  FutureOr<void> build() {}

  IHabitRepository get _repo => ref.read(habitRepositoryProvider);

  NotificationNotifier get _notifications =>
      ref.read(notificationProvider.notifier);

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<void> addHabit(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Get DB-generated id — required for notification ID zoning
      final id = await _repo.addHabit(habit);

      // Schedule daily reminder at 8:00 AM using the real DB id
      await _notifications.scheduleHabitReminder(
        habitId: id,
        habitTitle: habit.title,
      );

      // Schedule morning summary — habit count just increased
      await _scheduleDailySummary();
    });
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateHabit(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.updateHabit(habit);

      // Cancel old reminder — title may have changed
      await _notifications.cancelHabitReminder(habit.id);

      // Reschedule with updated title
      await _notifications.scheduleHabitReminder(
        habitId: habit.id,
        habitTitle: habit.title,
      );
    });
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteHabit(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Cancel notifications before DB delete — id won't exist after
      await _notifications.cancelHabitReminder(id);
      await _notifications.cancelNotificationById(
        NotificationIds.streakBreakWarning,
      );

      await _repo.deleteHabit(id);

      // Refresh summary — habit count decreased
      await _scheduleDailySummary();
    });
  }

  // ── Mark complete ─────────────────────────────────────────────────────────

  Future<void> markComplete(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.markComplete(habit);

      // Habit done for today — cancel today's reminder
      await _notifications.cancelHabitReminder(habit.id);

      // Streak is now safe — cancel the streak break warning
      await _notifications.cancelNotificationById(
        NotificationIds.streakBreakWarning,
      );
    });
  }

  // ── Unmark complete ───────────────────────────────────────────────────────

  Future<void> unmarkComplete(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.unmarkComplete(habit);

      // Habit is now pending again — reschedule reminder
      await _notifications.scheduleHabitReminder(
        habitId: habit.id,
        habitTitle: habit.title,
      );

      // If streak exists — warn at 9 PM before it breaks
      if (habit.streak > 0) {
        await _notifications.scheduleStreakWarning(
          habitId: habit.id,
          habitTitle: habit.title,
          currentStreak: habit.streak,
        );
      }
    });
  }

  // ── Daily summary helper ──────────────────────────────────────────────────
  // Reads current habit count and reschedules the morning summary.
  // Called after add and delete since count changes affect the summary text.

  Future<void> _scheduleDailySummary() async {
    final habits = await _repo.watchHabits().first;
    await _notifications.scheduleDailyHabitSummary(habitCount: habits.length);
  }
}
