// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_briefing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiBriefingNotifier)
final aiBriefingProvider = AiBriefingNotifierProvider._();

final class AiBriefingNotifierProvider
    extends $AsyncNotifierProvider<AiBriefingNotifier, String?> {
  AiBriefingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiBriefingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiBriefingNotifierHash();

  @$internal
  @override
  AiBriefingNotifier create() => AiBriefingNotifier();
}

String _$aiBriefingNotifierHash() =>
    r'bd5919729115c176a91186907ca59fbf005e24c9';

abstract class _$AiBriefingNotifier extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
