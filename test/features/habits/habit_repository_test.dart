import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/habits/data/habit_repository.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

void main() {
  group('HabitRepository local implementation', () {
    late AppDatabase db;
    late HabitRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
      repository = HabitRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'tracks unsynced habits and marks them synced after local sync',
      () async {
        final now = DateTime.utc(2024, 1, 1, 10);
        final insertedId = await repository.addHabit(
          HabitModel(
            id: 0,
            title: 'Read 20 pages',
            frequency: HabitFrequency.daily,
            streak: 0,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
          ),
        );

        final unsynced = await repository.getUnsyncedHabits();
        expect(unsynced, hasLength(1));
        expect(unsynced.single.id, insertedId);

        await repository.markHabitSynced(
          localId: insertedId,
          remoteId: 'remote-1',
          updatedAt: now.add(const Duration(minutes: 5)),
        );

        final afterSync = await repository.getUnsyncedHabits();
        expect(afterSync, isEmpty);

        final row = await (db.select(
          db.habits,
        )..where((h) => h.id.equals(insertedId))).getSingle();
        expect(row.isSynced, isTrue);
        expect(row.remoteId, 'remote-1');
      },
    );
  });
}
