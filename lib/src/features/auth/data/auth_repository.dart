import 'dart:io';

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

  Future<String> updateAvatar({required String localFilePath});
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

  @override
  Future<String> updateAvatar({required String localFilePath}) async {
    // 1) Resolve the signed-in identity first.
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You must be signed in to update your avatar.');
    }

    final storage = _client.storage.from('avatars');
    final objectPath = '$userId/profile.jpg';
    final file = File(localFilePath);

    // 2) Guard against invalid local input before touching storage.
    if (!await file.exists()) {
      throw Exception('Avatar upload failed. The selected file was not found.');
    }

    try {
      // 3) Upload deterministically to the user-scoped object path.
      await storage.uploadBinary(
        objectPath,
        await file.readAsBytes(),
        fileOptions: const FileOptions(upsert: true),
      );

      // 4) Resolve the public link immediately after upload.
      final publicUrl = storage.getPublicUrl(objectPath);

      try {
        // 5) Persist the URL into the active auth session metadata.
        await _client.auth.updateUser(
          UserAttributes(
            data: {'avatar_url': publicUrl},
          ),
        );
      } catch (_) {
        // 6) Roll back the uploaded object if auth metadata sync fails.
        try {
          await storage.remove([objectPath]);
        } catch (_) {
          // Best-effort cleanup only; do not mask the primary failure.
        }
        throw Exception(
          'Avatar uploaded, but syncing your profile failed. Please try again.',
        );
      }

      // 7) Return only the final public URL.
      return publicUrl;
    } catch (_) {
      rethrow;
    }
  }
}
