import 'dart:js_interop';

import 'package:chrome_prompt_api/models/ai_text_session.dart';
import 'package:chrome_prompt_api/promp_api.dart' as api;

export 'package:chrome_prompt_api/models/models.dart';

class ChromePromptApi {
  final _ai = api.ai;

  Future<String> canCreateTextSession() async {
    final status = await _ai.canCreateTextSession().toDart;

    return status.toDart;
  }

  Future<AITextSession> createTextSession({
    AITextSessionOptions? options,
  }) async {
    final session = await _ai
        .createTextSession(api.AITextSessionOptions(
          temperature: 0.8.toJS, //options?.temperature?.toJS,
          topK: 1.toJS, //options?.topK.toJS,
        ))
        .toDart;

    return AITextSession(
      prompt: (a) async {
        final response = await session.prompt(a).toDart;

        return response.toDart;
      },
      destroy: () => session.destroy(),
      promptStreaming: (input) => _readStream(session.promptStreaming(input)),
    );
  }

  Future<AITextSessionOptions> textModelInfo() async {
    final options = await _ai.textModelInfo().toDart;

    return AITextSessionOptions(
      temperature: options.temperature?.toDartDouble,
      topK: options.topK?.toDartInt ?? 0,
    );
  }
}

Stream<dynamic> _readStream(api.ReadableStream stream) async* {
  api.ReadableStreamReader reader = stream.getReader();
  try {
    while (true) {
      api.ReadResult result = await reader.read().toDart;

      if (result.done.toDart) {
        break;
      }
      yield result.value;
    }
  } finally {
    reader.releaseLock();
  }
}
