class LanguageDetector {
  final Future<dynamic> ready;
  final Function(dynamic event) onDownloadProgress;
  final Future<List<LanguageDetectionResult>> Function(String input) detect;

  LanguageDetector({
    required this.ready,
    required this.onDownloadProgress,
    required this.detect,
  });
}

class LanguageDetectionResult {
  final String? detectedLanguage;
  final double confidence;

  LanguageDetectionResult({
    required this.detectedLanguage,
    required this.confidence,
  });

  @override
  String toString() =>
      'LanguageDetectionResult(detectedLanguage: $detectedLanguage, confidence: $confidence)';
}
