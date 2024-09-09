part of '../basic_logger.dart';

final class BasicLogger {
  static final BasicLogger _instance = BasicLogger._();
  static late final Logger _logger;
  late String _name;

  final List<OutputLogger> _listenLogs = [];

  factory BasicLogger(String name) {
    _logger = Logger(name);
    return _instance.._name = name;
  }
  BasicLogger._();

  String get name => _name;

  Logger get logger => _logger;

  Logger attachLogger(OutputLogger listenLogger) {
    _listenLogs.add(listenLogger);
    return Logger(listenLogger.name);
  }

  Logger detachLogger(OutputLogger listenLogger) {
    if (_listenLogs.contains(listenLogger)) {
      _listenLogs.remove(listenLogger);
    }
    return Logger.detached(listenLogger.name);
  }

  Iterable<Logger> get attachedLoggers => Logger.attachedLoggers;
  String get attachedNames =>
      attachedLoggers.map((e) => ('${e.parent?.name}.${e.name}')).toString();

  Iterable<OutputLogger> get listenLoggers => _listenLogs;
  String get listenNames => listenLoggers.map((e) => e.name).toString();

  void output() {
    for (var listenLog in _listenLogs) {
      listenLog.output();
    }
  }

  void level(Level? value) {
    _logger.level = value;
  }

  void _log(
    Level logLevel,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.log(logLevel, message, error, stackTrace);

  /// log message at the specified level
  void logrec(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _log(_logger.level, message, error, stackTrace);

  void debug(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _log(Level.FINE, message, error, stackTrace);

  void info(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _log(Level.INFO, message, error, stackTrace);

  void warning(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _log(Level.WARNING, message, error, stackTrace);

  void error(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _log(Level.SEVERE, message, error, stackTrace);

  void critical(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _log(Level.SHOUT, message, error, stackTrace);
}

/// supper class, OutputLogger
abstract base class OutputLogger {
  final String _name;
  final String _parentName;

  OutputLogger(this._parentName, this._name);

  String get name => '$_parentName.$_name';

  void output();
}

/// output to console, use print
final class ConsoleOutputLogger extends OutputLogger {
  ConsoleOutputLogger({
    required String parentName,
    String name = 'basicConsoleLogger',
  }) : super(parentName, name) {
    name = '$parentName.$name';
    Logger(name).onRecord.listen((LogRecord record) {
      print(
          '${record.time}: [${record.level}] [${record.loggerName}] ${record.message}');
    });
  }

  @override
  void output() {}
}

/// output to log, use developer.log
final class DevOutputLogger extends OutputLogger {
  DevOutputLogger({
    required String parentName,
    String name = 'basieDevLogger',
  }) : super(parentName, name) {
    name = '$parentName.$name';
    Logger(name).onRecord.listen((LogRecord record) {
      developer.log(
        record.message,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: record.loggerName,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });
  }

  @override
  void output() {}
}
