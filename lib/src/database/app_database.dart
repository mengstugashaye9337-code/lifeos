import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(1))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // ── v4: sync metadata ──
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  // ── v5: sync metadata ──
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get frequency => text()();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastCompletedDate => dateTime().nullable()();
  // ── v5: sync metadata ──
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Tasks, Notes, Habits, HabitCompletions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5; // ← bumped

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tasks, tasks.createdAt);
        await m.addColumn(tasks, tasks.isSynced);
        await m.addColumn(notes, notes.isSynced);
        await m.addColumn(habits, habits.isSynced);
        await m.addColumn(habits, habits.createdAt);
      }
      if (from < 3) {
        await m.addColumn(habits, habits.lastCompletedDate);
        await m.createTable(habitCompletions);
      }
      if (from < 4) {
        await m.addColumn(tasks, tasks.remoteId);
        await m.addColumn(tasks, tasks.updatedAt);
        await m.addColumn(tasks, tasks.deletedAt);
        await m.database.customStatement(
          'UPDATE tasks SET updated_at = created_at',
        );
      }
      if (from < 5) {
        // ── Habits sync columns ──
        await m.addColumn(habits, habits.remoteId as GeneratedColumn<Object>);
        await m.addColumn(habits, habits.updatedAt as GeneratedColumn<Object>);
        await m.addColumn(habits, habits.deletedAt as GeneratedColumn<Object>);
        await m.database.customStatement(
          'UPDATE habits SET updated_at = created_at',
        );

        // ── Notes sync columns ──
        await m.addColumn(notes, notes.remoteId as GeneratedColumn<Object>);
        await m.addColumn(notes, notes.updatedAt as GeneratedColumn<Object>);
        await m.addColumn(notes, notes.deletedAt as GeneratedColumn<Object>);
        await m.database.customStatement(
          'UPDATE notes SET updated_at = created_at',
        );
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'life_os.sqlite'));
    return NativeDatabase(file);
  });
}
