import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/services/openai_service.dart';

part 'ai_controller.g.dart';

@riverpod
class AIController extends _$AIController {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> cleanUpTask(String input) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = OpenAIService(); // In a real app, use a provider for this
      return await service.getSmartTaskSuggestion(input);
    });
  }
}
