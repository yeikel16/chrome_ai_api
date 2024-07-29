// ignore_for_file: unused_element, avoid_web_libraries_in_flutter

@JS()
library prompt_api;

import 'dart:js_interop';

@JS('window.ai.canCreateTextSession')
external JSPromise<JSString> canCreateTextSession();

@JS('window.ai.createTextSession')
external JSPromise<AITextSessionJs> createTextSession();

@JS('window.ai.defaultTextSessionOptions')
external JSPromise<AITextSessionOptionsJs> defaultTextSessionOptions();

@JS()
@staticInterop
extension type AITextSessionOptionsJs(JSAny _) implements JSAny {
  external JSNumber topK;
  external JSNumber temperature;
}

// external AiJs get ai;

// @JS('ai')
// abstract class AiJs {
//   external JSPromise<JSString> canCreateTextSession();
//   external JSPromise<AITextSessionJs> createTextSession();
//   // external JSPromise<AITextSessionOptions> defaultTextSessionOptions();
// }

@JS()
@staticInterop
extension type AITextSessionJs(JSAny _) implements JSAny {
  external JSPromise<JSString> prompt(String input);
  external ReadableStream promptStreaming(String input);
  external void destroy();
}

@JS()
@staticInterop
extension type ReadableStream(JSAny _) {
  external ReadableStreamReader getReader();
}

@JS()
@staticInterop
extension type ReadableStreamReader(JSAny _) {
  external JSPromise<ReadResult> read();
  external void releaseLock();
}

@JS()
@staticInterop
extension type ReadResult(JSAny _) implements JSAny {
  external bool get done;
  external JSAny get value;
}
