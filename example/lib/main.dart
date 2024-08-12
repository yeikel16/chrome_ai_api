// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chrome_ai_api/chrome_ai_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final chromeAiApiPlugin = ChromeAiApi();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Web using the local Gemini API of Chrome'),
        ),
        body: Builder(builder: (context) {
          final supported = chromeAiApiPlugin.isSupported;

          if (!supported) {
            return const Center(
              child: Text('Unsupported Ai Api feature in this browser'),
            );
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Prompt'),
                    Tab(text: 'Language Detection'),
                    Tab(text: 'Summarization'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      PromptTabView(
                        chromeAiApiPlugin: chromeAiApiPlugin,
                      ),
                      LanguageTabView(
                        chromeAiApiPlugin: chromeAiApiPlugin,
                      ),
                      SummarizationTabView(
                        chromeAiApiPlugin: chromeAiApiPlugin,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

class PromptTabView extends StatefulWidget {
  const PromptTabView({super.key, required this.chromeAiApiPlugin});

  final ChromeAiApi chromeAiApiPlugin;

  @override
  State<PromptTabView> createState() => _PromptTabViewState();
}

class _PromptTabViewState extends State<PromptTabView> {
  late final PromptNotifier promptNotifier;

  @override
  void initState() {
    super.initState();

    promptNotifier =
        PromptNotifier(chromeAiApiPlugin: widget.chromeAiApiPlugin);
    promptNotifier.getOptionsAndCheckStatus();
  }

  final _promptController = TextEditingController();
  final scrollController = ScrollController();
  double _temperature = 0.8;
  int _topK = 1;

  @override
  void dispose() {
    promptNotifier.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: promptNotifier,
      builder: (context, child) {
        final sessionStatus = promptNotifier.sessionStatus;
        final session = promptNotifier.session;

        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Status: $sessionStatus'),
                      Row(
                        children: [
                          Text('Temperature: ${_temperature.toString()}'),
                          Slider(
                            value: _temperature,
                            max: 1,
                            min: 0,
                            divisions: 10,
                            label: _temperature.toString(),
                            onChanged: (double value) {
                              setState(() {
                                _temperature = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('topK: ${_topK.toString()}'),
                          Slider(
                            value: _topK.toDouble(),
                            max: 100,
                            min: 1,
                            divisions: 100,
                            label: _topK.toString(),
                            onChanged: (double value) {
                              setState(() {
                                _topK = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FilledButton(
                        child: const Text('Create New Session'),
                        onPressed: () {
                          promptNotifier.createSession(
                            temperature: _temperature,
                            topK: _topK,
                          );
                        },
                      ),
                    ),
                    if (session == null)
                      const SizedBox.shrink()
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: OutlinedButton(
                          child: const Text('Destroy Session'),
                          onPressed: () {
                            promptNotifier.destroy();
                            setState(() {
                              _topK = 1;
                              _temperature = 0.8;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final notHasResponse = promptNotifier.aiResponse.isEmpty;
                final isLoading = promptNotifier.loading;

                if (notHasResponse && !isLoading) {
                  return const Expanded(child: SizedBox.shrink());
                }

                if (isLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final String prompResponse = promptNotifier.aiResponse;

                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }

                return Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        reverse: true,
                        child: SelectableText(prompResponse),
                      ),
                    ),
                  ),
                );
              },
            ),
            Builder(builder: (context) {
              final isLoading = promptNotifier.loading;
              final hasSession = promptNotifier.session != null;

              if (isLoading && !hasSession) {
                return const Center(child: CircularProgressIndicator());
              }

              if (hasSession) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          maxLines: 4,
                          minLines: 1,
                          decoration: const InputDecoration(
                            hintText: 'Write you prompt hear...',
                          ),
                          onSubmitted: (value) {
                            promptNotifier.promptStreming(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedBuilder(
                          animation: _promptController,
                          builder: (context, child) {
                            return FilledButton(
                              onPressed: _promptController.text.isEmpty
                                  ? null
                                  : () => promptNotifier
                                      .promptStreming(_promptController.text),
                              child: const Text('Submit'),
                            );
                          }),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }
}

class LanguageTabView extends StatefulWidget {
  const LanguageTabView({super.key, required this.chromeAiApiPlugin});

  final ChromeAiApi chromeAiApiPlugin;

  @override
  State<LanguageTabView> createState() => _LanguageTabViewState();
}

class _LanguageTabViewState extends State<LanguageTabView> {
  late LanguageDetectionNotifier _languageDetectionNotifier;
  final _languageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _languageDetectionNotifier =
        LanguageDetectionNotifier(widget.chromeAiApiPlugin);
    _languageDetectionNotifier.getLanguageStatus();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: _languageDetectionNotifier,
        builder: (context, child) {
          final languageStatus = _languageDetectionNotifier.languageStatus;
          final languageDetected = _languageDetectionNotifier.languageDetected;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Language Status: $languageStatus')),
                  AnimatedBuilder(
                    animation: _languageController,
                    builder: (context, child) {
                      return FilledButton(
                        onPressed: _languageController.text.isEmpty
                            ? null
                            : () => _languageDetectionNotifier
                                .detectLanguage(_languageController.text),
                        child: const Text('Detect Language'),
                      );
                    },
                  ),
                ],
              ),
              TextField(
                controller: _languageController,
                minLines: 5,
                maxLines: 15,
              ),
              if (languageDetected.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text('Result: $languageDetected'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LanguageDetectionNotifier extends ChangeNotifier {
  LanguageDetectionNotifier(this._chromeAiApiPlugin);

  final ChromeAiApi _chromeAiApiPlugin;

  String languageStatus = 'Unknown';
  List<LanguageDetectionResult> languageDetected = const [];

  bool loading = false;

  bool get isSupported => _chromeAiApiPlugin.isSupported;

  Future<void> getLanguageStatus() async {
    loading = true;
    notifyListeners();

    try {
      if (isSupported) {
        languageStatus = await _chromeAiApiPlugin.canDetectLanguage();
      }
    } on PlatformException {
      languageStatus = 'Failed to get Language status.';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> detectLanguage(String text) async {
    loading = true;
    languageDetected = [];
    notifyListeners();

    try {
      if (isSupported) {
        final detector = await _chromeAiApiPlugin.createLanguageDetector();

        languageDetected = await detector.detect(text);
      }
    } on PlatformException {
      languageStatus = 'Failed to get Language status.';
    }

    loading = false;
    notifyListeners();
  }
}

class PromptNotifier extends ChangeNotifier {
  PromptNotifier({
    this.loading = false,
    this.options,
    this.session,
    this.aiResponse = '',
    this.sessionStatus = 'Unknown',
    required this.chromeAiApiPlugin,
  });

  final ChromeAiApi chromeAiApiPlugin;

  bool loading = false;
  AITextSessionOptions? options;
  AITextSession? session;
  String aiResponse = '';
  String sessionStatus;
  StreamSubscription<dynamic>? _promptSubscription;

  bool get isSupported => chromeAiApiPlugin.isSupported;

  @override
  void dispose() {
    _promptSubscription?.cancel();
    super.dispose();
  }

  Future<void> getOptionsAndCheckStatus() async {
    loading = true;
    notifyListeners();

    try {
      if (isSupported) {
        sessionStatus = await chromeAiApiPlugin.canCreateTextSession();
      }
      // options = await _chromeAiApiPlugin.textModelInfo();
    } on PlatformException {
      sessionStatus = 'Failed to get session status.';
    }

    loading = false;
    notifyListeners();
  }

  void destroy() {
    session?.destroy();
    session = null;
    loading = false;
    notifyListeners();
  }

  Future<void> createSession({
    required double temperature,
    required int topK,
  }) async {
    loading = true;
    notifyListeners();

    try {
      aiResponse = '';
      if (session != null) {
        session?.destroy();
      }
      session = await chromeAiApiPlugin.createTextSession(
        options: AITextSessionOptions(topK: topK, temperature: temperature),
      );
    } on PlatformException {
      sessionStatus = 'Failed to create session.';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> prompt(String text) async {
    loading = true;
    notifyListeners();

    aiResponse = await session?.prompt(text) ?? '';

    loading = false;
    notifyListeners();
  }

  Future<void> promptStreming(String text) async {
    loading = true;
    notifyListeners();

    final response = session?.promptStreaming(text);
    aiResponse = '';
    int? previousLength;

    if (response != null) {
      _promptSubscription = response.listen((aiStream) {
        if (aiStream is String) {
          final newContent = aiStream.substring(previousLength ?? 0);

          aiResponse += newContent;
          previousLength = aiResponse.length;

          loading = false;
          notifyListeners();
        }
      });
    }
  }
}

class SummarizationTabView extends StatefulWidget {
  const SummarizationTabView({super.key, required this.chromeAiApiPlugin});

  final ChromeAiApi chromeAiApiPlugin;

  @override
  State<SummarizationTabView> createState() => _SummarizationTabViewState();
}

class _SummarizationTabViewState extends State<SummarizationTabView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Summarization View'),
    );
  }
}
