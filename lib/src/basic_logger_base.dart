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

  void debug(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(Level.FINE, message, error, stackTrace);

  void info(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(Level.INFO, message, error, stackTrace);

  void warning(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(Level.WARNING, message, error, stackTrace);

  void error(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(Level.SEVERE, message, error, stackTrace);

  void critical(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(Level.SHOUT, message, error, stackTrace);
}

abstract base class OutputLogger {
  final String _name;
  final String _parentName;

  OutputLogger(this._parentName, this._name);

  String get name => '$_parentName.$_name';

  void output();
}

final class FileOutputLogger extends OutputLogger {
  final List<LogRecord> _buffer = [];
  int _bufferSize = 10;
  String _logfile = '';

  FileOutputLogger({
    required String parentName,
    String name = 'basicFileLogger',
    String dir = '.',
    int bufferSize = 2,
  }) : super(parentName, name) {
    _bufferSize = bufferSize;
    _logfile = path.join(
        dir, '${DateTime.now().toLocal().toString().substring(0, 10)}.log');

    name = '$parentName.$name';
    Logger(name).onRecord.listen((LogRecord record) {
      _buffer.add(record);

      if (_buffer.length >= _bufferSize) {
        output();
      }
    });
  }

  @override
  void output() {
    final bufs = <String>[];
    for (LogRecord log in _buffer) {
      bufs.add(
          '${log.time}: [${log.level}] [${log.loggerName}] ${log.message} ${Platform.lineTerminator}');
    }
    unawaited(
      File(_logfile).writeAsString(
        bufs.join(),
        mode: FileMode.writeOnlyAppend,
      ),
    );
    bufs.clear();
    _buffer.clear();
  }
}

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
