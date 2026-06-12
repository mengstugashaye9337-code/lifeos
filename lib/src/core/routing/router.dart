import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/src/core/routing/router_refresh_stream.dart';
import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:lifeos/src/features/auth/domain/auth_model.dart';
import 'package:lifeos/src/features/auth/presentation/login_screen.dart';
import 'package:lifeos/src/features/auth/presentation/signup_screen.dart';
import 'package:lifeos/src/features/home/presentation/home_screen.dart';
import 'package:lifeos/src/features/tasks/presentation/task_screen.dart';
import 'package:lifeos/src/features/habits/presentation/habit_screen.dart';
import 'package:lifeos/src/features/notes/presentation/note_list_screen.dart';

// ---------------------------------------------------------------------------
// Route name constants
// ---------------------------------------------------------------------------

abstract class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/';
  static const tasks = '/tasks';
  static const habits = '/habits';
  static const notes = '/notes';
}

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------

GoRouter createRouter(WidgetRef ref) {
  // Read auth state — AsyncValue<AuthModel?>
  // authProvider is keepAlive — safe to read on every build
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,

    // GoRouterRefreshStream bridges the Riverpod stream → GoRouter Listenable
    // Fires redirect re-evaluation on every auth state change
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).watchAuthState(),
    ),

    // ✅ PASTE THIS NEW BLOCK INSTEAD:
    redirect: (context, state) {
      // Session still resolving — hold position, never flash login
      if (authAsync.isLoading) {
        return null;
      }

      // Explicit pattern matching forces the compiler to unwrap the state cleanly
      final AuthModel? user = authAsync.maybeWhen(
        data: (userModel) => userModel,
        orElse: () => null,
      );

      final bool isLoggedIn = user != null;
      final bool isOnAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Not authenticated → force to login
      if (!isLoggedIn && !isOnAuthRoute) {
        return AppRoutes.login;
      }

      // Authenticated and trying to access login/signup → force to home
      if (isLoggedIn && isOnAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: AppRoutes.tasks, builder: (_, __) => const TaskScreen()),
      GoRoute(path: AppRoutes.habits, builder: (_, __) => const HabitScreen()),
      GoRoute(
        path: AppRoutes.notes,
        builder: (_, __) => const NoteListScreen(),
      ),
    ],
  );
}
