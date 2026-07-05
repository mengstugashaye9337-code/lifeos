import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const _baseUrl = 'https://api.openai.com/v1';

  final String apiKey;
  const OpenAIService({required this.apiKey});

  // ── Private HTTP helper — single place for headers + error handling ───────

  Future<Map<String, dynamic>> _post({
    required List<Map<String, String>> messages,
    int maxTokens = 500,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'max_tokens': maxTokens,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
  }

  // ── Extract content from response — single place for parsing ─────────────

  String _extractContent(Map<String, dynamic> data) =>
      (data['choices'][0]['message']['content'] as String).trim();

  // ── Public methods ────────────────────────────────────────────────────────

  Future<String> getSmartTaskSuggestion(String rawInput) async {
    final data = await _post(
      maxTokens: 60,
      messages: [
        {
          'role': 'system',
          'content':
              'Convert the user\'s messy note into a single clean, '
              'concise task title. Return only the task title — '
              'no explanation, no punctuation at the end.',
        },
        {'role': 'user', 'content': rawInput},
      ],
    );
    return _extractContent(data);
  }

  Future<String> getDailyBriefing({
    required int pendingTasksCount,
    required int overdueTasksCount,
    required List<String> dueTodayTaskTitles,
    required int completedTodayTasksCount,
    required int totalHabitsCount,
    required int completedTodayHabitsCount,
    required int pendingTodayHabitsCount,
    required int bestStreak,
  }) async {
    final dueTodayText = dueTodayTaskTitles.isEmpty
        ? 'none'
        : dueTodayTaskTitles.join(', ');

    final data = await _post(
      maxTokens: 120,
      messages: [
        {
          'role': 'system',
          'content':
              'You are a personal productivity assistant '
              'inside a life management app called LifeOS. '
              'Write short, warm, motivating daily briefings '
              'based on the user\'s real data. '
              '2-3 sentences maximum. '
              'No bullet points. Natural flowing text. '
              'Be specific about their data. '
              'Be encouraging but honest about overdue items.',
        },
        {
          'role': 'user',
          'content':
              '''
My productivity data for today:

TASKS:
- Pending: $pendingTasksCount
- Overdue: $overdueTasksCount
- Due today: $dueTodayText
- Completed today: $completedTodayTasksCount

HABITS:
- Total: $totalHabitsCount
- Completed today: $completedTodayHabitsCount
- Still pending: $pendingTodayHabitsCount
- Best streak: $bestStreak days

Write my daily briefing.
''',
        },
      ],
    );
    return _extractContent(data);
  }
}
