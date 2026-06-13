import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:lifeos/src/features/auth/domain/auth_model.dart';
import 'package:lifeos/src/features/auth/presentation/login_screen.dart';
import 'package:lifeos/src/features/auth/presentation/signup_screen.dart';
import 'package:lifeos/src/features/home/presentation/home_screen.dart';
import 'package:lifeos/src/features/tasks/presentation/task_screen.dart';
import 'package:lifeos/src/features/habits/presentation/habit_screen.dart';
import 'package:lifeos/src/features/notes/presentation/note_list_screen.dart';
import 'package:lifeos/src/features/settings/presentation/settings_screen.dart';

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
  static const settings = '/settings';
}

// ---------------------------------------------------------------------------
// Stable Gatekeeper Notifier
// ---------------------------------------------------------------------------
class RouterAuthNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isInitialized = false;

  RouterAuthNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthModel?>>(authProvider, (previous, next) {
      // SENIOR INSIGHT: If the state is transitioning through loading
      // or contains an unhandled error, we intentionally swallow the event
      // to prevent GoRouter from evaluating intermediate states.
      if (next.isLoading || next.hasError) {
        return;
      }

      // Only notify GoRouter when a definitive, terminal state change occurs
      if (previous?.value != next.value || !_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
    }, fireImmediately: true);
  }
}

// Global provider to manage our gatekeeper's lifecycle cleanly
final routerAuthNotifierProvider = Provider.autoDispose((ref) {
  return RouterAuthNotifier(ref);
});

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------
GoRouter createRouter(WidgetRef ref) {
  // Watch our stable, filtered listener instead of the raw, flickering state
  final authListener = ref.watch(routerAuthNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,

    // ✅ FIXED: Single, clean, stable listenable reference
    refreshListenable: authListener,

    redirect: (context, state) {
      // Read current state atomically at this exact instant
      final authState = ref.read(authProvider);

      // Gatekeeper: If the state is fundamentally unstable or erroring out, freeze navigation
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final AuthModel? user = authState.value;
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
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
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
