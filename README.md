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
