import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/src/core/routing/router.dart';
import 'package:lifeos/src/core/theme/theme.dart';
import 'package:lifeos/src/features/tasks/application/task_sync_coordinator.dart';
import 'package:lifeos/src/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();
  runApp(const ProviderScope(child: LifeOSApp()));
}

class LifeOSApp extends ConsumerWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    // Keep sync coordinator alive for auth-triggered background sync.
    ref.watch(taskSyncCoordinatorProvider);
    final router = createRouter(ref);
    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      routerConfig: router,
    );
  }
}
