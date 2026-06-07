// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitRepository)
final habitRepositoryProvider = HabitRepositoryProvider._();

final class HabitRepositoryProvider
    extends
        $FunctionalProvider<
          IHabitRepository,
          IHabitRepository,
          IHabitRepository
        >
    with $Provider<IHabitRepository> {
  HabitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitRepositoryHash();

  @$internal
  @override
  $ProviderElement<IHabitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IHabitRepository create(Ref ref) {
    return habitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IHabitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IHabitRepository>(value),
    );
  }
}

String _$habitRepositoryHash() => r'b2218f44c133428fc74b3fc1f3bb78a6393b6d1d';

@ProviderFor(habitListStream)
final habitListStreamProvider = HabitListStreamProvider._();

final class HabitListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitModel>>,
          List<HabitModel>,
          Stream<List<HabitModel>>
        >
    with $FutureModifier<List<HabitModel>>, $StreamProvider<List<HabitModel>> {
  HabitListStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitListStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitListStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<HabitModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitModel>> create(Ref ref) {
    return habitListStream(ref);
  }
}

String _$habitListStreamHash() => r'd8bce52dcae5dd5398505df574f90c8b9b7269b8';

@ProviderFor(HabitNotifier)
final habitProvider = HabitNotifierProvider._();

final class HabitNotifierProvider
    extends $AsyncNotifierProvider<HabitNotifier, void> {
  HabitNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitNotifierHash();

  @$internal
  @override
  HabitNotifier create() => HabitNotifier();
}

String _$habitNotifierHash() => r'347ea77f290578ed37ef2c33261a62ebf32b3e2a';

abstract class _$HabitNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
