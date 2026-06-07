// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noteRepository)
final noteRepositoryProvider = NoteRepositoryProvider._();

final class NoteRepositoryProvider
    extends
        $FunctionalProvider<INoteRepository, INoteRepository, INoteRepository>
    with $Provider<INoteRepository> {
  NoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRepositoryHash();

  @$internal
  @override
  $ProviderElement<INoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  INoteRepository create(Ref ref) {
    return noteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(INoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<INoteRepository>(value),
    );
  }
}

String _$noteRepositoryHash() => r'522283e1ca4c94f5b83dca43c28d803c304a2aee';

@ProviderFor(noteListStream)
final noteListStreamProvider = NoteListStreamProvider._();

final class NoteListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NoteModel>>,
          List<NoteModel>,
          Stream<List<NoteModel>>
        >
    with $FutureModifier<List<NoteModel>>, $StreamProvider<List<NoteModel>> {
  NoteListStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteListStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteListStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<NoteModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NoteModel>> create(Ref ref) {
    return noteListStream(ref);
  }
}

String _$noteListStreamHash() => r'970fde5aaba16fe0dbcae3e7bc019613cceb5ad0';

@ProviderFor(NoteNotifier)
final noteProvider = NoteNotifierProvider._();

final class NoteNotifierProvider
    extends $AsyncNotifierProvider<NoteNotifier, void> {
  NoteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteNotifierHash();

  @$internal
  @override
  NoteNotifier create() => NoteNotifier();
}

String _$noteNotifierHash() => r'52d3d9435f80af48dc8c099f9bef72b8b70ab4a8';

abstract class _$NoteNotifier extends $AsyncNotifier<void> {
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
