import 'package:basic_logger/basic_logger.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final named = 'main';
    final basicLogger = BasicLogger('main');

    setUp(() {
      // Additional setup goes here.
    });

    test('basicLogger singleton', () {
      expect(basicLogger.name, equals(named));
    });
  });
}
