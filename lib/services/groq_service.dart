import 'dart:convert';
import 'package:Schedule_generator_app/models/app_settings_model.dart';
import 'package:Schedule_generator_app/models/schedule_item_model.dart';
import 'package:Schedule_generator_app/models/task_model.dart';
import 'package:http/http.dart' as http;


class GroqService {
  static const String _apiKey = 'YOUR_GROQ_API_KEY'; // Ganti dengan API key Anda, atau gunakan API pada .env
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  Future<List<ScheduleItem>> generateSchedule({
    required List<Task> tasks,
    required AppSettings settings,
  }) async {
    final pending = tasks.where((t) => !t.isCompleted).toList();
    if (pending.isEmpty) throw Exception('Tidak ada task yang perlu dijadwalkan.');

    final tasksJson = pending
        .map((t) => {
              'id': t.id,
              'title': t.title,
              'duration_minutes': t.duration,
              'priority': t.priorityLabel,
              'deadline': t.deadline?.toIso8601String(),
            })
        .toList();

    final prompt = '''
You are a productivity schedule optimizer. Create an optimized daily schedule for today.

Working hours: ${settings.workStartTime} to ${settings.workEndTime}
Break: ${settings.breakDuration} minutes every ${settings.breakInterval} hour(s)

Tasks:
${json.encode(tasksJson)}

Return ONLY a valid JSON array. No markdown, no explanation, no code blocks. Raw JSON only.
Format:
[
  {
    "taskId": "id from task list",
    "taskTitle": "task title",
    "startTime": "HH:mm",
    "endTime": "HH:mm",
    "notes": "brief note"
  }
]

Rules:
1. Schedule HIGH priority tasks first, then MEDIUM, then LOW
2. Tasks near deadline should be scheduled earlier
3. Insert ${settings.breakDuration}-min breaks every ${settings.breakInterval}h as: taskId="break", taskTitle="Break"
4. Do NOT go beyond ${settings.workEndTime}
5. No overlapping time slots
6. If tasks don't fit, schedule as many as possible within working hours
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: json.encode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
    }

    final data = json.decode(response.body);
    String raw = (data['choices'][0]['message']['content'] ?? '').trim();

    // Bersihkan markdown jika ada
    if (raw.startsWith('```')) {
      raw = raw
          .replaceAll(RegExp(r'```json\n?'), '')
          .replaceAll('```', '')
          .trim();
    }

    try {
      final parsed = json.decode(raw) as List;
      return parsed.map((e) => ScheduleItem.fromJson(e)).toList();
    } catch (_) {
      throw Exception('Gagal memproses respons AI. Coba lagi.');
    }
  }
}
