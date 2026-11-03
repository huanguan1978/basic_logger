<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

BasicLogger is a fast, extensible, simple and lightweight logging tool for Dart and Flutter.

## Features

It is distributed as a single file module and has no dependencies other than the Dart Standard Library.

## Architecture Patterns

### Pattern 1: Multi-sink Fan-out
**Broadcast a single log event to multiple outputs simultaneously.**
This pattern implements a **one-to-many** distribution, allowing you to decouple log generation from log persistence. Common for concurrent real-time terminal monitoring and local file archiving.

```dart
  Logger.root.level = Level.ALL;
  final basicLogger = BasicLogger('main');

  // attach developer log
  basicLogger.attachLogger(DevOutputLogger(basicLogger.name));

  // attach output log, 
  // selfname, default console
  // selfonly, if true filter by selfname, else parentName match are output.
  final consoleLogger = basicLogger.attachLogger(OutputLogger(
    basicLogger.name,
    // selfname: 'console',
    // selfonly: true,
  ));

  // output to all attach instance
  basicLogger.info('hello world');
  
  // output buffer to all attach instance, not include detach instance
  basicLogger.output();

  // output
  // 2024-10-15 02:52:11.405809 [INFO] main: hello world
```


### Pattern 2: Scoped Log Routing
**Isolate logs by functional domains or business categories.**
By registering independent loggers for different modules (e.g., `Auth`, `Database`, `Network`), you achieve **Separation of Concerns (SoC)**. This allows for granular control over filtering levels and storage policies for each specific scope.

```dart
  Logger.root.level = Level.ALL;

  final basicLogger = BasicLogger('main');

  // attach output log, alias stdout, filter by selfname
  final stdoutOutputLogger =
      OutputLogger(basicLogger.name, selfname: 'stdout', selfonly: true);
  final stdoutLogger = basicLogger.attachLogger(stdoutOutputLogger);

  // attach output log, alias stderr, filter by selfname
  final stderrOutputLogger =
      OutputLogger(basicLogger.name, selfname: 'stderr', selfonly: true);
  final stderrLogger = basicLogger.attachLogger(stderrOutputLogger);

  stdoutLogger.info('info a11'); 
  stderrLogger.info('error 1234');
  stdoutLogger.info('info a22'); 

  // output
  // 2026-01-16 10:41:18.957774 [INFO] main.stdout: info a11
  // 2026-01-16 10:41:18.967899 [INFO] main.stderr: error 1234
  // 2026-01-16 10:41:18.967971 [INFO] main.stdout: info a22
```

## Advanced Usage: Seamless Integration with Dart Standard Library

`BasicLogger` is built upon the official Dart `logging` package. For advanced users, you can access the native `Logger` instance directly to enjoy the full power of the standard library while maintaining the simplicity of `BasicLogger`.

### 1. Level Reference Table
To assist with migration from other languages (e.g., Python/Java), here is the mapping of Dart's levels:

| Dart `Level` | Recommended Use Case |
| :--- | :--- |
| **`FINEST` / `FINER`** | High-frequency execution traces |
| **`FINE`** | Standard Debug (equivalent to Python `DEBUG`) |
| **`CONFIG`** | Application configuration/setup info |
| **`INFO`** | General operational milestones |
| **`WARNING`** | Non-fatal warnings |
| **`SEVERE`** | Error conditions (equivalent to Python `ERROR`) |
| **`SHOUT`** | Fatal/Critical errors (equivalent to Python `CRITICAL`) |

### 2. Native Logging Levels & Sub-library Import
`BasicLogger` directly exposes all native logging level methods (`finest`, `finer`, `fine`, `config`, `info`, `warning`, `severe`, `shout`, and generic `log`).
To configure root log levels or access standard logging primitives, import the bundled sub-library without declaring `logging` in your own `pubspec.yaml`:

```dart
import 'package:basic_logger/basic_logger.dart';
import 'package:basic_logger/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  final basicLogger = BasicLogger('main');

  // Call native level methods directly on basicLogger
  basicLogger.fine('Fine-grained debug information');
  basicLogger.shout('Critical alert before a crash');

  // Or access the underlying Logger instance if needed
  final Logger nativeLogger = basicLogger.logger;
}
```

