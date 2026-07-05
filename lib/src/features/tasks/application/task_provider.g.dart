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
    extends
        $FunctionalProvider<ITaskRepository, ITaskRepository, ITaskRepository>
    with $Provider<ITaskRepository> {
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
  $ProviderElement<ITaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ITaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ITaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ITaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'4845f304cfab6ea6735595272482ba40b93de6b6';

@ProviderFor(remoteTaskRepository)
final remoteTaskRepositoryProvider = RemoteTaskRepositoryProvider._();

final class RemoteTaskRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteTaskRepository,
          RemoteTaskRepository,
          RemoteTaskRepository
        >
    with $Provider<RemoteTaskRepository> {
  RemoteTaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteTaskRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteTaskRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteTaskRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteTaskRepository create(Ref ref) {
    return remoteTaskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteTaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteTaskRepository>(value),
    );
  }
}

String _$remoteTaskRepositoryHash() =>
    r'a5e0f9a380de1f2ef28bf21ccb96388f593a9c50';

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
    r'700aeb9ed8efa41f040371159606c830639b5ad2';

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
