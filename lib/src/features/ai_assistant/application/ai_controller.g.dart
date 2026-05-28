// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(openAIService)
final openAIServiceProvider = OpenAIServiceProvider._();

final class OpenAIServiceProvider
    extends $FunctionalProvider<OpenAIService, OpenAIService, OpenAIService>
    with $Provider<OpenAIService> {
  OpenAIServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openAIServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openAIServiceHash();

  @$internal
  @override
  $ProviderElement<OpenAIService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpenAIService create(Ref ref) {
    return openAIService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenAIService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenAIService>(value),
    );
  }
}

String _$openAIServiceHash() => r'13c0372b18a48899cf95450fc26e9582b81cbab7';

@ProviderFor(AIController)
final aIControllerProvider = AIControllerProvider._();

final class AIControllerProvider
    extends $NotifierProvider<AIController, AsyncValue<String?>> {
  AIControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aIControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aIControllerHash();

  @$internal
  @override
  AIController create() => AIController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$aIControllerHash() => r'85b7f6ccf7663daef6e36bd54f94e3a68025fd65';

abstract class _$AIController extends $Notifier<AsyncValue<String?>> {
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
