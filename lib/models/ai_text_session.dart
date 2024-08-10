class AITextSession {
  AITextSession({
    required this.prompt,
    required this.destroy,
    required this.promptStreaming,
  });

  final Future<String> Function(String input) prompt;
  final Stream<dynamic> Function(String input) promptStreaming;
  final void Function() destroy;
}

class AITextSessionOptions {
  final int topK;
  final double? temperature;

  AITextSessionOptions({required this.topK, this.temperature});
}
