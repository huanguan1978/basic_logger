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

BasicLogger is a fast, extensible, simple and lightweight logging tool for Dart and Flutter..

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

### 2. Accessing the Native `Logger` Instance
You can access the underlying `Logger` object via the `basicLogger.logger` property. This allows you to use the full `package:logging` API whenever needed:

```dart
// Ensure you have imported: import 'package:logging/logging.dart';
final basicLogger = BasicLogger('main');

// Get the native Logger instance
final logger = basicLogger.logger; 

// Use native-level methods
logger.fine('Fine-grained debug information');
logger.shout('Critical alert before a crash');
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
  // buffering allows you to write files multiple times instead of writing files once
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
