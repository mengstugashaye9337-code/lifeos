// lib/src/features/tasks/presentation/task_provider.dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart'; // ✅ Added
import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/services/notification_provider.dart';
//import 'package:drift/drift.dart' as drift;

part 'task_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

@riverpod
TaskRepository taskRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskRepository(db);
}

// ---------------------------------------------------------------------------
// Filter enum
// ---------------------------------------------------------------------------

enum TaskFilter { all, pending, completed }

// ---------------------------------------------------------------------------
// Unified view state — stream + filter in one object
// ---------------------------------------------------------------------------

class TasksViewState {
  final List<Task> allTasks;
  final TaskFilter filter;

  TasksViewState({required this.allTasks, required this.filter});

  List<Task> get filteredTasks {
    switch (filter) {
      case TaskFilter.all:
        return allTasks;
      case TaskFilter.pending:
        return allTasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return allTasks.where((t) => t.isCompleted).toList();
    }
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return allTasks
        .where(
          (t) =>
              !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now),
        )
        .toList();
  }
}

// ---------------------------------------------------------------------------
// TasksStateNotifier — owns stream, filter state, mutations, notifications
// ---------------------------------------------------------------------------

@riverpod
class TasksStateNotifier extends _$TasksStateNotifier {
  StreamSubscription<List<Task>>? _subscription;

  @override
  AsyncValue<TasksViewState> build() {
    // ✅ Fixed return type
    ref.onDispose(() => _subscription?.cancel());

    // ✅ Read directly into build context to avoid lifecycle race conditions
    final repo = ref.read(taskRepositoryProvider);

    _subscription?.cancel();
    _subscription = repo.watchTasks().listen((tasks) {
      final currentFilter = state.value?.filter ?? TaskFilter.all;
      state = AsyncValue.data(
        TasksViewState(allTasks: tasks, filter: currentFilter),
      );

      _refreshOverdueSummary(tasks);
    }, onError: (err, stack) => state = AsyncValue.error(err, stack));

    return const AsyncValue.loading();
  }

  // ── Accessors ─────────────────────────────────────────────────────────────

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  NotificationNotifier get _notifications =>
      ref.read(notificationProvider.notifier);

  // ── Filter ────────────────────────────────────────────────────────────────

  void setFilter(TaskFilter newFilter) {
    if (state.hasValue) {
      state = AsyncValue.data(
        TasksViewState(allTasks: state.value!.allTasks, filter: newFilter),
      );
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<void> addTask(TasksCompanion task) async {
    try {
      final id = await _repo.addTask(task);

      await _notifications.scheduleTaskReminder(
        taskId: id,
        taskTitle: task.title.value,
        dueDate: task.dueDate.present ? task.dueDate.value : null,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // ── Toggle complete ───────────────────────────────────────────────────────

  Future<void> toggleTask(Task task) async {
    try {
      await _repo.toggleTask(task);

      if (!task.isCompleted) {
        await _notifications.cancelTaskReminder(task.id);
      } else {
        await _notifications.scheduleTaskReminder(
          taskId: task.id,
          taskTitle: task.title,
          dueDate: task.dueDate,
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateTask(TasksCompanion task) async {
    try {
      await _repo.updateTask(task.id.value, task);

      await _notifications.cancelTaskReminder(task.id.value);

      final isCompleted = task.isCompleted.present
          ? task.isCompleted.value
          : false;

      if (!isCompleted) {
        await _notifications.scheduleTaskReminder(
          taskId: task.id.value,
          taskTitle: task.title.value,
          dueDate: task.dueDate.present ? task.dueDate.value : null,
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteTask(int id) async {
    try {
      await _notifications.cancelTaskReminder(id);
      await _repo.deleteTask(id);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // ── Overdue summary ───────────────────────────────────────────────────────

  Future<void> _refreshOverdueSummary(List<Task> tasks) async {
    final now = DateTime.now();
    final overdueCount = tasks
        .where(
          (t) =>
              !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now),
        )
        .length;

    await _notifications.scheduleOverdueTasksSummary(
      overdueCount: overdueCount,
    );
  }
}
