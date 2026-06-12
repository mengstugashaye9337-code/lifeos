import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/src/features/auth/data/auth_mapper.dart';
import 'package:lifeos/src/features/auth/domain/auth_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract — swappable Supabase ↔ any other auth provider
// ---------------------------------------------------------------------------

abstract interface class IAuthRepository {
  // Current signed-in user — null if not authenticated
  AuthModel? get currentUser;

  // Reactive stream — emits on sign in, sign out, token refresh
  Stream<AuthModel?> watchAuthState();

  Future<AuthModel> signUp({required String email, required String password});

  Future<AuthModel> signIn({required String email, required String password});

  Future<void> signOut();
}

// ---------------------------------------------------------------------------
// Supabase implementation
// ---------------------------------------------------------------------------

class AuthRepository implements IAuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // ── Current user ──────────────────────────────────────────────────────────

  @override
  AuthModel? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthMapper.fromSupabaseUser(user);
  }

  // ── Reactive stream ───────────────────────────────────────────────────────
  //
  // Supabase emits AuthChangeEvent on every state change:
  // signedIn, signedOut, tokenRefreshed, userUpdated, passwordRecovery
  // We map each event to AuthModel? — null means signed out

  @override
  Stream<AuthModel?> watchAuthState() {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return AuthMapper.fromSupabaseUser(user);
    });
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  @override
  Future<AuthModel> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    final session = response.session;

    if (user == null) {
      throw Exception('Sign up failed. Please try again.');
    }

    if (session == null) {
      // ✅ Throw a distinct code token when email confirmation is active
      throw Exception('SIGNUP_CONFIRM_EMAIL');
    }

    return AuthMapper.fromSupabaseUser(user);
  }
  // ── Sign in ───────────────────────────────────────────────────────────────

  @override
  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign in failed. Please check your credentials.');
    }

    return AuthMapper.fromSupabaseUser(user);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
