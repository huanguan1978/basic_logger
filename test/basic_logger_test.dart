import 'package:basic_logger/basic_logger.dart';
import 'package:basic_logger/logging.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final named = 'main';
    final basicLogger = BasicLogger('main');

    setUp(() {
      Logger.root.level = Level.ALL;
    });

    test('basicLogger singleton', () {
      expect(basicLogger.name, equals(named));
    });

    test('all level methods record logs at correct levels', () {
      final records = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(records.add);

      basicLogger.finest('finest message');
      basicLogger.finer('finer message');
      basicLogger.fine('fine message');
      basicLogger.config('config message');
      basicLogger.info('info message');
      basicLogger.warning('warning message');
      basicLogger.severe('severe message');
      basicLogger.shout('shout message');

      // aliases
      basicLogger.debug('debug message');
      basicLogger.error('error message');
      basicLogger.critical('critical message');

      sub.cancel();

      expect(records.length, equals(11));
      expect(records[0].level, equals(Level.FINEST));
      expect(records[1].level, equals(Level.FINER));
      expect(records[2].level, equals(Level.FINE));
      expect(records[3].level, equals(Level.CONFIG));
      expect(records[4].level, equals(Level.INFO));
      expect(records[5].level, equals(Level.WARNING));
      expect(records[6].level, equals(Level.SEVERE));
      expect(records[7].level, equals(Level.SHOUT));

      expect(records[8].level, equals(Level.FINE));
      expect(records[9].level, equals(Level.SEVERE));
      expect(records[10].level, equals(Level.SHOUT));
    });

    test('isLoggable respects root and logger levels', () {
      Logger.root.level = Level.INFO;
      expect(basicLogger.isLoggable(Level.FINE), isFalse);
      expect(basicLogger.isLoggable(Level.INFO), isTrue);
      expect(basicLogger.isLoggable(Level.SEVERE), isTrue);
    });
  });
}
