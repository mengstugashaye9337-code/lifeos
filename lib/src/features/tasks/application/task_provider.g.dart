// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'5516d58b168da4130aff6e838768867a71f59b3f';

@ProviderFor(TasksStateNotifier)
final tasksStateProvider = TasksStateNotifierProvider._();

final class TasksStateNotifierProvider
    extends $NotifierProvider<TasksStateNotifier, AsyncValue<TasksViewState>> {
  TasksStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksStateNotifierHash();

  @$internal
  @override
  TasksStateNotifier create() => TasksStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TasksViewState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TasksViewState>>(value),
    );
  }
}

String _$tasksStateNotifierHash() =>
    r'00668ffc6e8027459a21bb0adb139d42db1a77d3';

abstract class _$TasksStateNotifier
    extends $Notifier<AsyncValue<TasksViewState>> {
  AsyncValue<TasksViewState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TasksViewState>, AsyncValue<TasksViewState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TasksViewState>,
                AsyncValue<TasksViewState>
              >,
              AsyncValue<TasksViewState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
