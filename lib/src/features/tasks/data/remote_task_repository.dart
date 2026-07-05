import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/src/features/tasks/data/task_mapper.dart';
import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';

class RemoteTaskRepository implements ITaskRepository {
  final SupabaseClient _client;
  static const String _table = 'tasks';

  RemoteTaskRepository(this._client);

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Supabase user is not signed in.');
    }
    return id;
  }

  @override
  Stream<List<TaskModel>> watchTasks() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('updated_at')
        .map(
          (rows) => rows.cast<Map<String, dynamic>>().map(TaskMapper.fromRemoteRow).toList(),
        );
  }

  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    return const [];
  }

  @override
  Future<int> addTask(TaskModel task) async {
    final created = await createTask(task);
    return created.id;
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await syncTask(task);
  }

  @override
  Future<void> toggleTask(TaskModel task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  @override
  Future<void> deleteTask(int id) async {
    throw UnsupportedError(
      'RemoteTaskRepository.deleteTask requires remote UUID. Use softDeleteTask(TaskModel).',
    );
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final payload = TaskMapper.toRemoteRow(task, userId: _userId);
    final row = await _client.from(_table).insert(payload).select().single();
    return TaskMapper.fromRemoteRow(row);
  }

  Future<TaskModel> syncTask(TaskModel task) async {
    if (task.remoteId == null) {
      return createTask(task);
    }

    final row = await _client
        .from(_table)
        .update(TaskMapper.toRemoteRow(task, userId: _userId))
        .eq('id', task.remoteId!)
        .eq('user_id', _userId)
        .select()
        .single();
    return TaskMapper.fromRemoteRow(row);
  }

  Future<TaskModel> softDeleteTask(TaskModel task) async {
    final remoteId = task.remoteId;
    if (remoteId == null) {
      throw StateError('Task must have a remoteId to delete on Supabase.');
    }

    final row = await _client
        .from(_table)
        .update({
          'deleted_at':
              task.deletedAt?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', remoteId)
        .eq('user_id', _userId)
        .select()
        .single();
    return TaskMapper.fromRemoteRow(row);
  }

  Future<List<TaskModel>> fetchTasks({bool includeDeleted = false}) async {
    final query = _client.from(_table).select().eq('user_id', _userId);
    final rows = await (includeDeleted ? query : query.isFilter('deleted_at', null)).order(
      'updated_at',
      ascending: false,
    );
    return rows.cast<Map<String, dynamic>>().map(TaskMapper.fromRemoteRow).toList();
  }

  Future<List<TaskModel>> fetchSince(DateTime since, {bool includeDeleted = true}) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .gte('updated_at', since.toIso8601String())
        .order('updated_at', ascending: true);

    final parsed = rows.cast<Map<String, dynamic>>().map(TaskMapper.fromRemoteRow);
    return includeDeleted ? parsed.toList() : parsed.where((t) => !t.isDeleted).toList();
  }
}