### 3. Flutter Global Error Handling & Custom Output
By leveraging the `record` and `format` hooks of `OutputLogger`, you can customize log output (e.g., using Flutter's `debugPrint`) and unify global exception handling into your logging pipeline:

```dart
void main() {
  Logger.root.level = Level.ALL;
  final basicLogger = BasicLogger('main');
  
  // Customize output format and redirect to Flutter's debugPrint
  basicLogger.attachLogger(
    OutputLogger(basicLogger.name)
      ..record = debugPrint
      ..format = (logRec) => logRec.toString(),
  );

  // Get the native Logger instance
  final logger = basicLogger.logger; 

  // Integrate Global Exception Handling
  FlutterError.onError = (details) => 
    logger.severe('FlutterError', details.exception, details.stack);

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.severe('UnhandledError', error, stack);
    return true;
  };

  // runApp(const MyApp());
}
```

### 4. Capturing Named Third-Party Loggers (Advanced)

As shown above, BasicLogger processes records emitted by the standard Logger API from `package:logging`.
That means if a third-party package uses a named Logger (for example, `GoogleAI.HTTP`), BasicLogger can capture those records and route them through your existing pipeline.

The same named-logger capture pattern works across all OutputLogger-based sinks in this package:
1. `OutputLogger`
2. `DevOutputLogger`
3. `FileOutputLogger`

In most cases, no third-party source changes are required.
Once you know the logger name, you can attach a sink and centralize:
1. Collection
2. Level filtering
3. Fan-out (console, dev output, file)
4. Troubleshooting and audit trails

Prerequisites:
1. Set an appropriate root level (for example, `Logger.root.level = Level.ALL`).
2. Confirm the third-party package actually uses `package:logging`.
3. Match the logger name exactly as defined by that package.

High-value observability scenarios:
1. HTTP SDKs: method, URL, status code, latency, retries, headers, response snippets.
2. Database SDKs: connection lifecycle, query execution, slow queries, retries, stack traces.
3. Message queue SDKs: publish, ack, redelivery, backlog growth, failure reasons.
4. Other infrastructure clients: cache, object storage, auth, gateway, and related components.

```dart
void main() async {
  // hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  final basicLogger = BasicLogger('main');

  // Example: googleai_dart uses a named Logger: GoogleAI.HTTP
  basicLogger.attachLogger(
    OutputLogger('GoogleAI.HTTP'),
  );

  final client = GoogleAIClient.fromEnvironment();
  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Hello')],
      ),
    );

    basicLogger.info(response.text);
  } finally {
    client.close();
  }
}
```

Sample output (truncated):

```text
2026-08-12 09:09:02.419060 [INFO] GoogleAI.HTTP: REQUEST ...
2026-08-12 09:09:03.870647 [INFO] GoogleAI.HTTP: RESPONSE ... 200 (1473ms)
2026-08-12 09:09:03.897237 [INFO] main: Hello! How can I help you today?
```

## Additional information

- FileOutputLogger, file-based logging for Android, iOS, Linux, macOS, and Windows platforms.

```shell
dart pub add basic_logger_file
```

- FileOutputLogger, specify output file path

```dart
  basicLogger.attachLogger(FileOutputLogger(
    basicLogger.name,
    dir: './logs/',
  ));
```

- FileOutputLogger, specify output buffer size

```dart
  // bufferSize is measured in log lines: logs are buffered in memory and flushed to disk in one batch when the line count reaches bufferSize, reducing disk I/O.
  basicLogger.attachLogger(FileOutputLogger(
    basicLogger.name,
    bufferSize: 100,
  ));

  // output and clear buffer
  basicLogger.output();
```

- FileOutputLogger, specify output categorization

```dart
  // allow custom log extensions via `ext` parameter for log categorization.
  basicLogger.attachLogger(FileOutputLogger(
    basicLogger.name,
    ext: '_sql.log',
  ));
```

## 💖 Support the Project
If you find this tool helpful and would like to see it continue to improve and evolve, please consider showing your support.

*   ⭐ **Star the Repo**: This is a great encouragement. Your stars help more people discover this tool and gain more recognition in the community.
*   ☕ **Support the Developer (Global)**: Any contribution, however small, is a huge affirmation of my work. You can support via [GitHub Sponsors](https://github.com/sponsors/huanguan1978) or [Buy Me a Coffee](https://buymeacoffee.com/huanguan1978).
*   🐼 **Support via Ifdian (Mainland China)**: Users in China can also show support via [Ifdian](https://ifdian.net/a/huanguan1978).

*Thank you for your support, which is a vital boost that keeps me focused on the project's continuous iteration; because of you, more people can benefit from this tool much sooner.*