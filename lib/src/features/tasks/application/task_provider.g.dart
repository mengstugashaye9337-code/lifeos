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

/// The single manager provider for your entire Task screen UI state

@ProviderFor(TasksStateNotifier)
final tasksStateProvider = TasksStateNotifierProvider._();

/// The single manager provider for your entire Task screen UI state
final class TasksStateNotifierProvider
    extends $NotifierProvider<TasksStateNotifier, AsyncValue<TasksViewState>> {
  /// The single manager provider for your entire Task screen UI state
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
    r'938c1ee09fb729a4c0ebb870798d72cc6a4bc57d';

/// The single manager provider for your entire Task screen UI state

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
