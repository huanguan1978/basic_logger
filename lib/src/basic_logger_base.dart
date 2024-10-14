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
    for (var element in _listenLogs) {
      if (element.name == listenLogger.name) {
        _listenLogs.remove(element);
      }
    }
    /*
    if (_listenLogs.contains(listenLogger)) {
      _listenLogs.remove(listenLogger);
    }
    */
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
  }) {
    _selfname = selfname;
    _selfonly = selfonly;
    _logName = '$_parentName.$_selfname';
    Logger(_parentName).onRecord.listen((LogRecord record) {
      if (_selfonly && (_logName != record.loggerName)) return;
      output(record);
    });
  }

  String get name => _logName;

  void output([LogRecord? logRec]) =>
      logRec == null ? null : record(format(logRec));
}

/// output to log, use developer.log
final class DevOutputLogger extends OutputLogger {
  DevOutputLogger({
    required String parentName,
    String selfname = 'developer',
    bool selfonly = false,
  }) : super(parentName, selfname: selfname, selfonly: selfonly);

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
