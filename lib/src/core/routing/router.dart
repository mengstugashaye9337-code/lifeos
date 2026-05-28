// lib/src/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/src/features/tasks/presentation/task_screen.dart';

// ---------------------------------------------------------------------------
// Route name constants — use these everywhere instead of raw strings
// ---------------------------------------------------------------------------
abstract class AppRoutes {
  static const home = '/';
  static const tasks = '/tasks';
  // Uncomment as you complete each feature:
  // static const notes   = '/notes';
  // static const habits  = '/habits';
}

// ---------------------------------------------------------------------------
// Home shell — navigation hub shown at launch
// ---------------------------------------------------------------------------
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LifeOS')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _FeatureTile(
            icon: Icons.check_circle_outline,
            title: 'Tasks',
            subtitle: 'Manage your to-dos',
            onTap: () => context.push(AppRoutes.tasks),
          ),
          // Add tiles here as you complete each feature:
          // _FeatureTile(title: 'Notes', onTap: () => context.push(AppRoutes.notes)),
          // _FeatureTile(title: 'Habits', onTap: () => context.push(AppRoutes.habits)),
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

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
final goRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _HomePage(),
    ),
    GoRoute(
      path: AppRoutes.tasks,
      builder: (context, state) => const TaskScreen(),
    ),
    // Add routes here as you complete each feature:
    // GoRoute(path: AppRoutes.notes,  builder: (_, __) => const NoteListScreen()),
    // GoRoute(path: AppRoutes.habits, builder: (_, __) => const HabitScreen()),
  ],
);
