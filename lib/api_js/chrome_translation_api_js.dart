@JS()
library translation;

import 'dart:js_interop';

@JS('translation')
external Translation get translation;

// [Exposed=(Window,Worker)]
extension type Translation(JSAny _) {
  external JSPromise<JSString> canDetect();
  external JSPromise<LanguageDetector> createDetector();
}

// [Exposed=(Window,Worker)]
extension type LanguageDetector(JSAny _) implements JSAny {
  // external JSPromise<JSAny> ready;
  external JSFunction ondownloadprogress;
  external JSPromise<JSArray<LanguageDetectionResult>> detect(JSString input);
}

enum TranslationAvailability {
  readily('readily'),
  afterDownload('after-download'),
  no('no');

  const TranslationAvailability(this.availabity);
  final String availabity;
}

extension type LanguageDetectionResult(JSAny _) implements JSAny {
  external JSString? detectedLanguage;
  external JSNumber confidence;
}
