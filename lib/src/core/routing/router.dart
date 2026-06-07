// lib/src/core/routing/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/src/features/tasks/presentation/task_screen.dart';
import 'package:lifeos/src/features/habits/presentation/habit_screen.dart';
import 'package:lifeos/src/features/notes/presentation/note_list_screen.dart';

// ---------------------------------------------------------------------------
// Route name constants
// ---------------------------------------------------------------------------

abstract class AppRoutes {
  static const home = '/';
  static const tasks = '/tasks';
  static const habits = '/habits';
  static const notes = '/notes';
}

// ---------------------------------------------------------------------------
// Home shell
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

// ---------------------------------------------------------------------------
// Feature tile
// ---------------------------------------------------------------------------

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
    GoRoute(path: AppRoutes.home, builder: (_, __) => const _HomePage()),
    GoRoute(path: AppRoutes.tasks, builder: (_, __) => const TaskScreen()),
    GoRoute(path: AppRoutes.habits, builder: (_, __) => const HabitScreen()),
    GoRoute(path: AppRoutes.notes, builder: (_, __) => const NoteListScreen()),
  ],
);
