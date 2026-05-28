// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_ai_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bridge between the tasks feature and the AI feature.
/// The presentation layer only knows about this — never about ai_controller directly.

@ProviderFor(TaskAiBridge)
final taskAiBridgeProvider = TaskAiBridgeProvider._();

/// Bridge between the tasks feature and the AI feature.
/// The presentation layer only knows about this — never about ai_controller directly.
final class TaskAiBridgeProvider
    extends $NotifierProvider<TaskAiBridge, AsyncValue<String?>> {
  /// Bridge between the tasks feature and the AI feature.
  /// The presentation layer only knows about this — never about ai_controller directly.
  TaskAiBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskAiBridgeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskAiBridgeHash();

  @$internal
  @override
  TaskAiBridge create() => TaskAiBridge();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$taskAiBridgeHash() => r'75ba4c3304277925f0dfc10dc6d6e748146bf140';

/// Bridge between the tasks feature and the AI feature.
/// The presentation layer only knows about this — never about ai_controller directly.

abstract class _$TaskAiBridge extends $Notifier<AsyncValue<String?>> {
  AsyncValue<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, AsyncValue<String?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, AsyncValue<String?>>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
