import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/habits/data/habit_repository.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

part 'habit_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider — depends on interface, not concrete class
// ---------------------------------------------------------------------------

@riverpod
IHabitRepository habitRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepository(db); // swap to RemoteHabitRepository here later
}

// ---------------------------------------------------------------------------
// Habits stream — reactive list of domain models
// ---------------------------------------------------------------------------

@riverpod
Stream<List<HabitModel>> habitListStream(Ref ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
}

// ---------------------------------------------------------------------------
// Habit mutations — AsyncNotifier handles loading + error per action
// ---------------------------------------------------------------------------

@riverpod
class HabitNotifier extends _$HabitNotifier {
  @override
  FutureOr<void> build() {}
  // void state — this notifier owns mutations, not list state
  // the list is owned by habitListStreamProvider above

  IHabitRepository get _repo => ref.read(habitRepositoryProvider);

  Future<void> addHabit(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addHabit(habit));
  }

  Future<void> updateHabit(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateHabit(habit));
  }

  Future<void> deleteHabit(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteHabit(id));
  }

  Future<void> markComplete(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.markComplete(habit));
  }

  Future<void> unmarkComplete(HabitModel habit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.unmarkComplete(habit));
  }
}
