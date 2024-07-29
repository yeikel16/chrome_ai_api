// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chrome_prompt_api/chrome_prompt_api.dart';

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

  @override
  void initState() {
    super.initState();
    promptNotifier.getOptionsAndCheckStatus();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Web using the local AI API of Chrome'),
        ),
        body: Center(
          child: AnimatedBuilder(
              animation: promptNotifier,
              builder: (context, child) {
                final options = promptNotifier.options;
                final sessionStatus = promptNotifier.sessionStatus;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Session Status: $sessionStatus'),
                    const SizedBox(height: 6),
                    if (options != null)
                      Text(
                        'temperature: ${options.temperature}\n '
                        'topK:${options.topK}',
                      ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final isLoading = promptNotifier.loading;
                        final hasSession = promptNotifier.session != null;

                        if (isLoading && !hasSession) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (hasSession) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _promptController,
                                    decoration: const InputDecoration(
                                      hintText: 'Write you prompt hear...',
                                    ),
                                    onSubmitted: (value) {
                                      promptNotifier.prompt(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                AnimatedBuilder(
                                    animation: _promptController,
                                    builder: (context, child) {
                                      return FilledButton(
                                        onPressed: _promptController
                                                .text.isEmpty
                                            ? null
                                            : () => promptNotifier
                                                .prompt(_promptController.text),
                                        child: const Text('Submit'),
                                      );
                                    }),
                              ],
                            ),
                          );
                        }

                        return TextButton(
                          child: const Text('Create new Text Session'),
                          onPressed: () {
                            promptNotifier.createSession();
                          },
                        );
                      },
                    ),
                    Builder(
                      builder: (context) {
                        final notHasResponse =
                            promptNotifier.aiResponse.isEmpty;

                        if (notHasResponse) {
                          return const SizedBox.shrink();
                        }

                        final isLoading = promptNotifier.loading;

                        if (isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final String prompResponse = promptNotifier.aiResponse;

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: Text(prompResponse)),
                        );
                      },
                    ),
                  ],
                );
              }),
        ),
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

  bool loading = false;
  AITextSessionOptions? options;
  AITextSession? session;
  String aiResponse = '';
  String sessionStatus;

  final _chromePromptApiPlugin = ChromePromptApi();

  Future<void> getOptionsAndCheckStatus() async {
    loading = true;
    notifyListeners();

    try {
      sessionStatus = await _chromePromptApiPlugin.canCreateTextSession();
      options = await _chromePromptApiPlugin.defaultTextSessionOptions();
    } on PlatformException {
      sessionStatus = 'Failed to get session status.';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createSession() async {
    loading = true;
    notifyListeners();

    try {
      session = await _chromePromptApiPlugin.createTextSession();
    } on PlatformException {
      sessionStatus = 'Failed to create session.';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> prompt(String text) async {
    loading = true;
    notifyListeners();

    print('prompt(session: $session): $text');
    aiResponse = await session?.prompt(text) ?? '';
    print('aiResponse: $aiResponse');

    loading = false;
    notifyListeners();
  }
}
