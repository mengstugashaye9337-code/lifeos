// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(systemStatus)
final systemStatusProvider = SystemStatusProvider._();

final class SystemStatusProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  SystemStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemStatusHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return systemStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$systemStatusHash() => r'32c682752ce86eda9533fe3545fff77792184142';
