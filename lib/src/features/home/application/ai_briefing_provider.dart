import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifeos/src/features/ai_assistant/application/ai_controller.dart';
import 'package:lifeos/src/features/home/application/dashboard_provider.dart';
import 'package:lifeos/src/features/home/domain/dashboard_summary.dart';

part 'ai_briefing_provider.g.dart';

String _todayKey() {
  final now = DateTime.now();
  return 'ai_briefing_${now.year}_${now.month}_${now.day}';
}

@riverpod
class AiBriefingNotifier extends _$AiBriefingNotifier {
  @override
  FutureOr<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_todayKey());
    if (cached != null) return cached;
    return null;
  }

  Future<void> generate() async {
    if (state.isLoading) return;
    if (state.value != null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final dashAsync = ref.read(dashboardProvider);
      final summary = dashAsync.value ?? DashboardSummary.empty;

      // ✅ named parameters — OpenAIService stays decoupled from domain
      final briefing = await ref
          .read(openAIServiceProvider)
          .getDailyBriefing(
            pendingTasksCount: summary.pendingTasksCount,
            overdueTasksCount: summary.overdueTasksCount,
            dueTodayTaskTitles: summary.dueTodayTaskTitles,
            completedTodayTasksCount: summary.completedTodayTasksCount,
            totalHabitsCount: summary.totalHabitsCount,
            completedTodayHabitsCount: summary.completedTodayHabitsCount,
            pendingTodayHabitsCount: summary.pendingTodayHabitsCount,
            bestStreak: summary.bestStreak,
          );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_todayKey(), briefing);

      return briefing;
    });
  }

  void dismiss() => state = const AsyncData('');
}
