part of '../basic_logger.dart';

/// Observer Pattern, BasicLogger
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

  /// Attach an observer
  Logger attachLogger(OutputLogger listenLogger) {
    _listenLogs.add(listenLogger);
    return Logger(listenLogger.name);
  }

  /// Detach an observer
  Logger detachLogger(OutputLogger listenLogger) {
    _listenLogs.removeWhere((e) => e.name == listenLogger.name);
    return Logger.detached(listenLogger.name);
  }

  /// all logger instance
  Iterable<Logger> get attachedLoggers => Logger.attachedLoggers;

  /// all logger name
  String get attachedNames =>
      attachedLoggers.map((e) => ('${e.parent?.name}.${e.name}')).toString();

  /// all observer instance
  Iterable<OutputLogger> get listenLoggers => _listenLogs;

  /// all observer name
  String get listenNames => listenLoggers.map((e) => e.name).toString();

  /// Output and flush the buffer
  void output() {
    for (var listenLog in _listenLogs) {
      listenLog.output(null);
    }
  }

  void level(Level? value) {
    Logger.root.level = value ?? Level.ALL;
    // _logger.level = value;
  }

  /// Log message at the specified [logLevel].
  void log(
    Level logLevel,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.log(logLevel, message, error, stackTrace);

  /// Check whether messages at [value] level would be processed.
  bool isLoggable(Level value) => _logger.isLoggable(value);

  /// Log message at the logger's current level.
  void logrec(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(_logger.level, message, error, stackTrace);

  /// Log message at level [Level.FINEST].
  void finest(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.FINEST, message, error, stackTrace);

  /// Log message at level [Level.FINER].
  void finer(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.FINER, message, error, stackTrace);

  /// Log message at level [Level.FINE].
  void fine(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.FINE, message, error, stackTrace);

  /// Log message at level [Level.CONFIG].
  void config(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.CONFIG, message, error, stackTrace);

  /// Log message at level [Level.INFO].
  void info(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.INFO, message, error, stackTrace);

  /// Log message at level [Level.WARNING].
  void warning(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.WARNING, message, error, stackTrace);

  /// Log message at level [Level.SEVERE].
  void severe(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.SEVERE, message, error, stackTrace);

  /// Log message at level [Level.SHOUT].
  void shout(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(Level.SHOUT, message, error, stackTrace);

  // Convenient multi-language aliases:

  /// Convenience alias for [fine] (equivalent to Python/Java `DEBUG`).
  void debug(Object? message, [Object? error, StackTrace? stackTrace]) =>
      fine(message, error, stackTrace);

  /// Convenience alias for [severe] (equivalent to Python/Java `ERROR`).
  void error(Object? message, [Object? error, StackTrace? stackTrace]) =>
      severe(message, error, stackTrace);

  /// Convenience alias for [shout] (equivalent to Python/Java `CRITICAL`).
  void critical(Object? message, [Object? error, StackTrace? stackTrace]) =>
      shout(message, error, stackTrace);
}

/// Template Method Pattern, OutputLogger
base class OutputLogger {
  late final String _logName;
  late final String _selfname;
  late final bool _selfonly;

  final String _parentName;

  void Function(String) record = print;
  String Function(LogRecord) format = (logRec) => '${logRec.time} $logRec';

  OutputLogger(
    this._parentName, {
    String selfname = 'console',
    bool selfonly = false,
    bool listening = true,
  }) {
    _selfname = selfname;
    _selfonly = selfonly;
    _logName = '$_parentName.$_selfname';

    // leverage conditional constructor termination to toggle a class
    // between a functional logic provider and a pure data type.
    if (!listening) return;
    Logger(_parentName).onRecord.listen((LogRecord record) {
      if (_selfonly) {
        if (_logName == record.loggerName) output(record);
      } else {
        if (_parentName == record.loggerName) output(record);
      }
    });
  }

  String get name => _logName;

  void output([LogRecord? logRec]) =>
      logRec == null ? null : record(format(logRec));
}

/// output to log, use developer.log
final class DevOutputLogger extends OutputLogger {
  late final String __logName;

  DevOutputLogger(
    String parentName, {
    bool selfonly = false,
    super.selfname = 'developer',
  }) : super(parentName, listening: false) {
    __logName = '$_parentName.$_selfname';
    Logger(_parentName).onRecord.listen((LogRecord record) {
      if (selfonly) {
        if (__logName == record.loggerName) output(record);
      } else {
        if (parentName == record.loggerName) output(record);
      }
    });
  }

  @override
  String get name => __logName;

  @override
  void output([LogRecord? logRec]) {
    if (logRec == null) return;
    developer.log(
      logRec.message,
      time: logRec.time,
      sequenceNumber: logRec.sequenceNumber,
      level: logRec.level.value,
      name: logRec.loggerName,
      zone: logRec.zone,
      error: logRec.error,
      stackTrace: logRec.stackTrace,
    );
  }
}
