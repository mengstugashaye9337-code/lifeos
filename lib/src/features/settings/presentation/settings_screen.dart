import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:lifeos/src/features/tasks/application/task_sync_coordinator.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  Future<void> _syncTasks(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref.read(taskSyncCoordinatorProvider.notifier).sync();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synced ${result.pushed} up, ${result.pulled} down',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final syncStatus = ref.watch(taskSyncCoordinatorProvider);
    final user = authState.value;
    final colorScheme = Theme.of(context).colorScheme;
    final email = user?.email;
    final initial = email != null && email.isNotEmpty
        ? email[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(initial)),
              title: Text(email ?? ''),
              subtitle: const Text('Member'),
            ),
          ),
          const SizedBox(height: 16),
          if (user != null) ...[
            FilledButton.tonalIcon(
              onPressed: syncStatus == TaskSyncStatus.syncing
                  ? null
                  : () => _syncTasks(context, ref),
              icon: syncStatus == TaskSyncStatus.syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                syncStatus == TaskSyncStatus.syncing
                    ? 'Syncing tasks...'
                    : 'Sync tasks now',
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
