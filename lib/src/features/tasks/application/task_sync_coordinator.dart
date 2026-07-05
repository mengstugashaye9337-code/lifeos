import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/features/tasks/data/remote_task_repository.dart';
import 'package:lifeos/src/features/tasks/data/task_repository.dart';

part 'task_sync_coordinator.g.dart';

enum TaskSyncStatus { idle, syncing, success, error }

class TaskSyncResult {
  final int pushed;
  final int pulled;
  final int skippedLocalDeletes;

  const TaskSyncResult({
    required this.pushed,
    required this.pulled,
    required this.skippedLocalDeletes,
  });

  static const empty = TaskSyncResult(pushed: 0, pulled: 0, skippedLocalDeletes: 0);
}

@Riverpod(keepAlive: true)
class TaskSyncCoordinator extends _$TaskSyncCoordinator {
  Timer? _debounce;
  DateTime? _lastSyncAt;

  @override
  TaskSyncStatus build() {
    ref.onDispose(() => _debounce?.cancel());

    // Full sync when user signs in.
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      final wasSignedOut = previous?.value == null;
      final isSignedIn = next.value != null;
      if (wasSignedOut && isSignedIn) {
        unawaited(sync());
      }
    });

    return TaskSyncStatus.idle;
  }

  LocalTaskRepository get _localRepo {
    final repo = ref.read(taskRepositoryProvider);
    if (repo is! LocalTaskRepository) {
      throw StateError('Task sync requires LocalTaskRepository.');
    }
    return repo;
  }

  RemoteTaskRepository get _remoteRepo => ref.read(remoteTaskRepositoryProvider);

  bool get _isSignedIn => ref.read(authProvider).value != null;

  /// Debounced sync — call after local mutations.
  void requestSync() {
    if (!_isSignedIn) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(sync());
    });
  }

  Future<TaskSyncResult> sync() async {
    if (!_isSignedIn) return TaskSyncResult.empty;

    state = TaskSyncStatus.syncing;

    try {
      final result = await _runPushPull();
      _lastSyncAt = DateTime.now();
      state = TaskSyncStatus.success;
      return result;
    } catch (_) {
      state = TaskSyncStatus.error;
      rethrow;
    } finally {
      // Return to idle after a short beat so UI can show success/error.
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (ref.mounted) state = TaskSyncStatus.idle;
      });
    }
  }

  Future<TaskSyncResult> _runPushPull() async {
    int pushed = 0;
    int skippedLocalDeletes = 0;

    final unsynced = await _localRepo.getUnsyncedTasks();

    for (final local in unsynced) {
      if (local.isDeleted && local.remoteId == null) {
        await _localRepo.markTaskSynced(
          localId: local.id,
          updatedAt: DateTime.now(),
        );
        skippedLocalDeletes++;
        continue;
      }

      if (local.isDeleted) {
        await _remoteRepo.softDeleteTask(local);
        await _localRepo.markTaskSynced(
          localId: local.id,
          remoteId: local.remoteId!,
          updatedAt: DateTime.now(),
        );
        pushed++;
        continue;
      }

      final remote = await _remoteRepo.syncTask(local);
      await _localRepo.markTaskSynced(
        localId: local.id,
        remoteId: remote.remoteId!,
        updatedAt: remote.updatedAt,
      );
      pushed++;
    }

    final remoteTasks = _lastSyncAt == null
        ? await _remoteRepo.fetchTasks(includeDeleted: true)
        : await _remoteRepo.fetchSince(_lastSyncAt!, includeDeleted: true);

    for (final remote in remoteTasks) {
      await _localRepo.upsertFromRemote(remote);
    }

    return TaskSyncResult(
      pushed: pushed,
      pulled: remoteTasks.length,
      skippedLocalDeletes: skippedLocalDeletes,
    );
  }
}
