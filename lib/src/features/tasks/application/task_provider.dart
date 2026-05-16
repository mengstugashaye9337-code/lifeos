import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/database/database_provider.dart';

part 'task_provider.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskRepository(db);
}

@riverpod
Stream<List<Task>> taskListStream(Ref ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
}
