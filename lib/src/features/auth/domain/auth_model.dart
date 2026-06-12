import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String id,
    required String email,
    required DateTime createdAt,
  }) = _AuthModel;

  const AuthModel._();

  // Convenience — display name derived from email
  // "john.doe@gmail.com" → "john.doe"
  // Used in settings screen before we add display name support
  String get displayName => email.split('@').first;

  // Convenience — is this a valid non-empty user
  bool get isValid => id.isNotEmpty && email.isNotEmpty;
}
