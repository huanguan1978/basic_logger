/// Sub-library entrypoint re-exporting the underlying `logging` package.
///
/// ## Design Rationale
/// `BasicLogger` is built on top of Dart's standard `package:logging`. Downstream
/// applications often need to interact directly with standard logging primitives—such
/// as setting log thresholds via [Level], configuring [Logger.root], or formatting
/// [LogRecord] instances.
///
/// By providing this dedicated sub-library entrypoint, applications using
/// `basic_logger` can access the complete `package:logging` API on demand without
/// needing to declare an additional, redundant dependency on `logging` in their own
/// `pubspec.yaml`.
///
/// ## Typical Use Cases
/// - Configuring global or hierarchical log levels (`Level.ALL`, `Level.INFO`, etc.).
/// - Intercepting and listening to log streams (`Logger.root.onRecord.listen(...)`).
/// - Customizing log message formatting via [LogRecord] properties.
/// - Utilizing standard [Logger] instances in third-party or infrastructure modules.
///
/// ## Usage Example
/// ```dart
/// import 'package:basic_logger/basic_logger.dart';
/// import 'package:basic_logger/logging.dart';
///
/// void main() {
///   // Configure root log level using re-exported Level and Logger classes
///   Logger.root.level = Level.ALL;
///
///   final logger = BasicLogger('app');
///   logger.info('Application started');
/// }
/// ```
library;

export 'package:logging/logging.dart';
