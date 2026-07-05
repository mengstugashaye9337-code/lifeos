// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_sync_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskSyncCoordinator)
final taskSyncCoordinatorProvider = TaskSyncCoordinatorProvider._();

final class TaskSyncCoordinatorProvider
    extends $NotifierProvider<TaskSyncCoordinator, TaskSyncStatus> {
  TaskSyncCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskSyncCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskSyncCoordinatorHash();

  @$internal
  @override
  TaskSyncCoordinator create() => TaskSyncCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskSyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskSyncStatus>(value),
    );
  }
}

String _$taskSyncCoordinatorHash() =>
    r'565d67e881a34e85b3e61cc968d7617cff8b76a9';

abstract class _$TaskSyncCoordinator extends $Notifier<TaskSyncStatus> {
  TaskSyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskSyncStatus, TaskSyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskSyncStatus, TaskSyncStatus>,
              TaskSyncStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
