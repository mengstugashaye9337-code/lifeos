// lib/src/features/ai_assistant/application/ai_controller.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/services/openai_service.dart';

part 'ai_controller.g.dart';

@riverpod
OpenAIService openAIService(Ref ref) {
  final key = dotenv.maybeGet('OPENAI_API_KEY') ?? '';
  return OpenAIService(apiKey: key);
}

@riverpod
class AIController extends _$AIController {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> cleanUpTask(String input) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return ref.read(openAIServiceProvider).getSmartTaskSuggestion(input);
    });
  }

  void reset() => state = const AsyncValue.data(null);
}
