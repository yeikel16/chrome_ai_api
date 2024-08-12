import 'dart:js_interop';

import 'package:chrome_ai_api/api_js/chrome_ai_api_js.dart' as api;
import 'package:chrome_ai_api/api_js/chrome_translation_api_js.dart'
    as translation_api;
import 'package:chrome_ai_api/models/models.dart';

export 'package:chrome_ai_api/models/models.dart';

class ChromeAiApi {
  ChromeAiApi() {
    try {
      _ai = api.ai;
      _translation = translation_api.translation;
    } catch (e) {
      _ai = null;
      _translation = null;
    }
  }
  api.Ai? _ai;
  translation_api.Translation? _translation;

  bool get isSupported => _ai != null;

  Future<String> canCreateTextSession() async {
    if (_ai == null) throw ChromeAiException();

    final status = await _ai!.canCreateTextSession().toDart;

    return status.toDart;
  }

  Future<AITextSession> createTextSession({
    AITextSessionOptions? options,
  }) async {
    if (_ai == null) throw ChromeAiException();

    final session = await _ai!
        .createTextSession(
          api.AITextSessionOptions(
            temperature: options?.temperature?.toJS,
            topK: options?.topK.toJS,
          ),
        )
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
    if (_ai == null) throw ChromeAiException();

    final options = await _ai!.textModelInfo().toDart;

    return AITextSessionOptions(
      temperature: options.temperature?.toDartDouble,
      topK: options.topK?.toDartInt ?? 0,
    );
  }

  Future<String> canDetectLanguage() async {
    if (_translation == null) throw ChromeAiException();

    final status = await _translation!.canDetect().toDart;

    return status.toDart;
  }

  Future<LanguageDetector> createLanguageDetector() async {
    if (_translation == null) throw ChromeAiException();

    final detector = await _translation!.createDetector().toDart;

    return LanguageDetector(
      detect: (e) async {
        final result = await detector.detect(e.toJS).toDart;

        return result.toDart
            .cast<translation_api.LanguageDetectionResult>()
            .map(
              (r) => LanguageDetectionResult(
                confidence: r.confidence.toDartDouble,
                detectedLanguage: r.detectedLanguage?.toDart,
              ),
            )
            .toList();
      },
      ready: Future.value(), // TODO: is not implemented in JS side
      onDownloadProgress: (event) {
        return detector.ondownloadprogress;
      },
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

class ChromeAiException implements Exception {
  ChromeAiException({
    this.message = 'Unsupported Ai Api feature in this browser',
  });
  final String message;
}
