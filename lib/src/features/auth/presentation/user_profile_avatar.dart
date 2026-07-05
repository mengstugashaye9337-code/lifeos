import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:lifeos/src/features/auth/application/profile_controller.dart';
import 'package:lifeos/src/features/auth/presentation/auth_ui_extensions.dart';

class UserProfileAvatar extends ConsumerWidget {
  const UserProfileAvatar({super.key, this.radius = 40});

  final double radius;

  Future<void> _pickAndUploadImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    await ref
        .read(profileControllerProvider.notifier)
        .updateProfileImage(picked.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(profileControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final uploadState = ref.watch(profileControllerProvider);
    final user = authState.value;
    final avatarUrl = user?.avatarUrl;

    final fallbackLetter = user?.avatarFallbackLetter ?? '?';

    return GestureDetector(
      onTap: uploadState.isLoading ? null : () => _pickAndUploadImage(ref),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            foregroundImage: avatarUrl != null && avatarUrl.trim().isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.trim().isEmpty
                ? Text(
                    fallbackLetter,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          if (uploadState.isLoading)
            CircleAvatar(
              radius: radius,
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
        ],
      ),
    );
  }
}
