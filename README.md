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

## Getting started

```shell
  dart pub add basic_logger
```

```shell
  flutter pub add basic_logger
```

## Usage

```dart
  Logger.root.level = Level.ALL;
  final basicLogger = BasicLogger('main');

  // attach developer log
  basicLogger.attachLogger(DevOutputLogger(parentName: basicLogger.name));

  // attach output log, 
  // selfname, default console
  // selfonly, when true, filter by selfname. Otherwise, output all.
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

## Flutter Usage
```dart
  Logger.root.level = Level.ALL;
  final basicLogger = BasicLogger('main');

  // attach observer, console log use debugPrint
  basicLogger.attachLogger(
    OutputLogger(basicLogger.name)..record = debugPrint,
    );

  basicLogger.info('hello world');
)    
```

## Additional information

- FileOutputLogger, file-based logging for Android, iOS, Linux, macOS, and Windows platforms.

```shell
dart pub add basic_logger_file
```
```shell
flutter pub add basic_logger_file
```

- FileOutputLogger, specify output file path

```dart
  basicLogger.attachLogger(FileOutputLogger(
    parentName: basicLogger.name,
    dir: './logs/',
  ));
```

- FileOutputLogger, specify output buffer size

```dart
  // buffering allows you to write files multiple times instead of writing files once
  basicLogger.attachLogger(FileOutputLogger(
    parentName: basicLogger.name,
    bufferSize: 100,
  ));

  // output and clear buffer
  basicLogger.output();
```


