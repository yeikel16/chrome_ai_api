import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:chrome_prompt_api/models/ai_text_session.dart';
import 'package:chrome_prompt_api/promp_api.dart' as api;

export 'package:chrome_prompt_api/models/models.dart';

class ChromePromptApi {
  Future<String> canCreateTextSession() async {
    final status = await api.canCreateTextSession().toDart;

    return status.toDart;
  }

  Future<AITextSession> createTextSession() async {
    final session = await api.createTextSession().toDart;

    return AITextSession(
      prompt: (a) async {
        final response = await session.prompt(a).toDart;

        return response.toDart;
      },
      destroy: () => session.destroy(),
      promptStreaming: (input) => _readStream(session.promptStreaming(input)),
    );
  }

  Future<AITextSessionOptions> defaultTextSessionOptions() async {
    final options = await api.defaultTextSessionOptions().toDart;

    return AITextSessionOptions(
      temperature: options.temperature.toDartDouble,
      topK: options.topK.toDartInt,
    );
  }
}

Stream<String> _readStream(api.ReadableStream stream) async* {
  api.ReadableStreamReader reader = stream.getReader();
  try {
    while (true) {
      api.ReadResult result = await reader.read().toDart;
      if (result.done) {
        break;
      }
      yield utf8.decode((result.value as Uint8List).toList());
    }
  } finally {
    reader.releaseLock();
  }
}
