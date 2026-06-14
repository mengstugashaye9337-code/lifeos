import 'package:lifeos/src/features/auth/domain/auth_model.dart';

extension AuthModelUi on AuthModel {
  /// Returns a safe fallback character for avatar placeholders.
  /// Falls back to '?' when no valid alphanumeric character exists.
  String get avatarFallbackLetter {
    final base = displayName.trim();
    if (base.isEmpty) return '?';

    final first = base[0].toUpperCase();

    return RegExp(r'[A-Z0-9]').hasMatch(first) ? first : '?';
  }
}
