/// Pure domain object — zero Flutter, zero Drift, zero Riverpod
/// Computed once by DashboardProvider, read by HomeScreen
class DashboardSummary {
  final int pendingTasksCount;
  final int overdueTasksCount;
  final int completedTodayTasksCount;
  final List<String> dueTodayTaskTitles; // max 3 shown on dashboard

  final int totalHabitsCount;
  final int completedTodayHabitsCount;
  final int pendingTodayHabitsCount;
  final int bestStreak;

  const DashboardSummary({
    required this.pendingTasksCount,
    required this.overdueTasksCount,
    required this.completedTodayTasksCount,
    required this.dueTodayTaskTitles,
    required this.totalHabitsCount,
    required this.completedTodayHabitsCount,
    required this.pendingTodayHabitsCount,
    required this.bestStreak,
  });

  // Convenience getters — UI reads these, never calculates
  bool get hasOverdueTasks => overdueTasksCount > 0;
  bool get allHabitsDoneToday =>
      totalHabitsCount > 0 && pendingTodayHabitsCount == 0;
  double get habitCompletionRate =>
      totalHabitsCount == 0 ? 0 : completedTodayHabitsCount / totalHabitsCount;

  // Empty state — shown when user has no data yet
  static const empty = DashboardSummary(
    pendingTasksCount: 0,
    overdueTasksCount: 0,
    completedTodayTasksCount: 0,
    dueTodayTaskTitles: [],
    totalHabitsCount: 0,
    completedTodayHabitsCount: 0,
    pendingTodayHabitsCount: 0,
    bestStreak: 0,
  );
}
