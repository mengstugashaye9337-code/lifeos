// lib/src/features/tasks/application/task_ai_bridge.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/features/ai_assistant/application/ai_controller.dart';

part 'task_ai_bridge.g.dart';

/// Bridge between the tasks feature and the AI feature.
/// The presentation layer only knows about this — never about ai_controller directly.
@riverpod
class TaskAiBridge extends _$TaskAiBridge {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<String?> cleanUpTask(String input) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // 1. Tell the AI controller to run its process (which updates its state internally)
      await ref.read(aIControllerProvider.notifier).cleanUpTask(input);

      // 2. Read the resulting value out of the AI controller state and return it
      final aiState = ref.read(aIControllerProvider);
      return aiState.value;
    });

    return state.value;
  }

  void reset() => state = const AsyncValue.data(null);
}
