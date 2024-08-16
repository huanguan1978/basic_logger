import 'package:basic_logger/basic_logger.dart';
import 'package:logging/logging.dart';

void main() {
  // hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;

  final basicLogger = BasicLogger('main');

  // attach developer log
  basicLogger.attachLogger(DevOutputLogger(parentName: basicLogger.name));

  // attach console log
  final consoleLogger = basicLogger
      .attachLogger(ConsoleOutputLogger(parentName: basicLogger.name));
  consoleLogger.info('console output 1234');

  // attach file log, bufferSize default 10
  final fileOutputLogger = FileOutputLogger(parentName: basicLogger.name);
  final fileLogger = basicLogger.attachLogger(fileOutputLogger);
  fileLogger.info('file output 1234'); // output to file

  /*
  /// detach instance, get orphan logger,
  /// It can be useful when you just need a local short-living logger,
  /// which you'd like to be garbage-collected later.
  final notfileLogger = basicLogger.detachLogger(fileOutputLogger);
  notfileLogger.info('file output 12345'); // not output to file
  basicLogger.detachLogger(fileOutputLogger); // remove instance
  */

  basicLogger.debug('debug a1'); // output to all attach instance
  basicLogger.info('info a1'); // output to all attach instance

  // output buffer to all attach instance, not include detach instance
  basicLogger.output();

  // show all attach Logger instance name
  print(basicLogger.attachedNames);

  // show all attach OutputLogger instance name
  print(basicLogger.listenNames);

  basicLogger.attachLogger(FileOutputLogger(
    parentName: basicLogger.name,
    dir: './logs/',
    bufferSize: 100,
  ));
}
