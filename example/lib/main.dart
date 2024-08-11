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
  final promptNotifier = PromptNotifier();
  final _promptController = TextEditingController();
  final scrollController = ScrollController();
  double _temperature = 0.8;
  int _topK = 1;

  @override
  void initState() {
    super.initState();
    promptNotifier.getOptionsAndCheckStatus();
  }

  @override
  void dispose() {
    _promptController.dispose();
    promptNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Web using the local Gemini API of Chrome'),
        ),
        body: AnimatedBuilder(
            animation: promptNotifier,
            builder: (context, child) {
              final sessionStatus = promptNotifier.sessionStatus;
              final session = promptNotifier.session;

              final supported = promptNotifier.isSupported;

              if (!supported) {
                return const Center(
                  child: Text('Unsupported Ai Api feature in this browser'),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        : () => promptNotifier.promptStreming(
                                            _promptController.text),
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
            }),
      ),
    );
  }
}

class PromptNotifier extends ChangeNotifier {
  PromptNotifier({
    this.loading = false,
    this.options,
    this.session,
    this.aiResponse = '',
    this.sessionStatus = 'Unknown',
  });

  final _chromeAiApiPlugin = ChromeAiApi();

  bool loading = false;
  AITextSessionOptions? options;
  AITextSession? session;
  String aiResponse = '';
  String sessionStatus;
  StreamSubscription<dynamic>? _promptSubscription;

  bool get isSupported => _chromeAiApiPlugin.isSupported;

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
        sessionStatus = await _chromeAiApiPlugin.canCreateTextSession();
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
      session = await _chromeAiApiPlugin.createTextSession(
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
