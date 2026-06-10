import 'package:go_router/go_router.dart';
import 'package:lifeos/src/features/home/presentation/home_screen.dart';
import 'package:lifeos/src/features/tasks/presentation/task_screen.dart';
import 'package:lifeos/src/features/habits/presentation/habit_screen.dart';
import 'package:lifeos/src/features/notes/presentation/note_list_screen.dart';

abstract class AppRoutes {
  static const home = '/';
  static const tasks = '/tasks';
  static const habits = '/habits';
  static const notes = '/notes';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
    GoRoute(path: AppRoutes.tasks, builder: (_, __) => const TaskScreen()),
    GoRoute(path: AppRoutes.habits, builder: (_, __) => const HabitScreen()),
    GoRoute(path: AppRoutes.notes, builder: (_, __) => const NoteListScreen()),
  ],
);
