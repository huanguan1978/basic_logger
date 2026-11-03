import 'package:basic_logger/basic_logger.dart';
import 'package:basic_logger/logging.dart';

void main() {
  // hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;

  final basicLogger = BasicLogger('main');

  // attach developer log
  basicLogger.attachLogger(DevOutputLogger(basicLogger.name));

  // attach output log, alias console
  // selfonly, if true filter by selfname, else parentName match are output.
  final consoleLogger = basicLogger.attachLogger(OutputLogger(
    basicLogger.name,
    // selfname: 'console',
    // selfonly: true,
  ));

  consoleLogger.info('console output 1234');
  basicLogger.debug('debug a1'); // output to all attach instance

  basicLogger.info('info a1'); // output to all attach instance

  // output buffer to all attach instance, not include detach instance
  basicLogger.output();

  // show all attach Logger instance name
  print(basicLogger.attachedNames);

  // show all attach OutputLogger instance name
  print(basicLogger.listenNames);

  // basicLogger children
  print(basicLogger.logger.children);
}
