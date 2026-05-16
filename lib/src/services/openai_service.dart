// OpenAI service for AI assistant
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _baseUrl = 'https://api.openai.com/v1';

  // Method to interact with OpenAI API
  Future<String> getSmartTaskSuggestion(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response from OpenAI');
    }
  }
}
