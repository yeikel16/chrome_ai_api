# chrome_prompt_api

[![License: MIT][license_badge]][license_link]

Allow connect Flutter Web to using the local Gemini API of Chrome by making use of [interoperability][js_interop] between *Dart* and *JavaScript*.

🚧🚩**This package is proof of concept, it is not recommended to use it in a production environment and should only be used on the Web platform.**

|Tested on| MacOs | iOS   | Windows  | Android   | Linux |
|-------------|---------|-------|--------|-------|-------|
| **Work** | Yes | * | * |  * | * |

## Install

1. Add the following lines to your project dependencies

    ```yaml
    chrome_prompt_api:
        git: https://github.com/yeikel16/chrome_prompt_api.git
    ```

    > Run `flutter pub get`

2. Make sure than you have install [Chrome Canary][chrome_canary_link] in you machine and complate every steps from [Built-in AI Early Preview Program][chrome_prompt_guide_link] setup guide.

    The session status be one of the following:

    * "readily": the model is available on-device and so creating will happen quickly
    * "after-download": the model is not available on-device, but the device is capable,
    so creating the session will start the download process (which can take a while).
    * "no": the model is not available for this device.

    > Since the Gemeni API currently has no way of knowing the download progress ([issue #4][issue_4]) of the model, you will have to monitor your network activity. The model weighs around 1.37 GB.

3. Run example:
    **Option A:** The easy wahy is copy the URL after run the example project into [Chrome Canary][chrome_canary_link]y version. The normal version of Chrome not work beacause the Gemini API is only aviable in Chrome Dev channel (or [Canary][chrome_canary_link] channel).
    **Option B:**  [Compile the example][app-for-release] and launch a web server (for example, `python -m http.server 8000`, or by using the **dhttpd** package), and open the `/build/web` directory and opem `localhost:8000` in your [Chrome Canary][chrome_canary_link] browser.

## Usege

```dart
final chromePromptApi = ChromePromptApi();
```

You can see the full example [here][example_url].

---

## Bugs or Requests

If you want to [report a problem][github_issue_link] or would like to add a new feature, feel free to open an [issue on GitHub][github_issue_link]. Pull requests are also welcome.

[app-for-release]: https://docs.flutter.dev/deployment/web#building-the-app-for-release
[chrome_canary_link]: https://www.google.com/chrome/canary/
[chrome_prompt_guide_link]: https://docs.google.com/document/d/1VG8HIyz361zGduWgNG7R_R8Xkv0OOJ8b5C9QKeCjU0c/edit#heading=h.5s2qlonhpm36
[example_url]: https://github.com/yeikel16/chrome_prompt_api/example
[js_interop]: https://dart.dev/interop/js-interop
[issue_4]: https://github.com/explainers-by-googlers/prompt-api/issues/4
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[github_issue_link]: https://github.com/yeikel16/chrome_prompt_api
