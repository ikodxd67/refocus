import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pause_reason.dart';

/// The text shown during a pause: a personal, loss-framed reframe plus the
/// "cost mirror" line.
class Reframe {
  final String line; // the main 2nd-person sentence
  final String costLine; // e.g. "Today · 7 opens"
  final String? goalLine; // the user's own goal, if set
  final bool fromAi;

  const Reframe({
    required this.line,
    required this.costLine,
    this.goalLine,
    this.fromAi = false,
  });
}

/// Builds the reframe. Tries Gemini when the user enabled AI and gave a key;
/// otherwise (and on any failure) falls back to an offline template so the
/// pause screen ALWAYS has something to say.
class ReframeService {
  final http.Client _client;
  ReframeService({http.Client? client}) : _client = client ?? http.Client();

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<Reframe> build({
    required String appName,
    required PauseReason reason,
    required String goal,
    required int opensToday,
    required int minutesToday,
    required bool aiReady,
    required String apiKey,
    DateTime? now,
  }) async {
    final cost = _costLine(opensToday, minutesToday);
    final goalLine = goal.trim().isEmpty ? null : goal.trim();

    if (aiReady) {
      try {
        final line = await _gemini(
          appName: appName,
          reason: reason,
          goal: goal,
          opensToday: opensToday,
          now: now ?? DateTime.now(),
          apiKey: apiKey,
        );
        if (line != null && line.trim().isNotEmpty) {
          return Reframe(
            line: line.trim(),
            costLine: cost,
            goalLine: goalLine,
            fromAi: true,
          );
        }
      } catch (_) {
        // fall through to offline template
      }
    }

    return Reframe(
      line: offlineLine(
        appName: appName,
        reason: reason,
        goal: goal,
        opensToday: opensToday,
      ),
      costLine: cost,
      goalLine: goalLine,
      fromAi: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Offline templates — no network, no key required.
  // ---------------------------------------------------------------------------

  String offlineLine({
    required String appName,
    required PauseReason reason,
    required String goal,
    required int opensToday,
  }) {
    final g = goal.trim();
    final goalClause = g.isEmpty ? '' : ' You said: “$g.”';
    switch (reason) {
      case PauseReason.bored:
        return 'Boredom passes in a couple of minutes. A scroll session usually '
            'takes far longer from you.$goalClause';
      case PauseReason.quickBreak:
        return 'A real break rests your mind — an endless feed just refills it '
            'with noise.$goalClause';
      case PauseReason.specific:
        return 'Looking for something specific? Do that one thing, then come '
            'back up for air before the feed takes over.$goalClause';
      case PauseReason.habit:
        return 'This one is just muscle memory — you have reached for $appName '
            '$opensToday ${opensToday == 1 ? 'time' : 'times'} today.$goalClause';
    }
  }

  String _costLine(int opens, int minutes) {
    final parts = <String>['$opens ${opens == 1 ? 'open' : 'opens'}'];
    if (minutes > 0) parts.add('$minutes min');
    return 'Today · ${parts.join(' · ')}';
  }

  // ---------------------------------------------------------------------------
  // Gemini 1.5 Flash — one short, personal, loss-framed sentence.
  // ---------------------------------------------------------------------------

  Future<String?> _gemini({
    required String appName,
    required PauseReason reason,
    required String goal,
    required int opensToday,
    required DateTime now,
    required String apiKey,
  }) async {
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final goalText = goal.trim().isEmpty ? '(none given)' : goal.trim();

    final prompt = '''
You write a single short sentence shown when someone is about to open a
time-sink app, to help them pause. Rules:
- One sentence, max 26 words, second person ("you").
- Calm and kind, never preachy or guilt-tripping.
- Frame it around what they'd LOSE, not a lecture.
- Weave in the details below naturally; do not list them.

Details:
- App: $appName
- Their stated reason for opening it: ${reason.label}
- Their personal goal: $goalText
- Times already opened today: $opensToday
- Current time: $hour:$minute

Return ONLY the sentence, no quotes, no preamble.''';

    final uri = Uri.parse('$_endpoint?key=$apiKey');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.9,
              'maxOutputTokens': 60,
            }
          }),
        )
        .timeout(const Duration(seconds: 6));

    if (res.statusCode != 200) return null;
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = j['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.first['text'] as String?;
    return text?.replaceAll('"', '').trim();
  }
}
