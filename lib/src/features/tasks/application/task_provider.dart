import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/tasks/application/task_sync_coordinator.dart';
import 'package:lifeos/src/features/tasks/data/remote_task_repository.dart';
import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';
import 'package:lifeos/src/services/notification_provider.dart';
import 'package:lifeos/src/services/supabase_service.dart';

part 'task_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider — depends on interface, not concrete class
// ---------------------------------------------------------------------------

@riverpod
ITaskRepository taskRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  // Session 3 keeps tasks local-first; remote sync is orchestrated explicitly.
  return LocalTaskRepository(db);
}

@riverpod
RemoteTaskRepository remoteTaskRepository(Ref ref) {
  return RemoteTaskRepository(SupabaseService.client);
}

// ---------------------------------------------------------------------------
// Filter enum
// ---------------------------------------------------------------------------

enum TaskFilter { all, pending, completed }

// ---------------------------------------------------------------------------
// Unified view state — stream + filter in one object
// ---------------------------------------------------------------------------

class TasksViewState {
  final List<TaskModel> allTasks;
  final TaskFilter filter;

  TasksViewState({required this.allTasks, required this.filter});

  List<TaskModel> get filteredTasks {
    switch (filter) {
      case TaskFilter.all:
        return allTasks;
      case TaskFilter.pending:
        return allTasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return allTasks.where((t) => t.isCompleted).toList();
    }
  }

  List<TaskModel> get overdueTasks {
    return allTasks.where((t) => t.isOverdue).toList();
  }
}

// ---------------------------------------------------------------------------
// TasksStateNotifier — owns stream, filter, mutations, notifications
// ---------------------------------------------------------------------------

@riverpod
class TasksStateNotifier extends _$TasksStateNotifier {
  StreamSubscription<List<TaskModel>>? _subscription;

  @override
  AsyncValue<TasksViewState> build() {
    ref.onDispose(() => _subscription?.cancel());

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

  ITaskRepository get _repo => ref.read(taskRepositoryProvider);

  NotificationNotifier get _notifications =>
      ref.read(notificationProvider.notifier);

  void _requestSyncIfSignedIn() =>
      ref.read(taskSyncCoordinatorProvider.notifier).requestSync();

  void setFilter(TaskFilter newFilter) {
    if (state.hasValue) {
      state = AsyncValue.data(
        TasksViewState(allTasks: state.value!.allTasks, filter: newFilter),
      );
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final id = await _repo.addTask(task);

      await _notifications.scheduleTaskReminder(
        taskId: id,
        taskTitle: task.title,
        dueDate: task.dueDate,
      );
      _requestSyncIfSignedIn();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleTask(TaskModel task) async {
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
      _requestSyncIfSignedIn();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repo.updateTask(task);

      await _notifications.cancelTaskReminder(task.id);

      if (!task.isCompleted) {
        await _notifications.scheduleTaskReminder(
          taskId: task.id,
          taskTitle: task.title,
          dueDate: task.dueDate,
        );
      }
      _requestSyncIfSignedIn();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _notifications.cancelTaskReminder(id);
      await _repo.deleteTask(id);
      _requestSyncIfSignedIn();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _refreshOverdueSummary(List<TaskModel> tasks) async {
    final overdueCount = tasks.where((t) => t.isOverdue).length;

    await _notifications.scheduleOverdueTasksSummary(
      overdueCount: overdueCount,
    );
  }
}
