import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/src/core/routing/router.dart';
import 'package:lifeos/src/services/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) requestNotificationPermissionsIfNeeded(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _FeatureTile(
            icon: Icons.check_circle_outline,
            title: 'Tasks',
            subtitle: 'Manage your to-dos',
            onTap: () => context.push(AppRoutes.tasks),
          ),
          _FeatureTile(
            icon: Icons.loop_rounded,
            title: 'Habits',
            subtitle: 'Build streaks, track consistency',
            onTap: () => context.push(AppRoutes.habits),
          ),
          _FeatureTile(
            icon: Icons.notes_outlined,
            title: 'Notes',
            subtitle: 'Capture your thoughts',
            onTap: () => context.push(AppRoutes.notes),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
