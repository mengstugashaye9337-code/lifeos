import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_database.dart';

// This line allows Riverpod to generate the 'appDatabaseProvider'
part 'database_provider.g.dart';

@riverpod
AppDatabase appDatabase(Ref ref) {
  // We create a single instance of the database to be shared across the app
  final db = AppDatabase();

  // Optional: Ensure the database is closed when the provider is disposed
  ref.onDispose(() => db.close());

  return db;
}
