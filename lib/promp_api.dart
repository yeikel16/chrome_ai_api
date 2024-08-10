// ignore_for_file: unused_element, avoid_web_libraries_in_flutter

@JS()
library prompt_api;

import 'dart:js_interop';

@JS('ai')
external Ai get ai;

@JS()
extension type Ai(JSAny _) {
  external JSPromise<JSString> canCreateTextSession();
  external JSPromise<AITextSessionJs> createTextSession(
    AITextSessionOptions? options,
  );
  external JSPromise<AITextSessionOptions> textModelInfo();
}

@JS()
extension type AITextSessionOptions._(JSAny _) implements JSAny {
  external AITextSessionOptions({
    JSNumber? topK,
    JSNumber? temperature,
  });

  external JSNumber? topK;
  external JSNumber? temperature;
}

@JS()
extension type AITextSessionJs(JSAny _) implements JSAny {
  external JSPromise<JSString> prompt(String input);
  external ReadableStream promptStreaming(String input);
  external void destroy();
}

@JS()
extension type ReadableStream(JSAny _) {
  external ReadableStreamReader getReader();
}

@JS()
extension type ReadableStreamReader(JSAny _) {
  external JSPromise<ReadResult> read();
  external void releaseLock();
}

@JS()
extension type ReadResult(JSAny _) implements JSAny {
  external JSBoolean done;
  external JSAny get value;
}
