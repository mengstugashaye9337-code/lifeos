import 'dart:async';

import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {
    // Idle state: this controller owns no local profile data.
  }

  Future<void> updateProfileImage(String localFilePath) async {
    // Idle -> Loading
    state = const AsyncLoading();

    // Loading -> Data/Error
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateAvatar(localFilePath: localFilePath);
      // Session refresh is handled by AuthRepository.watchAuthState().
    });
  }
}
