// lib/src/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const _baseUrl = 'https://api.openai.com/v1';

  // Key is injected so the service is testable and easy to mock.
  // In production, pass the value from flutter_dotenv:
  //   OpenAIService(apiKey: dotenv.env['OPENAI_API_KEY'] ?? '')
  final String apiKey;

  const OpenAIService({required this.apiKey});

  Future<String> getSmartTaskSuggestion(String rawInput) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'Convert the user\'s messy note into a single clean, '
                'concise task title. Return only the task title — '
                'no explanation, no punctuation at the end.',
          },
          {'role': 'user', 'content': rawInput},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }
  }
}
