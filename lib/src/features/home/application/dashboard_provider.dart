import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/features/habits/application/habit_provider.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';
import 'package:lifeos/src/features/home/domain/dashboard_summary.dart';
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';

part 'dashboard_provider.g.dart';

// ---------------------------------------------------------------------------
// DashboardProvider — derives DashboardSummary from tasks + habits streams
//
// Pure computed state — owns zero mutations, zero side effects
// Re-computes automatically whenever tasks or habits change
// ---------------------------------------------------------------------------

@riverpod
AsyncValue<DashboardSummary> dashboard(Ref ref) {
  // Watch both upstream providers — re-evaluates when either changes
  final tasksAsync = ref.watch(tasksStateProvider);
  final habitsAsync = ref.watch(habitListStreamProvider);

  // Both must be loaded before we compute — never show partial data
  if (tasksAsync.isLoading || habitsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // Surface errors — tasks error takes priority
  if (tasksAsync.hasError) {
    return AsyncValue.error(tasksAsync.error!, tasksAsync.stackTrace!);
  }
  if (habitsAsync.hasError) {
    return AsyncValue.error(habitsAsync.error!, habitsAsync.stackTrace!);
  }

  // Both loaded — safe to unwrap
  final tasks = tasksAsync.value!.allTasks;
  final habits = habitsAsync.value ?? [];

  return AsyncValue.data(_compute(tasks, habits));
}

// ---------------------------------------------------------------------------
// Pure computation — no side effects, fully testable in isolation
// ---------------------------------------------------------------------------

DashboardSummary _compute(List<TaskModel> tasks, List<HabitModel> habits) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // ── Task metrics ──────────────────────────────────────────────────────────

  // Pending = not completed and not deleted
  final pendingTasks = tasks
      .where((t) => !t.isCompleted && !t.isDeleted)
      .toList();

  // Overdue = pending + due date before today
  final overdueTasks = tasks.where((t) => t.isOverdue && !t.isDeleted).toList();

  // Due today = pending + due date is exactly today
  final dueTodayTasks = pendingTasks.where((t) {
    if (t.dueDate == null) return false;
    final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
    return due.isAtSameMomentAs(today);
  }).toList();

  // Completed today = completed + updatedAt is today
  final completedTodayTasks = tasks.where((t) {
    if (!t.isCompleted || t.isDeleted) return false;
    final updated = DateTime(
      t.updatedAt.year,
      t.updatedAt.month,
      t.updatedAt.day,
    );
    return updated.isAtSameMomentAs(today);
  }).toList();

  // ── Habit metrics ─────────────────────────────────────────────────────────

  final completedTodayHabits = habits.where((h) => h.isCompletedToday).toList();

  final pendingTodayHabits = habits.where((h) => !h.isCompletedToday).toList();

  // Best active streak across all habits
  final bestStreak = habits.isEmpty
      ? 0
      : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  return DashboardSummary(
    pendingTasksCount: pendingTasks.length,
    overdueTasksCount: overdueTasks.length,
    completedTodayTasksCount: completedTodayTasks.length,

    // Max 3 titles shown on dashboard — prevents overflow
    dueTodayTaskTitles: dueTodayTasks.take(3).map((t) => t.title).toList(),

    totalHabitsCount: habits.length,
    completedTodayHabitsCount: completedTodayHabits.length,
    pendingTodayHabitsCount: pendingTodayHabits.length,
    bestStreak: bestStreak,
  );
}
