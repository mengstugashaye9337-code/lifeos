import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/src/features/auth/domain/auth_model.dart';

class AuthMapper {
  AuthMapper._(); // not instantiable — pure static utility

  // ── Supabase User → Domain Model ───────────────────────────────────────

  static AuthModel fromSupabaseUser(User user) => AuthModel(
    id: user.id,
    email: user.email ?? '',
    createdAt: DateTime.parse(user.createdAt),
    avatarUrl: user.userMetadata?['avatar_url'] as String?,
  );
}
