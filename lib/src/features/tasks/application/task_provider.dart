// lib/src/features/tasks/application/task_provider.dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/database/app_database.dart';

part 'task_provider.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskRepository(db);
}

enum TaskFilter { all, pending, completed }

/// This configuration state holds both our raw tasks and the active UI filter
class TasksViewState {
  final List<Task> allTasks;
  final TaskFilter filter;

  TasksViewState({required this.allTasks, required this.filter});

  /// Computed property that your UI can easily read synchronously
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
}

/// The single manager provider for your entire Task screen UI state
@riverpod
class TasksStateNotifier extends _$TasksStateNotifier {
  StreamSubscription<List<Task>>? _subscription;

  @override
  AsyncValue<TasksViewState> build() {
    // Whenever this provider is destroyed or unmounted, clean up database stream allocations
    ref.onDispose(() => _subscription?.cancel());

    // Start listening to the Drift database real-time stream repository channel
    _subscription?.cancel();
    _subscription = ref.watch(taskRepositoryProvider).watchTasks().listen((
      tasks,
    ) {
      final currentFilter = state.value?.filter ?? TaskFilter.all;
      state = AsyncValue.data(
        TasksViewState(allTasks: tasks, filter: currentFilter),
      );
    }, onError: (err, stack) => state = AsyncValue.error(err, stack));

    return const AsyncValue.loading();
  }

  /// Changes the visible filter view state without forcing a database reload
  void setFilter(TaskFilter newFilter) {
    if (state.hasValue) {
      state = AsyncValue.data(
        TasksViewState(allTasks: state.value!.allTasks, filter: newFilter),
      );
    }
  }
}
