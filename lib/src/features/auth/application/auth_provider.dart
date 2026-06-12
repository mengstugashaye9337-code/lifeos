import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/src/features/auth/data/auth_repository.dart';
import 'package:lifeos/src/features/auth/domain/auth_model.dart';

part 'auth_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider — injects SupabaseClient, returns interface
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

// ---------------------------------------------------------------------------
// Auth notifier — owns auth state + all mutations
//
// keepAlive: true — router watches this, must never be disposed
// State: AsyncValue<AuthModel?> — null means signed out
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<AuthModel?>? _subscription;

  @override
  FutureOr<AuthModel?> build() {
    ref.onDispose(() => _subscription?.cancel());

    final repo = ref.read(authRepositoryProvider);

    // Listen to Supabase auth state changes reactively
    // Fires on: signIn, signOut, tokenRefresh, appRestart with valid session
    _subscription = repo.watchAuthState().listen(
      (user) => state = AsyncValue.data(user),
      onError: (err, stack) => state = AsyncValue.error(err, stack),
    );

    // Return current user synchronously on first build
    // This handles app restart with existing session — no loading flash
    return repo.currentUser;
  }

  IAuthRepository get _repo => ref.read(authRepositoryProvider);

  // ── Sign in ───────────────────────────────────────────────────────────────

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email, password: password),
    );
  }

  // ── Sign up ───────────────────────────────────────────────────────────────

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signUp(email: email, password: password),
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signOut();
      return null; // signed out = null user
    });
  }
}
